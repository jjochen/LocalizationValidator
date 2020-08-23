import Files
import Foundation

public struct LocalizationValidator {
    public static var defaultLocalizationFunction = "NSLocalizedString"
    public typealias ValidationProgress = (_ total: Int, _ count: Int) -> Void

    let sourceFolder: Folder
    let localizationFolder: Folder
    let localizationFunctionName: String

    public init(sourcePath: String,
                localizationPath: String,
                functionName: String = LocalizationValidator.defaultLocalizationFunction) throws {
        try sourceFolder = Folder(path: sourcePath)
        try localizationFolder = Folder(path: localizationPath)
        localizationFunctionName = functionName
    }

    public func validate(verbose _: Bool = false, progress _: ValidationProgress? = nil) throws {}
}

internal extension LocalizationValidator {
    func localizationKeys(inLocalizationFile file: File) throws -> [String: SearchResult] {
        let contents = try file.readAsString(encodedAs: .utf8)
        let regularExpression = try NSRegularExpression(pattern: #""(\w+)"=""#)
        let fullRange = NSRange(contents.startIndex ..< contents.endIndex,
                                in: contents)
        var results: [String: SearchResult] = [:]
        regularExpression.enumerateMatches(in: contents,
                                           options: [],
                                           range: fullRange) { match, _, _ in
            guard let match = match, match.numberOfRanges == 2 else { return }
            guard let keyRange = Range(match.range(at: 1), in: contents) else { return }
            let key = String(contents[keyRange])
            let result = SearchResult(filePath: file.path, line: 0, key: key)

            results[key] = result
        }
        return results
    }
}
