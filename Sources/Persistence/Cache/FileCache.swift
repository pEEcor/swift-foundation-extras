//
//  FileCache.swift
//
//  Copyright © 2024 Paavo Becker.
//

import Foundation

// MARK: - FileCache

/// A cache that stores its values to the file system
///
/// The cache stores values of a specific type. If different types need to be stored in the Cache,
/// consider using the `Data` type as the cache's storage type.
///
/// The ``FileCache`` does not give any guarantee about the duration of element storage inside the
/// cache. According to the availability of system resources, elements may be evicted from the cache
/// at any time. The ``FileCache`` stores its files to the cache directory that is provided by the
/// system.
public final class FileCache<Key: Hashable & Codable, Value: Codable> {
    private let config: Config

    /// The unique id of the cache.
    let id: UUID

    /// Creates a ``FileCache``.
    ///
    /// The cache itself requires a unique id. Reusing an id, will reuse the storage, that was used
    /// when previously. This allows to restore a cache content across multiple launches of the
    /// application.
    ///
    /// - Warning: Creating multiple FileCache instances with the same id simultaneously should be
    /// avoided.
    ///
    /// - Parameters:
    ///   - initialValues: Dictionary with initial content. Defaults to empty dictionary
    ///   - id: Unique id of the cache
    ///   - config: A configuration for the FileCache
    public init(
        initialValues: [Key: Value] = [:],
        id: UUID = UUID(),
        config: Config = .default
    ) throws {
        self.config = config
        self.id = id

        // Creates a cache folder if required
        try self.makeCacheDirectoryIfRequired(id: id)

        try initialValues.forEach { key, value in
            try self.insert(value, forKey: key)
        }
    }

    private func makeUrl(for key: Key) -> URL {
        self.cacheDirectory.appendingPathComponent("\(key.hashValue)")
    }

    private func entry(forUrl url: URL) throws -> (key: Key, value: Value) {
        guard let data = self.config.fileManager.contents(atPath: url.path()) else {
            throw FileCacheFailure.missingFileForKey
        }
        return try self.config.decode(data)
    }

    private func makeCacheDirectoryIfRequired(id: UUID) throws {
        // Make sure that the directory does not exist.
        guard !self.config.fileManager.directoryExists(at: self.cacheDirectory) else {
            return
        }

        // Create cache folder.
        try self.config.fileManager
            .createDirectory(at: self.cacheDirectory, withIntermediateDirectories: true)
    }

    private var cacheDirectory: URL {
        if #available(iOS 16, *) {
            return self.config.url.appending(path: self.id.uuidString)
        } else {
            return self.config.url.appendingPathComponent(self.id.uuidString)
        }
    }
}

// MARK: Cache

extension FileCache: Cache {
    public var content: [Key: Value] {
        // A failure while reading the cache directory is gracefully relaxed to an empty dictionary.
        guard
            let urls: [URL] = try? self.config.fileManager
                .contentsOfDirectory(
                    at: self.cacheDirectory,
                    includingPropertiesForKeys: nil
                ) else
        {
            return [:]
        }

        let content: [Key: Value] = urls.reduce(into: [:]) { partialResult, url in
            // Entries where reading fails, are gracefully ignored.
            guard let (key, value) = try? self.entry(forUrl: url) else {
                return
            }

            partialResult[key] = value
        }

        return content
    }

    public func clear() {
        // Make sure that clearing of cache is ignored when path to cache is not a folder.
        guard self.config.fileManager.directoryExists(atPath: self.cacheDirectory.path()) else {
            return
        }
        // Remove the item and ignore any failures.
        try? self.config.fileManager.removeItem(at: self.cacheDirectory)
    }

    public func insert(_ value: Value, forKey key: Key) throws {
        let data = try config.encode(key, value)
        let url = self.makeUrl(for: key)

        // Create cache folder if necessary
        try self.makeCacheDirectoryIfRequired(id: self.id)

        // Prior to writing to the cache, there is no check if the file exists already. That means
        // that the old content will be replaced with the new content.
        guard self.config.fileManager.createFile(at: url, contents: data) else {
            throw FileCacheFailure.insufficientPermissions
        }
    }

    public func value(forKey key: Key) throws -> Value {
        let url = self.makeUrl(for: key)
        return try self.entry(forUrl: url).value
    }

    @discardableResult
    public func remove(forKey key: Key) throws -> Value {
        let url = self.makeUrl(for: key)

        // Get the entry before removing it
        let entry = try self.entry(forUrl: url)

        // Perform the actual removal
        if self.config.fileManager.fileExists(at: url) {
            try self.config.fileManager.removeItem(at: url)
        }

        // Return the deleted value to the caller.
        return entry.value
    }
}

extension FileCache {
    /// Wrapper type that bundles key and value since tuples cannot conform to any protocol.
    struct Entry: Codable {
        let key: Key
        let value: Value

        /// Creates the empty wrapper from a key and value pair.
        ///
        /// - Parameters:
        ///   - key: The key
        ///   - value: The value
        init(key: Key, value: Value) {
            self.key = key
            self.value = value
        }
    }

    /// Configuration of the ``FileCache``
    public struct Config {
        /// Location where the cache should be placed on the file system.
        public let url: URL

        /// Encoder to encode cache entry into `Data` object.
        public let encode: (Key, Value) throws -> Data

        /// Decoder to decode data object into cache entiry.
        public let decode: (Data) throws -> (Key, Value)

        /// A FileManager.
        public let fileManager: FileManager

        /// Creates a configuration for the ``FileCache``. All configuration option come with
        /// sensible defaults.
        ///
        /// - Parameters:
        ///   - url: Location where the cache should be placed on the file system
        ///   - encode: Encoder to encode cache entry into `Data` object
        ///   - decode: Decoder to decode data object into cache entiry
        ///   - fileSystemAccessor: A file system accessor
        public init(
            url: URL = URL.cachesDirectory,
            encode: ((Key, Value) throws -> Data)? = nil,
            decode: ((Data) throws -> (Key, Value))? = nil,
            fileManager: FileManager = .default
        ) {
            self.url = url

            self.encode = encode ?? { key, value in
                try JSONEncoder().encode(Entry(key: key, value: value))
            }

            self.decode = decode ?? { data in
                let entry = try JSONDecoder().decode(Entry.self, from: data)
                return (entry.key, entry.value)
            }

            self.fileManager = fileManager
        }

        /// A default configuration with sensible defaults.
        public static var `default`: Self {
            Config()
        }
    }
}

// MARK: - FileCacheFailure

public enum FileCacheFailure: Error {
    case invalidCacheIdFileWithEqualNameAlreadyExists
    case missingFileForKey
    case insufficientPermissions
}
