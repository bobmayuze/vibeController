#!/usr/bin/env swift

import Foundation
import IOKit
import IOKit.hid
import CoreGraphics
import AppKit

print("🎮 Vibe Controller Service")
print("   基于 IOKit HID 的后台服务")
print("   按 Ctrl+C 退出\n")

// MARK: - 鼠标/键盘控制

class InputController {
    var mouseLocation: CGPoint = .zero
    var isPrecisionMode = false
    var isDragging = false
    
    init() {
        updateMouseLocation()
    }
    
    func updateMouseLocation() {
        let loc = NSEvent.mouseLocation
        if let screen = NSScreen.main {
            mouseLocation = CGPoint(x: loc.x, y: screen.frame.height - loc.y)
        }
    }
    
    func moveMouse(dx: CGFloat, dy: CGFloat) {
        mouseLocation.x += dx
        mouseLocation.y += dy
        
        if let screen = NSScreen.main {
            mouseLocation.x = max(0, min(mouseLocation.x, screen.frame.width))
            mouseLocation.y = max(0, min(mouseLocation.y, screen.frame.height))
        }
        
        CGWarpMouseCursorPosition(mouseLocation)
        
        if isDragging {
            postMouseEvent(type: .leftMouseDragged, at: mouseLocation)
        }
    }
    
    func scroll(dx: CGFloat, dy: CGFloat) {
        if let event = CGEvent(scrollWheelEvent2Source: nil, units: .pixel, wheelCount: 2, wheel1: Int32(dy), wheel2: Int32(-dx), wheel3: 0) {
            event.post(tap: .cgSessionEventTap)
        }
    }
    
    func click(button: Int) {
        updateMouseLocation()
        if button == 0 {
            postMouseEvent(type: .leftMouseDown, at: mouseLocation)
            postMouseEvent(type: .leftMouseUp, at: mouseLocation)
        } else {
            postMouseEvent(type: .rightMouseDown, at: mouseLocation)
            postMouseEvent(type: .rightMouseUp, at: mouseLocation)
        }
    }
    
    func startDrag() {
        guard !isDragging else { return }
        isDragging = true
        updateMouseLocation()
        postMouseEvent(type: .leftMouseDown, at: mouseLocation)
        print("   拖拽开始")
    }
    
    func endDrag() {
        guard isDragging else { return }
        isDragging = false
        postMouseEvent(type: .leftMouseUp, at: mouseLocation)
        print("   拖拽结束")
    }
    
    private func postMouseEvent(type: CGEventType, at location: CGPoint) {
        if let event = CGEvent(mouseEventSource: nil, mouseType: type, mouseCursorPosition: location, mouseButton: .left) {
            event.post(tap: .cgSessionEventTap)
        }
    }
    
    func pressKey(keyCode: Int, modifiers: CGEventFlags = []) {
        if let keyDown = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(keyCode), keyDown: true) {
            keyDown.flags = modifiers
            keyDown.post(tap: .cgSessionEventTap)
        }
        if let keyUp = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(keyCode), keyDown: false) {
            keyUp.flags = modifiers
            keyUp.post(tap: .cgSessionEventTap)
        }
    }
    
    func keyDown(keyCode: Int, modifiers: CGEventFlags = []) {
        if let event = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(keyCode), keyDown: true) {
            event.flags = modifiers
            event.post(tap: .cgSessionEventTap)
        }
    }
    
    func keyUp(keyCode: Int, modifiers: CGEventFlags = []) {
        if let event = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(keyCode), keyDown: false) {
            event.flags = modifiers
            event.post(tap: .cgSessionEventTap)
        }
    }
    
    func startDictation() {
        let script = """
        tell application "System Events"
            tell (first application process whose frontmost is true)
                tell menu bar 1
                    tell menu bar item "Edit"
                        tell menu "Edit"
                            click menu item "Start Dictation"
                        end tell
                    end tell
                end tell
            end tell
        end tell
        """
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
        process.arguments = ["-e", script]
        try? process.run()
    }
}

// MARK: - HID 手柄服务

class HIDControllerService {
    let input = InputController()
    var manager: IOHIDManager?
    var isEnabled = true
    
    // 配置
    var cursorSpeed: CGFloat = 15
    var scrollSpeed: CGFloat = 8
    var deadZone: Float = 0.15
    var precisionMultiplier: CGFloat = 0.3
    
    // 手柄状态
    var leftStickX: Float = 0
    var leftStickY: Float = 0
    var rightStickX: Float = 0
    var rightStickY: Float = 0
    var leftTrigger: Float = 0
    var rightTrigger: Float = 0
    
    // 按钮状态（用于检测按下/释放）
    var buttonStates: [UInt32: Bool] = [:]
    
    // App Switcher 模式
    var isAppSwitcherActive = false
    
    // 处理定时器
    var processTimer: DispatchSourceTimer?
    
    init() {
        setupHIDManager()
        startProcessTimer()
    }
    
    func setupHIDManager() {
        manager = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))
        
        guard let manager = manager else {
            print("❌ 无法创建 HID Manager")
            return
        }
        
        // 匹配游戏手柄
        let matchingDict: [String: Any] = [
            kIOHIDDeviceUsagePageKey as String: kHIDPage_GenericDesktop,
            kIOHIDDeviceUsageKey as String: kHIDUsage_GD_GamePad
        ]
        
        IOHIDManagerSetDeviceMatching(manager, matchingDict as CFDictionary)
        
        let context = Unmanaged.passUnretained(self).toOpaque()
        
        IOHIDManagerRegisterDeviceMatchingCallback(manager, { context, result, sender, device in
            guard let context = context else { return }
            let this = Unmanaged<HIDControllerService>.fromOpaque(context).takeUnretainedValue()
            this.deviceConnected(device)
        }, context)
        
        IOHIDManagerRegisterDeviceRemovalCallback(manager, { context, result, sender, device in
            print("❌ 手柄已断开")
        }, context)
        
        IOHIDManagerRegisterInputValueCallback(manager, { context, result, sender, value in
            guard let context = context else { return }
            let this = Unmanaged<HIDControllerService>.fromOpaque(context).takeUnretainedValue()
            this.handleInput(value)
        }, context)
        
        IOHIDManagerScheduleWithRunLoop(manager, CFRunLoopGetMain(), CFRunLoopMode.defaultMode.rawValue)
        let openResult = IOHIDManagerOpen(manager, IOOptionBits(kIOHIDOptionsTypeNone))
        
        if openResult == kIOReturnSuccess {
            print("✅ HID Manager 已启动，等待手柄连接...")
        } else {
            print("❌ HID Manager 打开失败")
        }
    }
    
    func deviceConnected(_ device: IOHIDDevice) {
        let name = IOHIDDeviceGetProperty(device, kIOHIDProductKey as CFString) as? String ?? "Unknown"
        print("✅ 手柄已连接: \(name)")
        print("\n按键映射:")
        print("   A = 左键点击")
        print("   B = 右键点击")
        print("   X = 复制 (Cmd+C)")
        print("   Y = 粘贴 (Cmd+V)")
        print("   LB = 撤销 (Cmd+Z)")
        print("   RB = 双击右Cmd (听写)")
        print("   LT = 拖拽模式")
        print("   RT = 回车")
        print("   L3 = 回车")
        print("   R3 = Escape")
        print("   Menu = 命令面板 (Cmd+Shift+P)")
        print("   Back = App Switcher (按住+LB/RB切换)")
        print("   左摇杆 = 鼠标移动")
        print("   右摇杆 = 滚动")
        print("   D-Pad = 方向键")
        print("")
    }
    
    func handleInput(_ value: IOHIDValue) {
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
            
            if pressed && !wasPressed {
                handleButtonPress(usage)
            }
        }
        
        // Consumer 按钮 (Back) - App Switcher
        if usagePage == kHIDPage_Consumer {
            let pressed = intValue == 1
            let key = usage + 10000  // 区分 Consumer 按钮
            let wasPressed = buttonStates[key] ?? false
            buttonStates[key] = pressed
            
            if usage == 548 {  // Back button
                if pressed && !wasPressed {
                    // Back pressed - start app switcher (hold Cmd, press Tab)
                    print("🔘 Back 按下 → App Switcher 开始")
                    isAppSwitcherActive = true
                    input.keyDown(keyCode: 55)  // Cmd down
                    input.pressKey(keyCode: 48, modifiers: .maskCommand)  // Tab
                } else if !pressed && wasPressed {
                    // Back released - end app switcher
                    print("🔘 Back 释放 → App Switcher 结束")
                    isAppSwitcherActive = false
                    input.keyUp(keyCode: 55)  // Cmd up
                }
            }
        }
        
        // 扳机 (Simulation page)
        if usagePage == 0x02 {
            let normalized = normalizeAxisPositive(intValue, element: element)
            if usage == 197 {  // LT
                let wasActive = leftTrigger > 0.5
                leftTrigger = normalized
                if normalized > 0.5 && !wasActive {
                    input.startDrag()
                } else if normalized <= 0.5 && wasActive {
                    input.endDrag()
                }
            } else if usage == 196 {  // RT
                let wasActive = rightTrigger > 0.5
                rightTrigger = normalized
                if normalized > 0.5 && !wasActive {
                    print("🎮 RT → 回车")
                    input.pressKey(keyCode: 36)
                }
            }
        }
        
        // 摇杆和 D-Pad
        if usagePage == kHIDPage_GenericDesktop {
            switch usage {
            case UInt32(kHIDUsage_GD_X):  // 左摇杆 X
                leftStickX = normalizeAxis(intValue, element: element)
            case UInt32(kHIDUsage_GD_Y):  // 左摇杆 Y
                leftStickY = normalizeAxis(intValue, element: element)
            case UInt32(kHIDUsage_GD_Z):  // 右摇杆 X
                rightStickX = normalizeAxis(intValue, element: element)
            case UInt32(kHIDUsage_GD_Rz):  // 右摇杆 Y
                rightStickY = normalizeAxis(intValue, element: element)
            case UInt32(kHIDUsage_GD_Hatswitch):  // D-Pad
                handleDPad(intValue)
            default:
                break
            }
        }
    }
    
    func handleButtonPress(_ button: UInt32) {
        switch button {
        case 1:  // A
            print("🔘 A → 左键点击")
            input.click(button: 0)
        case 2:  // B
            print("🔘 B → 右键点击")
            input.click(button: 1)
        case 4:  // X
            print("🔘 X → 复制 (Cmd+C)")
            input.pressKey(keyCode: 8, modifiers: .maskCommand)
        case 5:  // Y
            print("🔘 Y → 粘贴 (Cmd+V)")
            input.pressKey(keyCode: 9, modifiers: .maskCommand)
        case 7:  // LB
            if isAppSwitcherActive {
                print("🔘 LB → 上一个 App (Shift+Tab)")
                input.pressKey(keyCode: 48, modifiers: [.maskCommand, .maskShift])  // Shift+Tab
            } else {
                print("🔘 LB → 撤销 (Cmd+Z)")
                input.pressKey(keyCode: 6, modifiers: .maskCommand)
            }
        case 8:  // RB
            if isAppSwitcherActive {
                print("🔘 RB → 下一个 App (Tab)")
                input.pressKey(keyCode: 48, modifiers: .maskCommand)  // Tab
            } else {
                print("🔘 RB → Option+Space")
                input.pressKey(keyCode: 49, modifiers: .maskAlternate)
            }
        case 12:  // Menu
            print("🔘 Menu → 命令面板 (Cmd+Shift+P)")
            input.pressKey(keyCode: 35, modifiers: [.maskCommand, .maskShift])
        case 14:  // L3
            print("🔘 L3 → 回车")
            input.pressKey(keyCode: 36)
        case 15:  // R3
            print("🔘 R3 → Escape")
            input.pressKey(keyCode: 53)
        default:
            print("🔘 按钮 \(button)")
        }
    }
    
    var lastDPad = -1
    func handleDPad(_ value: Int) {
        if value == lastDPad { return }
        lastDPad = value
        
        print("🎮 D-Pad 原始值: \(value)")
        
        switch value {
        case 1:  // 上
            print("🔘 D-Pad ↑")
            input.pressKey(keyCode: 126)
        case 3:  // 右
            print("🔘 D-Pad →")
            input.pressKey(keyCode: 124)
        case 5:  // 下
            print("🔘 D-Pad ↓")
            input.pressKey(keyCode: 125)
        case 7:  // 左
            print("🔘 D-Pad ←")
            input.pressKey(keyCode: 123)
        case 0, 8:  // 释放
            break
        default:
            break
        }
    }
    
    func startProcessTimer() {
        processTimer = DispatchSource.makeTimerSource(queue: DispatchQueue.global(qos: .userInteractive))
        processTimer?.schedule(deadline: .now(), repeating: 1.0/60.0)
        processTimer?.setEventHandler { [weak self] in
            self?.processSticks()
        }
        processTimer?.resume()
    }
    
    func processSticks() {
        guard isEnabled else { return }
        
        // 左摇杆 → 鼠标移动
        let lx = applyDeadZone(leftStickX)
        let ly = applyDeadZone(leftStickY)
        
        if lx != 0 || ly != 0 {
            let multiplier = input.isPrecisionMode ? precisionMultiplier : 1.0
            let dx = CGFloat(lx) * cursorSpeed * multiplier
            let dy = CGFloat(ly) * cursorSpeed * multiplier
            input.moveMouse(dx: dx, dy: dy)
        }
        
        // 右摇杆 → 滚动
        let rx = applyDeadZone(rightStickX)
        let ry = applyDeadZone(rightStickY)
        
        if rx != 0 || ry != 0 {
            let dx = CGFloat(rx) * scrollSpeed
            let dy = CGFloat(ry) * scrollSpeed
            input.scroll(dx: dx, dy: dy)
        }
    }
    
    func applyDeadZone(_ value: Float) -> Float {
        if abs(value) < deadZone { return 0 }
        let sign: Float = value > 0 ? 1 : -1
        return sign * (abs(value) - deadZone) / (1 - deadZone)
    }
    
    func normalizeAxis(_ value: Int, element: IOHIDElement) -> Float {
        let min = IOHIDElementGetLogicalMin(element)
        let max = IOHIDElementGetLogicalMax(element)
        let range = Float(max - min)
        if range == 0 { return 0 }
        return (Float(value - min) / range) * 2 - 1
    }
    
    func normalizeAxisPositive(_ value: Int, element: IOHIDElement) -> Float {
        let min = IOHIDElementGetLogicalMin(element)
        let max = IOHIDElementGetLogicalMax(element)
        let range = Float(max - min)
        if range == 0 { return 0 }
        return Float(value - min) / range
    }
    
    func run() {
        RunLoop.main.run()
    }
}

// MARK: - 主程序

// 检查辅助功能权限
let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
let trusted = AXIsProcessTrustedWithOptions(options as CFDictionary)

if !trusted {
    print("⚠️ 需要辅助功能权限")
    print("   请在系统设置中授权 Terminal 后重新运行\n")
}

let service = HIDControllerService()
service.run()
