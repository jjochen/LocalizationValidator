import ArgumentParser
import Foundation
import LocalizationValidator

enum ValidationType: String, ExpressibleByArgument {
    case unavailable
    case unused
    case dynamic

    static var allValueStrings: [String] {
        return [
            ValidationType.unavailable.rawValue,
            ValidationType.unused.rawValue,
            ValidationType.dynamic.rawValue,
        ]
    }
}

struct ValidateLocalization: ParsableCommand {
    @Option(name: .shortAndLong, help: "Path to source files.")
    var sourcePath: String = "."

    @Option(name: .shortAndLong, help: "Path to localization files.")
    var localizationPath: String = "."

    @Option(name: .shortAndLong, help: "Name of localizing function.")
    var function: String = LocalizationValidator.defaultLocalizationFunction

    @Option(name: .shortAndLong, help: "Validation type [unavailable, unused, dynamic].")
    var type: ValidationType = .unavailable

    mutating func run() throws {
        let validator = try LocalizationValidator(sourcePath: sourcePath,
                                                  localizationPath: localizationPath,
                                                  functionName: function)
        switch type {
        case .unavailable:
            try printUnavailableLocalizations(using: validator)
        case .unused:
            try printUnusedLocalizations(using: validator)
        case .dynamic:
            try printDynamicLocalizations(using: validator)
        }
    }

    func printUnavailableLocalizations(using validator: LocalizationValidator) throws {
        let unavailable = try validator.unavailableLocalizations()
        guard !unavailable.isEmpty else {
            print("No unavailable localizations!")
            return
        }
        print("\n\(unavailable.count) unavailable localizations:\n")
        unavailable.forEach { _, searchResult in
            print(searchResult)
        }
    }

    func printUnusedLocalizations(using validator: LocalizationValidator) throws {
        let unused = try validator.unusedLocalizations()
        guard !unused.isEmpty else {
            print("No unused localizations!")
            return
        }
        print("\n\(unused.count) unused localizations:\n")
        unused.forEach { key, _ in
            print(key)
        }
    }

    func printDynamicLocalizations(using validator: LocalizationValidator) throws {
        let dynamic = try validator.dynamicLocalizations()
        guard !dynamic.isEmpty else {
            print("No dynamic localizations!")
            return
        }
        print("\n\(dynamic.count) dynamic localizations:\n")
        dynamic.forEach { searchResult in
            print(searchResult)
        }
    }
}

ValidateLocalization.main()
