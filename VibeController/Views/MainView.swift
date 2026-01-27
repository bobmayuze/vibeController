import SwiftUI

struct MainView: View {
    @ObservedObject var hid = HIDControllerManager.shared
    @State var accessOK = AXIsProcessTrusted()
    
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
                HStack(spacing: 6) {
                    Circle().fill(hid.isConnected ? .green : .red).frame(width: 8, height: 8)
                    Text(hid.isConnected ? "已连接" : "未连接").font(.caption)
                }
                .padding(.horizontal, 10).padding(.vertical, 4)
                .background(Color.gray.opacity(0.2)).cornerRadius(12)
            }
            .padding()
            
            Divider()
            
            // 手柄图 + 映射
            ZStack {
                Image("ControllerImage")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 450)
                    .opacity(0.9)
                
                HStack(spacing: 0) {
                    // 左侧
                    VStack(alignment: .trailing, spacing: 8) {
                        MapLabel("D-Pad", "方向键", active: hid.pressedButtons.contains("DPad"))
                        Spacer().frame(height: 20)
                        MapLabel("LB", "撤销 ⌘Z", active: hid.pressedButtons.contains("LB"))
                        MapLabel("LT", "拖拽模式", active: hid.ltActive)
                        Spacer().frame(height: 20)
                        MapLabel("左摇杆", "鼠标移动", active: hid.leftStickActive)
                        MapLabel("L3", "回车", active: hid.pressedButtons.contains("L3"))
                        Spacer()
                        MapLabel("Back", "App Switcher", active: hid.isAppSwitcherActive)
                    }
                    .frame(width: 140)
                    
                    Spacer().frame(width: 380)
                    
                    // 右侧
                    VStack(alignment: .leading, spacing: 8) {
                        MapLabel("Y", "粘贴 ⌘V", left: false, active: hid.pressedButtons.contains("Y"))
                        MapLabel("X", "复制 ⌘C", left: false, active: hid.pressedButtons.contains("X"))
                        Spacer().frame(height: 20)
                        MapLabel("RB", "Option+Space", left: false, active: hid.pressedButtons.contains("RB"))
                        MapLabel("RT", "回车", left: false, active: hid.rtActive)
                        Spacer().frame(height: 20)
                        MapLabel("A", "左键点击", left: false, active: hid.pressedButtons.contains("A"))
                        MapLabel("B", "右键点击", left: false, active: hid.pressedButtons.contains("B"))
                        MapLabel("右摇杆", "滚动", left: false, active: hid.rightStickActive)
                        MapLabel("R3", "Esc", left: false, active: hid.pressedButtons.contains("R3"))
                        Spacer()
                        MapLabel("Start", "命令面板", left: false, active: hid.pressedButtons.contains("Start"))
                    }
                    .frame(width: 140)
                }
            }
            .padding(.vertical, 30)
            
            Divider()
            
            // 底部
            HStack {
                Text("窗口可关闭，程序在状态栏继续运行")
                    .font(.caption)
                    .foregroundColor(.secondary)
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
        .frame(width: 700, height: 580)
        .onReceive(timer) { _ in accessOK = AXIsProcessTrusted() }
    }
}

// MARK: - 映射标签

struct MapLabel: View {
    let title: String
    let action: String
    var left = true
    var active = false
    
    init(_ title: String, _ action: String, left: Bool = true, active: Bool = false) {
        self.title = title
        self.action = action
        self.left = left
        self.active = active
    }
    
    var body: some View {
        HStack(spacing: 4) {
            if !left { line }
            VStack(alignment: left ? .trailing : .leading, spacing: 1) {
                Text(title).font(.system(size: 11, weight: .bold))
                Text(action).font(.system(size: 9)).foregroundColor(.secondary)
            }
            if left { line }
        }
        .padding(.horizontal, 6).padding(.vertical, 3)
        .background(RoundedRectangle(cornerRadius: 5).fill(active ? Color.green.opacity(0.3) : Color.clear))
        .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray.opacity(0.3), lineWidth: 1))
    }
    
    var line: some View {
        Rectangle().fill(Color.gray.opacity(0.4)).frame(width: 15, height: 1)
    }
}
