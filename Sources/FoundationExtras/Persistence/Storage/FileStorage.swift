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
/// storing them, i.e. `Data`.
///
/// ## Threading considerations
///
/// A `FileStorage` is Sendable and safe to be used from any concurrent context. It's still a class,
/// the thread-safeness is provided by the underlying filemanager.
public final class FileStorage<Key: Codable & Hashable & Sendable, Value: Codable & Sendable> {
    /// The configuration of the file storage.
    public let config: Config

    // MARK: - Init

    /// Creates a FileStorage
    /// - Parameter config: The configuration of the FileStorage
    public init(
        config: Config
    ) {
        self.config = config
    }
}

// MARK: Storage

extension FileStorage: Storage {
    public var keys: [Key] {
        // Make sure that the target directory exists, otherwise return empty array.
        guard self.config.fileManager.fileExists(at: self.config.url) else {
            return []
        }

        // Get urls to all files that are managed by the filemanager.
        guard let urls = try? self.config.fileManager.contentsOfDirectory(at: self.config.url) else {
            return []
        }

        // Transform the urls into actual keys.
        return urls.compactMap { try? self.makeKey(for: $0) }
    }

    public func insert(
        value: Value,
        for key: Key
    ) throws {
        // Make the url that will be used to store the value.
        let fileUrl = try self.makeUrl(for: key)

        // Make sure that the file does not exist yet.
        guard !self.config.fileManager.fileExists(at: fileUrl) else {
            throw FileStorageFailure.fileAlreadyExists
        }

        // Check if target directory exists.
        try self.makeStorageDirectoryIfRequired()

        // Encode the value.
        let data = try self.config.valueCoder.encode(value)

        // Write the data to the filesystem.
        guard self.config.fileManager.createFile(at: fileUrl, contents: data) else {
            throw FileStorageFailure.writeFailure
        }
    }

    public func remove(
        for key: Key
    ) throws {
        // Make the url that will be used to store the value.
        let url = try self.makeUrl(for: key)

        // Deletion is gracefully ignored if file or directory does not exist.
        guard self.config.fileManager.fileExists(at: url) else {
            return
        }

        // Remove the file from the filesystem.
        try self.config.fileManager.removeItem(at: url)
    }

    public func value(
        for key: Key
    ) throws -> Value {
        // Make the url that will be used to store the value.
        let url = try self.makeUrl(for: key)

        // Make sure that the file exists.
        guard self.config.fileManager.fileExists(at: url) else {
            throw FileStorageFailure.fileDoesNotExist
        }

        // Make sure that the file exists.
        guard let data = self.config.fileManager.contents(at: url) else {
            throw FileStorageFailure.readFailure
        }

        // Decode the data into the Type of the storage.
        return try self.config.valueCoder.decode(Value.self, from: data)
    }

    // MARK: - Private

    private func encodeKey(key: Key) throws -> String {
        try self.config.keyCoder.encode(key)
    }

    private func decodeKey(_ value: String) throws -> Key {
        try self.config.keyCoder.decode(from: value)
    }

    private func makeUrl(for key: Key) throws -> URL {
        try self.config.url.appending(path: self.encodeKey(key: key))
    }

    private func makeKey(for url: URL) throws -> Key {
        try self.decodeKey(url.lastPathComponent)
    }

    private func makeStorageDirectoryIfRequired() throws {
        // Make sure that the directory does not exist.
        guard !self.config.fileManager.directoryExists(at: self.config.url) else {
            return
        }

        // Create storage directory.
        try self.config.fileManager
            .createDirectory(at: self.config.url, withIntermediateDirectories: true)
    }
}

// MARK: FileStorage.Config

extension FileStorage {
    public struct Config: Sendable {
        /// The url to use for file storage.
        public let url: URL

        /// A FileManager that handles all access to the filesystem.
        let fileManager: FileManager

        /// The coder that is used to transform the keys for storage.
        let keyCoder: AnyTypedCoder<String, Key>

        /// The coder that is used to transform the values for storage.
        let valueCoder: AnyCoder<Data>

        // MARK: - Init

        /// Creates config for a `FileStorage`.
        ///
        /// - Parameters:
        ///   - url: The url where the files of this storage should be stored at data object.
        ///   - keyCoder: The coder to encode and decode keys.
        ///   - valueCoder: The coder to encode and decode values.
        ///   - fileManager: The filemanager that is used for this storage.
        public init(
            url: URL = URL.documentsDirectory,
            keyCoder: AnyTypedCoder<String, Key>? = nil,
            valueCoder: AnyCoder<Data>? = nil,
            fileManager: FileManager = .default
        ) {
            self.url = url
            self.keyCoder = keyCoder ?? JSONCoder()
                .typed(to: Key.self)
                .base64String()

            self.valueCoder = valueCoder ?? JSONCoder().eraseToAnyCoder()
            self.fileManager = fileManager
        }

        /// A default configuration with sensible defaults.
        public static var `default`: Self {
            Config()
        }
    }
}

// MARK: - FileStorageFailure

public enum FileStorageFailure: Error {
    case invalidEncoding
    case fileAlreadyExists
    case invalidDirectory
    case writeFailure
    case fileDoesNotExist
    case readFailure
    case migrationFailed
}
