# Vibe Controller

用 Xbox 手柄控制 macOS 的系统级工具，类似 BetterTouchTool。

## 功能特性

- **状态栏常驻** - 关闭窗口后继续后台运行
- **可视化键位图** - 直观显示当前按键映射
- **后台运行** - 基于 IOKit HID，窗口失去焦点也能控制
- **App Switcher** - 按住 Back 键像 Cmd+Tab 一样切换应用

## 按键映射

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
| **L3** | 回车 |
| **R3** | Esc |
| **Start** | 命令面板 (⌘⇧P) |
| **Back** | App Switcher（按住切换应用） |
| **D-Pad** | 方向键 |

## App Switcher 使用

1. **按住 Back** → 打开应用切换器
2. **按住 Back + RB** → 下一个应用
3. **按住 Back + LB** → 上一个应用  
4. **松开 Back** → 确认选择

## 快速开始

### 方式一：Xcode 运行

1. 打开 `VibeController.xcodeproj`
2. 按 Cmd+R 运行
3. 首次运行授予辅助功能权限

### 方式二：命令行服务

```bash
cd VibeControllerService
swiftc -O -o VibeControllerService main.swift \
  -framework Foundation -framework IOKit \
  -framework CoreGraphics -framework AppKit
./VibeControllerService
```

## 权限要求

首次运行需要授予辅助功能权限：

**系统设置 → 隐私与安全性 → 辅助功能 → 允许 Vibe Controller**

## 技术实现

- **Swift + SwiftUI** - 原生 macOS 应用
- **IOKit HID** - 直接读取手柄输入，支持后台运行
- **CoreGraphics** - 模拟鼠标和键盘操作
- **MenuBarExtra** - 状态栏常驻

## 项目结构

```
VibeController/
├── App/                    # 应用入口
│   ├── VibeControllerApp.swift
│   └── AppDelegate.swift
├── Controllers/            # 控制器
│   ├── HIDControllerManager.swift  # IOKit HID 手柄管理
│   ├── ConfigManager.swift         # 配置管理
│   └── ActionExecutor.swift        # 动作执行
├── Views/                  # 界面
│   ├── ControllerMapView.swift     # 键位图主界面
│   ├── MenuBarView.swift           # 状态栏菜单
│   └── SettingsView.swift          # 设置面板
└── Resources/              # 资源文件

VibeControllerService/      # 独立命令行服务
└── main.swift
```

## 待实现

- [ ] 可视化配置按键映射（点击保存）
- [ ] 配置导入/导出
- [ ] 多配置切换
- [ ] 打包 DMG 分发

## License

MIT
