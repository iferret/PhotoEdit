//
//  DispatchQueue+Extends.swift
//  
//
//  Created by iferret on 2024/5/8.
//

import Foundation

extension DispatchQueue {
    
    /// execute
    /// - Parameters:
    ///   - queue: Optional<DispatchQueue>
    ///   - block: block: @escaping () -> Void
    internal static func execute(inQueue queue: Optional<DispatchQueue> = .none, block: @escaping () -> Void) {
        if Thread.isMainThread == true && queue === DispatchQueue.main {
            block()
        } else if let queue = queue {
            queue.async(execute: block)
        } else {
            block()
        }
    }
}
