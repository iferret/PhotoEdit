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

extension UIImage: Compatible {}
extension CompatibleWrapper where Base: UIImage {
    
    /// 修复转向
    internal func fixOrientation() -> UIImage {
        if base.imageOrientation == .up { return base }
        
        var transform = CGAffineTransform.identity
        
        switch base.imageOrientation {
        case .down, .downMirrored:
            transform = CGAffineTransform(translationX: base.size.width, y: base.size.height)
            transform = transform.rotated(by: .pi)
        case .left, .leftMirrored:
            transform = CGAffineTransform(translationX: base.size.width, y: 0.0)
            transform = transform.rotated(by: .pi * 0.5)
        case .right, .rightMirrored:
            transform = CGAffineTransform(translationX: 0.0, y: base.size.height)
            transform = transform.rotated(by: -.pi * 0.5)
        default: break
        }
        
        switch base.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: base.size.width, y: 0.0)
            transform = transform.scaledBy(x: -1.0, y: 1.0)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: base.size.height, y: 0.0)
            transform = transform.scaledBy(x: -1.0, y: 1.0)
        default: break
        }
        // 绘制图片
        guard let cgImage = base.cgImage, let colorSpace = cgImage.colorSpace else {
            return base
        }
        let context: Optional<CGContext> = .init(data: .none,
                                                 width: Int(base.size.width),
                                                 height: Int(base.size.height),
                                                 bitsPerComponent: cgImage.bitsPerComponent,
                                                 bytesPerRow: 0,
                                                 space: colorSpace, bitmapInfo: cgImage.bitmapInfo.rawValue)
        context?.concatenate(transform)
        switch base.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            context?.draw(cgImage, in: .init(x: 0, y: 0, width: base.size.height, height: base.size.width))
        default:
            context?.draw(cgImage, in: .init(x: 0, y: 0, width: base.size.width, height: base.size.height))
        }
        guard let newCgImage = context?.makeImage() else { return base }
        return UIImage(cgImage: newCgImage)
    }
}
