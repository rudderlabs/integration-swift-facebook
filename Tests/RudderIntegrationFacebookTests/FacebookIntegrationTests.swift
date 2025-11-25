import Testing
import RudderStackAnalytics
import FacebookCore
@testable import RudderIntegrationFacebook

struct FacebookIntegrationTests {

    @Test("given destination config with limitedDataUse disabled, when integration is created, then data processing options are cleared")
    func testCreateLimitedDataUseDisabled() throws {
        let (integration, _, mockSettings) = createIntegrationWithMocks()

        let config: [String: Any] = [
            "limitedDataUse": false,
            "dpoState": 0,
            "dpoCountry": 0
        ]

        try integration.create(destinationConfig: config)

        #expect(mockSettings.setDataProcessingOptionsCalls.count == 1)
        let call = mockSettings.setDataProcessingOptionsCalls[0]
        #expect(call.options.isEmpty)
        #expect(call.country == nil)
        #expect(call.state == nil)
    }

    @Test("given destination config with limitedDataUse enabled, when integration is created, then data processing options are set correctly")
    func testCreateLimitedDataUseEnabled() throws {
        let (integration, _, mockSettings) = createIntegrationWithMocks()

        let config: [String: Any] = [
            "limitedDataUse": true,
            "dpoState": 1000,
            "dpoCountry": 1
        ]

        try integration.create(destinationConfig: config)

        #expect(mockSettings.setDataProcessingOptionsCalls.count == 1)
        let call = mockSettings.setDataProcessingOptionsCalls[0]
        #expect(call.options == ["LDU"])
        #expect(call.country == 1)
        #expect(call.state == 1000)
    }

    @Test("given destination config with invalid dpoState, when integration is created, then dpoState is validated to 0")
    func testCreateInvalidDpoState() throws {
        let (integration, _, mockSettings) = createIntegrationWithMocks()

        let config: [String: Any] = [
            "limitedDataUse": true,
            "dpoState": 500,  // Invalid value
            "dpoCountry": 1
        ]

        try integration.create(destinationConfig: config)

        #expect(mockSettings.setDataProcessingOptionsCalls.count == 1)
        let call = mockSettings.setDataProcessingOptionsCalls[0]
        #expect(call.options == ["LDU"])
        #expect(call.country == 1)
        #expect(call.state == 0)  // Should be validated to 0
    }

    @Test("given destination config with invalid dpoCountry, when integration is created, then dpoCountry is validated to 0")
    func testCreateInvalidDpoCountry() throws {
        let (integration, _, mockSettings) = createIntegrationWithMocks()

        let config: [String: Any] = [
            "limitedDataUse": true,
            "dpoState": 1000,
            "dpoCountry": 5  // Invalid value
        ]

        try integration.create(destinationConfig: config)

        #expect(mockSettings.setDataProcessingOptionsCalls.count == 1)
        let call = mockSettings.setDataProcessingOptionsCalls[0]
        #expect(call.options == ["LDU"])
        #expect(call.country == 0)  // Should be validated to 0
        #expect(call.state == 1000)
    }

    @Test("given integration is created, when getDestinationInstance is called, then returns app events instance")
    func testGetDestinationInstance() throws {
        let (integration, mockAppEvents, _) = createIntegrationWithMocks()

        // Before create is called, should return nil
        let instanceBeforeCreate = integration.getDestinationInstance()
        #expect(instanceBeforeCreate == nil)

        let config: [String: Any] = ["limitedDataUse": false]
        try integration.create(destinationConfig: config)

        // After create is called, should return the app events instance
        let instance = integration.getDestinationInstance()
        #expect(instance as? String == "MockAppEventsInstance")
        #expect(mockAppEvents.appEventsInstance as? String == "MockAppEventsInstance")
    }

    @Test("given integration is created multiple times, when create is called, then app events instance is only set once")
    func testCreateMultipleCallsOnlySetInstanceOnce() throws {
        let (integration, mockAppEvents, _) = createIntegrationWithMocks()

        let config: [String: Any] = ["limitedDataUse": false]

        // First call should set the instance
        try integration.create(destinationConfig: config)
        #expect(mockAppEvents.appEventsInstance as? String == "MockAppEventsInstance")

        // Modify the instance to verify it's not overwritten
        mockAppEvents.appEventsInstance = "ModifiedInstance"

        // Second call should not overwrite the instance
        try integration.create(destinationConfig: config)
        #expect(mockAppEvents.appEventsInstance as? String == "ModifiedInstance")
    }

    @Test("given integration config is updated, when update is called, then data processing options are updated")
    func testUpdate() throws {
        let (integration, _, mockSettings) = createIntegrationWithMocks()

        let initialConfig: [String: Any] = ["limitedDataUse": false]
        try integration.create(destinationConfig: initialConfig)

        let updatedConfig: [String: Any] = [
            "limitedDataUse": true,
            "dpoState": 1000,
            "dpoCountry": 1
        ]
        try integration.update(destinationConfig: updatedConfig)

        #expect(mockSettings.setDataProcessingOptionsCalls.count == 2)
        let updateCall = mockSettings.setDataProcessingOptionsCalls[1]
        #expect(updateCall.options == ["LDU"])
        #expect(updateCall.country == 1)
        #expect(updateCall.state == 1000)
    }

    @Test("given integration is reset, when reset is called, then user data is cleared")
    func testReset() throws {
        let (integration, mockAppEvents, _) = createIntegrationWithMocks()

        let config: [String: Any] = ["limitedDataUse": false]
        try integration.create(destinationConfig: config)

        integration.reset()

        #expect(mockAppEvents.userID == nil)
        #expect(mockAppEvents.clearUserDataCalled == true)
    }

    // MARK: - Identify Tests

    @Test("given identify event with userId, when identify is called, then userId is set")
    func testIdentifyWithUserId() {
        let (integration, mockAppEvents, _) = createIntegrationWithMocks()

        let identifyEvent = createIdentifyEvent(userId: "user123")

        integration.identify(payload: identifyEvent)

        #expect(mockAppEvents.userID == "user123")
    }

    @Test("given identify event with all user traits, when identify is called, then all user data is set")
    func testIdentifyWithAllTraits() {
        let (integration, mockAppEvents, _) = createIntegrationWithMocks()

        let address: [String: Any] = [
            "city": "San Francisco",
            "state": "CA",
            "postalcode": "94105",
            "country": "USA"
        ]

        let traits: [String: Any] = [
            "email": "test@example.com",
            "firstName": "John",
            "lastName": "Doe",
            "phone": "+1234567890",
            "birthday": "1990-01-01",
            "gender": "male",
            "address": address
        ]

        let identifyEvent = createIdentifyEvent(userId: "user123", traits: traits)

        integration.identify(payload: identifyEvent)

        #expect(mockAppEvents.userID == "user123")

        let expectedCalls: [(String, FBSDKAppEventUserDataType)] = [
            ("test@example.com", .email),
            ("John", .firstName),
            ("Doe", .lastName),
            ("+1234567890", .phone),
            ("1990-01-01", .dateOfBirth),
            ("male", .gender),
            ("San Francisco", .city),
            ("CA", .state),
            ("94105", .zip),
            ("USA", .country)
        ]

        #expect(mockAppEvents.setUserDataCalls.count == expectedCalls.count)

        for (expectedValue, expectedType) in expectedCalls {
            let found = mockAppEvents.setUserDataCalls.contains { call in
                call.value == expectedValue && call.type == expectedType
            }
            #expect(found, "Expected setUserData call with value: \(expectedValue), type: \(expectedType)")
        }
    }

    @Test("given identify event with no traits, when identify is called, then only userId is set")
    func testIdentifyWithNoTraits() {
        let (integration, mockAppEvents, _) = createIntegrationWithMocks()

        let identifyEvent = createIdentifyEvent(userId: "user123")

        integration.identify(payload: identifyEvent)

        #expect(mockAppEvents.userID == "user123")
        #expect(mockAppEvents.setUserDataCalls.isEmpty)
    }

    @Test("given identify event with partial address, when identify is called, then only available address fields are set")
    func testIdentifyWithPartialAddress() {
        let (integration, mockAppEvents, _) = createIntegrationWithMocks()

        let address: [String: Any] = [
            "city": "New York",
            "postalcode": "10001"
            // Missing state and country
        ]

        let traits: [String: Any] = [
            "email": "test@example.com",
            "address": address
        ]

        let identifyEvent = createIdentifyEvent(userId: "user123", traits: traits)

        integration.identify(payload: identifyEvent)

        #expect(mockAppEvents.userID == "user123")

        let addressCalls = mockAppEvents.setUserDataCalls.filter { call in
            [FBSDKAppEventUserDataType.city, .state, .zip, .country].contains(call.type)
        }

        #expect(addressCalls.count == 2) // Only city and zip

        let cityCall = addressCalls.first { $0.type == .city }
        #expect(cityCall?.value == "New York")

        let zipCall = addressCalls.first { $0.type == .zip }
        #expect(zipCall?.value == "10001")
    }

    // MARK: - Track Tests - Standard Events

    @Test("given track event for products searched, when track is called, then Facebook searched event is logged")
    func testTrackProductsSearched() {
        let (integration, mockAppEvents, _) = createIntegrationWithMocks()

        let properties: [String: Any] = [
            "query": "shoes",
            "category": "footwear"
        ]
        let trackEvent = createTrackEvent(name: ECommerceEvents.productsSearched, properties: properties)

        integration.track(payload: trackEvent)

        #expect(mockAppEvents.logEventCalls.count == 1)
        let call = mockAppEvents.logEventCalls[0]
        #expect(call.name == AppEvents.Name.searched.rawValue)
        #expect(call.valueToSum == nil)
        #expect(call.parameters[AppEvents.ParameterName.searchString.rawValue] as? String == "shoes")
        #expect(call.parameters["category"] as? String == "footwear")
    }

    @Test("given track event for product viewed with price, when track is called, then Facebook viewed content event is logged with valueToSum")
    func testTrackProductViewedWithPrice() {
        let (integration, mockAppEvents, _) = createIntegrationWithMocks()

        let properties: [String: Any] = [
            ECommerceParamNames.productId: "prod123",
            ECommerceParamNames.price: 99.99,
            ECommerceParamNames.currency: "USD"
        ]
        let trackEvent = createTrackEvent(name: ECommerceEvents.productViewed, properties: properties)

        integration.track(payload: trackEvent)

        #expect(mockAppEvents.logEventCalls.count == 1)
        let call = mockAppEvents.logEventCalls[0]
        #expect(call.name == AppEvents.Name.viewedContent.rawValue)
        #expect(call.valueToSum == 99.99)
        #expect(call.parameters[AppEvents.ParameterName.contentID.rawValue] as? String == "prod123")
        #expect(call.parameters[AppEvents.ParameterName.currency.rawValue] as? String == "USD")
    }

    @Test("given track event for product added to cart, when track is called, then Facebook added to cart event is logged")
    func testTrackProductAdded() {
        let (integration, mockAppEvents, _) = createIntegrationWithMocks()

        let properties: [String: Any] = [
            ECommerceParamNames.productId: "prod456",
            ECommerceParamNames.price: 149.99,
            "quantity": 2
        ]
        let trackEvent = createTrackEvent(name: ECommerceEvents.productAdded, properties: properties)

        integration.track(payload: trackEvent)

        #expect(mockAppEvents.logEventCalls.count == 1)
        let call = mockAppEvents.logEventCalls[0]
        #expect(call.name == AppEvents.Name.addedToCart.rawValue)
        #expect(call.valueToSum == 149.99)
        #expect(call.parameters[AppEvents.ParameterName.contentID.rawValue] as? String == "prod456")
        #expect(call.parameters["quantity"] as? NSNumber == 2)
    }

    @Test("given track event for product added to wishlist, when track is called, then Facebook added to wishlist event is logged")
    func testTrackProductAddedToWishlist() {
        let (integration, mockAppEvents, _) = createIntegrationWithMocks()

        let properties: [String: Any] = [
            ECommerceParamNames.productId: "wish123",
            ECommerceParamNames.price: 79.99
        ]
        let trackEvent = createTrackEvent(name: ECommerceEvents.productAddedToWishList, properties: properties)

        integration.track(payload: trackEvent)

        #expect(mockAppEvents.logEventCalls.count == 1)
        let call = mockAppEvents.logEventCalls[0]
        #expect(call.name == AppEvents.Name.addedToWishlist.rawValue)
        #expect(call.valueToSum == 79.99)
        #expect(call.parameters[AppEvents.ParameterName.contentID.rawValue] as? String == "wish123")
    }

    @Test("given track event for checkout started with value, when track is called, then Facebook initiated checkout event is logged")
    func testTrackCheckoutStarted() {
        let (integration, mockAppEvents, _) = createIntegrationWithMocks()

        let properties: [String: Any] = [
            "value": 299.97,
            ECommerceParamNames.currency: "EUR",
            ECommerceParamNames.orderId: "order789"
        ]
        let trackEvent = createTrackEvent(name: ECommerceEvents.checkoutStarted, properties: properties)

        integration.track(payload: trackEvent)

        #expect(mockAppEvents.logEventCalls.count == 1)
        let call = mockAppEvents.logEventCalls[0]
        #expect(call.name == AppEvents.Name.initiatedCheckout.rawValue)
        #expect(call.valueToSum == 299.97)
        #expect(call.parameters[AppEvents.ParameterName.orderID.rawValue] as? String == "order789")
        #expect(call.parameters[AppEvents.ParameterName.currency.rawValue] as? String == "EUR")
    }

    @Test("given track event for order completed with revenue, when track is called, then Facebook purchase event is logged")
    func testTrackOrderCompletedWithRevenue() {
        let (integration, mockAppEvents, _) = createIntegrationWithMocks()

        let properties: [String: Any] = [
            ECommerceParamNames.revenue: 199.99,
            ECommerceParamNames.currency: "GBP",
            ECommerceParamNames.orderId: "order456"
        ]
        let trackEvent = createTrackEvent(name: ECommerceEvents.orderCompleted, properties: properties)

        integration.track(payload: trackEvent)

        #expect(mockAppEvents.logEventCalls.isEmpty) // Should use logPurchase instead
        #expect(mockAppEvents.logPurchaseCalls.count == 1)

        let purchaseCall = mockAppEvents.logPurchaseCalls[0]
        #expect(purchaseCall.amount == 199.99)
        #expect(purchaseCall.currency == "GBP")
        #expect(purchaseCall.parameters[AppEvents.ParameterName.orderID.rawValue] as? String == "order456")
    }

    @Test("given track event for order completed without revenue, when track is called, then regular Facebook event is logged")
    func testTrackOrderCompletedWithoutRevenue() {
        let (integration, mockAppEvents, _) = createIntegrationWithMocks()

        let properties: [String: Any] = [
            ECommerceParamNames.orderId: "order789"
        ]
        let trackEvent = createTrackEvent(name: ECommerceEvents.orderCompleted, properties: properties)

        integration.track(payload: trackEvent)

        #expect(mockAppEvents.logPurchaseCalls.isEmpty) // No revenue, so no purchase call
        #expect(mockAppEvents.logEventCalls.count == 1)

        let call = mockAppEvents.logEventCalls[0]
        #expect(call.name == "Order Completed")
        #expect(call.valueToSum == nil)
        #expect(call.parameters[AppEvents.ParameterName.orderID.rawValue] as? String == "order789")
    }

    @Test("given track event for payment info entered, when track is called, then Facebook added payment info event is logged")
    func testTrackPaymentInfoEntered() {
        let (integration, mockAppEvents, _) = createIntegrationWithMocks()

        let properties: [String: Any] = [
            "payment_method": "credit_card"
        ]
        let trackEvent = createTrackEvent(name: ECommerceEvents.paymentInfoEntered, properties: properties)

        integration.track(payload: trackEvent)

        #expect(mockAppEvents.logEventCalls.count == 1)
        let call = mockAppEvents.logEventCalls[0]
        #expect(call.name == AppEvents.Name.addedPaymentInfo.rawValue)
        #expect(call.valueToSum == nil)
        #expect(call.parameters["payment_method"] as? String == "credit_card")
    }

    @Test("given track event with standard event properties, when track is called, then properties are mapped correctly")
    func testTrackStandardEventProperties() {
        let (integration, mockAppEvents, _) = createIntegrationWithMocks()

        let properties: [String: Any] = [
            ECommerceParamNames.productId: "prod123",
            ECommerceParamNames.rating: 5,
            "name": "Product Name",
            ECommerceParamNames.orderId: "order456",
            ECommerceParamNames.currency: "USD",
            "description": "Product description",
            ECommerceParamNames.query: "search term"
        ]
        let trackEvent = createTrackEvent(name: ECommerceEvents.productViewed, properties: properties)

        integration.track(payload: trackEvent)

        #expect(mockAppEvents.logEventCalls.count == 1)
        let call = mockAppEvents.logEventCalls[0]

        #expect(call.parameters[AppEvents.ParameterName.contentID.rawValue] as? String == "prod123")
        #expect(call.parameters[AppEvents.ParameterName.maxRatingValue.rawValue] as? NSNumber == 5)
        #expect(call.parameters[AppEvents.ParameterName.adType.rawValue] as? String == "Product Name")
        #expect(call.parameters[AppEvents.ParameterName.orderID.rawValue] as? String == "order456")
        #expect(call.parameters[AppEvents.ParameterName.currency.rawValue] as? String == "USD")
        #expect(call.parameters[AppEvents.ParameterName.description.rawValue] as? String == "Product description")
        #expect(call.parameters[AppEvents.ParameterName.searchString.rawValue] as? String == "search term")
    }

    @Test("given track event for other standard events, when track is called, then appropriate Facebook events are logged")
    func testTrackOtherStandardEvents() {
        let (integration, mockAppEvents, _) = createIntegrationWithMocks()

        let testCases: [(String, String)] = [
            ("Complete Registration", AppEvents.Name.completedRegistration.rawValue),
            ("Achieve Level", AppEvents.Name.achievedLevel.rawValue),
            ("Complete Tutorial", AppEvents.Name.completedTutorial.rawValue),
            ("Unlock Achievement", AppEvents.Name.unlockedAchievement.rawValue),
            ("Subscribe", AppEvents.Name.subscribe.rawValue),
            ("Start Trial", AppEvents.Name.startTrial.rawValue),
            (ECommerceEvents.promotionClicked, AppEvents.Name.adClick.rawValue),
            (ECommerceEvents.promotionViewed, AppEvents.Name.adImpression.rawValue),
            ("Spend Credits", AppEvents.Name.spentCredits.rawValue),
            (ECommerceEvents.productReviewed, AppEvents.Name.rated.rawValue)
        ]

        for (eventName, expectedFbEvent) in testCases {
            mockAppEvents.logEventCalls.removeAll()

            let trackEvent = createTrackEvent(name: eventName)
            integration.track(payload: trackEvent)

            #expect(mockAppEvents.logEventCalls.count == 1, "Failed for event: \(eventName)")
            #expect(mockAppEvents.logEventCalls[0].name == expectedFbEvent, "Failed mapping for event: \(eventName)")
        }
    }

    @Test("given track event with custom event name, when track is called, then custom event is logged")
    func testTrackCustomEvent() {
        let (integration, mockAppEvents, _) = createIntegrationWithMocks()

        let properties: [String: Any] = [
            "custom_property": "custom_value",
            "number_property": 42
        ]
        let trackEvent = createTrackEvent(name: "Custom Event", properties: properties)

        integration.track(payload: trackEvent)

        #expect(mockAppEvents.logEventCalls.count == 1)
        let call = mockAppEvents.logEventCalls[0]
        #expect(call.name == "Custom Event")
        #expect(call.valueToSum == nil)
        #expect(call.parameters["custom_property"] as? String == "custom_value")
        #expect(call.parameters["number_property"] as? NSNumber == 42)
    }

    @Test("given track event with event name exceeding 40 characters, when track is called, then event name is truncated")
    func testTrackLongEventName() {
        let (integration, mockAppEvents, _) = createIntegrationWithMocks()

        let longEventName = "This is a very long event name that exceeds forty characters"
        let expectedTruncatedName = String(longEventName.prefix(40))

        let trackEvent = createTrackEvent(name: longEventName)

        integration.track(payload: trackEvent)

        #expect(mockAppEvents.logEventCalls.count == 1)
        let call = mockAppEvents.logEventCalls[0]
        #expect(call.name == expectedTruncatedName)
    }

    @Test("given track event with empty event name, when track is called, then event is dropped")
    func testTrackEmptyEventName() {
        let (integration, mockAppEvents, _) = createIntegrationWithMocks()

        let trackEvent = createTrackEvent(name: "")

        integration.track(payload: trackEvent)

        #expect(mockAppEvents.logEventCalls.isEmpty)
    }

    @Test("given track event with reserved keywords, when track is called, then reserved keywords are filtered out")
    func testTrackReservedKeywords() {
        let (integration, mockAppEvents, _) = createIntegrationWithMocks()

        let properties: [String: Any] = [
            ECommerceParamNames.productId: "prod123", // Reserved keyword - should be filtered
            "name": "Product Name", // Reserved keyword - should be filtered
            "custom_property": "custom_value", // Not reserved - should be included
            ECommerceParamNames.price: 99.99 // Reserved keyword - should be filtered
        ]
        let trackEvent = createTrackEvent(name: "Custom Event", properties: properties)

        integration.track(payload: trackEvent)

        #expect(mockAppEvents.logEventCalls.count == 1)
        let call = mockAppEvents.logEventCalls[0]

        // Should only contain custom_property, reserved keywords should be filtered
        #expect(call.parameters["custom_property"] as? String == "custom_value")
        #expect(call.parameters[ECommerceParamNames.productId] == nil)
        #expect(call.parameters["name"] == nil)
        #expect(call.parameters[ECommerceParamNames.price] == nil)
    }

    @Test("given track event with currency extraction, when track is called, then currency is extracted case-insensitively")
    func testTrackCurrencyExtraction() {
        let (integration, mockAppEvents, _) = createIntegrationWithMocks()

        let properties: [String: Any] = [
            "CURRENCY": "EUR" // Uppercase key
        ]
        let trackEvent = createTrackEvent(name: ECommerceEvents.productViewed, properties: properties)

        integration.track(payload: trackEvent)

        #expect(mockAppEvents.logEventCalls.count == 1)
        let call = mockAppEvents.logEventCalls[0]
        #expect(call.parameters[AppEvents.ParameterName.currency.rawValue] as? String == "EUR")
    }

    @Test("given track event without currency, when track is called, then default USD currency is used")
    func testTrackDefaultCurrency() {
        let (integration, mockAppEvents, _) = createIntegrationWithMocks()

        let trackEvent = createTrackEvent(name: ECommerceEvents.productViewed)

        integration.track(payload: trackEvent)

        #expect(mockAppEvents.logEventCalls.count == 1)
        let call = mockAppEvents.logEventCalls[0]
        #expect(call.parameters[AppEvents.ParameterName.currency.rawValue] as? String == "USD")
    }

    // MARK: - Screen Tests

    @Test("given screen event with screen name, when screen is called, then Facebook event is logged")
    func testScreenWithScreenName() {
        let (integration, mockAppEvents, _) = createIntegrationWithMocks()

        let screenEvent = createScreenEvent(name: "Home")

        integration.screen(payload: screenEvent)

        #expect(mockAppEvents.logEventCalls.count == 1)
        let call = mockAppEvents.logEventCalls[0]
        #expect(call.name == "Viewed Home Screen")
        #expect(call.valueToSum == nil)
        #expect(call.parameters.count == 1)
        #expect(call.parameters["name"] as? String == "Home")
    }

    @Test("given screen event with properties, when screen is called, then properties are included")
    func testScreenWithProperties() {
        let (integration, mockAppEvents, _) = createIntegrationWithMocks()

        let properties: [String: Any] = [
            "section": "main",
            "user_type": "premium",
            ECommerceParamNames.productId: "prod123", // Reserved keyword - should NOT be filtered for screen events
            "count": 5
        ]
        let screenEvent = createScreenEvent(name: "Product Details", properties: properties)

        integration.screen(payload: screenEvent)

        #expect(mockAppEvents.logEventCalls.count == 1)
        let call = mockAppEvents.logEventCalls[0]
        #expect(call.name == "Viewed Product Details Screen")

        // All properties should be included (no filtering for screen events)
        #expect(call.parameters["section"] as? String == "main")
        #expect(call.parameters["user_type"] as? String == "premium")
        #expect(call.parameters[ECommerceParamNames.productId] as? String == "prod123")
        #expect(call.parameters["count"] as? NSNumber == 5)
    }

    @Test("given screen event with long screen name, when screen is called, then screen name is truncated to 26 characters")
    func testScreenLongScreenName() {
        let (integration, mockAppEvents, _) = createIntegrationWithMocks()

        let longScreenName = "This is a very long screen name that exceeds twenty six characters"
        let expectedTruncatedName = String(longScreenName.prefix(26))

        let screenEvent = createScreenEvent(name: longScreenName)

        integration.screen(payload: screenEvent)

        #expect(mockAppEvents.logEventCalls.count == 1)
        let call = mockAppEvents.logEventCalls[0]
        #expect(call.name == "Viewed \(expectedTruncatedName) Screen")
    }

    @Test("given screen event with empty screen name, when screen is called, then event is dropped")
    func testScreenEmptyScreenName() {
        let (integration, mockAppEvents, _) = createIntegrationWithMocks()

        let screenEvent = createScreenEvent(name: "")

        integration.screen(payload: screenEvent)

        #expect(mockAppEvents.logEventCalls.isEmpty)
    }

    // MARK: - Property Handling Tests

    @Test("given properties with various data types, when processed, then types are handled correctly")
    func testPropertyTypeHandling() {
        let (integration, mockAppEvents, _) = createIntegrationWithMocks()

        let properties: [String: Any] = [
            "string_value": "test",
            "int_value": 42,
            "double_value": 3.14,
            "bool_value": true,
            "null_value": NSNull()
        ]
        let trackEvent = createTrackEvent(name: "Type Test", properties: properties)

        integration.track(payload: trackEvent)

        #expect(mockAppEvents.logEventCalls.count == 1)
        let call = mockAppEvents.logEventCalls[0]

        #expect(call.parameters["string_value"] as? String == "test")
        #expect(call.parameters["int_value"] as? NSNumber == 42)
        #expect(call.parameters["double_value"] as? NSNumber == 3.14)
        #expect(call.parameters["bool_value"] as? Bool == true)
        #expect(call.parameters["null_value"] as? String == "<null>") // Converted to string
    }

    @Test("given value extraction for different numeric types, when getValueToSum is called, then correct values are extracted")
    func testValueExtraction() {
        let (integration, mockAppEvents, _) = createIntegrationWithMocks()

        let testCases: [([String: Any], Double?)] = [
            (["price": 99], 99.0),
            (["price": 99.99], 99.99),
            (["price": "123.45"], 123.45),
            (["price": "invalid"], nil),
            (["price": true], 1.0),
            ([:], nil)
        ]

        for (properties, expectedValue) in testCases {
            mockAppEvents.logEventCalls.removeAll()

            let trackEvent = createTrackEvent(name: ECommerceEvents.productViewed, properties: properties)
            integration.track(payload: trackEvent)

            #expect(mockAppEvents.logEventCalls.count == 1)
            let call = mockAppEvents.logEventCalls[0]

            if let expectedValue = expectedValue {
                #expect(call.valueToSum == expectedValue, "Failed for properties: \(properties)")
            } else {
                #expect(call.valueToSum == nil, "Failed for properties: \(properties)")
            }
        }
    }
}

extension FacebookIntegrationTests {

    private func createIntegrationWithMocks() -> (FacebookIntegration, MockFacebookAppEventsAdapter, MockFacebookSettingsAdapter) {
        let mockAppEvents = MockFacebookAppEventsAdapter()
        let mockSettings = MockFacebookSettingsAdapter()
        let integration = FacebookIntegration(
            appEventsAdapter: mockAppEvents,
            settingsAdapter: mockSettings
        )
        return (integration, mockAppEvents, mockSettings)
    }

    private func createIdentifyEvent(userId: String? = nil, traits: [String: Any]? = nil) -> IdentifyEvent {
        var event = IdentifyEvent()
        event.userId = userId
        event.context = event.context ?? [:] + (["traits": traits ?? [:]].mapValues { AnyCodable($0) })

        return event
    }

    private func createTrackEvent(name: String, properties: [String: Any]? = nil) -> TrackEvent {
        return TrackEvent(event: name, properties: properties)
    }

    private func createScreenEvent(name: String, properties: [String: Any]? = nil) -> ScreenEvent {
        return ScreenEvent(screenName: name, properties: properties)
    }
}
