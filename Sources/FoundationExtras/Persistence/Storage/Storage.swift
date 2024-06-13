//
//  Storage.swift
//
//  Copyright © 2024 Paavo Becker.
//

import Foundation

// MARK: - Storage

/// A Protocol that defines persistence capabilities.
///
/// An implementor is responsible for storing one specific type. If the storage container should
/// store non-homogenous values, use a type erasing wrapper as the storages type. The type erasing
/// wrapper is then repsponsible to implement the codable conformance for its wrapped values.
public protocol Storage<Key, Value> {
    associatedtype Key: Hashable & Sendable
    associatedtype Value: Sendable

    /// Contains all keys in storage.
    ///
    /// - returns: All keys in storage.
    var keys: [Key] { get async }

    /// Saves value a value identified by the given key.
    ///
    /// The method fails when the storage already contains data for the given key. The
    ///  ``update(value:for:)`` method will insert values by overriding existing values.
    ///
    /// - Parameter value: Value that should be stored.
    /// - Parameter key: Key to store the value under.
    func insert(value: Value, for: Key) async throws

    /// Deletes value from storage.
    ///
    /// - Parameter name: Name of value.
    func remove(for: Key) async throws

    /// Provides specific value from storage.
    ///
    /// - Parameter name: Name of value to retrieve.
    /// - returns: Value
    func value(for: Key) async throws -> Value
}

extension Storage where Self: Sendable {
    /// Contains all values that are managed by this storage instance.
    ///
    /// - Warning: Use with caution. Accessing this property will load the entire content of the
    /// storage into memory. This might not be desired.
    public var values: [Value] {
        get async throws { try await self.keys.asyncMap { try await self.value(for: $0) } }
    }

    /// Contains the entire content that are managed by this storage instance.
    ///
    /// - Warning: Use with caution. Accessing this property will load the entire content of the
    /// storage into memory. This might not be desired.
    public var content: [Key: Value] {
        get async throws {
            try await self.keys.asyncReduce(into: [:]) { $0[$1] = try await self.value(for: $1) }
        }
    }

    /// Deletes all values.
    public func clear() async throws {
        try await self.keys.asyncForEach { try await self.remove(for: $0) }
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
    ) async throws {
        // Delete the existing file.
        try await self.remove(for: key)

        // Insert new value using the same key.
        try await self.insert(value: value, for: key)
    }
}
