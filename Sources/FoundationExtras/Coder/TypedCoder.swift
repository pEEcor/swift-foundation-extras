//
//  TypedCoder.swift
//
//  Copyright © 2024 Paavo Becker.
//

import Foundation

// MARK: - TypedCoder

/// A protocol similar to ``Coder``, that not only specifies the output type of the encode operation
/// but also the input type.
///
/// The protocol allows to specify various coders for encoding and decoding operations. Since both
/// the `Encoded` and `Decoded` type are managed by the protocol, custom coders can be implemented
/// and chained together.
public protocol TypedCoder<Encoded, Decoded>: Sendable {
    /// The type that is produced by the encode operation and that is fed into the decode operation.
    associatedtype Encoded

    /// The type that is produced by the decode operation and that is fed into the encode operation.
    associatedtype Decoded: Codable

    /// Encodes the given value.
    ///
    /// - Parameter value: The value that should be encoded.
    /// - Returns: The encoded value.
    func encode(_ value: Decoded) throws -> Encoded

    /// Decodes the given value.
    ///
    /// - Parameter value: The value that should be decoded.
    /// - Returns: The decoded value.
    func decode(from value: Encoded) throws -> Decoded
}

// MARK: - AnyTypedCoder

/// A type-erasing wrapper for typed coders.
public final class AnyTypedCoder<Encoded, Decoded: Codable>: TypedCoder {
    private let onEncode: @Sendable (Decoded) throws -> Encoded
    private let onDecode: @Sendable (Encoded) throws -> Decoded

    /// Creates a type-erasing wrapper for typed coders.
    /// - Parameters:
    ///   - encode: The encoding operation.
    ///   - decode: The decoding operation.
    public init(
        encode: @escaping @Sendable (Decoded) throws -> Encoded,
        decode: @escaping @Sendable (Encoded) throws -> Decoded
    ) {
        self.onEncode = encode
        self.onDecode = decode
    }

    public func encode(_ value: Decoded) throws -> Encoded {
        try self.onEncode(value)
    }

    public func decode(from value: Encoded) throws -> Decoded {
        try self.onDecode(value)
    }

    /// Creates a type-erasing wrapper around any other typed coder.
    ///
    /// - Parameter coder: The typed coder.
    public convenience init(coder: any TypedCoder<Encoded, Decoded>) {
        self.init(encode: { try coder.encode($0) }, decode: { try coder.decode(from: $0) })
    }

    /// Creates a type-erasing wrapper around any other non-typed coder.
    ///
    /// - Parameters:
    ///   - coder: The non-typed coder.
    ///   - type: The type that should be used to constrain the non-typed coder's input.
    public convenience init(coder: any Coder<Encoded>, type: Decoded.Type) {
        self.init(
            encode: { try coder.encode($0) },
            decode: { try coder.decode(type, from: $0) }
        )
    }
}

extension TypedCoder {
    /// Erases a concrete typed coder into a type-erased typed coder.
    public func eraseToAnyTypedCoder() -> AnyTypedCoder<Encoded, Decoded> {
        AnyTypedCoder(coder: self)
    }
}
