// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftBot",
    dependencies: [
        .package(url: "https://github.com/Nonchalant/SlackKit.git", .branch("linux_compile_error")),
        .package(url: "https://github.com/kareman/SwiftShell.git", "4.0.0"..<"5.0.0"),
        .package(url: "https://github.com/kylef/PathKit.git", .upToNextMinor(from: "0.9.1")),
        .package(url: "https://github.com/IBM-Swift/swift-html-entities.git", .upToNextMajor(from: "3.0.0"))
    ],
    targets: [
        .target(
            name: "SwiftBot",
            dependencies: [
                "SwiftBotCore"
            ]
        ),
        .target(
            name: "SwiftBotCore",
            dependencies: [
                "PathKit",
                "SlackKit",
                "SwiftShell",
                "HTMLEntities"
            ]
        )
    ]
)
