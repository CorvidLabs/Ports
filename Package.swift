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
            resources: [
                .copy("Resources/code-review.html")
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "PortViewerTests",
            dependencies: ["PortViewer"],
            path: "Tests/PortViewerTests",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        )
    ]
)
