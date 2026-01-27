# Vibe Controller

Control macOS with an Xbox controller.

## Quick Start

### 1. Build

```bash
cd VibeControllerService
swiftc -O -o VibeControllerService main.swift -framework Foundation -framework IOKit -framework CoreGraphics -framework AppKit
```

### 2. Grant Permission

First run will prompt for Accessibility permission:
**System Settings → Privacy & Security → Accessibility → Allow Terminal**

### 3. Run

```bash
./VibeControllerService
```

## Button Mappings

| Controller | Action |
|------------|--------|
| Left Stick | Mouse movement |
| Right Stick | Scroll |
| A | Left click |
| B | Right click |
| X | Copy (⌘C) |
| Y | Paste (⌘V) |
| LB | Undo (⌘Z) / Previous app in switcher |
| RB | Option+Space / Next app in switcher |
| LT | Drag mode (hold to drag) |
| RT | Enter |
| Start | Command Palette (⌘⇧P) |
| Back | App Switcher (hold + LB/RB to switch) |
| D-Pad | Arrow keys |

## App Switcher

1. **Hold Back** → Opens app switcher (Cmd+Tab)
2. **While holding Back, press RB** → Next app
3. **While holding Back, press LB** → Previous app
4. **Release Back** → Confirm selection

## Customization

Edit `handleButtonPress` function in `VibeControllerService/main.swift`, then recompile.

## Technical Details

- Uses IOKit HID for controller input (works in background)
- Uses CoreGraphics for mouse/keyboard simulation
