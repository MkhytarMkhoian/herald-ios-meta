import HeraldCore

/// Meta's start, sign-in and consent.
///
/// `setEnabled` turns Meta's own collection on or off: the events it logs by itself, such as
/// installs, and the advertiser id. It doesn't stop the events your app logs.
///
/// Meta's SDK starts before any Herald code runs, so a fresh install collects nothing by itself
/// only if `Info.plist` turns its automatic collection off: `FacebookAutoLogAppEventsEnabled` and
/// `FacebookAdvertiserIDCollectionEnabled` set to `NO`. `setEnabled` then turns them on or off.
/// Call it with the stored answer on every launch.
public struct MetaAnalyticsService: AnalyticsLifecycleService, IdentifiableUserService,
    ConsentService
{
    private let sdk: any MetaSDK

    public init() {
        self.init(sdk: LiveMetaSDK())
    }

    init(sdk: any MetaSDK) {
        self.sdk = sdk
    }

    /// Meta's SDK starts itself, so there is nothing to start.
    public func start() {}

    public func flush() {
        sdk.flush()
    }

    public func setEnabled(_ enabled: Bool) {
        sdk.setCollectionEnabled(enabled)
    }

    public func identify(_ identity: Identity) {
        sdk.setUserID(identity.userId)
    }

    public func reset() {
        sdk.setUserID(nil)
    }
}
