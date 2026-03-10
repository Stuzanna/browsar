# Browsar

A macOS menu bar utility for switching the system default browser. Browsar sits in your menu bar and lets you change which browser handles links with a single click.

This is a default browser **switcher**, not a per-URL picker. It changes the actual macOS system default browser setting.

## Requirements

- macOS 13 (Ventura) or later
- Swift 5.9+

## Install

```bash
git clone https://github.com/Stuzanna/browsar.git
cd browsar
make install
```

This builds the app, ad-hoc signs it, copies it to `/Applications`, registers it with Launch Services, and opens it. Browsar will launch automatically on login.

## Uninstall

```bash
make uninstall
```

## Usage

1. Click the globe icon in the menu bar
2. See all installed browsers with a checkmark next to the current default
3. Click a browser to make it the new system default
4. Any links opened system-wide now go to your chosen browser

When Browsar is registered as a URL handler, it forwards incoming URLs to whichever browser you've selected.

## Development

```bash
make build    # build to build/Browsar.app
make run      # build and launch from build directory
make clean    # remove build artifacts
```

## Architecture

Built with Swift Package Manager and SwiftUI `MenuBarExtra` (no Xcode project required).

```
Sources/Browsar/
├── BrowsarApp.swift       # @main, MenuBarExtra scene, login item registration
├── AppDelegate.swift      # Apple Event handler for URL forwarding
├── Browser.swift          # Browser data model
└── BrowserManager.swift   # Detection, default get/set, URL forwarding
```

- **Browser detection** — `LSCopyApplicationURLsForURL` discovers all apps that handle `https://` URLs
- **Default management** — `LSSetDefaultHandlerForURLScheme` sets the default for both `http` and `https`
- **URL forwarding** — Apple Event handler receives URLs and opens them with `NSWorkspace` in the selected browser
- **Login item** — `SMAppService` registers Browsar to launch at login
- **Menu bar only** — `LSUIElement = true` keeps the app out of the Dock

## Notes

- `LSSetDefaultHandlerForURLScheme` is deprecated but remains the only practical API for this task. Apple has not provided a replacement that works without user interaction.
- Switching the default browser may trigger a one-time macOS confirmation dialog. This is OS-level behavior and cannot be bypassed.
- The app filters itself out of the browser list using bundle ID `com.browsar.app`.
