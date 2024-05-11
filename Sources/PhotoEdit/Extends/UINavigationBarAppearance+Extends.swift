//
//  UINavigationBarAppearance+Extends.swift
//
//
//  Created by iferret on 2024/5/11.
//

import UIKit

extension UINavigationBarAppearance {
    
    /// UINavigationBarAppearance
    internal static func transparent() -> UINavigationBarAppearance {
        let obj: UINavigationBarAppearance = .init()
        obj.configureWithTransparentBackground()
        return obj
    }
}
