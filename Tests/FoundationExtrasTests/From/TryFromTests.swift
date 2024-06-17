//
//  File.swift
//
//
//  Created by Paavo Becker on 17.06.24.
//

import XCTest
import FoundationExtras

final class TryFromTests: XCTestCase {
    func testConvert() throws {
        // GIVEN
        let input = "foo"
        let sut = TryFrom<Int, String> { $0.count }
        
        // WHEN
        let output = try sut.convert(input)
        
        // THEN
        XCTAssertEqual(output, 3)
    }
    
    func testCallAsFunction() throws {
        // GIVEN
        let input = "foo"
        let sut = TryFrom<Int, String> { $0.count }
        
        // WHEN
        let output = try sut(input)
        
        // THEN
        XCTAssertEqual(output, 3)
    }
    
    func testPullback() throws {
        // GIVEN
        let input = ["foo", "bar"]
        let sut = TryFrom<Int, String> { $0.count }
        
        // WHEN
        let output = try sut.pullback({ $0.joined() }).convert(input)
        
        // THEN
        XCTAssertEqual(output, 6)
    }
}
