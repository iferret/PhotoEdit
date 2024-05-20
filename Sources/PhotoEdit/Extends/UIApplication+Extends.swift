//
//  UIApplication+Extends.swift
//
//
//  Created by iferret on 2024/5/16.
//

import UIKit

extension UIApplication: Compatible {}
extension CompatibleWrapper where Base: UIApplication {
    
    /// The app's key window.
    internal var keyWindow: Optional<UIWindow> {
        guard Thread.isMainThread == true else {
            return DispatchQueue.main.sync { self.keyWindow }
        }
        if #available(iOS 15.0, *) {
            let connectedScenes: [UIWindowScene] = base.connectedScenes.compactMap { $0 as? UIWindowScene }
            for connectedScene in connectedScenes {
                guard let window = connectedScene.windows.first(where: \.isKeyWindow) else { continue }
                return window
            }
            return UIApplication.shared.keyWindow
        } else {
            return base.windows.first(where: \.isKeyWindow) ?? UIApplication.shared.keyWindow
        }
    }
    
    /// Optional<UIScreen>
    internal var screen: Optional<UIScreen> {
        if Thread.isMainThread == true {
            return base.hub.keyWindow?.screen
        } else {
            return DispatchQueue.main.sync { base.hub.keyWindow?.screen }
        }
    }
    
    /// The insets that you use to determine the safe area for this view.
    internal var safeAreaInsets: UIEdgeInsets {
        guard Thread.isMainThread == true else {
            return DispatchQueue.main.sync { self.safeAreaInsets }
        }
        return keyWindow?.safeAreaInsets ?? .zero
    }
    
    /// The frame rectangle defining the area of the status bar.
    internal var statusBarFrame: CGRect {
        guard Thread.isMainThread == true else {
            return DispatchQueue.main.sync { self.statusBarFrame }
        }
        let connectedScenes: [UIWindowScene] = base.connectedScenes.compactMap { $0 as? UIWindowScene }
        return connectedScenes.first(where: { $0.statusBarManager != nil })?.statusBarManager?.statusBarFrame ?? .zero
    }
    
    /// UIInterfaceOrientation
    internal var interfaceOrientation: UIInterfaceOrientation {
        return base.hub.keyWindow?.windowScene?.interfaceOrientation ?? .portrait
    }
}
