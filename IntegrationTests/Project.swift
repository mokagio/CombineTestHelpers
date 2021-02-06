import ProjectDescription

let dependencies: [TargetDependency] = [.package(product: "CombineTestHelpers")]

let project = Project(
    name: "IntegrationTests",
    organizationName: "mokagio",
    // Merely using ".." didn't work, so we go up two folders and back into the
    // parent folder of this project specification.
    packages: [.package(path: "../../CombineTestHelpers")],
    targets: [
        Target(
            name: "iosTests",
            platform: .iOS,
            product: .unitTests,
            bundleId: "ios.mokagio.CombineTestHelpers",
            deploymentTarget: .iOS(targetVersion: "13.0", devices: [.iphone, .ipad]),
            infoPlist: "Info.plist",
            sources: ["Tests/**"],
            dependencies: dependencies
        ),
        Target(
            name: "macosTests",
            platform: .macOS,
            product: .unitTests,
            bundleId: "macos.mokagio.CombineTestHelpers",
            deploymentTarget: .macOS(targetVersion: "10.15"),
            infoPlist: "Info.plist",
            sources: ["Tests/**"],
            dependencies: dependencies
        ),
    ]
)
