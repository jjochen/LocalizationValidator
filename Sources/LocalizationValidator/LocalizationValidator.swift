import Files
import Foundation

public struct LocalizationValidator {
    public static var defaultLocalizationFunction = "NSLocalizedString"

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

    public func unusedLocalizations() throws -> [String: SearchResult] {
        let usedLocalizations = try searchForUsedLocalizations()
        let availableLocalizations = try searchForAvailableLocalizations()

        var unusedLocalizations: [String: SearchResult] = [:]
        availableLocalizations.forEach { key, searchResult in
            if usedLocalizations[key] == nil {
                unusedLocalizations[key] = searchResult
            }
        }
        return unusedLocalizations
    }

    public func unavailableLocalizations() throws -> [String: SearchResult] {
        let usedLocalizations = try searchForUsedLocalizations()
        let availableLocalizations = try searchForAvailableLocalizations()

        var unavailableLocalizations: [String: SearchResult] = [:]
        usedLocalizations.forEach { key, searchResult in
            if availableLocalizations[key] == nil {
                unavailableLocalizations[key] = searchResult
            }
        }
        return unavailableLocalizations
    }
}

internal extension LocalizationValidator {
    func searchForAvailableLocalizations() throws -> [String: SearchResult] {
        var availableLocalizations: [String: SearchResult] = [:]
        try localizationFolder.files.recursive.forEach { file in
            guard file.extension == "strings" else { return }
            let newLocalizations = try localizationKeys(inLocalizationFile: file)
            availableLocalizations.merge(newLocalizations) { existing, _ -> SearchResult in existing }
        }
        return availableLocalizations
    }

    func searchForUsedLocalizations() throws -> [String: SearchResult] {
        var usedLocalizations: [String: SearchResult] = [:]
        try sourceFolder.files.recursive.forEach { file in
            guard file.extension == "swift" || file.extension == "m" else { return }
            let newLocalizations = try localizationKeys(inSourceFile: file)
            usedLocalizations.merge(newLocalizations) { existing, _ -> SearchResult in existing }
        }
        return usedLocalizations
    }

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
            let result = SearchResult(filePath: file.path, lineNumber: 0, key: key)

            results[key] = result
        }
        return results
    }

    func localizationKeys(inSourceFile file: File) throws -> [String: SearchResult] {
        let contents = try file.readAsString(encodedAs: .utf8)
        let pattern = localizationFunctionName + #"\(@{0,1}"(\w+)","#
        let regularExpression = try NSRegularExpression(pattern: pattern)
        let fullRange = NSRange(contents.startIndex ..< contents.endIndex,
                                in: contents)
        var results: [String: SearchResult] = [:]
        regularExpression.enumerateMatches(in: contents,
                                           options: [],
                                           range: fullRange) { match, _, _ in
            guard let match = match, match.numberOfRanges == 2 else { return }
            guard let keyRange = Range(match.range(at: 1), in: contents) else { return }
            let key = String(contents[keyRange])
            let result = SearchResult(filePath: file.path, lineNumber: 0, key: key)

            results[key] = result
        }
        return results
    }
}
