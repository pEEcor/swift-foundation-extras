//
//  StringCoderTests.swift
//
//  Copyright © 2024 Paavo Becker.
//

import XCTest
import FoundationExtras

final class StringCoderTests: XCTestCase {
    func testEncode_useConfiguredEncoding() throws {
        // GIVEN
        let sut = StringCoder(encoding: .utf8)
        
        // WHEN
        let output = try sut.encode(try XCTUnwrap("foo".data(using: .utf8)))
        
        // THEN
        XCTAssertEqual(output, "foo")
    }
    
    func testEncode_throwError_whenEncodingFails() throws {
        // GIVEN
        let sut = StringCoder(encoding: .utf8)
        
        // Creates an invalid utf8 byte sequence
        let bytes: [UInt8] = [0xF0, 0x28, 0x8C, 0x28]

        // WHEN
        XCTAssertThrowsError(try sut.encode(Data(bytes))) { error in
            // THEN
            XCTAssertEqual(error as! StringCoderFailure, .invalidEncoding(.utf8))
        }
    }
    
    func testDecode_useConfiguredDecoding() throws {
        // GIVEN
        let sut = StringCoder(encoding: .utf8)
        
        // WHEN
        let output = try sut.decode(from: "foo")
        
        // THEN
        XCTAssertEqual(output, "foo".data(using: .utf8)!)
    }
    
    func testDecode_throwError_whenDecodingFails() throws {
        // GIVEN
        let sut = StringCoder(encoding: .ascii)
        
        // WHEN
        XCTAssertThrowsError(try sut.decode(from: "👨🏼‍💻")) { error in
            // THEN
            XCTAssertEqual(error as! StringCoderFailure, .invalidEncoding(.ascii))
        }
    }
    
    func testString_createAnyTypedCoderFromDataToString() throws {
        // GIVEN
        let sut = JSONCoder().typed(to: String.self)
        
        // WHEN
        let output = sut.string(encoding: .utf8)
        
        // THEN
        XCTAssertEqual(try output.encode("👨🏼‍💻"), "\"👨🏼‍💻\"")
    }
}

