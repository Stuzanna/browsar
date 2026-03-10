import AppKit
import SwiftUI

final class BrowserManager: ObservableObject {
    static let shared = BrowserManager()

    @Published var browsers: [Browser] = []
    @Published var currentDefault: String?

    private let selfBundleID = "com.browsar.app"

    init() {
        refresh()
    }

    func refresh() {
        browsers = detectBrowsers()
        currentDefault = currentDefaultBrowser()
    }

    func setDefault(_ browser: Browser) {
        let bundleID = browser.bundleID as CFString
        LSSetDefaultHandlerForURLScheme("http" as CFString, bundleID)
        LSSetDefaultHandlerForURLScheme("https" as CFString, bundleID)
        currentDefault = browser.bundleID
    }

    func forwardURL(_ url: URL) {
        guard let defaultID = currentDefault,
              let browser = browsers.first(where: { $0.bundleID == defaultID }) else {
            NSWorkspace.shared.open(url)
            return
        }
        let config = NSWorkspace.OpenConfiguration()
        NSWorkspace.shared.open([url], withApplicationAt: browser.url, configuration: config)
    }

    // MARK: - Private

    private func detectBrowsers() -> [Browser] {
        guard let appURLs = LSCopyApplicationURLsForURL(
            URL(string: "https://example.com")! as CFURL, .all
        )?.takeRetainedValue() as? [URL] else {
            return []
        }

        return appURLs.compactMap { appURL in
            guard let bundle = Bundle(url: appURL),
                  let bundleID = bundle.bundleIdentifier,
                  bundleID.lowercased() != selfBundleID else {
                return nil
            }
            let name = bundle.object(forInfoDictionaryKey: "CFBundleName") as? String
                ?? appURL.deletingPathExtension().lastPathComponent
            return Browser(bundleID: bundleID, name: name, url: appURL)
        }
        .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    private func currentDefaultBrowser() -> String? {
        guard let url = URL(string: "https://example.com"),
              let appURL = NSWorkspace.shared.urlForApplication(toOpen: url),
              let bundle = Bundle(url: appURL) else {
            return nil
        }
        return bundle.bundleIdentifier
    }
}
