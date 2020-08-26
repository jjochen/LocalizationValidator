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

    func searchForAvailableLocalizations(inFile file: File) throws -> [String: SearchResult] {
        let pattern = #""(\w+)"=""#
        return try searchForLocalizations(inFile: file, pattern: pattern)
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

    func searchForUsedLocalizations(inFile file: File) throws -> [String: SearchResult] {
        let pattern = localizationFunctionName + #"\(@?"(\w+)","#
        return try searchForLocalizations(inFile: file, pattern: pattern)
    }

    func searchForLocalizations(inFile file: File, pattern: String) throws -> [String: SearchResult] {
        let contents = try file.readAsString(encodedAs: .utf8)
        let regularExpression = try NSRegularExpression(pattern: pattern)
        let fullRange = NSRange(contents.startIndex ..< contents.endIndex,
                                in: contents)
        var results: [String: SearchResult] = [:]
        regularExpression.enumerateMatches(in: contents,
                                           options: [],
                                           range: fullRange) { match, _, _ in
            guard let match = match, match.numberOfRanges > 1 else { return }
            guard let keyRange = Range(match.range(at: 1), in: contents) else { return }
            let key = String(contents[keyRange])
            let path = file.path(relativeTo: currentDirectory)
            let line = lineNumber(forMatch: match, in: contents)
            let result = SearchResult(filePath: path, lineNumber: line, key: key)
            results[key] = result
        }
        return results
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

    func searchForDynamicLocalizations(inFile file: File) throws -> [SearchResult] {
        let pattern = localizationFunctionName + #"\([^@"]"#
        let contents = try file.readAsString(encodedAs: .utf8)
        let regularExpression = try NSRegularExpression(pattern: pattern)
        let fullRange = NSRange(contents.startIndex ..< contents.endIndex,
                                in: contents)
        var results: [SearchResult] = []
        regularExpression.enumerateMatches(in: contents,
                                           options: [],
                                           range: fullRange) { match, _, _ in
            guard let match = match else { return }
            let path = file.path(relativeTo: currentDirectory)
            let line = lineNumber(forMatch: match, in: contents)
            let result = SearchResult(filePath: path, lineNumber: line, key: nil)
            results.append(result)
        }
        return results
    }

    func lineNumber(forMatch match: NSTextCheckingResult, in contents: String) -> Int {
        let location = match.range.location
        guard location > 0 else {
            return 1
        }
        let index = contents.index(contents.startIndex, offsetBy: match.range.location)
        let substring = contents.prefix(upTo: index)
        let lines = substring.split(omittingEmptySubsequences: false, whereSeparator: \.isNewline)
        return lines.count
    }
}
