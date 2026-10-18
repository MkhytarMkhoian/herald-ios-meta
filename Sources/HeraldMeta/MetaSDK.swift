import FBSDKCoreKit
import Foundation

/// The Meta calls this module makes, so the tests can record them instead: ``LiveMetaSDK`` in the
/// app, a recorder in the tests.
protocol MetaSDK: Sendable {
    func logEvent(_ name: String, parameters: [AppEvents.ParameterName: Any])
    func logPurchase(amount: Double, currency: String, parameters: [AppEvents.ParameterName: Any])
    func setUserID(_ userID: String?)
    func flush()
    func setCollectionEnabled(_ enabled: Bool)
}

/// Calls Meta's shared `AppEvents` and `Settings`.
struct LiveMetaSDK: MetaSDK {
    func logEvent(_ name: String, parameters: [AppEvents.ParameterName: Any]) {
        AppEvents.shared.logEvent(AppEvents.Name(name), parameters: parameters)
    }

    func logPurchase(amount: Double, currency: String, parameters: [AppEvents.ParameterName: Any]) {
        AppEvents.shared.logPurchase(amount: amount, currency: currency, parameters: parameters)
    }

    func setUserID(_ userID: String?) {
        AppEvents.shared.userID = userID
    }

    func flush() {
        AppEvents.shared.flush()
    }

    func setCollectionEnabled(_ enabled: Bool) {
        Settings.shared.isAutoLogAppEventsEnabled = enabled
        Settings.shared.isAdvertiserIDCollectionEnabled = enabled
    }
}
