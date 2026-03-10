# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **macOS browser switcher** - a menu bar utility that allows quick switching of the system default browser. The app registers itself as a browser and forwards URLs to the user's chosen browser.

**Current Status:** Planning phase. No code has been written yet. See BROWSER_SWITCHER_PROJECT.md for comprehensive project planning.

**Key Distinction:** This is a default browser switcher, NOT a per-URL picker. It changes the actual macOS system default browser setting.

## Technology Stack

- **Language:** Swift
- **UI Framework:** SwiftUI for menus, AppKit NSStatusItem for menu bar integration
- **APIs:** Launch Services (LSSetDefaultHandlerForURLScheme, LSCopyDefaultHandlerForURLScheme)
- **Persistence:** UserDefaults
- **No external dependencies** needed for MVP

## Planned Architecture

Based on BROWSER_SWITCHER_PROJECT.md, the typical structure should be:

```
BrowserSwitcher/
├── App/
│   ├── AppDelegate.swift          # Main app lifecycle
│   ├── StatusBarController.swift  # Menu bar management
│   └── URLHandler.swift            # Intercept & forward URLs
├── Models/
│   ├── Browser.swift               # Browser data model
│   └── BrowserManager.swift        # Detection & management
├── Views/
│   ├── MenuView.swift              # SwiftUI menu
│   └── PreferencesView.swift       # Settings window
├── Utilities/
│   └── IconCache.swift             # Icon extraction/caching
└── Resources/
    ├── Info.plist
    └── Assets.xcassets
```

## Core Technical Components

### 1. Menu Bar App
- Use `NSStatusBar.system.statusItem(withLength:)` to create status bar item
- Set `LSUIElement = true` in Info.plist to make it menu bar only

### 2. Browser Detection
- Use `NSWorkspace` APIs to discover apps that can handle http/https URLs
- `LSCopyApplicationURLsForURL` to enumerate URL handlers

### 3. Default Browser Management
- Get current: `LSCopyDefaultHandlerForURLScheme("https" as CFString)`
- Set new: `LSSetDefaultHandlerForURLScheme("https" as CFString, bundleID as CFString)`
- Must register for both "http" and "https" schemes

### 4. URL Registration
Must add to Info.plist:
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>http</string>
            <string>https</string>
        </array>
    </dict>
</array>
```

### 5. URL Forwarding
- Implement Apple Event handler to receive URLs
- Forward to selected browser: `NSWorkspace.shared.open(urls, withApplicationAt:, configuration:)`

## MVP Features Checklist

1. Detect installed browsers
2. Show menu bar icon
3. List browsers in menu when clicked
4. Change system default on selection
5. Forward intercepted URLs to chosen browser

Estimated ~150-200 lines of Swift for basic version.

## Important Technical Considerations

### Security
- Validate URLs before forwarding
- Sanitize browser bundle IDs
- Use proper code signing (Apple Developer ID required)

### Performance
- Fast switching (< 1 second)
- Cache browser icons to avoid repeated extraction

### Compatibility
- Test on different macOS versions
- Handle browsers outside /Applications
- Support both Intel and Apple Silicon

## Development Workflow

### Git Hooks
A pre-push hook runs `gitleaks detect` to prevent committing secrets. Ensure gitleaks is installed before pushing.

### Development Process
1. Create new macOS app project in Xcode
2. Configure as menu bar app (LSUIElement = true)
3. Add URL scheme handlers to Info.plist
4. Implement browser detection logic
5. Build menu UI with SwiftUI
6. Implement default browser switching
7. Test URL forwarding thoroughly

### Building and Testing
When code exists, typical commands will be:
- Build: `xcodebuild -scheme BrowserSwitcher`
- Test: `xcodebuild test -scheme BrowserSwitcher`
- Run: Open .app bundle or `open Build/Products/Debug/BrowserSwitcher.app`

## Reference Documentation

- Launch Services: Core API for default handler management
- NSStatusItem: Menu bar integration
- NSWorkspace: App discovery and icon extraction
- Apple Events: URL handling mechanism

## Alternative Projects for Reference

Active open-source alternatives as of March 2026:
- **punt** (mpalczew): Swift-based browser selector
- **bowzer** (lailo): Lightweight, Homebrew-available
- **browser-clutch** (nikuscs): Swift/SwiftUI with routing
- **BrowserCat** (rmarinsky): Menu bar picker

Review these for implementation patterns and UX inspiration.
