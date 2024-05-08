//
//  File.swift
//  
//
//  Created by iferret on 2024/5/9.
//

import UIKit

extension UIGraphicsImageRendererFormat {
    
    /// preferred
    /// - Parameter scale: CGFloat
    /// - Returns: UIGraphicsImageRendererFormat
    internal static func preferred(scale: CGFloat) -> UIGraphicsImageRendererFormat {
        let format: UIGraphicsImageRendererFormat = .preferred()
        format.scale = scale
        return format
    }
    
    /// `default`
    /// - Parameter scale: CGFloat
    /// - Returns: UIGraphicsImageRendererFormat
    internal static func `default`(scale: CGFloat) -> UIGraphicsImageRendererFormat {
        let format: UIGraphicsImageRendererFormat = .default()
        format.scale = scale
        return format
    }
}
