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
        currentConfig = .default
        loadConfigs()
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
    
    // MARK: - 持久化
    
    private func loadConfigs() {
        if let data = UserDefaults.standard.data(forKey: configsKey),
           let decoded = try? JSONDecoder().decode([ControllerConfig].self, from: data) {
            configs = decoded
        }
        
        if configs.isEmpty {
            configs = [.default]
        }
        
        // 加载当前选中的配置
        if let currentIdString = UserDefaults.standard.string(forKey: currentConfigIdKey),
           let currentId = UUID(uuidString: currentIdString),
           let config = configs.first(where: { $0.id == currentId }) {
            currentConfig = config
        } else {
            currentConfig = configs[0]
        }
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
            settings: base.settings
        )
        addConfig(newConfig)
        return newConfig
    }
    
    func duplicateConfig(_ config: ControllerConfig) -> ControllerConfig {
        return createNewConfig(name: "\(config.name) 副本", basedOn: config)
    }
}
