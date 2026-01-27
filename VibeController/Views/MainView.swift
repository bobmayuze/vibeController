import SwiftUI

// MARK: - View 条件修饰符扩展

extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

struct MainView: View {
    @ObservedObject var hid = HIDControllerManager.shared
    @State var accessOK = AXIsProcessTrusted()
    @StateObject var layout = ButtonLayoutManager.shared
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 0) {
            // 权限警告
            if !accessOK {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.orange)
                    Text("需要辅助功能权限")
                    Spacer()
                    Button("打开设置") {
                        NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                }
                .padding(10)
                .background(Color.orange.opacity(0.15))
            }
            
            // 标题栏
            HStack {
                Image(systemName: "gamecontroller.fill").font(.title2)
                Text("Vibe Controller").font(.headline)
                Spacer()
                
                // 编辑模式切换
                Toggle(isOn: $layout.isEditMode) {
                    Text("编辑布局")
                        .font(.caption)
                }
                .toggleStyle(.switch)
                .controlSize(.small)
                
                if layout.isEditMode {
                    Button("导出") { layout.exportToJSON() }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    
                    Button("重置") { layout.resetToDefault() }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                }
                
                Spacer().frame(width: 20)
                
                HStack(spacing: 6) {
                    Circle().fill(hid.isConnected ? .green : .red).frame(width: 8, height: 8)
                    Text(hid.isConnected ? "已连接" : "未连接").font(.caption)
                }
                .padding(.horizontal, 10).padding(.vertical, 4)
                .background(Color.gray.opacity(0.2)).cornerRadius(12)
            }
            .padding()
            
            Divider()
            
            // 手柄可视化
            ControllerOverlayView(hid: hid, layout: layout)
                .padding(.vertical, 10)
            
            Divider()
            
            // 底部
            HStack {
                if layout.isEditMode {
                    Text("拖拽按钮调整位置，完成后点击「导出」保存")
                        .font(.caption)
                        .foregroundColor(.orange)
                } else {
                    Text("窗口可关闭，程序在状态栏继续运行")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                if hid.isEnabled {
                    Label("控制已启用", systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.caption)
                } else {
                    Label("控制已暂停", systemImage: "pause.circle.fill")
                        .foregroundColor(.orange)
                        .font(.caption)
                }
            }
            .padding()
        }
        .frame(minWidth: 680, minHeight: 540)
        .onReceive(timer) { _ in accessOK = AXIsProcessTrusted() }
    }
}

// MARK: - 按钮布局管理器

class ButtonLayoutManager: ObservableObject {
    static let shared = ButtonLayoutManager()
    
    @Published var isEditMode = false
    @Published var positions: [String: CGPoint] = [:]
    
    private let configURL: URL = {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let folder = appSupport.appendingPathComponent("VibeController")
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder.appendingPathComponent("button_layout.json")
    }()
    
    // 默认位置 - 每个按钮单独
    static let defaultPositions: [String: CGPoint] = [
        "LT": CGPoint(x: -135.390625, y: -106.93359375),
        "LB": CGPoint(x: -174.6328125, y: -57.859375),
        "RT": CGPoint(x: 129.56640625, y: -106.921875),
        "RB": CGPoint(x: 161.62890625, y: -58.9921875),
        "LeftStick": CGPoint(x: -89.37109375, y: -25.89453125),
        "RightStick": CGPoint(x: 38.53125, y: 24.89453125),
        "DPad": CGPoint(x: -47.34765625, y: 22.484375),
        "Back": CGPoint(x: -29.42578125, y: -30.1796875),
        "Start": CGPoint(x: 18.09375, y: -29.80859375),
        "Xbox": CGPoint(x: -5.734375, y: -72.01953125),
        "BtnY": CGPoint(x: 79.4921875, y: -54.38671875),
        "BtnX": CGPoint(x: 56.48828125, y: -32.109375),
        "BtnB": CGPoint(x: 104.69921875, y: -31.23828125),
        "BtnA": CGPoint(x: 79.7421875, y: -9.09375),
    ]
    
    init() {
        loadFromJSON()
    }
    
    func position(for key: String) -> CGPoint {
        positions[key] ?? ButtonLayoutManager.defaultPositions[key] ?? .zero
    }
    
    func updatePosition(for key: String, offset: CGSize) {
        let current = position(for: key)
        positions[key] = CGPoint(x: current.x + offset.width, y: current.y + offset.height)
    }
    
    func loadFromJSON() {
        guard FileManager.default.fileExists(atPath: configURL.path) else {
            positions = ButtonLayoutManager.defaultPositions
            return
        }
        
        do {
            let data = try Data(contentsOf: configURL)
            let decoded = try JSONDecoder().decode([String: [String: CGFloat]].self, from: data)
            positions = decoded.mapValues { CGPoint(x: $0["x"] ?? 0, y: $0["y"] ?? 0) }
            print("✅ 已加载按钮布局配置")
        } catch {
            print("❌ 加载布局配置失败: \(error)")
            positions = ButtonLayoutManager.defaultPositions
        }
    }
    
    func exportToJSON() {
        let encoded = positions.mapValues { ["x": $0.x, "y": $0.y] }
        
        do {
            let data = try JSONEncoder().encode(encoded)
            let jsonString = String(data: data, encoding: .utf8)!
            
            // 保存到文件
            try data.write(to: configURL)
            print("✅ 已保存按钮布局到: \(configURL.path)")
            
            // 同时复制到剪贴板
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(jsonString, forType: .string)
            
            // 显示保存成功提示
            let alert = NSAlert()
            alert.messageText = "布局已保存"
            alert.informativeText = "配置已保存到:\n\(configURL.path)\n\nJSON 已复制到剪贴板"
            alert.alertStyle = .informational
            alert.addButton(withTitle: "好")
            alert.runModal()
            
        } catch {
            print("❌ 保存布局配置失败: \(error)")
        }
    }
    
    func resetToDefault() {
        positions = ButtonLayoutManager.defaultPositions
    }
}

// MARK: - 控制器叠加视图

struct ControllerOverlayView: View {
    @ObservedObject var hid: HIDControllerManager
    @ObservedObject var layout: ButtonLayoutManager
    
    let imgWidth: CGFloat = 420
    
    var body: some View {
        ZStack {
            // 控制器背景图
            Image("ControllerImage")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: imgWidth)
            
            // LT
            DraggableButton(key: "LT", layout: layout) {
                ButtonOverlay(label: "LT", action: "拖拽", isActive: hid.ltActive, editMode: layout.isEditMode)
            }
            
            // LB
            DraggableButton(key: "LB", layout: layout) {
                ButtonOverlay(label: "LB", action: "撤销", isActive: hid.pressedButtons.contains("LB"), editMode: layout.isEditMode)
            }
            
            // RT
            DraggableButton(key: "RT", layout: layout) {
                ButtonOverlay(label: "RT", action: "回车", isActive: hid.rtActive, editMode: layout.isEditMode)
            }
            
            // RB
            DraggableButton(key: "RB", layout: layout) {
                ButtonOverlay(label: "RB", action: "Opt+空格", isActive: hid.pressedButtons.contains("RB"), editMode: layout.isEditMode)
            }
            
            // 左摇杆
            DraggableButton(key: "LeftStick", layout: layout) {
                StickOverlay(label: "左摇杆", action: "鼠标", isActive: hid.leftStickActive, l3Label: "L3:回车", l3Active: hid.pressedButtons.contains("L3"), editMode: layout.isEditMode, stickX: hid.leftStickXValue, stickY: hid.leftStickYValue)
            }
            
            // 右摇杆
            DraggableButton(key: "RightStick", layout: layout) {
                StickOverlay(label: "右摇杆", action: "滚动", isActive: hid.rightStickActive, l3Label: "R3:Esc", l3Active: hid.pressedButtons.contains("R3"), editMode: layout.isEditMode, stickX: hid.rightStickXValue, stickY: hid.rightStickYValue)
            }
            
            // D-Pad
            DraggableButton(key: "DPad", layout: layout) {
                DPadOverlay(isActive: hid.pressedButtons.contains("DPad"), editMode: layout.isEditMode)
            }
            
            // Xbox 按钮
            DraggableButton(key: "Xbox", layout: layout) {
                Image("XboxLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 32, height: 32)
                    .if(layout.isEditMode) { $0.colorInvert() }
            }
            
            // Back 按钮
            DraggableButton(key: "Back", layout: layout) {
                VStack(spacing: 2) {
                    SmallButtonOverlay(isActive: hid.isAppSwitcherActive, editMode: layout.isEditMode)
                    Text("App切换").font(.system(size: 6)).foregroundColor(hid.isAppSwitcherActive ? .primary : .secondary)
                }
            }
            
            // Start 按钮
            DraggableButton(key: "Start", layout: layout) {
                VStack(spacing: 2) {
                    SmallButtonOverlay(isActive: hid.pressedButtons.contains("Start"), editMode: layout.isEditMode)
                    Text("命令面板").font(.system(size: 6)).foregroundColor(hid.pressedButtons.contains("Start") ? .primary : .secondary)
                }
            }
            
            // Y 按钮
            DraggableButton(key: "BtnY", layout: layout) {
                FaceBtnOverlay(letter: "Y", color: .yellow, action: "粘贴", isActive: hid.pressedButtons.contains("Y"), editMode: layout.isEditMode)
            }
            
            // X 按钮
            DraggableButton(key: "BtnX", layout: layout) {
                FaceBtnOverlay(letter: "X", color: .blue, action: "复制", isActive: hid.pressedButtons.contains("X"), editMode: layout.isEditMode)
            }
            
            // B 按钮
            DraggableButton(key: "BtnB", layout: layout) {
                FaceBtnOverlay(letter: "B", color: .red, action: "右键", isActive: hid.pressedButtons.contains("B"), editMode: layout.isEditMode)
            }
            
            // A 按钮
            DraggableButton(key: "BtnA", layout: layout) {
                FaceBtnOverlay(letter: "A", color: .green, action: "左键", isActive: hid.pressedButtons.contains("A"), editMode: layout.isEditMode)
            }
        }
    }
}

// MARK: - 可拖拽按钮容器

struct DraggableButton<Content: View>: View {
    let key: String
    @ObservedObject var layout: ButtonLayoutManager
    let content: () -> Content
    
    @State private var dragOffset: CGSize = .zero
    
    var body: some View {
        content()
            .offset(x: layout.position(for: key).x + dragOffset.width,
                    y: layout.position(for: key).y + dragOffset.height)
            .gesture(
                layout.isEditMode ?
                DragGesture()
                    .onChanged { value in
                        dragOffset = value.translation
                    }
                    .onEnded { value in
                        layout.updatePosition(for: key, offset: value.translation)
                        dragOffset = .zero
                    }
                : nil
            )
    }
}

// MARK: - 按钮叠加层

struct ButtonOverlay: View {
    let label: String
    let action: String
    let isActive: Bool
    var editMode: Bool = false
    
    var body: some View {
        VStack(spacing: 2) {
            ZStack {
                RoundedRectangle(cornerRadius: 5)
                    .fill((editMode || isActive) ? Color.black : Color.white)
                    .frame(width: 38, height: 18)
                
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.black, lineWidth: 1.5)
                    .frame(width: 38, height: 18)
                
                Text(label)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor((editMode || isActive) ? .white : .black)
            }
            
            Text(action)
                .font(.system(size: 7))
                .foregroundColor(isActive ? .primary : .secondary)
        }
        .animation(.easeInOut(duration: 0.1), value: isActive)
    }
}

// MARK: - 摇杆叠加层

struct StickOverlay: View {
    let label: String
    let action: String
    let isActive: Bool
    let l3Label: String
    let l3Active: Bool
    var editMode: Bool = false
    var stickX: Float = 0
    var stickY: Float = 0
    
    // 摇杆大小
    let outerSize: CGFloat = 52
    let innerRatio: CGFloat = 0.6  // 内圈占比 60%
    let maxOffset: CGFloat = 8     // 最大偏移量
    
    var body: some View {
        VStack(spacing: 2) {
            ZStack {
                // 外圈 - 底座
                Circle()
                    .fill(Color.white)
                    .frame(width: outerSize, height: outerSize)
                
                Circle()
                    .stroke(Color.black, lineWidth: 1.5)
                    .frame(width: outerSize, height: outerSize)
                
                // 内圈 - 摇杆头，根据推动方向偏移
                Circle()
                    .fill((editMode || isActive) ? Color.black : Color.white)
                    .frame(width: outerSize * innerRatio, height: outerSize * innerRatio)
                    .overlay(
                        Circle()
                            .stroke(Color.black, lineWidth: 1.5)
                    )
                    .overlay(
                        Text(editMode ? String(label.prefix(2)) : "")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                    )
                    .offset(x: CGFloat(stickX) * maxOffset, y: CGFloat(stickY) * maxOffset)
            }
            
            Text("\(label): \(action)")
                .font(.system(size: 7))
                .foregroundColor(isActive ? .primary : .secondary)
            
            Text(l3Label)
                .font(.system(size: 6))
                .foregroundColor(l3Active ? .primary : .secondary.opacity(0.6))
        }
        .animation(.easeInOut(duration: 0.05), value: stickX)
        .animation(.easeInOut(duration: 0.05), value: stickY)
    }
}

// MARK: - D-Pad 叠加层

struct DPadOverlay: View {
    let isActive: Bool
    var editMode: Bool = false
    
    var body: some View {
        VStack(spacing: 2) {
            ZStack {
                DPadHighlight()
                    .fill((editMode || isActive) ? Color.black : Color.white)
                    .frame(width: 50, height: 50)
                
                DPadHighlight()
                    .stroke(Color.black, lineWidth: 1.5)
                    .frame(width: 50, height: 50)
                
                Text(editMode ? "D" : "+")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor((editMode || isActive) ? .white : .black)
            }
            
            Text("方向键")
                .font(.system(size: 7))
                .foregroundColor(isActive ? .primary : .secondary)
        }
        .animation(.easeInOut(duration: 0.1), value: isActive)
    }
}

struct DPadHighlight: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width, h = rect.height
        let e: CGFloat = 0.33
        
        path.move(to: CGPoint(x: e * w, y: 0))
        path.addLine(to: CGPoint(x: (1 - e) * w, y: 0))
        path.addLine(to: CGPoint(x: (1 - e) * w, y: e * h))
        path.addLine(to: CGPoint(x: w, y: e * h))
        path.addLine(to: CGPoint(x: w, y: (1 - e) * h))
        path.addLine(to: CGPoint(x: (1 - e) * w, y: (1 - e) * h))
        path.addLine(to: CGPoint(x: (1 - e) * w, y: h))
        path.addLine(to: CGPoint(x: e * w, y: h))
        path.addLine(to: CGPoint(x: e * w, y: (1 - e) * h))
        path.addLine(to: CGPoint(x: 0, y: (1 - e) * h))
        path.addLine(to: CGPoint(x: 0, y: e * h))
        path.addLine(to: CGPoint(x: e * w, y: e * h))
        path.closeSubpath()
        return path
    }
}

// MARK: - ABXY 单独按钮

struct FaceBtnOverlay: View {
    let letter: String
    let color: Color
    let action: String
    let isActive: Bool
    var editMode: Bool = false
    
    var body: some View {
        VStack(spacing: 1) {
            ZStack {
                Circle()
                    .fill(editMode ? Color.black : (isActive ? color : Color.white))
                    .frame(width: 26, height: 26)
                
                Circle()
                    .stroke(Color.black, lineWidth: 1.5)
                    .frame(width: 26, height: 26)
                
                Text(letter)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor((editMode || isActive) ? .white : color)
            }
            
            Text(action)
                .font(.system(size: 6))
                .foregroundColor(isActive ? .primary : .secondary)
        }
        .animation(.easeInOut(duration: 0.1), value: isActive)
    }
}

// MARK: - 小按钮叠加层

struct SmallButtonOverlay: View {
    let isActive: Bool
    var editMode: Bool = false
    
    var body: some View {
        ZStack {
            Circle()
                .fill((editMode || isActive) ? Color.black : Color.white)
                .frame(width: 16, height: 16)
            
            Circle()
                .stroke(Color.black, lineWidth: 1.5)
                .frame(width: 16, height: 16)
        }
        .animation(.easeInOut(duration: 0.1), value: isActive)
    }
}
