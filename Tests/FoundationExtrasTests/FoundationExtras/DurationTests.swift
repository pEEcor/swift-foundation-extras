//
//  DurationTests.swift
//
//  Copyright © 2024 Paavo Becker.
//

import FoundationExtras
import XCTest

final class DurationTests: XCTestCase {
    func testInitSeconds_shouldInitializeDurationFromSeconds() {
        // GIVEN
        let seconds = 3.141

        // WHEN
        let components = Duration(seconds: seconds).components

        // THEN
        XCTAssertEqual(components.seconds, 3)
        XCTAssertEqual(components.attoseconds, 141_000_000_000_000_000)
    }

    func testSeconds_shouldContainDurationAsFloatingPointSeconds() {
        // GIVEN WHEN
        let duration = Duration(secondsComponent: 3, attosecondsComponent: 141_000_000_000_000_000)

        // THEN
        XCTAssertEqual(duration.seconds, Double(3.141))
    }
}
