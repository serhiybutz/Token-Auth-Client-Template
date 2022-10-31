// swift-tools-version: 5.5

import PackageDescription

let package = Package(
    name: "MyServerAPI",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "MyServerAPI",
            targets: ["MyServerAPI"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "MyServerAPI",
            dependencies: []),
        .testTarget(
            name: "MyServerAPITests",
            dependencies: ["MyServerAPI"]),
    ]
)
