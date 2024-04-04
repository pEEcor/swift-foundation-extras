//
//  DecoratingTypedCoder.swift
//
//  Copyright © 2024 Paavo Becker.
//

import Foundation

// MARK: - DecoratingTypedCoder

public final class DecoratingTypedCoder<Encoded, Decoded: Codable, T: Codable>: TypedCoder {
    let coder: AnyTypedCoder<T, Decoded>
    let decorator: AnyTypedCoder<Encoded, T>

    public init(coder: any TypedCoder<T, Decoded>, decorator: any TypedCoder<Encoded, T>) {
        self.coder = coder.eraseToAnyTypedCoder()
        self.decorator = decorator.eraseToAnyTypedCoder()
    }

    public func encode(_ value: Decoded) throws -> Encoded {
        try self.decorator.encode(self.coder.encode(value))
    }

    public func decode(from data: Encoded) throws -> Decoded {
        try self.coder.decode(from: self.decorator.decode(from: data))
    }
}

extension TypedCoder where Encoded: Codable {
    public func decorate<T: Codable>(
        _ other: any TypedCoder<T, Encoded>
    ) -> AnyTypedCoder<T, Decoded> {
        DecoratingTypedCoder(coder: self, decorator: other).eraseToAnyTypedCoder()
    }
}
