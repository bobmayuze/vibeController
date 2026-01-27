import SwiftUI

// MARK: - 手柄键位图主界面

struct ControllerMapView: View {
    @ObservedObject var controllerManager = ControllerManager.shared
    @ObservedObject var configManager = ConfigManager.shared
    @ObservedObject var appController = AppController.shared
    
    @State private var editingButton: ControllerButton?
    @State private var showingSettings = false
    
    var body: some View {
        VStack(spacing: 0) {
            // 标题栏
            headerView
            
            Divider()
            
            // 手柄背景图 + 标签
            ZStack {
                // 背景图
                Image("ControllerImage")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 500)
                    .opacity(0.9)
                
                // 标签布局
                HStack(spacing: 0) {
                    // 左侧标签
                    VStack(alignment: .trailing, spacing: 10) {
                        MappingLabel(title: "↑ 方向键 ↑", action: configManager.action(for: .dpadUp), isPressed: controllerManager.pressedButtons.contains(.dpadUp), alignment: .trailing) { editingButton = .dpadUp }
                        MappingLabel(title: "↓ 方向键 ↓", action: configManager.action(for: .dpadDown), isPressed: controllerManager.pressedButtons.contains(.dpadDown), alignment: .trailing) { editingButton = .dpadDown }
                        
                        Spacer().frame(height: 20)
                        
                        MappingLabel(title: "LB", action: configManager.action(for: .leftBumper), isPressed: controllerManager.pressedButtons.contains(.leftBumper), alignment: .trailing) { editingButton = .leftBumper }
                        MappingLabel(title: "LT", action: Action(type: .none), subtitle: "精准模式", isPressed: controllerManager.currentState.leftTrigger > 0.5, alignment: .trailing) { editingButton = .leftTrigger }
                        
                        Spacer().frame(height: 30)
                        
                        MappingLabel(title: "左摇杆", action: Action(type: .mouseMove), subtitle: "鼠标移动", isPressed: false, alignment: .trailing) { editingButton = .leftStickButton }
                        MappingLabel(title: "L3", action: configManager.action(for: .leftStickButton), isPressed: controllerManager.pressedButtons.contains(.leftStickButton), alignment: .trailing) { editingButton = .leftStickButton }
                        
                        Spacer()
                        
                        MappingLabel(title: "Back", action: configManager.action(for: .backButton), isPressed: controllerManager.pressedButtons.contains(.backButton), alignment: .trailing) { editingButton = .backButton }
                    }
                    .frame(width: 160)
                    
                    Spacer().frame(width: 420) // 给中间图片留出空间
                    
                    // 右侧标签
                    VStack(alignment: .leading, spacing: 10) {
                        MappingLabel(title: "Y", action: configManager.action(for: .buttonY), isPressed: controllerManager.pressedButtons.contains(.buttonY), alignment: .leading) { editingButton = .buttonY }
                        MappingLabel(title: "X", action: configManager.action(for: .buttonX), isPressed: controllerManager.pressedButtons.contains(.buttonX), alignment: .leading) { editingButton = .buttonX }
                        
                        Spacer().frame(height: 20)
                        
                        MappingLabel(title: "RB", action: configManager.action(for: .rightBumper), isPressed: controllerManager.pressedButtons.contains(.rightBumper), alignment: .leading) { editingButton = .rightBumper }
                        MappingLabel(title: "RT", action: Action(type: .none), subtitle: "拖拽模式", isPressed: controllerManager.currentState.rightTrigger > 0.5, alignment: .leading) { editingButton = .rightTrigger }
                        
                        Spacer().frame(height: 30)
                        
                        MappingLabel(title: "A", action: configManager.action(for: .buttonA), isPressed: controllerManager.pressedButtons.contains(.buttonA), alignment: .leading) { editingButton = .buttonA }
                        MappingLabel(title: "B", action: configManager.action(for: .buttonB), isPressed: controllerManager.pressedButtons.contains(.buttonB), alignment: .leading) { editingButton = .buttonB }
                        
                        MappingLabel(title: "右摇杆", action: Action(type: .scroll), subtitle: "滚动", isPressed: false, alignment: .leading) { editingButton = .rightStickButton }
                        MappingLabel(title: "R3", action: configManager.action(for: .rightStickButton), isPressed: controllerManager.pressedButtons.contains(.rightStickButton), alignment: .leading) { editingButton = .rightStickButton }
                        
                        Spacer()
                        
                        MappingLabel(title: "Start", action: configManager.action(for: .startButton), isPressed: controllerManager.pressedButtons.contains(.startButton), alignment: .leading) { editingButton = .startButton }
                    }
                    .frame(width: 160)
                }
            }
            .padding(.vertical, 40)
            
            Divider()
            
            // 底部配置栏
            footerView
        }
        .frame(minWidth: 800, minHeight: 600)
        .background(Color(NSColor.windowBackgroundColor))
        .sheet(item: $editingButton) { button in
            ActionEditorSheet(
                button: button,
                currentAction: configManager.action(for: button),
                onSave: { action in
                    configManager.setAction(action, for: button)
                }
            )
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }
    
    // MARK: - 标题栏
    
    private var headerView: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "gamecontroller.fill")
                    .font(.title2)
                Text("Vibe Controller")
                    .font(.headline)
                Text("|").foregroundColor(.secondary)
                Text("Xbox 键位映射").foregroundColor(.secondary)
            }
            Spacer()
            HStack(spacing: 6) {
                Circle().fill(controllerManager.connectedController != nil ? Color.green : Color.red).frame(width: 8, height: 8)
                Text(controllerManager.connectedController != nil ? "已连接" : "未连接").font(.caption)
            }
            .padding(.horizontal, 10).padding(.vertical, 4).background(Color.gray.opacity(0.2)).cornerRadius(12)
            Button(action: { showingSettings = true }) { Image(systemName: "gear") }
        }
        .padding()
    }
    
    // MARK: - 底部栏
    
    private var footerView: some View {
        HStack {
            HStack(spacing: 4) {
                Image(systemName: "xbox.logo")
                Text("Xbox 键")
                Text("暂停/恢复控制").foregroundColor(.secondary)
            }.font(.caption)
            Spacer()
            Text("配置:")
            Picker("", selection: Binding(get: { configManager.currentConfig }, set: { configManager.selectConfig($0) })) {
                ForEach(configManager.configs) { config in Text(config.name).tag(config) }
            }.frame(width: 120)
            Button("导入") { importConfig() }
            Button("导出") { exportConfig() }
            Button("新建") { createNewConfig() }
        }
        .padding()
    }
    
    // MARK: - 配置操作
    
    private func importConfig() {
        let panel = NSOpenPanel(); panel.allowedContentTypes = [.json]; panel.allowsMultipleSelection = false
        if panel.runModal() == .OK, let url = panel.url { try? _ = configManager.importConfig(from: url) }
    }
    
    private func exportConfig() {
        let panel = NSSavePanel(); panel.allowedContentTypes = [.json]; panel.nameFieldStringValue = "\(configManager.currentConfig.name).json"
        if panel.runModal() == .OK, let url = panel.url { try? configManager.exportConfig(configManager.currentConfig, to: url) }
    }
    
    private func createNewConfig() {
        let newConfig = configManager.createNewConfig(name: "新配置 \(configManager.configs.count + 1)")
        configManager.selectConfig(newConfig)
    }
}

// MARK: - 映射标签组件

struct MappingLabel: View {
    let title: String
    let action: Action?
    var subtitle: String? = nil
    let isPressed: Bool
    let alignment: HorizontalAlignment
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                if alignment == .leading {
                    Rectangle().fill(Color.gray.opacity(0.4)).frame(width: 20, height: 1)
                }
                VStack(alignment: alignment == .leading ? .leading : .trailing, spacing: 2) {
                    Text(title).font(.system(size: 12, weight: .bold))
                    if let subtitle = subtitle {
                        Text(subtitle).font(.system(size: 10)).foregroundColor(.secondary)
                    } else if let action = action {
                        Text(action.displayName).font(.system(size: 10)).foregroundColor(.secondary)
                    }
                }
                if alignment == .trailing {
                    Rectangle().fill(Color.gray.opacity(0.4)).frame(width: 20, height: 1)
                }
            }
            .padding(.horizontal, 8).padding(.vertical, 4)
            .background(RoundedRectangle(cornerRadius: 6).fill(isPressed ? Color.green.opacity(0.3) : Color.clear))
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(isPressed ? Color.green : Color.gray.opacity(0.3), lineWidth: 1))
        }.buttonStyle(.plain)
    }
}

extension ControllerButton: Identifiable { var id: String { rawValue } }
extension ControllerConfig: Equatable { static func == (lhs: ControllerConfig, rhs: ControllerConfig) -> Bool { lhs.id == rhs.id } }
extension ControllerConfig: Hashable { func hash(into hasher: inout Hasher) { hasher.combine(id) } }
