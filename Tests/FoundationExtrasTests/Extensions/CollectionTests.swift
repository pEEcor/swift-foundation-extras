//
//  CollectionTests.swift
//  
//
//  Created by Paavo Becker on 14.06.24.
//

import XCTest

final class CollectionTests: XCTestCase {
    func testAsyncReduce_whenIntitialResultIsGiven() async throws {
        // GIVEN
        let input = [1, 2, 3, 4]
        let transform: (Int, Int) -> Int = { $0 + $1 }
        
        // WHEN
        let output = await input.asyncReduce(0, transform)
        
        // THEN
        XCTAssertEqual(output, 10)
    }
    
    func testAsyncReduce_whenAccumulatorIsGiven() async throws {
        // GIVEN
        let input = [1, 2, 3, 4]
        let transform: (inout [Int], Int) -> Void = { $0.append($1) }
        
        // WHEN
        let output: [Int] = await input.asyncReduce(into: [], transform)
        
        // THEN
        XCTAssertEqual(output, input)
    }
}
