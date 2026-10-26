// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "CoachFinder",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "CoachFinderCore", targets: ["CoachFinderCore"]),
    ],
    targets: [
        .target(
            name: "CoachFinderCore",
            path: "CoachFinder",
            exclude: ["CoachFinderApp.swift", "Views"]
        ),
        .testTarget(
            name: "CoachFinderTests",
            dependencies: ["CoachFinderCore"],
            path: "CoachFinderTests"
        )
    ]
)
