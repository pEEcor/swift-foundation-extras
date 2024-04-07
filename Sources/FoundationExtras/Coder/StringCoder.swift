//
//  StringCoder.swift
//
//  Copyright © 2024 Paavo Becker.
//

import Foundation

// MARK: - StringCoder

/// A string coder that encodes data into a string using a predefined encoding. The decoding
/// operation decodes a string into data respectively.
public final class StringCoder: TypedCoder {
    public typealias Encoded = String
    public typealias Decoded = Data

    private var encoding: String.Encoding

    /// Creates a StringCoder that encodes/decodes data into/from String.
    /// - Parameter encoding: The encoding that should be used when encoding into `String` and that
    /// is used when decoding from `String`.
    public init(
        encoding: String.Encoding = .utf8
    ) {
        self.encoding = encoding
    }

    public func encode(_ value: Decoded) throws -> Encoded {
        guard let encoded = String(data: value, encoding: self.encoding) else {
            throw StringCoderFailure.invalidEncoding(self.encoding)
        }

        return encoded
    }

    public func decode(from value: String) throws -> Decoded {
        guard let data = value.data(using: self.encoding) else {
            throw StringCoderFailure.invalidEncoding(self.encoding)
        }

        return data
    }
}

// MARK: - StringCoderFailure

/// Failures that can be throws by StringCoder.
public enum StringCoderFailure: Error, Equatable {
    /// Failure that gets thrown when encoding or decoding operations fail due to the type of
    /// encoding that is used.
    case invalidEncoding(String.Encoding)
}

extension TypedCoder where Encoded == Data {
    /// Applies the ``StringCoder`` to any other typed coder where the `Encoded` type is `Data`.
    ///
    /// - Parameter encoding: The encoding that should be used for encoding and decoting of the
    /// data.
    /// - Returns: A typed coder that encodes `Data` as a base64 string.
    public func string(encoding: String.Encoding = .utf8) -> AnyTypedCoder<String, Decoded> {
        self.decorate(StringCoder(encoding: encoding))
    }
}
