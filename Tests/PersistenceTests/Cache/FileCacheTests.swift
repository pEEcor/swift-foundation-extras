//
//  FileCacheTests.swift
//
//  Copyright © 2024 Paavo Becker.
//

import Persistence
import XCTest

final class FileCacheTests: XCTestCase {
    func testInit_shouldCreateCacheDirectory_whenNotPresent() throws {
        var directory: URL? = nil

        // GIVEN
        // A random id will always force the creation of a new cache directory
        let id = UUID()
        let fileSystemAccessor = FileSystemAccessorBuilder()
            .withCreateDirectory { url in directory = url }
            .build()

        let config: FileCache<Int, Int>.Config = .default(fileSystemAccessor: fileSystemAccessor)

        // WHEN
        let _: FileCache<Int, Int> = try FileCache(id: id, config: config)

        // THEN
        XCTAssertEqual(config.url.appending(path: id.uuidString), directory)
    }

    func testInit_shouldInsertInitialValuesIntoCache_whenInitialValuesAreProvided() throws {
        // GIVEN
        let id = UUID()
        let fileSystemAccessor = FileSystemAccessorBuilder()
            .build()

        let config: FileCache<Int, Int>.Config = .default(fileSystemAccessor: fileSystemAccessor)

        // WHEN
        let cache: FileCache = try FileCache(initialValues: [1: 42], id: id, config: config)

        // THEN
        XCTAssertEqual(cache.value(forKey: 1), 42)
    }
}
