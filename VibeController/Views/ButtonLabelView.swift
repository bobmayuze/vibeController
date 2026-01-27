import SwiftUI

// MARK: - 按键标签组件

struct ButtonLabelView: View {
    let button: ControllerButton
    let action: Action
    let isPressed: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 2) {
                Text(button.shortName)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                
                Text(action.displayName)
                    .font(.system(size: 9))
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(1)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isPressed ? Color.green : Color.gray.opacity(0.7))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(isPressed ? Color.green.opacity(0.8) : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 1.1 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
    }
}

// MARK: - 摇杆显示组件

struct StickView: View {
    let title: String
    let subtitle: String
    let xValue: Float
    let yValue: Float
    let isPressed: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                
                ZStack {
                    // 背景圆
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 2)
                        .frame(width: 50, height: 50)
                    
                    // 摇杆位置指示
                    Circle()
                        .fill(isPressed ? Color.green : Color.white)
                        .frame(width: 16, height: 16)
                        .offset(
                            x: CGFloat(xValue) * 17,
                            y: CGFloat(-yValue) * 17
                        )
                }
                
                Text(subtitle)
                    .font(.system(size: 9))
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 扳机显示组件

struct TriggerView: View {
    let title: String
    let action: Action
    let value: Float
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white)
                
                // 进度条
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.gray.opacity(0.3))
                        
                        RoundedRectangle(cornerRadius: 3)
                            .fill(value > 0.5 ? Color.green : Color.blue)
                            .frame(width: geo.size.width * CGFloat(value))
                    }
                }
                .frame(height: 6)
                
                Text(action.displayName)
                    .font(.system(size: 9))
                    .foregroundColor(.white.opacity(0.7))
            }
            .frame(width: 70)
            .padding(6)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.gray.opacity(0.4))
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 十字键组件

struct DpadView: View {
    let pressedButtons: Set<ControllerButton>
    let actions: [ControllerButton: Action]
    let onTap: (ControllerButton) -> Void
    
    var body: some View {
        VStack(spacing: 2) {
            // 上
            DpadButtonView(
                direction: "↑",
                action: actions[.dpadUp] ?? .none,
                isPressed: pressedButtons.contains(.dpadUp)
            ) { onTap(.dpadUp) }
            
            HStack(spacing: 2) {
                // 左
                DpadButtonView(
                    direction: "←",
                    action: actions[.dpadLeft] ?? .none,
                    isPressed: pressedButtons.contains(.dpadLeft)
                ) { onTap(.dpadLeft) }
                
                // 中间空白
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: 36, height: 36)
                
                // 右
                DpadButtonView(
                    direction: "→",
                    action: actions[.dpadRight] ?? .none,
                    isPressed: pressedButtons.contains(.dpadRight)
                ) { onTap(.dpadRight) }
            }
            
            // 下
            DpadButtonView(
                direction: "↓",
                action: actions[.dpadDown] ?? .none,
                isPressed: pressedButtons.contains(.dpadDown)
            ) { onTap(.dpadDown) }
        }
    }
}

struct DpadButtonView: View {
    let direction: String
    let action: Action
    let isPressed: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 1) {
                Text(direction)
                    .font(.system(size: 14, weight: .bold))
                Text(action.displayName)
                    .font(.system(size: 7))
                    .lineLimit(1)
            }
            .foregroundColor(.white)
            .frame(width: 36, height: 36)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(isPressed ? Color.green : Color.gray.opacity(0.6))
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {
        Color.black
        VStack(spacing: 20) {
            ButtonLabelView(
                button: .buttonA,
                action: .leftClick,
                isPressed: false
            ) {}
            
            StickView(
                title: "左摇杆",
                subtitle: "鼠标移动",
                xValue: 0.5,
                yValue: -0.3,
                isPressed: false
            ) {}
            
            TriggerView(
                title: "LT",
                action: Action(type: .none),
                value: 0.7
            ) {}
        }
        .padding()
    }
}
