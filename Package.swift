// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ArtifactBundleGen",
    platforms: [.macOS(.v12)],
    products: [
        .plugin(name: "ArtifactBundleGenPluginCommand", targets: ["ArtifactBundleGenPluginCommand"]),
        .library(name: "ArtifactBundleGen", targets: ["ArtifactBundleGen"])
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "ArtifactBundleGen",
            dependencies: []),
        .testTarget(
            name: "ArtifactBundleGenTests",
            dependencies: ["ArtifactBundleGen"]),
        .plugin(
            name: "ArtifactBundleGenPluginCommand",
            capability: .command(
                intent: .custom(verb: "generate-artifact-bundle",
                                description: "Generate Artifact Bundle"),
                permissions: [.writeToPackageDirectory(reason: "Save Artifact Bundle information")]
            ),
            path: "Plugins/ArtifactBundleGenPluginCommand"
        ),
    ]
)
