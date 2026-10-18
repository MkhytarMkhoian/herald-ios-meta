import HeraldCore

/// Logs the event under its own name, with its parameters.
public struct GenericMetaEventTracker: MetaEventTracker {
    private let event: any Event
    private let sdk: any MetaSDK

    public init(event: any Event) {
        self.init(event: event, sdk: LiveMetaSDK())
    }

    init(event: any Event, sdk: any MetaSDK) {
        self.event = event
        self.sdk = sdk
    }

    public func track() {
        sdk.logEvent(event.name, parameters: event.parameters.toMetaParameters())
    }
}
