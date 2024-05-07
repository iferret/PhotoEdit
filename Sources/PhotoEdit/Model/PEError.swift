//
//  File.swift
//  
//
//  Created by iferret on 2024/5/7.
//

import Foundation

/// PEError
enum PEError: LocalizedError {
    case custom(_ text: String)
    
    /// Optional<String>
    internal var errorDescription: Optional<String> {
        switch self {
        case .custom(let text): return text
        }
    }
}

