// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MyAcademicWebsite",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(name: "MyAcademicWebsite", targets: ["MyAcademicWebsite"])
    ],
    dependencies: [
        .package(url: "https://github.com/JohnSundell/Publish.git", from: "0.9.0"),
        .package(url: "https://github.com/JohnSundell/Plot.git", from: "0.14.0")
    ],
    targets: [
        .executableTarget(
            name: "MyAcademicWebsite",
            dependencies: [
                .product(name: "Publish", package: "Publish"),
                .product(name: "Plot", package: "Plot")
            ],
            path: "MyAcademicWebsite"
        )
    ]
)
