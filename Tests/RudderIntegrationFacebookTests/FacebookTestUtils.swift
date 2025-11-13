//
//  FacebookTestUtils.swift
//  integration-swift-facebook
//
//  Created by Vishal Gupta on 12/11/25.
//

import Foundation
import FacebookCore
@testable import RudderIntegrationFacebook

/**
 * Mock implementation for FacebookAppEventsAdapter
 */
class MockFacebookAppEventsAdapter: FacebookAppEventsAdapter {
    var userID: String?
    var clearUserDataCalled = false
    var setUserDataCalls: [(value: String, type: FBSDKAppEventUserDataType)] = []
    var logEventCalls: [(name: String, valueToSum: Double?, parameters: [String: Any])] = []
    var logPurchaseCalls: [(amount: Double, currency: String, parameters: [String: Any])] = []

    func clearUserData() {
        clearUserDataCalled = true
    }

    func setUserData(_ value: String, forType: FBSDKAppEventUserDataType) {
        setUserDataCalls.append((value: value, type: forType))
    }

    func logEvent(_ name: AppEvents.Name, valueToSum: Double, parameters: [AppEvents.ParameterName: Any]) {
        let paramDict = parameters.reduce(into: [String: Any]()) { result, param in
            result[param.key.rawValue] = param.value
        }
        logEventCalls.append((name: name.rawValue, valueToSum: valueToSum, parameters: paramDict))
    }

    func logEvent(_ name: AppEvents.Name, parameters: [AppEvents.ParameterName: Any]) {
        let paramDict = parameters.reduce(into: [String: Any]()) { result, param in
            result[param.key.rawValue] = param.value
        }
        logEventCalls.append((name: name.rawValue, valueToSum: nil, parameters: paramDict))
    }

    func logPurchase(amount: Double, currency: String, parameters: [AppEvents.ParameterName: Any]) {
        let paramDict = parameters.reduce(into: [String: Any]()) { result, param in
            result[param.key.rawValue] = param.value
        }
        logPurchaseCalls.append((amount: amount, currency: currency, parameters: paramDict))
    }

    func getAppEventsInstance() -> Any? {
        return "MockAppEventsInstance"
    }
}

/**
 * Mock implementation for FacebookSettingsAdapter
 */
class MockFacebookSettingsAdapter: FacebookSettingsAdapter {
    var setDataProcessingOptionsCalls: [(options: [String], country: Int32?, state: Int32?)] = []

    func setDataProcessingOptions(_ options: [String]) {
        setDataProcessingOptionsCalls.append((options: options, country: nil, state: nil))
    }

    func setDataProcessingOptions(_ options: [String], country: Int32, state: Int32) {
        setDataProcessingOptionsCalls.append((options: options, country: country, state: state))
    }
}

extension Dictionary where Key == String {
    static func + (lhs: [Key: Value], rhs: [Key: Value]) -> [Key: Value] {
        return lhs.merging(rhs) { (_, new) in new }
    }
}
