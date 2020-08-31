import Foundation

internal extension Dictionary {
    @inlinable mutating func removeValues(forKeys keys: Dictionary.Keys) {
        keys.forEach { key in
            self.removeValue(forKey: key)
        }
    }
}
