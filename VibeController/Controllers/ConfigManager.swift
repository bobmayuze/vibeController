import Foundation
import Combine

// MARK: - Bundle 配置文件结构

struct BundleConfigFile: Codable {
    var buttonPositions: [String: CGPointCodable]?
    var profiles: [ControllerConfig]
    
    struct CGPointCodable: Codable {
        var x: CGFloat
        var y: CGFloat
    }
}

// MARK: - 配置管理器

@MainActor
class ConfigManager: ObservableObject {
    static let shared = ConfigManager()
    
    @Published var configs: [ControllerConfig] = []
    @Published var currentConfig: ControllerConfig
    @Published var buttonPositions: [String: CGPoint] = [:]
    
    private let configsKey = "SavedConfigs"
    private let currentConfigIdKey = "CurrentConfigId"
    private let buttonPositionsKey = "ButtonPositions"
    
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
        // 先尝试从 UserDefaults 加载
        if let data = UserDefaults.standard.data(forKey: configsKey),
           let decoded = try? JSONDecoder().decode([ControllerConfig].self, from: data) {
            configs = decoded
            print("✅ 已从 UserDefaults 加载 \(decoded.count) 个配置")
            for config in decoded {
                print("   - \(config.name): \(config.chordMappings.count) 个组合键")
            }
        }
        
        // 加载按钮位置
        loadButtonPositions()
        
        // 如果没有配置，尝试从 bundle 加载默认配置
        if configs.isEmpty {
            if let bundleConfigs = loadFromBundle() {
                configs = bundleConfigs
                print("✅ 从 Bundle 加载了 \(bundleConfigs.count) 个默认配置")
                saveConfigs()  // 保存到 UserDefaults
            } else {
                let defaultConfig = ControllerConfig.default
                configs = [defaultConfig]
                print("✅ 创建默认配置，包含 \(defaultConfig.chordMappings.count) 个组合键")
            }
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
    
    /// 从 Bundle 加载默认配置
    private func loadFromBundle() -> [ControllerConfig]? {
        guard let url = Bundle.main.url(forResource: "default_config", withExtension: "json") else {
            print("⚠️ Bundle 中未找到 default_config.json")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            let bundleConfig = try JSONDecoder().decode(BundleConfigFile.self, from: data)
            
            // 加载按钮位置
            if let positions = bundleConfig.buttonPositions {
                for (key, point) in positions {
                    buttonPositions[key] = CGPoint(x: point.x, y: point.y)
                }
                saveButtonPositions()
                print("✅ 从 Bundle 加载了 \(positions.count) 个按钮位置")
            }
            
            return bundleConfig.profiles
        } catch {
            print("❌ 加载 Bundle 配置失败: \(error)")
            return nil
        }
    }
    
    private func loadButtonPositions() {
        if let data = UserDefaults.standard.data(forKey: buttonPositionsKey),
           let decoded = try? JSONDecoder().decode([String: BundleConfigFile.CGPointCodable].self, from: data) {
            for (key, point) in decoded {
                buttonPositions[key] = CGPoint(x: point.x, y: point.y)
            }
        }
    }
    
    private func saveButtonPositions() {
        var codable: [String: BundleConfigFile.CGPointCodable] = [:]
        for (key, point) in buttonPositions {
            codable[key] = BundleConfigFile.CGPointCodable(x: point.x, y: point.y)
        }
        if let encoded = try? JSONEncoder().encode(codable) {
            UserDefaults.standard.set(encoded, forKey: buttonPositionsKey)
        }
    }
    
    func updateButtonPosition(_ button: String, position: CGPoint) {
        buttonPositions[button] = position
        saveButtonPositions()
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
        return createNewConfig(name: "\(config.name) Copy", basedOn: config)
    }
}
