//
//  MapTypedCoder.swift
//
//
//  Created by Paavo Becker on 01.04.24.
//

import Foundation

public final class MapTypedCoder<Encoded, Decoded: Codable, T: Codable>: TypedCoder {
    let coder: AnyTypedCoder<T, Decoded>
    let decorator: AnyTypedCoder<Encoded, T>
    
    public init(coder: any TypedCoder<T, Decoded>, decorator: any TypedCoder<Encoded, T>) {
        self.coder = coder.eraseToAnyConstrainedCoder()
        self.decorator = decorator.eraseToAnyConstrainedCoder()
    }
    
    public func encode(_ value: Decoded) throws -> Encoded {
        try self.decorator.encode(try self.coder.encode(value))
    }
    
    public func decode(from data: Encoded) throws -> Decoded {
        try self.coder.decode(from: try self.decorator.decode(from: data))
    }
}

extension TypedCoder where Encoded: Codable {
    public func decorate<T: Codable>(
        _ other: any TypedCoder<T, Encoded>
    ) -> AnyTypedCoder<T, Decoded> {
        MapTypedCoder(coder: self, decorator: other).eraseToAnyConstrainedCoder()
    }
}
