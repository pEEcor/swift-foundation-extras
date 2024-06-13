//
//  MemoryStorage.swift
//
//  Copyright © 2024 Paavo Becker.
//

import ConcurrencyExtras
import Foundation

// MARK: - MemoryStorage

/// A Storage implementation that holds its entire content in memory.
///
/// This storage can be used when data should be cleared between cold launches of an appliction
/// automatically. Use with caution when storing big values, since the entire content of the
/// storage is kept in memory.
public final actor MemoryStorage<Key: Hashable & Sendable, Value: Sendable> {
    /// The dictionary that holds all key-value pairs that get inserted into the storage.
    private var storage: [Key: Value]

    /// Creates a MemoryStorage.
    ///
    /// - Parameter initialValue: Initial values, that are available in the storage after init.
    public init(initialValue: [Key: Value] = [:]) {
        self.storage = initialValue
    }
}

// MARK: Storage

extension MemoryStorage: Storage {
    public var keys: [Key] {
        self.storage.keys.map { $0 }
    }

    public func insert(value: Value, for key: Key) throws {
        // Make sure that the key does not exist yet inside the storage.
        guard !self.storage.keys.contains(key) else {
            throw MemoryStorageError.keyAlreadyExists
        }
        
        self.storage[key] = value
    }

    public func remove(for key: Key) throws {
        self.storage[key] = nil
    }

    public func value(for key: Key) throws -> Value {
        // Make sure that the storage contains the given key.
        guard let value = self.storage[key] else {
            throw MemoryStorageError.keyDoesNotExist
        }

        return value
    }
}

// MARK: - MemoryStorageError

public enum MemoryStorageError: String, Error {
    /// Indicates that the storage contains no key-value pair for a specific key.
    case keyDoesNotExist

    /// Indicates that the storage already contains a key-value pair with a specific key.
    case keyAlreadyExists
}
