//
//  File.swift
//
//
//  Created by Jochen on 30.08.20.
//

import Foundation
@testable import LocalizationValidator
import XCTest

final class SearchResultTests: XCTestCase {
    func testInitializer() {
        let searchResult = SearchResult(filePath: "filePath", position: FilePosition(lineNumber: 3, positionInLine: 4), key: "key")
        XCTAssertEqual(searchResult.filePath, "filePath")
        XCTAssertEqual(searchResult.position.lineNumber, 3)
        XCTAssertEqual(searchResult.position.positionInLine, 4)
        XCTAssertEqual(searchResult.key, "key")
    }
}
