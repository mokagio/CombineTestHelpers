import ProjectDescription

func testTarget(for platform: Platform) -> Target {
    let bundleIdRoot: String
    let deploymentTarget: DeploymentTarget
    switch platform {
    case .iOS:
        bundleIdRoot = "ios"
        deploymentTarget = .iOS(targetVersion: "13.0", devices: [.iphone, .ipad])
    case .macOS:
        bundleIdRoot = "macos"
        deploymentTarget = .macOS(targetVersion: "10.15")
    case _:
        fatalError("Not yet supported")
    }

    return Target(
        name: "\(bundleIdRoot)Tests",
        platform: platform,
        product: .unitTests,
        bundleId: "\(bundleIdRoot).mokagio.CombineTestHelpers",
        deploymentTarget: deploymentTarget,
        infoPlist: "Info.plist",
        sources: ["Tests/**"],
        dependencies: [.package(product: "CombineTestHelpers")]
    )
}

let project = Project(
    name: "IntegrationTests",
    organizationName: "mokagio",
    // Merely using ".." didn't work, so we go up two folders and back into the
    // parent folder of this project specification.
    packages: [.package(path: "../../CombineTestHelpers")],
    targets: [
        testTarget(for: .iOS),
        testTarget(for: .macOS),
    ]
)
