//
//  FacebookAppEventsAdapter.swift
//  RudderIntegrationFacebook
//
//  Created by RudderStack on 12/11/25.
//

import Foundation
import FacebookCore

/**
 * Protocol to wrap Facebook AppEvents.
 */
protocol FacebookAppEventsAdapter {
    var appEventsInstance: Any? { get set }
    var userID: String? { get set }
    func clearUserData()
    func setUserData(_ value: String, forType: FBSDKAppEventUserDataType)
    func logEvent(_ name: AppEvents.Name, valueToSum: Double, parameters: [AppEvents.ParameterName: Any])
    func logEvent(_ name: AppEvents.Name, parameters: [AppEvents.ParameterName: Any])
    func logPurchase(amount: Double, currency: String, parameters: [AppEvents.ParameterName: Any])
    func provideAppEventsInstance() -> Any
}

// MARK: Actual Implementation
class DefaultFacebookAppEventsAdapter: FacebookAppEventsAdapter {
    var appEventsInstance: Any?
    
    private var appEvents: AppEvents? {
        return appEventsInstance as? AppEvents
    }
    
    var userID: String? {
        get {
            return appEvents?.userID
        }
        set {
            appEvents?.userID = newValue
        }
    }

    func clearUserData() {
        appEvents?.clearUserData()
    }

    func setUserData(_ value: String, forType: FBSDKAppEventUserDataType) {
        appEvents?.setUserData(value, forType: forType)
    }

    func logEvent(_ name: AppEvents.Name, valueToSum: Double, parameters: [AppEvents.ParameterName: Any]) {
        appEvents?.logEvent(name, valueToSum: valueToSum, parameters: parameters)
    }

    func logEvent(_ name: AppEvents.Name, parameters: [AppEvents.ParameterName: Any]) {
        appEvents?.logEvent(name, parameters: parameters)
    }

    func logPurchase(amount: Double, currency: String, parameters: [AppEvents.ParameterName: Any]) {
        appEvents?.logPurchase(amount: amount, currency: currency, parameters: parameters)
    }

    func provideAppEventsInstance() -> Any {
        return AppEvents.shared
    }
}
