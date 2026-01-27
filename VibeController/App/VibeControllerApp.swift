import SwiftUI

@main
struct VibeControllerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            MainView()
        }
        .windowResizability(.contentMinSize)
        
        MenuBarExtra {
            MenuBarContent()
        } label: {
            Image(systemName: HIDControllerManager.shared.isConnected ? "gamecontroller.fill" : "gamecontroller")
        }
    }
}

// MARK: - 菜单栏内容

struct MenuBarContent: View {
    @ObservedObject var hid = HIDControllerManager.shared
    @Environment(\.openWindow) private var openWindow
    
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    
    var body: some View {
        // 版本号
        Text("VibeController v\(appVersion)")
            .foregroundColor(.secondary)
        
        Divider()
        
        // 状态
        HStack {
            Circle().fill(hid.isConnected ? .green : .red).frame(width: 8, height: 8)
            Text(hid.isConnected ? hid.controllerName : "未连接")
        }
        
        // 开关
        Toggle(isOn: Binding(
            get: { hid.isEnabled },
            set: { _ in hid.toggleEnabled() }
        )) {
            Text("启用控制")
        }
        
        Divider()
        
        Button("Settings...") {
            NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        }
        .keyboardShortcut(",", modifiers: .command)
        
        Button("Check for Updates...") {
            // TODO: 实现更新检查
        }
        
        Divider()
        
        Button("Quit") {
            NSApp.terminate(nil)
        }
        .keyboardShortcut("q", modifiers: .command)
    }
}
