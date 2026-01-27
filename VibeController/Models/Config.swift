import Foundation

// MARK: - 配置文件

struct ControllerConfig: Codable, Identifiable {
    var id: UUID
    var name: String
    var mappings: [ControllerButton: Action]
    var settings: ControllerSettings
    
    init(id: UUID = UUID(), name: String, mappings: [ControllerButton: Action], settings: ControllerSettings = .default) {
        self.id = id
        self.name = name
        self.mappings = mappings
        self.settings = settings
    }
    
    func action(for button: ControllerButton) -> Action {
        mappings[button] ?? .none
    }
    
    mutating func setAction(_ action: Action, for button: ControllerButton) {
        mappings[button] = action
    }
    
    // MARK: - Codable
    
    enum CodingKeys: String, CodingKey {
        case id, name, mappings, settings
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        settings = try container.decode(ControllerSettings.self, forKey: .settings)
        
        // 解码 mappings (String -> ControllerButton)
        let stringMappings = try container.decode([String: Action].self, forKey: .mappings)
        var buttonMappings: [ControllerButton: Action] = [:]
        for (key, value) in stringMappings {
            if let button = ControllerButton(rawValue: key) {
                buttonMappings[button] = value
            }
        }
        mappings = buttonMappings
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(settings, forKey: .settings)
        
        // 编码 mappings (ControllerButton -> String)
        var stringMappings: [String: Action] = [:]
        for (key, value) in mappings {
            stringMappings[key.rawValue] = value
        }
        try container.encode(stringMappings, forKey: .mappings)
    }
}

// MARK: - 设置

struct ControllerSettings: Codable {
    var cursorSpeed: Double
    var scrollSpeed: Double
    var deadZone: Double
    var precisionMultiplier: Double
    
    static let `default` = ControllerSettings(
        cursorSpeed: 800,
        scrollSpeed: 5,
        deadZone: 0.15,
        precisionMultiplier: 0.3
    )
}

// MARK: - 默认配置

extension ControllerConfig {
    static let `default`: ControllerConfig = {
        var mappings: [ControllerButton: Action] = [:]
        
        // ABXY
        mappings[.buttonA] = .leftClick
        mappings[.buttonB] = .rightClick
        mappings[.buttonX] = .shortcut(modifiers: .command, keyCode: KeyCodes.c, display: "C")
        mappings[.buttonY] = .shortcut(modifiers: .command, keyCode: KeyCodes.v, display: "V")
        
        // 肩键
        mappings[.leftBumper] = .shortcut(modifiers: .command, keyCode: KeyCodes.z, display: "Z")
        mappings[.rightBumper] = .shortcut(modifiers: .option, keyCode: KeyCodes.space, display: "Space")
        
        // 扳机键
        mappings[.leftTrigger] = .drag  // LT：拖拽模式
        mappings[.rightTrigger] = .shortcut(modifiers: [], keyCode: KeyCodes.returnKey, display: "↵")
        
        // 摇杆按下
        mappings[.leftStickButton] = .shortcut(modifiers: [], keyCode: KeyCodes.returnKey, display: "↵")
        mappings[.rightStickButton] = .shortcut(modifiers: [], keyCode: KeyCodes.escape, display: "Esc")
        
        // 十字键
        mappings[.dpadUp] = .shortcut(modifiers: [], keyCode: KeyCodes.upArrow, display: "↑")
        mappings[.dpadDown] = .shortcut(modifiers: [], keyCode: KeyCodes.downArrow, display: "↓")
        mappings[.dpadLeft] = .shortcut(modifiers: .option, keyCode: KeyCodes.leftArrow, display: "←")
        mappings[.dpadRight] = .shortcut(modifiers: .option, keyCode: KeyCodes.rightArrow, display: "→")
        
        // 特殊键
        mappings[.startButton] = .shortcut(modifiers: [.command, .shift], keyCode: KeyCodes.p, display: "P")
        mappings[.backButton] = .shortcut(modifiers: .command, keyCode: KeyCodes.b, display: "B")
        
        return ControllerConfig(
            name: "Default",
            mappings: mappings,
            settings: .default
        )
    }()
}
