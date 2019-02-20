// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EventStreamer",
    dependencies: [
        .package(url: "https://github.com/mannie/AzureCocoaSAS.git", .branch("master"))
    ],
    targets: [
        .target(name: "EventStreamer", dependencies: [ "AzureCocoaSAS" ]),
        .testTarget( name: "EventStreamerTests", dependencies: ["EventStreamer"]),
    ]
)
