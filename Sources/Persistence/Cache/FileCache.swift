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
/// consider using the ``Data`` type as the cache's storage type.
///
/// The ``FileCache`` does not give any guarantee about the duration of element storage inside the
/// cache. According to the availability of system resources, elements may be evicted from the cache
/// at any time. The ``FileCache`` stores its files to the cache directory that is provided by the
/// system.
public final class FileCache<Key: Hashable & Codable, Value: Codable> {
    private let config: Config
    private let id: UUID

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
        id: UUID,
        config: Config
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
        self.urlToCacheDirectory.appendingPathComponent("\(key.hashValue)")
    }

    private func entry(forUrl url: URL) throws -> Entry {
        let data = try self.config.fileSystemAccessor.read(url)
        return try self.config.decode(data)
    }

    private func makeCacheDirectoryIfRequired(id: UUID) throws {
        // Check if the cache folder exists
        if self.config.fileSystemAccessor.fileExists(self.urlToCacheDirectory) {
            // Make sure that there is no file with the same name of the cache
            guard self.config.fileSystemAccessor.isDirectory(self.urlToCacheDirectory) else {
                throw FileCacheError.invalidCacheIdFileWithEqualNameAlreadyExists
            }
        } else {
            // Create cache folder
            try self.config.fileSystemAccessor.createDirectory(self.urlToCacheDirectory)
        }
    }

    private var urlToCacheDirectory: URL {
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
        guard let urls = try? self.config.fileSystemAccessor
            .contentsOfDirectory(self.urlToCacheDirectory) else {
            return [:]
        }

        let content: [Key: Value] = urls.reduce(into: [:]) { partialResult, url in
            // Entries where reading fails, are gracefully ignored.
            guard let entry = try? self.entry(forUrl: url) else {
                return
            }

            partialResult[entry.key] = entry.value
        }

        return content
    }

    public func clear() {
        // Make sure that clearing of cache is ignored when path to cache is not a folder.
        guard self.config.fileSystemAccessor.isDirectory(self.urlToCacheDirectory) else {
            return
        }

        try? self.config.fileSystemAccessor.remove(self.urlToCacheDirectory)
    }

    public func insert(_ value: Value, forKey key: Key) throws {
        let data = try config.encode(Entry(key: key, value: value))
        let url = self.makeUrl(for: key)

        // Create cache folder if necessary
        try self.makeCacheDirectoryIfRequired(id: self.id)

        // Prior to writing to the cache, there is no check if the file exists already. That means
        // that the old content will be replaced with the new content.
        try self.config.fileSystemAccessor.write(data, url)
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
        try self.config.fileSystemAccessor.remove(url)
        
        // Return the deleted value to the caller.
        return entry.value
    }
}

extension FileCache {
    /// Wrapper zum bündeln von Key und Value Paaren. Dieser ist notwendig um die Paare gemeinsam
    /// im Dateisystem ablegen zu können
    public final class Entry: Codable {
        let key: Key
        let value: Value

        /// Erzeugt Entry Wrapper
        /// - Parameters:
        ///   - key: Key des Werts
        ///   - value: Wert selbst
        public init(key: Key, value: Value) {
            self.key = key
            self.value = value
        }
    }

    /// Configuration of the ``FileCache``
    public struct Config {
        /// Location where the cache should be placed on the file system
        public let url: URL

        /// Encoder to encode cache entry into ``Data`` object
        public let encode: (Entry) throws -> Data

        /// Decoder to decode data object into cache entiry
        public let decode: (Data) throws -> Entry

        /// A file system accessor
        public let fileSystemAccessor: FileSystemAccessor

        /// Creates a conficuration for the ``FileCache``
        /// - Parameters:
        ///   - url: Location where the cache should be placed on the file system
        ///   - encode: Encoder to encode cache entry into ``Data`` object
        ///   - decode: Decoder to decode data object into cache entiry
        ///   - fileSystemAccessor: A file system accessor
        public init(
            url: URL,
            encode: @escaping (Entry) throws -> Data,
            decode: @escaping (Data) throws -> Entry,
            fileSystemAccessor: FileSystemAccessor
        ) {
            self.url = url
            self.encode = encode
            self.decode = decode
            self.fileSystemAccessor = fileSystemAccessor
        }

        /// A default configuration with sensible defaults.
        public static func `default`(
            fileSystemAccessor: FileSystemAccessor = .default()
        ) -> Self {
            return Config(
                url: URL.cachesDirectory,
                encode: { try JSONEncoder().encode($0) },
                decode: { try JSONDecoder().decode(Entry.self, from: $0) },
                fileSystemAccessor: fileSystemAccessor
            )
        }
    }
}

// MARK: - FileCacheError

public enum FileCacheError: Error {
    case invalidCacheIdFileWithEqualNameAlreadyExists
}
