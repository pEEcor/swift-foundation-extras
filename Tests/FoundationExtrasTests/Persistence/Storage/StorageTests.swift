//
//  StorageTests.swift
//
//  Copyright © 2024 Paavo Becker.
//

import FoundationExtras
import XCTest

final class StorageTests: XCTestCase {
    func testValues_containAllValues() async throws {
        // GIVEN
        let storage: any Storage<Int, Int> = MemoryStorage(initialValue: [1: 42, 2: 43])

        // WHEN
        let output = try await storage.values

        // THEN
        XCTAssertTrue(output.contains(42))
        XCTAssertTrue(output.contains(43))
    }

    func testContent_containAllKeyValuePairs() async throws {
        // GIVEN
        let storage: any Storage<Int, Int> = MemoryStorage(initialValue: [1: 42, 2: 43])

        // WHEN
        let output = try await storage.content

        // THEN
        XCTAssertEqual(output, [1: 42, 2: 43])
    }

    func testClear_removesAllKeyValuePairsFromStorage() async throws {
        // GIVEN
        let storage: any Storage<Int, Int> = MemoryStorage(initialValue: [1: 42, 2: 43])

        // WHEN
        try await storage.clear()

        // THEN
        let output = try await storage.content
        XCTAssertEqual(output, [:])
    }

    func testUpdate_updateValue_whenKeyAlreadyExists() async throws {
        // GIVEN
        let storage: any Storage<Int, Int> = MemoryStorage(initialValue: [1: 42])

        // WHEN
        try await storage.update(value: 43, for: 1)

        // THEN
        let output = try await storage.content
        XCTAssertEqual(output, [1: 43])
    }

    func testUpdate_insertValue_whenKeyDoesNotExist() async throws {
        // GIVEN
        let storage: any Storage<Int, Int> = MemoryStorage()

        // WHEN
        try await storage.update(value: 43, for: 1)

        // THEN
        let output = try await storage.content
        XCTAssertEqual(output, [1: 43])
    }
}
