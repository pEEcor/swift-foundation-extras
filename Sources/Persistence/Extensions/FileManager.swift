//
//  FileManager.swift
//
//  Copyright © 2022 Paavo Becker.
//

import Foundation

extension FileManager {
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
