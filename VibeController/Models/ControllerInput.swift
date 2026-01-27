import Foundation

// MARK: - 手柄按键

enum ControllerButton: String, Codable, CaseIterable, Hashable, Identifiable {
    var id: String { rawValue }
    case buttonA = "buttonA"
    case buttonB = "buttonB"
    case buttonX = "buttonX"
    case buttonY = "buttonY"
    case leftBumper = "leftBumper"
    case rightBumper = "rightBumper"
    case leftTrigger = "leftTrigger"
    case rightTrigger = "rightTrigger"
    case leftStickButton = "leftStickButton"
    case rightStickButton = "rightStickButton"
    case dpadUp = "dpadUp"
    case dpadDown = "dpadDown"
    case dpadLeft = "dpadLeft"
    case dpadRight = "dpadRight"
    case startButton = "startButton"      // Menu button
    case backButton = "backButton"        // Options/View button
    case xboxButton = "xboxButton"        // Guide button
    
    var displayName: String {
        switch self {
        case .buttonA: return "A"
        case .buttonB: return "B"
        case .buttonX: return "X"
        case .buttonY: return "Y"
        case .leftBumper: return "LB"
        case .rightBumper: return "RB"
        case .leftTrigger: return "LT"
        case .rightTrigger: return "RT"
        case .leftStickButton: return "L3"
        case .rightStickButton: return "R3"
        case .dpadUp: return "D-Pad ↑"
        case .dpadDown: return "D-Pad ↓"
        case .dpadLeft: return "D-Pad ←"
        case .dpadRight: return "D-Pad →"
        case .startButton: return "Start"
        case .backButton: return "Back"
        case .xboxButton: return "Xbox"
        }
    }
    
    var shortName: String {
        switch self {
        case .buttonA: return "A"
        case .buttonB: return "B"
        case .buttonX: return "X"
        case .buttonY: return "Y"
        case .leftBumper: return "LB"
        case .rightBumper: return "RB"
        case .leftTrigger: return "LT"
        case .rightTrigger: return "RT"
        case .leftStickButton: return "L3"
        case .rightStickButton: return "R3"
        case .dpadUp: return "↑"
        case .dpadDown: return "↓"
        case .dpadLeft: return "←"
        case .dpadRight: return "→"
        case .startButton: return "☰"
        case .backButton: return "⧉"
        case .xboxButton: return "ⓧ"
        }
    }
}

// MARK: - 摇杆

enum ControllerStick: String, Codable {
    case left
    case right
}

// MARK: - 手柄状态

struct ControllerState {
    var leftStickX: Float = 0
    var leftStickY: Float = 0
    var rightStickX: Float = 0
    var rightStickY: Float = 0
    var leftTrigger: Float = 0
    var rightTrigger: Float = 0
    var pressedButtons: Set<ControllerButton> = []
    
    var isLeftTriggerPressed: Bool {
        leftTrigger > 0.5
    }
    
    var isRightTriggerPressed: Bool {
        rightTrigger > 0.5
    }
}

// MARK: - 手柄信息

struct ControllerInfo: Identifiable {
    let id: String
    let name: String
    let vendorName: String?
    var isConnected: Bool
}

// MARK: - 组合键

struct ButtonChord: Hashable, Codable, Identifiable {
    var modifiers: Set<ControllerButton>  // 修饰按钮集合 (如 LT+LB)
    var button: ControllerButton          // 主按钮 (如 D-pad Up)
    
    // 兼容旧版单修饰键的初始化
    init(modifier: ControllerButton, button: ControllerButton) {
        self.modifiers = [modifier]
        self.button = button
    }
    
    init(modifiers: Set<ControllerButton>, button: ControllerButton) {
        self.modifiers = modifiers
        self.button = button
    }
    
    var id: String {
        let sortedModifiers = modifiers.map { $0.rawValue }.sorted().joined(separator: "+")
        return "\(sortedModifiers)+\(button.rawValue)"
    }
    
    var displayName: String {
        let modifierNames = modifiers.sorted { $0.rawValue < $1.rawValue }.map { $0.shortName }.joined(separator: " + ")
        return "\(modifierNames) + \(button.shortName)"
    }
    
    // 兼容旧代码的 modifier 属性（返回第一个修饰键）
    var modifier: ControllerButton {
        modifiers.first ?? .leftTrigger
    }
    
    // 预设的修饰按钮（可作为组合键的修饰器）
    static let modifierButtons: [ControllerButton] = [
        .leftTrigger, .rightTrigger, .leftBumper, .rightBumper
    ]
    
    // 可被修饰的按钮
    static let modifiableButtons: [ControllerButton] = [
        .dpadUp, .dpadDown, .dpadLeft, .dpadRight,
        .buttonA, .buttonB, .buttonX, .buttonY
    ]
}
