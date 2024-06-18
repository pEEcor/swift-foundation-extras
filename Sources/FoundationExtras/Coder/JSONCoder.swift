//
//  JSONCoder.swift
//
//  Copyright © 2024 Paavo Becker.
//

import Combine
import Foundation
import XCTestDynamicOverlay

// MARK: - JSONCoder

/// A coder that can encode into and decode from JSON `Data`.
public final class JSONCoder: Coder {
    public typealias Output = Data

    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    /// Creates a JSONCoder.
    ///
    /// - Parameters:
    ///   - encoder: The JSONEncoder that will be used for encoding operations.
    ///   - decoder: The JSONDecoder that will be used for decoding operations.
    public init(
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.encoder = encoder
        self.decoder = decoder
    }

    public func encode<T>(_ value: T) throws -> Data where T: Encodable {
        try self.encoder.encode(value)
    }

    public func decode<T>(_ type: T.Type, from data: Data) throws -> T where T: Decodable {
        try self.decoder.decode(type, from: data)
    }
}

extension AnyCoder {
    public static var json: AnyCoder<Data> {
        JSONCoder().eraseToAnyCoder()
    }
}
