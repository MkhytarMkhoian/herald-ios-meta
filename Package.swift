// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "herald-ios-meta",
    // Meta's SDK builds for iOS only, so the tests run in the iOS Simulator, through Xcode.
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "HeraldMeta", targets: ["HeraldMeta"])
    ],
    dependencies: [
        .package(url: "https://github.com/MkhytarMkhoian/herald-ios", from: "1.2.0"),
        // 19.0.0's binaries don't match the checksums in its own Package.swift, so SwiftPM refuses
        // it. Raise the bound once Meta fixes it.
        .package(url: "https://github.com/facebook/facebook-ios-sdk", "18.1.1"..<"19.0.0"),
    ],
    targets: [
        .target(
            name: "HeraldMeta",
            dependencies: [
                .product(name: "HeraldCore", package: "herald-ios"),
                .product(name: "FacebookCore", package: "facebook-ios-sdk"),
            ]
        ),
        .testTarget(
            name: "HeraldMetaTests",
            dependencies: [
                "HeraldMeta",
                .product(name: "HeraldTesting", package: "herald-ios"),
            ]
        ),
    ]
)
