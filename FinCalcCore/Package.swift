// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FinCalcCore",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "FinCalcCore",
            targets: ["FinCalcCore"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/airbnb/lottie-ios.git", from: "4.3.3"),
    ],
    targets: [
        .target(
            name: "FinCalcCore",
            dependencies: [
                .product(name: "Lottie", package: "lottie-ios"),
            ],
            path: "Sources"
        )
    ]
)
