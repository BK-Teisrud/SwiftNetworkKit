// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "SwiftNetworkKit",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .watchOS(.v10),
        .tvOS(.v17),
    ],
    products: [
        .library(name: "NetworkKit", targets: ["NetworkKit"]),
    ],
    targets: [
        .target(name: "NetworkKit"),
        .testTarget(name: "NetworkKitTests", dependencies: ["NetworkKit"]),
    ],
    swiftLanguageModes: [.v6]
)
