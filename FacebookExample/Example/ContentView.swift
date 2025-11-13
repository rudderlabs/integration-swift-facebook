//
//  ContentView.swift
//  FacebookExample
//
//  Created by Vishal Gupta on 12/11/25.
//

import SwiftUI
import RudderStackAnalytics

struct ContentView: View {
    @StateObject private var analyticsManager = AnalyticsManager.shared
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    Text("Facebook Integration Example")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding()
                    
                    // User Identity Section
                    VStack(spacing: 12) {
                        Text("User Identity")
                            .font(.headline)
                        
                        Button("Identify User") {
                            identify()
                        }
                        .buttonStyle(PrimaryButtonStyle())
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    
                    // E-commerce Events Section
                    VStack(spacing: 12) {
                        Text("E-commerce Events")
                            .font(.headline)
                        
                        Button("Products Searched") {
                            productsSearched()
                        }
                        .buttonStyle(SecondaryButtonStyle())
                        
                        Button("Product Viewed") {
                            productViewed()
                        }
                        .buttonStyle(SecondaryButtonStyle())
                        
                        Button("Product Added") {
                            productAdded()
                        }
                        .buttonStyle(SecondaryButtonStyle())
                        
                        Button("Added to Wishlist") {
                            productAddedToWishlist()
                        }
                        .buttonStyle(SecondaryButtonStyle())
                        
                        Button("Checkout Started") {
                            checkoutStarted()
                        }
                        .buttonStyle(SecondaryButtonStyle())
                        
                        Button("Payment Info Entered") {
                            paymentInfoEntered()
                        }
                        .buttonStyle(SecondaryButtonStyle())
                        
                        Button("Order Completed") {
                            orderCompleted()
                        }
                        .buttonStyle(SecondaryButtonStyle())
                        
                        Button("Product Reviewed") {
                            productReviewed()
                        }
                        .buttonStyle(SecondaryButtonStyle())
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)
                    
                    // App Lifecycle Events Section
                    VStack(spacing: 12) {
                        Text("App Lifecycle Events")
                            .font(.headline)
                        
                        Button("Complete Registration") {
                            completeRegistration()
                        }
                        .buttonStyle(SecondaryButtonStyle())
                        
                        Button("Achieve Level") {
                            achieveLevel()
                        }
                        .buttonStyle(SecondaryButtonStyle())
                        
                        Button("Complete Tutorial") {
                            completeTutorial()
                        }
                        .buttonStyle(SecondaryButtonStyle())
                        
                        Button("Unlock Achievement") {
                            unlockAchievement()
                        }
                        .buttonStyle(SecondaryButtonStyle())
                        
                        Button("Subscribe") {
                            subscribe()
                        }
                        .buttonStyle(SecondaryButtonStyle())
                        
                        Button("Start Trial") {
                            startTrial()
                        }
                        .buttonStyle(SecondaryButtonStyle())
                        
                        Button("Spend Credits") {
                            spendCredits()
                        }
                        .buttonStyle(SecondaryButtonStyle())
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(10)
                    
                    // Advertising Events Section
                    VStack(spacing: 12) {
                        Text("Advertising Events")
                            .font(.headline)
                        
                        Button("Promotion Clicked") {
                            promotionClicked()
                        }
                        .buttonStyle(SecondaryButtonStyle())
                        
                        Button("Promotion Viewed") {
                            promotionViewed()
                        }
                        .buttonStyle(SecondaryButtonStyle())
                    }
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(10)
                    
                    // Custom Events Section
                    VStack(spacing: 12) {
                        Text("Custom Events")
                            .font(.headline)
                        
                        Button("Custom Track (No Properties)") {
                            customTrackWithoutProperties()
                        }
                        .buttonStyle(SecondaryButtonStyle())
                        
                        Button("Custom Track (With Properties)") {
                            customTrackWithProperties()
                        }
                        .buttonStyle(SecondaryButtonStyle())
                    }
                    .padding()
                    .background(Color.purple.opacity(0.1))
                    .cornerRadius(10)
                    
                    // Screen Events Section
                    VStack(spacing: 12) {
                        Text("Screen Events")
                            .font(.headline)
                        
                        Button("Screen Events") {
                            screenEvents()
                        }
                        .buttonStyle(SecondaryButtonStyle())
                    }
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(10)
                    
                    // Reset Section
                    VStack(spacing: 12) {
                        Text("Reset")
                            .font(.headline)
                        
                        Button("Reset User") {
                            reset()
                        }
                        .buttonStyle(PrimaryButtonStyle())
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
                .padding()
            }
            .navigationTitle("Facebook Example")
        }
    }
}


// MARK: - Event Methods

extension ContentView {
    
    // MARK: - User Identity
    
    private func identify() {
        let traits: [String: Any] = [
            "address": getAddress(),
            "email": "test@random.com",
            "firstName": "FName",
            "lastName": "LName",
            "phone": "1234567890",
            "birthday": "1990-01-01",
            "gender": "M"
        ]
        
        analyticsManager.analytics?.identify(userId: "iOSUserId", traits: traits)
        print("✅ Identified user with traits")
    }
    
    // MARK: - E-commerce Events
    
    private func productsSearched() {
        analyticsManager.analytics?.track(name: "Products Searched", properties: getAllStandardProperties())
        print("✅ Tracked Products Searched event")
    }
    
    private func productViewed() {
        analyticsManager.analytics?.track(name: "Product Viewed", properties: getAllStandardProperties())
        print("✅ Tracked Product Viewed event")
    }
    
    private func productAdded() {
        analyticsManager.analytics?.track(name: "Product Added", properties: getAllStandardProperties())
        print("✅ Tracked Product Added event")
    }
    
    private func productAddedToWishlist() {
        analyticsManager.analytics?.track(name: "Product Added to Wishlist", properties: getAllStandardProperties())
        print("✅ Tracked Product Added to Wishlist event")
    }
    
    private func checkoutStarted() {
        analyticsManager.analytics?.track(name: "Checkout Started", properties: getAllStandardProperties())
        print("✅ Tracked Checkout Started event")
    }
    
    private func paymentInfoEntered() {
        analyticsManager.analytics?.track(name: "Payment Info Entered", properties: getAllStandardProperties())
        print("✅ Tracked Payment Info Entered event")
    }
    
    private func orderCompleted() {
        analyticsManager.analytics?.track(name: "Order Completed", properties: getAllStandardProperties())
        print("✅ Tracked Order Completed event")
    }
    
    private func productReviewed() {
        analyticsManager.analytics?.track(name: "Product Reviewed", properties: getAllStandardProperties())
        print("✅ Tracked Product Reviewed event")
    }
    
    // MARK: - App Lifecycle Events
    
    private func completeRegistration() {
        analyticsManager.analytics?.track(name: "Complete Registration", properties: getAllStandardProperties())
        print("✅ Tracked Complete Registration event")
    }
    
    private func achieveLevel() {
        analyticsManager.analytics?.track(name: "Achieve Level", properties: getAllStandardProperties())
        print("✅ Tracked Achieve Level event")
    }
    
    private func completeTutorial() {
        analyticsManager.analytics?.track(name: "Complete Tutorial", properties: getAllStandardProperties())
        print("✅ Tracked Complete Tutorial event")
    }
    
    private func unlockAchievement() {
        analyticsManager.analytics?.track(name: "Unlock Achievement", properties: getAllStandardProperties())
        print("✅ Tracked Unlock Achievement event")
    }
    
    private func subscribe() {
        analyticsManager.analytics?.track(name: "Subscribe", properties: getAllStandardProperties())
        print("✅ Tracked Subscribe event")
    }
    
    private func startTrial() {
        analyticsManager.analytics?.track(name: "Start Trial", properties: getAllStandardProperties())
        print("✅ Tracked Start Trial event")
    }
    
    private func spendCredits() {
        analyticsManager.analytics?.track(name: "Spend Credits", properties: getAllStandardProperties())
        print("✅ Tracked Spend Credits event")
    }
    
    // MARK: - Advertising Events
    
    private func promotionClicked() {
        analyticsManager.analytics?.track(name: "Promotion Clicked", properties: getAllStandardProperties())
        print("✅ Tracked Promotion Clicked event")
    }
    
    private func promotionViewed() {
        analyticsManager.analytics?.track(name: "Promotion Viewed", properties: getAllStandardProperties())
        print("✅ Tracked Promotion Viewed event")
    }
    
    // MARK: - Custom Events
    
    private func customTrackWithoutProperties() {
        analyticsManager.analytics?.track(name: "level_up")
        analyticsManager.analytics?.track(name: "custom track 2")
        print("✅ Tracked custom events without properties")
    }
    
    private func customTrackWithProperties() {
        analyticsManager.analytics?.track(name: "daily_rewards_claim", properties: getCustomProperties())
        print("✅ Tracked custom event with properties")
    }
    
    // MARK: - Screen Events
    
    private func screenEvents() {
        analyticsManager.analytics?.screen(screenName: "View Controller 1")
        analyticsManager.analytics?.screen(screenName: "View Controller 2", properties: getCustomProperties())
        print("✅ Tracked screen events")
    }
    
    // MARK: - Reset
    
    private func reset() {
        analyticsManager.analytics?.reset()
        print("✅ Reset user data")
    }
}

// MARK: - Data Helpers

extension ContentView {
    
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

// MARK: - Button Styles

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            .background(Color.gray.opacity(0.2))
            .foregroundColor(.primary)
            .cornerRadius(6)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

#Preview {
    ContentView()
}
