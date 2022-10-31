// swift-tools-version: 5.5

import PackageDescription

let package = Package(
    name: "KeychainSecretStore",
    platforms: [.iOS("11.3")],
    products: [
        .library(
            name: "KeychainSecretStore",
            targets: ["KeychainSecretStore"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "KeychainSecretStore",
            dependencies: []),
        .testTarget(
            name: "KeychainSecretStoreTests",
            dependencies: ["KeychainSecretStore"]),
    ]
)
