//
//  Assertions.swift
//
//  Copyright © 2024 Paavo Becker.
//

import XCTest

public func XCTAssertThrowsError<T>(
    _ expression: @autoclosure () async throws -> T,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #filePath,
    line: UInt = #line,
    _ errorHandler: (_ error: any Error) -> Void = { _ in }
) async {
    do {
        _ = try await expression()
        XCTFail(message())
    } catch {
        errorHandler(error)
    }
}
