import Foundation

internal extension String {
    func string(forRangeAt index: Int, ofMatch match: NSTextCheckingResult) -> String? {
        guard match.numberOfRanges > index else { return nil }
        guard let keyRange = Range(match.range(at: index), in: self) else { return nil }
        return String(self[keyRange])
    }

    func filePosition(forMatch match: NSTextCheckingResult) -> FilePosition {
        let location = match.range.location
        return FilePosition(forLocation: location, inContents: self)
    }
}
