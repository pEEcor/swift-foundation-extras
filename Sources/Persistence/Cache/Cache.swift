//
//  Cache.swift
//
//
//  Created by Paavo Becker on 31.07.22.
//

import Foundation

/// A generic cache protocol
public protocol Cache<Key, Value> {
    associatedtype Key: Hashable
    associatedtype Value
    
    /// The entire content of the cache. Be carefull when using this. The concrete implementation
    /// might take a lot of time when accessing all elements of a cache.
    var content: [Key: Value] { get }
    
    /// Clears the cache
    func clear()
    
    /// Adds a new element for the given key to the cache
    ///
    /// If the cache already contains an element for the given key. The cache implementation may
    /// decide to replace the old value with the new one.
    ///
    /// - Parameters:
    ///   - value: Value that should be stored
    ///   - forKey: Key
    func insert(_ value: Value, forKey: Key) throws
    
    /// Returns the value for the given key if the cache contains a value for the key
    /// - Parameter forKey: Key
    /// - Returns: Optional value, that contains value or nil if not found in cache
    func value(forKey: Key) -> Value?
    
    /// Removes the value of the given key from the cache
    /// - Parameter forKey: Key
    func removeValue(forKey: Key)
}

extension Cache where Value == Data {
    /// Adds a new element for the given key to the cache
    ///
    /// If the cache already contains an element for the given key. The cache implementation may
    /// decide to replace the old value with the new one.
    ///
    /// - Parameters:
    ///   - value: Value that should be stored
    ///   - forKey: Key
    public func insert<Value: Encodable>(_ value: Value, forKey key: Key) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(value)
        try self.insert(data, forKey: key)
    }
    
    /// Returns the value for the given key if the cache contains a value for the key
    /// - Parameter forKey: Key
    /// - Returns: Optional value, that contains value or nil if not found in cache
    public func value<Value: Decodable>(forKey key: Key) -> Value? {
        guard let data = self.value(forKey: key) else {
            return nil
        }
        
        let decoder = JSONDecoder()
        let value: Value? = try? decoder.decode(Value.self, from: data)
        
        return value
    }
}
