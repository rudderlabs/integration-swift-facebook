<p align="center">
  <a href="https://rudderstack.com/">
    <img alt="RudderStack" width="512" src="https://raw.githubusercontent.com/rudderlabs/rudder-sdk-js/develop/assets/rs-logo-full-light.jpg">
  </a>
  <br />
  <caption>The Customer Data Platform for Developers</caption>
</p>
<p align="center">
  <b>
    <a href="https://rudderstack.com">Website</a>
    ·
    <a href="https://rudderstack.com/docs/">Documentation</a>
    ·
    <a href="https://rudderstack.com/join-rudderstack-slack-community">Community Slack</a>
  </b>
</p>

---


# Facebook Integration

The Facebook integration allows you to send your event data from RudderStack to Facebook for analytics and advertising.

## Installation

### Swift Package Manager

Add the Facebook integration to your Swift project using Swift Package Manager:

1. In Xcode, go to `File > Add Package Dependencies`
2. Enter the package repository URL: `https://github.com/rudderlabs/integration-swift-facebook` in the search bar
3. Select the version you want to use
4. Select the target to which you want to add the package
5. Finally, click on **Add Package**

Alternatively, add it to your `Package.swift` file:

```swift
// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "YourApp",
    products: [
        .library(
            name: "YourApp",
            targets: ["YourApp"]),
    ],
    dependencies: [
        // Add the Facebook integration
        .package(url: "https://github.com/rudderlabs/integration-swift-facebook.git", .upToNextMajor(from: "<latest_version>"))
    ],
    targets: [
        .target(
            name: "YourApp",
            dependencies: [
                .product(name: "RudderStackAnalytics", package: "rudder-sdk-swift"),
                .product(name: "RudderIntegrationFacebook", package: "integration-swift-facebook")
            ]),
    ]
)
```

## Supported Native Facebook SDK Version

This integration supports Facebook iOS SDK version:

```
18.0.0+
```

### Platform Support

The integration supports the following platforms:
- iOS 15.0+
- tvOS 15.0+

## Usage

Initialize the RudderStack SDK and add the Facebook integration:

```swift
import RudderStackAnalytics
import RudderIntegrationFacebook

class AppDelegate: UIResponder, UIApplicationDelegate {

    var analytics: Analytics?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Initialize the RudderStack Analytics SDK
        let config = Configuration(
            writeKey: "<WRITE_KEY>",
            dataPlaneUrl: "<DATA_PLANE_URL>"
        )
        let analytics = Analytics(configuration: config)

        // Add Facebook integration
        analytics.add(plugin: FacebookIntegration())

        return true
    }
}
```

Replace:
- `<WRITE_KEY>`: Your project's write key from the RudderStack dashboard
- `<DATA_PLANE_URL>`: The URL of your RudderStack data plane

---

## Contact us

For more information:

- Email us at [docs@rudderstack.com](mailto:docs@rudderstack.com)
- Join our [Community Slack](https://rudderstack.com/join-rudderstack-slack-community)

## Follow Us

- [RudderStack Blog](https://rudderstack.com/blog/)
- [Slack](https://rudderstack.com/join-rudderstack-slack-community)
- [Twitter](https://twitter.com/rudderstack)
- [YouTube](https://www.youtube.com/channel/UCgV-B77bV_-LOmKYHw8jvBw)