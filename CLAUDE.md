# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Browsar** is a macOS menu bar utility for switching the system default browser. It registers as an HTTP/HTTPS handler and forwards URLs to the user's chosen browser.

This is a default browser **switcher**, not a per-URL picker. It changes the actual macOS system default browser setting.

## Technology Stack

- **Language:** Swift
- **UI Framework:** SwiftUI `MenuBarExtra` (macOS 13+)
- **APIs:** Launch Services (`LSSetDefaultHandlerForURLScheme`), `NSWorkspace`, `SMAppService`
- **Build System:** Swift Package Manager + Makefile
- **No external dependencies**

## Architecture

```
Sources/Browsar/
├── BrowsarApp.swift       # @main, MenuBarExtra scene, login item registration
├── AppDelegate.swift      # Apple Event handler for URL forwarding
├── Browser.swift          # Browser data model
└── BrowserManager.swift   # Detection, default get/set, URL forwarding
```

- `BrowserManager` is a shared `ObservableObject` singleton used by both the SwiftUI views and the AppDelegate
- Browser detection uses `LSCopyApplicationURLsForURL` to find all HTTPS handlers
- Default browser is read via `NSWorkspace.shared.urlForApplication(toOpen:)`
- Default browser is set via `LSSetDefaultHandlerForURLScheme` for both `http` and `https`
- URL forwarding uses Apple Events (`kInternetEventClass` / `kAEGetURL`)

## Building and Running

```bash
make build    # build to build/Browsar.app
make run      # build and launch
make install  # build, sign, copy to /Applications, register with Launch Services
make clean    # remove build artifacts
```

## Development Workflow

### Git Hooks
A pre-push hook runs `gitleaks detect` to prevent committing secrets. Ensure gitleaks is installed before pushing.

### Key Files
- `Package.swift` — SPM manifest, macOS 13+ deployment target
- `Makefile` — builds .app bundle, handles code signing and icon generation
- `Resources/Info.plist` — LSUIElement, CFBundleURLTypes for http/https
- `Resources/AppIcon.png` — optional 1024x1024 source icon (generates .icns at build time)
