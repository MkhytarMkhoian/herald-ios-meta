import HeraldCore
import Testing

@testable import HeraldMeta

@Suite struct Consent {
    let meta = RecordingMetaSDK()

    @Test func setEnabledTurnsMetasCollectionOnAndOff() {
        let service = MetaAnalyticsService(sdk: meta)

        service.setEnabled(true)
        service.setEnabled(false)

        #expect(meta.calls == ["collection true", "collection false"])
    }
}

@Suite struct Service {
    let meta = RecordingMetaSDK()

    @Test func identifyAndResetSetAndClearTheUserID() {
        let service = MetaAnalyticsService(sdk: meta)

        service.identify(Identity(userId: "user-42"))
        service.reset()

        #expect(meta.calls == ["userID user-42", "userID nil"])
    }

    @Test func flushFlushesMeta() {
        MetaAnalyticsService(sdk: meta).flush()

        #expect(meta.calls == ["flush"])
    }

    @Test func theTrackerSendsWhatItsFactoryChainClaims() {
        let tracker = MetaAnalyticsTrackerService(
            eventTrackerFactory: GenericMetaEventTrackerFactory(sdk: meta))

        tracker.track(TestEvent(name: "sign_up"))

        #expect(meta.calls == ["logEvent sign_up"])
    }
}

@Suite struct Trackers {
    let meta = RecordingMetaSDK()

    @Test func parametersKeepNumbersAsNumbersAndSendTrueOrFalseAsText() {
        let parameters: [String: AnalyticsValue] = [
            "plan": .string("pro"), "seats": .int(3), "price": .double(9.99), "trial": .bool(false),
        ]

        GenericMetaEventTracker(
            event: TestEvent(name: "plan_selected", parameters: parameters), sdk: meta
        )
        .track()

        #expect(
            meta.calls == [
                "logEvent plan_selected plan=String(pro) price=Double(9.99) seats=Int(3) trial=String(false)"
            ])
    }

    @Test func aPurchaseIsLoggedWithItsAmountAndCurrency() throws {
        let purchase = MetaPurchaseEvent(
            name: "ticket_bought", amount: 4.99, currency: "EUR",
            parameters: ["fare": .string("day")])

        try PurchaseMetaEventTracker(event: purchase, sdk: meta).track()

        #expect(meta.calls == ["logPurchase 4.99 EUR fare=String(day)"])
    }

    @Test func aPurchaseWithAnAmountThatIsNotAFiniteNumberIsReported() {
        let failures = ReportedFailures()
        let tracker = MetaAnalyticsTrackerService(eventTrackerFactory: PurchaseFactory(sdk: meta))
        let herald = Herald(
            providers: [HeraldProvider(name: "meta", events: tracker)],
            errorReporter: { failure in failures.append(failure) })

        herald.track(MetaPurchaseEvent(name: "ticket_bought", amount: .nan, currency: "EUR"))

        #expect(meta.calls.isEmpty)
        #expect("\(failures.all.first?.error as Any)".contains("needs a finite amount"))
    }

    @Test func theRequireMappedFactoryFailsForAnyEvent() {
        #expect(throws: UnhandledEventError.self) {
            try RequireMappedMetaEventTrackerFactory().create(TestEvent(name: "search_tapped"))
        }
    }

    @Test func theCompositeUsesTheFirstFactoryThatAnswers() throws {
        let factory = CompositeMetaEventTrackerFactory([
            PurchaseFactory(sdk: meta), GenericMetaEventTrackerFactory(sdk: meta),
        ])

        try factory.create(TestEvent(name: "search_tapped")).handlers().first?.track()

        #expect(meta.calls == ["logEvent search_tapped"])
    }
}

/// Sends `MetaPurchaseEvent` as a purchase, and declines everything else.
private struct PurchaseFactory: MetaEventTrackerFactory {
    let sdk: any MetaSDK

    func create(_ event: any Event) -> Resolution<any MetaEventTracker> {
        guard let purchase = event as? MetaPurchaseEvent else {
            return .declined
        }
        return .claimed([PurchaseMetaEventTracker(event: purchase, sdk: sdk)])
    }
}
