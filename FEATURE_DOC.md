# Vibe Controller

用 Xbox 手柄控制 macOS 的工具。

## 快速开始

### 1. 编译

```bash
cd VibeControllerService
swiftc -O -o VibeControllerService main.swift -framework Foundation -framework IOKit -framework CoreGraphics -framework AppKit
```

### 2. 授权

首次运行会提示授予辅助功能权限：
**系统设置 → 隐私与安全性 → 辅助功能 → 允许 Terminal**

### 3. 运行

```bash
./VibeControllerService
```

## 按键映射

| 手柄 | 功能 |
|-----|------|
| 左摇杆 | 鼠标移动 |
| 右摇杆 | 滚动 |
| A | 左键点击 |
| B | 右键点击 |
| X | 复制 (⌘C) |
| Y | 粘贴 (⌘V) |
| LB | 撤销 (⌘Z) / App Switcher 时上一个 |
| RB | Option+Space / App Switcher 时下一个 |
| LT | 拖拽模式（按住拖动） |
| RT | 回车 |
| Start | 命令面板 (⌘⇧P) |
| Back | App Switcher（按住+LB/RB切换应用） |
| D-Pad | 方向键 |

## App Switcher 使用方法

1. **按住 Back** → 打开应用切换器 (Cmd+Tab)
2. **按住 Back 的同时按 RB** → 切换到下一个应用
3. **按住 Back 的同时按 LB** → 切换到上一个应用
4. **松开 Back** → 确认选择

## 修改映射

编辑 `VibeControllerService/main.swift` 中的 `handleButtonPress` 函数，然后重新编译。

## 技术说明

- 使用 IOKit HID 直接读取手柄输入，支持后台运行
- 使用 CoreGraphics 模拟鼠标和键盘
