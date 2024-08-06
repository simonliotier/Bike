// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "Bike",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
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
            ],
            plugins: [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLint")]
        ),
        .testTarget(
            name: "BikeTests",
            dependencies: ["Bike"],
            plugins: [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLint")]
        )
    ]
)
