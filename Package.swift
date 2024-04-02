// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-foundation-extras",
    platforms: [.macOS(.v13), .iOS(.v16)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to
        // other packages.
        .library(name: "FoundationExtras", targets: ["FoundationExtras"]),
        .library(name: "Persistence", targets: ["Persistence"]),
        .library(name: "TestExtras", targets: ["TestExtras"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
        .package(url: "https://github.com/pointfreeco/xctest-dynamic-overlay.git", from: "1.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-concurrency-extras", from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Persistence",
            dependencies: [
                .product(name: "ConcurrencyExtras", package: "swift-concurrency-extras"),
            ]
        ),
        .target(
            name: "FoundationExtras",
            dependencies: [
                .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
            ]
        ),
        .target(
            name: "TestExtras",
            dependencies: [
                .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
            ]
        ),
        .testTarget(
            name: "FoundationExtrasTests",
            dependencies: [
                .target(name: "FoundationExtras"),
            ]
        ),
        .testTarget(
            name: "PersistenceTests",
            dependencies: [
                .target(name: "Persistence"),
                .target(name: "TestExtras"),
            ]
        ),
        .testTarget(
            name: "TestExtrasTests",
            dependencies: [
                .target(name: "TestExtras"),
                .target(name: "Persistence"),
            ]
        ),
    ]
)
