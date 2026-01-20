// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "PortViewer",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "PortViewer", targets: ["PortViewer"])
    ],
    targets: [
        .executableTarget(
            name: "PortViewer",
            path: "Sources/PortViewer",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        )
    ]
)
