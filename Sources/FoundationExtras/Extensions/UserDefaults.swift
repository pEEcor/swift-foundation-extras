//
//  UserDefaults.swift
//
//  Copyright © 2024 Paavo Becker.
//

import Foundation

extension UserDefaults {
    /// Returns the given type from user defaults.
    ///
    /// - Parameter key: Unique key
    /// - Returns: Value if present, otherwise nil
    public func get<Key: Hashable, T: Decodable>(
        for key: Key
    ) -> T? {
        guard let data = data(forKey: "\(key.hashValue)") else {
            return nil
        }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    /// Returns the given type from user defaults.
    ///
    /// - Parameter key: Unique key
    /// - Parameter default: Default value
    /// - Returns: Value if present, otherwise default value.
    public func get<Key: Hashable, T: Decodable>(
        for key: Key,
        default: T
    ) -> T {
        return self.get(for: "\(key.hashValue)") ?? `default`
    }

    /// Stores a value to user defaults.
    ///
    /// - Parameter value: Value to store, needs to be codable.
    /// - Parameter key: Unique key
    ///
    public func set<Key: Hashable, T: Encodable>(_ value: T, for key: Key) {
        let encoded = try? JSONEncoder().encode(value)
        setValue(encoded, forKey: "\(key.hashValue)")
    }
}
