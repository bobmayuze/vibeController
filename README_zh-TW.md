# Vibe Controller

用 Xbox 手把控制 macOS 的系統級工具。

**[English](README.md)** | **[简体中文](README_zh-CN.md)** | **[日本語](README_ja.md)**

## 功能特性

- **狀態列常駐** - 關閉視窗後繼續背景執行
- **視覺化按鍵圖** - 直觀顯示當前按鍵映射
- **背景執行** - 基於 IOKit HID，視窗失去焦點也能控制
- **App Switcher** - 按住 Back 鍵像 Cmd+Tab 一樣切換應用程式
- **配置輪盤** - 按下 L3 快速切換配置
- **自訂映射** - 可配置任意按鍵到任意動作

## 預設按鍵映射

| 手把 | 功能 |
|-----|------|
| **左搖桿** | 滑鼠移動 |
| **右搖桿** | 捲動 |
| **A** | 左鍵點擊 |
| **B** | 右鍵點擊 |
| **X** | 複製 (⌘C) |
| **Y** | 貼上 (⌘V) |
| **LB** | 復原 (⌘Z) / App Switcher 時切換上一個 |
| **RB** | Option+Space / App Switcher 時切換下一個 |
| **LT** | 拖曳模式（按住拖動檔案/文字） |
| **RT** | Enter |
| **L3** | 配置輪盤 |
| **R3** | Esc |
| **Start** | 命令面板 (⌘⇧P) |
| **Back** | App Switcher (⌘Tab) |
| **D-Pad 上/下** | 方向鍵 |
| **D-Pad 左/右** | Option + 方向鍵（按詞移動） |

### 組合鍵

| 組合 | 功能 |
|-----|------|
| **LT + D-Pad** | Shift + 方向鍵（文字選擇） |

## App Switcher 使用

1. **按住 Back** → 開啟應用程式切換器
2. **按住 Back + RB** → 下一個應用程式
3. **按住 Back + LB** → 上一個應用程式
4. **放開 Back** → 確認選擇

## 快速開始

### 方式一：Xcode 執行

1. 開啟 `VibeController.xcodeproj`
2. 按 Cmd+R 執行
3. 首次執行授予輔助使用權限

## 權限要求

首次執行需要授予輔助使用權限：

**系統設定 → 隱私權與安全性 → 輔助使用 → 允許 Vibe Controller**

## 技術實現

- **Swift + SwiftUI** - 原生 macOS 應用程式
- **IOKit HID** - 直接讀取手把輸入，支援背景執行
- **CoreGraphics** - 模擬滑鼠和鍵盤操作
- **MenuBarExtra** - 狀態列常駐

## 推薦工具

配合 Vibe Controller 使用語音輸入，推薦 [Handy](https://github.com/cjpais/Handy) - 一個免費、開源、注重隱私的離線語音轉文字應用程式。

## License

MIT License © 2026 [Yuze Ma](mailto:yuze.bob.ma@gmail.com)

詳見 [LICENSE](LICENSE)。
