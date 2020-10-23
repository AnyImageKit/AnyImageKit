// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AnyImageKit",
    defaultLocalization: "en",
    platforms: [.iOS(.v10)],
    products: [
        .library(name: "AnyImageKit", targets: ["AnyImageKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/SnapKit/SnapKit", from: "5.0.0"),
    ],
    targets: [
        .target(name: "AnyImageKit",
                dependencies: ["SnapKit"],
                resources: [
                    .process("Resources"),
                ],
                swiftSettings: [
                    .define("ANYIMAGEKIT_ENABLE_SPM"),
                    .define("ANYIMAGEKIT_ENABLE_PICKER"),
                    .define("ANYIMAGEKIT_ENABLE_EDITOR"),
                    .define("ANYIMAGEKIT_ENABLE_CAPTURE"),
                ]),
    ]
)
