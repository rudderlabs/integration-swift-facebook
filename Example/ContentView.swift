//
//  ContentView.swift
//  FacebookExample
//
//  Created by Vishal Gupta on 12/11/25.
//

import SwiftUI
import RudderStackAnalytics

struct ContentView: View {
    private var analyticsManager = AnalyticsManager.shared
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    
                    // User Identity Section
                    userIdentitySection
                    
                    // E-commerce Events Section
                    ecommerceEventsSection
                    
                    // App Lifecycle Events Section
                    appLifecycleEventsSection
                    
                    // Advertising Events Section
                    advertisingEventsSection
                    
                    // Custom Events Section
                    customEventsSection
                    
                    // Screen Events Section
                    screenEventsSection
                    
                    // Reset Section
                    resetSection
                }
                .padding()
            }
            .navigationTitle("Facebook Example")
        }
    }
}

extension ContentView {

    var userIdentitySection: some View {
        VStack(spacing: 12) {
            Text("User Identity")
                .font(.headline)
            
            Button("Identify User") {
                analyticsManager.identifyUser()
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }

    var ecommerceEventsSection: some View {
        VStack(spacing: 12) {
            Text("E-commerce Events")
                .font(.headline)
            
            Button("Products Searched") {
                analyticsManager.productsSearchedEvent()
            }
            .buttonStyle(SecondaryButtonStyle())
            
            Button("Product Viewed") {
                analyticsManager.productViewedEvent()
            }
            .buttonStyle(SecondaryButtonStyle())
            
            Button("Product Added") {
                analyticsManager.productAddedEvent()
            }
            .buttonStyle(SecondaryButtonStyle())
            
            Button("Added to Wishlist") {
                analyticsManager.productAddedToWishlistEvent()
            }
            .buttonStyle(SecondaryButtonStyle())
            
            Button("Checkout Started") {
                analyticsManager.checkoutStartedEvent()
            }
            .buttonStyle(SecondaryButtonStyle())
            
            Button("Payment Info Entered") {
                analyticsManager.paymentInfoEnteredEvent()
            }
            .buttonStyle(SecondaryButtonStyle())
            
            Button("Order Completed") {
                analyticsManager.orderCompletedEvent()
            }
            .buttonStyle(SecondaryButtonStyle())
            
            Button("Product Reviewed") {
                analyticsManager.productReviewedEvent()
            }
            .buttonStyle(SecondaryButtonStyle())
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(10)
    }

    var appLifecycleEventsSection: some View {
        VStack(spacing: 12) {
            Text("App Lifecycle Events")
                .font(.headline)
            
            Button("Complete Registration") {
                analyticsManager.completeRegistrationEvent()
            }
            .buttonStyle(SecondaryButtonStyle())
            
            Button("Achieve Level") {
                analyticsManager.achieveLevelEvent()
            }
            .buttonStyle(SecondaryButtonStyle())
            
            Button("Complete Tutorial") {
                analyticsManager.completeTutorialEvent()
            }
            .buttonStyle(SecondaryButtonStyle())
            
            Button("Unlock Achievement") {
                analyticsManager.unlockAchievementEvent()
            }
            .buttonStyle(SecondaryButtonStyle())
            
            Button("Subscribe") {
                analyticsManager.subscribeEvent()
            }
            .buttonStyle(SecondaryButtonStyle())
            
            Button("Start Trial") {
                analyticsManager.startTrialEvent()
            }
            .buttonStyle(SecondaryButtonStyle())
            
            Button("Spend Credits") {
                analyticsManager.spendCreditsEvent()
            }
            .buttonStyle(SecondaryButtonStyle())
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(10)
    }

    var advertisingEventsSection: some View {
        VStack(spacing: 12) {
            Text("Advertising Events")
                .font(.headline)
            
            Button("Promotion Clicked") {
                analyticsManager.promotionClickedEvent()
            }
            .buttonStyle(SecondaryButtonStyle())
            
            Button("Promotion Viewed") {
                analyticsManager.promotionViewedEvent()
            }
            .buttonStyle(SecondaryButtonStyle())
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(10)
    }

    var customEventsSection: some View {
        VStack(spacing: 12) {
            Text("Custom Events")
                .font(.headline)
            
            Button("Custom Track (No Properties)") {
                analyticsManager.customTrackEventWithoutProperties()
            }
            .buttonStyle(SecondaryButtonStyle())
            
            Button("Custom Track (With Properties)") {
                analyticsManager.customTrackEventWithProperties()
            }
            .buttonStyle(SecondaryButtonStyle())
        }
        .padding()
        .background(Color.purple.opacity(0.1))
        .cornerRadius(10)
    }

    var screenEventsSection: some View {
        VStack(spacing: 12) {
            Text("Screen Events")
                .font(.headline)
            
            Button("Screen Events") {
                analyticsManager.screenEvents()
            }
            .buttonStyle(SecondaryButtonStyle())
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .cornerRadius(10)
    }

    var resetSection: some View {
        VStack(spacing: 12) {
            Text("Reset")
                .font(.headline)
            
            Button("Reset User") {
                analyticsManager.resetUser()
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
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
