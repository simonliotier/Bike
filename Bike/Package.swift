// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Bike",
    platforms: [
        .iOS(.v18),
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "Bike",
            targets: ["Bike"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire", .upToNextMajor(from: "5.7.0")),
        .package(url: "https://github.com/p2/OAuth2", branch: "main"),
        .package(url: "https://github.com/realm/SwiftLint", .upToNextMajor(from: "0.55.0"))
    ],
    targets: [
        .target(
            name: "Bike",
            dependencies: [
                .product(name: "Alamofire", package: "Alamofire"),
                .product(name: "OAuth2", package: "OAuth2")
            ]
        ),
        .testTarget(
            name: "BikeTests",
            dependencies: ["Bike"]
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
