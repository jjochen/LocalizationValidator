import Files
import Foundation
struct TestFolder {
    let folder: Folder
    let sourceFolder: Folder
    let localizationFolder: Folder

    init() throws {
        let parent = try Folder(path: "/tmp")
        let mainFolder = try parent.createSubfolderIfNeeded(withName: "LocalizationValidator")
        folder = try mainFolder.createSubfolder(named: NSUUID().uuidString)
        sourceFolder = try folder.createSubfolder(at: "source")
        localizationFolder = try folder.createSubfolder(at: "en.lproj")
    }

    func localizationFile(named name: String = "Localization.strings", withContents contents: String) throws -> File {
        let data = contents.data(using: .utf8)
        return try localizationFolder.createFile(named: name, contents: data)
    }

    func sourceFile(named name: String = "Source.m", withContents contents: String) throws -> File {
        let data = contents.data(using: .utf8)
        return try sourceFolder.createFile(named: name, contents: data)
    }

    func delete() throws {
        try folder.delete()
    }
}
