import Foundation

internal enum LocalizationValidatorError: Error {
    case unknown(message: String)
}

extension LocalizationValidatorError: CustomStringConvertible {
    public var description: String {
        var description: String
        switch self {
        case let .unknown(message):
            description = message
        }
        return description
    }
}
