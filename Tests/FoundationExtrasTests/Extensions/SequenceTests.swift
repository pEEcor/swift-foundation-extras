//
//  SequenceTests.swift
//
//  Copyright © 2024 Paavo Becker.
//

import XCTest

final class SequenceTests: XCTestCase {
    func testAsyncMap() async {
        // GIVEN
        let input = ["one", "two", "three"]
        let transform: (String) async -> Int = { $0.count }

        // WHEN
        let output = await input.asyncMap(transform)

        // THEN
        XCTAssertEqual(output, [3, 3, 5])
    }

    func testAsyncCompactMap() async {
        // GIVEN
        let input = ["one", nil, "three"]
        let transform: (String?) async -> Int? = { $0.map(\.count) }

        // WHEN
        let output = await input.asyncCompactMap(transform)

        // THEN
        XCTAssertEqual(output, [3, 5])
    }

    func testAsyncForEach() async {
        // GIVEN
        let input = ["one", "two", "three"]
        var output: [Int] = []
        let transform: (String) async -> Void = { output.append($0.count) }

        // WHEN
        await input.asyncForEach(transform)

        // THEN
        XCTAssertEqual(output, [3, 3, 5])
    }
}
