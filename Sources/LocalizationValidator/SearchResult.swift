import Foundation

public struct SearchResult {
    let filePath: String
    let lineNumber: Int
    let key: String?
}

extension SearchResult: CustomStringConvertible {
    public var description: String {
        let location = "\(filePath):\(lineNumber)"
        guard let key = key else {
            return location
        }
        return "\(key): \(location)"
    }
}
