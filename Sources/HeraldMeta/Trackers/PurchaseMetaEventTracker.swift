import HeraldCore

/// Logs a purchase as Meta's `fb_mobile_purchase`. Throws for an amount that isn't a finite
/// number.
public struct PurchaseMetaEventTracker: MetaEventTracker {
    private let event: MetaPurchaseEvent
    private let sdk: any MetaSDK

    public init(event: MetaPurchaseEvent) {
        self.init(event: event, sdk: LiveMetaSDK())
    }

    init(event: MetaPurchaseEvent, sdk: any MetaSDK) {
        self.event = event
        self.sdk = sdk
    }

    public func track() throws {
        guard event.amount.isFinite else {
            throw MetaRefusal(
                description: "Meta purchase '\(event.name)' needs a finite amount, "
                    + "not \(event.amount).")
        }
        sdk.logPurchase(
            amount: event.amount, currency: event.currency,
            parameters: event.parameters.toMetaParameters())
    }
}

/// Why this module refused an event: it says what to change.
struct MetaRefusal: Error, CustomStringConvertible {
    let description: String
}
