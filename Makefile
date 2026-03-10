APP_NAME = Browsar
BUILD_DIR = build
APP_BUNDLE = $(BUILD_DIR)/$(APP_NAME).app
CONTENTS_DIR = $(APP_BUNDLE)/Contents
MACOS_DIR = $(CONTENTS_DIR)/MacOS
RESOURCES_DIR = $(CONTENTS_DIR)/Resources
INSTALL_DIR = /Applications
LSREGISTER = /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister
ICONSET_DIR = $(BUILD_DIR)/AppIcon.iconset
HAS_ICON = $(wildcard Resources/AppIcon.png)

.PHONY: build run install uninstall clean icon

icon:
ifneq ($(HAS_ICON),)
	mkdir -p $(ICONSET_DIR)
	sips -z 16 16     Resources/AppIcon.png --out $(ICONSET_DIR)/icon_16x16.png
	sips -z 32 32     Resources/AppIcon.png --out $(ICONSET_DIR)/icon_16x16@2x.png
	sips -z 32 32     Resources/AppIcon.png --out $(ICONSET_DIR)/icon_32x32.png
	sips -z 64 64     Resources/AppIcon.png --out $(ICONSET_DIR)/icon_32x32@2x.png
	sips -z 128 128   Resources/AppIcon.png --out $(ICONSET_DIR)/icon_128x128.png
	sips -z 256 256   Resources/AppIcon.png --out $(ICONSET_DIR)/icon_128x128@2x.png
	sips -z 256 256   Resources/AppIcon.png --out $(ICONSET_DIR)/icon_256x256.png
	sips -z 512 512   Resources/AppIcon.png --out $(ICONSET_DIR)/icon_256x256@2x.png
	sips -z 512 512   Resources/AppIcon.png --out $(ICONSET_DIR)/icon_512x512.png
	sips -z 1024 1024 Resources/AppIcon.png --out $(ICONSET_DIR)/icon_512x512@2x.png
	iconutil -c icns $(ICONSET_DIR) -o Resources/AppIcon.icns
endif

build: icon
	swift build -c release
	mkdir -p $(MACOS_DIR) $(RESOURCES_DIR)
	cp .build/release/$(APP_NAME) $(MACOS_DIR)/$(APP_NAME)
	cp Resources/Info.plist $(CONTENTS_DIR)/Info.plist
	@if [ -f Resources/AppIcon.icns ]; then cp Resources/AppIcon.icns $(RESOURCES_DIR)/AppIcon.icns; fi
	codesign --force --deep --sign - $(APP_BUNDLE)
	@echo "Built $(APP_BUNDLE)"

run: build
	open $(APP_BUNDLE)

install: build
	cp -R $(APP_BUNDLE) $(INSTALL_DIR)/$(APP_NAME).app
	$(LSREGISTER) -f $(INSTALL_DIR)/$(APP_NAME).app
	@echo "Installed to $(INSTALL_DIR)/$(APP_NAME).app"
	@echo "Opening Browsar..."
	open $(INSTALL_DIR)/$(APP_NAME).app

uninstall:
	osascript -e 'tell application "Browsar" to quit' 2>/dev/null || true
	rm -rf $(INSTALL_DIR)/$(APP_NAME).app
	@echo "Uninstalled Browsar"

clean:
	swift package clean
	rm -rf $(BUILD_DIR)
