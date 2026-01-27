import Foundation
import CoreGraphics
import AppKit
import IOKit
import IOKit.hid

// MARK: - 动作执行器

@MainActor
class ActionExecutor: ObservableObject {
    static let shared = ActionExecutor()
    
    @Published var isDragging = false
    @Published var isPrecisionMode = false
    
    private var mouseLocation: CGPoint = .zero
    private var moveTimer: Timer?
    private let mouseQueue = DispatchQueue(label: "com.vibecontroller.mouse", qos: .userInteractive)
    
    private init() {
        updateMouseLocation()
    }
    
    private func updateMouseLocation() {
        let loc = NSEvent.mouseLocation
        if let screen = NSScreen.main {
            mouseLocation = CGPoint(x: loc.x, y: screen.frame.height - loc.y)
        }
    }
    
    // MARK: - 执行动作
    
    func execute(_ action: Action) {
        switch action.type {
        case .mouseClick:
            executeMouseClick(action)
        case .shortcut:
            executeShortcut(action)
        case .command:
            executeCommand(action)
        case .text:
            executeText(action)
        case .mouseMove, .scroll, .none:
            break
        }
    }
    
    // MARK: - 鼠标点击
    
    private func executeMouseClick(_ action: Action) {
        let button = action.mouseButton ?? .left
        let location = getCurrentMouseLocation()
        
        switch button {
        case .left:
            postMouseEvent(type: .leftMouseDown, at: location)
            postMouseEvent(type: .leftMouseUp, at: location)
        case .right:
            postMouseEvent(type: .rightMouseDown, at: location)
            postMouseEvent(type: .rightMouseUp, at: location)
        case .middle:
            postMouseEvent(type: .otherMouseDown, at: location, buttonNumber: 2)
            postMouseEvent(type: .otherMouseUp, at: location, buttonNumber: 2)
        }
    }
    
    private func postMouseEvent(type: CGEventType, at location: CGPoint, buttonNumber: Int64 = 0) {
        guard let event = CGEvent(mouseEventSource: nil, mouseType: type, mouseCursorPosition: location, mouseButton: .left) else { return }
        if buttonNumber > 0 {
            event.setIntegerValueField(.mouseEventButtonNumber, value: buttonNumber)
        }
        event.post(tap: .cghidEventTap)
    }
    
    // MARK: - 键盘快捷键
    
    private func executeShortcut(_ action: Action) {
        guard let keyCode = action.keyCode else { return }
        let flags = action.modifiers?.cgEventFlags ?? []
        
        // Key down
        if let keyDown = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(keyCode), keyDown: true) {
            keyDown.flags = flags
            keyDown.post(tap: .cghidEventTap)
        }
        
        // Key up
        if let keyUp = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(keyCode), keyDown: false) {
            keyUp.flags = flags
            keyUp.post(tap: .cghidEventTap)
        }
    }
    
    // MARK: - 运行命令
    
    private func executeCommand(_ action: Action) {
        guard let command = action.commandString else { return }
        
        Task.detached {
            let process = Process()
            process.launchPath = "/bin/zsh"
            process.arguments = ["-c", command]
            try? process.run()
        }
    }
    
    // MARK: - 输入文本
    
    private func executeText(_ action: Action) {
        guard let text = action.textToType else { return }
        
        for char in text.unicodeScalars {
            if let event = CGEvent(keyboardEventSource: nil, virtualKey: 0, keyDown: true) {
                event.keyboardSetUnicodeString(stringLength: 1, unicodeString: [UniChar(char.value)])
                event.post(tap: .cghidEventTap)
            }
            if let event = CGEvent(keyboardEventSource: nil, virtualKey: 0, keyDown: false) {
                event.post(tap: .cghidEventTap)
            }
        }
    }
    
    // MARK: - 鼠标移动
    
    private var lastMoveLog: Date = Date()
    
    func moveMouse(deltaX: Float, deltaY: Float, speed: Double) {
        let multiplier = isPrecisionMode ? 0.3 : 1.0
        let dx = CGFloat(deltaX) * speed * multiplier / 60.0
        let dy = CGFloat(-deltaY) * speed * multiplier / 60.0  // Y 轴反转
        
        mouseLocation.x += dx
        mouseLocation.y += dy
        
        // 限制在屏幕范围内
        if let screen = NSScreen.main {
            mouseLocation.x = max(0, min(mouseLocation.x, screen.frame.width))
            mouseLocation.y = max(0, min(mouseLocation.y, screen.frame.height))
        }
        
        let targetLocation = mouseLocation
        let dragging = isDragging
        
        // 在独立队列中移动鼠标
        mouseQueue.async {
            // 直接设置鼠标位置
            CGWarpMouseCursorPosition(targetLocation)
            
            // 发送移动事件让系统知道鼠标移动了
            if let event = CGEvent(mouseEventSource: nil, mouseType: dragging ? .leftMouseDragged : .mouseMoved, mouseCursorPosition: targetLocation, mouseButton: .left) {
                event.post(tap: .cgSessionEventTap)
            }
        }
    }
    
    // MARK: - 滚动
    
    func scroll(deltaX: Float, deltaY: Float, speed: Double) {
        let scrollX = Int32(-deltaX * Float(speed))
        let scrollY = Int32(deltaY * Float(speed))
        
        if let event = CGEvent(scrollWheelEvent2Source: nil, units: .pixel, wheelCount: 2, wheel1: scrollY, wheel2: scrollX, wheel3: 0) {
            event.post(tap: .cghidEventTap)
        }
    }
    
    // MARK: - 拖拽
    
    func startDrag() {
        guard !isDragging else { return }
        isDragging = true
        let location = getCurrentMouseLocation()
        postMouseEvent(type: .leftMouseDown, at: location)
    }
    
    func endDrag() {
        guard isDragging else { return }
        isDragging = false
        let location = getCurrentMouseLocation()
        postMouseEvent(type: .leftMouseUp, at: location)
    }
    
    // MARK: - 精准模式
    
    func setPrecisionMode(_ enabled: Bool) {
        isPrecisionMode = enabled
    }
    
    // MARK: - 工具方法
    
    private func getCurrentMouseLocation() -> CGPoint {
        var location = NSEvent.mouseLocation
        if let screen = NSScreen.main {
            location.y = screen.frame.height - location.y
        }
        return location
    }
}
