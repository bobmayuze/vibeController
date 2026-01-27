# Vibe Controller

A system-level tool for controlling macOS with an Xbox controller.

**[简体中文](README_zh-CN.md)** | **[繁體中文](README_zh-TW.md)** | **[日本語](README_ja.md)**

## Features

- **Menu Bar App** - Runs in background after closing window
- **Visual Button Map** - Intuitive display of current button mappings
- **Background Operation** - IOKit HID based, works even when window loses focus
- **App Switcher** - Hold Back button to switch apps like Cmd+Tab
- **Customizable Mappings** - Configure any button to any action

## Default Button Mappings

| Controller | Function |
|------------|----------|
| **Left Stick** | Mouse movement |
| **Right Stick** | Scroll |
| **A** | Left click |
| **B** | Right click |
| **X** | Copy (⌘C) |
| **Y** | Paste (⌘V) |
| **LB** | Undo (⌘Z) / Previous app in App Switcher |
| **RB** | Option+Space / Next app in App Switcher |
| **LT** | Drag mode (hold to drag files/text) |
| **RT** | None |
| **L3** | Enter |
| **R3** | Esc |
| **Start** | Command Palette (⌘⇧P) |
| **Back** | App Switcher (⌘Tab) |
| **D-Pad** | Arrow keys |

### Chord Mappings (Combos)

| Combo | Function |
|-------|----------|
| **LT + D-Pad** | Shift + Arrow keys (text selection) |
| **LT + RT + D-Pad** | Shift + Option + Arrow keys (word selection) |

## App Switcher Usage

1. **Hold Back** → Open app switcher
2. **Hold Back + RB** → Next app
3. **Hold Back + LB** → Previous app
4. **Release Back** → Confirm selection

## Quick Start

### Option 1: Run with Xcode

1. Open `VibeController.xcodeproj`
2. Press Cmd+R to run
3. Grant Accessibility permission on first launch

### Option 2: Command Line Service

```bash
cd VibeControllerService
swiftc -O -o VibeControllerService main.swift \
  -framework Foundation -framework IOKit \
  -framework CoreGraphics -framework AppKit
./VibeControllerService
```

## Permissions

First launch requires Accessibility permission:

**System Settings → Privacy & Security → Accessibility → Allow Vibe Controller**

## Tech Stack

- **Swift + SwiftUI** - Native macOS app
- **IOKit HID** - Direct controller input, supports background operation
- **CoreGraphics** - Mouse and keyboard simulation
- **MenuBarExtra** - Menu bar integration

## License

MIT
