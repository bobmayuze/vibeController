import Foundation
import Combine

// MARK: - App 控制器 (协调各模块)

@MainActor
class AppController: ObservableObject {
    static let shared = AppController()
    
    let controllerManager = ControllerManager.shared
    let configManager = ConfigManager.shared
    let actionExecutor = ActionExecutor.shared
    
    @Published var isRunning = true
    
    private var cancellables = Set<AnyCancellable>()
    private var stickTimer: DispatchSourceTimer?
    
    private init() {
        updateSettings()
        setupBindings()
        startStickProcessing()
    }
    
    private func setupBindings() {
        // 按键按下
        controllerManager.onButtonPressed = { [weak self] button in
            Task { @MainActor in
                self?.handleButtonPressed(button)
            }
        }
        
        // 按键释放
        controllerManager.onButtonReleased = { [weak self] button in
            Task { @MainActor in
                self?.handleButtonReleased(button)
            }
        }
        
        // 左扳机 - 精准模式
        controllerManager.onLeftTriggerChanged = { [weak self] value in
            Task { @MainActor in
                self?.actionExecutor.setPrecisionMode(value > 0.3)
            }
        }
        
        // 右扳机 - 拖拽模式
        controllerManager.onRightTriggerChanged = { [weak self] value in
            Task { @MainActor in
                if value > 0.5 {
                    self?.actionExecutor.startDrag()
                } else {
                    self?.actionExecutor.endDrag()
                }
            }
        }
    }
    
    // MARK: - 按键处理
    
    private func handleButtonPressed(_ button: ControllerButton) {
        guard isRunning else { return }
        
        // 特殊处理扳机（已经在回调中处理了）
        if button == .leftTrigger || button == .rightTrigger {
            return
        }
        
        let action = configManager.action(for: button)
        actionExecutor.execute(action)
    }
    
    private func handleButtonReleased(_ button: ControllerButton) {
        // 大多数动作不需要释放处理
    }
    
    // MARK: - 摇杆处理
    
    private func startStickProcessing() {
        let timer = DispatchSource.makeTimerSource(queue: DispatchQueue.global(qos: .userInteractive))
        timer.schedule(deadline: .now(), repeating: 1.0/60.0)
        timer.setEventHandler { [weak self] in
            self?.processSticks()
        }
        timer.resume()
        stickTimer = timer
    }
    
    private var lastProcessLog: Date = Date()
    
    // 缓存设置，避免频繁访问 MainActor
    private var cachedDeadZone: Float = 0.15
    private var cachedCursorSpeed: Double = 800
    private var cachedScrollSpeed: Double = 5
    
    private func processSticks() {
        guard isRunning else { return }
        
        // 从 controllerManager 读取摇杆状态（线程安全的值类型）
        let leftX = controllerManager.currentState.leftStickX
        let leftY = controllerManager.currentState.leftStickY
        let rightX = controllerManager.currentState.rightStickX
        let rightY = controllerManager.currentState.rightStickY
        
        // 应用死区
        let processedLeftX = applyDeadZone(leftX, deadZone: cachedDeadZone)
        let processedLeftY = applyDeadZone(leftY, deadZone: cachedDeadZone)
        let processedRightX = applyDeadZone(rightX, deadZone: cachedDeadZone)
        let processedRightY = applyDeadZone(rightY, deadZone: cachedDeadZone)
        
        // 左摇杆 - 鼠标移动
        if processedLeftX != 0 || processedLeftY != 0 {
            Task { @MainActor in
                actionExecutor.moveMouse(
                    deltaX: processedLeftX,
                    deltaY: processedLeftY,
                    speed: cachedCursorSpeed
                )
            }
        }
        
        // 右摇杆 - 滚动
        if processedRightX != 0 || processedRightY != 0 {
            Task { @MainActor in
                actionExecutor.scroll(
                    deltaX: processedRightX,
                    deltaY: processedRightY,
                    speed: cachedScrollSpeed
                )
            }
        }
    }
    
    func updateSettings() {
        let settings = configManager.currentConfig.settings
        cachedDeadZone = Float(settings.deadZone)
        cachedCursorSpeed = settings.cursorSpeed
        cachedScrollSpeed = settings.scrollSpeed
    }
    
    private func applyDeadZone(_ value: Float, deadZone: Float) -> Float {
        if abs(value) < deadZone {
            return 0
        }
        // 重新映射到 0-1 范围
        let sign: Float = value > 0 ? 1 : -1
        return sign * (abs(value) - deadZone) / (1 - deadZone)
    }
    
    // MARK: - 控制
    
    func toggle() {
        isRunning.toggle()
    }
    
    func stop() {
        isRunning = false
        stickTimer?.cancel()
        stickTimer = nil
    }
}
