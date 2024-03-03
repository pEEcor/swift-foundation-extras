//
//  FileCache.swift
//
//
//  Created by Paavo Becker on 31.07.22.
//

import Foundation

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
    
    /// Creates a ``FileCache``
    ///
    /// The cache itself requires a unique id. If another cache with the same id is used, then these
    /// caches will share their storages. This allows to restore a cache across multiple launches
    /// of the application.
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
    
    private func entry(forKey key: Key) -> Entry? {
        let url = self.makeUrl(for: key)
        return self.entry(forUrl: url)
    }
    
    private func entry(forUrl url: URL) -> Entry? {
        guard let data = try? self.config.fileSystemAccessor.read(url) else {
            return nil
        }
        return try? self.config.decode(data)
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
            try config.fileSystemAccessor.createDirectory(self.urlToCacheDirectory)
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

extension FileCache: Cache {
    public var content: [Key: Value] {
        // Make sure that empty dictionary gets retured when path to cache does not exist
        guard self.config.fileSystemAccessor.isDirectory(self.urlToCacheDirectory) else {
            return [:]
        }
        
        guard let urls = try? self.config.fileSystemAccessor.contentsOfDirectory(
            self.urlToCacheDirectory
        ) else {
            return [:]
        }
        
        let content: [Key: Value] = urls.reduce(into: [:]) { partialResult, url in
            guard let entry = self.entry(forUrl: url) else {
                return
            }
            
            partialResult[entry.key] = entry.value
        }
        
        return content
    }
    
    public func clear() {
        // Make sure that clearing of cache is ignored when path do cache is not a folder
        guard self.config.fileSystemAccessor.isDirectory(self.urlToCacheDirectory) else {
            return
        }
        
        try? self.config.fileSystemAccessor.remove(self.urlToCacheDirectory)
    }
    
    public func insert(_ value: Value, forKey key: Key) throws {
        let data = try config.encode(Entry(key: key, value: value))
        let url = self.makeUrl(for: key)
        
        // Create cache folder if necessary
        try self.makeCacheDirectoryIfRequired(id: id)
        
        // Prior to writing to the cache, there is no check if the file exists already. That means
        // that the old content will be replaced with the new content
        try self.config.fileSystemAccessor.write(data, url)
    }
    
    public func value(forKey key: Key) -> Value? {
        return self.entry(forKey: key)?.value
    }
    
    public func removeValue(forKey key: Key) {
        let url = self.makeUrl(for: key)
        
        // Make sure that removal is ignored when path to cache is not a folder
        guard self.config.fileSystemAccessor.isDirectory(self.urlToCacheDirectory) else {
            return
        }
        
        // Make sure that removal is ignored when file does not exist
        guard self.config.fileSystemAccessor.fileExists(url) else {
            return
        }
        
        try? self.config.fileSystemAccessor.remove(url)
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
        let url: URL
        
        /// Encoder to encode cache entry into ``Data`` object
        let encode: (Entry) throws -> Data
        
        /// Decoder to decode data object into cache entiry
        let decode: (Data) throws -> Entry
        
        /// A file system accessor
        let fileSystemAccessor: FileSystemAccessor
        
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
        ) -> Self? {
            return Config(
                url: URL.cachesDirectory,
                encode: { try JSONEncoder().encode($0) },
                decode: { try JSONDecoder().decode(Entry.self, from: $0) },
                fileSystemAccessor: fileSystemAccessor
            )
        }
    }
    
    enum FileCacheError: Error {
        case invalidCacheIdFileWithEqualNameAlreadyExists
    }
}
