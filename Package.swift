// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "WorthIt",
    platforms: [
        .iOS("18.0"),
        .macOS(.v13)
    ],
    products: [
        .library(name: "WorthItAPI", targets: ["WorthItAPI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-openapi-generator", exact: "1.2.0"),
        .package(url: "https://github.com/apple/swift-openapi-runtime", exact: "1.2.0"),
        .package(url: "https://github.com/apple/swift-openapi-urlsession", exact: "1.0.0"),
    ],
    targets: [
        .target(
            name: "WorthItAPI",
            dependencies: [
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(name: "OpenAPIURLSession", package: "swift-openapi-urlsession"),
            ],
            plugins: [
                .plugin(name: "OpenAPIGenerator", package: "swift-openapi-generator")
            ]
        ),
    ]
)
