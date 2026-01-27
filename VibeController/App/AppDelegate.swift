import SwiftUI
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    private var appController: AppController?
    private var activity: NSObjectProtocol?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // 禁用 App Nap，确保后台也能运行
        activity = ProcessInfo.processInfo.beginActivity(
            options: [.userInitiatedAllowingIdleSystemSleep, .latencyCritical],
            reason: "Controller input processing"
        )
        
        // 初始化 App 控制器
        appController = AppController.shared
        
        // 检查辅助功能权限
        checkAccessibilityPermission()
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        appController?.stop()
        if let activity = activity {
            ProcessInfo.processInfo.endActivity(activity)
        }
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false  // 关闭窗口后继续在菜单栏运行
    }
    
    private func checkAccessibilityPermission() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        let trusted = AXIsProcessTrustedWithOptions(options as CFDictionary)
        
        if !trusted {
            print("需要辅助功能权限才能控制鼠标和键盘")
        }
    }
}
