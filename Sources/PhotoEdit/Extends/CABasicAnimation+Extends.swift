//
//  CABasicAnimation+Extends.swift
//
//
//  Created by iferret on 2024/5/7.
//

import UIKit

extension CABasicAnimation {
    
    /// KeyPath
   internal enum KeyPath: String {
        case fade = "opacity"
        case scale = "transform.scale"
        case rotation = "transform.rotation"
    }
    
    /// animation
    /// - Parameters:
    ///   - type: KeyPath
    ///   - fromValue: CGFloat
    ///   - toValue: CGFloat
    ///   - duration: TimeInterval
    /// - Returns: CAAnimation
    internal static func animation(keyPath: KeyPath, fromValue: CGFloat, toValue: CGFloat, duration: TimeInterval) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: keyPath.rawValue)
        animation.fromValue = fromValue
        animation.toValue = toValue
        animation.duration = duration
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        return animation
    }
}
