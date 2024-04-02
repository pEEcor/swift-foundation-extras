//
//  File.swift
//  
//
//  Created by Paavo Becker on 02.04.24.
//

import XCTest
import Persistence

final class StorageTests: XCTestCase {
    func testValues_containAllValues() throws {
        // GIVEN
        let storage: any Storage<Int, Int> = MemoryStorage(initialValue: [1: 42, 2: 43])
        
        // WHEN
        let output = try storage.values
        
        // THEN
        XCTAssertEqual(output, [42, 43])
    }
    
    func testContent_containAllKeyValuePairs() throws {
        // GIVEN
        let storage: any Storage<Int, Int> = MemoryStorage(initialValue: [1: 42, 2: 43])
        
        // WHEN
        let output = try storage.content
        
        // THEN
        XCTAssertEqual(output, [1: 42, 2: 43])
    }
    
    func testClear_removesAllKeyValuePairsFromStorage() throws {
        // GIVEN
        let storage: any Storage<Int, Int> = MemoryStorage(initialValue: [1: 42, 2: 43])
        
        // WHEN
        try storage.clear()
        
        // THEN
        XCTAssertEqual(try storage.content, [:])
    }
    
    func testUpdate_updateValue_whenKeyAlreadyExists() throws {
        // GIVEN
        let storage: any Storage<Int, Int> = MemoryStorage(initialValue: [1: 42])
        
        // WHEN
        try storage.update(value: 43, for: 1)
        
        // THEN
        XCTAssertEqual(try storage.content, [1: 43])
    }
    
    func testUpdate_insertValue_whenKeyDoesNotExist() throws {
        // GIVEN
        let storage: any Storage<Int, Int> = MemoryStorage()
        
        // WHEN
        try storage.update(value: 43, for: 1)
        
        // THEN
        XCTAssertEqual(try storage.content, [1: 43])
    }
}
