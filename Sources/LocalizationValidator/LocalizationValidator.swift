import Files
import Foundation

public struct LocalizationValidator {
    public typealias ValidationProgress = (_ total: Int, _ count: Int) -> Void

    public init() throws {}

    public func validate(verbose _: Bool = false, progress _: ValidationProgress? = nil) throws {}
}

internal extension LocalizationValidator {}
