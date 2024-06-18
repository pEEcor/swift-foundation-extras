//
//  MockFileManagerTests.swift
//
//  Copyright © 2024 Paavo Becker.
//

import FoundationExtras
import MockExtras
import XCTest

final class MockFileManagerTests: XCTestCase {
    func testContents_callsOnContents() throws {
        let expectation = expectation(description: "call-onContents")

        // GIVEN
        let sut = MockFileManager()
        sut.onContents = { _ in
            expectation.fulfill()
            return nil
        }

        // WHEN
        _ = sut.contents(atPath: "test")

        // THEN
        wait(for: [expectation])
    }

    func testContentsOfDirectory_callOnContentsOfDirectory() throws {
        let expectation = expectation(description: "call-onContentsOfDirectory")

        // GIVEN
        let sut = MockFileManager()
        sut.onContentsOfDirectory = { _ in
            expectation.fulfill()
            return []
        }

        // WHEN
        _ = try sut.contentsOfDirectory(at: URL(string: "test")!)

        // THEN
        wait(for: [expectation])
    }

    func testCopyItem_callOnCopyItem() throws {
        let expectation = expectation(description: "call-onCopyItem")

        // GIVEN
        let sut = MockFileManager()
        sut.onCopyItem = { _, _ in
            expectation.fulfill()
        }

        // WHEN
        try sut.copyItem(at: URL(string: "source")!, to: URL(string: "destination")!)

        // THEN
        wait(for: [expectation])
    }

    func testCreateDirectory_callOnCreateDirectory() throws {
        let expectation = expectation(description: "call-onCreateDirectory")

        // GIVEN
        let sut = MockFileManager()
        sut.onCreateDirectory = { _ in
            expectation.fulfill()
        }

        // WHEN
        try sut.createDirectory(at: URL(string: "test")!, withIntermediateDirectories: true)

        // THEN
        wait(for: [expectation])
    }

    func testCreateFile_callOnCreateFile() {
        let expectation = expectation(description: "call-onCreateFile")

        // GIVEN
        let sut = MockFileManager()
        sut.onCreateFile = { _, _ in
            expectation.fulfill()
            return true
        }

        // WHEN
        sut.createFile(at: URL(string: "test")!, contents: nil)

        // THEN
        wait(for: [expectation])
    }

    func testFileExists_callOnFileExists() {
        let expectation = expectation(description: "call-onFileExists")

        // GIVEN
        let sut = MockFileManager()
        sut.onFileExists = { _ in
            expectation.fulfill()
            return true
        }

        // WHEN
        _ = sut.fileExists(at: URL(string: "test")!)

        // THEN
        wait(for: [expectation])
    }

    func testRemoveItem_callOnRemoveItem() throws {
        let expectation = expectation(description: "call-onRemoveItem")

        // GIVEN
        let sut = MockFileManager()
        sut.onRemoveItem = { _ in
            expectation.fulfill()
        }

        // WHEN
        _ = try sut.removeItem(at: URL(string: "test")!)

        // THEN
        wait(for: [expectation])
    }
}
