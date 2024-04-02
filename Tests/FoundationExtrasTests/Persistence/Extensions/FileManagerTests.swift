//
//  FileManagerTests.swift
//
//  Copyright © 2024 Paavo Becker.
//

import Foundation
import FoundationExtras
import XCTest

final class FileManagerTests: XCTestCase {
    func testDirectoryExists_returnTrue_whenDirectoryExistsAtPath() throws {
        // GIVEN
        let tempDirectoryUrl = FileManager.default.temporaryDirectory

        // WHEN
        let output = FileManager.default.directoryExists(atPath: tempDirectoryUrl.path())

        // THEN
        XCTAssertTrue(output)
    }
}
