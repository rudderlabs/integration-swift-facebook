// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "integration-swift-facebook",
    platforms: [
        .iOS(.v15),
        .tvOS(.v15)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "RudderIntegrationFacebook",
            targets: ["RudderIntegrationFacebook"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/facebook/facebook-ios-sdk",
            .upToNextMajor(from: "18.0.0")
        ),
        .package(
            url: "https://github.com/rudderlabs/rudder-sdk-swift.git",
            branch: "chore/test-firebase-integration"
        )
    ],
    targets: [
        .target(
            name: "RudderIntegrationFacebook",
            dependencies: [
                .product(name: "FacebookCore", package: "facebook-ios-sdk"),
                .product(name: "RudderStackAnalytics", package: "rudder-sdk-swift")
            ]
        ),
        .testTarget(
            name: "RudderIntegrationFacebookTests",
            dependencies: ["RudderIntegrationFacebook"]
        )
    ]
)
