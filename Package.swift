// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "Primality",
    products: [
        .library(
            name: "Primality",
            targets: ["Primality"]),
    ],
    dependencies: [
        .package(url: "https://github.com/nixberg/subtle-swift", .branch("master")),
    ],
    targets: [
        .target(
            name: "Primality",
            dependencies: [
                .product(name: "Subtle", package: "subtle-swift"),
            ]),
        .testTarget(
            name: "PrimalityTests",
            dependencies: ["Primality"]),
    ]
)
