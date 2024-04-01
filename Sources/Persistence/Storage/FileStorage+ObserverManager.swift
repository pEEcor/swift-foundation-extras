//
//  FileStorage+ObserverManager.swift
//
//  Copyright © 2024 Paavo Becker.
//

////
////  FileStorage+ObserverManager.swift
////
////  Copyright © 2024 Paavo Becker.
////
//
// import ConcurrencyExtras
// import Foundation
//
// extension FileStorage {
//    class ObserverManager: @unchecked Sendable {
//        /// Action that gets executed for each observation when the stored value changes.
//        private typealias NotifyAction = (Value, Value) -> Void
//
//        /// The collection of observers.
//        private let observers: LockIsolated<[PartialKeyPath<Value>: NotifyAction]>
//
//        init() {
//            self.observers = LockIsolated([:])
//        }
//
//        func add<Element: Equatable>(
//            keyPath: KeyPath<Value, Element>,
//            emit: @Sendable @escaping (StorageEvent<Element>) -> Void,
//            finish: @Sendable @escaping () -> Void
//        ) {
//            self.observers.withValue { observers in
//                observers[keyPath] = { prev, next in
//                    // Determine the prev and next state at the given key path.
//                    let prev = prev[keyPath: keyPath]
//                    let next = next[keyPath: keyPath]
//
//                    // Abort if no change is present.
//                    guard next != prev else {
//                        return
//                    }
//
//                    // Create the event
//                    let event = StorageEvent(prev: prev, next: next)
//
//                    // Emit event to the observer.
//                    emit(event)
//
//                    // If the event is .deleted, the stream of the observer is closed
//                    /automatically
//                    // since it is clear, that no event for this element will ever emitted again.
//                    if case .deleted = event {
//                        finish()
//                    }
//                }
//            }
//        }
//
//        func remove(keyPath: PartialKeyPath<Value>) {
//            self.observers.withValue { _ = $0.removeValue(forKey: keyPath) }
//        }
//
//        func notify(prev: Value, next: Value) {
//            self.observers.withValue { observers in
//                observers.values.forEach { $0(prev, next) }
//            }
//        }
//    }
// }
