// swift-tools-version:5.9.2

import PackageDescription

let package = Package(
    name: "Utils9",
    defaultLocalization: "en",
    platforms: [.iOS(.v15), .macOS(.v10_15)],
    products: [
        .library(name: "Utils9", targets: ["Utils9"]),
    ],
    targets: [
        .target(name: "Utils9",
                path: "Sources"),
        .testTarget(
            name: "Utils9Tests",
            dependencies: [
                .target(name: "Utils9"),
            ]
        )
    ]
)
