import FBSDKCoreKit
import Foundation
import HeraldCore

@testable import HeraldMeta

struct TestEvent: Event {
    let name: String
    var parameters: [String: AnalyticsValue] = [:]
}

/// Records the Meta calls instead of making them, each as one line that shows every value's type,
/// like `logEvent sign_up plan=String(pro)`. Locked, so any thread can call it: hence
/// `@unchecked Sendable`.
final class RecordingMetaSDK: MetaSDK, @unchecked Sendable {
    private let lock = NSLock()
    private var recorded: [String] = []

    var calls: [String] {
        lock.lock()
        defer { lock.unlock() }
        return recorded
    }

    func logEvent(_ name: String, parameters: [AppEvents.ParameterName: Any]) {
        record("logEvent \(name)\(formatted(parameters))")
    }

    func logPurchase(amount: Double, currency: String, parameters: [AppEvents.ParameterName: Any]) {
        record("logPurchase \(amount) \(currency)\(formatted(parameters))")
    }

    func setUserID(_ userID: String?) { record("userID \(userID ?? "nil")") }

    func flush() { record("flush") }

    func setCollectionEnabled(_ enabled: Bool) { record("collection \(enabled)") }

    private func formatted(_ parameters: [AppEvents.ParameterName: Any]) -> String {
        var text = ""
        for key in parameters.keys.sorted(by: { $0.rawValue < $1.rawValue }) {
            let value = parameters[key]!
            text += " \(key.rawValue)=\(type(of: value))(\(value))"
        }
        return text
    }

    private func record(_ line: String) {
        lock.lock()
        defer { lock.unlock() }
        recorded.append(line)
    }
}

/// What Herald sent to its error reporter. Locked like ``RecordingMetaSDK``.
final class ReportedFailures: @unchecked Sendable {
    private let lock = NSLock()
    private var failures: [AnalyticsFailure] = []

    var all: [AnalyticsFailure] {
        lock.lock()
        defer { lock.unlock() }
        return failures
    }

    func append(_ failure: AnalyticsFailure) {
        lock.lock()
        defer { lock.unlock() }
        failures.append(failure)
    }
}
