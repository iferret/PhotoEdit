//
//  File.swift
//  
//
//  Created by iferret on 2024/5/7.
//

import Foundation

extension String: CompatibleValue {}
extension CompatibleWrapper where Base == String {
    
    /// String
    internal var lastPathComponent: String {
        return (base as NSString).lastPathComponent
    }
}
