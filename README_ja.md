# Vibe Controller

Xbox コントローラーで macOS を操作するシステムレベルのツール。

**[English](README.md)** | **[简体中文](README_zh-CN.md)** | **[繁體中文](README_zh-TW.md)**

## 機能

- **メニューバー常駐** - ウィンドウを閉じてもバックグラウンドで動作
- **ビジュアルボタンマップ** - 現在のボタンマッピングを直感的に表示
- **バックグラウンド動作** - IOKit HID ベース、ウィンドウがフォーカスを失っても操作可能
- **App Switcher** - Back ボタン長押しで Cmd+Tab のようにアプリを切り替え
- **カスタマイズ可能** - 任意のボタンを任意のアクションに設定可能

## デフォルトボタンマッピング

| コントローラー | 機能 |
|--------------|------|
| **左スティック** | マウス移動 |
| **右スティック** | スクロール |
| **A** | 左クリック |
| **B** | 右クリック |
| **X** | コピー (⌘C) |
| **Y** | ペースト (⌘V) |
| **LB** | 元に戻す (⌘Z) / App Switcher で前のアプリ |
| **RB** | Option+Space / App Switcher で次のアプリ |
| **LT** | ドラッグモード（押しながらファイル/テキストをドラッグ） |
| **RT** | なし |
| **L3** | Enter |
| **R3** | Esc |
| **Start** | コマンドパレット (⌘⇧P) |
| **Back** | App Switcher (⌘Tab) |
| **D-Pad** | 矢印キー |

### コンボキー

| コンボ | 機能 |
|-------|------|
| **LT + D-Pad** | Shift + 矢印キー（テキスト選択） |
| **LT + RT + D-Pad** | Shift + Option + 矢印キー（単語選択） |

## App Switcher の使い方

1. **Back を長押し** → アプリスイッチャーを開く
2. **Back + RB** → 次のアプリ
3. **Back + LB** → 前のアプリ
4. **Back を離す** → 選択を確定

## クイックスタート

### 方法1：Xcode で実行

1. `VibeController.xcodeproj` を開く
2. Cmd+R で実行
3. 初回起動時にアクセシビリティ権限を許可

### 方法2：コマンドラインサービス

```bash
cd VibeControllerService
swiftc -O -o VibeControllerService main.swift \
  -framework Foundation -framework IOKit \
  -framework CoreGraphics -framework AppKit
./VibeControllerService
```

## 権限

初回起動時にアクセシビリティ権限が必要です：

**システム設定 → プライバシーとセキュリティ → アクセシビリティ → Vibe Controller を許可**

## 技術スタック

- **Swift + SwiftUI** - ネイティブ macOS アプリ
- **IOKit HID** - コントローラー入力を直接読み取り、バックグラウンド動作をサポート
- **CoreGraphics** - マウスとキーボードのシミュレーション
- **MenuBarExtra** - メニューバー統合

## License

MIT
