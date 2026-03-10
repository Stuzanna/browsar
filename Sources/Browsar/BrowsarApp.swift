import ServiceManagement
import SwiftUI

@main
struct BrowsarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var browserManager = BrowserManager.shared

    init() {
        try? SMAppService.mainApp.register()
    }

    var body: some Scene {
        MenuBarExtra("Browsar", systemImage: "network") {
            BrowserMenuContent(browserManager: browserManager)
        }
    }
}

struct BrowserMenuContent: View {
    @ObservedObject var browserManager: BrowserManager

    var body: some View {
        ForEach(browserManager.browsers) { browser in
            Button {
                browserManager.setDefault(browser)
            } label: {
                let isCurrent = browser.bundleID == browserManager.currentDefault
                Text("\(isCurrent ? "✓ " : "   ")\(browser.name)")
            }
        }
        Divider()
        Button("Quit Browsar") {
            NSApplication.shared.terminate(nil)
        }
        .onAppear {
            browserManager.refresh()
        }
    }
}
