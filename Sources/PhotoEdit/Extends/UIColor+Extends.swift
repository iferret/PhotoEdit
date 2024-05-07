//
//  UIColor+Extends.swift
//
//
//  Created by iferret on 2024/5/6.
//

import UIKit

/// UIColor
extension UIColor {
    
    /// 构建
    /// - Parameters:
    ///   - hex: String
    ///   - alpha: CGFloat
    internal convenience init(hex: String, alpha: CGFloat = 1.0) {
        let hex = hex.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        if Scanner(string: hex).scanHexInt64(&rgb) {
            self.init(red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
                      green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
                      blue: CGFloat(rgb & 0x0000FF) / 255.0,
                      alpha: alpha)
        } else {
            self.init(red: 0.0, green: 0.0, blue: 0.0, alpha: alpha)
        }
    }
    
    /// 构建
    /// - Parameters:
    ///   - hex: String
    ///   - alpha: CGFloat
    /// - Returns: UIColor
    internal static func hex(_ hex: String, alpha: CGFloat = 1.0) -> UIColor {
        return .init(hex: hex, alpha: alpha)
    }
    
    /// UIColor
    internal static var random: UIColor {
        let randomRed: CGFloat = .random(in: 0...1)
        let randomGreen: CGFloat = .random(in: 0...1)
        let randomBlue: CGFloat = .random(in: 0...1)
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
    }
}
