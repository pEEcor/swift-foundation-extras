//
//  SequenceTests.swift
//
//  Copyright © 2024 Paavo Becker.
//

import XCTest
import ConcurrencyExtras

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
    
    func testAsyncFilter() async {
        // GIVEN
        let input = ["one", "two", "three"]
        let transform: (String) async -> Bool = { $0.count < 5 }

        // WHEN
        let output = await input.asyncFilter(transform)

        // THEN
        XCTAssertEqual(output, ["one", "two"])
    }
    
    func testConcurrentMap() async throws {
        // GIVEN
        let input = ["one", "two", "three", "four"]
        let transform: @Sendable (String) async -> Int = { $0.count }

        // WHEN
        let output = try await input.concurrentMap(transform)

        // THEN
        XCTAssertEqual(output, [3, 3, 5, 4])
    }
    
    func testUnorderedConcurrentMap() async throws {
        // GIVEN
        let input = ["one", "two", "three", "four"]
        let transform: @Sendable (String) async -> Int = { $0.count }

        // WHEN
        let output = try await input.unorderedConcurrentMap(transform)

        // THEN
        XCTAssertTrue(output.contains(3))
        XCTAssertTrue(output.contains(4))
        XCTAssertTrue(output.contains(5))
        XCTAssertEqual(output.count, 4)
    }
    
    func testConcurrentCompactMap() async throws {
        // GIVEN
        let input = ["one", nil, "three"]
        let transform: @Sendable (String?) async -> Int? = { $0.map(\.count) }

        // WHEN
        let output = try await input.concurrentCompactMap(transform)

        // THEN
        XCTAssertEqual(output, [3, 5])
    }
    
    func testConcurrentForEach() async throws {
        // GIVEN
        let input = ["one", "two", "three"]
        let output: LockIsolated<[Int]> = LockIsolated([])
        let transform: @Sendable (String) async -> Void = { element in
            output.withValue { $0.append(element.count) }
        }

        // WHEN
        try await input.concurrentForEach(transform)

        // THEN
        XCTAssertTrue(output.value.contains(3))
        XCTAssertTrue(output.value.contains(5))
        XCTAssertEqual(output.value.count, 3)
    }
    
    func testConcurrentFilter() async throws {
        // GIVEN
        let input = ["one", "two", "three"]
        let transform: @Sendable (String) async -> Bool = { $0.count < 5 }

        // WHEN
        let output = try await input.concurrentFilter(transform)

        // THEN
        XCTAssertEqual(output, ["one", "two"])
    }
}
