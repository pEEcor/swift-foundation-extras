//
//  FileManager.swift
//
//  Copyright © 2022 Paavo Becker.
//

import Foundation

extension FileManager {
    /// Returns a `Data` object that contains the file content at the given url.
    ///
    /// If no file exists a the given url, nil is returned.
    /// - Parameter url: Url to the desired file.
    /// - Returns: Data object.
    public func contents(at url: URL) -> Data? {
        self.contents(atPath: url.path())
    }
    
    /// Provides the Array with urls to all elements in this directory.
    ///
    /// - Parameter url: The url to the directory.
    /// - Returns: Urls to all files inside the directory.
    public func contentsOfDirectory(at url: URL) throws -> [URL] {
        try self.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
    }

    /// Writes data into file at the given location.
    ///
    /// When a file exists at the given url, that file will be overriden with the new data.
    ///
    /// - Parameters:
    ///   - url: The location where the file should be stored.
    ///   - data: The data that should be stored.
    ///   - attr: Attributes for the file.
    /// - Returns: True when the creation succeeds, otherwise false.
    @discardableResult
    public func createFile(
        at url: URL,
        contents data: Data?,
        attributes attr: [FileAttributeKey: Any]? = nil
    ) -> Bool {
        self.createFile(atPath: url.path(), contents: data, attributes: attr)
    }

    /// Returns true if the given path points to a directory.
    ///
    /// - Parameter path: The path to check.
    /// - Returns: True if path points to directory.
    public func directoryExists(atPath path: String) -> Bool {
        var isDirectory = ObjCBool(true)
        let exists = self.fileExists(atPath: path, isDirectory: &isDirectory)
        return exists && isDirectory.boolValue
    }

    /// Returns true if the given url points to a directory.
    ///
    /// - Parameter url: The url to check.
    /// - Returns: True if url points to directory.
    public func directoryExists(at url: URL) -> Bool {
        self.directoryExists(atPath: url.path())
    }

    /// Returns true if a file at the given url exists.
    ///
    /// - Parameter url: the url to check.
    /// - Returns: True if a file exists a the url.
    public func fileExists(at url: URL) -> Bool {
        self.directoryExists(atPath: url.path())
    }
}
