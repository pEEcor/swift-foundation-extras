//
//  MemoryStorage.swift
//  
//
//  Created by Paavo Becker on 31.07.22.
//

import Foundation
import ConcurrencyExtras
import AsyncAlgorithms

public class MemoryStorage<Value: Codable> {
    private var storage: LockIsolated<[String: Value]>
    
    public init(initialValue: [String: Value] = [:]) {
        self.storage = LockIsolated(initialValue)
    }
}

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
        return storage.values.map { $0 }
    }
    
    public func update(name: String, value: Value) throws {
        try create(name: name, value: value)
    }
}

extension MemoryStorage {
    enum MemoryStorageError: String, Error {
        case dataNotFound
    }
}
