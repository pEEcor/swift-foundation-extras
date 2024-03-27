//
//  FileStorage.swift
//
//  Copyright © 2024 Paavo Becker.
//

import ConcurrencyExtras
import Foundation

// MARK: - FileStorage

/// A ``Storage`` implementation that stores to the filesystem. The storage can handle one
/// particular type of values which need to be codable.
///
/// > Tip: If storage of multiple types is required, transform your values to a uniform type before
/// storing them, i.e. ``Data``.
public class FileStorage<Value: Codable> {
    /// The configuration of the file storage.
    public let config: Config

    /// Manager that handles all observers of this file storage.
    private let observerManager: ObserverManager

    // MARK: - Init

    /// Creates a FileStorage
    /// - Parameter config: The configuration of the FileStorage
    public init(
        config: Config
    ) {
        self.config = config
        self.observerManager = ObserverManager()
    }
}

// MARK: Storage

extension FileStorage: Storage {
    public func create(
        name: String,
        value: Value
    ) throws {
        let fileUrl = try self.makeURL(for: name)
        guard !self.config.fileManager.fileExists(at: fileUrl) else {
            throw Error.fileAlreadyExists
        }

        // Create url without filename component.
        let folderUrl = fileUrl.deletingLastPathComponent()

        // Check if target directory exists.
        if !self.config.fileManager.directoryExists(at: folderUrl) {
            // Create target directory that holds the values of this FileStorage.
            try self.config.fileManager
                .createDirectory(at: folderUrl, withIntermediateDirectories: false)
        }

        logger.info("Writing \(Value.self) to \(fileUrl)")

        // Encode and write value
        try self.config.encode(value).write(to: fileUrl)
    }

    public func delete(
        name: String
    ) throws {
        let url = try self.makeURL(for: name)

        // Deletion is gracefully ignored if file or directory does not exist
        guard self.config.fileManager.fileExists(at: url) else {
            return
        }

        logger.info("Deleting \(Value.self) \(url)")

        try self.config.fileManager.removeItem(at: url)
    }

    public func delete() throws {
        guard self.config.fileManager.fileExists(at: self.config.url) else {
            return
        }

        logger.info("Deleting directory \(self.config.url)")

        try self.config.fileManager.removeItem(at: self.config.url)
    }

    public func observe<Element: Equatable>(
        keyPath: KeyPath<Value, Element>
    ) -> AsyncStream<StorageEvent<Element>> {
        AsyncStream<StorageEvent<Element>> { continuation in
            // Register termination action. This ensures that the observation gets removed
            // automatically when the callsite drops the returned stream.
            continuation.onTermination = { _ in self.observerManager.remove(keyPath: keyPath) }

            // Add observer
            self.observerManager.add(
                keyPath: keyPath,
                emit: { continuation.yield($0) },
                finish: { continuation.finish() }
            )
        }
    }

    public func read(
        name: String
    ) throws -> Value {
        let url = try self.makeURL(for: name)

        logger.info("Reading \(Value.self) from \(url)")

        return try self.config.decode(self.read(url: url))
    }

    public func read() throws -> [Value] {
        // Make sure that the target directory exists, otherwise return empty array
        guard self.config.fileManager.fileExists(at: self.config.url) else {
            return []
        }

        // Read in all files from target directory and filter out the contained directories
        let urls = try self.config.fileManager
            .contentsOfDirectory(at: self.config.url)
            .filter { !self.config.fileManager.directoryExists(at: $0) }

        logger.info("Reading \(Value.self)'s from \(self.config.url)")

        // Read in all files and try to decode them. If decoding fails, the file will be gracefully
        // ignored and not returned in the output of this function
        return try urls.compactMap { url in
            let data = try self.read(url: url)
            return try? self.config.decode(data)
        }
    }

    public func update(
        name: String,
        value: Value
    ) throws {
        let url = try self.makeURL(for: name)

        if self.config.fileManager.fileExists(at: url) {
            // Remember the previous value.
            let prev = try self.read(name: name)

            // Update stored value to the new value.
            try self.delete(name: name)
            try self.create(name: name, value: value)

            // Notify observers.
            self.observerManager.notify(prev: prev, next: value)
        } else {
            try self.create(name: name, value: value)
        }
    }

    // MARK: - Private

    /// Create url
    ///
    /// - Parameter fileName: Name of file
    /// - Parameter dirName: Name of directory inside documents folder
    private func makeURL(
        for name: String
    ) throws -> URL {
        return self.config.url.appendingPathComponent(name)
    }

    /// Reads specific data from filesystem
    ///
    /// - Parameter url: URL to file
    /// - returns: Data object of file
    private func read(
        url: URL
    ) throws -> Data {
        guard self.config.fileManager.fileExists(at: url) else {
            throw Error.fileDoesNotExist
        }

        return try Data(contentsOf: url)
    }
}

// MARK: FileStorage.Config

extension FileStorage {
    public struct Config {
        /// A file system accessor
        let fileManager: FileManager

        /// The url to use for file storage
        public let url: URL

        let decode: (Data) throws -> Value
        let encode: (Value) throws -> Data

        // MARK: - Init

        /// Creates a FileStorage
        /// - Parameters:
        ///   - url: The url where the files of this storage should be stored at
        ///   - decode: A decoding function that decodes data objects into the type that this
        ///   storage handles
        ///   - encode: An encoding function that encodes the type that this storage handles into a
        ///   data object
        ///   - fileManager: The filemanager that is used for this storage
        public init(
            url: URL = URL.documentsDirectory,
            encode: @escaping (Value) throws -> Data = { try JSONEncoder().encode($0) },
            decode: @escaping (Data) throws -> Value = { try JSONDecoder().decode(
                Value.self,
                from: $0
            ) },
            fileManager: FileManager = .default
        ) {
            self.url = url
            self.decode = decode
            self.encode = encode
            self.fileManager = fileManager
        }

        /// A default configuration with sensible defaults.
        public static var `default`: Self {
            Self()
        }
    }
}

// MARK: FileStorage.Error

extension FileStorage {
    enum Error: Swift.Error {
        case fileAlreadyExists
        case invalidDirectory
        case writingFailed
        case fileDoesNotExist
        case readingFailed
        case migrationFailed
    }
}
