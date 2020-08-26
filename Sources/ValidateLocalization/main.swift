import ArgumentParser
import Foundation
import LocalizationValidator

struct ValidateLocalization: ParsableCommand {
    @Option(name: .shortAndLong, help: "Path to source files.")
    var sourcePath: String = "."

    @Option(name: .shortAndLong, help: "Path to localization files.")
    var localizationPath: String = "."

    @Option(name: .shortAndLong, help: "Name of localizing function.")
    var function: String = LocalizationValidator.defaultLocalizationFunction

    @Flag(name: .shortAndLong, help: "Print unused localization keys.")
    var unused = false

    mutating func run() throws {
        let validator = try LocalizationValidator(sourcePath: sourcePath,
                                                  localizationPath: localizationPath,
                                                  functionName: function)
        if unused {
            try printUnusedLocalizations(using: validator)
        } else {
            try printUnavailableLocalizations(using: validator)
        }
    }

    func printUnavailableLocalizations(using validator: LocalizationValidator) throws {
        let unavailable = try validator.unavailableLocalizations()
        guard !unavailable.isEmpty else {
            print("no unavailable localizations!")
            return
        }
        print("unavailable localizations:")
        unavailable.forEach { _, searchResult in
            print(searchResult)
        }
    }

    func printUnusedLocalizations(using validator: LocalizationValidator) throws {
        let unused = try validator.unusedLocalizations()
        guard !unused.isEmpty else {
            print("no unused localizations!")
            return
        }
        print("unused localizations:")
        unused.forEach { key, _ in
            print(key)
        }
    }
}

ValidateLocalization.main()
