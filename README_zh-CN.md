# Vibe Controller

![Demo](demo.gif)

用 Xbox 手柄控制 macOS 的系统级工具。

**[English](README.md)** | **[繁體中文](README_zh-TW.md)** | **[日本語](README_ja.md)**

## 功能特性

- **状态栏常驻** - 关闭窗口后继续后台运行
- **可视化键位图** - 直观显示当前按键映射
- **后台运行** - 基于 IOKit HID，窗口失去焦点也能控制
- **App Switcher** - 按住 Back 键像 Cmd+Tab 一样切换应用
- **配置轮盘** - 按下 L3 快速切换配置
- **自动切换配置** - 切换应用时自动切换到对应的配置
- **App Exposé 模式** - 使用方向键导航窗口
- **自定义映射** - 可配置任意按键到任意动作

## 快速开始

### 方式一：下载发布版

从 [GitHub Releases](https://github.com/bobmayuze/vibeController/releases/tag/alpha) 下载最新版本

### 方式二：Xcode 运行

1. 打开 `VibeController.xcodeproj`
2. 按 Cmd+R 运行
3. 首次运行授予辅助功能权限

## 默认按键映射

| 手柄 | 功能 |
|-----|------|
| **左摇杆** | 鼠标移动 |
| **右摇杆** | 滚动 |
| **A** | 左键点击 |
| **B** | 右键点击 |
| **X** | 复制 (⌘C) |
| **Y** | 粘贴 (⌘V) |
| **LB** | 撤销 (⌘Z) / App Switcher 时切换上一个 |
| **RB** | Option+Space / App Switcher 时切换下一个 |
| **LT** | 拖拽模式（按住拖动文件/文本） |
| **RT** | 回车 |
| **L3** | 配置轮盘 |
| **R3** | Esc |
| **Start** | 命令面板 (⌘⇧P) |
| **Back** | App Switcher (⌘Tab) |
| **D-Pad 上/下** | 方向键 |
| **D-Pad 左/右** | Option + 方向键（按词移动） |

### 组合键

| 组合 | 功能 |
|-----|------|
| **LT + D-Pad** | Shift + 方向键（文字选择） |

## App Switcher 使用

1. **按住 Back** → 打开应用切换器
2. **按住 Back + RB** → 下一个应用
3. **按住 Back + LB** → 上一个应用  
4. **松开 Back** → 确认选择

## 自动切换配置

根据当前活动应用自动切换配置：

1. 在设置中启用"自动切换配置"
2. 点击配置的"管理关联应用"
3. 选择要关联到该配置的应用
4. 设置一个默认配置用于没有关联的应用

切换到已关联的应用时，配置会自动切换并显示通知。

## 权限要求

首次运行需要授予辅助功能权限：

**系统设置 → 隐私与安全性 → 辅助功能 → 允许 Vibe Controller**

## 技术实现

- **Swift + SwiftUI** - 原生 macOS 应用
- **IOKit HID** - 直接读取手柄输入，支持后台运行
- **CoreGraphics** - 模拟鼠标和键盘操作
- **MenuBarExtra** - 状态栏常驻

## 推荐工具

配合 Vibe Controller 使用语音输入，推荐 [Handy](https://github.com/cjpais/Handy) - 一个免费、开源、注重隐私的离线语音转文字应用。

## License

MIT License © 2026 [Yuze Ma](mailto:yuze.bob.ma@gmail.com)

详见 [LICENSE](LICENSE)。
