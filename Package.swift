// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PhotoEdit",
    defaultLocalization: "zh-Hans",
    platforms: [.iOS(.v13)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        // .library(name: "ZLPhotoBrowser", targets: ["ZLPhotoBrowser"]),
        .library(name: "PhotoEdit", targets: ["PhotoEdit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/SnapKit/SnapKit.git", .upToNextMajor(from: "5.7.1")),
        .package(url: "https://github.com/HeroTransitions/Hero.git", .upToNextMajor(from: "1.6.3")),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "ZLPhotoBrowser",
            path: "Sources/ZLPhotoBrowser",
            exclude: [
                "Info.plist",
                "General/ZLWeakProxy.h",
                "General/ZLWeakProxy.m"
            ],
            resources: [
                .process("ZLPhotoBrowser.bundle"),
                .copy("PrivacyInfo.xcprivacy")
            ]),
        .target(name: "PhotoEdit",
                dependencies: ["ZLPhotoBrowser", "SnapKit", "Hero"],
                path: "Sources/PhotoEdit", resources: [
                    .process("PhotoEdit.xcassets")
                ]),
    ]
)
