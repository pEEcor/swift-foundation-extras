//
//  Base64Coder.swift
//
//  Copyright © 2024 Paavo Becker.
//

import Foundation

// MARK: - Base64Coder

public final class Base64Coder: TypedCoder {
    public typealias Encoded = String
    public typealias Decoded = Data

    public init() {}

    public func encode(_ value: Decoded) throws -> Encoded {
        return value.base64EncodedString()
    }

    public func decode(from data: String) throws -> Decoded {
        guard let data = Data(base64Encoded: data) else {
            throw Base64CoderFailure.invalidEncoding
        }

        return data
    }
}

// MARK: - Base64CoderFailure

public enum Base64CoderFailure: Error, Equatable {
    case invalidEncoding
}

extension TypedCoder where Encoded == Data {
    /// Applies the ``Base64Coder`` to any other typed coder where the `Encoded` type is `Data`.
    ///
    /// - Returns: A typed coder that encodes `Data` as a base64 string.
    public func base64String() -> AnyTypedCoder<String, Decoded> {
        self.decorate(Base64Coder())
    }
}
