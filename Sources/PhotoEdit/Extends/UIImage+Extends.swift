//
//  UIImage+Extends.swift
//
//
//  Created by iferret on 2024/5/6.
//

import UIKit

extension UIImage {
    
    /// moduleImage
    /// - Parameter named: String
    /// - Returns: Optional<UIImage>
    internal static func moduleImage(_ named: String) -> Optional<UIImage> {
        return UIImage.init(named: named, in: .module, with: .none)
    }
}
