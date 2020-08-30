import Foundation

internal extension String {
    func string(forRangeAt index: Int, ofMatch match: NSTextCheckingResult) -> String? {
        guard match.numberOfRanges > index else { return nil }
        guard let keyRange = Range(match.range(at: index), in: self) else { return nil }
        return String(self[keyRange])
    }

    func filePosition(forMatch match: NSTextCheckingResult) -> (line: Int, positionInLine: Int) {
        let location = match.range.location
        guard location > 0 else {
            return (1, 1)
        }
        let index = self.index(startIndex, offsetBy: match.range.location)
        let substring = prefix(upTo: index)
        let lines = substring.split(omittingEmptySubsequences: false, whereSeparator: \.isNewline)
        let lineNumber: Int = lines.count
        let positionInLine: Int = (lines.last?.count ?? 0) + 1
        return (lineNumber, positionInLine)
    }
}
