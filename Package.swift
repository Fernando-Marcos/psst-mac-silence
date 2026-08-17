// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Psst",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "Psst", targets: ["Psst"])
    ],
    targets: [
        .executableTarget(name: "Psst"),
        .testTarget(name: "PsstTests", dependencies: ["Psst"])
    ],
    swiftLanguageVersions: [.v5]
)
