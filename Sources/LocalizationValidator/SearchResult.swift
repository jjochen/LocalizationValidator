import Foundation

public struct SearchResult {
    let filePath: String
    let position: FilePosition
    let key: String?

    public init(filePath: String, position: FilePosition, key: String? = nil) {
        self.filePath = filePath
        self.position = position
        self.key = key
    }
}

internal extension SearchResult {
    init?(forMatch match: NSTextCheckingResult?, inFileAt path: String, withContents contents: String) {
        guard let match = match else { return nil }
        let key = contents.string(forRangeAt: 1, ofMatch: match)
        let position = contents.filePosition(forMatch: match)
        self.init(filePath: path, position: position, key: key)
    }
}

extension SearchResult: CustomStringConvertible {
    public var description: String {
        let fileLocation = "\(filePath):\(position.lineNumber):\(position.positionInLine)"
        guard let key = key else {
            return fileLocation
        }
        return "\(key): \(fileLocation)"
    }
}
