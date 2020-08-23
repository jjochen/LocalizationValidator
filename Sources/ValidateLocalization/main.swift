import ArgumentParser
import Foundation
import LocalizationValidator
import Progress

struct ValidateLocalization: ParsableCommand {
    @Option(name: .shortAndLong, help: "Path to source files.")
    var sourcePath: String = "."

    @Option(name: .shortAndLong, help: "Path to localization files.")
    var localizationPath: String = "."

    @Option(name: .shortAndLong, help: "Name of localizing function.")
    var function: String = "NSLocalizedString"

    @Flag(name: .shortAndLong, help: "Verbose output.")
    var verbose = false

    mutating func run() throws {
        let validator = try LocalizationValidator()
        var progressBar: ProgressBar?
        let progressBarConfiguration: [ProgressElementType] = [ProgressIndex(),
                                                               ProgressBarLine(barLength: 60),
                                                               ProgressTimeEstimates()]
        try validator.validate(verbose: verbose) { total, count in
            if progressBar == nil {
                progressBar = ProgressBar(count: total, configuration: progressBarConfiguration)
            }
            progressBar?.setValue(count)
        }
    }
}

ValidateLocalization.main()
