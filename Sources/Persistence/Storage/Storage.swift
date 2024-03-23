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
public protocol Storage<Value> {
    associatedtype Value: Codable

    /// Saves value a value identified by the given name.
    ///
    /// - Parameter name: Name to store the value under.
    /// - Parameter value: Value that should be stored.
    func create(name: String, value: Value) throws

    /// Deletes value from storage.
    ///
    /// - Parameter name: Name of value.
    func delete(name: String) throws

    /// Deletes all values
    func delete() throws

    /// Provides an async sequence that emits events whenever the value at the specified key path
    /// changes.
    ///
    /// - Parameter keyPath: Keypath to the property of interest.
    /// - Returns: Async Sequence that emits updates.
    func observe<Element: Equatable>(
        keyPath: KeyPath<Value, Element>
    ) -> AsyncStream<StorageEvent<Element>>

    /// Reads specific value from storage.
    ///
    /// - Parameter name: Name of value to retrieve.
    /// - returns: Value
    func read(name: String) throws -> Value

    /// Reads all values in storage.
    ///
    /// - returns: Array of Value
    func read() throws -> [Value]

    /// Updates value with given data.
    ///
    /// If the value does not exist it will be created instead.
    ///
    /// - Parameter name: Name to store value under
    /// - Parameter value: Value that should be stored
    func update(name: String, value: Value) throws
}

// MARK: - StorageEvent

public enum StorageEvent<Value> {
    case created(Value)
    case updated(Value, Value)
    case deleted(Value)
    case undefined

    init(prev: Value?, next: Value?) {
        switch (prev, next) {
        case let (prev?, next?):
            self = .updated(prev, next)
        case let (nil, next?):
            self = .created(next)
        case let (prev?, nil):
            self = .deleted(prev)
        case (nil, nil):
            self = .undefined
        }
    }
}
