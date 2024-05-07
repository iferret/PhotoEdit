//
//  File.swift
//  
//
//  Created by iferret on 2024/5/7.
//

import UIKit

extension UIAlertController: Compatible {}
extension CompatibleWrapper where Base: UIAlertController {
    
    /// addAction
    /// - Parameters:
    ///   - title: Optional<String>
    ///   - titleColor: UIColor
    ///   - style: UIAlertAction.Style
    ///   - handler: Optional<(_ action: UIAlertAction) -> Void>
    internal func addAction(title: Optional<String>,
                            titleColor: Optional<UIColor> = .none,
                            style: UIAlertAction.Style = .default,
                            handler: Optional<(_ action: UIAlertAction) -> Void> = .none) {
        let obj: UIAlertAction = .init(title: title, style: style, handler: handler)
        if let titleColor = titleColor {
            obj.setValue(titleColor, forKey: "titleTextColor")
        }
        base.addAction(obj)
    }
    
}
