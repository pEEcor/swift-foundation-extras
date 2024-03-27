//
//  MockFileManager.swift
//
//  Copyright © 2024 Paavo Becker.
//

import Foundation
import XCTestDynamicOverlay

public final class MockFileManager: FileManager {
    public var onContents: (String) -> Data? =
        unimplemented("MockFileManager.onContents")

    public var onContentsOfDirectory: (URL) throws -> [URL] =
        unimplemented("MockFileManager.onContentsOfDirectory")

    public var onCopyItem: (URL, URL) throws -> Void =
        unimplemented("MockFileManager.onCopyItem")

    public var onCreateDirectory: (URL) throws -> Void =
        unimplemented("MockFileManager.onCreateDirectory")

    public var onCreateFile: (String, Data?) -> Bool =
        unimplemented("MockFileManager.onCreateFile")

    public var onFileExists: (String) -> Bool =
        unimplemented("MockFileManager.onFileExists")

    public var onRemove: (URL) throws -> Void =
        unimplemented("MockFileManager.onRemove")

    override public init() {
        super.init()
    }

    override public func contents(atPath path: String) -> Data? {
        self.onContents(path)
    }

    override public func contentsOfDirectory(
        at url: URL,
        includingPropertiesForKeys keys: [URLResourceKey]?,
        options mask: FileManager.DirectoryEnumerationOptions = []
    ) throws -> [URL] {
        try self.onContentsOfDirectory(url)
    }

    override public func copyItem(at srcURL: URL, to dstURL: URL) throws {
        try self.onCopyItem(srcURL, dstURL)
    }

    override public func createDirectory(
        at url: URL,
        withIntermediateDirectories createIntermediates: Bool,
        attributes: [FileAttributeKey: Any]? = nil
    ) throws {
        try self.onCreateDirectory(url)
    }

    override public func createFile(
        atPath path: String,
        contents data: Data?,
        attributes attr: [FileAttributeKey: Any]? = nil
    ) -> Bool {
        self.onCreateFile(path, data)
    }

    override public func fileExists(
        atPath path: String,
        isDirectory: UnsafeMutablePointer<ObjCBool>?
    ) -> Bool {
        self.onFileExists(path)
    }

    override public func removeItem(at url: URL) throws {
        try self.onRemove(url)
    }
}
