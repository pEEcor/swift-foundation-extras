//
//  FileCacheTests.swift
//
//  Copyright © 2024 Paavo Becker.
//

import Persistence
import XCTest
import TestExtras

final class FileCacheTests: XCTestCase {
    func testInit_shouldCreateCacheDirectory_whenNotPresent() throws {
        let expectation = expectation(description: "create-directory")

        // GIVEN
        let id = UUID()
        let fileManager = MockFileManager()
        let config = FileCache<Int, Int>.Config(fileManager: fileManager)

        // WHEN
        fileManager.onCreateDirectory = { url in
            XCTAssertEqual(url, config.url.appending(path: id.uuidString))
            expectation.fulfill()
        }
        fileManager.onFileExists = { _ in false }
        let _: FileCache<Int, Int> = try FileCache(id: id, config: config)

        // THEN
        wait(for: [expectation], timeout: 3)
    }

    func testInit_shouldNotMakeCacheDirectory_whenPresent() throws {
        let expectation = expectation(description: "create-directory")
        expectation.isInverted = true
        
        // GIVEN
        let id = UUID()
        let fileManager = MockFileManager()
        let config = FileCache<Int, Int>.Config(fileManager: fileManager)
        
        // Make the first cache.
        fileManager.onFileExists = { _ in false }
        fileManager.onCreateDirectory = { _ in }
        let _: FileCache<Int, Int> = try FileCache(id: id, config: config)
        
        // WHEN
        // Make the second cache with the same id such that the directory already exists.
        fileManager.onFileExists = { _ in true }
        fileManager.onCreateDirectory = { _ in expectation.fulfill() }
        let _: FileCache<Int, Int> = try FileCache(id: id, config: config)

        // THEN
        wait(for: [expectation], timeout: 0.5)
    }
    
    func testInit_shouldInsertInitialValuesIntoCache_whenInitialValuesAreProvided() throws {
        let expectation = expectation(description: "write-file")

        // GIVEN
        let fileManager = MockFileManager()
        let config = FileCache<Int, Int>.Config(fileManager: fileManager)
        
        fileManager.onFileExists = { _ in true }
        fileManager.onCreateFile = { path, data in
            let (key, value) = try! config.decode(data!)
            XCTAssertEqual(key, 1)
            XCTAssertEqual(value, 42)
            expectation.fulfill()
            return true
        }
        
        // WHEN
        let _ = try FileCache(initialValues: [1: 42], config: config)

        // THEN
        wait(for: [expectation])
    }


    func testContent_containEmptyDictionary_whenCacheDirectoryDoesNotExist() throws {
        struct Failure: Error, Equatable {}
        
        // GIVEN
        let fileManager = MockFileManager()
        let config = FileCache<Int, Int>.Config(fileManager: fileManager)
        
        fileManager.onFileExists = { _ in false }
        fileManager.onCreateDirectory = { _ in }
        let cache = try FileCache(config: config)

        // WHEN
        fileManager.onContentsOfDirectory = { _ in throw Failure() }
        let content = cache.content

        // THEN
        XCTAssertEqual(content, [:])
    }

    func testContent_containEmptyPairs_whereAccessSucceeds() throws {
        struct Failure: Error, Equatable {}

        // GIVEN
        let fileManager = MockFileManager()
        let config = FileCache<Int, Int>.Config(fileManager: fileManager)
        
        fileManager.onFileExists = { _ in true }
        let cache = try FileCache(config: config)

        // Define the results that are returned or thrown when the content for a specific path
        // gets requested from the filemanager.
        let results: [Int: Result<Data, Failure>] = [
            1.hashValue: .success(try! config.encode(1, 42)),
            2.hashValue: .failure(Failure())
        ]
        
        // Define the paths that should be returned when reading the content of the cache directory.
        fileManager.onContentsOfDirectory = { directory in
            results.keys.map(String.init).map { directory.appending(path: $0) }
        }
        
        // Return the respective result based on the requested key.
        fileManager.onContents = { path in
            let hashValue = Int(URL(filePath: path).lastPathComponent)!
            return try? results[hashValue]?.get()
        }
        
        // WHEN
        let content = cache.content

        // THEN
        XCTAssertEqual(content, [1: 42])
    }

    func testClear_deleteCacheDirectory() throws {
        let expectation = expectation(description: "remove-directory")

        // GIVEN
        let id = UUID()
        let fileManager = MockFileManager()
        let config = FileCache<Int, Int>.Config(fileManager: fileManager)
        
        fileManager.onFileExists = { _ in true }
        fileManager.onRemove = { url in
            XCTAssertEqual(url, config.url.appending(path: id.uuidString))
            expectation.fulfill()
        }
        let cache = try FileCache(id: id, config: config)

        // WHEN
        cache.clear()

        // THEN
        wait(for: [expectation])
    }

    func testClear_doNothing_whenCacheDirectoryIsNotPresent() throws {
        let expectation = expectation(description: "remove-directory")
        expectation.isInverted = true

        // GIVEN
        let fileManager = MockFileManager()
        let config = FileCache<Int, Int>.Config(fileManager: fileManager)
        
        fileManager.onFileExists = { _ in true }
        let cache = try FileCache(config: config)
        
        fileManager.onFileExists = { _ in false }
        fileManager.onRemove = { _ in expectation.fulfill() }

        // WHEN
        cache.clear()

        // THEN
        wait(for: [expectation], timeout: 0.5)
    }

    func testInsert_insertValueForKey() throws {
        let expectation = expectation(description: "insert-key-value")

        // GIVEN
        let fileManager = MockFileManager()
        let config = FileCache<Int, Int>.Config(fileManager: fileManager)
        
        fileManager.onFileExists = { _ in true }
        let cache = try FileCache(config: config)
        
        fileManager.onCreateFile = { (path, data) in
            let (key, value) = try! config.decode(data!)
            XCTAssertEqual([key: value], [1: 42])
            expectation.fulfill()
            return true
        }

        // WHEN
        try cache.insert(42, forKey: 1)

        // THEN
        wait(for: [expectation])
    }
    
    func testInsert_throwError_whenFileOperationFails() throws {
        // GIVEN
        let fileManager = MockFileManager()
        let config = FileCache<Int, Int>.Config(fileManager: fileManager)
        
        fileManager.onFileExists = { _ in true }
        let cache = try FileCache(config: config)
        
        fileManager.onCreateFile = { _, _ in false }

        // WHEN
        XCTAssertThrowsError(try cache.insert(42, forKey: 1)) { error in
            // THEN
            XCTAssertEqual(error as! FileCacheFailure, .insufficientPermissions)
        }
    }

    func testValue_returnValueForKey_whenKeyExists() throws {
        let expectation = expectation(description: "read-key-value")

        // GIVEN
        let fileManager = MockFileManager()
        let config = FileCache<Int, Int>.Config(fileManager: fileManager)
        
        fileManager.onFileExists = { _ in true }
        let cache = try FileCache(config: config)
        
        fileManager.onContents = { path in
            XCTAssertEqual(Int(URL(filePath: path).lastPathComponent)!, 1.hashValue)
            expectation.fulfill()
            return try! config.encode(1, 42)
        }

        // WHEN
        _ = try cache.value(forKey: 1)

        // THEN
        wait(for: [expectation])
    }

    func testRemove_shouldRemove() throws {
        let expectation = expectation(description: "remove-key-value")

        // GIVEN
        let fileManager = MockFileManager()
        let config = FileCache<Int, Int>.Config(fileManager: fileManager)
        
        fileManager.onFileExists = { _ in true }
        let cache = try FileCache(config: config)
        
        fileManager.onContents = { path in
            XCTAssertEqual(Int(URL(filePath: path).lastPathComponent)!, 1.hashValue)
            expectation.fulfill()
            return try! config.encode(1, 42)
        }
        
        fileManager.onRemove = { url in }
        
        // WHEN
        _ = try cache.remove(forKey: 1)

        // THEN
        wait(for: [expectation])
    }

    func testRemove_shouldNotDeleteFile_whenItDoesNotExist() throws {
        let expectation = expectation(description: "remove-key-value")
        expectation.isInverted = true

        // GIVEN
        let fileManager = MockFileManager()
        let config = FileCache<Int, Int>.Config(fileManager: fileManager)
        
        fileManager.onFileExists = { _ in true }
        let cache = try FileCache(config: config)
        
        fileManager.onContents = { path in
            XCTAssertEqual(Int(URL(filePath: path).lastPathComponent)!, 1.hashValue)
            return try! config.encode(1, 42)
        }
        
        fileManager.onFileExists = { _ in false }
        fileManager.onRemove = { url in expectation.fulfill() }
        
        // WHEN
        _ = try cache.remove(forKey: 1)

        // THEN
        wait(for: [expectation], timeout: 0.5)
    }
}
