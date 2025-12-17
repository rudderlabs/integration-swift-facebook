//
//  FacebookSettingsAdapter.swift
//  RudderIntegrationFacebook
//
//  Created by RudderStack on 12/11/25.
//

import Foundation
import FacebookCore

/**
 * Protocol to wrap Facebook Settings.
 */
protocol FacebookSettingsAdapter {
    func setDataProcessingOptions(_ options: [String])
    func setDataProcessingOptions(_ options: [String], country: Int32, state: Int32)
}

// MARK: Actual Implementation
class DefaultFacebookSettingsAdapter: FacebookSettingsAdapter {
    func setDataProcessingOptions(_ options: [String]) {
        Settings.shared.setDataProcessingOptions(options)
    }

    func setDataProcessingOptions(_ options: [String], country: Int32, state: Int32) {
        Settings.shared.setDataProcessingOptions(options, country: country, state: state)
    }
}
