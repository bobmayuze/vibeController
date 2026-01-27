import Foundation
import IOKit
import IOKit.hid
import CoreGraphics
import AppKit

// MARK: - HID 手柄管理器

class HIDControllerManager: ObservableObject {
    static let shared = HIDControllerManager()
    
    @Published var isConnected = false
    @Published var controllerName = ""
    @Published var isEnabled = true
    @Published var isAppSwitcherActive = false
    @Published var pressedButtons: Set<String> = []
    @Published var ltActive = false
    @Published var rtActive = false
    @Published var leftStickActive = false
    @Published var rightStickActive = false
    @Published var leftStickXValue: Float = 0
    @Published var leftStickYValue: Float = 0
    @Published var rightStickXValue: Float = 0
    @Published var rightStickYValue: Float = 0
    
    // 配置
    var cursorSpeed: CGFloat = 15
    var scrollSpeed: CGFloat = 8
    var deadZone: Float = 0.15
    
    // 手柄状态
    private var leftStickX: Float = 0
    private var leftStickY: Float = 0
    private var rightStickX: Float = 0
    private var rightStickY: Float = 0
    private var leftTrigger: Float = 0
    private var rightTrigger: Float = 0
    
    private var buttonStates: [UInt32: Bool] = [:]
    private var lastDPad = -1
    
    private var manager: IOHIDManager?
    private var processTimer: DispatchSourceTimer?
    
    // 鼠标状态
    private var mouseLocation: CGPoint = .zero
    private var isDragging = false
    
    // 连击追踪 (用于支持双击/三击)
    private var lastClickTime: [Int: Date] = [:]  // button -> 上次点击时间
    private var clickCount: [Int: Int64] = [:]     // button -> 当前连击次数
    private let doubleClickInterval: TimeInterval = 0.5  // 双击判定间隔（秒）
    
    // Profile 轮盘状态
    @Published var profileWheelActive = false
    private var profileWheelTriggerButton: UInt32? = nil  // 记录哪个按钮触发了轮盘
    
    private init() {}
    
    // MARK: - 启动/停止
    
    func start() {
        updateMouseLocation()
        setupHIDManager()
        startProcessTimer()
        print("✅ HID Manager 已启动")
    }
    
    func stop() {
        processTimer?.cancel()
        processTimer = nil
        if let manager = manager {
            IOHIDManagerClose(manager, IOOptionBits(kIOHIDOptionsTypeNone))
        }
    }
    
    // MARK: - HID 设置
    
    private func setupHIDManager() {
        manager = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))
        guard let manager = manager else { return }
        
        let matchingDict: [String: Any] = [
            kIOHIDDeviceUsagePageKey as String: kHIDPage_GenericDesktop,
            kIOHIDDeviceUsageKey as String: kHIDUsage_GD_GamePad
        ]
        IOHIDManagerSetDeviceMatching(manager, matchingDict as CFDictionary)
        
        let context = Unmanaged.passUnretained(self).toOpaque()
        
        IOHIDManagerRegisterDeviceMatchingCallback(manager, { ctx, _, _, device in
            guard let ctx = ctx else { return }
            let this = Unmanaged<HIDControllerManager>.fromOpaque(ctx).takeUnretainedValue()
            let name = IOHIDDeviceGetProperty(device, kIOHIDProductKey as CFString) as? String ?? "Unknown"
            DispatchQueue.main.async {
                this.isConnected = true
                this.controllerName = name
            }
            print("✅ 手柄已连接: \(name)")
        }, context)
        
        IOHIDManagerRegisterDeviceRemovalCallback(manager, { ctx, _, _, _ in
            guard let ctx = ctx else { return }
            let this = Unmanaged<HIDControllerManager>.fromOpaque(ctx).takeUnretainedValue()
            DispatchQueue.main.async {
                this.isConnected = false
                this.controllerName = ""
            }
            print("❌ 手柄已断开")
        }, context)
        
        IOHIDManagerRegisterInputValueCallback(manager, { ctx, _, _, value in
            guard let ctx = ctx else { return }
            let this = Unmanaged<HIDControllerManager>.fromOpaque(ctx).takeUnretainedValue()
            this.handleInput(value)
        }, context)
        
        IOHIDManagerScheduleWithRunLoop(manager, CFRunLoopGetMain(), CFRunLoopMode.commonModes.rawValue)
        IOHIDManagerOpen(manager, IOOptionBits(kIOHIDOptionsTypeNone))
    }
    
    // MARK: - 输入处理
    
    private func handleInput(_ value: IOHIDValue) {
        guard isEnabled else { return }
        
        let element = IOHIDValueGetElement(value)
        let usage = IOHIDElementGetUsage(element)
        let usagePage = IOHIDElementGetUsagePage(element)
        let intValue = IOHIDValueGetIntegerValue(value)
        
        // 按钮
        if usagePage == kHIDPage_Button {
            let pressed = intValue == 1
            let wasPressed = buttonStates[usage] ?? false
            buttonStates[usage] = pressed
            
            let buttonName = buttonNameFor(usage)
            DispatchQueue.main.async {
                if pressed { self.pressedButtons.insert(buttonName) }
                else { self.pressedButtons.remove(buttonName) }
            }
            
            // 检查是否是轮盘释放
            if !pressed && wasPressed && profileWheelTriggerButton == usage {
                print("🔘 轮盘按钮释放 → 确认 Profile 选择")
                profileWheelTriggerButton = nil
                Task { @MainActor in
                    self.profileWheelActive = false
                    if let selectedConfig = ProfileWheelWindowController.shared.hide() {
                        ConfigManager.shared.selectConfig(selectedConfig)
                        print("✅ 切换到 Profile: \(selectedConfig.name)")
                    }
                }
                return
            }
            
            if pressed && !wasPressed { handleButtonPress(usage) }
        }
        
        // Back 键 - App Switcher
        if usagePage == kHIDPage_Consumer && usage == 548 {
            let pressed = intValue == 1
            let key = usage + 10000
            let wasPressed = buttonStates[key] ?? false
            buttonStates[key] = pressed
            
            if pressed && !wasPressed {
                print("🔘 Back → App Switcher 开始")
                isAppSwitcherActive = true
                keyDown(55)
                pressKey(48, modifiers: .maskCommand)
            } else if !pressed && wasPressed {
                print("🔘 Back → App Switcher 结束")
                isAppSwitcherActive = false
                keyUp(55)
            }
        }
        
        // 扳机
        if usagePage == 0x02 {
            let normalized = normalizePositive(intValue, element: element)
            if usage == 197 {  // LT
                let wasActive = leftTrigger > 0.5
                leftTrigger = normalized
                DispatchQueue.main.async { self.ltActive = normalized > 0.5 }
                
                // LT 释放时：如果正在拖拽则结束拖拽
                if normalized <= 0.5 && wasActive {
                    if isDragging { endDrag() }
                }
                // LT 按下时：执行配置的动作
                else if normalized > 0.5 && !wasActive {
                    let action = runOnMain { ConfigManager.shared.currentConfig.action(for: .leftTrigger) }
                    if action.type == .mouseDrag {
                        startDrag()
                    } else if action.type != .none {
                        print("🔘 LT → \(action.displayName)")
                        executeAction(action)
                    }
                }
                
            } else if usage == 196 {  // RT
                let wasActive = rightTrigger > 0.5
                rightTrigger = normalized
                DispatchQueue.main.async { self.rtActive = normalized > 0.5 }
                
                // RT 按下时执行配置的动作
                if normalized > 0.5 && !wasActive {
                    let action = runOnMain { ConfigManager.shared.currentConfig.action(for: .rightTrigger) }
                    if action.type != .none {
                        print("🔘 RT → \(action.displayName)")
                        executeAction(action)
                    }
                }
            }
        }
        
        // 摇杆和 D-Pad
        if usagePage == kHIDPage_GenericDesktop {
            switch usage {
            case UInt32(kHIDUsage_GD_X): leftStickX = normalize(intValue, element: element)
            case UInt32(kHIDUsage_GD_Y): leftStickY = normalize(intValue, element: element)
            case UInt32(kHIDUsage_GD_Z): rightStickX = normalize(intValue, element: element)
            case UInt32(kHIDUsage_GD_Rz): rightStickY = normalize(intValue, element: element)
            case UInt32(kHIDUsage_GD_Hatswitch): handleDPad(intValue)
            default: break
            }
        }
    }
    
    private func handleButtonPress(_ button: UInt32) {
        // 将 HID button 编号映射到 ControllerButton
        let controllerButton: ControllerButton?
        switch button {
        case 1: controllerButton = .buttonA
        case 2: controllerButton = .buttonB
        case 4: controllerButton = .buttonX
        case 5: controllerButton = .buttonY
        case 7: controllerButton = .leftBumper
        case 8: controllerButton = .rightBumper
        case 12: controllerButton = .startButton
        case 14: controllerButton = .leftStickButton
        case 15: controllerButton = .rightStickButton
        default: controllerButton = nil
        }
        
        guard let btn = controllerButton else { return }
        
        // App Switcher 模式下，LB/RB 有特殊行为
        if isAppSwitcherActive {
            if btn == .leftBumper {
                print("🔘 LB → 上一个App")
                pressKey(48, modifiers: [.maskCommand, .maskShift])
                return
            } else if btn == .rightBumper {
                print("🔘 RB → 下一个App")
                pressKey(48, modifiers: .maskCommand)
                return
            }
        }
        
        // 从配置读取动作
        let action = runOnMain { ConfigManager.shared.currentConfig.action(for: btn) }
        guard action.type != .none else { return }
        
        // Profile 轮盘 - 特殊处理（需要在按钮释放时确认）
        if action.type == .profileWheel {
            let isLeftStick = (button == 14)  // 14 = LS↓, 15 = RS↓
            print("🔘 \(btn.displayName) → 打开 Profile 轮盘 (用\(isLeftStick ? "右" : "左")摇杆选择)")
            profileWheelTriggerButton = button
            Task { @MainActor in
                self.profileWheelActive = true
                ProfileWheelWindowController.shared.show(triggeredByLeftStick: isLeftStick)
            }
            return
        }
        
        print("🔘 \(btn.displayName): \(action.displayName)")
        executeAction(action)
    }
    
    private func handleDPad(_ value: Int) {
        guard value != lastDPad else { return }
        lastDPad = value
        
        // 确定当前按下的 D-Pad 按钮
        let dpadButton: ControllerButton?
        switch value {
        case 1: dpadButton = .dpadUp
        case 3: dpadButton = .dpadRight
        case 5: dpadButton = .dpadDown
        case 7: dpadButton = .dpadLeft
        default: dpadButton = nil
        }
        
        DispatchQueue.main.async {
            self.pressedButtons.remove("DPadUp")
            self.pressedButtons.remove("DPadDown")
            self.pressedButtons.remove("DPadLeft")
            self.pressedButtons.remove("DPadRight")
            switch value {
            case 1: self.pressedButtons.insert("DPadUp")
            case 3: self.pressedButtons.insert("DPadRight")
            case 5: self.pressedButtons.insert("DPadDown")
            case 7: self.pressedButtons.insert("DPadLeft")
            default: break
            }
        }
        
        guard let button = dpadButton else { return }
        
        // 检查是否有修饰键被按住，尝试执行组合键
        if tryExecuteChord(for: button) {
            return  // 组合键已执行，不再执行普通动作
        }
        
        // 从配置读取 D-Pad 动作
        let action = runOnMain { ConfigManager.shared.currentConfig.action(for: button) }
        guard action.type != .none else { return }
        
        print("🔘 \(button.displayName): \(action.displayName)")
        executeAction(action)
    }
    
    // MARK: - 组合键处理
    
    /// 在主线程同步执行闭包
    private func runOnMain<T>(_ block: @MainActor () -> T) -> T {
        if Thread.isMainThread {
            return MainActor.assumeIsolated { block() }
        } else {
            var result: T!
            DispatchQueue.main.sync {
                result = MainActor.assumeIsolated { block() }
            }
            return result
        }
    }
    
    /// 获取当前按住的所有修饰键
    private func getCurrentPressedModifiers() -> Set<ControllerButton> {
        var pressed: Set<ControllerButton> = []
        if leftTrigger > 0.5 { pressed.insert(.leftTrigger) }
        if rightTrigger > 0.5 { pressed.insert(.rightTrigger) }
        if buttonStates[7] ?? false { pressed.insert(.leftBumper) }
        if buttonStates[8] ?? false { pressed.insert(.rightBumper) }
        return pressed
    }
    
    /// 尝试执行组合键，返回是否成功执行
    private func tryExecuteChord(for button: ControllerButton) -> Bool {
        let pressedModifiers = getCurrentPressedModifiers()
        guard !pressedModifiers.isEmpty else { return false }
        
        // 获取所有匹配的组合键（修饰键是当前按住修饰键的子集）
        let matchingChords: [(ButtonChord, Action)] = runOnMain {
            ConfigManager.shared.currentConfig.chordMappings.compactMap { chord, action in
                // 检查：组合键的所有修饰键都被按住，且主按钮匹配
                if chord.modifiers.isSubset(of: pressedModifiers) && chord.button == button {
                    return (chord, action)
                }
                return nil
            }
        }
        
        // 按修饰键数量从多到少排序（更精确的组合优先）
        if let (chord, action) = matchingChords.sorted(by: { $0.0.modifiers.count > $1.0.modifiers.count }).first,
           action.type != .none {
            print("🔘 组合键: \(chord.displayName): \(action.displayName)")
            executeAction(action)
            return true
        }
        
        return false
    }
    
    /// 执行动作
    private func executeAction(_ action: Action) {
        switch action.type {
        case .shortcut:
            if let keyCode = action.keyCode {
                let flags = action.modifiers?.cgEventFlags ?? []
                pressKey(keyCode, modifiers: flags)
            }
        case .mouseClick:
            switch action.mouseButton {
            case .left: click(0)
            case .right: click(1)
            case .middle: clickMiddle()
            case .none: break
            }
        default:
            break
        }
    }
    
    private func clickMiddle() {
        updateMouseLocation()
        
        // 计算连击次数 (用 button = 2 表示中键)
        let button = 2
        let now = Date()
        if let lastTime = lastClickTime[button], now.timeIntervalSince(lastTime) < doubleClickInterval {
            clickCount[button] = (clickCount[button] ?? 0) + 1
        } else {
            clickCount[button] = 1
        }
        lastClickTime[button] = now
        let count = clickCount[button] ?? 1
        
        let clickName = count == 1 ? "单击" : count == 2 ? "双击" : "\(count)连击"
        print("   中键点击位置: \(mouseLocation) (\(clickName))")
        
        if let down = CGEvent(mouseEventSource: nil, mouseType: .otherMouseDown, mouseCursorPosition: mouseLocation, mouseButton: .center),
           let up = CGEvent(mouseEventSource: nil, mouseType: .otherMouseUp, mouseCursorPosition: mouseLocation, mouseButton: .center) {
            down.setIntegerValueField(.mouseEventButtonNumber, value: 2)
            down.setIntegerValueField(.mouseEventClickState, value: count)
            up.setIntegerValueField(.mouseEventButtonNumber, value: 2)
            up.setIntegerValueField(.mouseEventClickState, value: count)
            down.post(tap: .cgSessionEventTap)
            up.post(tap: .cgSessionEventTap)
            print("   中键\(clickName)成功")
        }
    }
    
    private func buttonNameFor(_ usage: UInt32) -> String {
        switch usage {
        case 1: return "A"
        case 2: return "B"
        case 4: return "X"
        case 5: return "Y"
        case 7: return "LB"
        case 8: return "RB"
        case 12: return "Start"
        case 14: return "LS↓"  // Left Stick Press
        case 15: return "RS↓"  // Right Stick Press
        default: return "Button\(usage)"
        }
    }
    
    // MARK: - 摇杆处理
    
    private func startProcessTimer() {
        processTimer = DispatchSource.makeTimerSource(queue: .global(qos: .userInteractive))
        processTimer?.schedule(deadline: .now(), repeating: 1.0/60.0)
        processTimer?.setEventHandler { [weak self] in self?.processSticks() }
        processTimer?.resume()
    }
    
    private func processSticks() {
        guard isEnabled else { return }
        
        let lx = applyDeadZone(leftStickX), ly = applyDeadZone(leftStickY)
        let leftActive = lx != 0 || ly != 0
        let rx = applyDeadZone(rightStickX), ry = applyDeadZone(rightStickY)
        let rightActive = rx != 0 || ry != 0
        
        // 如果 Profile 轮盘激活，用另一个摇杆选择 Profile
        if profileWheelActive {
            Task { @MainActor in
                // 根据触发按钮选择用哪个摇杆
                // 如果是左摇杆触发的，用右摇杆选择；反之亦然
                let useRightStick = ProfileWheelWindowController.shared.triggeredByLeftStick
                let stickX = useRightStick ? self.rightStickX : self.leftStickX
                let stickY = useRightStick ? self.rightStickY : self.leftStickY
                ProfileWheelWindowController.shared.updateSelection(stickX: stickX, stickY: stickY)
            }
        } else {
            if leftActive {
                moveMouse(dx: CGFloat(lx) * cursorSpeed, dy: CGFloat(ly) * cursorSpeed)
            }
            if rightActive {
                scroll(dx: CGFloat(rx) * scrollSpeed, dy: CGFloat(ry) * scrollSpeed)
            }
        }
        
        DispatchQueue.main.async {
            self.leftStickActive = leftActive
            self.rightStickActive = rightActive
            self.leftStickXValue = lx
            self.leftStickYValue = ly
            self.rightStickXValue = rx
            self.rightStickYValue = ry
        }
    }
    
    // MARK: - 工具函数
    
    private func applyDeadZone(_ v: Float) -> Float {
        abs(v) < deadZone ? 0 : (v > 0 ? 1 : -1) * (abs(v) - deadZone) / (1 - deadZone)
    }
    
    private func normalize(_ v: Int, element: IOHIDElement) -> Float {
        let min = IOHIDElementGetLogicalMin(element), max = IOHIDElementGetLogicalMax(element)
        let range = Float(max - min)
        return range == 0 ? 0 : (Float(v - min) / range) * 2 - 1
    }
    
    private func normalizePositive(_ v: Int, element: IOHIDElement) -> Float {
        let min = IOHIDElementGetLogicalMin(element), max = IOHIDElementGetLogicalMax(element)
        let range = Float(max - min)
        return range == 0 ? 0 : Float(v - min) / range
    }
    
    // MARK: - 鼠标/键盘
    
    private func updateMouseLocation() {
        // 直接用 CGEvent 获取鼠标位置，已经是 Quartz 坐标系（左上角原点）
        mouseLocation = CGEvent(source: nil)?.location ?? .zero
    }
    
    private func getTotalDisplayBounds() -> CGRect {
        // 使用 CGDisplayBounds 获取 Quartz 坐标系下的所有显示器边界
        var bounds = CGRect.zero
        let maxDisplays: UInt32 = 16
        var displays = [CGDirectDisplayID](repeating: 0, count: Int(maxDisplays))
        var displayCount: UInt32 = 0
        CGGetActiveDisplayList(maxDisplays, &displays, &displayCount)
        for i in 0..<Int(displayCount) {
            let displayBounds = CGDisplayBounds(displays[i])
            bounds = bounds.union(displayBounds)
        }
        return bounds
    }
    
    private func moveMouse(dx: CGFloat, dy: CGFloat) {
        // 每次移动前先同步真实鼠标位置，防止漂移
        mouseLocation = CGEvent(source: nil)?.location ?? mouseLocation
        mouseLocation.x += dx; mouseLocation.y += dy
        // 获取所有显示器的总边界（Quartz 坐标系）
        let totalBounds = getTotalDisplayBounds()
        mouseLocation.x = max(totalBounds.minX, min(mouseLocation.x, totalBounds.maxX - 1))
        mouseLocation.y = max(totalBounds.minY, min(mouseLocation.y, totalBounds.maxY - 1))
        CGWarpMouseCursorPosition(mouseLocation)
        CGAssociateMouseAndMouseCursorPosition(1)
        if isDragging { postMouse(.leftMouseDragged) }
    }
    
    private func scroll(dx: CGFloat, dy: CGFloat) {
        CGEvent(scrollWheelEvent2Source: nil, units: .pixel, wheelCount: 2, wheel1: Int32(dy), wheel2: Int32(-dx), wheel3: 0)?.post(tap: .cghidEventTap)
    }
    
    private func click(_ button: Int) {
        updateMouseLocation()
        
        // 计算连击次数
        let now = Date()
        if let lastTime = lastClickTime[button], now.timeIntervalSince(lastTime) < doubleClickInterval {
            clickCount[button] = (clickCount[button] ?? 0) + 1
        } else {
            clickCount[button] = 1
        }
        lastClickTime[button] = now
        let count = clickCount[button] ?? 1
        
        let clickName = count == 1 ? "单击" : count == 2 ? "双击" : "\(count)连击"
        print("   点击位置: \(mouseLocation) (\(clickName))")
        
        if button == 0 {
            if postMouse(.leftMouseDown, clickCount: count) && postMouse(.leftMouseUp, clickCount: count) {
                print("   左键\(clickName)成功")
            } else {
                print("   ❌ 左键点击失败")
            }
        } else {
            if postMouse(.rightMouseDown, button: .right, clickCount: count) && postMouse(.rightMouseUp, button: .right, clickCount: count) {
                print("   右键\(clickName)成功")
            } else {
                print("   ❌ 右键点击失败")
            }
        }
    }
    
    private func startDrag() {
        guard !isDragging else { return }
        isDragging = true; updateMouseLocation(); postMouse(.leftMouseDown)
        print("   拖拽开始")
    }
    
    private func endDrag() {
        guard isDragging else { return }
        isDragging = false; postMouse(.leftMouseUp)
        print("   拖拽结束")
    }
    
    @discardableResult
    private func postMouse(_ type: CGEventType, button: CGMouseButton = .left, clickCount: Int64 = 1) -> Bool {
        guard let event = CGEvent(mouseEventSource: nil, mouseType: type, mouseCursorPosition: mouseLocation, mouseButton: button) else {
            print("   ❌ CGEvent 创建失败")
            return false
        }
        event.setIntegerValueField(.mouseEventClickState, value: clickCount)
        // 使用 cgSessionEventTap 以确保窗口能被激活
        event.post(tap: .cgSessionEventTap)
        return true
    }
    
    private func pressKey(_ code: Int, modifiers: CGEventFlags = []) {
        print("   pressKey: code=\(code), modifiers=\(modifiers.rawValue)")
        if let down = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(code), keyDown: true) {
            down.flags = modifiers
            down.post(tap: .cghidEventTap)
            print("   ✓ key down posted")
        } else {
            print("   ✗ failed to create key down event")
        }
        if let up = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(code), keyDown: false) {
            up.flags = modifiers
            up.post(tap: .cghidEventTap)
            print("   ✓ key up posted")
        } else {
            print("   ✗ failed to create key up event")
        }
    }
    
    private func keyDown(_ code: Int) {
        CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(code), keyDown: true)?.post(tap: .cghidEventTap)
    }
    
    private func keyUp(_ code: Int) {
        CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(code), keyDown: false)?.post(tap: .cghidEventTap)
    }
    
    func toggleEnabled() { isEnabled.toggle() }
}
