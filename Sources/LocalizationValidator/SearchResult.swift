import Foundation

public struct SearchResult {
    let filePath: String
    let lineNumber: Int
    let key: String
}

extension SearchResult: CustomStringConvertible {
    public var description: String {
        return "\(key): \(filePath):\(lineNumber)"
    }
}
