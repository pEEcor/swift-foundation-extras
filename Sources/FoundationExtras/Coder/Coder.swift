//
//  Coder.swift
//
//  Copyright © 2024 Paavo Becker.
//

import Combine
import ConcurrencyExtras
import Foundation

// MARK: - Coder

/// A protocol that defines how values can be encoded and decoded from and into a specific type.
///
/// The generic argument of the protocol declares the type that a coder's encode operation will
/// produce when encoding a value. Thus this is also the type that is fed into the decode operation.
public protocol Coder<Value>: TopLevelEncoder, TopLevelDecoder, Sendable
    where Self.Input == Self.Value, Self.Output == Self.Value
{
    associatedtype Value: Sendable
}

// MARK: - AnyCoder

/// Type-erasing wrapper for Coders.
public struct AnyCoder<Value: Sendable>: Coder {
    /// The embedded coder that handles the actual coding.
    private let coder: LockIsolated<any Coder<Value>>

    /// Creates a type-erased Coder from any other coder.
    /// - Parameter coder: The type-erased coder.
    public init(coder: any Coder<Value>) {
        self.coder = LockIsolated(coder)
    }

    public func encode<T: Sendable>(_ value: T) throws -> Value where T: Encodable {
        try self.coder.withValue { try $0.encode(value) }
    }

    public func decode<T: Sendable>(
        _ type: T.Type,
        from value: Value
    ) throws -> T where T: Decodable {
        try self.coder.withValue { try $0.decode(type, from: value) }
    }
}

extension Coder {
    /// Erases the concrete type of the given coder.
    ///
    /// - Returns: A type-erased coder.
    public func eraseToAnyCoder() -> AnyCoder<Value> {
        AnyCoder(coder: self)
    }

    /// Converts coder into a typed coder.
    ///
    /// The type configures the input type that is used by the typed coder for the encode operation.
    /// A such, the output type of the decode operation produces a value of the given type.
    ///
    /// - Parameter type: The input type of the typed coder.
    /// - Returns: A type coder that encodes form und decodes into the given type.
    public func typed<T>(
        to type: T.Type
    ) -> AnyTypedCoder<Value, T> where T: Codable {
        AnyTypedCoder(coder: self, type: type)
    }
}
