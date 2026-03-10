# Browsar

A macOS menu bar utility for switching the system default browser. Browsar sits in your menu bar and lets you change which browser handles links with a single click.

This is a default browser **switcher**, not a per-URL picker. It changes the actual macOS system default browser setting.

## Requirements

- macOS 13 (Ventura) or later
- Swift 5.9+

## Build and Run

```bash
make build    # produces build/Browsar.app
make run      # builds and launches
make clean    # cleans build artifacts
```

## How It Works

1. Click the globe icon in the menu bar
2. See all installed browsers with a checkmark next to the current default
3. Click a browser to make it the new system default
4. Any links opened system-wide now go to your chosen browser

When Browsar is registered as a URL handler, it forwards incoming URLs to whichever browser you've selected.

## Architecture

Built with Swift Package Manager and SwiftUI `MenuBarExtra` (no Xcode project required).

```
Sources/Browsar/
├── BrowsarApp.swift       # @main, MenuBarExtra scene
├── AppDelegate.swift      # Apple Event handler for URL forwarding
├── Browser.swift          # Browser data model
└── BrowserManager.swift   # Detection, default get/set, URL forwarding
```

- **Browser detection** — `LSCopyApplicationURLsForURL` discovers all apps that handle `https://` URLs
- **Default management** — `LSSetDefaultHandlerForURLScheme` sets the default for both `http` and `https`
- **URL forwarding** — Apple Event handler receives URLs and opens them with `NSWorkspace` in the selected browser
- **Menu bar only** — `LSUIElement = true` keeps the app out of the Dock

## Notes

- `LSSetDefaultHandlerForURLScheme` is deprecated but remains the only practical API for this task. Apple has not provided a replacement that works without user interaction.
- On macOS 12+, setting the default browser may trigger a one-time system confirmation dialog.
- The app filters itself out of the browser list using bundle ID `com.browsar.app`.
