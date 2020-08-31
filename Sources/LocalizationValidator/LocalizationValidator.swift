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
        let identifier: SearchResultIdentifier = { result in result.key }
        return try remove(resultsFromSearch: searchForUsedLocalizations,
                          from: searchForAvailableLocalizations,
                          resultIdentifier: identifier)
    }

    public func unavailableLocalizations() throws -> [String: SearchResult] {
        let identifier: SearchResultIdentifier = { result in result.key }
        return try remove(resultsFromSearch: searchForAvailableLocalizations,
                          from: searchForUsedLocalizations,
                          resultIdentifier: identifier)
    }

    public func dynamicLocalizations() throws -> [String: SearchResult] {
        let identifier: SearchResultIdentifier = { result in result.fileLocation }
        return try remove(resultsFromSearch: searchForUsedLocalizations,
                          from: searchForAllLocalizations,
                          resultIdentifier: identifier)
    }
}

internal extension LocalizationValidator {
    typealias FileSearch = (SearchResultIdentifier) throws -> [String: SearchResult]

    func remove(resultsFromSearch search1: FileSearch,
                from search2: FileSearch,
                resultIdentifier: @escaping SearchResultIdentifier) throws -> [String: SearchResult] {
        var results = try search2(resultIdentifier)
        let keys = try search1(resultIdentifier).keys
        results.removeValues(forKeys: keys)
        return results
    }

    func searchForAvailableLocalizations(identifier: SearchResultIdentifier) throws -> [String: SearchResult] {
        let pattern = #""(\w+)"=""#
        let filter = ["strings"]
        return try search(folder: localizationFolder, filter: filter, pattern: pattern, identifier: identifier)
    }

    func searchForUsedLocalizations(identifier: SearchResultIdentifier) throws -> [String: SearchResult] {
        let pattern = localizationFunctionName + #"\(@?"(\w+)","#
        let filter = ["swift", "m"]
        return try search(folder: sourceFolder, filter: filter, pattern: pattern, identifier: identifier)
    }

    func searchForAllLocalizations(identifier: SearchResultIdentifier) throws -> [String: SearchResult] {
        let pattern = localizationFunctionName + #"\("#
        let filter = ["swift", "m"]
        return try search(folder: sourceFolder, filter: filter, pattern: pattern, identifier: identifier)
    }
}

internal extension LocalizationValidator {
    typealias SearchResultIdentifier = (SearchResult) -> String?

    func search(folder: Folder,
                filter: [String],
                pattern: String,
                identifier: SearchResultIdentifier) throws -> [String: SearchResult] {
        var results: [String: SearchResult] = [:]
        try folder.files.recursive.forEach { file in
            guard let fileExtension = file.extension else { return }
            guard filter.contains(fileExtension) else { return }
            let resultsInFile = try search(file: file, pattern: pattern, identifier: identifier)
            results.merge(resultsInFile) { existing, _ -> SearchResult in existing }
        }
        return results
    }

    func search(file: File,
                pattern: String,
                identifier: SearchResultIdentifier) throws -> [String: SearchResult] {
        let contents = try file.readAsString(encodedAs: .utf8)
        let regularExpression = try NSRegularExpression(pattern: pattern)
        let fullRange = NSRange(contents.startIndex ..< contents.endIndex,
                                in: contents)
        var results: [String: SearchResult] = [:]
        regularExpression.enumerateMatches(in: contents,
                                           options: [],
                                           range: fullRange) { match, _, _ in
            guard let result = self.searchResult(forMatch: match, inFile: file, withContents: contents) else { return }
            guard let key = identifier(result) else { return }
            results[key] = result
        }
        return results
    }

    func searchResult(forMatch match: NSTextCheckingResult?,
                      inFile file: File,
                      withContents contents: String) -> SearchResult? {
        let path = file.path(relativeTo: currentDirectory)
        return SearchResult(forMatch: match, inFileAt: path, withContents: contents)
    }
}
