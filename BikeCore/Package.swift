// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "BikeCore",
    platforms: [
        .iOS(.v18),
        .macOS(.v15),
        .watchOS(.v11),
        .visionOS(.v2),
        .tvOS(.v18)
    ],
    products: [
        .library(
            name: "BikeCore",
            targets: ["BikeCore"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire", .upToNextMajor(from: "5.7.0")),
        .package(url: "https://github.com/realm/SwiftLint", .upToNextMajor(from: "0.55.0")),
        .package(url: "https://github.com/evgenyneu/keychain-swift.git", from: "24.0.0")

    ],
    targets: [
        .target(
            name: "BikeCore",
            dependencies: [
                .product(name: "Alamofire", package: "Alamofire"),
                .product(name: "KeychainSwift", package: "keychain-swift")
            ],
            resources: [
                .copy("Authentication/OAuth/OAuthConfiguration.plist")
            ]
        ),
        .testTarget(
            name: "BikeCoreTests",
            dependencies: ["BikeCore"]
        )
    ]
)

for target in package.targets {
    // Enable SwiftLint on all targets.
    target.addPlugin(.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLint"))
}

private extension Target {
    func addPlugin(_ plugin: PluginUsage) {
        var plugins = plugins ?? []
        plugins.append(plugin)
        self.plugins = plugins
    }
}
