//
//  Base64CoderTests.swift
//
//  Copyright © 2024 Paavo Becker.
//

import FoundationExtras
import XCTest

final class Base64CoderTests: XCTestCase {
    func testEncode_makeBase64String() throws {
        // GIVEN
        let sut = Base64Coder()

        // WHEN
        let output = try sut.encode("foo".data(using: .utf8)!)

        // THEN
        XCTAssertEqual(output, "Zm9v")
    }

    func testDecode_makeData() throws {
        // GIVEN
        let sut = Base64Coder()

        // WHEN
        let output = try sut.decode(from: "Zm9v")

        // THEN
        XCTAssertEqual(output, "foo".data(using: .utf8)!)
    }

    func testDecode_throwError_whenCodingIsInvalid() throws {
        // GIVEN
        let sut = Base64Coder()

        // WHEN
        XCTAssertThrowsError(try sut.decode(from: "foo")) { error in
            XCTAssertEqual(error as! Base64CoderFailure, .invalidEncoding)
        }
    }
}
