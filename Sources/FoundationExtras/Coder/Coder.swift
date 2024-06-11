//
//  Coder.swift
//
//  Copyright © 2024 Paavo Becker.
//

import Combine
import Foundation

// MARK: - Coder

/// A protocol that defines how values can be encoded and decoded from and into a specific type.
///
/// The generic argument of the protocol declares the type that a coder's encode operation will
/// produce when encoding a value. Thus this is also the type that is fed into the decode operation.
public protocol Coder<Output>: TopLevelEncoder, TopLevelDecoder
    where Self.Input == Self.Output, Self.Output == Self.Output
{
    associatedtype Output
}

// MARK: - AnyCoder

/// Type-erased wrapper for Coders.
public class AnyCoder<Output>: Coder {
    /// The embedded coder that handles the actual coding.
    private let coder: any Coder<Output>

    /// Creates a type-erased Coder from any other coder.
    /// - Parameter coder: The type-erased coder.
    public init(coder: any Coder<Output>) {
        self.coder = coder
    }

    public func encode<T>(_ value: T) throws -> Output where T: Encodable {
        try self.coder.encode(value)
    }

    public func decode<T>(_ type: T.Type, from value: Output) throws -> T where T: Decodable {
        try self.coder.decode(type, from: value)
    }
}

extension Coder {
    /// Erases the concrete type of the given coder.
    ///
    /// - Returns: A type-erased coder.
    public func eraseToAnyCoder() -> AnyCoder<Output> {
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
    ) -> AnyTypedCoder<Output, T> where T: Codable {
        AnyTypedCoder(coder: self, type: type)
    }
}
