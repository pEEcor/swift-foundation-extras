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
    public func create(name: String, value: Value) throws {
        self.storage.withValue { $0[name] = value }
    }

    public func delete(name: String) throws {
        self.storage.withValue { $0[name] = nil }
    }

    public func delete() throws {
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

    public func update(name: String, value: Value) throws {
        try self.create(name: name, value: value)
    }
}

// MARK: MemoryStorage.MemoryStorageError

extension MemoryStorage {
    enum MemoryStorageError: String, Error {
        case dataNotFound
    }
}
