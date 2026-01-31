import Foundation

// MARK: - 配置文件

struct ControllerConfig: Codable, Identifiable {
    var id: UUID
    var name: String
    var mappings: [ControllerButton: Action]
    var chordMappings: [ButtonChord: Action]  // 组合键映射
    var settings: ControllerSettings
    var associatedApps: [String]  // 关联的应用 Bundle ID 列表
    
    init(id: UUID = UUID(), name: String, mappings: [ControllerButton: Action], chordMappings: [ButtonChord: Action] = [:], settings: ControllerSettings = .default, associatedApps: [String] = []) {
        self.id = id
        self.name = name
        self.mappings = mappings
        self.chordMappings = chordMappings
        self.settings = settings
        self.associatedApps = associatedApps
    }
    
    func action(for button: ControllerButton) -> Action {
        mappings[button] ?? .none
    }
    
    func action(for chord: ButtonChord) -> Action {
        chordMappings[chord] ?? .none
    }
    
    mutating func setAction(_ action: Action, for button: ControllerButton) {
        mappings[button] = action
    }
    
    mutating func setAction(_ action: Action, for chord: ButtonChord) {
        if action.type == .none {
            chordMappings.removeValue(forKey: chord)
        } else {
            chordMappings[chord] = action
        }
    }
    
    // MARK: - Codable
    
    enum CodingKeys: String, CodingKey {
        case id, name, mappings, chordMappings, settings, associatedApps
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        settings = try container.decode(ControllerSettings.self, forKey: .settings)
        associatedApps = try container.decodeIfPresent([String].self, forKey: .associatedApps) ?? []
        
        // 解码 mappings (String -> ControllerButton)
        let stringMappings = try container.decode([String: Action].self, forKey: .mappings)
        var buttonMappings: [ControllerButton: Action] = [:]
        for (key, value) in stringMappings {
            if let button = ControllerButton(rawValue: key) {
                buttonMappings[button] = value
            }
        }
        mappings = buttonMappings
        
        // 解码 chordMappings
        if let chordStringMappings = try container.decodeIfPresent([String: Action].self, forKey: .chordMappings) {
            var chordButtonMappings: [ButtonChord: Action] = [:]
            for (key, value) in chordStringMappings {
                let parts = key.split(separator: "+").map { String($0) }
                guard !parts.isEmpty else { continue }
                
                // 尝试解析最后一个部分是否是可修饰的按钮
                let lastPart = parts.last!
                let mainButton = ControllerButton(rawValue: lastPart)
                let isMainButton = mainButton != nil && ButtonChord.modifiableButtons.contains(mainButton!)
                
                let modifierRawValues: [String]
                let button: ControllerButton?
                
                if isMainButton && parts.count >= 2 {
                    // 传统格式：修饰键+主按钮
                    modifierRawValues = Array(parts.dropLast())
                    button = mainButton
                } else {
                    // 纯修饰键组合（无主按钮）
                    modifierRawValues = parts.map { String($0) }
                    button = nil
                }
                
                var modifiers: Set<ControllerButton> = []
                var validModifiers = true
                for modRaw in modifierRawValues {
                    if let mod = ControllerButton(rawValue: modRaw) {
                        modifiers.insert(mod)
                    } else {
                        validModifiers = false
                        break
                    }
                }
                
                if validModifiers && !modifiers.isEmpty {
                    chordButtonMappings[ButtonChord(modifiers: modifiers, button: button)] = value
                }
            }
            chordMappings = chordButtonMappings
        } else {
            chordMappings = [:]
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(settings, forKey: .settings)
        try container.encode(associatedApps, forKey: .associatedApps)
        
        // 编码 mappings (ControllerButton -> String)
        var stringMappings: [String: Action] = [:]
        for (key, value) in mappings {
            stringMappings[key.rawValue] = value
        }
        try container.encode(stringMappings, forKey: .mappings)
        
        // 编码 chordMappings
        var chordStringMappings: [String: Action] = [:]
        for (chord, action) in chordMappings {
            chordStringMappings[chord.id] = action
        }
        try container.encode(chordStringMappings, forKey: .chordMappings)
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
        mappings[.leftStickButton] = .profileWheel  // LS↓：配置轮盘
        mappings[.rightStickButton] = .shortcut(modifiers: [], keyCode: KeyCodes.escape, display: "Esc")
        
        // 十字键
        mappings[.dpadUp] = .shortcut(modifiers: [], keyCode: KeyCodes.upArrow, display: "↑")
        mappings[.dpadDown] = .shortcut(modifiers: [], keyCode: KeyCodes.downArrow, display: "↓")
        mappings[.dpadLeft] = .shortcut(modifiers: .option, keyCode: KeyCodes.leftArrow, display: "←")
        mappings[.dpadRight] = .shortcut(modifiers: .option, keyCode: KeyCodes.rightArrow, display: "→")
        
        // 特殊键
        mappings[.startButton] = .shortcut(modifiers: [.command, .shift], keyCode: KeyCodes.p, display: "P")
        mappings[.backButton] = .shortcut(modifiers: .command, keyCode: KeyCodes.b, display: "B")
        
        // 组合键 - LT + D-pad = Shift + 方向键（精细选择文字）
        var chords: [ButtonChord: Action] = [:]
        chords[ButtonChord(modifier: .leftTrigger, button: .dpadUp)] = .shortcut(modifiers: .shift, keyCode: KeyCodes.upArrow, display: "↑")
        chords[ButtonChord(modifier: .leftTrigger, button: .dpadDown)] = .shortcut(modifiers: .shift, keyCode: KeyCodes.downArrow, display: "↓")
        chords[ButtonChord(modifier: .leftTrigger, button: .dpadLeft)] = .shortcut(modifiers: .shift, keyCode: KeyCodes.leftArrow, display: "←")
        chords[ButtonChord(modifier: .leftTrigger, button: .dpadRight)] = .shortcut(modifiers: .shift, keyCode: KeyCodes.rightArrow, display: "→")
        
        return ControllerConfig(
            name: "Default",
            mappings: mappings,
            chordMappings: chords,
            settings: .default
        )
    }()
}
