import SwiftUI
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    private var activity: NSObjectProtocol?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // 禁用 App Nap
        activity = ProcessInfo.processInfo.beginActivity(
            options: [.userInitiated, .idleSystemSleepDisabled],
            reason: "Controller input"
        )
        
        // 检查辅助功能权限
        let opts = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        let trusted = AXIsProcessTrustedWithOptions(opts as CFDictionary)
        print("✅ 辅助功能权限: \(trusted ? "已授权" : "未授权")")
        
        // 启动 HID
        HIDControllerManager.shared.start()
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        HIDControllerManager.shared.stop()
        if let activity = activity {
            ProcessInfo.processInfo.endActivity(activity)
        }
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false  // 状态栏继续运行
    }
}
