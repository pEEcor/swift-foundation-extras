//
//  MemoryStorage.swift
//
//  Copyright © 2022 Paavo Becker.
//

import AsyncAlgorithms
import ConcurrencyExtras
import Foundation

// MARK: - MemoryStorage

/// A Storage implementation that holds its entire content in memory.
///
/// This storage can be used when data should be cleared between cold launches of an appliction
/// automatically. Use with caution when storing big values, since the entire content of the
/// storage is kept in memory.
public final class MemoryStorage<Key: Hashable, Value>: Sendable {
    /// The dictionary that holds all key-value pairs that get insertet into the storage.
    private let storage: LockIsolated<[Key: Value]>

    /// Creates a MemoryStorage.
    ///
    /// - Parameter initialValue: Initial values, that are available in the storage after init.
    public init(initialValue: [Key: Value] = [:]) {
        self.storage = LockIsolated(initialValue)
    }
}

// MARK: Storage

extension MemoryStorage: Storage {
    public var keys: [Key] {
        self.storage.keys.map { $0 }
    }

    public func clear() throws {
        self.storage.withValue { $0.removeAll() }
    }

    public func insert(value: Value, for key: Key) throws {
        self.storage.withValue { $0[key] = value }
    }

    public func remove(for key: Key) throws {
        self.storage.withValue { $0[key] = nil }
    }

    public func update(value: Value, for key: Key) throws {
        try self.insert(value: value, for: key)
    }

    public func value(for key: Key) throws -> Value {
        guard let value = storage[key] else {
            throw MemoryStorageError.dataNotFound
        }
        return value
    }
}

// MARK: MemoryStorage.MemoryStorageError

extension MemoryStorage {
    enum MemoryStorageError: String, Error {
        case dataNotFound
    }
}
