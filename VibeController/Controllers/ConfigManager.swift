import Foundation
import Combine

// MARK: - 配置管理器

@MainActor
class ConfigManager: ObservableObject {
    static let shared = ConfigManager()
    
    @Published var configs: [ControllerConfig] = []
    @Published var currentConfig: ControllerConfig
    
    private let configsKey = "SavedConfigs"
    private let currentConfigIdKey = "CurrentConfigId"
    
    private init() {
        // 先创建一个临时默认配置，loadConfigs 会覆盖它
        currentConfig = .default
        loadConfigs()
        
        // 确保 currentConfig 在 configs 数组中
        if !configs.contains(where: { $0.id == currentConfig.id }) {
            if configs.isEmpty {
                configs = [currentConfig]
            } else {
                currentConfig = configs[0]
            }
            saveConfigs()
        }
    }
    
    // MARK: - 配置管理
    
    func addConfig(_ config: ControllerConfig) {
        configs.append(config)
        saveConfigs()
    }
    
    func updateConfig(_ config: ControllerConfig) {
        if let index = configs.firstIndex(where: { $0.id == config.id }) {
            configs[index] = config
        }
        if currentConfig.id == config.id {
            currentConfig = config
        }
        saveConfigs()
    }
    
    func deleteConfig(_ config: ControllerConfig) {
        configs.removeAll { $0.id == config.id }
        if currentConfig.id == config.id && !configs.isEmpty {
            currentConfig = configs[0]
        }
        saveConfigs()
    }
    
    func selectConfig(_ config: ControllerConfig) {
        currentConfig = config
        UserDefaults.standard.set(config.id.uuidString, forKey: currentConfigIdKey)
    }
    
    // MARK: - 按键映射
    
    func action(for button: ControllerButton) -> Action {
        currentConfig.action(for: button)
    }
    
    func setAction(_ action: Action, for button: ControllerButton) {
        currentConfig.setAction(action, for: button)
        updateConfig(currentConfig)
    }
    
    // MARK: - 组合键映射
    
    func action(for chord: ButtonChord) -> Action {
        currentConfig.action(for: chord)
    }
    
    func setAction(_ action: Action, for chord: ButtonChord) {
        currentConfig.setAction(action, for: chord)
        updateConfig(currentConfig)
    }
    
    var allChords: [ButtonChord] {
        Array(currentConfig.chordMappings.keys).sorted { $0.displayName < $1.displayName }
    }
    
    // MARK: - 持久化
    
    private func loadConfigs() {
        if let data = UserDefaults.standard.data(forKey: configsKey),
           let decoded = try? JSONDecoder().decode([ControllerConfig].self, from: data) {
            configs = decoded
            print("✅ 已加载 \(decoded.count) 个配置")
            for config in decoded {
                print("   - \(config.name): \(config.chordMappings.count) 个组合键")
            }
        }
        
        if configs.isEmpty {
            let defaultConfig = ControllerConfig.default
            configs = [defaultConfig]
            print("✅ 创建默认配置，包含 \(defaultConfig.chordMappings.count) 个组合键")
        }
        
        // 加载当前选中的配置
        if let currentIdString = UserDefaults.standard.string(forKey: currentConfigIdKey),
           let currentId = UUID(uuidString: currentIdString),
           let config = configs.first(where: { $0.id == currentId }) {
            currentConfig = config
        } else {
            currentConfig = configs[0]
        }
        
        print("✅ 当前配置: \(currentConfig.name), 组合键数量: \(currentConfig.chordMappings.count)")
    }
    
    private func saveConfigs() {
        if let encoded = try? JSONEncoder().encode(configs) {
            UserDefaults.standard.set(encoded, forKey: configsKey)
        }
    }
    
    // MARK: - 导入导出
    
    func exportConfig(_ config: ControllerConfig, to url: URL) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(config)
        try data.write(to: url)
    }
    
    func importConfig(from url: URL) throws -> ControllerConfig {
        let data = try Data(contentsOf: url)
        var config = try JSONDecoder().decode(ControllerConfig.self, from: data)
        config.id = UUID()  // 生成新 ID 避免冲突
        addConfig(config)
        return config
    }
    
    // MARK: - 创建新配置
    
    func createNewConfig(name: String, basedOn: ControllerConfig? = nil) -> ControllerConfig {
        let base = basedOn ?? .default
        let newConfig = ControllerConfig(
            name: name,
            mappings: base.mappings,
            chordMappings: base.chordMappings,
            settings: base.settings
        )
        addConfig(newConfig)
        return newConfig
    }
    
    func duplicateConfig(_ config: ControllerConfig) -> ControllerConfig {
        return createNewConfig(name: "\(config.name) 副本", basedOn: config)
    }
}
