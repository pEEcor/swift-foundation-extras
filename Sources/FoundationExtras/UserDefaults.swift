//
//  UserDefaults.swift
//
//  Copyright © 2024 Paavo Becker.
//

import Foundation

extension UserDefaults {
    /// Returns the given type from user defaults
    ///
    /// - Parameter key: Unique key
    /// - Returns: Value if present, otherwise nil
    public func get<T: Decodable>(
        for key: String
    ) -> T? {
        guard let data = data(forKey: key) else {
            return nil
        }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    /// Returns the given type from user defaults
    ///
    /// - Parameter key: Unique key
    /// - Parameter default: Default value
    /// - Returns: Value if present, otherwise default value
    public func get<T: Decodable>(
        for key: String,
        default: T
    ) -> T {
        return self.get(for: key) ?? `default`
    }

    /// Stores a value to user defaults
    ///
    /// - Parameter value: Value to store, needs to be codable
    /// - Parameter key: Unique key
    ///
    public func set<T: Encodable>(_ value: T, for key: String) {
        let encoded = try? JSONEncoder().encode(value)
        setValue(encoded, forKey: key)
    }
}
