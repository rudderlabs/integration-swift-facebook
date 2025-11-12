//
//  FacebookIntegration.swift
//  RudderIntegrationFacebook
//
//  Created by RudderStack on 10/11/25.
//

import Foundation
import FacebookCore
import RudderStackAnalytics

/**
 * Facebook App Events integration for RudderStack Swift SDK.
 * 
 * This integration sends events to Facebook App Events SDK, supporting:
 * - User identification with Facebook user data
 * - Event tracking with Facebook standard events mapping
 * - Screen tracking as "Viewed [Screen] Screen" events
 * - Data processing options for privacy compliance
 *
 */
public class FacebookIntegration: IntegrationPlugin, StandardIntegration {

    // MARK: - Adapters
    final var appEventsAdapter: FacebookAppEventsAdapter
    final let settingsAdapter: FacebookSettingsAdapter

    internal init(
        appEventsAdapter: FacebookAppEventsAdapter,
        settingsAdapter: FacebookSettingsAdapter
    ) {
        self.appEventsAdapter = appEventsAdapter
        self.settingsAdapter = settingsAdapter
    }

    public convenience init() {
        self.init(
            appEventsAdapter: DefaultFacebookAppEventsAdapter(),
            settingsAdapter: DefaultFacebookSettingsAdapter()
        )
    }

    // MARK: - Plugin Properties
    public var pluginType: PluginType = .terminal
    public var analytics: Analytics?
    public var key: String = "Facebook App Events"

    // MARK: - Integration Properties
    private var limitedDataUse: Bool = false
    private var dpoState: Int = 0
    private var dpoCountry: Int = 0
    private let supportedEvents: [String] = ["identify", "track", "screen"]
    private let trackReservedKeywords: [String] = [
        ECommerceParamNames.productId, ECommerceParamNames.rating, "name", ECommerceParamNames.orderId, ECommerceParamNames.currency,
        "description", ECommerceParamNames.query, "value", ECommerceParamNames.price, ECommerceParamNames.revenue
    ]

    // MARK: - IntegrationPlugin Required Methods

    public func getDestinationInstance() -> Any? {
        return appEventsAdapter.getAppEventsInstance()
    }

    public func create(destinationConfig: [String: Any]) throws {
        configureDataProcessingOptions(from: destinationConfig, isUpdate: false)
    }

    // MARK: - Optional IntegrationPlugin Methods
    
    public func update(destinationConfig: [String: Any]) throws {
        configureDataProcessingOptions(from: destinationConfig, isUpdate: true)
    }

    public func reset() {
        appEventsAdapter.userID = nil
        appEventsAdapter.clearUserData()
        LoggerAnalytics.debug("FacebookIntegration: User data and ID reset successfully")
    }

    // MARK: - Event Handling Methods

    public func identify(payload: IdentifyEvent) {
        // Set user ID
        if let userId = payload.userId {
            appEventsAdapter.userID = userId
            LoggerAnalytics.debug("FacebookIntegration: Setting userId to Facebook App Events")
        }

        // Extract traits dictionary
        guard let traits = payload.traits?.dictionary?.rawDictionary else {
            LoggerAnalytics.debug("FacebookIntegration: No traits found in identify event - skipping user data update")
            return
        }

        // Set user data properties
        if let email = traits["email"] as? String {
            appEventsAdapter.setUserData(email, forType: .email)
        }

        if let firstName = traits["firstName"] as? String {
            appEventsAdapter.setUserData(firstName, forType: .firstName)
        }

        if let lastName = traits["lastName"] as? String {
            appEventsAdapter.setUserData(lastName, forType: .lastName)
        }

        if let phone = traits["phone"] as? String {
            appEventsAdapter.setUserData(phone, forType: .phone)
        }

        if let birthday = traits["birthday"] as? String {
            appEventsAdapter.setUserData(birthday, forType: .dateOfBirth)
        }

        if let gender = traits["gender"] as? String {
            appEventsAdapter.setUserData(gender, forType: .gender)
        }

        // Handle address properties
        if let address = traits["address"] as? [String: Any] {
            if let city = address["city"] as? String {
                appEventsAdapter.setUserData(city, forType: .city)
            }

            if let state = address["state"] as? String {
                appEventsAdapter.setUserData(state, forType: .state)
            }

            if let postalCode = address["postalcode"] as? String {
                appEventsAdapter.setUserData(postalCode, forType: .zip)
            }

            if let country = address["country"] as? String {
                appEventsAdapter.setUserData(country, forType: .country)
            }
        }

        LoggerAnalytics.debug("FacebookIntegration: Identify event processed successfully with user data")
    }

    public func track(payload: TrackEvent) {
        guard !payload.event.isEmpty else {
            LoggerAnalytics.debug("FacebookIntegration: Track event missing event name - event dropped")
            return
        }
        let eventName = payload.event

        // FB Event Names must be <= 40 characters
        let truncatedEvent = String(eventName.prefix(40))
        let facebookEventName = getFacebookEventName(truncatedEvent)

        // Get properties dictionary
        let properties = payload.properties?.dictionary?.rawDictionary ?? [:]

        // Create parameters dictionary for custom properties
        var params: [AppEvents.ParameterName: Any] = [:]
        handleCustomProperties(properties: properties, params: &params, isScreenEvent: false)

        // Handle different Facebook standard events
        switch facebookEventName {
        case AppEvents.Name.addedToCart.rawValue,
             AppEvents.Name.addedToWishlist.rawValue,
             AppEvents.Name.viewedContent.rawValue:
            handleStandardProperties(properties: properties, params: &params, eventName: facebookEventName)
            if let price = getValueToSum(from: properties, key: ECommerceParamNames.price) {
                appEventsAdapter.logEvent(AppEvents.Name(rawValue: facebookEventName), valueToSum: price, parameters: params)
                LoggerAnalytics.debug("FacebookIntegration: Logged \"\(facebookEventName)\" to Facebook with price: \(price) and properties: \(properties)")
            } else {
                appEventsAdapter.logEvent(AppEvents.Name(rawValue: facebookEventName), parameters: params)
                LoggerAnalytics.debug("FacebookIntegration: Logged \"\(facebookEventName)\" to Facebook with properties: \(properties)")
            }

        case AppEvents.Name.initiatedCheckout.rawValue,
             AppEvents.Name.spentCredits.rawValue:
            handleStandardProperties(properties: properties, params: &params, eventName: facebookEventName)
            if let value = getValueToSum(from: properties, key: "value") {
                appEventsAdapter.logEvent(AppEvents.Name(rawValue: facebookEventName), valueToSum: value, parameters: params)
                LoggerAnalytics.debug("FacebookIntegration: Logged \"\(facebookEventName)\" to Facebook with value: \(value) and properties: \(properties)")
            } else {
                appEventsAdapter.logEvent(AppEvents.Name(rawValue: facebookEventName), parameters: params)
                LoggerAnalytics.debug("FacebookIntegration: Logged \"\(facebookEventName)\" to Facebook with properties: \(properties)")
            }

        case "Order Completed": // Special handling for purchases
            handleStandardProperties(properties: properties, params: &params, eventName: facebookEventName)
            if let revenue = getValueToSum(from: properties, key: ECommerceParamNames.revenue) {
                let currency = extractCurrency(from: properties, key: ECommerceParamNames.currency)
                appEventsAdapter.logPurchase(amount: revenue, currency: currency, parameters: params)
                LoggerAnalytics.debug("FacebookIntegration: Logged purchase to Facebook with revenue: \(revenue), currency: \(currency) and properties: \(properties)")
            } else {
                appEventsAdapter.logEvent(AppEvents.Name(rawValue: facebookEventName), parameters: params)
                LoggerAnalytics.debug("FacebookIntegration: Logged \"\(facebookEventName)\" to Facebook with properties: \(properties)")
            }

        case AppEvents.Name.searched.rawValue,
             AppEvents.Name.addedPaymentInfo.rawValue,
             AppEvents.Name.completedRegistration.rawValue,
             AppEvents.Name.achievedLevel.rawValue,
             AppEvents.Name.completedTutorial.rawValue,
             AppEvents.Name.unlockedAchievement.rawValue,
             AppEvents.Name.subscribe.rawValue,
             AppEvents.Name.startTrial.rawValue,
             AppEvents.Name.adClick.rawValue,
             AppEvents.Name.adImpression.rawValue,
             AppEvents.Name.rated.rawValue:
            handleStandardProperties(properties: properties, params: &params, eventName: facebookEventName)
            appEventsAdapter.logEvent(AppEvents.Name(rawValue: facebookEventName), parameters: params)
            LoggerAnalytics.debug("FacebookIntegration: Logged \"\(facebookEventName)\" to Facebook with properties: \(properties)")

        default:
            // Custom event
            appEventsAdapter.logEvent(AppEvents.Name(rawValue: facebookEventName), parameters: params)
            LoggerAnalytics.debug("FacebookIntegration: Logged custom event \"\(facebookEventName)\" to Facebook with properties: \(properties)")
        }
    }

    public func screen(payload: ScreenEvent) {
        guard !payload.event.isEmpty else {
            LoggerAnalytics.debug("FacebookIntegration: Screen event missing screen name - event dropped")
            return
        }
        let screenName = payload.event

        // FB Event Names must be <= 40 characters
        // 'Viewed' and 'Screen' with spaces take up 14 characters, so screen name can be max 26
        let truncatedScreenName = String(screenName.prefix(26))
        let eventName = "Viewed \(truncatedScreenName) Screen"

        // Get properties dictionary
        let properties = payload.properties?.dictionary?.rawDictionary ?? [:]

        // Create parameters dictionary - screen events don't skip reserved keywords
        var params: [AppEvents.ParameterName: Any] = [:]
        handleCustomProperties(properties: properties, params: &params, isScreenEvent: true)

        appEventsAdapter.logEvent(AppEvents.Name(rawValue: eventName), parameters: params)

        LoggerAnalytics.debug("FacebookIntegration: Logged screen view \"\(eventName)\" to Facebook with properties: \(properties)")
    }
}

// MARK: - FacebookIntegration Private Methods
private extension FacebookIntegration {
    
    func configureDataProcessingOptions(from destinationConfig: [String: Any], isUpdate: Bool) {
        // Extract configuration from destination config
        let limitedDataUse = destinationConfig["limitedDataUse"] as? Bool ?? false
        let dpoState = destinationConfig["dpoState"] as? Int ?? 0
        let dpoCountry = destinationConfig["dpoCountry"] as? Int ?? 0

        // Validate DPO state (0 or 1000 only)
        let validatedDpoState = (dpoState == 0 || dpoState == 1000) ? dpoState : 0
        
        // Validate DPO country (0 or 1 only)
        let validatedDpoCountry = (dpoCountry == 0 || dpoCountry == 1) ? dpoCountry : 0

        // Update instance variables
        self.limitedDataUse = limitedDataUse
        self.dpoState = validatedDpoState
        self.dpoCountry = validatedDpoCountry

        // Configure Facebook data processing options
        if self.limitedDataUse {
            settingsAdapter.setDataProcessingOptions(["LDU"], country: Int32(self.dpoCountry), state: Int32(self.dpoState))
            let actionWord = isUpdate ? "Updated" : ""
            LoggerAnalytics.debug("FacebookIntegration: \(actionWord) data processing options \(isUpdate ? "to" : "set to") [LDU] with country: \(self.dpoCountry), state: \(self.dpoState)")
        } else {
            settingsAdapter.setDataProcessingOptions([])
            let actionWord = isUpdate ? "Updated" : ""
            LoggerAnalytics.debug("FacebookIntegration: \(actionWord) data processing options cleared (no LDU restrictions)")
        }

        let successMessage = isUpdate ? "Integration configuration updated successfully" : "Integration initialized successfully"
        LoggerAnalytics.debug("FacebookIntegration: \(successMessage)")
    }
}

// MARK: - FacebookIntegration Utility Methods Extension
private extension FacebookIntegration {

    func getFacebookEventName(_ event: String) -> String {
        // Map common ecommerce events to Facebook standard events
        switch event {
        case ECommerceEvents.productsSearched:
            return AppEvents.Name.searched.rawValue
        case ECommerceEvents.productViewed:
            return AppEvents.Name.viewedContent.rawValue
        case ECommerceEvents.productAdded:
            return AppEvents.Name.addedToCart.rawValue
        case ECommerceEvents.productAddedToWishList:
            return AppEvents.Name.addedToWishlist.rawValue
        case ECommerceEvents.paymentInfoEntered:
            return AppEvents.Name.addedPaymentInfo.rawValue
        case ECommerceEvents.checkoutStarted:
            return AppEvents.Name.initiatedCheckout.rawValue
        case "Complete Registration":
            return AppEvents.Name.completedRegistration.rawValue
        case "Achieve Level":
            return AppEvents.Name.achievedLevel.rawValue
        case "Complete Tutorial":
            return AppEvents.Name.completedTutorial.rawValue
        case "Unlock Achievement":
            return AppEvents.Name.unlockedAchievement.rawValue
        case "Subscribe":
            return AppEvents.Name.subscribe.rawValue
        case "Start Trial":
            return AppEvents.Name.startTrial.rawValue
        case ECommerceEvents.promotionClicked:
            return AppEvents.Name.adClick.rawValue
        case ECommerceEvents.promotionViewed:
            return AppEvents.Name.adImpression.rawValue
        case "Spend Credits":
            return AppEvents.Name.spentCredits.rawValue
        case ECommerceEvents.productReviewed:
            return AppEvents.Name.rated.rawValue
        case ECommerceEvents.orderCompleted:
            return "Order Completed" // Special handling for purchases
        default:
            return event
        }
    }

    func handleCustomProperties(properties: [String: Any], params: inout [AppEvents.ParameterName: Any], isScreenEvent: Bool) {
        for (key, value) in properties {
            // Skip reserved keywords for track events (but not screen events)
            if !isScreenEvent && trackReservedKeywords.contains(key) {
                continue
            }

            let parameterName = AppEvents.ParameterName(rawValue: key)

            // Handle different value types
            if let numberValue = value as? NSNumber {
                params[parameterName] = numberValue
            } else {
                params[parameterName] = String(describing: value)
            }
        }
    }

    func handleStandardProperties(properties: [String: Any], params: inout [AppEvents.ParameterName: Any], eventName: String) {
        // Map standard ecommerce properties to Facebook parameters
        if let productId = properties[ECommerceParamNames.productId] {
            params[AppEvents.ParameterName.contentID] = String(describing: productId)
        }

        if let rating = properties[ECommerceParamNames.rating] as? NSNumber {
            params[AppEvents.ParameterName.maxRatingValue] = rating
        }

        if let name = properties["name"] {
            params[AppEvents.ParameterName.adType] = String(describing: name)
        }

        if let orderId = properties[ECommerceParamNames.orderId] {
            params[AppEvents.ParameterName.orderID] = String(describing: orderId)
        }

        // For Purchase event, currency is handled separately
        if eventName != "Order Completed" {
            params[AppEvents.ParameterName.currency] = extractCurrency(from: properties, key: ECommerceParamNames.currency)
        }

        if let description = properties["description"] {
            params[AppEvents.ParameterName.description] = String(describing: description)
        }

        if let query = properties[ECommerceParamNames.query] {
            params[AppEvents.ParameterName.searchString] = String(describing: query)
        }
    }

    func getValueToSum(from properties: [String: Any], key: String) -> Double? {
        guard let value = properties[key] else { return nil }

        if let numberValue = value as? NSNumber {
            return numberValue.doubleValue
        } else if let stringValue = value as? String {
            return Double(stringValue)
        }

        return nil
    }

    func extractCurrency(from properties: [String: Any], key: String) -> String {
        // Case-insensitive search for currency key
        for (propertyKey, value) in properties {
            if propertyKey.caseInsensitiveCompare(key) == .orderedSame {
                return String(describing: value)
            }
        }
        return "USD" // Default currency
    }
}
