// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Browsar",
    platforms: [
        .macOS(.v13)
    ],
    targets: [
        .executableTarget(
            name: "Browsar",
            path: "Sources/Browsar"
        )
    ]
)
