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
        
        // 启动 App 切换监听器
        ActiveAppMonitor.shared.start()
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        HIDControllerManager.shared.stop()
        ActiveAppMonitor.shared.stop()
        if let activity = activity {
            ProcessInfo.processInfo.endActivity(activity)
        }
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false  // 状态栏继续运行
    }
}

// MARK: - 活动应用监听器

@MainActor
class ActiveAppMonitor: ObservableObject {
    static let shared = ActiveAppMonitor()
    
    @Published var currentAppBundleId: String = ""
    @Published var currentAppName: String = ""
    
    private var observer: NSObjectProtocol?
    
    private init() {}
    
    func start() {
        // 获取当前活动应用
        updateCurrentApp()
        
        // 监听应用激活通知
        observer = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didActivateApplicationNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            Task { @MainActor in
                self?.handleAppActivation(notification)
            }
        }
        print("✅ 活动应用监听器已启动")
    }
    
    func stop() {
        if let observer = observer {
            NSWorkspace.shared.notificationCenter.removeObserver(observer)
        }
        observer = nil
    }
    
    private func updateCurrentApp() {
        if let app = NSWorkspace.shared.frontmostApplication {
            currentAppBundleId = app.bundleIdentifier ?? ""
            currentAppName = app.localizedName ?? ""
        }
    }
    
    private func handleAppActivation(_ notification: Notification) {
        guard let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication else {
            return
        }
        
        let bundleId = app.bundleIdentifier ?? ""
        let appName = app.localizedName ?? ""
        
        // 忽略自己的应用
        if bundleId == Bundle.main.bundleIdentifier {
            return
        }
        
        currentAppBundleId = bundleId
        currentAppName = appName
        
        print("🔄 活动应用切换: \(appName) (\(bundleId))")
        
        // 尝试自动切换 Profile
        if let newConfig = ConfigManager.shared.switchToProfileForApp(bundleId) {
            print("✅ 自动切换到 Profile: \(newConfig.name)")
            // 显示切换通知
            ProfileSwitchOverlay.shared.show(profileName: newConfig.name)
        }
    }
}

// MARK: - Profile 切换 Overlay

@MainActor
class ProfileSwitchOverlay {
    static let shared = ProfileSwitchOverlay()
    
    private var window: NSWindow?
    private var hideTimer: Timer?
    
    private init() {}
    
    func show(profileName: String) {
        hideTimer?.invalidate()
        
        // 创建或更新窗口
        if window == nil {
            createWindow()
        }
        
        // 更新内容
        let contentView = ProfileSwitchOverlayView(profileName: profileName)
        window?.contentView = NSHostingView(rootView: contentView)
        
        // 定位到屏幕右上角
        positionWindow()
        
        // 显示
        window?.orderFrontRegardless()
        
        // 淡入动画
        window?.alphaValue = 0
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.2
            window?.animator().alphaValue = 1
        }
        
        // 2秒后自动隐藏
        hideTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
            Task { @MainActor in
                self?.hide()
            }
        }
    }
    
    func hide() {
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.3
            window?.animator().alphaValue = 0
        }, completionHandler: {
            self.window?.orderOut(nil)
        })
    }
    
    private func createWindow() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 280, height: 70),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        window.level = .floating
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = true
        window.collectionBehavior = [.canJoinAllSpaces, .stationary]
        window.ignoresMouseEvents = true
        
        self.window = window
    }
    
    private func positionWindow() {
        guard let window = window, let screen = NSScreen.main else { return }
        
        let screenFrame = screen.visibleFrame
        let windowSize = window.frame.size
        let padding: CGFloat = 20
        
        let x = screenFrame.maxX - windowSize.width - padding
        let y = screenFrame.maxY - windowSize.height - padding
        
        window.setFrameOrigin(NSPoint(x: x, y: y))
    }
}

// MARK: - Profile 切换 Overlay 视图

struct ProfileSwitchOverlayView: View {
    let profileName: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "gamecontroller.fill")
                .font(.system(size: 24))
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Profile switched to")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.7))
                
                Text(profileName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.88))
        )
    }
}
