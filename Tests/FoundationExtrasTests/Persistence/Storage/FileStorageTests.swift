//
//  FileStorageTests.swift
//
//  Copyright © 2024 Paavo Becker.
//

import Foundation
import FoundationExtras
import MockExtras
import XCTest

// MARK: - FileStorageTests

final class FileStorageTests: XCTestCase {
    func testInit_setConfig() {
        // GIVEN
        let config = FileStorage<Int, Int>.Config()

        // WHEN
        let storage = FileStorage(config: config)

        // THEN
        XCTAssertEqual(storage.config.url, config.url)
    }

    func testKeys_containAllKeys() throws {
        // GIVEN
        let fileManager = MockFileManager()
        let config = FileStorage<Int, Int>.Config(fileManager: fileManager)
        let storage = FileStorage(config: config)

        fileManager.onFileExists = { $0 == config.url }
        fileManager.onCreateFile = { _, _ in true }
        try storage.insert(value: 1, for: 42)

        // WHEN
        fileManager.onFileExists = { _ in true }
        fileManager.onContentsOfDirectory = { _ in
            [URL(string: self.makeKeyComponent(key: "1"))!]
        }
        let output = storage.keys

        // THEN
        XCTAssertEqual(output, [1])
    }

    func testKeys_beEmpty_whenStorageDirectoryDoesNotExist() throws {
        // GIVEN
        let fileManager = MockFileManager()
        let config = FileStorage<Int, Int>.Config(fileManager: fileManager)
        let storage = FileStorage(config: config)

        // WHEN
        fileManager.onFileExists = { _ in false }
        let output = storage.keys

        // THEN
        XCTAssertEqual(output, [])
    }

    func testKeys_beEmpty_whenReadingStorageDirectoryFails() throws {
        struct Failure: Error, Equatable {}

        // GIVEN
        let fileManager = MockFileManager()
        let config = FileStorage<Int, Int>.Config(fileManager: fileManager)
        let storage = FileStorage(config: config)

        // WHEN
        fileManager.onFileExists = { _ in true }
        fileManager.onContentsOfDirectory = { _ in throw Failure() }
        let output = storage.keys

        // THEN
        XCTAssertEqual(output, [])
    }

    func testInsert_throwError_whenKeyAlreadyExists() throws {
        // GIVEN
        let fileManager = MockFileManager()
        let config = FileStorage<Int, Int>.Config(fileManager: fileManager)
        let storage = FileStorage(config: config)

        // WHEN
        fileManager.onFileExists = { _ in true }
        XCTAssertThrowsError(try storage.insert(value: 1, for: 42)) { error in
            // THEN
            XCTAssertEqual(error as! FileStorageFailure, .fileAlreadyExists)
        }
    }

    func testInsert_throwError_whenFileCreationFails() throws {
        // GIVEN
        let fileManager = MockFileManager()
        let config = FileStorage<Int, Int>.Config(fileManager: fileManager)
        let storage = FileStorage(config: config)

        // WHEN
        fileManager.onFileExists = { $0 == config.url }
        fileManager.onCreateFile = { _, _ in false }
        XCTAssertThrowsError(try storage.insert(value: 1, for: 42)) { error in
            // THEN
            XCTAssertEqual(error as! FileStorageFailure, .writeFailure)
        }
    }

    func testInsert_createStorageDirectory_whenNotPresent() throws {
        let expectation = expectation(description: "create-directory")

        // GIVEN
        let fileManager = MockFileManager()
        let config = FileStorage<Int, Int>.Config(fileManager: fileManager)
        let storage = FileStorage(config: config)

        // WHEN
        fileManager.onFileExists = { _ in false }
        fileManager.onCreateFile = { _, _ in true }
        fileManager.onCreateDirectory = { _ in expectation.fulfill() }
        try storage.insert(value: 1, for: 42)

        // THEN
        wait(for: [expectation], timeout: 0.5)
    }

    func testRemove_doNothing_whenKeyDoesNotExist() throws {
        let expectation = expectation(description: "remove-file")
        expectation.isInverted = true

        // GIVEN
        let fileManager = MockFileManager()
        let config = FileStorage<Int, Int>.Config(fileManager: fileManager)
        let storage = FileStorage(config: config)

        // WHEN
        fileManager.onFileExists = { _ in false }
        fileManager.onRemoveItem = { _ in expectation.fulfill() }
        try storage.remove(for: 1)

        // THEN
        wait(for: [expectation], timeout: 0.5)
    }

    func testRemove_removeFile_whenKeyExists() throws {
        let expectation = expectation(description: "remove-file")

        // GIVEN
        let fileManager = MockFileManager()
        let config = FileStorage<Int, Int>.Config(fileManager: fileManager)
        let storage = FileStorage(config: config)

        // WHEN
        fileManager.onFileExists = { _ in true }
        fileManager.onRemoveItem = { _ in expectation.fulfill() }
        try storage.remove(for: 1)

        // THEN
        wait(for: [expectation], timeout: 0.5)
    }

    func testValue_returnValue_whenItExists() throws {
        // GIVEN
        let fileManager = MockFileManager()
        let valueCoder: AnyCoder<Data> = JSONCoder().eraseToAnyCoder()
        let config = FileStorage<Int, Int>.Config(valueCoder: valueCoder, fileManager: fileManager)
        let storage = FileStorage(config: config)

        // WHEN
        fileManager.onFileExists = { _ in true }
        fileManager.onContents = { _ in try? valueCoder.encode(42) }
        let output = try storage.value(for: 1)

        // THEN
        XCTAssertEqual(output, 42)
    }

    func testValue_throwError_whenFileDoesNotExist() throws {
        // GIVEN
        let fileManager = MockFileManager()
        let config = FileStorage<Int, Int>.Config(fileManager: fileManager)
        let storage = FileStorage(config: config)

        // WHEN
        fileManager.onFileExists = { _ in false }
        XCTAssertThrowsError(try storage.value(for: 1)) { error in
            // THEN
            XCTAssertEqual(error as! FileStorageFailure, .fileDoesNotExist)
        }
    }

    func testValue_throwError_whenReadingFileFails() throws {
        // GIVEN
        let fileManager = MockFileManager()
        let config = FileStorage<Int, Int>.Config(fileManager: fileManager)
        let storage = FileStorage(config: config)

        // WHEN
        fileManager.onFileExists = { _ in true }
        fileManager.onContents = { _ in nil }
        XCTAssertThrowsError(try storage.value(for: 1)) { error in
            // THEN
            XCTAssertEqual(error as! FileStorageFailure, .readFailure)
        }
    }

    private func makeKeyComponent(key: String) -> String {
        key.data(using: .utf8)!.base64EncodedString()
    }
}

// MARK: - FileStorageConfigTests

final class FileStorageConfigTests: XCTestCase {
    func testDefault_createDefaultConfiguration() {
        // GIVEN / WHEN
        let sut = FileStorage<Int, Int>.Config.default

        // THEN
        XCTAssertEqual(sut.url, URL.documentsDirectory)
    }
}
