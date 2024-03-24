//
//  FileSystemAccessor.swift
//
//  Copyright © 2023 Paavo Becker.
//

import Foundation

/// The ``FileSystemAccessor`` provides a thin abstraction for operations on the file system. This
/// allows for definitions of file based components without a dependency on a concrete FileManager.
public struct FileSystemAccessor {
    /// Returns the contents of a folder
    public private(set) var contentsOfDirectory: (URL) throws -> [URL]

    /// Creates a folder at the given url
    public private(set) var createDirectory: (URL) throws -> Void

    /// Checks if file or folder exists
    public private(set) var fileExists: (URL) -> Bool

    /// Checks if the url points to a directory
    public private(set) var isDirectory: (URL) -> Bool

    /// Reads file at the given url from the file system
    public private(set) var read: (URL) throws -> Data

    /// Romoves file or folder at the given url from the file system
    public private(set) var remove: (URL) throws -> Void

    /// Writes data to the given url
    public private(set) var write: (Data, URL) throws -> Void

    /// Copies file at first URL to second URL
    public private(set) var copy: (URL, URL) throws -> Void

    /// Erzeugt einen FileSystemAccessor
    /// - Parameters:
    ///   - contentsOfDirectory: Returns the contents of a folder
    ///   - createDirectory: Creates a folder at the given url
    ///   - fileExists: Checks if file or folder exists
    ///   - isDirectory: Checks if the url points to a directory
    ///   - read: Reads file at the given url from the file system
    ///   - remove: Romoves file or folder at the given url from the file system
    ///   - write: Writes data to the given url
    public init(
        contentsOfDirectory: @escaping (URL) throws -> [URL],
        createDirectory: @escaping (URL) throws -> Void,
        fileExists: @escaping (URL) -> Bool,
        isDirectory: @escaping (URL) -> Bool,
        read: @escaping (URL) throws -> Data,
        remove: @escaping (URL) throws -> Void,
        write: @escaping (Data, URL) throws -> Void,
        copy: @escaping (URL, URL) throws -> Void
    ) {
        self.contentsOfDirectory = contentsOfDirectory
        self.createDirectory = createDirectory
        self.fileExists = fileExists
        self.isDirectory = isDirectory
        self.read = read
        self.remove = remove
        self.write = write
        self.copy = copy
    }

    /// A ``FileSystemAccessor`` that is based on a ``FileManager``
    ///
    /// - Parameter fileManager: The filemanager to use, defaults to  ``FileManager.default``
    /// - Returns: FileSystemAccessor
    public static func `default`(fileManager: FileManager = .default) -> Self {
        FileSystemAccessorBuilder(fileManager: fileManager).build()
    }
}
