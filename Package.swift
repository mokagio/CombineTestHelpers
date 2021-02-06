// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CombineTestHelpers",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "CombineTestHelpers",
            targets: ["CombineTestHelpers"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "CombineTestHelpers",
            dependencies: []
        ),
        .testTarget(
            name: "CombineTestHelpersTests",
            dependencies: ["CombineTestHelpers"]
        ),
    ]
)
