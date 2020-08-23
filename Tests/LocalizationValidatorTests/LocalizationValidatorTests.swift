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
}
