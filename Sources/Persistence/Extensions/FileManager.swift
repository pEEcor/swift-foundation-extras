//
//  FileManager.swift
//  groceries-client-ios
//
//  Created by Paavo Becker on 01.08.22.
//

import Foundation

public extension FileManager {
    /// Returns true if the given path points to a directory
    /// - Parameter path: The path to check
    /// - Returns: True if path points to directory
    func directoryExists(atPath path: String) -> Bool {
        var isDirectory = ObjCBool(true)
        let exists = self.fileExists(atPath: path, isDirectory: &isDirectory)
        return exists && isDirectory.boolValue
    }
}
