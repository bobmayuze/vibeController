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
        "LT": CGPoint(x: -124.42344615933746, y: -60.494566028889444),
        "LB": CGPoint(x: -123.28555096506231, y: -80.53585130351419),
        "RT": CGPoint(x: 116.35700596004364, y: -59.08930560328747),
        "RB": CGPoint(x: 127.8842039343237, y: -82.23332507916514),
        "LeftStick": CGPoint(x: -147.6839345023522, y: 2.08622700200371),
        "RightStick": CGPoint(x: 148.84410379133055, y: 65.25821152191133),
        "DPad": CGPoint(x: -150.98512146128945, y: 50.09033122840975),
        "Back": CGPoint(x: -57.847679133204764, y: -73.79777760984308),
        "Start": CGPoint(x: 50.37942530330386, y: -73.50660623996629),
        "BtnY": CGPoint(x: 129.11520807679034, y: 19.26005757433967),
        "BtnX": CGPoint(x: 128.98023362377108, y: 1.2578441268882443),
        "BtnB": CGPoint(x: 129.355784077211, y: -16.628769823117736),
        "BtnA": CGPoint(x: 130.14057436058295, y: -33.98588480623606),
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
    
    private let baseWidth: CGFloat = 420 // 基准宽度
    
    var body: some View {
        GeometryReader { geo in
            let targetWidth = min(geo.size.width * 0.95, geo.size.height * 1.9) // SVG 宽高比约 1.9:1
            let scale = targetWidth / baseWidth
            
            ZStack {
                // 控制器背景图
                Image("ControllerImage")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: targetWidth)
            
            // LT - 左侧，文字在左
            DraggableButton(key: "LT", layout: layout, scale: scale) {
                SVGButtonOverlay(imageName: "LT", action: "拖拽", isActive: hid.ltActive, editMode: layout.isEditMode, size: 27 * scale, textAlign: .left, scale: scale)
            }
            
            // LB - 左侧，文字在左
            DraggableButton(key: "LB", layout: layout, scale: scale) {
                SVGButtonOverlay(imageName: "LB", action: "撤销", isActive: hid.pressedButtons.contains("LB"), editMode: layout.isEditMode, size: 27 * scale, textAlign: .left, scale: scale)
            }
            
            // RT - 右侧，文字在右
            DraggableButton(key: "RT", layout: layout, scale: scale) {
                SVGButtonOverlay(imageName: "RT", action: "回车", isActive: hid.rtActive, editMode: layout.isEditMode, size: 27 * scale, textAlign: .right, scale: scale)
            }
            
            // RB - 右侧，文字在右
            DraggableButton(key: "RB", layout: layout, scale: scale) {
                SVGButtonOverlay(imageName: "RB", action: "Opt+空格", isActive: hid.pressedButtons.contains("RB"), editMode: layout.isEditMode, size: 27 * scale, textAlign: .right, scale: scale)
            }
            
            // 左摇杆 - 左侧，文字在左
            DraggableButton(key: "LeftStick", layout: layout, scale: scale) {
                SVGStickOverlay(imageName: "LeftStick", action: "移动：鼠标", isActive: hid.leftStickActive, l3Label: "按下：回车", l3Active: hid.pressedButtons.contains("L3"), editMode: layout.isEditMode, stickX: hid.leftStickXValue, stickY: hid.leftStickYValue, size: 36 * scale, textAlign: .left, scale: scale)
            }
            
            // 右摇杆 - 右侧，文字在右
            DraggableButton(key: "RightStick", layout: layout, scale: scale) {
                SVGStickOverlay(imageName: "RightStick", action: "移动：滚动", isActive: hid.rightStickActive, l3Label: "按下：Esc", l3Active: hid.pressedButtons.contains("R3"), editMode: layout.isEditMode, stickX: hid.rightStickXValue, stickY: hid.rightStickYValue, size: 36 * scale, textAlign: .right, scale: scale)
            }
            
            // D-Pad - 左侧，文字在左
            DraggableButton(key: "DPad", layout: layout, scale: scale) {
                SVGButtonOverlay(imageName: "DPad", action: "方向键", isActive: hid.pressedButtons.contains("DPad"), editMode: layout.isEditMode, size: 35 * scale, textAlign: .left, scale: scale)
            }
            
            // Back 按钮 (View) - 左侧，文字在左
            DraggableButton(key: "Back", layout: layout, scale: scale) {
                SVGButtonOverlay(imageName: "ViewBtn", action: "App切换", isActive: hid.isAppSwitcherActive, editMode: layout.isEditMode, size: 20 * scale, textAlign: .left, scale: scale)
            }
            
            // Start 按钮 (Menu) - 右侧，文字在右
            DraggableButton(key: "Start", layout: layout, scale: scale) {
                SVGButtonOverlay(imageName: "MenuBtn", action: "命令面板", isActive: hid.pressedButtons.contains("Start"), editMode: layout.isEditMode, size: 20 * scale, textAlign: .right, scale: scale)
            }
            
            // Y 按钮 - 橙色，右侧，文字在右
            DraggableButton(key: "BtnY", layout: layout, scale: scale) {
                SVGButtonOverlay(imageName: "BtnY", action: "粘贴", isActive: hid.pressedButtons.contains("Y"), editMode: layout.isEditMode, size: 16 * scale, activeColor: .orange, textAlign: .right, scale: scale)
            }
            
            // X 按钮 - 蓝色，右侧，文字在右
            DraggableButton(key: "BtnX", layout: layout, scale: scale) {
                SVGButtonOverlay(imageName: "BtnX", action: "复制", isActive: hid.pressedButtons.contains("X"), editMode: layout.isEditMode, size: 16 * scale, activeColor: .blue, textAlign: .right, scale: scale)
            }
            
            // B 按钮 - 红色，右侧，文字在右
            DraggableButton(key: "BtnB", layout: layout, scale: scale) {
                SVGButtonOverlay(imageName: "BtnB", action: "右键", isActive: hid.pressedButtons.contains("B"), editMode: layout.isEditMode, size: 16 * scale, activeColor: .red, textAlign: .right, scale: scale)
            }
            
            // A 按钮 - 绿色，右侧，文字在右
            DraggableButton(key: "BtnA", layout: layout, scale: scale) {
                SVGButtonOverlay(imageName: "BtnA", action: "左键", isActive: hid.pressedButtons.contains("A"), editMode: layout.isEditMode, size: 16 * scale, activeColor: .green, textAlign: .right, scale: scale)
            }
        }
        .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}

// MARK: - 可拖拽按钮容器

struct DraggableButton<Content: View>: View {
    let key: String
    @ObservedObject var layout: ButtonLayoutManager
    var scale: CGFloat = 1.0
    let content: () -> Content
    
    @State private var dragOffset: CGSize = .zero
    
    var body: some View {
        content()
            .offset(x: (layout.position(for: key).x + dragOffset.width) * scale,
                    y: (layout.position(for: key).y + dragOffset.height) * scale)
            .gesture(
                layout.isEditMode ?
                DragGesture()
                    .onChanged { value in
                        dragOffset = CGSize(width: value.translation.width / scale, height: value.translation.height / scale)
                    }
                    .onEnded { value in
                        layout.updatePosition(for: key, offset: CGSize(width: value.translation.width / scale, height: value.translation.height / scale))
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

// MARK: - 文字对齐方向
enum TextAlign {
    case left, right, bottom
}

// MARK: - SVG 按钮叠加层

struct SVGButtonOverlay: View {
    let imageName: String
    let action: String
    let isActive: Bool
    var editMode: Bool = false
    var size: CGFloat = 32
    var activeColor: Color = .blue
    var textAlign: TextAlign = .bottom
    var scale: CGFloat = 1.0
    
    private var fontSize: CGFloat { 9 * scale }
    
    var body: some View {
        Group {
            switch textAlign {
            case .left:
                HStack(spacing: 3 * scale) {
                    actionText
                    buttonImage
                }
            case .right:
                HStack(spacing: 3 * scale) {
                    buttonImage
                    actionText
                }
            case .bottom:
                VStack(spacing: 2 * scale) {
                    buttonImage
                    actionText
                }
            }
        }
        .animation(.easeInOut(duration: 0.1), value: isActive)
    }
    
    private var buttonImage: some View {
        Image(imageName)
            .renderingMode(.template)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size, height: size)
            .foregroundColor((editMode || isActive) ? activeColor : .primary.opacity(0.6))
            .shadow(color: (editMode || isActive) ? activeColor.opacity(0.8) : .clear, radius: isActive ? 6 * scale : 0)
            .scaleEffect(isActive ? 1.15 : 1.0)
    }
    
    @ViewBuilder
    private var actionText: some View {
        if !action.isEmpty {
            Text(action)
                .font(.system(size: fontSize))
                .foregroundColor(isActive ? .primary : .secondary)
        }
    }
}

// MARK: - SVG 摇杆叠加层

struct SVGStickOverlay: View {
    let imageName: String
    let action: String
    let isActive: Bool
    let l3Label: String
    let l3Active: Bool
    var editMode: Bool = false
    var stickX: Float = 0
    var stickY: Float = 0
    var size: CGFloat = 52
    var textAlign: TextAlign = .bottom
    var scale: CGFloat = 1.0
    
    private var maxOffset: CGFloat { 6 * scale }
    private var fontSize: CGFloat { 9 * scale }
    
    var body: some View {
        Group {
            switch textAlign {
            case .left:
                HStack(spacing: 3 * scale) {
                    labelsView
                    stickImage
                }
            case .right:
                HStack(spacing: 3 * scale) {
                    stickImage
                    labelsView
                }
            case .bottom:
                VStack(spacing: 2 * scale) {
                    stickImage
                    labelsView
                }
            }
        }
        .animation(.easeInOut(duration: 0.05), value: stickX)
        .animation(.easeInOut(duration: 0.05), value: stickY)
    }
    
    private var stickImage: some View {
        Image(imageName)
            .renderingMode(.template)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size, height: size)
            .foregroundColor((editMode || isActive) ? .blue : .primary.opacity(0.6))
            .shadow(color: (editMode || isActive) ? .blue.opacity(0.8) : .clear, radius: isActive ? 6 * scale : 0)
            .offset(x: CGFloat(stickX) * maxOffset, y: CGFloat(stickY) * maxOffset)
    }
    
    private var labelsView: some View {
        VStack(alignment: textAlign == .left ? .trailing : .leading, spacing: 1 * scale) {
            Text(action)
                .font(.system(size: fontSize))
                .foregroundColor(isActive ? .primary : .secondary)
            
            Text(l3Label)
                .font(.system(size: fontSize))
                .foregroundColor(l3Active ? .primary : .secondary.opacity(0.6))
        }
    }
}
