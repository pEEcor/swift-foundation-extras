//
//  Duration.swift
//
//  Copyright © 2023 Paavo Becker.
//

import Foundation

extension Duration {
    public init(seconds: Double) {
        // Make nanoseconds from seconds
        let nanoseconds = seconds * Double(NSEC_PER_SEC)

        // Initialize self with nanoseconds
        self = Duration.nanoseconds(Int64(nanoseconds))
    }

    /// Provides the duration as seconds. This may be lossy if the duration connot represented
    /// exaclty by the Double value.
    public var seconds: Double {
        // Calculate nanoseconds
        let ASEC_PER_SEC = NSEC_PER_SEC * NSEC_PER_SEC
        let fraction = Double(self.components.attoseconds) / Double(ASEC_PER_SEC)

        // Cast to double
        return Double(self.components.seconds) + Double(fraction)
    }
}
