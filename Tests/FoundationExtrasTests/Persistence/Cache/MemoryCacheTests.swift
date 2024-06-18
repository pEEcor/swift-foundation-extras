//
//  MemoryCacheTests.swift
//
//  Copyright © 2024 Paavo Becker.
//

import FoundationExtras
import XCTest

final class MemoryCacheTests: XCTestCase {
    func testInit_createEmptyCache_whenNoValuesAreProvided() throws {
        // GIVEN / WHEN
        let cache: MemoryCache<Int, Int> = MemoryCache()

        // THEN
        XCTAssertEqual(cache.content, [:])
    }

    func testInit_insertInitialValues_whenValuesAreProvided() throws {
        // GIVEN
        let content = [1: 42]

        // WHEN
        let cache = MemoryCache(initialValues: content)

        // THEN
        XCTAssertEqual(cache.content, content)
    }

    func testContent_containCacheContent() throws {
        // GIVEN
        let content = [1: 42]

        // WHEN
        let cache = MemoryCache(initialValues: content)

        // THEN
        XCTAssertEqual(cache.content, content)
    }

    func testClear_removeAllContentFromCache() throws {
        // GIVEN
        let cache = MemoryCache(initialValues: [1: 42])

        // WHEN
        cache.clear()

        // THEN
        XCTAssertEqual(cache.content, [:])
    }

    func testInsert_insertKeyValuePairIntoCache() throws {
        // GIVEN
        let cache: MemoryCache<Int, Int> = MemoryCache()

        // WHEN
        cache.insert(42, forKey: 1)

        // THEN
        XCTAssertEqual(cache.content, [1: 42])
    }

    func testInsert_overrideValue_whenKeyAlreadyExists() throws {
        // GIVEN
        let cache = MemoryCache(initialValues: [1: 42])

        // WHEN
        cache.insert(43, forKey: 1)

        // THEN
        XCTAssertEqual(cache.content, [1: 43])
    }

    func testValue_returnValueForKey_whenEntryExists() throws {
        // GIVEN
        let cache = MemoryCache(initialValues: [1: 42])

        // WHEN
        let output = try cache.value(forKey: 1)

        // THEN
        XCTAssertEqual(output, 42)
    }

    func testValue_throwError_whenEntryDoesNotExist() throws {
        // GIVEN
        let cache = MemoryCache(initialValues: [1: 42])

        // WHEN
        XCTAssertThrowsError(try cache.value(forKey: 2)) { error in
            // THEN
            XCTAssertEqual(error as! MemoryCacheError, .missingValueForKey)
        }
    }

    func testRemove_removeKeyValuePair() throws {
        // GIVEN
        let cache = MemoryCache(initialValues: [1: 42, 2: 43])

        // WHEN
        try cache.remove(forKey: 1)

        // THEN
        XCTAssertEqual(cache.content, [2: 43])
    }
}
