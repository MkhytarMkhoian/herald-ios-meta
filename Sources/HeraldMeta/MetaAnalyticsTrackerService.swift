import HeraldCore

/// Sends events to Meta, as its factory chain decides.
///
/// Meta keeps no user attributes, so there are no properties.
///
/// ```swift
/// let tracker = MetaAnalyticsTrackerService(
///     eventTrackerFactory: CompositeMetaEventTrackerFactory([CheckoutMetaEventTrackerFactory()])
/// )
/// ```
public struct MetaAnalyticsTrackerService: EventTrackerService {
    private let eventTrackerFactory: any MetaEventTrackerFactory

    public init(eventTrackerFactory: any MetaEventTrackerFactory) {
        self.eventTrackerFactory = eventTrackerFactory
    }

    public func track(_ event: any Event) {
        do {
            for tracker in try eventTrackerFactory.create(event).handlers() {
                try tracker.track()
            }
        } catch {
            Herald.reportFailure(error)
        }
    }
}
