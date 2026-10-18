# Herald for Meta

[![Swift versions](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FMkhytarMkhoian%2Fherald-ios-meta%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/MkhytarMkhoian/herald-ios-meta)
[![Platforms](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FMkhytarMkhoian%2Fherald-ios-meta%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/MkhytarMkhoian/herald-ios-meta)

Sends [Herald](https://github.com/MkhytarMkhoian/herald-ios) events and purchases to Meta's App
Events, over the [Meta iOS SDK](https://github.com/facebook/facebook-ios-sdk). Meta keeps no user
attributes, so this package handles events only.

## Install

In Xcode, File → Add Package Dependencies, and add both packages:

- `https://github.com/MkhytarMkhoian/herald-ios`, for `HeraldCore`;
- `https://github.com/MkhytarMkhoian/herald-ios-meta`, for `HeraldMeta`.

It works with Meta's SDK 18, and needs iOS 15 or newer. All Herald for iOS packages share one
version, so use the same one for `herald-ios`.

## Set up

Set up Meta's SDK as its guide shows: the app id and client token in `Info.plist`, and
`ApplicationDelegate` in your app delegate. Turn its automatic collection off there too, so a fresh
install collects nothing by itself before consent:

```xml
<key>FacebookAutoLogAppEventsEnabled</key>
<false/>
<key>FacebookAdvertiserIDCollectionEnabled</key>
<false/>
```

```swift
import HeraldCore
import HeraldMeta

let service = MetaAnalyticsService()
let tracker = MetaAnalyticsTrackerService(
    eventTrackerFactory: CompositeMetaEventTrackerFactory(conversionFactories)
)

let provider = HeraldProvider(
    name: "meta",
    events: tracker,  // no properties
    identity: service,
    lifecycle: service,
    consent: service
)
```

| Herald | Meta |
| --- | --- |
| an event a factory handles | `AppEvents.shared.logEvent`, with numbers as numbers and true/false as text |
| a `MetaPurchaseEvent` | `logPurchase(amount:currency:parameters:)`, sent as `fb_mobile_purchase` |
| `identify` / `reset` | `AppEvents.shared.userID = userId` / `nil` |
| `flush` | `AppEvents.shared.flush()` |
| `setEnabled` | `isAutoLogAppEventsEnabled` and `isAdvertiserIDCollectionEnabled` |

**Consent.** `setEnabled` turns Meta's own collection on or off: the events it logs by itself, such
as installs, and the advertiser id. It doesn't stop the events your app logs. Call it with the
stored answer on every launch.

## Your conversions

A factory of your own maps your events to Meta's standard events. Use `MetaPurchaseEvent` for a
purchase, and `toMetaParameters()` for a tracker of your own:

```swift
import HeraldCore
import HeraldMeta

struct CheckoutMetaEventTrackerFactory: MetaEventTrackerFactory {
    func create(_ event: any Event) -> Resolution<any MetaEventTracker> {
        guard let checkout = event as? CheckoutCompleted else {
            return .declined
        }
        let purchase = MetaPurchaseEvent(
            name: checkout.name, amount: checkout.value, currency: checkout.currency)
        return .claimed([PurchaseMetaEventTracker(event: purchase)])
    }
}
```

## Documentation

The [Herald website](https://mkhytarmkhoian.github.io/herald-docs/) has the guides.

## License

Apache License 2.0. See [LICENSE](LICENSE).
