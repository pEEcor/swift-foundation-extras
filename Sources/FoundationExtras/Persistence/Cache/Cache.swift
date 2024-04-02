//
//  Cache.swift
//
//  Copyright © 2023 Paavo Becker.
//

import Foundation

// MARK: - Cache

/// A generic cache protocol.
public protocol Cache<Key, Value> {
    associatedtype Key: Hashable
    associatedtype Value

    /// The entire content of the cache. Be carefull when using this. The concrete implementation
    /// might take a lot of time when accessing all elements of a cache.
    var content: [Key: Value] { get }

    /// Clears the cache.
    func clear()

    /// Adds a new element for the given key to the cache.
    ///
    /// If the cache already contains an element for the given key. The cache implementation may
    /// decide to replace the old value with the new one.
    ///
    /// - Parameters:
    ///   - value: Value that should be stored.
    ///   - forKey: Key
    func insert(_ value: Value, forKey: Key) throws

    /// Returns the value for the given key if the cache contains a value for the key.
    ///
    /// - Parameter forKey: Key
    /// - Returns: Optional value, that contains value or nil if not found in cache.
    func value(forKey: Key) throws -> Value

    /// Removes the value of the given key from the cache.
    ///
    /// - Parameter forKey: Key
    func remove(forKey: Key) throws -> Value
}
