//
//  TryFrom.swift
//
//  Copyright © 2024 Paavo Becker.
//

// MARK: - TryFrom

/// Protocols in Swift are limited, period. Protocols cannot be implemented multiple times with
/// different implementations!
///
/// A trait that maps another type `T` into self `S` where the conversion can fail.
public struct TryFrom<S, T>: Sendable {
    /// Converts `T` into `S`.
    public let convert: @Sendable (T) throws -> S

    public init(convert: @escaping @Sendable (T) throws -> S) {
        self.convert = convert
    }

    /// Pull back operation.
    ///
    /// This operation can be expressed by saying: "If you tell me how to transfrom a U into a T, I
    /// tell you how to convert a U into S.
    ///
    /// [Explanation from math](https://en.wikipedia.org/wiki/Pullback)
    ///
    /// - Parameter f: Transformation of U to T.
    /// - Returns: Mapping from U to S.
    public func pullback<U>(_ f: @escaping @Sendable (U) throws -> T) -> TryFrom<S, U> {
        TryFrom<S, U> { u in try self.convert(f(u)) }
    }

    public func callAsFunction(_ other: T) throws -> S {
        try self.convert(other)
    }

    /// A universal error type that is available to all custom implementations of the TryFrom trait.
    public enum Failure: Error, Equatable {
        case conversionFailure(message: String)
    }
}
