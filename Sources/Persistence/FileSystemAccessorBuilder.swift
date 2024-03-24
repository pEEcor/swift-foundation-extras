//
//  FileSystemAccessorBuilder.swift
//
//  Copyright © 2024 Paavo Becker.
//

import Foundation

public class FileSystemAccessorBuilder {
    private var content: (URL) throws -> [URL]
    private var createDirectory: (URL) throws -> Void
    private var hasFile: (URL) -> Bool
    private var isDirectory: (URL) -> Bool
    private var read: (URL) throws -> Data
    private var remove: (URL) throws -> Void
    private var write: (Data, URL) throws -> Void
    private var copy: (URL, URL) throws -> Void

    public init(fileManager: FileManager = .default) {
        self.content = { url in
            try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
        }
        self.createDirectory = { url in
            try fileManager.createDirectory(at: url, withIntermediateDirectories: true)
        }
        self.hasFile = { fileManager.fileExists(atPath: $0.path()) }
        self.isDirectory = { fileManager.directoryExists(atPath: $0.path()) }
        self.read = { try Data(contentsOf: $0) }
        self.remove = { try fileManager.removeItem(at: $0) }
        self.write = { try $0.write(to: $1) }
        self.copy = { try fileManager.copyItem(at: $0, to: $1) }
    }

    public func content(_ operation: @escaping (URL) throws -> [URL]) -> Self {
        self.content = operation
        return self
    }

    public func withCreateDirectory(_ operation: @escaping (URL) throws -> Void) -> Self {
        self.createDirectory = operation
        return self
    }

    public func withHasFile(_ operation: @escaping (URL) -> Bool) -> Self {
        self.hasFile = operation
        return self
    }

    public func withIsDirectory(_ operation: @escaping (URL) -> Bool) -> Self {
        self.isDirectory = operation
        return self
    }

    public func withRead(_ operation: @escaping (URL) throws -> Data) -> Self {
        self.read = operation
        return self
    }

    public func withRemove(_ operation: @escaping (URL) throws -> Void) -> Self {
        self.remove = operation
        return self
    }

    public func withWrite(_ operation: @escaping (Data, URL) throws -> Void) -> Self {
        self.write = operation
        return self
    }

    public func withCopy(_ operation: @escaping (URL, URL) throws -> Void) -> Self {
        self.copy = self.copy
        return self
    }

    public func build() -> FileSystemAccessor {
        FileSystemAccessor(
            contentsOfDirectory: self.content,
            createDirectory: self.createDirectory,
            fileExists: self.hasFile,
            isDirectory: self.isDirectory,
            read: self.read,
            remove: self.remove,
            write: self.write,
            copy: self.copy
        )
    }
}
