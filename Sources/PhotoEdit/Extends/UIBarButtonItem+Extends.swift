//
//  UIBarButtonItem+Extends.swift
//
//
//  Created by iferret on 2024/5/7.
//

import UIKit

extension UIBarButtonItem {
    
    /// UIBarButtonItem
    internal static var disabled: UIBarButtonItem {
        let item: UIBarButtonItem = .init(title: .none, style: .plain, target: .none, action: .none)
        item.isEnabled = false
        if #available(iOS 16.0, *) {
            item.isHidden = true
        }
        return item
    }
    
    /// flexible
    /// - Returns: UIBarButtonItem
    internal static func flexible() -> UIBarButtonItem {
        if #available(iOS 14.0, *) {
            return .flexibleSpace()
        } else {
            return .init(barButtonSystemItem: .flexibleSpace, target: .none, action: .none)
        }
    }
    
    /// fixed
    /// - Parameter width: CGFloat
    /// - Returns: UIBarButtonItem
    internal static func fixed(_ width: CGFloat) -> UIBarButtonItem {
        if #available(iOS 14.0, *) {
            return .fixedSpace(width)
        } else {
            let item: UIBarButtonItem = .init(barButtonSystemItem: .fixedSpace, target: .none, action: .none)
            item.width = width
            return item
        }
    }
}
