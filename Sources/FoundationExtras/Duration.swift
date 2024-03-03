//
//  Duration.swift
//
//
//  Created by Paavo Becker on 14.09.23.
//

import Foundation

extension Duration {
    public init(seconds: Double) {
        /// Make nanoseconds from seconds
        let nanoseconds = seconds * Double(NSEC_PER_SEC)
        
        /// Initialize self with nanoseconds
        self = Duration.nanoseconds(Int64(nanoseconds))
    }
    
    public var seconds: Double {
        /// Calculate nanoseconds
        let nanoseconds = self.components.attoseconds / Int64(NSEC_PER_SEC)
        
        /// Cast to double
        return Double(nanoseconds)
    }
}
