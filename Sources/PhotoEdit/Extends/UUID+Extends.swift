//
//  UUID+Extends.swift
//
//
//  Created by iferret on 2024/5/8.
//

import Foundation

extension UUID: CompatibleValue {}
extension CompatibleWrapper where Base == UUID {
    
    /// String
    internal var simpleID: String {
        return base.uuidString.replacingOccurrences(of: "-", with: "")
    }
}
