import FBSDKCoreKit
import HeraldCore

extension [String: AnalyticsValue] {
    /// The parameters as Meta takes them: numbers stay numbers, and true/false becomes text, since
    /// Meta's parameters are text or numbers. For a tracker of your own, which passes them to
    /// `AppEvents.shared.logEvent`.
    public func toMetaParameters() -> [AppEvents.ParameterName: Any] {
        var parameters: [AppEvents.ParameterName: Any] = [:]
        for (key, value) in self {
            let key = AppEvents.ParameterName(key)
            switch value {
            case .string(let text):
                parameters[key] = text
            case .int(let number):
                parameters[key] = number
            case .double(let number):
                parameters[key] = number
            case .bool(let flag):
                parameters[key] = flag ? "true" : "false"
            }
        }
        return parameters
    }
}
