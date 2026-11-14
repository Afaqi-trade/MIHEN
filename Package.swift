// swift-tools-version: 5.10
import PackageDescription
let package = Package(
    name: "MIHENCore",
    platforms: [.macOS(.v13), .iOS("18.0")],
    products: [.library(name: "MIHENCore", targets: ["MIHENCore"])],
    targets: [
        .target(name: "MIHENCore", path: "Core"),
        .testTarget(name: "MIHENCoreTests", dependencies: ["MIHENCore"], path: "Tests/MIHENCoreTests")
    ]
)
