//
//  MemoryStorage.swift
//
//  Copyright © 2022 Paavo Becker.
//

import AsyncAlgorithms
import ConcurrencyExtras
import Foundation

// MARK: - MemoryStorage

public class MemoryStorage<Value: Codable> {
    private var storage: LockIsolated<[String: Value]>

    public init(initialValue: [String: Value] = [:]) {
        self.storage = LockIsolated(initialValue)
    }
}

// MARK: Storage

extension MemoryStorage: Storage {
    public func insert(value: Value, named name: String) throws {
        self.storage.withValue { $0[name] = value }
    }

    public func remove(name: String) throws {
        self.storage.withValue { $0[name] = nil }
    }

    public func clear() throws {
        self.storage.withValue { $0.removeAll() }
    }

    public func observe<Element>(
        keyPath: KeyPath<Value, Element>
    ) -> AsyncStream<StorageEvent<Element>> {
        let channel: AsyncChannel<StorageEvent<Element>> = AsyncChannel()

        return channel.eraseToStream()
    }

    public func read(name: String) throws -> Value {
        guard let value = storage[name] else {
            throw MemoryStorageError.dataNotFound
        }
        return value
    }

    public func read() throws -> [Value] {
        return self.storage.values.map { $0 }
    }

    public func update(value: Value, named name: String) throws {
        try self.insert(value: value, named: name)
    }
}

// MARK: MemoryStorage.MemoryStorageError

extension MemoryStorage {
    enum MemoryStorageError: String, Error {
        case dataNotFound
    }
}
