//
//  File.swift
//  
//
//  Created by iferret on 2024/5/7.
//

import UIKit

extension UIViewPropertyAnimator: Compatible {}
extension CompatibleWrapper where Base: UIViewPropertyAnimator {
    
    /// addAnimations
    /// - Parameter animation: @escaping () -> Void
    /// - Returns: UIViewPropertyAnimator
    @discardableResult
    internal func addAnimations(_ animation: @escaping () -> Void) -> UIViewPropertyAnimator {
        base.addAnimations(animation)
        return base
    }
    
    /// addCompletion
    /// - Parameter completion: (UIViewAnimatingPosition) -> Void
    /// - Returns: UIViewPropertyAnimator
    @discardableResult
    internal func addCompletion(_ completion: @escaping (UIViewAnimatingPosition) -> Void) -> UIViewPropertyAnimator {
        base.addCompletion(completion)
        return base
    }
}
