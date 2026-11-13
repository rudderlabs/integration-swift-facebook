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

    init(
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
    private let trackReservedKeywords: [String] = [
        ECommerceParamNames.productId, ECommerceParamNames.rating, "name", ECommerceParamNames.orderId, ECommerceParamNames.currency,
        "description", ECommerceParamNames.query, "value", ECommerceParamNames.price, ECommerceParamNames.revenue
    ]

    // MARK: - IntegrationPlugin Required Methods

    public func getDestinationInstance() -> Any? {
        return appEventsAdapter.appEventsInstance
    }

    public func create(destinationConfig: [String: Any]) throws {
        if appEventsAdapter.appEventsInstance == nil {
            appEventsAdapter.appEventsInstance = appEventsAdapter.provideAppEventsInstance()
        }
        configureDataProcessingOptions(from: destinationConfig, isUpdate: false)
    }

    // MARK: - Optional IntegrationPlugin Methods

    public func update(destinationConfig: [String: Any]) throws {
        // The SDK sends an empty config when the destination is disabled; clearing LDU then would lift a privacy setting.
        guard !destinationConfig.isEmpty else {
            LoggerAnalytics.debug("FacebookIntegration: Empty destination config, keeping the current data processing options")
            return
        }
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

        // extract the traits dictionary
        guard let traits = (payload.context?["traits"] as? AnyCodable)?.value as? [String: Any] else {
            LoggerAnalytics.debug("FacebookIntegration: No traits found in identify event - skipping user data update")
            return
        }

        // Set user data properties
        setUserData(from: traits, mapping: Self.traitUserDataTypes)

        // Handle address properties
        if let address = traits["address"] as? [String: Any] {
            setUserData(from: address, mapping: Self.addressUserDataTypes)
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
        let truncatedEvent = String(eventName.prefix(Self.maxEventNameLength))
        let facebookEventName = getFacebookEventName(truncatedEvent)

        // Get properties dictionary
        let properties = payload.properties?.dictionary?.rawDictionary ?? [:]

        // Create parameters dictionary for custom properties
        let customParams = handleCustomProperties(properties: properties, isScreenEvent: false)

        // Handle different Facebook standard events
        switch facebookEventName {
        case AppEvents.Name.addedToCart.rawValue,
             AppEvents.Name.addedToWishlist.rawValue,
             AppEvents.Name.viewedContent.rawValue:
            let standardParams = handleStandardProperties(properties: properties, eventName: facebookEventName)
            if let price = getValueToSum(from: properties, key: ECommerceParamNames.price) {
                appEventsAdapter.logEvent(AppEvents.Name(rawValue: facebookEventName), valueToSum: price, parameters: standardParams + customParams)
                LoggerAnalytics.debug("FacebookIntegration: Logged \"\(facebookEventName)\" to Facebook with price: \(price) and properties: \(properties)")
            } else {
                appEventsAdapter.logEvent(AppEvents.Name(rawValue: facebookEventName), parameters: standardParams + customParams)
                LoggerAnalytics.debug("FacebookIntegration: Logged \"\(facebookEventName)\" to Facebook with properties: \(properties)")
            }

        case AppEvents.Name.initiatedCheckout.rawValue,
             AppEvents.Name.spentCredits.rawValue:
            let standardParams = handleStandardProperties(properties: properties, eventName: facebookEventName)
            if let value = getValueToSum(from: properties, key: "value") {
                appEventsAdapter.logEvent(AppEvents.Name(rawValue: facebookEventName), valueToSum: value, parameters: standardParams + customParams)
                LoggerAnalytics.debug("FacebookIntegration: Logged \"\(facebookEventName)\" to Facebook with value: \(value) and properties: \(properties)")
            } else {
                appEventsAdapter.logEvent(AppEvents.Name(rawValue: facebookEventName), parameters: standardParams + customParams)
                LoggerAnalytics.debug("FacebookIntegration: Logged \"\(facebookEventName)\" to Facebook with properties: \(properties)")
            }

        case "Order Completed": // Special handling for purchases
            let standardParams = handleStandardProperties(properties: properties, eventName: facebookEventName)
            if let revenue = getValueToSum(from: properties, key: ECommerceParamNames.revenue) {
                let currency = extractCurrency(from: properties, key: ECommerceParamNames.currency)
                appEventsAdapter.logPurchase(amount: revenue, currency: currency, parameters: standardParams + customParams)
                LoggerAnalytics.debug("FacebookIntegration: Logged purchase to Facebook with revenue: \(revenue), currency: \(currency) and properties: \(properties)")
            } else {
                appEventsAdapter.logEvent(AppEvents.Name(rawValue: facebookEventName), parameters: standardParams + customParams)
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
            let standardParams = handleStandardProperties(properties: properties, eventName: facebookEventName)
            appEventsAdapter.logEvent(AppEvents.Name(rawValue: facebookEventName), parameters: standardParams + customParams)
            LoggerAnalytics.debug("FacebookIntegration: Logged \"\(facebookEventName)\" to Facebook with properties: \(properties)")

        default:
            // Custom event
            appEventsAdapter.logEvent(AppEvents.Name(rawValue: facebookEventName), parameters: customParams)
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
        let truncatedScreenName = String(screenName.prefix(Self.maxScreenNameLength))
        let eventName = "Viewed \(truncatedScreenName) Screen"

        // Get properties dictionary
        let properties = payload.properties?.dictionary?.rawDictionary ?? [:]

        // Create parameters dictionary - screen events don't skip reserved keywords
        let params = handleCustomProperties(properties: properties, isScreenEvent: true)

        appEventsAdapter.logEvent(AppEvents.Name(rawValue: eventName), parameters: params)

        LoggerAnalytics.debug("FacebookIntegration: Logged screen view \"\(eventName)\" to Facebook with properties: \(properties)")
    }
}

// MARK: - FacebookIntegration Private Methods
private extension FacebookIntegration {

    /// Facebook event names are limited to 40 characters.
    static let maxEventNameLength = 40
    /// "Viewed " and " Screen" take 14 of the 40 characters, so the screen name can be at most 26.
    static let maxScreenNameLength = 26
    /// The only non-zero DPO state Facebook accepts (California).
    static let californiaDpoState = 1000

    /// Identify traits that map to Facebook user data, in the order they are set.
    static let traitUserDataTypes: [(key: String, type: FBSDKAppEventUserDataType)] = [
        ("email", .email), ("firstName", .firstName), ("lastName", .lastName),
        ("phone", .phone), ("birthday", .dateOfBirth), ("gender", .gender)
    ]
    /// Address fields that map to Facebook user data, in the order they are set.
    static let addressUserDataTypes: [(key: String, type: FBSDKAppEventUserDataType)] = [
        ("city", .city), ("state", .state), ("postalcode", .zip), ("country", .country)
    ]

    func setUserData(from values: [String: Any], mapping: [(key: String, type: FBSDKAppEventUserDataType)]) {
        for (key, type) in mapping {
            if let value = values[key] as? String {
                appEventsAdapter.setUserData(value, forType: type)
            }
        }
    }

    func configureDataProcessingOptions(from destinationConfig: [String: Any], isUpdate: Bool) {
        // Extract configuration from destination config
        let limitedDataUse = destinationConfig["limitedDataUse"] as? Bool ?? false
        let dpoState = destinationConfig["dpoState"] as? Int ?? 0
        let dpoCountry = destinationConfig["dpoCountry"] as? Int ?? 0

        // Validate DPO state (0 or 1000 only)
        let validatedDpoState = (dpoState == 0 || dpoState == Self.californiaDpoState) ? dpoState : 0

        // Validate DPO country (0 or 1 only)
        let validatedDpoCountry = (dpoCountry == 0 || dpoCountry == 1) ? dpoCountry : 0

        // Update instance variables
        self.limitedDataUse = limitedDataUse
        self.dpoState = validatedDpoState
        self.dpoCountry = validatedDpoCountry

        // Configure Facebook data processing options
        if self.limitedDataUse {
            settingsAdapter.setDataProcessingOptions(["LDU"], country: Int32(self.dpoCountry), state: Int32(self.dpoState))
            LoggerAnalytics.debug("FacebookIntegration: \(isUpdate ? "Updated data processing options to" : "Set data processing options to") [LDU] with country: \(self.dpoCountry), state: \(self.dpoState)")
        } else {
            settingsAdapter.setDataProcessingOptions([])
            LoggerAnalytics.debug("FacebookIntegration: \(isUpdate ? "Updated data processing options cleared" : "Data processing options cleared") (no LDU restrictions)")
        }

        let successMessage = isUpdate ? "Integration configuration updated successfully" : "Integration initialized successfully"
        LoggerAnalytics.debug("FacebookIntegration: \(successMessage)")
    }

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

    func handleCustomProperties(properties: [String: Any], isScreenEvent: Bool) -> [AppEvents.ParameterName: Any] {
        var params = [AppEvents.ParameterName: Any]()
        for (key, value) in properties {
            // Skip reserved keywords for track events (but not screen events)
            if !isScreenEvent && trackReservedKeywords.contains(key) {
                continue
            }

            let parameterName = AppEvents.ParameterName(rawValue: key)

            // Handle different value types
            switch value {
            case is Int, is Double, is Float, is Bool, is NSNumber:
                params[parameterName] = value

            default:
                params[parameterName] = String(describing: value)
            }
        }
        return params
    }

    func handleStandardProperties(properties: [String: Any], eventName: String) -> [AppEvents.ParameterName: Any] {
        // Map standard ecommerce properties to Facebook parameters
        var params = [AppEvents.ParameterName: Any]()
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
        return params
    }

    func getValueToSum(from properties: [String: Any], key: String) -> Double? {
        guard let value = properties[key] else { return nil }

        switch value {
        case let number as Int:
            return Double(number)

        case let number as Double:
            return number

        case let number as Float:
            return Double(number)

        case let number as NSNumber:
            return number.doubleValue

        case let stringValue as String:
            return Double(stringValue)

        default:
            return nil
        }
    }

    func extractCurrency(from properties: [String: Any], key: String) -> String {
        // Case-insensitive search for currency key
        for (propertyKey, value) in properties where propertyKey.caseInsensitiveCompare(key) == .orderedSame {
            return String(describing: value)
        }
        return "USD" // Default currency
    }
}

extension Dictionary where Key == AppEvents.ParameterName {
    static func + (lhs: [Key: Value], rhs: [Key: Value]) -> [Key: Value] {
        return lhs.merging(rhs) { (_, new) in new }
    }
}
