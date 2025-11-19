//
//  FacebookExampleApp.swift
//  FacebookExample
//
//  Created by Vishal Gupta on 12/11/25.
//

import SwiftUI
import Combine
import RudderStackAnalytics
import RudderIntegrationFacebook
import FacebookCore

@main
struct FacebookExampleApp: App {
    
    init() {
        setupAnalytics()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    private func setupAnalytics() {
        // Configure Facebook SDK
        ApplicationDelegate.shared.application(
            UIApplication.shared,
            didFinishLaunchingWithOptions: [:]
        )
        
        LoggerAnalytics.logLevel = .verbose
        
        // Configuration for RudderStack Analytics
        let configuration = Configuration(writeKey: "", dataPlaneUrl: "")
        
        // Initialize Analytics
        let analytics = Analytics(configuration: configuration)
        
        // Add Facebook Integration
        let facebookIntegration = FacebookIntegration()
        analytics.add(plugin: facebookIntegration)
        
        // Store analytics instance globally for access in ContentView
        AnalyticsManager.shared.analytics = analytics
    }
}

// Singleton to manage analytics instance
class AnalyticsManager {
    static let shared = AnalyticsManager()
    var analytics: Analytics?

    private init() {}
}

extension AnalyticsManager {

    // MARK: - User Identity

    func identifyUser() {
        let traits: [String: Any] = [
            "address": getAddress(),
            "email": "test@random.com",
            "firstName": "FName",
            "lastName": "LName",
            "phone": "1234567890",
            "birthday": "1990-01-01",
            "gender": "M"
        ]
        
        analytics?.identify(userId: "iOSUserId", traits: traits)
        LoggerAnalytics.debug("✅ Identified user with traits")
    }

    // MARK: - E-commerce Events

    func productsSearchedEvent() {
        analytics?.track(name: "Products Searched", properties: getAllStandardProperties())
        LoggerAnalytics.debug("✅ Tracked Products Searched event")
    }

    func productViewedEvent() {
        analytics?.track(name: "Product Viewed", properties: getAllStandardProperties())
        LoggerAnalytics.debug("✅ Tracked Product Viewed event")
    }

    func productAddedEvent() {
        analytics?.track(name: "Product Added", properties: getAllStandardProperties())
        LoggerAnalytics.debug("✅ Tracked Product Added event")
    }

    func productAddedToWishlistEvent() {
        analytics?.track(name: "Product Added to Wishlist", properties: getAllStandardProperties())
        LoggerAnalytics.debug("✅ Tracked Product Added to Wishlist event")
    }

    func checkoutStartedEvent() {
        analytics?.track(name: "Checkout Started", properties: getAllStandardProperties())
        LoggerAnalytics.debug("✅ Tracked Checkout Started event")
    }

    func paymentInfoEnteredEvent() {
        analytics?.track(name: "Payment Info Entered", properties: getAllStandardProperties())
        LoggerAnalytics.debug("✅ Tracked Payment Info Entered event")
    }

    func orderCompletedEvent() {
        analytics?.track(name: "Order Completed", properties: getAllStandardProperties())
        LoggerAnalytics.debug("✅ Tracked Order Completed event")
    }

    func productReviewedEvent() {
        analytics?.track(name: "Product Reviewed", properties: getAllStandardProperties())
        LoggerAnalytics.debug("✅ Tracked Product Reviewed event")
    }

    // MARK: - App Lifecycle Events

    func completeRegistrationEvent() {
        analytics?.track(name: "Complete Registration", properties: getAllStandardProperties())
        LoggerAnalytics.debug("✅ Tracked Complete Registration event")
    }

    func achieveLevelEvent() {
        analytics?.track(name: "Achieve Level", properties: getAllStandardProperties())
        LoggerAnalytics.debug("✅ Tracked Achieve Level event")
    }

    func completeTutorialEvent() {
        analytics?.track(name: "Complete Tutorial", properties: getAllStandardProperties())
        LoggerAnalytics.debug("✅ Tracked Complete Tutorial event")
    }

    func unlockAchievementEvent() {
        analytics?.track(name: "Unlock Achievement", properties: getAllStandardProperties())
        LoggerAnalytics.debug("✅ Tracked Unlock Achievement event")
    }

    func subscribeEvent() {
        analytics?.track(name: "Subscribe", properties: getAllStandardProperties())
        LoggerAnalytics.debug("✅ Tracked Subscribe event")
    }

    func startTrialEvent() {
        analytics?.track(name: "Start Trial", properties: getAllStandardProperties())
        LoggerAnalytics.debug("✅ Tracked Start Trial event")
    }

    func spendCreditsEvent() {
        analytics?.track(name: "Spend Credits", properties: getAllStandardProperties())
        LoggerAnalytics.debug("✅ Tracked Spend Credits event")
    }

    // MARK: - Advertising Events

    func promotionClickedEvent() {
        analytics?.track(name: "Promotion Clicked", properties: getAllStandardProperties())
        LoggerAnalytics.debug("✅ Tracked Promotion Clicked event")
    }

    func promotionViewedEvent() {
        analytics?.track(name: "Promotion Viewed", properties: getAllStandardProperties())
        LoggerAnalytics.debug("✅ Tracked Promotion Viewed event")
    }

    // MARK: - Custom Events

    func customTrackEventWithoutProperties() {
        analytics?.track(name: "level_up")
        analytics?.track(name: "custom track 2")
        LoggerAnalytics.debug("✅ Tracked custom events without properties")
    }

    func customTrackEventWithProperties() {
        analytics?.track(name: "daily_rewards_claim", properties: getCustomProperties())
        LoggerAnalytics.debug("✅ Tracked custom event with properties")
    }

    // MARK: - Screen Events

    func screenEvents() {
        analytics?.screen(screenName: "View Controller 1")
        analytics?.screen(screenName: "View Controller 2", properties: getCustomProperties())
        LoggerAnalytics.debug("✅ Tracked screen events")
    }

    // MARK: - Reset

    func resetUser() {
        analytics?.reset()
        LoggerAnalytics.debug("✅ Reset user data")
    }
}

extension AnalyticsManager {
    
    private func getAddress() -> [String: Any] {
        return [
            "city": "Random City",
            "state": "Random State",
            "country": "Random Country"
        ]
    }
    
    private func getAllStandardProperties() -> [String: Any] {
        return [
            "price": 123,
            "value": 124,
            "revenue": 125,
            "currency": "INR",
            "product_id": "1001",
            "rating": 5,
            "name": "AdTypeValue",
            "order_id": "2001",
            "description": "description value",
            "query": "query value",
            "key-1": 123,
            "key-2": "value-1"
        ]
    }
    
    private func getCustomProperties() -> [String: Any] {
        return [
            "key-1": 123,
            "key-2": "value-1"
        ]
    }
}
