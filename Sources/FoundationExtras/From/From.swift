//
//  From.swift
//
//  Copyright © 2024 Paavo Becker.
//

// MARK: - From

/// Protocols in Swift are limited, period. Protocols cannot be implemented multiple times with
/// different implementations!
///
/// A trait that maps another type `T` into self `S`.
public struct From<S, T>: Sendable {
    /// Converts `T` into `S`.
    public let convert: @Sendable (T) -> S
    
    public init(convert: @escaping @Sendable (T) -> S) {
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
    public func pullback<U>(_ f: @escaping @Sendable (U) -> T) -> From<S, U> {
        From<S, U> { u in self.convert(f(u)) }
    }

    public func callAsFunction(_ other: T) -> S {
        self.convert(other)
    }
}
