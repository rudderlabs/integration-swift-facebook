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
    var userID: String? { get set }
    func clearUserData()
    func setUserData(_ value: String, forType: FBSDKAppEventUserDataType)
    func logEvent(_ name: AppEvents.Name, valueToSum: Double, parameters: [AppEvents.ParameterName: Any])
    func logEvent(_ name: AppEvents.Name, parameters: [AppEvents.ParameterName: Any])
    func logPurchase(amount: Double, currency: String, parameters: [AppEvents.ParameterName: Any])
    func getAppEventsInstance() -> Any?
}

// MARK: Actual Implementation
class DefaultFacebookAppEventsAdapter: FacebookAppEventsAdapter {
    var userID: String? {
        get {
            return AppEvents.shared.userID
        }
        set {
            AppEvents.shared.userID = newValue
        }
    }
    
    func clearUserData() {
        AppEvents.shared.clearUserData()
    }
    
    func setUserData(_ value: String, forType: FBSDKAppEventUserDataType) {
        AppEvents.shared.setUserData(value, forType: forType)
    }
    
    func logEvent(_ name: AppEvents.Name, valueToSum: Double, parameters: [AppEvents.ParameterName: Any]) {
        AppEvents.shared.logEvent(name, valueToSum: valueToSum, parameters: parameters)
    }
    
    func logEvent(_ name: AppEvents.Name, parameters: [AppEvents.ParameterName: Any]) {
        AppEvents.shared.logEvent(name, parameters: parameters)
    }
    
    func logPurchase(amount: Double, currency: String, parameters: [AppEvents.ParameterName: Any]) {
        AppEvents.shared.logPurchase(amount: amount, currency: currency, parameters: parameters)
    }
    
    func getAppEventsInstance() -> Any? {
        return AppEvents.shared
    }
}
