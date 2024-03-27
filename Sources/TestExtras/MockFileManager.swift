//
//  MockFileManager.swift
//
//  Copyright © 2024 Paavo Becker.
//

import Foundation
import XCTestDynamicOverlay

/// A derived Filemanager that allows to override common operations of the FileManager. This comes
/// in handy when writing Tests.
public final class MockFileManager: FileManager {
    /// Action that is executed when file at the given url is read.
    public var onContents: (URL) -> Data? =
        unimplemented("MockFileManager.onContents")

    /// Action that is executed when the urls of all files inside the given directory are queried.
    public var onContentsOfDirectory: (URL) throws -> [URL] =
        unimplemented("MockFileManager.onContentsOfDirectory")

    /// Action that is executed when content of source url is copied into destination url.
    public var onCopyItem: (URL, URL) throws -> Void =
        unimplemented("MockFileManager.onCopyItem")

    /// Action that is executed when a directory at the given url is created.
    public var onCreateDirectory: (URL) throws -> Void =
        unimplemented("MockFileManager.onCreateDirectory")

    /// Action that is executed when a file at the given url is created.
    public var onCreateFile: (URL, Data?) -> Bool =
        unimplemented("MockFileManager.onCreateFile")

    /// Action that is executed to check the existence of a file behind the given url.
    public var onFileExists: (URL) -> Bool =
        unimplemented("MockFileManager.onFileExists")

    /// Action that is executed when file at url is deleted
    public var onRemove: (URL) throws -> Void =
        unimplemented("MockFileManager.onRemove")

    /// Creates a `MockFileManager`.
    override public init() {
        super.init()
    }
    
    override public func contents(atPath path: String) -> Data? {
        self.onContents(URL(fileURLWithPath: path, isDirectory: true))
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
        self.onCreateFile(URL(fileURLWithPath: path), data)
    }

    override public func fileExists(
        atPath path: String,
        isDirectory: UnsafeMutablePointer<ObjCBool>?
    ) -> Bool {
        self.onFileExists(URL(fileURLWithPath: path))
    }

    override public func removeItem(at url: URL) throws {
        try self.onRemove(url)
    }
}
