import SwiftUI

@main
struct VibeControllerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            MainView()
        }
        .windowResizability(.contentSize)
        
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 状态
            HStack {
                Circle().fill(hid.isConnected ? .green : .red).frame(width: 8, height: 8)
                Text(hid.isConnected ? hid.controllerName : "未连接")
            }
            
            Divider()
            
            // 开关
            Button(hid.isEnabled ? "✓ 已启用" : "  已禁用") {
                hid.toggleEnabled()
            }
            
            Divider()
            
            Button("退出") { NSApp.terminate(nil) }
        }
        .padding()
        .frame(width: 180)
    }
}
