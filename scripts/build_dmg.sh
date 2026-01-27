#!/bin/bash
set -e

# 配置
APP_NAME="VibeController"
SCHEME="VibeController"
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="$PROJECT_DIR/build"
DMG_DIR="$BUILD_DIR/dmg"
RESOURCES_DIR="$PROJECT_DIR/scripts/dmg_resources"

# 签名和公证配置
DEVELOPER_ID="Developer ID Application: YUZE MA (2RS4MN6F35)"
TEAM_ID="2RS4MN6F35"
APPLE_ID="yuze.bob.ma@gmail.com"
KEYCHAIN_PROFILE="VibeController-notarize"

# 询问是否需要公证
echo ""
echo "📋 Build Options:"
echo "   1) Full build with notarization (for distribution)"
echo "   2) Quick build without notarization (for testing)"
echo ""
read -p "Choose [1/2, default=2]: " BUILD_OPTION
BUILD_OPTION=${BUILD_OPTION:-2}

if [ "$BUILD_OPTION" = "1" ]; then
    DO_NOTARIZE=true
    echo "→ Will notarize for distribution"
else
    DO_NOTARIZE=false
    echo "→ Quick build (no notarization)"
fi
echo ""

echo "🔨 Building $APP_NAME..."

# 清理
rm -rf "$BUILD_DIR"
mkdir -p "$DMG_DIR"

# 编译 Release 版本
xcodebuild -project "$PROJECT_DIR/VibeController.xcodeproj" \
    -scheme "$SCHEME" \
    -configuration Release \
    -derivedDataPath "$BUILD_DIR/DerivedData" \
    -destination "platform=macOS" \
    build

# 找到编译好的 app
APP_PATH=$(find "$BUILD_DIR/DerivedData" -name "*.app" -type d | head -1)

if [ -z "$APP_PATH" ]; then
    echo "❌ Build failed: app not found"
    exit 1
fi

echo "✅ Build complete: $APP_PATH"

# 复制默认配置文件到 app bundle (重命名为 default_config.json)
CONFIG_FILE="$PROJECT_DIR/vibe_controller_config.json"
if [ -f "$CONFIG_FILE" ]; then
    echo "📋 Copying default config to app bundle..."
    cp "$CONFIG_FILE" "$APP_PATH/Contents/Resources/default_config.json"
    echo "✅ Config copied as default_config.json"
fi

# 代码签名
echo "🔏 Signing app with Developer ID..."
codesign --force --deep --options runtime --sign "$DEVELOPER_ID" "$APP_PATH"
codesign --verify --verbose "$APP_PATH"
echo "✅ App signed"

# 创建 DMG
DMG_PATH="$BUILD_DIR/$APP_NAME.dmg"
echo "📦 Creating DMG..."

# 复制 app 到 DMG 目录
cp -R "$APP_PATH" "$DMG_DIR/"
ln -sf /Applications "$DMG_DIR/Applications"

# 检查是否安装了 create-dmg
if command -v create-dmg &> /dev/null; then
    echo "Using create-dmg for styled installer..."
    
    # 使用 create-dmg 创建美观的 DMG (从 DMG_DIR 创建)
    # 注意: create-dmg 可能因 Finder AppleScript 问题失败，但 DMG 通常已创建
    create-dmg \
        --volname "$APP_NAME" \
        --window-pos 200 120 \
        --window-size 600 400 \
        --icon-size 100 \
        --icon "$APP_NAME.app" 150 190 \
        --hide-extension "$APP_NAME.app" \
        --app-drop-link 450 190 \
        --no-internet-enable \
        "$DMG_PATH" \
        "$DMG_DIR" \
    || {
        echo "⚠️  create-dmg styling failed, falling back to basic DMG..."
        rm -f "$DMG_PATH"
        hdiutil create -volname "$APP_NAME" \
            -srcfolder "$DMG_DIR" \
            -ov -format UDZO \
            "$DMG_PATH"
    }
else
    echo "Using basic DMG creation..."
    hdiutil create -volname "$APP_NAME" \
        -srcfolder "$DMG_DIR" \
        -ov -format UDZO \
        "$DMG_PATH"
fi

echo "✅ DMG created: $DMG_PATH"

# 签名 DMG
echo "🔏 Signing DMG..."
codesign --force --sign "$DEVELOPER_ID" "$DMG_PATH"

if [ "$DO_NOTARIZE" = true ]; then
    # 公证
    echo "📤 Submitting for notarization (this may take a few minutes)..."
    xcrun notarytool submit "$DMG_PATH" --keychain-profile "$KEYCHAIN_PROFILE" --wait

    # Staple
    echo "📎 Stapling notarization ticket..."
    xcrun stapler staple "$DMG_PATH"

    echo ""
    echo "✅ Done! DMG is signed and notarized: $DMG_PATH"
    echo "   Users can open it without Gatekeeper warnings."
else
    echo ""
    echo "✅ Done! DMG created (not notarized): $DMG_PATH"
    echo "   ⚠️  For testing only. Users will see Gatekeeper warning."
    echo "   To bypass: Right-click → Open, or run: xattr -cr /path/to/app"
fi
