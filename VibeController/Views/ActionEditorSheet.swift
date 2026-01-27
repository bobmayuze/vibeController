import SwiftUI
import Carbon.HIToolbox

// MARK: - 动作编辑弹窗

struct ActionEditorSheet: View {
    let button: ControllerButton
    let currentAction: Action
    let onSave: (Action) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    // 当前编辑状态
    @State private var actionType: ActionType
    @State private var mouseButton: MouseButton = .left
    @State private var modifiers: ModifierKeys = []
    @State private var keyCode: Int = 0
    @State private var keyDisplay: String = ""
    @State private var commandString: String = ""
    @State private var textToType: String = ""
    
    // 原始值（用于检测改动和还原）
    private let originalActionType: ActionType
    private let originalMouseButton: MouseButton
    private let originalModifiers: ModifierKeys
    private let originalKeyCode: Int
    private let originalKeyDisplay: String
    private let originalCommandString: String
    private let originalTextToType: String
    
    init(button: ControllerButton, currentAction: Action, onSave: @escaping (Action) -> Void) {
        self.button = button
        self.currentAction = currentAction
        self.onSave = onSave
        
        // 初始化当前值
        _actionType = State(initialValue: currentAction.type)
        _mouseButton = State(initialValue: currentAction.mouseButton ?? .left)
        _modifiers = State(initialValue: currentAction.modifiers ?? [])
        _keyCode = State(initialValue: currentAction.keyCode ?? 0)
        _keyDisplay = State(initialValue: currentAction.keyDisplay ?? "")
        _commandString = State(initialValue: currentAction.commandString ?? "")
        _textToType = State(initialValue: currentAction.textToType ?? "")
        
        // 保存原始值
        self.originalActionType = currentAction.type
        self.originalMouseButton = currentAction.mouseButton ?? .left
        self.originalModifiers = currentAction.modifiers ?? []
        self.originalKeyCode = currentAction.keyCode ?? 0
        self.originalKeyDisplay = currentAction.keyDisplay ?? ""
        self.originalCommandString = currentAction.commandString ?? ""
        self.originalTextToType = currentAction.textToType ?? ""
    }
    
    // 检查是否有改动
    private var hasChanges: Bool {
        actionType != originalActionType ||
        mouseButton != originalMouseButton ||
        modifiers != originalModifiers ||
        keyCode != originalKeyCode ||
        keyDisplay != originalKeyDisplay ||
        commandString != originalCommandString ||
        textToType != originalTextToType
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 标题
            HStack {
                Text("编辑按键: \(button.displayName)")
                    .font(.headline)
                Spacer()
            }
            .padding()
            
            Divider()
            
            // 可滚动内容
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // 动作类型选择
                    VStack(alignment: .leading, spacing: 12) {
                        Text("动作类型")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Picker("", selection: $actionType) {
                            ForEach(ActionType.allCases.filter { $0 != .mouseMove && $0 != .scroll }, id: \.self) { type in
                                Text(type.displayName).tag(type)
                            }
                        }
                        .pickerStyle(.radioGroup)
                    }
                    
                    Divider()
                    
                    // 根据类型显示不同的配置
                    switch actionType {
                    case .mouseClick:
                        mouseClickConfig
                    case .shortcut:
                        shortcutConfig
                    case .command:
                        commandConfig
                    case .text:
                        textConfig
                    case .none, .mouseMove, .scroll:
                        Text("无需配置")
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
            }
            
            Divider()
            
            // 底部按钮
            HStack {
                // 还原按钮（只在有改动时显示）
                if hasChanges {
                    Button("还原") {
                        resetToOriginal()
                    }
                }
                
                Spacer()
                
                // 保存/关闭按钮
                Button(hasChanges ? "保存" : "关闭") {
                    if hasChanges {
                        saveAction()
                    }
                    dismiss()
                }
                .keyboardShortcut(.return)
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .frame(width: 420, height: 400)
    }
    
    // MARK: - 鼠标点击配置
    
    private var mouseClickConfig: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("鼠标按钮")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Picker("", selection: $mouseButton) {
                ForEach(MouseButton.allCases, id: \.self) { btn in
                    Text(btn.displayName).tag(btn)
                }
            }
            .pickerStyle(.segmented)
        }
    }
    
    // MARK: - 快捷键配置
    
    private var shortcutConfig: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("键盘快捷键")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // 当前快捷键显示
            HStack {
                Text("当前:")
                Text(shortcutDisplayString)
                    .font(.system(.body, design: .monospaced))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(4)
            }
            
            Text("在下方手动选择修饰键和输入按键")
                .font(.caption)
                .foregroundColor(.secondary)
            
            // 修饰键选择
            VStack(alignment: .leading, spacing: 6) {
                Text("修饰键:")
                    .font(.caption)
                
                HStack {
                    Toggle("⌘ Command", isOn: Binding(
                        get: { modifiers.contains(.command) },
                        set: { if $0 { modifiers.insert(.command) } else { modifiers.remove(.command) } }
                    ))
                    Toggle("⌥ Option", isOn: Binding(
                        get: { modifiers.contains(.option) },
                        set: { if $0 { modifiers.insert(.option) } else { modifiers.remove(.option) } }
                    ))
                }
                HStack {
                    Toggle("⌃ Control", isOn: Binding(
                        get: { modifiers.contains(.control) },
                        set: { if $0 { modifiers.insert(.control) } else { modifiers.remove(.control) } }
                    ))
                    Toggle("⇧ Shift", isOn: Binding(
                        get: { modifiers.contains(.shift) },
                        set: { if $0 { modifiers.insert(.shift) } else { modifiers.remove(.shift) } }
                    ))
                }
            }
            .font(.caption)
            
            // 按键输入
            HStack {
                Text("按键:")
                TextField("按键", text: $keyDisplay)
                    .frame(width: 60)
                    .onChange(of: keyDisplay) { newValue in
                        if let firstChar = newValue.uppercased().first {
                            keyCode = keyCodeFor(character: firstChar)
                            keyDisplay = String(firstChar)
                        }
                    }
            }
        }
    }
    
    private var shortcutDisplayString: String {
        let mods = modifiers.displayString
        let key = keyDisplay.isEmpty ? "未设置" : keyDisplay
        return mods.isEmpty ? key : "\(mods) + \(key)"
    }
    
    // MARK: - 命令配置
    
    private var commandConfig: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Shell 命令")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            TextField("例如: open -a Safari", text: $commandString)
                .textFieldStyle(.roundedBorder)
            
            Text("提示: 命令会在后台执行")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - 文本配置
    
    private var textConfig: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("输入文本")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            TextField("要输入的文本", text: $textToType)
                .textFieldStyle(.roundedBorder)
        }
    }
    
    // MARK: - 还原
    
    private func resetToOriginal() {
        actionType = originalActionType
        mouseButton = originalMouseButton
        modifiers = originalModifiers
        keyCode = originalKeyCode
        keyDisplay = originalKeyDisplay
        commandString = originalCommandString
        textToType = originalTextToType
    }
    
    // MARK: - 保存
    
    private func saveAction() {
        var action = Action(type: actionType)
        
        switch actionType {
        case .mouseClick:
            action.mouseButton = mouseButton
        case .shortcut:
            action.modifiers = modifiers
            action.keyCode = keyCode
            action.keyDisplay = keyDisplay
        case .command:
            action.commandString = commandString
        case .text:
            action.textToType = textToType
        default:
            break
        }
        
        onSave(action)
    }
    
    // MARK: - 按键码映射
    
    private func keyCodeFor(character: Character) -> Int {
        let keyMap: [Character: Int] = [
            "A": Int(kVK_ANSI_A), "B": Int(kVK_ANSI_B), "C": Int(kVK_ANSI_C),
            "D": Int(kVK_ANSI_D), "E": Int(kVK_ANSI_E), "F": Int(kVK_ANSI_F),
            "G": Int(kVK_ANSI_G), "H": Int(kVK_ANSI_H), "I": Int(kVK_ANSI_I),
            "J": Int(kVK_ANSI_J), "K": Int(kVK_ANSI_K), "L": Int(kVK_ANSI_L),
            "M": Int(kVK_ANSI_M), "N": Int(kVK_ANSI_N), "O": Int(kVK_ANSI_O),
            "P": Int(kVK_ANSI_P), "Q": Int(kVK_ANSI_Q), "R": Int(kVK_ANSI_R),
            "S": Int(kVK_ANSI_S), "T": Int(kVK_ANSI_T), "U": Int(kVK_ANSI_U),
            "V": Int(kVK_ANSI_V), "W": Int(kVK_ANSI_W), "X": Int(kVK_ANSI_X),
            "Y": Int(kVK_ANSI_Y), "Z": Int(kVK_ANSI_Z),
            "0": Int(kVK_ANSI_0), "1": Int(kVK_ANSI_1), "2": Int(kVK_ANSI_2),
            "3": Int(kVK_ANSI_3), "4": Int(kVK_ANSI_4), "5": Int(kVK_ANSI_5),
            "6": Int(kVK_ANSI_6), "7": Int(kVK_ANSI_7), "8": Int(kVK_ANSI_8),
            "9": Int(kVK_ANSI_9),
        ]
        return keyMap[character] ?? 0
    }
}
