//
//  Sequence.swift
//
//  Copyright © 2024 Paavo Becker.
//

import Foundation

// MARK: - async and concurrent mapping

extension Sequence {
    /// Maps an async closure over a sequence. The transformations are performed sequentially.
    ///
    /// - Parameter transform: Async transformation
    /// - Returns: Transformed sequence
    @inlinable
    public func asyncMap<T>(
        _ transform: @escaping (Element) async throws -> T
    ) async rethrows -> [T] {
        var values: [T] = []
        for element in self {
            try await values.append(transform(element))
        }
        return values
    }

    /// Maps an async closure over a sequence. The transformations are performed sequentially.
    ///
    /// - Parameter transform: Async transformation
    /// - Returns: Transformed sequence
    @inlinable
    public func asyncCompactMap<T>(
        _ transform: @escaping (Element) async throws -> T?
    ) async rethrows -> [T] {
        var values: [T] = []
        for element in self {
            guard let transformation = try await transform(element) else {
                continue
            }
            values.append(transformation)
        }
        return values
    }

    /// Applies an async closure to each element of the sequence.
    ///
    /// - Parameter operation: Async operation
    @inlinable
    public func asyncForEach(
        _ operation: @escaping (Element) async throws -> Void
    ) async rethrows {
        for element in self {
            try await operation(element)
        }
    }

    /// Filters the sequence using an async predicate.
    ///
    /// - Parameter isIncluded: Asynchrones Prädikat
    /// - Returns: Gefilterte Sequenz in der alle Elemente das Prädikat erfüllen
    @inlinable
    public func asyncFilter(
        _ isIncluded: @escaping (Element) async throws -> Bool
    ) async rethrows -> [Element] {
        try await self.asyncCompactMap { element in
            try await isIncluded(element) ? element : nil
        }
    }
}

extension Sequence where Element: Sendable {
    /// Maps an async closure over a sequence, performing all operations concurrently.
    ///
    /// The order of elements is preserved.
    ///
    /// - Parameter transform: Async transformation
    /// - Returns: Transformed sequence
    @inlinable
    public func concurrentMap<T: Sendable>(
        _ transform: @escaping @Sendable (Element) async throws -> T
    ) async throws -> [T] {
        try await map { element in
            Task {
                try Task.checkCancellation()
                let value = try await transform(element)
                try Task.checkCancellation()
                return value
            }
        }
        .asyncMap { task in
            try await task.value
        }
    }

    /// Maps an async closure over a sequence, performing all operations concurrently.
    ///
    /// The order of elements is NOT preserved.
    ///
    /// - Parameter transform: Async transformation
    /// - Returns: Transformed sequence
    @inlinable
    public func unorderedConcurrentMap<T: Sendable>(
        _ transform: @escaping @Sendable (Element) async throws -> T
    ) async throws -> [T] {
        try await withThrowingTaskGroup(of: T.self) { taskGroup in
            var result: [T] = []

            for element in self {
                taskGroup.addTask {
                    try await transform(element)
                }
            }

            for try await resultElement in taskGroup {
                result.append(resultElement)
            }

            return result
        }
    }

    /// Maps an async closure over a sequence, performing all operations concurrently
    ///
    /// The order of elements is preserved
    ///
    /// - Parameter transform: Async transformation
    /// - Returns: Transformed sequence
    @inlinable
    public func concurrentCompactMap<T: Sendable>(
        _ transform: @escaping @Sendable (Element) async throws -> T?
    ) async throws -> [T] {
        try await map { element in
            Task {
                try await transform(element)
            }
        }
        .asyncCompactMap { task in
            try await task.value
        }
    }

    /// Applies an async closure to each element of the sequence, performing all operations
    /// concurrently
    ///
    /// - Parameter transform: Async transformation
    @inlinable
    public func concurrentForEach(
        _ operation: @escaping @Sendable (Element) async throws -> Void
    ) async throws {
        try await map { element in
            Task {
                try await operation(element)
            }
        }
        .asyncForEach { task in
            try await task.value
        }
    }
}
