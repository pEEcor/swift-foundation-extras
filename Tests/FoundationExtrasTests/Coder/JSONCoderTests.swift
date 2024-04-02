//
//  JSONCoderTests.swift
//  
//
//  Created by Paavo Becker on 02.04.24.
//

import FoundationExtras
import XCTest
import XCTestDynamicOverlay

final class JSONCoderTests: XCTestCase {
    func testInit_setEncoderAndDecoder() throws {
        let expectation_encode = expectation(description: "encode")
        let expectation_decode = expectation(description: "decode")

        // GIVEN
        let encoder = MockJSONEncoder()
        let decoder = MockJSONDecoder()
        
        // WHEN
        let coder = JSONCoder(encoder: encoder, decoder: decoder)
        
        encoder.onEncode = { expectation_encode.fulfill() }
        decoder.onDecode = { expectation_decode.fulfill() }
        
        let data = try coder.encode(1)
        _ = try coder.decode(Int.self, from: data)

        // THEN
        wait(for: [expectation_encode, expectation_decode], timeout: 0.5)
    }
    
    func testJSON_createJSONCoderFromInferredType() throws {
        let _: AnyCoder<Data> = .json
    }
}

private class MockJSONEncoder: JSONEncoder {
    var onEncode: () throws -> Void = unimplemented("MockJSONEncoder.onEncode")
    
    override func encode<T>(_ value: T) throws -> Data where T : Encodable {
        try self.onEncode()
        return try super.encode(value)
    }
}

private class MockJSONDecoder: JSONDecoder {
    var onDecode: () throws -> Void = unimplemented("MockJSONEncoder.onDecode")
    
    override func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable {
        try self.onDecode()
        return try super.decode(type, from: data)
    }
}
