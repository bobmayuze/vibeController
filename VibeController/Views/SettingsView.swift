import SwiftUI
import ServiceManagement

// MARK: - 设置面板

struct SettingsView: View {
    @ObservedObject var configManager = ConfigManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var cursorSpeed: Double
    @State private var scrollSpeed: Double
    @State private var deadZone: Double
    @State private var precisionMultiplier: Double
    @State private var launchAtLogin = false
    
    // 原始值
    private let originalCursorSpeed: Double
    private let originalScrollSpeed: Double
    private let originalDeadZone: Double
    private let originalPrecisionMultiplier: Double
    
    init() {
        let settings = ConfigManager.shared.currentConfig.settings
        _cursorSpeed = State(initialValue: settings.cursorSpeed)
        _scrollSpeed = State(initialValue: settings.scrollSpeed)
        _deadZone = State(initialValue: settings.deadZone)
        _precisionMultiplier = State(initialValue: settings.precisionMultiplier)
        
        self.originalCursorSpeed = settings.cursorSpeed
        self.originalScrollSpeed = settings.scrollSpeed
        self.originalDeadZone = settings.deadZone
        self.originalPrecisionMultiplier = settings.precisionMultiplier
    }
    
    // 检查是否有改动
    private var hasChanges: Bool {
        cursorSpeed != originalCursorSpeed ||
        scrollSpeed != originalScrollSpeed ||
        deadZone != originalDeadZone ||
        precisionMultiplier != originalPrecisionMultiplier
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 标题
            HStack {
                Text("设置")
                    .font(.headline)
                Spacer()
            }
            .padding()
            
            Divider()
            
            // 可滚动内容
            ScrollView {
                VStack(spacing: 20) {
                    // 摇杆设置
                    GroupBox("摇杆设置") {
                        VStack(spacing: 16) {
                            // 鼠标速度
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text("鼠标移动速度")
                                    Spacer()
                                    Text("\(Int(cursorSpeed))")
                                        .foregroundColor(.secondary)
                                }
                                Slider(value: $cursorSpeed, in: 100...2000, step: 50)
                            }
                            
                            // 滚动速度
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text("滚动速度")
                                    Spacer()
                                    Text(String(format: "%.1f", scrollSpeed))
                                        .foregroundColor(.secondary)
                                }
                                Slider(value: $scrollSpeed, in: 1...20, step: 0.5)
                            }
                            
                            // 死区
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text("摇杆死区")
                                    Spacer()
                                    Text(String(format: "%.0f%%", deadZone * 100))
                                        .foregroundColor(.secondary)
                                }
                                Slider(value: $deadZone, in: 0.05...0.4, step: 0.01)
                            }
                            
                            // 精准模式倍率
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text("精准模式速度")
                                    Spacer()
                                    Text(String(format: "%.0f%%", precisionMultiplier * 100))
                                        .foregroundColor(.secondary)
                                }
                                Slider(value: $precisionMultiplier, in: 0.1...0.8, step: 0.05)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    
                    // 系统设置
                    GroupBox("系统") {
                        VStack(alignment: .leading, spacing: 12) {
                            Toggle("开机时自动启动", isOn: $launchAtLogin)
                                .onChange(of: launchAtLogin) { newValue in
                                    setLaunchAtLogin(newValue)
                                }
                            
                            HStack {
                                Text("辅助功能权限")
                                Spacer()
                                if checkAccessibilityPermission() {
                                    Label("已授权", systemImage: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                } else {
                                    Button("去授权") {
                                        openAccessibilitySettings()
                                    }
                                    .buttonStyle(.borderedProminent)
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    
                    // 配置管理
                    GroupBox("配置管理") {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("当前配置: \(configManager.currentConfig.name)")
                                Spacer()
                            }
                            
                            HStack {
                                Button("重命名") {
                                    // TODO: 重命名配置
                                }
                                
                                Button("复制") {
                                    _ = configManager.duplicateConfig(configManager.currentConfig)
                                }
                                
                                Button("删除", role: .destructive) {
                                    if configManager.configs.count > 1 {
                                        configManager.deleteConfig(configManager.currentConfig)
                                    }
                                }
                                .disabled(configManager.configs.count <= 1)
                            }
                            
                            Button("恢复默认配置") {
                                resetToDefault()
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                .padding()
            }
            
            Divider()
            
            // 底部按钮
            HStack {
                // 还原按钮（只在有改动时显示）
                if hasChanges {
                    Button("还原") {
                        resetToOriginal()
                    }
                }
                
                Spacer()
                
                // 保存/关闭按钮
                Button(hasChanges ? "保存" : "关闭") {
                    if hasChanges {
                        saveSettings()
                    }
                    dismiss()
                }
                .keyboardShortcut(.return)
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .frame(width: 450, height: 550)
    }
    
    // MARK: - 方法
    
    private func resetToOriginal() {
        cursorSpeed = originalCursorSpeed
        scrollSpeed = originalScrollSpeed
        deadZone = originalDeadZone
        precisionMultiplier = originalPrecisionMultiplier
    }
    
    private func saveSettings() {
        var config = configManager.currentConfig
        config.settings = ControllerSettings(
            cursorSpeed: cursorSpeed,
            scrollSpeed: scrollSpeed,
            deadZone: deadZone,
            precisionMultiplier: precisionMultiplier
        )
        configManager.updateConfig(config)
    }
    
    private func resetToDefault() {
        let defaultSettings = ControllerSettings.default
        cursorSpeed = defaultSettings.cursorSpeed
        scrollSpeed = defaultSettings.scrollSpeed
        deadZone = defaultSettings.deadZone
        precisionMultiplier = defaultSettings.precisionMultiplier
    }
    
    private func checkAccessibilityPermission() -> Bool {
        return AXIsProcessTrusted()
    }
    
    private func openAccessibilitySettings() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
        NSWorkspace.shared.open(url)
    }
    
    private func setLaunchAtLogin(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            print("设置开机启动失败: \(error)")
        }
    }
}
