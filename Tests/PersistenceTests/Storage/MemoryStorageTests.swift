//
//  MemoryStorageTests.swift
//
//  Copyright © 2024 Paavo Becker.
//

import Persistence
import XCTest

final class MemoryStorageTests: XCTestCase {
    func testInit_insertInitialValues_whenProvided() throws {
        // GIVEN
        let values = ["foo": 42]

        // WHEN
        let storage = MemoryStorage(initialValue: values)

        // THEN
        XCTAssertEqual(try storage.value(for: "foo"), 42)
    }

    func testContent_containsContent() throws {}
}
