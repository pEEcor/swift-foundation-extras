// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-foundation-extensions",
    platforms: [.macOS(.v13), .iOS(.v16)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "FoundationExtensions",
            targets: [
                "FoundationExtensions",
                "Persistence"
            ]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/xctest-dynamic-overlay.git", from: "1.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-concurrency-extras", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-async-algorithms", from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Persistence",
            dependencies: [
                .product(name: "ConcurrencyExtras", package: "swift-concurrency-extras"),
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms")
            ]
        ),
        .target(
            name: "FoundationExtensions",
            dependencies: [
                .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
                .product(name: "ConcurrencyExtras", package: "swift-concurrency-extras")
            ]
        ),
        .testTarget(
            name: "FoundationExtensionTests",
            dependencies: ["FoundationExtensions"]
        ),
    ]
)
