// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DoomStatus",
    platforms: [
        .macOS(.v14),
    ],
    products: [
        .executable(name: "DoomStatus", targets: ["DoomStatus"]),
    ],
    targets: [
        .executableTarget(
            name: "DoomStatus",
            resources: [
                .copy("Resources"),
            ]
        ),
    ]
)
