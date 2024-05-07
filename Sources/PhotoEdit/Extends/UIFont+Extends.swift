//
//  File.swift
//  
//
//  Created by iferret on 2024/5/7.
//

import UIKit

extension UIFont {
    
    /// PingFangSC Weight
    enum PFWeight: String {
        case medium     = "PingFangSC-Medium"
        case semibold   = "PingFangSC-Semibold"
        case light      = "PingFangSC-Light"
        case ultralight = "PingFangSC-Ultralight"
        case regular    = "PingFangSC-Regular"
        case thin       = "PingFangSC-Thin"
        
        /// UIFont.Weight
        fileprivate var fontWeight: UIFont.Weight {
            switch self {
            case .medium:       return .medium
            case .semibold:     return .semibold
            case .light:        return .light
            case .ultralight:   return .ultraLight
            case .regular:      return .regular
            case .thin:         return .thin
            }
        }
    }
    
    /// pingfang
    /// - Parameters:
    ///   - size: CGFloat
    ///   - weight: PFWeight
    /// - Returns: UIFont
    internal static func pingfang(ofSize size: CGFloat, weight: PFWeight = .regular) -> UIFont {
        if let font: UIFont = .init(name: weight.rawValue, size: size) {
            return font
        } else {
            return .systemFont(ofSize: size, weight: weight.fontWeight)
        }
    }
}
