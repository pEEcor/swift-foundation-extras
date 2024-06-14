//
//  MemoryStorageTests.swift
//
//  Copyright © 2024 Paavo Becker.
//

import FoundationExtras
import XCTest

// MARK: - MemoryStorageTests

final class MemoryStorageTests: XCTestCase {
    func testInit_insertInitialValues_whenProvided() async throws {
        // GIVEN
        let values = ["foo": 42, "bar": 43]

        // WHEN
        let storage = MemoryStorage(initialValue: values)

        // THEN
        let output1 = try await storage.value(for: "foo")
        let output2 = try await storage.value(for: "bar")
        XCTAssertEqual(output1, 42)
        XCTAssertEqual(output2, 43)
    }

    func testKey_containAllKeys() async throws {
        // GIVEN
        let storage = MemoryStorage(initialValue: ["foo": 42, "bar": 43])

        // WHEN
        let output = await storage.keys

        // THEN
        XCTAssertTrue(output.contains("foo"))
        XCTAssertTrue(output.contains("bar"))
    }

    func testInsert_insertsValue_whenKeyDoesNotExist() async throws {
        // GIVEN
        let storage = MemoryStorage(initialValue: ["foo": 42])

        // WHEN
        try await storage.insert(value: 43, for: "bar")

        // THEN
        let output = try await storage.value(for: "bar")
        XCTAssertEqual(output, 43)
    }

    func testInsert_throwError_whenKeyAlreadyExists() async throws {
        // GIVEN
        let storage = MemoryStorage(initialValue: ["foo": 42])

        // WHEN
        await XCTAssertThrowsError(try await storage.insert(value: 43, for: "foo")) { error in
            // THEN
            XCTAssertEqual(error as! MemoryStorageError, .keyAlreadyExists)
        }
    }

    func testRemove_removeKeyValuePairFromStorage_whenKeyExists() async throws {
        // GIVEN
        let storage = MemoryStorage(initialValue: ["foo": 42])

        // WHEN
        try await storage.remove(for: "foo")

        // THEN
        let output = try await storage.content
        XCTAssertEqual(output, [:])
    }

    func testValue_returnValueForKey_whenKeyExists() async throws {
        // GIVEN
        let storage = MemoryStorage(initialValue: ["foo": 42])

        // WHEN
        let output = try await storage.value(for: "foo")

        // THEN
        XCTAssertEqual(output, 42)
    }

    func testValue_throwError_whenKeyDoesNotExist() async throws {
        // GIVEN
        let storage = MemoryStorage(initialValue: ["foo": 42])

        // WHEN
        await XCTAssertThrowsError(try await storage.value(for: "bar")) { error in
            // THEN
            XCTAssertEqual(error as! MemoryStorageError, .keyDoesNotExist)
        }
    }
}
