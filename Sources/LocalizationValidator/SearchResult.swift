import Foundation

public struct SearchResult {
    let filePath: String
    let lineNumber: Int
    let positionInLine: Int
    let key: String?
}

extension SearchResult: CustomStringConvertible {
    public var description: String {
        let fileLocation = "\(filePath):\(lineNumber):\(positionInLine)"
        guard let key = key else {
            return fileLocation
        }
        return "\(key): \(fileLocation)"
    }
}
