import Files
import Foundation
@testable import LocalizationValidator
import XCTest

final class LocalizationValidatorTests: XCTestCase {
    var validator: LocalizationValidator!
    var testFolder: TestFolder!

    override func setUp() {
        super.setUp()
        do {
            testFolder = try TestFolder()
            validator = try LocalizationValidator(sourcePath: testFolder.sourceFolder.path,
                                                  localizationPath: testFolder.localizationFolder.path)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    override func tearDown() {
        do {
            try testFolder.delete()
        } catch {
            XCTFail(error.localizedDescription)
        }
        super.tearDown()
    }
}

extension LocalizationValidatorTests {
    func testInitializer() {
        XCTAssertNotNil(validator)
        XCTAssertEqual(validator.sourceFolder, testFolder.sourceFolder)
        XCTAssertEqual(validator.localizationFolder, testFolder.localizationFolder)
        XCTAssertEqual(validator.localizationFunctionName, "NSLocalizedString")
    }

    func testInitializerThrows() {
        XCTAssertThrowsError(_ = try LocalizationValidator(sourcePath: "/folder/does/not/exist",
                                                           localizationPath: testFolder.localizationFolder.path))

        XCTAssertThrowsError(_ = try LocalizationValidator(sourcePath: testFolder.sourceFolder.path,
                                                           localizationPath: "/folder/does/not/exist"))
    }

    func testLocalizationSearch() {
        let strings = "\"my_key\"=\"some_value\"\n\"key_2\"=\"value_2\""
        do {
            let file = try testFolder.createLocalizationFile(withContents: strings)
            let results = try validator.searchForAvailableLocalizations()
            XCTAssertEqual(results.count, 2)
            let result = results["key_2"]
            XCTAssertNotNil(result)
            XCTAssertEqual(result?.key, "key_2")
            XCTAssertEqual(result?.filePath, file.path)
            XCTAssertEqual(result?.lineNumber, 2)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testSwiftSourceSearch() {
        let contents = #"let string = NSLocalizedString("swift_key", comment: "")"#
        do {
            let file = try testFolder.createSourceFile(named: "Source.swift", withContents: contents)
            let results = try validator.searchForUsedLocalizations()
            let result = results["swift_key"]
            XCTAssertNotNil(result)
            XCTAssertEqual(result?.key, "swift_key")
            XCTAssertEqual(result?.filePath, file.path)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testObjCSourceSearch() {
        let source = #"NSString *string = (self.type == 1) ? NSLocalizedString(@"used_key_1", @"Notes") : NSLocalizedString(@"used_key_2", @"Favorites");"#
        do {
            let file = try testFolder.createSourceFile(named: "Source.m", withContents: source)
            let results = try validator.searchForUsedLocalizations()
            XCTAssertEqual(results.count, 2)
            let result = results["used_key_2"]
            XCTAssertNotNil(result)
            XCTAssertEqual(result?.key, "used_key_2")
            XCTAssertEqual(result?.filePath, file.path)
            XCTAssertEqual(result?.lineNumber, 1)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testDynamicKeySearch() {
        let source = #"NSString *string = (self.type == 1) ? NSLocalizedString(@"used_key_1", @"Notes") : NSLocalizedString(myVariable, @"Favorites");"#
        do {
            let file = try testFolder.createSourceFile(withContents: source)
            let results = try validator.searchForDynamicLocalizations()
            XCTAssertEqual(results.count, 1)
            let result = results.first
            XCTAssertNotNil(result)
            XCTAssertNil(result?.key)
            XCTAssertEqual(result?.filePath, file.path)
            XCTAssertEqual(result?.lineNumber, 1)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testUnavailableLocalizations() {
        let strings = "\"unused_key\"=\"some_value\"\n\"used_key_2\"=\"value_2\""
        let source = #"NSString *mainTitle = (self.type == 1) ? NSLocalizedString(@"used_key_1", @"Notes") : NSLocalizedString(@"used_key_2", @"Favorites");"#
        do {
            let file = try testFolder.createSourceFile(withContents: source)
            try testFolder.createLocalizationFile(withContents: strings)
            let results = try validator.unavailableLocalizations()
            XCTAssertEqual(results.count, 1)
            let result = results["used_key_1"]
            XCTAssertNotNil(result)
            XCTAssertEqual(result?.key, "used_key_1")
            XCTAssertEqual(result?.filePath, file.path)
            XCTAssertEqual(result?.lineNumber, 1)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testUnusedLocalizations() {
        let strings = "\n\n\"unused_key\"=\"some_value\"\n\"used_key_2\"=\"value_2\""
        let source = #"NSString *mainTitle = (self.type == 1) ? NSLocalizedString(@"used_key_1", @"Notes") : NSLocalizedString(@"used_key_2", @"Favorites");"#
        do {
            try testFolder.createSourceFile(named: "Source.m", withContents: source)
            let file = try testFolder.createLocalizationFile(withContents: strings)
            let results = try validator.unusedLocalizations()
            XCTAssertEqual(results.count, 1)
            let result = results["unused_key"]
            XCTAssertNotNil(result)
            XCTAssertEqual(result?.key, "unused_key")
            XCTAssertEqual(result?.filePath, file.path)
            XCTAssertEqual(result?.lineNumber, 3)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}
