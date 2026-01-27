import Foundation
import Carbon.HIToolbox

// MARK: - 动作类型

enum ActionType: String, Codable, CaseIterable {
    case mouseClick = "click"
    case mouseDrag = "drag"
    case shortcut = "shortcut"
    case profileWheel = "profileWheel"
    case command = "command"
    case text = "text"
    case mouseMove = "mouseMove"
    case scroll = "scroll"
    case none = "none"
    
    var displayName: String {
        switch self {
        case .mouseClick: return "Click"
        case .mouseDrag: return "Drag"
        case .shortcut: return "Shortcut"
        case .profileWheel: return "Profile Wheel"
        case .command: return "Command"
        case .text: return "Text"
        case .mouseMove: return "Mouse Move"
        case .scroll: return "Scroll"
        case .none: return "None"
        }
    }
}

// MARK: - 鼠标按钮

enum MouseButton: String, Codable, CaseIterable {
    case left
    case right
    case middle
    
    var displayName: String {
        switch self {
        case .left: return "Left"
        case .right: return "Right"
        case .middle: return "Middle"
        }
    }
}

// MARK: - 修饰键

struct ModifierKeys: OptionSet, Codable, Hashable {
    let rawValue: Int
    
    static let command = ModifierKeys(rawValue: 1 << 0)
    static let option = ModifierKeys(rawValue: 1 << 1)
    static let control = ModifierKeys(rawValue: 1 << 2)
    static let shift = ModifierKeys(rawValue: 1 << 3)
    
    var displayString: String {
        var parts: [String] = []
        if contains(.control) { parts.append("⌃") }
        if contains(.option) { parts.append("⌥") }
        if contains(.shift) { parts.append("⇧") }
        if contains(.command) { parts.append("⌘") }
        return parts.joined()
    }
    
    var cgEventFlags: CGEventFlags {
        var flags: CGEventFlags = []
        if contains(.command) { flags.insert(.maskCommand) }
        if contains(.option) { flags.insert(.maskAlternate) }
        if contains(.control) { flags.insert(.maskControl) }
        if contains(.shift) { flags.insert(.maskShift) }
        return flags
    }
}

// MARK: - 动作定义

struct Action: Codable, Equatable, Hashable {
    var type: ActionType
    var mouseButton: MouseButton?
    var modifiers: ModifierKeys?
    var keyCode: Int?
    var keyDisplay: String?
    var commandString: String?
    var textToType: String?
    
    // 预设动作
    static let leftClick = Action(type: .mouseClick, mouseButton: .left)
    static let rightClick = Action(type: .mouseClick, mouseButton: .right)
    static let drag = Action(type: .mouseDrag)
    static let profileWheel = Action(type: .profileWheel)
    static let none = Action(type: .none)
    
    static func shortcut(modifiers: ModifierKeys, keyCode: Int, display: String) -> Action {
        Action(type: .shortcut, modifiers: modifiers, keyCode: keyCode, keyDisplay: display)
    }
    
    static func command(_ cmd: String) -> Action {
        Action(type: .command, commandString: cmd)
    }
    
    static func text(_ text: String) -> Action {
        Action(type: .text, textToType: text)
    }
    
    var displayName: String {
        switch type {
        case .mouseClick:
            return mouseButton?.displayName ?? "Click"
        case .mouseDrag:
            return "Drag"
        case .shortcut:
            let mods = modifiers?.displayString ?? ""
            let key = keyDisplay ?? ""
            return "\(mods)\(key)"
        case .profileWheel:
            return "Profile"
        case .command:
            return commandString ?? "Cmd"
        case .text:
            let preview = textToType?.prefix(10) ?? ""
            return "Text: \(preview)"
        case .mouseMove:
            return "Move"
        case .scroll:
            return "Scroll"
        case .none:
            return "—"
        }
    }
}

// MARK: - 常用快捷键 KeyCode

struct KeyCodes {
    static let a: Int = Int(kVK_ANSI_A)
    static let b: Int = Int(kVK_ANSI_B)
    static let c: Int = Int(kVK_ANSI_C)
    static let p: Int = Int(kVK_ANSI_P)
    static let v: Int = Int(kVK_ANSI_V)
    static let z: Int = Int(kVK_ANSI_Z)
    static let space: Int = Int(kVK_Space)
    static let returnKey: Int = Int(kVK_Return)
    static let escape: Int = Int(kVK_Escape)
    static let upArrow: Int = Int(kVK_UpArrow)
    static let downArrow: Int = Int(kVK_DownArrow)
    static let leftArrow: Int = Int(kVK_LeftArrow)
    static let rightArrow: Int = Int(kVK_RightArrow)
}
