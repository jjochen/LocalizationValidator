import Files
import Foundation

public struct LocalizationValidator {
    public static var defaultLocalizationFunction = "NSLocalizedString"

    let sourceFolder: Folder
    let localizationFolder: Folder
    let localizationFunctionName: String
    let currentDirectory: Folder

    public init(sourcePath: String,
                localizationPath: String,
                functionName: String = LocalizationValidator.defaultLocalizationFunction) throws {
        sourceFolder = try Folder(path: sourcePath)
        localizationFolder = try Folder(path: localizationPath)
        localizationFunctionName = functionName
        currentDirectory = try Folder(path: FileManager.default.currentDirectoryPath)
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

    public func dynamicLocalizations() throws -> [SearchResult] {
        let dynamicLocalizations = try searchForDynamicLocalizations()
        return dynamicLocalizations
    }
}

internal extension LocalizationValidator {
    func searchForAvailableLocalizations() throws -> [String: SearchResult] {
        var availableLocalizations: [String: SearchResult] = [:]
        try localizationFolder.files.recursive.forEach { file in
            guard file.extension == "strings" else { return }
            let newLocalizations = try searchForAvailableLocalizations(inFile: file)
            availableLocalizations.merge(newLocalizations) { existing, _ -> SearchResult in existing }
        }
        return availableLocalizations
    }

    func searchForUsedLocalizations() throws -> [String: SearchResult] {
        var usedLocalizations: [String: SearchResult] = [:]
        try sourceFolder.files.recursive.forEach { file in
            guard file.extension == "swift" || file.extension == "m" else { return }
            let newLocalizations = try searchForUsedLocalizations(inFile: file)
            usedLocalizations.merge(newLocalizations) { existing, _ -> SearchResult in existing }
        }
        return usedLocalizations
    }

    func searchForAllLocalizations() throws -> [SearchResult] {
        var localizations: [SearchResult] = []
        try sourceFolder.files.recursive.forEach { file in
            guard file.extension == "swift" || file.extension == "m" else { return }
            let newLocalizations = try searchForAllLocalizations(inFile: file)
            localizations.append(contentsOf: newLocalizations)
        }
        return localizations
    }

    func searchForDynamicLocalizations() throws -> [SearchResult] {
        var dynamicLocalizations: [SearchResult] = []
        try sourceFolder.files.recursive.forEach { file in
            guard file.extension == "swift" || file.extension == "m" else { return }
            let newLocalizations = try searchForDynamicLocalizations(inFile: file)
            dynamicLocalizations.append(contentsOf: newLocalizations)
        }
        return dynamicLocalizations
    }

    func searchForAvailableLocalizations(inFile file: File) throws -> [String: SearchResult] {
        let pattern = #""(\w+)"=""#
        return try searchForLocalizationKeys(inFile: file, pattern: pattern)
    }

    func searchForUsedLocalizations(inFile file: File) throws -> [String: SearchResult] {
        let pattern = localizationFunctionName + #"\(@?"(\w+)","#
        return try searchForLocalizationKeys(inFile: file, pattern: pattern)
    }

    func searchForDynamicLocalizations(inFile file: File) throws -> [SearchResult] {
        let pattern = localizationFunctionName + #"\([^@"]"#
        return try searchForLocalizations(inFile: file, pattern: pattern)
    }

    func searchForAllLocalizations(inFile file: File) throws -> [SearchResult] {
        let pattern = localizationFunctionName + #"\("#
        return try searchForLocalizations(inFile: file, pattern: pattern)
    }

    func searchForLocalizationKeys(inFile file: File, pattern: String) throws -> [String: SearchResult] {
        let contents = try file.readAsString(encodedAs: .utf8)
        let regularExpression = try NSRegularExpression(pattern: pattern)
        let fullRange = NSRange(contents.startIndex ..< contents.endIndex,
                                in: contents)
        var results: [String: SearchResult] = [:]
        regularExpression.enumerateMatches(in: contents,
                                           options: [],
                                           range: fullRange) { match, _, _ in
            guard let result = self.searchResult(inFile: file, forMatch: match, in: contents) else { return }
            guard let key = result.key else { return }
            results[key] = result
        }
        return results
    }

    func searchForLocalizations(inFile file: File, pattern: String) throws -> [SearchResult] {
        let contents = try file.readAsString(encodedAs: .utf8)
        let regularExpression = try NSRegularExpression(pattern: pattern)
        let fullRange = NSRange(contents.startIndex ..< contents.endIndex,
                                in: contents)
        var results: [SearchResult] = []
        regularExpression.enumerateMatches(in: contents,
                                           options: [],
                                           range: fullRange) { match, _, _ in
            guard let result = self.searchResult(inFile: file, forMatch: match, in: contents) else { return }
            results.append(result)
        }
        return results
    }

    func searchResult(inFile file: File, forMatch match: NSTextCheckingResult?, in contents: String) -> SearchResult? {
        guard let match = match else { return nil }
        let path = file.path(relativeTo: currentDirectory)
        let key = contents.string(forRangeAt: 1, ofMatch: match)
        let position = contents.filePosition(forMatch: match)
        let result = SearchResult(filePath: path,
                                  lineNumber: position.line,
                                  positionInLine: position.positionInLine,
                                  key: key)

        return result
    }
}
