//
//  Storage.swift
//
//  Copyright © 2022 Paavo Becker.
//

import Foundation

// MARK: - Storage

/// A Protocol that defines persistence capabilities.
///
/// An implementor is responsible for storing one specific type. If the storage container should
/// store non-homogenous values, use a type erasing wrapper as the storages type. The type erasing
/// wrapper is then repsponsible to implement the codable conformance for its wrapped values.
public protocol Storage<Key, Value> {
    associatedtype Key: Hashable
    associatedtype Value

    /// Contains all keys in storage.
    ///
    /// - returns: All keys in storage.
    var keys: [Key] { get }

    /// Saves value a value identified by the given key.
    ///
    /// The method fails when the storage already contains data for the given key. The
    ///  ``update(value:for:)`` method will insert values by overriding existing values.
    ///
    /// - Parameter value: Value that should be stored.
    /// - Parameter key: Key to store the value under.
    func insert(value: Value, for: Key) throws

    /// Deletes value from storage.
    ///
    /// - Parameter name: Name of value.
    func remove(for: Key) throws

    /// Provides specific value from storage.
    ///
    /// - Parameter name: Name of value to retrieve.
    /// - returns: Value
    func value(for: Key) throws -> Value
}

extension Storage {
    /// Contains all values that are managed by this storage instance.
    ///
    /// - Warning: Use with caution. Accessing this property will load the entire content of the
    /// storage into memory. This might not be desired.
    var values: [Value] {
        get throws { try self.keys.map { try self.value(for: $0) } }
    }

    /// Contains the entire content that are managed by this storage instance.
    ///
    /// - Warning: Use with caution. Accessing this property will load the entire content of the
    /// storage into memory. This might not be desired.
    var content: [Key: Value] {
        get throws { try self.keys.reduce(into: [:]) { $0[$1] = try self.value(for: $1) } }
    }
    
    /// Deletes all values.
    func clear() throws {
        try self.keys.forEach { try self.remove(for: $0) }
    }
    
    /// Replaces value behind the given key.
    ///
    /// If the value does not exist it will be created instead.
    ///
    /// - Parameter name: Name to store value under
    /// - Parameter value: Value that should be stored
    public func update(
        value: Value,
        for key: Key
    ) throws {
        // Delete the existing file.
        try self.remove(for: key)
        
        // Insert new value using the same key.
        try self.insert(value: value, for: key)
    }
}

//// MARK: - StorageEvent
//
// public enum StorageEvent<Value> {
//    case created(Value)
//    case updated(Value, Value)
//    case deleted(Value)
//    case undefined
//
//    init(prev: Value?, next: Value?) {
//        switch (prev, next) {
//        case let (prev?, next?):
//            self = .updated(prev, next)
//        case let (nil, next?):
//            self = .created(next)
//        case let (prev?, nil):
//            self = .deleted(prev)
//        case (nil, nil):
//            self = .undefined
//        }
//    }
// }
