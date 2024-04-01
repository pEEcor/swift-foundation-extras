//
//  UserDefaultsTests.swift
//
//  Copyright © 2024 Paavo Becker.
//

import Foundation
import FoundationExtras
import XCTest

final class UserDefaultsTests: XCTestCase {
    func testSetGet_returnValue() {
        struct Foo: Codable, Equatable { let value: Int }

        // GIVEN
        let defaults = UserDefaults()
        defaults.set(Foo(value: 42), for: 1)

        // WHEN
        let output: Foo? = defaults.get(for: 1)

        // THEN
        XCTAssertEqual(output, Foo(value: 42))
    }

    func testGet_returnNil_whenNoValueExistsForKey() {
        struct Foo: Codable, Equatable { let value: Int }

        // GIVEN
        let defaults = UserDefaults()

        // WHEN
        let output: Foo? = defaults.get(for: 2)

        // THEN
        XCTAssertNil(output)
    }

    func testGet_returnDefault_whenNoValueExistsForKey() {
        struct Foo: Codable, Equatable { let value: Int }

        // GIVEN
        let defaults = UserDefaults()

        // WHEN
        let output: Foo? = defaults.get(for: 3, default: Foo(value: 43))

        // THEN
        XCTAssertEqual(output, Foo(value: 43))
    }
}
