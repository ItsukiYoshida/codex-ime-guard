// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "CodexImeGuard",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "codex-ime-guard", targets: ["CodexImeGuard"])
    ],
    targets: [
        .executableTarget(
            name: "CodexImeGuard",
            path: "Sources/CodexImeGuard"
        )
    ]
)
