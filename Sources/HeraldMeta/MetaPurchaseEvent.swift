import HeraldCore

/// A purchase, as Meta's standard `fb_mobile_purchase`, which Meta counts as revenue for ads.
///
/// Your events don't conform to it: your Meta factory builds one from your event and sends it with
/// ``PurchaseMetaEventTracker``.
public struct MetaPurchaseEvent: Event, Equatable {
    /// Not sent. Only used in failure reports.
    public let name: String

    /// The amount paid.
    public let amount: Double

    /// An ISO 4217 code, such as `EUR`.
    public let currency: String

    /// Sent with the purchase.
    public let parameters: [String: AnalyticsValue]

    public init(
        name: String, amount: Double, currency: String, parameters: [String: AnalyticsValue] = [:]
    ) {
        self.name = name
        self.amount = amount
        self.currency = currency
        self.parameters = parameters
    }
}
