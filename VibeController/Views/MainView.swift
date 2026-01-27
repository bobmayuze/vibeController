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

// MARK: - 语言管理器

enum AppLanguage: String, CaseIterable {
    case english = "en"
    case japanese = "ja"
    case simplifiedChinese = "zh-Hans"
    case traditionalChinese = "zh-Hant"
    
    var displayName: String {
        switch self {
        case .english: return "English"
        case .japanese: return "日本語"
        case .simplifiedChinese: return "简体中文"
        case .traditionalChinese: return "繁體中文"
        }
    }
}

class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    @Published var currentLanguage: AppLanguage {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: "appLanguage")
        }
    }
    
    init() {
        let saved = UserDefaults.standard.string(forKey: "appLanguage") ?? "zh-Hans"
        currentLanguage = AppLanguage(rawValue: saved) ?? .simplifiedChinese
    }
    
    // MARK: - 本地化字符串
    func localized(_ key: String) -> String {
        let strings: [String: [AppLanguage: String]] = [
            "needAccessibility": [
                .english: "Accessibility permission required",
                .japanese: "アクセシビリティ権限が必要です",
                .simplifiedChinese: "需要辅助功能权限",
                .traditionalChinese: "需要輔助功能權限"
            ],
            "openSettings": [
                .english: "Open Settings",
                .japanese: "設定を開く",
                .simplifiedChinese: "打开设置",
                .traditionalChinese: "打開設定"
            ],
            "editLayout": [
                .english: "Edit Layout",
                .japanese: "レイアウト編集",
                .simplifiedChinese: "编辑布局",
                .traditionalChinese: "編輯佈局"
            ],
            "export": [
                .english: "Export",
                .japanese: "エクスポート",
                .simplifiedChinese: "导出",
                .traditionalChinese: "匯出"
            ],
            "reset": [
                .english: "Reset",
                .japanese: "リセット",
                .simplifiedChinese: "重置",
                .traditionalChinese: "重置"
            ],
            "connected": [
                .english: "Connected",
                .japanese: "接続済み",
                .simplifiedChinese: "已连接",
                .traditionalChinese: "已連接"
            ],
            "disconnected": [
                .english: "Disconnected",
                .japanese: "未接続",
                .simplifiedChinese: "未连接",
                .traditionalChinese: "未連接"
            ],
            "dragHint": [
                .english: "Drag buttons to adjust position, auto-saved",
                .japanese: "ボタンをドラッグして調整、自動保存されます",
                .simplifiedChinese: "拖拽按钮调整位置，自动保存",
                .traditionalChinese: "拖曳按鈕調整位置，自動保存"
            ],
            "windowHint": [
                .english: "Window can be closed, app continues in menu bar",
                .japanese: "ウィンドウを閉じてもメニューバーで動作継続",
                .simplifiedChinese: "窗口可关闭，程序在状态栏继续运行",
                .traditionalChinese: "視窗可關閉，程式在狀態列繼續運行"
            ],
            "controlEnabled": [
                .english: "Control Enabled",
                .japanese: "コントロール有効",
                .simplifiedChinese: "控制已启用",
                .traditionalChinese: "控制已啟用"
            ],
            "controlPaused": [
                .english: "Control Paused",
                .japanese: "コントロール一時停止",
                .simplifiedChinese: "控制已暂停",
                .traditionalChinese: "控制已暫停"
            ],
            // 按钮动作
            "undo": [
                .english: "Undo",
                .japanese: "元に戻す",
                .simplifiedChinese: "撤销",
                .traditionalChinese: "撤銷"
            ],
            "drag": [
                .english: "Drag",
                .japanese: "ドラッグ",
                .simplifiedChinese: "拖拽",
                .traditionalChinese: "拖曳"
            ],
            "enter": [
                .english: "Enter",
                .japanese: "Enter",
                .simplifiedChinese: "回车",
                .traditionalChinese: "Enter"
            ],
            "optSpace": [
                .english: "Opt+Space",
                .japanese: "Opt+スペース",
                .simplifiedChinese: "Opt+空格",
                .traditionalChinese: "Opt+空格"
            ],
            "moveMouse": [
                .english: "Move: Mouse",
                .japanese: "移動：マウス",
                .simplifiedChinese: "移动：鼠标",
                .traditionalChinese: "移動：滑鼠"
            ],
            "pressEnter": [
                .english: "Press: Enter",
                .japanese: "押下：Enter",
                .simplifiedChinese: "按下：回车",
                .traditionalChinese: "按下：Enter"
            ],
            "moveScroll": [
                .english: "Move: Scroll",
                .japanese: "移動：スクロール",
                .simplifiedChinese: "移动：滚动",
                .traditionalChinese: "移動：滾動"
            ],
            "pressEsc": [
                .english: "Press: Esc",
                .japanese: "押下：Esc",
                .simplifiedChinese: "按下：Esc",
                .traditionalChinese: "按下：Esc"
            ],
            "dpadUp": [
                .english: "↑",
                .japanese: "↑",
                .simplifiedChinese: "↑",
                .traditionalChinese: "↑"
            ],
            "dpadDown": [
                .english: "↓",
                .japanese: "↓",
                .simplifiedChinese: "↓",
                .traditionalChinese: "↓"
            ],
            "dpadLeft": [
                .english: "←",
                .japanese: "←",
                .simplifiedChinese: "←",
                .traditionalChinese: "←"
            ],
            "dpadRight": [
                .english: "→",
                .japanese: "→",
                .simplifiedChinese: "→",
                .traditionalChinese: "→"
            ],
            "appSwitch": [
                .english: "App Switch",
                .japanese: "アプリ切替",
                .simplifiedChinese: "App切换",
                .traditionalChinese: "App切換"
            ],
            "cmdPalette": [
                .english: "Cmd Palette",
                .japanese: "コマンドパレット",
                .simplifiedChinese: "命令面板",
                .traditionalChinese: "命令面板"
            ],
            "paste": [
                .english: "Paste",
                .japanese: "貼り付け",
                .simplifiedChinese: "粘贴",
                .traditionalChinese: "貼上"
            ],
            "copy": [
                .english: "Copy",
                .japanese: "コピー",
                .simplifiedChinese: "复制",
                .traditionalChinese: "複製"
            ],
            "rightClick": [
                .english: "Right Click",
                .japanese: "右クリック",
                .simplifiedChinese: "右键",
                .traditionalChinese: "右鍵"
            ],
            "leftClick": [
                .english: "Left Click",
                .japanese: "左クリック",
                .simplifiedChinese: "左键",
                .traditionalChinese: "左鍵"
            ],
            "layoutSaved": [
                .english: "Layout Saved",
                .japanese: "レイアウト保存済み",
                .simplifiedChinese: "布局已保存",
                .traditionalChinese: "佈局已保存"
            ],
            "layoutSavedMsg": [
                .english: "Config saved to:\n%@\n\nJSON copied to clipboard",
                .japanese: "設定保存先:\n%@\n\nJSONをクリップボードにコピーしました",
                .simplifiedChinese: "配置已保存到:\n%@\n\nJSON 已复制到剪贴板",
                .traditionalChinese: "配置已保存到:\n%@\n\nJSON 已複製到剪貼簿"
            ],
            "ok": [
                .english: "OK",
                .japanese: "OK",
                .simplifiedChinese: "好",
                .traditionalChinese: "好"
            ],
            "exportConfig": [
                .english: "Export",
                .japanese: "エクスポート",
                .simplifiedChinese: "导出",
                .traditionalChinese: "導出"
            ],
            "loadConfig": [
                .english: "Load",
                .japanese: "インポート",
                .simplifiedChinese: "导入",
                .traditionalChinese: "導入"
            ],
            "exportSuccess": [
                .english: "Config exported successfully",
                .japanese: "設定をエクスポートしました",
                .simplifiedChinese: "配置导出成功",
                .traditionalChinese: "配置導出成功"
            ],
            "loadSuccess": [
                .english: "Config loaded successfully",
                .japanese: "設定をインポートしました",
                .simplifiedChinese: "配置导入成功",
                .traditionalChinese: "配置導入成功"
            ],
            "loadError": [
                .english: "Failed to load config",
                .japanese: "設定の読み込みに失敗しました",
                .simplifiedChinese: "配置导入失败",
                .traditionalChinese: "配置導入失敗"
            ]
        ]
        
        return strings[key]?[currentLanguage] ?? strings[key]?[.english] ?? key
    }
}

struct MainView: View {
    @ObservedObject var hid = HIDControllerManager.shared
    @ObservedObject var l10n = LocalizationManager.shared
    @State var accessOK = AXIsProcessTrusted()
    @StateObject var layout = ButtonLayoutManager.shared
    @StateObject var configManager = ConfigManager.shared
    @State private var editingButton: ControllerButton?
    @State private var editingChord: ButtonChord?
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 0) {
            // 权限警告
            if !accessOK {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.orange)
                    Text(l10n.localized("needAccessibility"))
                    Spacer()
                    Button(l10n.localized("openSettings")) {
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
                
                // 语言选择
                Picker("", selection: $l10n.currentLanguage) {
                    ForEach(AppLanguage.allCases, id: \.self) { lang in
                        Text(lang.displayName).tag(lang)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 100)
                
                Spacer().frame(width: 12)
                
                // 编辑模式切换
                Toggle(isOn: $layout.isEditMode) {
                    Text(l10n.localized("editLayout"))
                        .font(.caption)
                }
                .toggleStyle(.switch)
                .controlSize(.small)
                
                if layout.isEditMode {
                    Button(l10n.localized("reset")) { layout.resetToDefault() }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                }
                
                Spacer().frame(width: 20)
                
                HStack(spacing: 6) {
                    Circle().fill(hid.isConnected ? .green : .red).frame(width: 8, height: 8)
                    if hid.isConnected {
                        Text(hid.controllerName.isEmpty ? l10n.localized("connected") : hid.controllerName)
                            .font(.caption)
                            .lineLimit(1)
                    } else {
                        Text(l10n.localized("disconnected")).font(.caption)
                    }
                }
                .padding(.horizontal, 10).padding(.vertical, 4)
                .background(Color.gray.opacity(0.2)).cornerRadius(12)
            }
            .padding()
            
            Divider()
            
            // 主内容区域：左边手柄可视化，右边组合键列表
            HStack(spacing: 0) {
                // 手柄可视化
                ControllerOverlayView(hid: hid, layout: layout, l10n: l10n, configManager: configManager, editingButton: $editingButton)
                    .padding(.vertical, 10)
                
                Divider()
                
                // 组合键列表
                ChordListView(configManager: configManager, l10n: l10n, editingChord: $editingChord)
                    .frame(width: 200)
            }
            
            Divider()
            
            // 底部
            HStack {
                if layout.isEditMode {
                    Text(l10n.localized("dragHint"))
                        .font(.caption)
                        .foregroundColor(.orange)
                } else {
                    Text(l10n.localized("windowHint"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                
                // Export/Load 按钮
                Button(action: { exportFullConfig() }) {
                    Label(l10n.localized("exportConfig"), systemImage: "square.and.arrow.up")
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                
                Button(action: { loadFullConfig() }) {
                    Label(l10n.localized("loadConfig"), systemImage: "square.and.arrow.down")
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                
                Spacer()
                
                if hid.isEnabled {
                    Label(l10n.localized("controlEnabled"), systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.caption)
                } else {
                    Label(l10n.localized("controlPaused"), systemImage: "pause.circle.fill")
                        .foregroundColor(.orange)
                        .font(.caption)
                }
            }
            .padding()
        }
        .frame(minWidth: 880, minHeight: 540)
        .onReceive(timer) { _ in accessOK = AXIsProcessTrusted() }
        .sheet(item: $editingButton) { button in
            KeymapEditorView(button: button, configManager: configManager, l10n: l10n)
        }
        .sheet(item: $editingChord) { chord in
            UnifiedChordEditorView(mode: .edit(chord), configManager: configManager, l10n: l10n)
        }
    }
    
    // MARK: - 导出完整配置
    
    private func exportFullConfig() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.json]
        panel.nameFieldStringValue = "vibe_controller_config.json"
        panel.title = l10n.localized("exportConfig")
        
        panel.begin { response in
            guard response == .OK, let url = panel.url else { return }
            
            // 创建完整配置结构
            let fullConfig = FullExportConfig(
                buttonPositions: layout.positions.mapValues { ["x": $0.x, "y": $0.y] },
                keyMappings: configManager.currentConfig
            )
            
            do {
                let encoder = JSONEncoder()
                encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
                let data = try encoder.encode(fullConfig)
                try data.write(to: url)
                
                print("✅ 导出成功:")
                print("   - 按钮映射: \(fullConfig.keyMappings.mappings.count) 个")
                print("   - 组合键: \(fullConfig.keyMappings.chordMappings.count) 个")
                for (chord, action) in fullConfig.keyMappings.chordMappings {
                    print("     \(chord.displayName) → \(action.displayName)")
                }
                
                DispatchQueue.main.async {
                    let alert = NSAlert()
                    alert.messageText = l10n.localized("exportSuccess")
                    alert.informativeText = url.path
                    alert.alertStyle = .informational
                    alert.runModal()
                }
            } catch {
                print("❌ 导出失败: \(error)")
            }
        }
    }
    
    // MARK: - 导入完整配置
    
    private func loadFullConfig() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.json]
        panel.allowsMultipleSelection = false
        panel.title = l10n.localized("loadConfig")
        
        panel.begin { response in
            guard response == .OK, let url = panel.url else { return }
            
            do {
                let data = try Data(contentsOf: url)
                let fullConfig = try JSONDecoder().decode(FullExportConfig.self, from: data)
                
                // 恢复按钮位置
                layout.positions = fullConfig.buttonPositions.mapValues {
                    CGPoint(x: $0["x"] ?? 0, y: $0["y"] ?? 0)
                }
                layout.savePositions()
                
                // 恢复键位映射
                var updatedConfig = fullConfig.keyMappings
                updatedConfig.id = configManager.currentConfig.id // 保持当前ID
                configManager.updateConfig(updatedConfig)
                
                DispatchQueue.main.async {
                    let alert = NSAlert()
                    alert.messageText = l10n.localized("loadSuccess")
                    alert.alertStyle = .informational
                    alert.runModal()
                }
            } catch {
                print("❌ 导入失败: \(error)")
                DispatchQueue.main.async {
                    let alert = NSAlert()
                    alert.messageText = l10n.localized("loadError")
                    alert.informativeText = error.localizedDescription
                    alert.alertStyle = .warning
                    alert.runModal()
                }
            }
        }
    }
}

// MARK: - 完整配置导出结构

struct FullExportConfig: Codable {
    let buttonPositions: [String: [String: CGFloat]]
    let keyMappings: ControllerConfig
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
        "DPadUp": CGPoint(x: -151, y: 35),
        "DPadDown": CGPoint(x: -151, y: 75),
        "DPadLeft": CGPoint(x: -171, y: 55),
        "DPadRight": CGPoint(x: -131, y: 55),
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
        saveToFile()
    }
    
    func savePositions() {
        saveToFile()
    }
    
    private func saveToFile() {
        let encoded = positions.mapValues { ["x": $0.x, "y": $0.y] }
        do {
            let data = try JSONEncoder().encode(encoded)
            try data.write(to: configURL)
            print("✅ 布局已自动保存")
        } catch {
            print("❌ 自动保存失败: \(error)")
        }
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
    
    func exportToJSON(l10n: LocalizationManager? = nil) {
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
            alert.messageText = l10n?.localized("layoutSaved") ?? "Layout Saved"
            let msgTemplate = l10n?.localized("layoutSavedMsg") ?? "Config saved to:\n%@\n\nJSON copied to clipboard"
            alert.informativeText = String(format: msgTemplate, configURL.path)
            alert.alertStyle = .informational
            alert.addButton(withTitle: l10n?.localized("ok") ?? "OK")
            alert.runModal()
            
        } catch {
            print("❌ 保存布局配置失败: \(error)")
        }
    }
    
    func resetToDefault() {
        positions = ButtonLayoutManager.defaultPositions
        saveToFile()
    }
}

// MARK: - 控制器叠加视图

struct ControllerOverlayView: View {
    @ObservedObject var hid: HIDControllerManager
    @ObservedObject var layout: ButtonLayoutManager
    @ObservedObject var l10n: LocalizationManager
    @ObservedObject var configManager: ConfigManager
    @Binding var editingButton: ControllerButton?
    
    private let baseWidth: CGFloat = 420 // 基准宽度
    
    // 从 layout key 映射到 ControllerButton
    private func controllerButton(for key: String) -> ControllerButton? {
        switch key {
        case "BtnA": return .buttonA
        case "BtnB": return .buttonB
        case "BtnX": return .buttonX
        case "BtnY": return .buttonY
        case "LB": return .leftBumper
        case "RB": return .rightBumper
        case "LT": return .leftTrigger
        case "RT": return .rightTrigger
        case "LeftStick": return .leftStickButton
        case "RightStick": return .rightStickButton
        case "Back": return .backButton
        case "Start": return .startButton
        default: return nil
        }
    }
    
    // 获取按钮的动作显示名称
    private func actionDisplayName(for button: ControllerButton) -> String {
        let action = configManager.action(for: button)
        return action.displayName
    }
    
    // 获取摇杆按下的标签（带"按下："前缀）
    private func stickPressLabel(for button: ControllerButton) -> String {
        let action = configManager.action(for: button)
        let pressPrefix: String
        switch l10n.currentLanguage {
        case .english: pressPrefix = "Press: "
        case .japanese: pressPrefix = "押下: "
        case .simplifiedChinese: pressPrefix = "按下: "
        case .traditionalChinese: pressPrefix = "按下: "
        }
        return pressPrefix + action.displayName
    }
    
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
            DraggableButton(key: "LT", layout: layout, scale: scale, onTap: { editingButton = .leftTrigger }) {
                SVGButtonOverlay(imageName: "LT", action: actionDisplayName(for: .leftTrigger), isActive: hid.ltActive, editMode: layout.isEditMode, size: 27 * scale, textAlign: .left, scale: scale)
            }
            
            // LB - 左侧，文字在左
            DraggableButton(key: "LB", layout: layout, scale: scale, onTap: { editingButton = .leftBumper }) {
                SVGButtonOverlay(imageName: "LB", action: actionDisplayName(for: .leftBumper), isActive: hid.pressedButtons.contains("LB"), editMode: layout.isEditMode, size: 27 * scale, textAlign: .left, scale: scale)
            }
            
            // RT - 右侧，文字在右
            DraggableButton(key: "RT", layout: layout, scale: scale, onTap: { editingButton = .rightTrigger }) {
                SVGButtonOverlay(imageName: "RT", action: actionDisplayName(for: .rightTrigger), isActive: hid.rtActive, editMode: layout.isEditMode, size: 27 * scale, textAlign: .right, scale: scale)
            }
            
            // RB - 右侧，文字在右
            DraggableButton(key: "RB", layout: layout, scale: scale, onTap: { editingButton = .rightBumper }) {
                SVGButtonOverlay(imageName: "RB", action: actionDisplayName(for: .rightBumper), isActive: hid.pressedButtons.contains("RB"), editMode: layout.isEditMode, size: 27 * scale, textAlign: .right, scale: scale)
            }
            
            // 左摇杆 - 左侧，文字在左
            DraggableButton(key: "LeftStick", layout: layout, scale: scale, onTap: { editingButton = .leftStickButton }) {
                SVGStickOverlay(imageName: "LeftStick", action: l10n.localized("moveMouse"), isActive: hid.leftStickActive, l3Label: stickPressLabel(for: .leftStickButton), l3Active: hid.pressedButtons.contains("L3"), editMode: layout.isEditMode, stickX: hid.leftStickXValue, stickY: hid.leftStickYValue, size: 36 * scale, textAlign: .left, scale: scale)
            }
            
            // 右摇杆 - 右侧，文字在右
            DraggableButton(key: "RightStick", layout: layout, scale: scale, onTap: { editingButton = .rightStickButton }) {
                SVGStickOverlay(imageName: "RightStick", action: l10n.localized("moveScroll"), isActive: hid.rightStickActive, l3Label: stickPressLabel(for: .rightStickButton), l3Active: hid.pressedButtons.contains("R3"), editMode: layout.isEditMode, stickX: hid.rightStickXValue, stickY: hid.rightStickYValue, size: 36 * scale, textAlign: .right, scale: scale)
            }
            
            // D-Pad Up
            DraggableButton(key: "DPadUp", layout: layout, scale: scale, onTap: { editingButton = .dpadUp }) {
                SVGButtonOverlay(imageName: "DPadUp", action: actionDisplayName(for: .dpadUp), isActive: hid.pressedButtons.contains("DPadUp"), editMode: layout.isEditMode, size: 20 * scale, textAlign: .left, scale: scale)
            }
            
            // D-Pad Down
            DraggableButton(key: "DPadDown", layout: layout, scale: scale, onTap: { editingButton = .dpadDown }) {
                SVGButtonOverlay(imageName: "DPadDown", action: actionDisplayName(for: .dpadDown), isActive: hid.pressedButtons.contains("DPadDown"), editMode: layout.isEditMode, size: 20 * scale, textAlign: .left, scale: scale)
            }
            
            // D-Pad Left
            DraggableButton(key: "DPadLeft", layout: layout, scale: scale, onTap: { editingButton = .dpadLeft }) {
                SVGButtonOverlay(imageName: "DPadLeft", action: actionDisplayName(for: .dpadLeft), isActive: hid.pressedButtons.contains("DPadLeft"), editMode: layout.isEditMode, size: 20 * scale, textAlign: .left, scale: scale)
            }
            
            // D-Pad Right
            DraggableButton(key: "DPadRight", layout: layout, scale: scale, onTap: { editingButton = .dpadRight }) {
                SVGButtonOverlay(imageName: "DPadRight", action: actionDisplayName(for: .dpadRight), isActive: hid.pressedButtons.contains("DPadRight"), editMode: layout.isEditMode, size: 20 * scale, textAlign: .left, scale: scale)
            }
            
            // Back 按钮 (View) - 左侧，文字在左
            DraggableButton(key: "Back", layout: layout, scale: scale, onTap: { editingButton = .backButton }) {
                SVGButtonOverlay(imageName: "ViewBtn", action: actionDisplayName(for: .backButton), isActive: hid.isAppSwitcherActive, editMode: layout.isEditMode, size: 20 * scale, textAlign: .left, scale: scale)
            }
            
            // Start 按钮 (Menu) - 右侧，文字在右
            DraggableButton(key: "Start", layout: layout, scale: scale, onTap: { editingButton = .startButton }) {
                SVGButtonOverlay(imageName: "MenuBtn", action: actionDisplayName(for: .startButton), isActive: hid.pressedButtons.contains("Start"), editMode: layout.isEditMode, size: 20 * scale, textAlign: .right, scale: scale)
            }
            
            // Y 按钮 - 橙色，右侧，文字在右
            DraggableButton(key: "BtnY", layout: layout, scale: scale, onTap: { editingButton = .buttonY }) {
                SVGButtonOverlay(imageName: "BtnY", action: actionDisplayName(for: .buttonY), isActive: hid.pressedButtons.contains("Y"), editMode: layout.isEditMode, size: 16 * scale, activeColor: .orange, textAlign: .right, scale: scale)
            }
            
            // X 按钮 - 蓝色，右侧，文字在右
            DraggableButton(key: "BtnX", layout: layout, scale: scale, onTap: { editingButton = .buttonX }) {
                SVGButtonOverlay(imageName: "BtnX", action: actionDisplayName(for: .buttonX), isActive: hid.pressedButtons.contains("X"), editMode: layout.isEditMode, size: 16 * scale, activeColor: .blue, textAlign: .right, scale: scale)
            }
            
            // B 按钮 - 红色，右侧，文字在右
            DraggableButton(key: "BtnB", layout: layout, scale: scale, onTap: { editingButton = .buttonB }) {
                SVGButtonOverlay(imageName: "BtnB", action: actionDisplayName(for: .buttonB), isActive: hid.pressedButtons.contains("B"), editMode: layout.isEditMode, size: 16 * scale, activeColor: .red, textAlign: .right, scale: scale)
            }
            
            // A 按钮 - 绿色，右侧，文字在右
            DraggableButton(key: "BtnA", layout: layout, scale: scale, onTap: { editingButton = .buttonA }) {
                SVGButtonOverlay(imageName: "BtnA", action: actionDisplayName(for: .buttonA), isActive: hid.pressedButtons.contains("A"), editMode: layout.isEditMode, size: 16 * scale, activeColor: .green, textAlign: .right, scale: scale)
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
    var onTap: (() -> Void)? = nil
    let content: () -> Content
    
    @State private var dragOffset: CGSize = .zero
    
    var body: some View {
        content()
            .contentShape(Rectangle())
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
            .onTapGesture {
                if !layout.isEditMode {
                    onTap?()
                }
            }
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
            
            Text("D-Pad")
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
        VStack(alignment: .leading, spacing: 1 * scale) {
            Text(action)
                .font(.system(size: fontSize))
                .foregroundColor(isActive ? .primary : .secondary)
            
            Text(l3Label)
                .font(.system(size: fontSize))
                .foregroundColor(l3Active ? .primary : .secondary.opacity(0.6))
        }
    }
}

// MARK: - 键位编辑器

struct KeymapEditorView: View {
    let button: ControllerButton
    @ObservedObject var configManager: ConfigManager
    @ObservedObject var l10n: LocalizationManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var actionType: ActionType = .none
    @State private var mouseButton: MouseButton = .left
    @State private var modifiers: ModifierKeys = []
    @State private var selectedKey: KeyOption = .none
    
    // 常用按键选项
    enum KeyOption: String, CaseIterable {
        case none = "—"
        // 常用特殊键
        case space = "Space"
        case returnKey = "Return ↵"
        case escape = "Esc"
        case tab = "Tab"
        case delete = "Delete"
        // 方向键
        case upArrow = "↑"
        case downArrow = "↓"
        case leftArrow = "←"
        case rightArrow = "→"
        // 字母
        case a = "A", b = "B", c = "C", d = "D", e = "E", f = "F", g = "G", h = "H"
        case i = "I", j = "J", k = "K", l = "L", m = "M", n = "N", o = "O", p = "P"
        case q = "Q", r = "R", s = "S", t = "T", u = "U", v = "V", w = "W", x = "X"
        case y = "Y", z = "Z"
        // 数字
        case num0 = "0", num1 = "1", num2 = "2", num3 = "3", num4 = "4"
        case num5 = "5", num6 = "6", num7 = "7", num8 = "8", num9 = "9"
        // 功能键
        case f1 = "F1", f2 = "F2", f3 = "F3", f4 = "F4", f5 = "F5", f6 = "F6"
        case f7 = "F7", f8 = "F8", f9 = "F9", f10 = "F10", f11 = "F11", f12 = "F12"
        
        var keyCode: Int {
            switch self {
            case .none: return -1
            case .a: return 0x00
            case .b: return 0x0B
            case .c: return 0x08
            case .d: return 0x02
            case .e: return 0x0E
            case .f: return 0x03
            case .g: return 0x05
            case .h: return 0x04
            case .i: return 0x22
            case .j: return 0x26
            case .k: return 0x28
            case .l: return 0x25
            case .m: return 0x2E
            case .n: return 0x2D
            case .o: return 0x1F
            case .p: return 0x23
            case .q: return 0x0C
            case .r: return 0x0F
            case .s: return 0x01
            case .t: return 0x11
            case .u: return 0x20
            case .v: return 0x09
            case .w: return 0x0D
            case .x: return 0x07
            case .y: return 0x10
            case .z: return 0x06
            case .num0: return 0x1D
            case .num1: return 0x12
            case .num2: return 0x13
            case .num3: return 0x14
            case .num4: return 0x15
            case .num5: return 0x17
            case .num6: return 0x16
            case .num7: return 0x1A
            case .num8: return 0x1C
            case .num9: return 0x19
            case .returnKey: return 0x24
            case .escape: return 0x35
            case .tab: return 0x30
            case .space: return 0x31
            case .delete: return 0x33
            case .upArrow: return 0x7E
            case .downArrow: return 0x7D
            case .leftArrow: return 0x7B
            case .rightArrow: return 0x7C
            case .f1: return 0x7A
            case .f2: return 0x78
            case .f3: return 0x63
            case .f4: return 0x76
            case .f5: return 0x60
            case .f6: return 0x61
            case .f7: return 0x62
            case .f8: return 0x64
            case .f9: return 0x65
            case .f10: return 0x6D
            case .f11: return 0x67
            case .f12: return 0x6F
            }
        }
        
        var displayName: String {
            switch self {
            case .none: return ""
            case .space: return "Space"
            case .returnKey: return "↵"
            case .escape: return "Esc"
            case .tab: return "Tab"
            case .delete: return "⌫"
            case .upArrow: return "↑"
            case .downArrow: return "↓"
            case .leftArrow: return "←"
            case .rightArrow: return "→"
            case .f1, .f2, .f3, .f4, .f5, .f6, .f7, .f8, .f9, .f10, .f11, .f12:
                return rawValue  // F1-F12 直接返回
            default: return rawValue  // 字母和数字直接返回
            }
        }
    }
    
    init(button: ControllerButton, configManager: ConfigManager, l10n: LocalizationManager) {
        self.button = button
        self.configManager = configManager
        self.l10n = l10n
        
        // 从当前配置初始化状态
        let action = configManager.action(for: button)
        _actionType = State(initialValue: action.type)
        _mouseButton = State(initialValue: action.mouseButton ?? .left)
        _modifiers = State(initialValue: action.modifiers ?? [])
        
        // 根据 keyCode 找到对应的 KeyOption
        if let keyCode = action.keyCode {
            let found = KeyOption.allCases.first { $0.keyCode == keyCode }
            _selectedKey = State(initialValue: found ?? .none)
        } else {
            _selectedKey = State(initialValue: .none)
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // 标题
            HStack {
                Text(localizedTitle("editKeymap"))
                    .font(.headline)
                Text(button.displayName)
                    .font(.headline)
                    .foregroundColor(.blue)
                Spacer()
            }
            
            Divider()
            
            // 表单内容
            Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 12) {
                // 动作类型选择
                GridRow {
                    Text(localizedTitle("actionType"))
                        .gridColumnAlignment(.leading)
                    Picker("", selection: $actionType) {
                        Text(localizedTitle("mouseClick")).tag(ActionType.mouseClick)
                        Text(localizedTitle("mouseDrag")).tag(ActionType.mouseDrag)
                        Text(localizedTitle("shortcut")).tag(ActionType.shortcut)
                        Text(localizedTitle("noAction")).tag(ActionType.none)
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()
                }
                
                // 根据动作类型显示不同配置
                switch actionType {
                case .mouseClick:
                    GridRow {
                        Text(localizedTitle("mouseBtn"))
                        Picker("", selection: $mouseButton) {
                            Text(localizedTitle("leftBtn")).tag(MouseButton.left)
                            Text(localizedTitle("rightBtn")).tag(MouseButton.right)
                            Text(localizedTitle("middleBtn")).tag(MouseButton.middle)
                        }
                        .pickerStyle(.segmented)
                        .labelsHidden()
                    }
                case .shortcut:
                    GridRow {
                        Text(localizedTitle("modifiers"))
                        HStack(spacing: 8) {
                            ModifierToggle(label: "⌘", isOn: Binding(
                                get: { modifiers.contains(.command) },
                                set: { if $0 { modifiers.insert(.command) } else { modifiers.remove(.command) } }
                            ))
                            ModifierToggle(label: "⌥", isOn: Binding(
                                get: { modifiers.contains(.option) },
                                set: { if $0 { modifiers.insert(.option) } else { modifiers.remove(.option) } }
                            ))
                            ModifierToggle(label: "⌃", isOn: Binding(
                                get: { modifiers.contains(.control) },
                                set: { if $0 { modifiers.insert(.control) } else { modifiers.remove(.control) } }
                            ))
                            ModifierToggle(label: "⇧", isOn: Binding(
                                get: { modifiers.contains(.shift) },
                                set: { if $0 { modifiers.insert(.shift) } else { modifiers.remove(.shift) } }
                            ))
                            Spacer()
                        }
                    }
                    GridRow {
                        Text(localizedTitle("key"))
                        Picker("", selection: $selectedKey) {
                            ForEach(KeyOption.allCases, id: \.self) { key in
                                Text(key.rawValue).tag(key)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                case .mouseDrag, .none, .command, .text, .mouseMove, .scroll:
                    EmptyView()
                }
                
                // 预览
                GridRow {
                    Text(localizedTitle("preview"))
                        .foregroundColor(.secondary)
                    HStack {
                        Spacer()
                        Text(previewText)
                            .font(.system(.body, design: .monospaced))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(6)
                    }
                }
            }
            
            Spacer()
            
            Divider()
            
            // 按钮
            HStack {
                Button(localizedTitle("cancel")) {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
                
                Spacer()
                
                Button(localizedTitle("save")) {
                    saveAndDismiss()
                }
                .keyboardShortcut(.defaultAction)
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(20)
        .frame(width: 400, height: 320)
    }
    
    
    private var previewText: String {
        switch actionType {
        case .mouseClick:
            return mouseButton.displayName
        case .mouseDrag:
            return localizedTitle("mouseDrag")
        case .shortcut:
            let mods = modifiers.displayString
            let key = selectedKey == .none ? "" : selectedKey.displayName
            return mods.isEmpty ? key : "\(mods)\(key)"
        default:
            return localizedTitle("noAction")
        }
    }
    
    private func saveAndDismiss() {
        let action: Action
        switch actionType {
        case .mouseClick:
            action = Action(type: .mouseClick, mouseButton: mouseButton)
        case .mouseDrag:
            action = .drag
        case .shortcut:
            if selectedKey == .none {
                action = .none
            } else {
                action = Action(type: .shortcut, modifiers: modifiers, keyCode: selectedKey.keyCode, keyDisplay: selectedKey.displayName)
            }
        default:
            action = .none
        }
        
        configManager.setAction(action, for: button)
        dismiss()
    }
    
    private func localizedTitle(_ key: String) -> String {
        let strings: [String: [AppLanguage: String]] = [
            "editKeymap": [
                .english: "Edit Keymap:",
                .japanese: "キーマップ編集:",
                .simplifiedChinese: "编辑键位:",
                .traditionalChinese: "編輯鍵位:"
            ],
            "actionType": [
                .english: "Action",
                .japanese: "アクション",
                .simplifiedChinese: "动作类型",
                .traditionalChinese: "動作類型"
            ],
            "mouseClick": [
                .english: "Click",
                .japanese: "クリック",
                .simplifiedChinese: "点击",
                .traditionalChinese: "點擊"
            ],
            "mouseDrag": [
                .english: "Drag",
                .japanese: "ドラッグ",
                .simplifiedChinese: "拖拽",
                .traditionalChinese: "拖曳"
            ],
            "shortcut": [
                .english: "Shortcut",
                .japanese: "ショートカット",
                .simplifiedChinese: "快捷键",
                .traditionalChinese: "快捷鍵"
            ],
            "noAction": [
                .english: "None",
                .japanese: "なし",
                .simplifiedChinese: "无动作",
                .traditionalChinese: "無動作"
            ],
            "mouseBtn": [
                .english: "Button",
                .japanese: "ボタン",
                .simplifiedChinese: "按钮",
                .traditionalChinese: "按鈕"
            ],
            "leftBtn": [
                .english: "Left",
                .japanese: "左",
                .simplifiedChinese: "左键",
                .traditionalChinese: "左鍵"
            ],
            "rightBtn": [
                .english: "Right",
                .japanese: "右",
                .simplifiedChinese: "右键",
                .traditionalChinese: "右鍵"
            ],
            "middleBtn": [
                .english: "Middle",
                .japanese: "中央",
                .simplifiedChinese: "中键",
                .traditionalChinese: "中鍵"
            ],
            "modifiers": [
                .english: "Modifiers",
                .japanese: "修飾キー",
                .simplifiedChinese: "修饰键",
                .traditionalChinese: "修飾鍵"
            ],
            "key": [
                .english: "Key",
                .japanese: "キー",
                .simplifiedChinese: "按键",
                .traditionalChinese: "按鍵"
            ],
            "preview": [
                .english: "Preview:",
                .japanese: "プレビュー:",
                .simplifiedChinese: "预览:",
                .traditionalChinese: "預覽:"
            ],
            "cancel": [
                .english: "Cancel",
                .japanese: "キャンセル",
                .simplifiedChinese: "取消",
                .traditionalChinese: "取消"
            ],
            "save": [
                .english: "Save",
                .japanese: "保存",
                .simplifiedChinese: "保存",
                .traditionalChinese: "保存"
            ]
        ]
        return strings[key]?[l10n.currentLanguage] ?? strings[key]?[.english] ?? key
    }
}

// MARK: - 组合键列表视图

struct ChordListView: View {
    @ObservedObject var configManager: ConfigManager
    @ObservedObject var l10n: LocalizationManager
    @Binding var editingChord: ButtonChord?
    @State private var showingAddSheet = false
    @State private var duplicatingChord: ButtonChord?
    
    var body: some View {
        VStack(spacing: 0) {
            // 标题栏
            HStack {
                Text(localizedTitle("chordMappings"))
                    .font(.headline)
                Spacer()
                Button(action: { showingAddSheet = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                }
                .buttonStyle(.plain)
                .foregroundColor(.blue)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            
            Divider()
            
            // 组合键列表
            if configManager.currentConfig.chordMappings.isEmpty {
                VStack(spacing: 8) {
                    Spacer()
                    Image(systemName: "keyboard")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    Text(localizedTitle("noChords"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    Spacer()
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 4) {
                        ForEach(configManager.allChords, id: \.id) { chord in
                            ChordRowView(
                                chord: chord,
                                action: configManager.action(for: chord),
                                l10n: l10n,
                                onTap: { editingChord = chord },
                                onDelete: { configManager.setAction(.none, for: chord) },
                                onDuplicate: { duplicateChord(chord) }
                            )
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                }
            }
        }
        .background(Color(NSColor.controlBackgroundColor))
        .sheet(isPresented: $showingAddSheet) {
            UnifiedChordEditorView(mode: .add, configManager: configManager, l10n: l10n)
        }
        .sheet(item: $duplicatingChord) { chord in
            UnifiedChordEditorView(mode: .duplicate(chord), configManager: configManager, l10n: l10n)
        }
    }
    
    private func duplicateChord(_ chord: ButtonChord) {
        duplicatingChord = chord
    }
    
    private func localizedTitle(_ key: String) -> String {
        let strings: [String: [AppLanguage: String]] = [
            "chordMappings": [
                .english: "Combo Keys",
                .japanese: "コンボキー",
                .simplifiedChinese: "组合键",
                .traditionalChinese: "組合鍵"
            ],
            "noChords": [
                .english: "No combo keys\nTap + to add",
                .japanese: "コンボキーなし\n+をタップして追加",
                .simplifiedChinese: "暂无组合键\n点击 + 添加",
                .traditionalChinese: "暫無組合鍵\n點擊 + 添加"
            ]
        ]
        return strings[key]?[l10n.currentLanguage] ?? strings[key]?[.english] ?? key
    }
}

// MARK: - 组合键行视图

struct ChordRowView: View {
    let chord: ButtonChord
    let action: Action
    var l10n: LocalizationManager = .shared
    var onTap: () -> Void
    var onDelete: () -> Void
    var onDuplicate: () -> Void
    
    @State private var isHovering = false
    
    var body: some View {
        HStack(spacing: 8) {
            // 组合键显示
            HStack(spacing: 2) {
                // 显示所有修饰键
                ForEach(chord.modifiers.sorted { $0.rawValue < $1.rawValue }, id: \.self) { modifier in
                    if modifier != chord.modifiers.sorted(by: { $0.rawValue < $1.rawValue }).first {
                        Text("+")
                            .font(.system(size: 9))
                            .foregroundColor(.secondary)
                    }
                    Text(modifier.shortName)
                        .font(.system(size: 10, weight: .semibold))
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(3)
                }
                
                Text("+")
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
                
                Text(chord.button.shortName)
                    .font(.system(size: 10, weight: .semibold))
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(Color.green.opacity(0.2))
                    .cornerRadius(3)
            }
            
            Spacer()
            
            // 动作显示
            Text(action.displayName)
                .font(.system(size: 10))
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(isHovering ? Color.blue.opacity(0.1) : Color.clear)
        .cornerRadius(6)
        .contentShape(Rectangle())
        .onTapGesture { onTap() }
        .onHover { isHovering = $0 }
        .contextMenu {
            Button {
                onDuplicate()
            } label: {
                Label(localizedTitle("duplicate"), systemImage: "doc.on.doc")
            }
            
            Divider()
            
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label(localizedTitle("delete"), systemImage: "trash")
            }
        }
    }
    
    private func localizedTitle(_ key: String) -> String {
        let strings: [String: [AppLanguage: String]] = [
            "duplicate": [
                .english: "Duplicate",
                .japanese: "複製",
                .simplifiedChinese: "复制",
                .traditionalChinese: "複製"
            ],
            "delete": [
                .english: "Delete",
                .japanese: "削除",
                .simplifiedChinese: "删除",
                .traditionalChinese: "刪除"
            ]
        ]
        return strings[key]?[l10n.currentLanguage] ?? strings[key]?[.english] ?? key
    }
}

// MARK: - 统一组合键编辑器

enum ChordEditorMode {
    case add
    case edit(ButtonChord)
    case duplicate(ButtonChord)
    
    var isEditing: Bool {
        if case .edit = self { return true }
        return false
    }
    
    var sourceChord: ButtonChord? {
        switch self {
        case .add: return nil
        case .edit(let chord), .duplicate(let chord): return chord
        }
    }
}

struct UnifiedChordEditorView: View {
    let mode: ChordEditorMode
    @ObservedObject var configManager: ConfigManager
    @ObservedObject var l10n: LocalizationManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedModifiers: Set<ControllerButton>
    @State private var selectedButton: ControllerButton
    @State private var macModifiers: ModifierKeys
    @State private var selectedKey: KeymapEditorView.KeyOption
    
    init(mode: ChordEditorMode, configManager: ConfigManager, l10n: LocalizationManager) {
        self.mode = mode
        self.configManager = configManager
        self.l10n = l10n
        
        // 根据模式初始化状态
        switch mode {
        case .add:
            _selectedModifiers = State(initialValue: [.leftTrigger])
            _selectedButton = State(initialValue: .dpadUp)
            _macModifiers = State(initialValue: [])
            _selectedKey = State(initialValue: .upArrow)
            
        case .edit(let chord), .duplicate(let chord):
            _selectedModifiers = State(initialValue: chord.modifiers)
            _selectedButton = State(initialValue: chord.button)
            
            let action = configManager.action(for: chord)
            _macModifiers = State(initialValue: action.modifiers ?? [])
            
            if let keyCode = action.keyCode {
                let found = KeymapEditorView.KeyOption.allCases.first { $0.keyCode == keyCode }
                _selectedKey = State(initialValue: found ?? .none)
            } else {
                _selectedKey = State(initialValue: .none)
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            Text(titleText)
                .font(.headline)
            
            Divider()
            
            // 手柄组合键配置
            VStack(alignment: .leading, spacing: 4) {
                Text(localizedTitle("modifier"))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(localizedTitle("modifierHint"))
                    .font(.caption)
                    .foregroundColor(.secondary.opacity(0.8))
                
                HStack(spacing: 8) {
                    ForEach(ButtonChord.modifierButtons, id: \.self) { button in
                        Button(action: { toggleModifier(button) }) {
                            Text(button.shortName)
                                .font(.system(size: 12, weight: .medium))
                                .frame(width: 44, height: 32)
                                .background(selectedModifiers.contains(button) ? Color.blue : Color.gray.opacity(0.2))
                                .foregroundColor(selectedModifiers.contains(button) ? .white : .primary)
                                .cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            
            // 主按钮选择
            VStack(alignment: .leading, spacing: 8) {
                Text(localizedTitle("button"))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 8) {
                    ForEach(ButtonChord.modifiableButtons, id: \.self) { button in
                        Button(action: { selectedButton = button }) {
                            Text(button.shortName)
                                .font(.system(size: 12, weight: .medium))
                                .frame(width: 50, height: 32)
                                .background(selectedButton == button ? Color.blue : Color.gray.opacity(0.2))
                                .foregroundColor(selectedButton == button ? .white : .primary)
                                .cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            
            // 手柄组合预览
            HStack {
                Text(localizedTitle("preview"))
                    .foregroundColor(.secondary)
                Spacer()
                Text(previewText)
                    .font(.system(.body, design: .monospaced))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(6)
            }
            
            Divider()
            
            // Mac 快捷键配置
            VStack(alignment: .leading, spacing: 8) {
                Text(localizedTitle("macAction"))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 8) {
                    GridRow {
                        Text(localizedTitle("macModifiers"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        HStack(spacing: 6) {
                            ModifierToggle(label: "⌘", isOn: Binding(
                                get: { macModifiers.contains(.command) },
                                set: { if $0 { macModifiers.insert(.command) } else { macModifiers.remove(.command) } }
                            ))
                            ModifierToggle(label: "⌥", isOn: Binding(
                                get: { macModifiers.contains(.option) },
                                set: { if $0 { macModifiers.insert(.option) } else { macModifiers.remove(.option) } }
                            ))
                            ModifierToggle(label: "⌃", isOn: Binding(
                                get: { macModifiers.contains(.control) },
                                set: { if $0 { macModifiers.insert(.control) } else { macModifiers.remove(.control) } }
                            ))
                            ModifierToggle(label: "⇧", isOn: Binding(
                                get: { macModifiers.contains(.shift) },
                                set: { if $0 { macModifiers.insert(.shift) } else { macModifiers.remove(.shift) } }
                            ))
                            Spacer()
                        }
                    }
                    
                    GridRow {
                        Text(localizedTitle("macKey"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Picker("", selection: $selectedKey) {
                            ForEach(KeymapEditorView.KeyOption.allCases, id: \.self) { key in
                                Text(key.rawValue).tag(key)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    GridRow {
                        Text(localizedTitle("output"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        HStack {
                            Spacer()
                            Text(macPreviewText)
                                .font(.system(.body, design: .monospaced))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(6)
                        }
                    }
                }
            }
            
            Spacer()
            
            Divider()
            
            // 按钮
            HStack {
                Button(localizedTitle("cancel")) { dismiss() }
                    .keyboardShortcut(.cancelAction)
                
                Spacer()
                
                Button(saveButtonText) {
                    saveAndDismiss()
                }
                .keyboardShortcut(.defaultAction)
                .buttonStyle(.borderedProminent)
                .disabled(isSaveDisabled)
            }
        }
        .padding(20)
        .frame(width: 380, height: 520)
    }
    
    private var titleText: String {
        switch mode {
        case .add: return localizedTitle("addChord")
        case .edit: return localizedTitle("editChord")
        case .duplicate: return localizedTitle("duplicateChord")
        }
    }
    
    private var saveButtonText: String {
        switch mode {
        case .add: return localizedTitle("add")
        case .edit: return localizedTitle("save")
        case .duplicate: return localizedTitle("duplicate")
        }
    }
    
    private var isSaveDisabled: Bool {
        if selectedModifiers.isEmpty || selectedKey == .none { return true }
        // 检查组合键是否已存在（编辑模式下允许保存自己）
        let newChord = ButtonChord(modifiers: selectedModifiers, button: selectedButton)
        if case .edit(let originalChord) = mode, newChord.id == originalChord.id {
            return false
        }
        return configManager.action(for: newChord).type != .none
    }
    
    private func toggleModifier(_ button: ControllerButton) {
        if selectedModifiers.contains(button) {
            selectedModifiers.remove(button)
        } else {
            selectedModifiers.insert(button)
        }
    }
    
    private var previewText: String {
        guard !selectedModifiers.isEmpty else { return selectedButton.shortName }
        let modifierNames = selectedModifiers.sorted { $0.rawValue < $1.rawValue }.map { $0.shortName }.joined(separator: " + ")
        return "\(modifierNames) + \(selectedButton.shortName)"
    }
    
    private var macPreviewText: String {
        let mods = macModifiers.displayString
        let key = selectedKey == .none ? "" : selectedKey.displayName
        return mods.isEmpty ? key : "\(mods)\(key)"
    }
    
    private func saveAndDismiss() {
        let newChord = ButtonChord(modifiers: selectedModifiers, button: selectedButton)
        
        // 如果是编辑模式且组合键发生变化，删除旧的
        if case .edit(let originalChord) = mode, newChord.id != originalChord.id {
            configManager.setAction(.none, for: originalChord)
        }
        
        let action: Action
        if selectedKey == .none {
            action = .none
        } else {
            action = Action(type: .shortcut, modifiers: macModifiers, keyCode: selectedKey.keyCode, keyDisplay: selectedKey.displayName)
        }
        configManager.setAction(action, for: newChord)
        dismiss()
    }
    
    private func localizedTitle(_ key: String) -> String {
        let strings: [String: [AppLanguage: String]] = [
            "addChord": [
                .english: "Add Combo Key",
                .japanese: "コンボキーを追加",
                .simplifiedChinese: "添加组合键",
                .traditionalChinese: "添加組合鍵"
            ],
            "editChord": [
                .english: "Edit Combo Key",
                .japanese: "コンボキーを編集",
                .simplifiedChinese: "编辑组合键",
                .traditionalChinese: "編輯組合鍵"
            ],
            "duplicateChord": [
                .english: "Duplicate Combo Key",
                .japanese: "コンボキーを複製",
                .simplifiedChinese: "复制组合键",
                .traditionalChinese: "複製組合鍵"
            ],
            "modifier": [
                .english: "Hold Modifier",
                .japanese: "修飾キー（押し続ける）",
                .simplifiedChinese: "修饰键（按住不放）",
                .traditionalChinese: "修飾鍵（按住不放）"
            ],
            "modifierHint": [
                .english: "Hold this button first, then press the button below",
                .japanese: "このボタンを押したまま、下のボタンを押してください",
                .simplifiedChinese: "先按住此键不放，再按下方按钮触发",
                .traditionalChinese: "先按住此鍵不放，再按下方按鈕觸發"
            ],
            "button": [
                .english: "Then Press",
                .japanese: "その後押す",
                .simplifiedChinese: "然后按",
                .traditionalChinese: "然後按"
            ],
            "preview": [
                .english: "Combo:",
                .japanese: "コンボ:",
                .simplifiedChinese: "组合:",
                .traditionalChinese: "組合:"
            ],
            "macAction": [
                .english: "Mac Action",
                .japanese: "Macアクション",
                .simplifiedChinese: "对应 Mac 操作",
                .traditionalChinese: "對應 Mac 操作"
            ],
            "macModifiers": [
                .english: "Modifiers",
                .japanese: "修飾キー",
                .simplifiedChinese: "修饰键",
                .traditionalChinese: "修飾鍵"
            ],
            "macKey": [
                .english: "Key",
                .japanese: "キー",
                .simplifiedChinese: "按键",
                .traditionalChinese: "按鍵"
            ],
            "output": [
                .english: "Output:",
                .japanese: "出力:",
                .simplifiedChinese: "输出:",
                .traditionalChinese: "輸出:"
            ],
            "cancel": [
                .english: "Cancel",
                .japanese: "キャンセル",
                .simplifiedChinese: "取消",
                .traditionalChinese: "取消"
            ],
            "add": [
                .english: "Add",
                .japanese: "追加",
                .simplifiedChinese: "添加",
                .traditionalChinese: "添加"
            ],
            "save": [
                .english: "Save",
                .japanese: "保存",
                .simplifiedChinese: "保存",
                .traditionalChinese: "保存"
            ],
            "duplicate": [
                .english: "Duplicate",
                .japanese: "複製",
                .simplifiedChinese: "复制",
                .traditionalChinese: "複製"
            ]
        ]
        return strings[key]?[l10n.currentLanguage] ?? strings[key]?[.english] ?? key
    }
}

// MARK: - 修饰键切换按钮

struct ModifierToggle: View {
    let label: String
    @Binding var isOn: Bool
    
    var body: some View {
        Button(action: { isOn.toggle() }) {
            Text(label)
                .font(.system(size: 16, weight: .medium))
                .frame(width: 32, height: 32)
                .background(isOn ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(isOn ? .white : .primary)
                .cornerRadius(6)
        }
        .buttonStyle(.plain)
    }
}
