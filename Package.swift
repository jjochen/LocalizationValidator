// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "LocalizationValidator",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .executable(
            name: "validate-localization",
            targets: ["ValidateLocalization"]
        ),
        .library(
            name: "LocalizationValidator",
            targets: ["LocalizationValidator"]
        ),
    ],
    dependencies: [
        .package(
            name: "swift-argument-parser",
            url: "https://github.com/apple/swift-argument-parser",
            from: "0.2.0"
        ),
        .package(
            name: "Files",
            url: "https://github.com/johnsundell/files",
            from: "4.0.0"
        ),
    ],
    targets: [
        .target(
            name: "ValidateLocalization",
            dependencies: [
                "LocalizationValidator",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .target(
            name: "LocalizationValidator",
            dependencies: [
                "Files",
            ]
        ),
        .testTarget(
            name: "LocalizationValidatorTests",
            dependencies: [
                "LocalizationValidator",
                "Files",
            ]
        ),
    ]
)
