import Foundation

public struct FilePosition {
    let lineNumber: Int
    let positionInLine: Int

    public init(lineNumber: Int, positionInLine: Int) {
        self.lineNumber = lineNumber
        self.positionInLine = positionInLine
    }
}

internal extension FilePosition {
    init(forLocation location: Int, inContents contents: String) {
        let index = contents.index(contents.startIndex, offsetBy: location)
        let substring = contents.prefix(upTo: index)
        let lines = substring.split(omittingEmptySubsequences: false, whereSeparator: \.isNewline)
        let lineNumber: Int = lines.count
        let positionInLine: Int = (lines.last?.count ?? 0) + 1
        self.init(lineNumber: lineNumber, positionInLine: positionInLine)
    }
}
