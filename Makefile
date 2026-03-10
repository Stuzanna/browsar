APP_NAME = Browsar
BUILD_DIR = build
APP_BUNDLE = $(BUILD_DIR)/$(APP_NAME).app
CONTENTS_DIR = $(APP_BUNDLE)/Contents
MACOS_DIR = $(CONTENTS_DIR)/MacOS
RESOURCES_DIR = $(CONTENTS_DIR)/Resources
INSTALL_DIR = /Applications
LSREGISTER = /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister

.PHONY: build run install uninstall clean

build:
	swift build -c release
	mkdir -p $(MACOS_DIR) $(RESOURCES_DIR)
	cp .build/release/$(APP_NAME) $(MACOS_DIR)/$(APP_NAME)
	cp Resources/Info.plist $(CONTENTS_DIR)/Info.plist
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
