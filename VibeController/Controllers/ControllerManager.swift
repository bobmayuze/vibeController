import Foundation
import GameController
import Combine

// MARK: - 手柄管理器

@MainActor
class ControllerManager: ObservableObject {
    static let shared = ControllerManager()
    
    @Published var connectedController: GCController?
    @Published var controllerInfo: ControllerInfo?
    @Published var currentState = ControllerState()
    @Published var isEnabled = true
    @Published var pressedButtons: Set<ControllerButton> = []
    
    // 按键回调
    var onButtonPressed: ((ControllerButton) -> Void)?
    var onButtonReleased: ((ControllerButton) -> Void)?
    var onLeftStickMoved: ((Float, Float) -> Void)?
    var onRightStickMoved: ((Float, Float) -> Void)?
    var onLeftTriggerChanged: ((Float) -> Void)?
    var onRightTriggerChanged: ((Float) -> Void)?
    
    private var pollTimer: DispatchSourceTimer?
    
    private init() {
        setupNotifications()
        startDiscovery()
    }
    
    // MARK: - 连接管理
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(controllerConnected),
            name: .GCControllerDidConnect,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(controllerDisconnected),
            name: .GCControllerDidDisconnect,
            object: nil
        )
    }
    
    private func startDiscovery() {
        GCController.startWirelessControllerDiscovery {
            // 发现完成
        }
        
        // 检查已连接的手柄
        if let controller = GCController.controllers().first {
            setupController(controller)
        }
    }
    
    @objc private func controllerConnected(_ notification: Notification) {
        guard let controller = notification.object as? GCController else { return }
        setupController(controller)
    }
    
    @objc private func controllerDisconnected(_ notification: Notification) {
        connectedController = nil
        controllerInfo = nil
        stopPolling()
    }
    
    private func setupController(_ controller: GCController) {
        connectedController = controller
        controllerInfo = ControllerInfo(
            id: controller.vendorName ?? UUID().uuidString,
            name: controller.productCategory,
            vendorName: controller.vendorName,
            isConnected: true
        )
        
        print("🎮 手柄已连接: \(controller.productCategory) - \(controller.vendorName ?? "Unknown")")
        
        setupInputHandlers(controller)
        startPolling()
    }
    
    // MARK: - 输入处理
    
    private func setupInputHandlers(_ controller: GCController) {
        guard let gamepad = controller.extendedGamepad else { return }
        
        // A B X Y 按键
        gamepad.buttonA.pressedChangedHandler = { [weak self] _, _, pressed in
            self?.handleButton(.buttonA, pressed: pressed)
        }
        gamepad.buttonB.pressedChangedHandler = { [weak self] _, _, pressed in
            self?.handleButton(.buttonB, pressed: pressed)
        }
        gamepad.buttonX.pressedChangedHandler = { [weak self] _, _, pressed in
            self?.handleButton(.buttonX, pressed: pressed)
        }
        gamepad.buttonY.pressedChangedHandler = { [weak self] _, _, pressed in
            self?.handleButton(.buttonY, pressed: pressed)
        }
        
        // 肩键
        gamepad.leftShoulder.pressedChangedHandler = { [weak self] _, _, pressed in
            self?.handleButton(.leftBumper, pressed: pressed)
        }
        gamepad.rightShoulder.pressedChangedHandler = { [weak self] _, _, pressed in
            self?.handleButton(.rightBumper, pressed: pressed)
        }
        
        // 扳机
        gamepad.leftTrigger.valueChangedHandler = { [weak self] _, value, _ in
            Task { @MainActor in
                self?.currentState.leftTrigger = value
                self?.onLeftTriggerChanged?(value)
                if value > 0.5 {
                    self?.handleButton(.leftTrigger, pressed: true)
                } else {
                    self?.handleButton(.leftTrigger, pressed: false)
                }
            }
        }
        gamepad.rightTrigger.valueChangedHandler = { [weak self] _, value, _ in
            Task { @MainActor in
                self?.currentState.rightTrigger = value
                self?.onRightTriggerChanged?(value)
                if value > 0.5 {
                    self?.handleButton(.rightTrigger, pressed: true)
                } else {
                    self?.handleButton(.rightTrigger, pressed: false)
                }
            }
        }
        
        // 摇杆按下
        gamepad.leftThumbstickButton?.pressedChangedHandler = { [weak self] _, _, pressed in
            self?.handleButton(.leftStickButton, pressed: pressed)
        }
        gamepad.rightThumbstickButton?.pressedChangedHandler = { [weak self] _, _, pressed in
            self?.handleButton(.rightStickButton, pressed: pressed)
        }
        
        // 十字键
        gamepad.dpad.up.pressedChangedHandler = { [weak self] _, _, pressed in
            self?.handleButton(.dpadUp, pressed: pressed)
        }
        gamepad.dpad.down.pressedChangedHandler = { [weak self] _, _, pressed in
            self?.handleButton(.dpadDown, pressed: pressed)
        }
        gamepad.dpad.left.pressedChangedHandler = { [weak self] _, _, pressed in
            self?.handleButton(.dpadLeft, pressed: pressed)
        }
        gamepad.dpad.right.pressedChangedHandler = { [weak self] _, _, pressed in
            self?.handleButton(.dpadRight, pressed: pressed)
        }
        
        // 特殊键
        gamepad.buttonMenu.pressedChangedHandler = { [weak self] _, _, pressed in
            self?.handleButton(.startButton, pressed: pressed)
        }
        gamepad.buttonOptions?.pressedChangedHandler = { [weak self] _, _, pressed in
            self?.handleButton(.backButton, pressed: pressed)
        }
        gamepad.buttonHome?.pressedChangedHandler = { [weak self] _, _, pressed in
            self?.handleButton(.xboxButton, pressed: pressed)
        }
        
        // 摇杆
        gamepad.leftThumbstick.valueChangedHandler = { [weak self] _, xValue, yValue in
            Task { @MainActor in
                self?.currentState.leftStickX = xValue
                self?.currentState.leftStickY = yValue
                self?.onLeftStickMoved?(xValue, yValue)
            }
        }
        gamepad.rightThumbstick.valueChangedHandler = { [weak self] _, xValue, yValue in
            Task { @MainActor in
                self?.currentState.rightStickX = xValue
                self?.currentState.rightStickY = yValue
                self?.onRightStickMoved?(xValue, yValue)
            }
        }
    }
    
    private func handleButton(_ button: ControllerButton, pressed: Bool) {
        Task { @MainActor in
            if pressed {
                print("🔘 按键: \(button.displayName) - 按下")
            }
            
            guard isEnabled else { 
                print("⚠️ 控制器已禁用，忽略按键")
                return 
            }
            
            // Xbox 键用于切换启用状态
            if button == .xboxButton && pressed {
                isEnabled.toggle()
                print("🎮 控制器状态切换: \(isEnabled ? "启用" : "禁用")")
                return
            }
            
            if pressed {
                pressedButtons.insert(button)
                currentState.pressedButtons.insert(button)
                onButtonPressed?(button)
            } else {
                pressedButtons.remove(button)
                currentState.pressedButtons.remove(button)
                onButtonReleased?(button)
            }
        }
    }
    
    // MARK: - 轮询摇杆
    
    private func startPolling() {
        let timer = DispatchSource.makeTimerSource(queue: DispatchQueue.global(qos: .userInteractive))
        timer.schedule(deadline: .now(), repeating: 1.0/60.0)
        timer.setEventHandler { [weak self] in
            self?.pollSticks()
        }
        timer.resume()
        pollTimer = timer
    }
    
    private func stopPolling() {
        pollTimer?.cancel()
        pollTimer = nil
    }
    
    private var lastLogTime: Date = Date()
    
    private func pollSticks() {
        guard let gamepad = connectedController?.extendedGamepad else { return }
        
        let leftX = gamepad.leftThumbstick.xAxis.value
        let leftY = gamepad.leftThumbstick.yAxis.value
        let rightX = gamepad.rightThumbstick.xAxis.value
        let rightY = gamepad.rightThumbstick.yAxis.value
        
        Task { @MainActor in
            currentState.leftStickX = leftX
            currentState.leftStickY = leftY
            currentState.rightStickX = rightX
            currentState.rightStickY = rightY
        }
        
        // 每秒打印一次摇杆状态（避免刷屏）
        let now = Date()
        if now.timeIntervalSince(lastLogTime) >= 1.0 {
            if abs(leftX) > 0.1 || abs(leftY) > 0.1 {
                print("🕹️ 左摇杆: X=\(String(format: "%.2f", leftX)), Y=\(String(format: "%.2f", leftY))")
            }
            lastLogTime = now
        }
    }
    
    // MARK: - 公开方法
    
    func toggleEnabled() {
        isEnabled.toggle()
    }
}
