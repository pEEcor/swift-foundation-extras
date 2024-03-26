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
        XCTAssertEqual(try cache.value(forKey: 1), 42)
    }

    func testInit_shouldMakeCacheDirectory_whenNotPresent() throws {
        // GIVEN
        let fileSystemAccessor = FileSystemAccessorBuilder()
            .withHasFile { _ in true }
            .withIsDirectory { _ in false }
            .build()

        let id = UUID()
        let config: FileCache<Int, Int>.Config = .default(fileSystemAccessor: fileSystemAccessor)

        // WHEN
        XCTAssertThrowsError(try FileCache(
            initialValues: [1: 42],
            id: id,
            config: config
        )) { error in
            XCTAssertEqual(error as! FileCacheError, .invalidCacheIdFileWithEqualNameAlreadyExists)
        }
    }

    func testContent_containEmptyDictionary_whenCacheDirectoryDoesNotExist() throws {
        // GIVEN
        let fileSystemAccessor = FileSystemAccessorBuilder()
            .build()

        let id = UUID()
        let config: FileCache<Int, Int>.Config = .default(fileSystemAccessor: fileSystemAccessor)
        let cache = try FileCache(initialValues: [1: 42], id: id, config: config)

        // WHEN
        try fileSystemAccessor.remove(config.url.appending(path: id.uuidString))
        let content = cache.content

        // THEN
        XCTAssertEqual(content, [:])
    }

    func testContent_containEmptyDictionary_whenDirectoryAccessFails() throws {
        struct Failure: Error, Equatable {}

        // GIVEN
        let fileSystemAccessor = FileSystemAccessorBuilder()
            .withContent { _ in throw Failure() }
            .build()

        let id = UUID()
        let config: FileCache<Int, Int>.Config = .default(fileSystemAccessor: fileSystemAccessor)
        let cache = try FileCache(initialValues: [1: 42], id: id, config: config)

        // WHEN
        let content = cache.content

        // THEN
        XCTAssertEqual(content, [:])
    }
    
    func testContent_ignoresFilesWhenReadingFails() throws {
        struct Failure: Error, Equatable {}

        // GIVEN
        let fileSystemAccessor = FileSystemAccessorBuilder()
            .withRead { _ in throw Failure() }
            .build()

        let id = UUID()
        let config: FileCache<Int, Int>.Config = .default(fileSystemAccessor: fileSystemAccessor)
        let cache = try FileCache(initialValues: [1: 42], id: id, config: config)

        // WHEN
        let content = cache.content

        // THEN
        XCTAssertEqual(content, [:])
    }

    func testContent_containInitialValues() throws {
        // GIVEN
        let fileSystemAccessor = FileSystemAccessorBuilder()
            .build()

        let id = UUID()
        let config: FileCache<Int, Int>.Config = .default(fileSystemAccessor: fileSystemAccessor)
        let cache = try FileCache(initialValues: [1: 42], id: id, config: config)

        // WHEN
        let content = cache.content

        // THEN
        XCTAssertEqual(content, [1: 42])
    }

    func testClear_deleteDirectory() throws {
        var directory: URL?

        // GIVEN
        let fileSystemAccessor = FileSystemAccessorBuilder()
            .withRemove { directory = $0 }
            .build()

        let id = UUID()
        let config: FileCache<Int, Int>.Config = .default(fileSystemAccessor: fileSystemAccessor)
        let cache = try FileCache(initialValues: [1: 42], id: id, config: config)

        // WHEN
        cache.clear()

        // THEN
        XCTAssertEqual(directory, config.url.appending(path: id.uuidString))
    }

    func testClear_doNothing_whenCacheDirectoryIsNotPresent() throws {
        var directory: URL?
        var isDirectory = true

        // GIVEN
        let fileSystemAccessor = FileSystemAccessorBuilder()
            .withIsDirectory { _ in isDirectory }
            .withRemove { directory = $0 }
            .build()

        let id = UUID()
        let config: FileCache<Int, Int>.Config = .default(fileSystemAccessor: fileSystemAccessor)
        let cache = try FileCache(initialValues: [1: 42], id: id, config: config)

        // WHEN
        isDirectory = false
        cache.clear()

        // THEN
        XCTAssertNil(directory)
    }
    
    func testInsert_insertValueForKey() throws {
        // GIVEN
        let fsAccessor = FileSystemAccessorBuilder()
            .build()
        
        let id = UUID()
        let config: FileCache<Int, Int>.Config = .default(fileSystemAccessor: fsAccessor)
        let cache = try FileCache(initialValues: [1: 42], id: id, config: config)
        
        // WHEN
        try cache.insert(43, forKey: 2)
        
        // THEN
        let output = try cache.value(forKey: 2)
        XCTAssertEqual(output, 43)
    }
    
    func testValue_returnValueForKey_whenKeyExists() throws {
        // GIVEN
        let cache = try FileCache(initialValues: [1: 42], id: UUID(), config: .default())
        
        // WHEN
        let output = try cache.value(forKey: 1)
        
        // THEN
        XCTAssertEqual(output, 42)
    }
    
    func testValue_returnNil_whenKeyDoesNotExist() throws {
        // GIVEN
        let cache = try FileCache(initialValues: [1: 42], id: UUID(), config: .default())
        
        // WHEN
        XCTAssertThrowsError(try cache.value(forKey: 2)) { error in
            // THEN
            XCTAssertEqual((error as NSError).code, 260)
        }
    }
    
    func testRemove_shouldRemove() throws {
        // GIVEN
        let cache = try FileCache(initialValues: [1: 42], id: UUID(), config: .default())
        
        // WHEN
        try cache.remove(forKey: 1)
        
        // THEN
        XCTAssertThrowsError(try cache.value(forKey: 2)) { error in
            // THEN
            XCTAssertEqual((error as NSError).code, 260)
        }
    }
    
    func testRemove_shouldNotDeleteFile_whenItDoesNotExist() throws {
        var didRemoveFile = false
        
        // GIVEN
        let fsAccessor = FileSystemAccessorBuilder()
            .withRemove { _ in didRemoveFile = true }
            .build()
        
        let id = UUID()
        let config: FileCache<Int, Int>.Config = .default(fileSystemAccessor: fsAccessor)
        let cache = try FileCache(initialValues: [1: 42], id: id, config: config)
        
        // WHEN
        XCTAssertThrowsError(try cache.remove(forKey: 2)) { error in
            // THEN
            XCTAssertEqual((error as NSError).code, 260)
        }
        
        XCTAssertFalse(didRemoveFile)
    }
}
