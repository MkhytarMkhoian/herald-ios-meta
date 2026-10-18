import HeraldCore

/// Logs any event under its own name. Claims every event, so it goes last in a chain.
///
/// Most apps leave it out and send Meta only their conversions, each claimed by a factory of its
/// own.
public struct GenericMetaEventTrackerFactory: MetaEventTrackerFactory, FallbackFactory {
    private let sdk: any MetaSDK

    public init() {
        self.init(sdk: LiveMetaSDK())
    }

    init(sdk: any MetaSDK) {
        self.sdk = sdk
    }

    public func create(_ event: any Event) -> Resolution<any MetaEventTracker> {
        .claimed([GenericMetaEventTracker(event: event, sdk: sdk)])
    }
}

/// Fails for any event that reaches it, so the error reporter shows events nobody mapped.
public struct RequireMappedMetaEventTrackerFactory: MetaEventTrackerFactory, FallbackFactory {
    public init() {}

    public func create(_ event: any Event) throws -> Resolution<any MetaEventTracker> {
        throw UnhandledEventError(event: event)
    }
}
