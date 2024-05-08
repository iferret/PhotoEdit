//
//  UINavigationController+Extends.swift
//
//
//  Created by iferret on 2024/5/8.
//

import UIKit

extension UINavigationController: Compatible {}
extension CompatibleWrapper where Base: UINavigationController {
    
    /// viewControllers
    /// - Returns:  Array<T>
    internal func viewControllers<T>() -> Array<T> where T: UIViewController {
        return base.viewControllers.compactMap { $0 as? T }
    }
}
