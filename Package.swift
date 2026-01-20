// swift-tools-version: 6.0

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
            path: "Sources/PortViewer"
        ),
        .testTarget(
            name: "PortViewerTests",
            dependencies: ["PortViewer"],
            path: "Tests/PortViewerTests"
        )
    ]
)
