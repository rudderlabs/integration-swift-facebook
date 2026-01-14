//
//  ObjCFacebookIntegration.swift
//  RudderIntegrationFacebook
//
//  Created by RudderStack on 11/01/26.
//

import Foundation
import RudderStackAnalytics

// MARK: - ObjCFacebookIntegration
/**
 An Objective-C compatible wrapper for the Facebook Integration.

 This class provides an Objective-C interface to the Facebook integration,
 allowing Objective-C apps to use the Facebook App Events device mode integration with RudderStack.

 ## Usage in Objective-C:
 ```objc
 RSSConfigurationBuilder *builder = [[RSSConfigurationBuilder alloc] initWithWriteKey:@"<WriteKey>"
                                                          dataPlaneUrl:@"<DataPlaneUrl>"];
 RSSAnalytics *analytics = [[RSSAnalytics alloc] initWithConfiguration:[builder build]];

 RSSFacebookIntegration *facebookIntegration = [[RSSFacebookIntegration alloc] init];
 [analytics addPlugin:facebookIntegration];
 ```
 */
@objc(RSSFacebookIntegration)
public class ObjCFacebookIntegration: NSObject, ObjCIntegrationPlugin, ObjCStandardIntegration {

    // MARK: - ObjCPlugin Properties

    public var pluginType: PluginType {
        get { facebookIntegration.pluginType }
        set { facebookIntegration.pluginType = newValue }
    }

    // MARK: - ObjCIntegrationPlugin Properties

    public var key: String {
        get { facebookIntegration.key }
        set { facebookIntegration.key = newValue }
    }

    // MARK: - Private Properties

    private let facebookIntegration: FacebookIntegration

    // MARK: - Initializers

    /**
     Initializes a new Facebook integration instance.

     Use this initializer to create a Facebook integration that can be added to the analytics client.
     */
    @objc
    public override init() {
        self.facebookIntegration = FacebookIntegration()
        super.init()
    }

    // MARK: - ObjCIntegrationPlugin Methods

    /**
     Returns the Facebook App Events SDK instance.

     - Returns: The Facebook App Events SDK instance, or nil if not initialized.
     */
    @objc
    public func getDestinationInstance() -> Any? {
        return facebookIntegration.getDestinationInstance()
    }

    /**
     Creates and configures the Facebook SDK with the provided destination configuration.

     - Parameters:
        - destinationConfig: Configuration dictionary from RudderStack dashboard.
        - errorPointer: A pointer to an NSError that will be set if initialization fails.
     - Returns: `true` if initialization succeeded, `false` otherwise.
     */
    @objc
    public func createWithDestinationConfig(_ destinationConfig: [String: Any], error errorPointer: NSErrorPointer) -> Bool {
        do {
            try facebookIntegration.create(destinationConfig: destinationConfig)
            return true
        } catch let err as NSError {
            errorPointer?.pointee = err
            return false
        } catch {
            errorPointer?.pointee = NSError(
                domain: "com.rudderstack.FacebookIntegration",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: error.localizedDescription]
            )
            return false
        }
    }

    /**
     Updates the Facebook SDK configuration with the provided destination configuration.

     - Parameters:
        - destinationConfig: Updated configuration dictionary from RudderStack dashboard.
        - errorPointer: A pointer to an NSError that will be set if update fails.
     - Returns: `true` if update succeeded, `false` otherwise.
     */
    @objc
    public func updateWithDestinationConfig(_ destinationConfig: [String: Any], error errorPointer: NSErrorPointer) -> Bool {
        do {
            try facebookIntegration.update(destinationConfig: destinationConfig)
            return true
        } catch let err as NSError {
            errorPointer?.pointee = err
            return false
        } catch {
            errorPointer?.pointee = NSError(
                domain: "com.rudderstack.FacebookIntegration",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: error.localizedDescription]
            )
            return false
        }
    }

    /**
     Resets the integration state.

     This clears the user ID and user data from Facebook App Events.
     */
    @objc
    public func reset() {
        facebookIntegration.reset()
    }

    // MARK: - ObjCEventPlugin Methods

    /**
     Processes a track event and forwards it to the underlying Facebook integration.

     - Parameter payload: The ObjC track event payload.
     */
    @objc
    public func track(_ payload: ObjCTrackEvent) {
        var trackEvent = TrackEvent(
            event: payload.eventName,
            properties: payload.properties,
            options: payload.options
        )
        trackEvent.anonymousId = payload.anonymousId
        trackEvent.userId = payload.userId

        facebookIntegration.track(payload: trackEvent)
    }

    /**
     Processes an identify event and forwards it to the underlying Facebook integration.

     - Parameter payload: The ObjC identify event payload.
     */
    @objc
    public func identify(_ payload: ObjCIdentifyEvent) {
        var identifyEvent = IdentifyEvent(options: payload.options)
        identifyEvent.anonymousId = payload.anonymousId
        identifyEvent.userId = payload.userId

        facebookIntegration.identify(payload: identifyEvent)
    }

    /**
     Processes a screen event and forwards it to the underlying Facebook integration.

     - Parameter payload: The ObjC screen event payload.
     */
    @objc
    public func screen(_ payload: ObjCScreenEvent) {
        var screenEvent = ScreenEvent(
            screenName: payload.screenName,
            category: payload.category,
            properties: payload.properties,
            options: payload.options
        )
        screenEvent.anonymousId = payload.anonymousId
        screenEvent.userId = payload.userId

        facebookIntegration.screen(payload: screenEvent)
    }
}
