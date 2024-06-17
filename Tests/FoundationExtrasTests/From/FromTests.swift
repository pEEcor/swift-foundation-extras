//
//  FromTests.swift
//
//  Copyright © 2024 Paavo Becker.
//

import FoundationExtras
import XCTest

final class FromTests: XCTestCase {
    func testConvert() {
        // GIVEN
        let input = "foo"
        let sut = From<Int, String> { $0.count }

        // WHEN
        let output = sut.convert(input)

        // THEN
        XCTAssertEqual(output, 3)
    }

    func testCallAsFunction() {
        // GIVEN
        let input = "foo"
        let sut = From<Int, String> { $0.count }

        // WHEN
        let output = sut(input)

        // THEN
        XCTAssertEqual(output, 3)
    }

    func testPullback() {
        // GIVEN
        let input = ["foo", "bar"]
        let sut = From<Int, String> { $0.count }

        // WHEN
        let output = sut.pullback { $0.joined() }.convert(input)

        // THEN
        XCTAssertEqual(output, 6)
    }
}
