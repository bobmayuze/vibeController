.PHONY: generate build run clean

# 生成 Xcode 项目（需要安装 xcodegen）
generate:
	@which xcodegen > /dev/null || (echo "请先安装 xcodegen: brew install xcodegen" && exit 1)
	xcodegen generate

# 构建项目
build: generate
	xcodebuild -project VibeController.xcodeproj -scheme VibeController -configuration Release build

# 运行项目
run: generate
	xcodebuild -project VibeController.xcodeproj -scheme VibeController -configuration Debug build
	open build/Debug/Vibe\ Controller.app

# 清理
clean:
	rm -rf build
	rm -rf VibeController.xcodeproj
	rm -rf ~/Library/Developer/Xcode/DerivedData/VibeController-*

# 安装依赖
setup:
	brew install xcodegen
