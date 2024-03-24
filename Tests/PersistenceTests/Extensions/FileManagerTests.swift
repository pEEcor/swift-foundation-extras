//
//  FileManagerTests.swift
//  
//
//  Created by Paavo Becker on 23.03.24.
//

import XCTest
import Foundation
import Persistence

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
