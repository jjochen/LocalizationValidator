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

internal extension LocalizationValidator {}
