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

@MainActor
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
            ],
            "manageProfiles": [
                .english: "Manage Profiles",
                .japanese: "プロファイル管理",
                .simplifiedChinese: "管理配置",
                .traditionalChinese: "管理配置"
            ],
            "profiles": [
                .english: "Profiles",
                .japanese: "プロファイル",
                .simplifiedChinese: "配置列表",
                .traditionalChinese: "配置列表"
            ],
            "newProfile": [
                .english: "New Profile",
                .japanese: "新規プロファイル",
                .simplifiedChinese: "新建配置",
                .traditionalChinese: "新建配置"
            ],
            "duplicateProfile": [
                .english: "Duplicate",
                .japanese: "複製",
                .simplifiedChinese: "复制",
                .traditionalChinese: "複製"
            ],
            "deleteProfile": [
                .english: "Delete",
                .japanese: "削除",
                .simplifiedChinese: "删除",
                .traditionalChinese: "刪除"
            ],
            "renameProfile": [
                .english: "Rename",
                .japanese: "名前変更",
                .simplifiedChinese: "重命名",
                .traditionalChinese: "重新命名"
            ],
            "profileName": [
                .english: "Profile Name",
                .japanese: "プロファイル名",
                .simplifiedChinese: "配置名称",
                .traditionalChinese: "配置名稱"
            ],
            "current": [
                .english: "Current",
                .japanese: "使用中",
                .simplifiedChinese: "当前",
                .traditionalChinese: "當前"
            ],
            "wheelHint": [
                .english: "Hold button to open wheel",
                .japanese: "ボタン長押しでホイール表示",
                .simplifiedChinese: "按住按钮打开轮盘",
                .traditionalChinese: "按住按鈕打開輪盤"
            ],
            "selectProfilesToExport": [
                .english: "Select Profiles to Export",
                .japanese: "エクスポートするプロファイルを選択",
                .simplifiedChinese: "选择要导出的配置",
                .traditionalChinese: "選擇要導出的配置"
            ],
            "selectProfilesToImport": [
                .english: "Select Profiles to Import",
                .japanese: "インポートするプロファイルを選択",
                .simplifiedChinese: "选择要导入的配置",
                .traditionalChinese: "選擇要導入的配置"
            ],
            "selectAll": [
                .english: "Select All",
                .japanese: "すべて選択",
                .simplifiedChinese: "全选",
                .traditionalChinese: "全選"
            ],
            "deselectAll": [
                .english: "Deselect All",
                .japanese: "選択解除",
                .simplifiedChinese: "取消全选",
                .traditionalChinese: "取消全選"
            ],
            "includeLayout": [
                .english: "Include Button Layout",
                .japanese: "ボタンレイアウトを含める",
                .simplifiedChinese: "包含按钮布局",
                .traditionalChinese: "包含按鈕佈局"
            ],
            "profilesSelected": [
                .english: "profiles selected",
                .japanese: "個のプロファイルを選択",
                .simplifiedChinese: "个配置已选择",
                .traditionalChinese: "個配置已選擇"
            ],
            "noProfileSelected": [
                .english: "Please select at least one profile",
                .japanese: "少なくとも1つのプロファイルを選択してください",
                .simplifiedChinese: "请至少选择一个配置",
                .traditionalChinese: "請至少選擇一個配置"
            ],
            "importedProfiles": [
                .english: "profiles imported",
                .japanese: "個のプロファイルをインポートしました",
                .simplifiedChinese: "个配置已导入",
                .traditionalChinese: "個配置已導入"
            ],
            "cancel": [
                .english: "Cancel",
                .japanese: "キャンセル",
                .simplifiedChinese: "取消",
                .traditionalChinese: "取消"
            ],
            "buttons": [
                .english: "buttons",
                .japanese: "ボタン",
                .simplifiedChinese: "个按钮",
                .traditionalChinese: "個按鈕"
            ],
            "chordMappings": [
                .english: "combos",
                .japanese: "コンボ",
                .simplifiedChinese: "个组合键",
                .traditionalChinese: "個組合鍵"
            ]
        ]
        
        return strings[key]?[currentLanguage] ?? strings[key]?[.english] ?? key
    }
}

@MainActor
struct MainView: View {
    @ObservedObject var hid = HIDControllerManager.shared
    @ObservedObject var l10n = LocalizationManager.shared
    @State var accessOK = AXIsProcessTrusted()
    @StateObject var layout = ButtonLayoutManager.shared
    @StateObject var configManager = ConfigManager.shared
    @State private var editingButton: ControllerButton?
    @State private var editingChord: ButtonChord?
    @State private var showProfileManager = false
    @State private var showExportSheet = false
    @State private var showImportSheet = false
    @State private var importedProfiles: [ControllerConfig] = []
    @State private var importedLayout: [String: [String: CGFloat]]? = nil
    
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
                
                Spacer().frame(width: 20)
                
                // Profile 选择器
                HStack(spacing: 8) {
                    Image(systemName: "folder.fill").foregroundColor(.secondary)
                    Picker("", selection: Binding(
                        get: { configManager.currentConfig.id },
                        set: { id in
                            if let config = configManager.configs.first(where: { $0.id == id }) {
                                configManager.selectConfig(config)
                            }
                        }
                    )) {
                        ForEach(configManager.configs) { config in
                            Text(config.name).tag(config.id)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(width: 120)
                    
                    Button(action: { showProfileManager = true }) {
                        Image(systemName: "gearshape")
                    }
                    .buttonStyle(.borderless)
                    .help(l10n.localized("manageProfiles"))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                
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
                Button(action: { showExportSheet = true }) {
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
        .sheet(isPresented: $showProfileManager) {
            ProfileManagerView(configManager: configManager, l10n: l10n)
        }
        .sheet(isPresented: $showExportSheet) {
            ExportProfileSelectionView(
                configManager: configManager,
                layout: layout,
                l10n: l10n,
                isPresented: $showExportSheet
            )
        }
        .sheet(isPresented: $showImportSheet) {
            ImportProfileSelectionView(
                profiles: importedProfiles,
                buttonPositions: importedLayout,
                configManager: configManager,
                layout: layout,
                l10n: l10n,
                isPresented: $showImportSheet
            )
        }
    }
    
    // MARK: - 导入配置（从文件读取后显示选择界面）
    
    private func loadFullConfig() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.json]
        panel.allowsMultipleSelection = false
        panel.title = l10n.localized("loadConfig")
        
        panel.begin { response in
            guard response == .OK, let url = panel.url else { return }
            
            do {
                let data = try Data(contentsOf: url)
                
                // 尝试新格式（多配置）
                if let multiConfig = try? JSONDecoder().decode(MultiProfileExportConfig.self, from: data) {
                    importedProfiles = multiConfig.profiles
                    importedLayout = multiConfig.buttonPositions
                    showImportSheet = true
                    return
                }
                
                // 兼容旧格式（单配置）
                if let singleConfig = try? JSONDecoder().decode(FullExportConfig.self, from: data) {
                    importedProfiles = [singleConfig.keyMappings]
                    importedLayout = singleConfig.buttonPositions
                    showImportSheet = true
                    return
                }
                
                throw NSError(domain: "VibeController", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid config format"])
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

// MARK: - 多配置导出结构

struct MultiProfileExportConfig: Codable {
    let buttonPositions: [String: [String: CGFloat]]?
    let profiles: [ControllerConfig]
}

// MARK: - 导出配置选择视图

struct ExportProfileSelectionView: View {
    @ObservedObject var configManager: ConfigManager
    @ObservedObject var layout: ButtonLayoutManager
    @ObservedObject var l10n: LocalizationManager
    @Binding var isPresented: Bool
    
    @State private var selectedIds: Set<UUID> = []
    @State private var includeLayout = true
    
    var body: some View {
        VStack(spacing: 16) {
            Text(l10n.localized("selectProfilesToExport"))
                .font(.headline)
            
            // 全选/取消全选
            HStack {
                Button(l10n.localized("selectAll")) {
                    selectedIds = Set(configManager.configs.map { $0.id })
                }
                .buttonStyle(.borderless)
                
                Button(l10n.localized("deselectAll")) {
                    selectedIds.removeAll()
                }
                .buttonStyle(.borderless)
                
                Spacer()
                
                Text("\(selectedIds.count) \(l10n.localized("profilesSelected"))")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            
            // 配置列表
            List(configManager.configs) { config in
                HStack {
                    Image(systemName: selectedIds.contains(config.id) ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(selectedIds.contains(config.id) ? .accentColor : .secondary)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(config.name)
                            .fontWeight(configManager.currentConfig.id == config.id ? .semibold : .regular)
                        
                        Text("\(config.mappings.count) \(l10n.localized("buttons")), \(config.chordMappings.count) \(l10n.localized("chordMappings"))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if configManager.currentConfig.id == config.id {
                        Text(l10n.localized("current"))
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.accentColor.opacity(0.2))
                            .cornerRadius(4)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if selectedIds.contains(config.id) {
                        selectedIds.remove(config.id)
                    } else {
                        selectedIds.insert(config.id)
                    }
                }
            }
            .frame(height: 200)
            
            // 包含布局选项
            Toggle(l10n.localized("includeLayout"), isOn: $includeLayout)
            
            Divider()
            
            // 按钮
            HStack {
                Button(l10n.localized("cancel")) {
                    isPresented = false
                }
                .keyboardShortcut(.cancelAction)
                
                Spacer()
                
                Button(l10n.localized("exportConfig")) {
                    exportSelectedProfiles()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(selectedIds.isEmpty)
            }
        }
        .padding()
        .frame(width: 400)
        .onAppear {
            // 默认选中当前配置
            selectedIds = [configManager.currentConfig.id]
        }
    }
    
    private func exportSelectedProfiles() {
        let selectedConfigs = configManager.configs.filter { selectedIds.contains($0.id) }
        guard !selectedConfigs.isEmpty else { return }
        
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.json]
        panel.nameFieldStringValue = "vibe_controller_config.json"
        panel.title = l10n.localized("exportConfig")
        
        panel.begin { response in
            guard response == .OK, let url = panel.url else { return }
            
            let exportConfig = MultiProfileExportConfig(
                buttonPositions: includeLayout ? layout.positions.mapValues { ["x": $0.x, "y": $0.y] } : nil,
                profiles: selectedConfigs
            )
            
            do {
                let encoder = JSONEncoder()
                encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
                let data = try encoder.encode(exportConfig)
                try data.write(to: url)
                
                print("✅ 导出成功: \(selectedConfigs.count) 个配置")
                
                DispatchQueue.main.async {
                    isPresented = false
                    let alert = NSAlert()
                    alert.messageText = l10n.localized("exportSuccess")
                    alert.informativeText = "\(selectedConfigs.count) \(l10n.localized("profilesSelected"))\n\(url.path)"
                    alert.alertStyle = .informational
                    alert.runModal()
                }
            } catch {
                print("❌ 导出失败: \(error)")
            }
        }
    }
}

// MARK: - 导入配置选择视图

struct ImportProfileSelectionView: View {
    let profiles: [ControllerConfig]
    let buttonPositions: [String: [String: CGFloat]]?
    @ObservedObject var configManager: ConfigManager
    @ObservedObject var layout: ButtonLayoutManager
    @ObservedObject var l10n: LocalizationManager
    @Binding var isPresented: Bool
    
    @State private var selectedIds: Set<UUID> = []
    @State private var importLayout = true
    
    var body: some View {
        VStack(spacing: 16) {
            Text(l10n.localized("selectProfilesToImport"))
                .font(.headline)
            
            // 全选/取消全选
            HStack {
                Button(l10n.localized("selectAll")) {
                    selectedIds = Set(profiles.map { $0.id })
                }
                .buttonStyle(.borderless)
                
                Button(l10n.localized("deselectAll")) {
                    selectedIds.removeAll()
                }
                .buttonStyle(.borderless)
                
                Spacer()
                
                Text("\(selectedIds.count) \(l10n.localized("profilesSelected"))")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            
            // 配置列表
            List(profiles) { config in
                HStack {
                    Image(systemName: selectedIds.contains(config.id) ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(selectedIds.contains(config.id) ? .accentColor : .secondary)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(config.name)
                        
                        Text("\(config.mappings.count) \(l10n.localized("buttons")), \(config.chordMappings.count) \(l10n.localized("chordMappings"))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if selectedIds.contains(config.id) {
                        selectedIds.remove(config.id)
                    } else {
                        selectedIds.insert(config.id)
                    }
                }
            }
            .frame(height: 200)
            
            // 包含布局选项（如果导入文件中有布局）
            if buttonPositions != nil {
                Toggle(l10n.localized("includeLayout"), isOn: $importLayout)
            }
            
            Divider()
            
            // 按钮
            HStack {
                Button(l10n.localized("cancel")) {
                    isPresented = false
                }
                .keyboardShortcut(.cancelAction)
                
                Spacer()
                
                Button(l10n.localized("loadConfig")) {
                    importSelectedProfiles()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(selectedIds.isEmpty)
            }
        }
        .padding()
        .frame(width: 400)
        .onAppear {
            // 默认全选
            selectedIds = Set(profiles.map { $0.id })
        }
    }
    
    private func importSelectedProfiles() {
        let selectedConfigs = profiles.filter { selectedIds.contains($0.id) }
        guard !selectedConfigs.isEmpty else { return }
        
        // 导入布局
        if importLayout, let positions = buttonPositions {
            layout.positions = positions.mapValues {
                CGPoint(x: $0["x"] ?? 0, y: $0["y"] ?? 0)
            }
            layout.savePositions()
        }
        
        // 导入配置（生成新ID避免冲突）
        var importedCount = 0
        for config in selectedConfigs {
            var newConfig = config
            newConfig.id = UUID()
            
            // 检查是否有同名配置
            let existingNames = configManager.configs.map { $0.name }
            if existingNames.contains(config.name) {
                var counter = 1
                var newName = "\(config.name) (\(counter))"
                while existingNames.contains(newName) {
                    counter += 1
                    newName = "\(config.name) (\(counter))"
                }
                newConfig.name = newName
            }
            
            configManager.addConfig(newConfig)
            importedCount += 1
        }
        
        isPresented = false
        
        let alert = NSAlert()
        alert.messageText = l10n.localized("loadSuccess")
        alert.informativeText = "\(importedCount) \(l10n.localized("importedProfiles"))"
        alert.alertStyle = .informational
        alert.runModal()
    }
}

// MARK: - 按钮布局管理器

@MainActor
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

@MainActor
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
        let pressPrefix: String
        switch l10n.currentLanguage {
        case .english: pressPrefix = "Press: "
        case .japanese: pressPrefix = "押下: "
        case .simplifiedChinese: pressPrefix = "按下: "
        case .traditionalChinese: pressPrefix = "按下: "
        }
        
        let action = configManager.action(for: button)
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
                SVGStickOverlay(imageName: "LeftStick", action: l10n.localized("moveMouse"), isActive: hid.leftStickActive, l3Label: stickPressLabel(for: .leftStickButton), l3Active: hid.pressedButtons.contains("LS↓"), editMode: layout.isEditMode, stickX: hid.leftStickXValue, stickY: hid.leftStickYValue, size: 36 * scale, textAlign: .left, scale: scale)
            }
            
            // 右摇杆 - 右侧，文字在右
            DraggableButton(key: "RightStick", layout: layout, scale: scale, onTap: { editingButton = .rightStickButton }) {
                SVGStickOverlay(imageName: "RightStick", action: l10n.localized("moveScroll"), isActive: hid.rightStickActive, l3Label: stickPressLabel(for: .rightStickButton), l3Active: hid.pressedButtons.contains("RS↓"), editMode: layout.isEditMode, stickX: hid.rightStickXValue, stickY: hid.rightStickYValue, size: 36 * scale, textAlign: .right, scale: scale)
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
    
    @State private var isHovering = false
    
    private var fontSize: CGFloat { 9 * scale }
    private var isHighlighted: Bool { editMode || isActive || isHovering }
    
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
        .animation(.easeInOut(duration: 0.1), value: isHovering)
        .onHover { isHovering = $0 }
    }
    
    private var buttonImage: some View {
        Image(imageName)
            .renderingMode(.template)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size, height: size)
            .foregroundColor(isHighlighted ? activeColor : .primary.opacity(0.6))
            .shadow(color: isHighlighted ? activeColor.opacity(0.8) : .clear, radius: (isActive || isHovering) ? 6 * scale : 0)
            .scaleEffect(isActive ? 1.15 : (isHovering ? 1.08 : 1.0))
    }
    
    @ViewBuilder
    private var actionText: some View {
        if !action.isEmpty {
            Text(action)
                .font(.system(size: fontSize))
                .foregroundColor((isActive || isHovering) ? .primary : .secondary)
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
    
    @State private var isHovering = false
    
    private var maxOffset: CGFloat { 6 * scale }
    private var fontSize: CGFloat { 9 * scale }
    private var isHighlighted: Bool { editMode || isActive || isHovering }
    
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
        .animation(.easeInOut(duration: 0.1), value: isHovering)
        .onHover { isHovering = $0 }
    }
    
    private var stickImage: some View {
        Image(imageName)
            .renderingMode(.template)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size, height: size)
            .foregroundColor(isHighlighted ? .blue : .primary.opacity(0.6))
            .shadow(color: isHighlighted ? .blue.opacity(0.8) : .clear, radius: (isActive || isHovering) ? 6 * scale : 0)
            .scaleEffect(isHovering && !isActive ? 1.08 : 1.0)
            .offset(x: CGFloat(stickX) * maxOffset, y: CGFloat(stickY) * maxOffset)
    }
    
    private var labelsView: some View {
        VStack(alignment: .leading, spacing: 1 * scale) {
            Text(action)
                .font(.system(size: fontSize))
                .foregroundColor((isActive || isHovering) ? .primary : .secondary)
            
            Text(l3Label)
                .font(.system(size: fontSize))
                .foregroundColor((l3Active || isHovering) ? .primary : .secondary.opacity(0.6))
        }
    }
}

// MARK: - Profile 轮盘选择视图 (带预览)

@MainActor
struct ProfileWheelView: View {
    @ObservedObject var configManager: ConfigManager
    let selectedIndex: Int
    let windowSize: CGSize
    
    var selectedConfig: ControllerConfig? {
        guard selectedIndex >= 0 && selectedIndex < configManager.configs.count else { return nil }
        return configManager.configs[selectedIndex]
    }
    
    // 动态计算 scale 让内容填满窗口
    private var dynamicScale: CGFloat {
        // 基础内容尺寸 (scale=1 时)：
        // - 轮盘直径: 360 (outerRadius=180)
        // - 预览宽度: 420 * 1.45 = 609
        // - 间距: 50
        // - 总宽度约: 1020
        // - 高度约: 400 (轮盘 360 + 边距)
        let baseContentWidth: CGFloat = 1020
        let baseContentHeight: CGFloat = 420
        
        // 留出边距
        let availableWidth = windowSize.width * 0.92
        let availableHeight = windowSize.height * 0.88
        
        // 取较小的缩放比，确保内容不超出
        return min(availableWidth / baseContentWidth, availableHeight / baseContentHeight)
    }
    
    var body: some View {
        ZStack {
            // 半透明背景
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.black.opacity(0.88))
            
            // 内容居中
            HStack(spacing: 50 * dynamicScale) {
                // 左边：轮盘
                ProfileWheelDonut(configManager: configManager, selectedIndex: selectedIndex, scale: dynamicScale)
                
                // 右边：控制器布局预览
                if let config = selectedConfig {
                    ControllerLayoutPreview(config: config, scale: dynamicScale)
                }
            }
        }
        .frame(width: windowSize.width, height: windowSize.height)
    }
}

// Donut 轮盘部分
@MainActor
struct ProfileWheelDonut: View {
    @ObservedObject var configManager: ConfigManager
    let selectedIndex: Int
    let scale: CGFloat
    
    private var outerRadius: CGFloat { 180 * scale }
    private var innerRadius: CGFloat { 85 * scale }
    private var gapWidth: CGFloat { 6 * scale }  // 固定像素间隙
    
    private var donutSize: CGFloat { outerRadius * 2 }
    
    var body: some View {
        ZStack {
            // Donut 扇形 - 所有扇形使用相同的固定 frame 确保一致性
            ForEach(Array(configManager.configs.enumerated()), id: \.element.id) { index, config in
                let total = configManager.configs.count
                let isSelected = index == selectedIndex
                let isCurrent = config.id == configManager.currentConfig.id
                
                DonutSegment(
                    startAngle: startAngle(for: index, total: total),
                    endAngle: endAngle(for: index, total: total),
                    innerRadius: innerRadius,
                    outerRadius: outerRadius,
                    gapWidth: gapWidth
                )
                .fill(segmentColor(isSelected: isSelected, isCurrent: isCurrent))
                .frame(width: donutSize, height: donutSize)  // 固定 frame
                .animation(.easeOut(duration: 0.15), value: isSelected)
                
                // 扇形上的文字标签
                let midAngle = (startAngle(for: index, total: total) + endAngle(for: index, total: total)) / 2
                let labelRadius = (innerRadius + outerRadius) / 2
                
                VStack(spacing: 4 * scale) {
                    Image(systemName: isCurrent ? "checkmark.circle.fill" : "folder.fill")
                        .font(.system(size: 24 * scale))
                    Text(config.name)
                        .font(.system(size: 14 * scale, weight: isSelected ? .bold : .medium))
                        .lineLimit(1)
                }
                .foregroundColor(.white)
                .offset(
                    x: cos(midAngle - .pi / 2) * labelRadius,
                    y: sin(midAngle - .pi / 2) * labelRadius
                )
            }
            
            // 中心圆
            Circle()
                .fill(Color.black.opacity(0.95))
                .frame(width: innerRadius * 2 - 10, height: innerRadius * 2 - 10)
            
            // 中心内容
            VStack(spacing: 6 * scale) {
                Image(systemName: "gamecontroller.fill")
                    .font(.system(size: 36 * scale))
                    .foregroundColor(.white.opacity(0.9))
                if selectedIndex >= 0 && selectedIndex < configManager.configs.count {
                    Text(configManager.configs[selectedIndex].name)
                        .font(.system(size: 16 * scale, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                }
            }
        }
        .frame(width: donutSize + 30, height: donutSize + 30)
    }
    
    private func startAngle(for index: Int, total: Int) -> Double {
        guard total > 0 else { return 0 }
        return (Double(index) / Double(total)) * 2 * .pi
    }
    
    private func endAngle(for index: Int, total: Int) -> Double {
        guard total > 0 else { return 0 }
        return (Double(index + 1) / Double(total)) * 2 * .pi
    }
    
    private func segmentColor(isSelected: Bool, isCurrent: Bool) -> Color {
        if isSelected {
            return Color.blue
        } else if isCurrent {
            return Color.green.opacity(0.7)
        } else {
            return Color.white.opacity(0.15)
        }
    }
}

// 控制器布局预览 (使用与主界面相同的可视化)
@MainActor
struct ControllerLayoutPreview: View {
    let config: ControllerConfig
    let scale: CGFloat
    @ObservedObject var layout = ButtonLayoutManager.shared
    @ObservedObject var l10n = LocalizationManager.shared
    
    private let baseWidth: CGFloat = 420
    
    // 获取按钮的动作显示名称
    private func actionDisplayName(for button: ControllerButton) -> String {
        return config.action(for: button).displayName
    }
    
    // 获取摇杆按下的标签
    private func stickPressLabel(for button: ControllerButton) -> String {
        let pressPrefix: String
        switch l10n.currentLanguage {
        case .english: pressPrefix = "Press: "
        case .japanese: pressPrefix = "押下: "
        case .simplifiedChinese: pressPrefix = "按下: "
        case .traditionalChinese: pressPrefix = "按下: "
        }
        return pressPrefix + config.action(for: button).displayName
    }
    
    var body: some View {
        VStack(spacing: 12 * scale) {
            // 标题
            Text(config.name)
                .font(.system(size: 20 * scale, weight: .bold))
                .foregroundColor(.white)
            
            // 控制器布局 (复用主界面的结构)
            let previewScale = scale * 1.45  // 预览缩放 (增大30%)
            let targetWidth = baseWidth * previewScale
            
            ZStack {
                // 控制器背景图 (使用模板模式渲染为白色)
                Image("ControllerImage")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: targetWidth)
                    .foregroundColor(.white.opacity(0.85))
                
                // LT
                StaticButtonOverlay(key: "LT", layout: layout, scale: previewScale) {
                    SVGButtonOverlay(imageName: "LT", action: actionDisplayName(for: .leftTrigger), isActive: false, size: 27 * previewScale, textAlign: .left, scale: previewScale)
                }
                
                // LB
                StaticButtonOverlay(key: "LB", layout: layout, scale: previewScale) {
                    SVGButtonOverlay(imageName: "LB", action: actionDisplayName(for: .leftBumper), isActive: false, size: 27 * previewScale, textAlign: .left, scale: previewScale)
                }
                
                // RT
                StaticButtonOverlay(key: "RT", layout: layout, scale: previewScale) {
                    SVGButtonOverlay(imageName: "RT", action: actionDisplayName(for: .rightTrigger), isActive: false, size: 27 * previewScale, textAlign: .right, scale: previewScale)
                }
                
                // RB
                StaticButtonOverlay(key: "RB", layout: layout, scale: previewScale) {
                    SVGButtonOverlay(imageName: "RB", action: actionDisplayName(for: .rightBumper), isActive: false, size: 27 * previewScale, textAlign: .right, scale: previewScale)
                }
                
                // 左摇杆
                StaticButtonOverlay(key: "LeftStick", layout: layout, scale: previewScale) {
                    SVGStickOverlay(imageName: "LeftStick", action: l10n.localized("moveMouse"), isActive: false, l3Label: stickPressLabel(for: .leftStickButton), l3Active: false, size: 36 * previewScale, textAlign: .left, scale: previewScale)
                }
                
                // 右摇杆
                StaticButtonOverlay(key: "RightStick", layout: layout, scale: previewScale) {
                    SVGStickOverlay(imageName: "RightStick", action: l10n.localized("moveScroll"), isActive: false, l3Label: stickPressLabel(for: .rightStickButton), l3Active: false, size: 36 * previewScale, textAlign: .right, scale: previewScale)
                }
                
                // D-Pad
                StaticButtonOverlay(key: "DPadUp", layout: layout, scale: previewScale) {
                    SVGButtonOverlay(imageName: "DPadUp", action: actionDisplayName(for: .dpadUp), isActive: false, size: 20 * previewScale, textAlign: .left, scale: previewScale)
                }
                StaticButtonOverlay(key: "DPadDown", layout: layout, scale: previewScale) {
                    SVGButtonOverlay(imageName: "DPadDown", action: actionDisplayName(for: .dpadDown), isActive: false, size: 20 * previewScale, textAlign: .left, scale: previewScale)
                }
                StaticButtonOverlay(key: "DPadLeft", layout: layout, scale: previewScale) {
                    SVGButtonOverlay(imageName: "DPadLeft", action: actionDisplayName(for: .dpadLeft), isActive: false, size: 20 * previewScale, textAlign: .left, scale: previewScale)
                }
                StaticButtonOverlay(key: "DPadRight", layout: layout, scale: previewScale) {
                    SVGButtonOverlay(imageName: "DPadRight", action: actionDisplayName(for: .dpadRight), isActive: false, size: 20 * previewScale, textAlign: .left, scale: previewScale)
                }
                
                // Back & Start
                StaticButtonOverlay(key: "Back", layout: layout, scale: previewScale) {
                    SVGButtonOverlay(imageName: "ViewBtn", action: actionDisplayName(for: .backButton), isActive: false, size: 20 * previewScale, textAlign: .left, scale: previewScale)
                }
                StaticButtonOverlay(key: "Start", layout: layout, scale: previewScale) {
                    SVGButtonOverlay(imageName: "MenuBtn", action: actionDisplayName(for: .startButton), isActive: false, size: 20 * previewScale, textAlign: .right, scale: previewScale)
                }
                
                // ABXY
                StaticButtonOverlay(key: "BtnY", layout: layout, scale: previewScale) {
                    SVGButtonOverlay(imageName: "BtnY", action: actionDisplayName(for: .buttonY), isActive: false, size: 16 * previewScale, activeColor: .orange, textAlign: .right, scale: previewScale)
                }
                StaticButtonOverlay(key: "BtnX", layout: layout, scale: previewScale) {
                    SVGButtonOverlay(imageName: "BtnX", action: actionDisplayName(for: .buttonX), isActive: false, size: 16 * previewScale, activeColor: .blue, textAlign: .right, scale: previewScale)
                }
                StaticButtonOverlay(key: "BtnB", layout: layout, scale: previewScale) {
                    SVGButtonOverlay(imageName: "BtnB", action: actionDisplayName(for: .buttonB), isActive: false, size: 16 * previewScale, activeColor: .red, textAlign: .right, scale: previewScale)
                }
                StaticButtonOverlay(key: "BtnA", layout: layout, scale: previewScale) {
                    SVGButtonOverlay(imageName: "BtnA", action: actionDisplayName(for: .buttonA), isActive: false, size: 16 * previewScale, activeColor: .green, textAlign: .right, scale: previewScale)
                }
            }
            .frame(width: targetWidth, height: targetWidth / 1.9)
            .colorScheme(.dark)  // 强制深色模式，让 SVG 图标显示为白色
        }
    }
}

// 静态按钮位置容器 (无拖拽功能)
struct StaticButtonOverlay<Content: View>: View {
    let key: String
    @ObservedObject var layout: ButtonLayoutManager
    var scale: CGFloat = 1.0
    let content: () -> Content
    
    var body: some View {
        content()
            .offset(
                x: layout.position(for: key).x * scale,
                y: layout.position(for: key).y * scale
            )
    }
}

// Donut 扇形 Shape (使用固定像素间隙)
struct DonutSegment: Shape {
    let startAngle: Double
    let endAngle: Double
    let innerRadius: CGFloat
    let outerRadius: CGFloat
    var gapWidth: CGFloat = 4  // 固定像素间隙宽度
    
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        var path = Path()
        
        // 根据半径计算角度偏移，使间隙宽度一致
        let innerGapAngle = gapWidth / (2 * innerRadius)
        let outerGapAngle = gapWidth / (2 * outerRadius)
        
        // 从 12 点钟方向开始（-π/2）
        let adjustedStartOuter = startAngle - .pi / 2 + outerGapAngle
        let adjustedEndOuter = endAngle - .pi / 2 - outerGapAngle
        let adjustedStartInner = startAngle - .pi / 2 + innerGapAngle
        let adjustedEndInner = endAngle - .pi / 2 - innerGapAngle
        
        // 外圈弧线
        path.addArc(center: center, radius: outerRadius,
                    startAngle: .radians(adjustedStartOuter),
                    endAngle: .radians(adjustedEndOuter),
                    clockwise: false)
        
        // 连接到内圈
        path.addLine(to: CGPoint(
            x: center.x + innerRadius * CGFloat(cos(adjustedEndInner)),
            y: center.y + innerRadius * CGFloat(sin(adjustedEndInner))
        ))
        
        // 内圈弧线
        path.addArc(center: center, radius: innerRadius,
                    startAngle: .radians(adjustedEndInner),
                    endAngle: .radians(adjustedStartInner),
                    clockwise: true)
        
        path.closeSubpath()
        
        return path
    }
}

// MARK: - Profile 轮盘窗口控制器

@MainActor
class ProfileWheelWindowController: NSObject, ObservableObject {
    static let shared = ProfileWheelWindowController()
    
    @Published var isVisible = false
    @Published var selectedIndex = 0
    
    // 追踪是哪个摇杆触发的 (true = 左摇杆, false = 右摇杆)
    var triggeredByLeftStick = true
    
    private var window: NSWindow?
    private var hostingView: NSHostingView<ProfileWheelView>?
    
    private var currentWindowSize: CGSize = .zero
    
    func show(triggeredByLeftStick: Bool) {
        guard !isVisible else { return }
        isVisible = true
        self.triggeredByLeftStick = triggeredByLeftStick
        
        let configManager = ConfigManager.shared
        // 找到当前配置的索引
        selectedIndex = configManager.configs.firstIndex(where: { $0.id == configManager.currentConfig.id }) ?? 0
        
        // 获取鼠标所在的屏幕（多显示器支持）
        let mouseLocation = NSEvent.mouseLocation
        var targetScreen: NSScreen = NSScreen.main ?? NSScreen.screens.first!
        for s in NSScreen.screens {
            if s.frame.contains(mouseLocation) {
                targetScreen = s
                break
            }
        }
        let screen = targetScreen
        
        // 计算窗口大小为屏幕的 80%
        let screenFrame = screen.visibleFrame
        let windowWidth = screenFrame.width * 0.80
        let windowHeight = screenFrame.height * 0.80
        currentWindowSize = CGSize(width: windowWidth, height: windowHeight)
        
        // 创建窗口
        let windowFrame = NSRect(
            x: screen.frame.midX - windowWidth / 2,
            y: screen.frame.midY - windowHeight / 2,
            width: windowWidth,
            height: windowHeight
        )
        
        window = NSWindow(
            contentRect: windowFrame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        
        guard let window = window else { return }
        window.isOpaque = false
        window.backgroundColor = .clear
        window.level = .screenSaver  // 更高的层级确保显示在最前面
        window.hasShadow = true
        window.ignoresMouseEvents = true
        
        // 创建 SwiftUI 视图，传入窗口尺寸
        let wheelView = ProfileWheelView(
            configManager: configManager,
            selectedIndex: selectedIndex,
            windowSize: currentWindowSize
        )
        
        // 创建 hosting view 并设置 Auto Layout
        let hosting = NSHostingView(rootView: wheelView)
        hosting.translatesAutoresizingMaskIntoConstraints = false
        
        window.contentView = hosting
        
        // 使用 Auto Layout 让 hosting view 填满窗口
        if let contentView = window.contentView {
            NSLayoutConstraint.activate([
                hosting.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                hosting.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                hosting.topAnchor.constraint(equalTo: contentView.topAnchor),
                hosting.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ])
        }
        
        hostingView = hosting
        window.orderFront(nil)
    }
    
    func updateSelection(stickX: Float, stickY: Float) {
        let configManager = ConfigManager.shared
        let deadZone: Float = 0.3
        
        // 如果摇杆在死区内，不更新选择
        let magnitude = sqrt(stickX * stickX + stickY * stickY)
        if magnitude < deadZone {
            return  // 保持当前选择
        }
        
        // 计算摇杆角度
        // atan2(x, -y) 让上方为0，顺时针增加
        // stickY 在游戏手柄中：上=-1，下=+1
        // stickX：左=-1，右=+1
        var angle = atan2(Double(stickX), Double(-stickY))
        if angle < 0 { angle += 2 * .pi }  // 转换为 0-2π 范围
        
        // 根据角度计算选中的索引
        let total = configManager.configs.count
        if total > 0 {
            let segmentSize = (2 * .pi) / Double(total)
            // 加上半个扇形大小来让选择落在扇形中心
            selectedIndex = Int((angle + segmentSize / 2).truncatingRemainder(dividingBy: 2 * .pi) / segmentSize) % total
        }
        
        updateView()
    }
    
    func hide() -> ControllerConfig? {
        guard isVisible else { return nil }
        isVisible = false
        
        window?.orderOut(nil)
        window = nil
        hostingView = nil
        
        // 返回选中的配置
        let configManager = ConfigManager.shared
        if selectedIndex >= 0 && selectedIndex < configManager.configs.count {
            return configManager.configs[selectedIndex]
        }
        return nil
    }
    
    private func updateView() {
        let wheelView = ProfileWheelView(
            configManager: ConfigManager.shared,
            selectedIndex: selectedIndex,
            windowSize: currentWindowSize
        )
        hostingView?.rootView = wheelView
    }
}

// MARK: - Profile 管理视图

@MainActor
struct ProfileManagerView: View {
    @ObservedObject var configManager: ConfigManager
    @ObservedObject var l10n: LocalizationManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var editingProfileId: UUID?
    @State private var editingName: String = ""
    @State private var showingNewProfileAlert = false
    @State private var newProfileName = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // 标题
            HStack {
                Text(l10n.localized("profiles"))
                    .font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()
            
            Divider()
            
            // Profile 列表
            List {
                ForEach(configManager.configs) { config in
                    HStack {
                        if editingProfileId == config.id {
                            TextField("", text: $editingName, onCommit: {
                                saveRename(config)
                            })
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 150)
                            
                            Button(action: { saveRename(config) }) {
                                Image(systemName: "checkmark")
                            }
                            .buttonStyle(.borderless)
                            
                            Button(action: { editingProfileId = nil }) {
                                Image(systemName: "xmark")
                            }
                            .buttonStyle(.borderless)
                        } else {
                            Image(systemName: config.id == configManager.currentConfig.id ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(config.id == configManager.currentConfig.id ? .green : .secondary)
                            
                            Text(config.name)
                                .fontWeight(config.id == configManager.currentConfig.id ? .semibold : .regular)
                            
                            if config.id == configManager.currentConfig.id {
                                Text("(\(l10n.localized("current")))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            // 重命名按钮
                            Button(action: {
                                editingProfileId = config.id
                                editingName = config.name
                            }) {
                                Image(systemName: "pencil")
                            }
                            .buttonStyle(.borderless)
                            
                            // 复制按钮
                            Button(action: {
                                let _ = configManager.duplicateConfig(config)
                            }) {
                                Image(systemName: "doc.on.doc")
                            }
                            .buttonStyle(.borderless)
                            
                            // 删除按钮（至少保留一个）
                            Button(action: {
                                if configManager.configs.count > 1 {
                                    configManager.deleteConfig(config)
                                }
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(configManager.configs.count > 1 ? .red : .gray)
                            }
                            .buttonStyle(.borderless)
                            .disabled(configManager.configs.count <= 1)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if editingProfileId == nil {
                            configManager.selectConfig(config)
                        }
                    }
                }
            }
            .listStyle(.inset)
            
            Divider()
            
            // 底部按钮
            HStack {
                Button(action: { showingNewProfileAlert = true }) {
                    Label(l10n.localized("newProfile"), systemImage: "plus")
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Text(l10n.localized("wheelHint"))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
        .frame(width: 400, height: 350)
        .alert(l10n.localized("newProfile"), isPresented: $showingNewProfileAlert) {
            TextField(l10n.localized("profileName"), text: $newProfileName)
            Button(l10n.localized("cancel"), role: .cancel) { newProfileName = "" }
            Button(l10n.localized("ok")) {
                if !newProfileName.isEmpty {
                    let newConfig = configManager.createNewConfig(name: newProfileName)
                    configManager.selectConfig(newConfig)
                    newProfileName = ""
                }
            }
        }
    }
    
    private func saveRename(_ config: ControllerConfig) {
        if !editingName.isEmpty {
            var updated = config
            updated.name = editingName
            configManager.updateConfig(updated)
        }
        editingProfileId = nil
    }
}

// MARK: - 键位编辑器

@MainActor
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
        // 符号键
        case leftBracket = "["
        case rightBracket = "]"
        case semicolon = ";"
        case quote = "'"
        case comma = ","
        case period = "."
        case slash = "/"
        case backslash = "\\"
        case equal = "="
        case minus = "-"
        case grave = "`"
        
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
            // 符号键
            case .leftBracket: return 0x21
            case .rightBracket: return 0x1E
            case .semicolon: return 0x29
            case .quote: return 0x27
            case .comma: return 0x2B
            case .period: return 0x2F
            case .slash: return 0x2C
            case .backslash: return 0x2A
            case .equal: return 0x18
            case .minus: return 0x1B
            case .grave: return 0x32
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
            default: return rawValue  // 字母、数字和符号直接返回
            }
        }
        
        static func from(keyCode: Int) -> KeyOption? {
            return KeyOption.allCases.first { $0.keyCode == keyCode }
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
                        Text(localizedTitle("profileWheel")).tag(ActionType.profileWheel)
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
                        KeyCaptureField(selectedKey: $selectedKey)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                case .mouseDrag, .profileWheel, .none, .command, .text, .mouseMove, .scroll:
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
        case .profileWheel:
            return localizedTitle("profileWheel")
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
        case .profileWheel:
            action = .profileWheel
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
            "profileWheel": [
                .english: "Profile",
                .japanese: "プロファイル",
                .simplifiedChinese: "配置轮盘",
                .traditionalChinese: "配置輪盤"
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

@MainActor
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

@MainActor
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

@MainActor
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
                        KeyCaptureField(selectedKey: $selectedKey)
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

// MARK: - 按键捕获字段

struct KeyCaptureField: View {
    @Binding var selectedKey: KeymapEditorView.KeyOption
    @State private var isCapturing = false
    @State private var eventMonitor: Any?
    
    var body: some View {
        Button(action: { startCapturing() }) {
            HStack {
                Text(isCapturing ? "按下按键..." : (selectedKey == .none ? "点击选择按键" : selectedKey.displayName))
                    .foregroundColor(isCapturing ? .secondary : (selectedKey == .none ? .secondary : .primary))
                Spacer()
                if selectedKey != .none && !isCapturing {
                    Button(action: { selectedKey = .none }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .frame(maxWidth: .infinity)
            .background(isCapturing ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(isCapturing ? Color.blue : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .onDisappear {
            stopCapturing()
        }
    }
    
    private func startCapturing() {
        isCapturing = true
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            if let keyOption = KeymapEditorView.KeyOption.from(keyCode: Int(event.keyCode)) {
                selectedKey = keyOption
            }
            stopCapturing()
            return nil // 消费事件
        }
    }
    
    private func stopCapturing() {
        isCapturing = false
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }
}
