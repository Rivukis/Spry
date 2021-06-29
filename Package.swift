// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NSpry",
    platforms: [
        .iOS(.v10)
    ],
    products: [
        .library(name: "NSpry", targets: ["NSpry"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Quick/Quick.git", .upToNextMajor(from: "4.0.0")),
        .package(url: "https://github.com/Quick/Nimble.git", .upToNextMajor(from: "9.2.0"))
    ],
    targets: [
        .target(name: "NSpry",
                dependencies: ["Nimble",
                               "Quick"],
                path: "Source"),
        .testTarget(name: "NSpryTests",
                    dependencies: [
                        "NSpry",
                        "Nimble",
                        "Quick"
                    ],
                    path: "Tests/Specs",
                    exclude: ["Resources/cocoapods"])
    ],
    swiftLanguageVersions: [.v5]
)
