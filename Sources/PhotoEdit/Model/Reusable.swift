//
//  File.swift
//  
//
//  Created by iferret on 2024/5/7.
//

import Foundation

/// Reusable
protocol Reusable {
    /// String
    static var reusedID: String { get }
}

extension Reusable {
    
    /// String
    internal static var reusedID: String {
        return .init(describing: self) + ".reusedID"
    }
}
