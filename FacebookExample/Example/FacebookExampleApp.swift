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
class AnalyticsManager: ObservableObject {
    static let shared = AnalyticsManager()
    @Published var analytics: Analytics?
    
    private init() {}
}
