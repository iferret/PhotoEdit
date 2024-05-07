//
//  PEPresetItem.swift
//
//
//  Created by iferret on 2024/5/7.
//

import UIKit

/// PEPresetItem
struct PEPresetItem: Hashable {
    internal let text: String
    internal let attributes: [NSAttributedString.Key: Any]
    internal let selectedAttributes: [NSAttributedString.Key: Any]
    
    /// ==
    /// - Parameters:
    ///   - lhs: PEPresetItem
    ///   - rhs: PEPresetItem
    /// - Returns: Bool
    internal static func == (lhs: PEPresetItem, rhs: PEPresetItem) -> Bool {
        return lhs.text == rhs.text
    }
    
    /// hash
    /// - Parameter hasher: Hasher
    internal func hash(into hasher: inout Hasher) {
        hasher.combine(text)
    }
}

extension PEPresetItem {
    
    /// [NSAttributedString.Key: Any]
    fileprivate static var attributes: [NSAttributedString.Key: Any] {
        return [.font: UIFont.pingfang(ofSize: 14.0), .foregroundColor: UIColor.hex("#CCCCCC")]
    }
    
    /// [NSAttributedString.Key: Any]
    fileprivate static var selectedAttributes: [NSAttributedString.Key: Any] {
        return [.font: UIFont.pingfang(ofSize: 14.0, weight: .medium), .foregroundColor: UIColor.hex("#FFE27E")]
    }
    
    /// 视频
    internal static var video: PEPresetItem {
        return .init(text: "视频", attributes: PEPresetItem.attributes, selectedAttributes: PEPresetItem.selectedAttributes)
    }
    
    /// 照片
    internal static var photo: PEPresetItem {
        return .init(text: "照片", attributes: PEPresetItem.attributes, selectedAttributes: PEPresetItem.selectedAttributes)
    }
}

extension PEPresetItem: CompatibleValue {}
extension CompatibleWrapper where Base == PEPresetItem {
    
    /// UIFont
    internal var maxfont: UIFont {
        if let font = base.selectedAttributes[.font] as? UIFont {
            return font
        } else if let font = base.attributes[.font] as? UIFont {
            return font
        } else {
            return .pingfang(ofSize: 14.0, weight: .medium)
        }
    }
    
    /// NSAttributedString
    internal var normalText: NSAttributedString {
        return .init(string: base.text, attributes: base.attributes)
    }
    
    /// NSAttributedString
    internal var selectedText: NSAttributedString {
        return .init(string: base.text, attributes: base.selectedAttributes)
    }
}
