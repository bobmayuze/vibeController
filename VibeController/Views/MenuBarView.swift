import SwiftUI

// MARK: - 菜单栏视图

struct MenuBarView: View {
    @ObservedObject var controllerManager = ControllerManager.shared
    @ObservedObject var configManager = ConfigManager.shared
    @ObservedObject var appController = AppController.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 连接状态
            HStack {
                Circle()
                    .fill(controllerManager.connectedController != nil ? Color.green : Color.red)
                    .frame(width: 8, height: 8)
                
                Text(controllerManager.connectedController != nil ? "手柄已连接" : "未连接")
                    .font(.headline)
            }
            
            if let info = controllerManager.controllerInfo {
                Text(info.name)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Divider()
            
            // 启用/暂停
            Toggle(isOn: $appController.isRunning) {
                Label(appController.isRunning ? "已启用" : "已暂停", 
                      systemImage: appController.isRunning ? "checkmark.circle.fill" : "pause.circle.fill")
            }
            
            Divider()
            
            // 配置切换
            Text("配置")
                .font(.caption)
                .foregroundColor(.secondary)
            
            ForEach(configManager.configs) { config in
                Button(action: { configManager.selectConfig(config) }) {
                    HStack {
                        if config.id == configManager.currentConfig.id {
                            Image(systemName: "checkmark")
                        }
                        Text(config.name)
                    }
                }
                .buttonStyle(.plain)
            }
            
            Divider()
            
            // 打开主窗口
            Button(action: openMainWindow) {
                Label("打开配置窗口", systemImage: "slider.horizontal.3")
            }
            .buttonStyle(.plain)
            
            Divider()
            
            // 退出
            Button(action: { NSApplication.shared.terminate(nil) }) {
                Label("退出", systemImage: "xmark.circle")
            }
            .buttonStyle(.plain)
        }
        .padding()
        .frame(width: 200)
    }
    
    private func openMainWindow() {
        NSApp.activate(ignoringOtherApps: true)
        if let window = NSApp.windows.first(where: { $0.title == "" || $0.contentView is NSHostingView<ControllerMapView> }) {
            window.makeKeyAndOrderFront(nil)
        } else {
            // 如果窗口不存在，创建新窗口
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 600, height: 500),
                styleMask: [.titled, .closable, .miniaturizable, .resizable],
                backing: .buffered,
                defer: false
            )
            window.contentView = NSHostingView(rootView: ControllerMapView())
            window.center()
            window.makeKeyAndOrderFront(nil)
        }
    }
}

#Preview {
    MenuBarView()
}
