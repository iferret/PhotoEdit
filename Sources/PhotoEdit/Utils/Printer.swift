//
//  Printer.swift
//
//
//  Created by iferret on 2024/5/7.
//

import Foundation

/// xprint
/// - Parameters:
///   - items: Any...
///   - separator: String
///   - terminator: String
func xprint(_ items: Any..., separator: String = " ", terminator: String = "\n") {
#if DEBUG
    Swift.print(items, separator: separator, terminator: terminator)
#endif
}
