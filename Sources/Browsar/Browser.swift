import Foundation

struct Browser: Identifiable, Hashable {
    var id: String { bundleID }
    let bundleID: String
    let name: String
    let url: URL
}
