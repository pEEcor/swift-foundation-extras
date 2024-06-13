//
//  Collection.swift
//
//  Copyright © 2024 Paavo Becker.
//

import Foundation

extension Collection {
    /// Similar to syncronous `reduce(_:_)` but this version enables the usage of an async closure
    /// to make a partial result.
    ///
    /// - Parameters:
    ///   - initialResult: The value to use as the initial accumulating value.
    ///     `initialResult` is passed to `nextPartialResult` the first time the
    ///     closure is executed.
    ///   - nextPartialResult: A closure that combines an accumulating value and
    ///     an element of the sequence into a new accumulating value, to be used
    ///     in the next call of the `nextPartialResult` closure or returned to
    ///     the caller.
    /// - Returns: The final accumulated value. If the sequence has no elements,
    ///   the result is `initialResult`.
    ///
    /// - Complexity: O(*n*), where *n* is the length of the sequence.
    @inlinable
    public func asyncReduce<Result>(
        _ initialResult: Result,
        _ nextPartialResult: (_ partialResult: Result, Self.Element) async throws -> Result
    ) async rethrows -> Result {
        if let first = self.first {
            // Calculate the partial result of the current result and the first item in the list.
            let next = try await nextPartialResult(initialResult, first)

            // Make the remaining list by removing the first element.
            let rest = self.dropFirst()

            // Call asyncReduce recursively to reduce the rest.
            return try await rest.asyncReduce(next, nextPartialResult)
        } else {
            return initialResult
        }
    }

    /// Similar to syncronous `reduce(into:_)` but this version enables the usage of an async
    /// closure to make a partial result.
    ///
    /// - Parameters:
    ///   - initialResult: The value to use as the initial accumulating value.
    ///   - updateAccumulatingResult: A closure that updates the accumulating
    ///     value with an element of the sequence.
    /// - Returns: The final accumulated value. If the sequence has no elements,
    ///   the result is `initialResult`.
    ///
    /// - Complexity: O(*n*), where *n* is the length of the sequence.
    @inlinable
    public func asyncReduce<Result>(
        into initialResult: Result,
        _ updateAccumulatingResult: (inout Result, Element) async throws -> Void
    ) async rethrows -> Result {
        // Make mutable copy of result
        var result = initialResult

        // Run reduce
        if let first = self.first {
            // Accumulate first value.
            try await updateAccumulatingResult(&result, first)

            // Make the remaining list by removing the first element.
            let rest = self.dropFirst()

            // Call asyncReduce recursively to reduce the rest.
            return try await rest.asyncReduce(into: result, updateAccumulatingResult)
        } else {
            return result
        }
    }
}
