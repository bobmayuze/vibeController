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
