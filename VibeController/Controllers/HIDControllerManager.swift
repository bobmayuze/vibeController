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
            if usage == 197 {  // LT - 拖拽
                let wasActive = leftTrigger > 0.5
                leftTrigger = normalized
                DispatchQueue.main.async { self.ltActive = normalized > 0.5 }
                if normalized > 0.5 && !wasActive { startDrag() }
                else if normalized <= 0.5 && wasActive { endDrag() }
            } else if usage == 196 {  // RT - 回车
                let wasActive = rightTrigger > 0.5
                rightTrigger = normalized
                DispatchQueue.main.async { self.rtActive = normalized > 0.5 }
                if normalized > 0.5 && !wasActive {
                    print("🔘 RT → 回车")
                    pressKey(36)
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
        switch button {
        case 1: print("🔘 A → 左键"); click(0)
        case 2: print("🔘 B → 右键"); click(1)
        case 4: print("🔘 X → 复制"); pressKey(8, modifiers: .maskCommand)
        case 5: print("🔘 Y → 粘贴"); pressKey(9, modifiers: .maskCommand)
        case 7:
            if isAppSwitcherActive {
                print("🔘 LB → 上一个App"); pressKey(48, modifiers: [.maskCommand, .maskShift])
            } else {
                print("🔘 LB → 撤销"); pressKey(6, modifiers: .maskCommand)
            }
        case 8:
            if isAppSwitcherActive {
                print("🔘 RB → 下一个App"); pressKey(48, modifiers: .maskCommand)
            } else {
                print("🔘 RB → Option+Space"); pressKey(49, modifiers: .maskAlternate)
            }
        case 12: print("🔘 Start → 命令面板"); pressKey(35, modifiers: [.maskCommand, .maskShift])
        case 14: print("🔘 L3 → 回车"); pressKey(36)
        case 15: print("🔘 R3 → Esc"); pressKey(53)
        default: break
        }
    }
    
    private func handleDPad(_ value: Int) {
        guard value != lastDPad else { return }
        lastDPad = value
        
        DispatchQueue.main.async {
            self.pressedButtons.remove("DPad")
            if value != 0 && value != 8 { self.pressedButtons.insert("DPad") }
        }
        
        switch value {
        case 1: print("🔘 D-Pad ↑"); pressKey(126)
        case 3: print("🔘 D-Pad →"); pressKey(124)
        case 5: print("🔘 D-Pad ↓"); pressKey(125)
        case 7: print("🔘 D-Pad ←"); pressKey(123)
        default: break
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
        case 14: return "L3"
        case 15: return "R3"
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
        if leftActive {
            moveMouse(dx: CGFloat(lx) * cursorSpeed, dy: CGFloat(ly) * cursorSpeed)
        }
        
        let rx = applyDeadZone(rightStickX), ry = applyDeadZone(rightStickY)
        let rightActive = rx != 0 || ry != 0
        if rightActive {
            scroll(dx: CGFloat(rx) * scrollSpeed, dy: CGFloat(ry) * scrollSpeed)
        }
        
        DispatchQueue.main.async {
            self.leftStickActive = leftActive
            self.rightStickActive = rightActive
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
        let loc = NSEvent.mouseLocation
        if let screen = NSScreen.main {
            mouseLocation = CGPoint(x: loc.x, y: screen.frame.height - loc.y)
        }
    }
    
    private func moveMouse(dx: CGFloat, dy: CGFloat) {
        mouseLocation.x += dx; mouseLocation.y += dy
        if let screen = NSScreen.main {
            mouseLocation.x = max(0, min(mouseLocation.x, screen.frame.width))
            mouseLocation.y = max(0, min(mouseLocation.y, screen.frame.height))
        }
        CGWarpMouseCursorPosition(mouseLocation)
        CGAssociateMouseAndMouseCursorPosition(1)  // 重新关联鼠标和光标
        if isDragging { postMouse(.leftMouseDragged) }
    }
    
    private func scroll(dx: CGFloat, dy: CGFloat) {
        CGEvent(scrollWheelEvent2Source: nil, units: .pixel, wheelCount: 2, wheel1: Int32(dy), wheel2: Int32(-dx), wheel3: 0)?.post(tap: .cghidEventTap)
    }
    
    private func click(_ button: Int) {
        updateMouseLocation()
        print("   点击位置: \(mouseLocation)")
        if button == 0 {
            if postMouse(.leftMouseDown) && postMouse(.leftMouseUp) {
                print("   左键点击成功")
            } else {
                print("   ❌ 左键点击失败")
            }
        } else {
            if postMouse(.rightMouseDown, button: .right) && postMouse(.rightMouseUp, button: .right) {
                print("   右键点击成功")
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
    private func postMouse(_ type: CGEventType, button: CGMouseButton = .left) -> Bool {
        guard let event = CGEvent(mouseEventSource: nil, mouseType: type, mouseCursorPosition: mouseLocation, mouseButton: button) else {
            print("   ❌ CGEvent 创建失败")
            return false
        }
        event.post(tap: .cghidEventTap)  // 使用 cghidEventTap 而不是 cgSessionEventTap
        return true
    }
    
    private func pressKey(_ code: Int, modifiers: CGEventFlags = []) {
        if let down = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(code), keyDown: true) {
            down.flags = modifiers; down.post(tap: .cghidEventTap)
        }
        if let up = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(code), keyDown: false) {
            up.flags = modifiers; up.post(tap: .cghidEventTap)
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
