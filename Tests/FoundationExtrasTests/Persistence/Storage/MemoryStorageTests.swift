//
//  MemoryStorageTests.swift
//
//  Copyright © 2024 Paavo Becker.
//

import FoundationExtras
import XCTest

final class MemoryStorageTests: XCTestCase {
    func testInit_insertInitialValues_whenProvided() throws {
        // GIVEN
        let values = ["foo": 42, "bar": 43]

        // WHEN
        let storage = MemoryStorage(initialValue: values)

        // THEN
        XCTAssertEqual(try storage.value(for: "foo"), 42)
        XCTAssertEqual(try storage.value(for: "bar"), 43)
    }

    func testKey_containAllKeys() throws {
        // GIVEN
        let storage = MemoryStorage(initialValue: ["foo": 42, "bar": 43])

        // WHEN
        let output = storage.keys

        // THEN
        XCTAssertTrue(output.contains("foo"))
        XCTAssertTrue(output.contains("bar"))
    }

    func testInsert_insertsValue_whenKeyDoesNotExist() throws {
        // GIVEN
        let storage = MemoryStorage(initialValue: ["foo": 42])

        // WHEN
        try storage.insert(value: 43, for: "bar")

        // THEN
        XCTAssertEqual(try storage.value(for: "bar"), 43)
    }

    func testInsert_throwError_whenKeyAlreadyExists() throws {
        // GIVEN
        let storage = MemoryStorage(initialValue: ["foo": 42])

        // WHEN
        XCTAssertThrowsError(try storage.insert(value: 43, for: "foo")) { error in
            // THEN
            XCTAssertEqual(error as! MemoryStorageError, .keyAlreadyExists)
        }
    }

    func testRemove_removeKeyValuePairFromStorage_whenKeyExists() throws {
        // GIVEN
        let storage = MemoryStorage(initialValue: ["foo": 42])

        // WHEN
        try storage.remove(for: "foo")

        // THEN
        XCTAssertEqual(try storage.content, [:])
    }

    func testValue_returnValueForKey_whenKeyExists() throws {
        // GIVEN
        let storage = MemoryStorage(initialValue: ["foo": 42])

        // WHEN
        let output = try storage.value(for: "foo")

        // THEN
        XCTAssertEqual(output, 42)
    }

    func testValue_throwError_whenKeyDoesNotExist() throws {
        // GIVEN
        let storage = MemoryStorage(initialValue: ["foo": 42])

        // WHEN
        XCTAssertThrowsError(try storage.value(for: "bar")) { error in
            // THEN
            XCTAssertEqual(error as! MemoryStorageError, .keyDoesNotExist)
        }
    }
}
