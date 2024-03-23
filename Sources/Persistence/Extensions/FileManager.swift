//
//  FileManager.swift
//
//  Copyright © 2022 Paavo Becker.
//

import Foundation

extension FileManager {
    /// Returns true if the given path points to a directory
    /// - Parameter path: The path to check
    /// - Returns: True if path points to directory
    public func directoryExists(atPath path: String) -> Bool {
        var isDirectory = ObjCBool(true)
        let exists = self.fileExists(atPath: path, isDirectory: &isDirectory)
        return exists && isDirectory.boolValue
    }
}
