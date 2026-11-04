// swift-tools-version: 5.9
import PackageDescription
let package = Package(
    name: "RudderIntegrationFacebook",
    platforms: [.iOS(.v15), .tvOS(.v15)],
    products: [.library(name: "RudderIntegrationFacebook", targets: ["RudderIntegrationFacebook"])],
    dependencies: [.package(url: "https://github.com/rudderlabs/rudder-sdk-swift.git", from: "2.0.0"), .package(url: "https://github.com/facebook/facebook-ios-sdk", .upToNextMajor(from: "18.0.0"))],
    targets: [.target(name: "RudderIntegrationFacebook", dependencies: [.product(name: "RudderStackAnalytics", package: "rudder-sdk-swift"), .product(name: "FacebookCore", package: "facebook-ios-sdk")])]
)
