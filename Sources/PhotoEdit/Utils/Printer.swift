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
func xprint(_ items: Optional<Any>..., separator: String = " ", terminator: String = "\n") {
#if DEBUG
    let newText: String = items.compactMap { $0 }.map { "\($0)" }.joined(separator: separator)
    Swift.print(newText, separator: separator, terminator: terminator)
#endif
}
