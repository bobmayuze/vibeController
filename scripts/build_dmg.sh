#!/bin/bash
set -e

# 配置
APP_NAME="VibeController"
SCHEME="VibeController"
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="$PROJECT_DIR/build"
DMG_DIR="$BUILD_DIR/dmg"

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

# 复制到 DMG 目录
cp -R "$APP_PATH" "$DMG_DIR/"
ln -s /Applications "$DMG_DIR/Applications"

# 创建 DMG
DMG_PATH="$BUILD_DIR/$APP_NAME.dmg"
echo "📦 Creating DMG..."

hdiutil create -volname "$APP_NAME" \
    -srcfolder "$DMG_DIR" \
    -ov -format UDZO \
    "$DMG_PATH"

echo ""
echo "✅ DMG created: $DMG_PATH"
echo ""
echo "⚠️  Note: Without Developer ID signing, users will see Gatekeeper warning."
echo "   They need to: Right-click → Open → Open anyway"
