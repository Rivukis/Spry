// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Spry",
    platforms: [
        .iOS(.v10)
    ],
    products: [
        .library(name: "Spry", targets: ["Spry"]),
        .library(name: "Spry_Nimble", targets: ["Spry_Nimble"])
    ],
    dependencies: [
        .package(url: "https://github.com/Quick/Quick.git", .upToNextMajor(from: "4.0.0")),
        .package(url: "https://github.com/Quick/Nimble.git", .upToNextMajor(from: "9.2.0"))
    ],
    targets: [
        .target(name: "Spry",
                dependencies: [],
                path: "Source"),
        .target(name: "Spry_Nimble",
                dependencies: ["Spry", "Nimble"],
                path: "SourceNimble"),
        .testTarget(name: "SpryTests",
                    dependencies: [
                        "Spry_Nimble",
                        "Spry",
                        "Nimble",
                        "Quick"
                    ],
                    path: "Tests/Specs",
                    exclude: ["Resources/cocoapods"])
    ],
    swiftLanguageVersions: [.v5]
)
