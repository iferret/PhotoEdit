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

extension CompatibleWrapper where Base: UIImage {
    
    /// CGFloat
    internal var widthAndHeight: CGFloat {
        return base.size.width / base.size.height
    }
    
    /// jpegData data
    /// - Parameter compressionQuality: CGFloat
    /// - Returns: Data
    internal func jpegData(compressionQuality: CGFloat) -> Data {
        if let data = base.jpegData(compressionQuality: compressionQuality) {
            return data
        } else {
            let render: UIGraphicsImageRenderer = .init(size: base.size, format: .preferred())
            return render.jpegData(withCompressionQuality: compressionQuality) { ctx in
                base.draw(in: .init(origin: .zero, size: base.size))
            }
        }
    }
    
    /// 压缩图片
    /// - Parameter maxLength: 最大字节
    /// - Returns: UIImage
    internal func compressData(toByte maxLength: Int) throws -> Data {
        var compression: CGFloat = 1
        var data = base.hub.jpegData(compressionQuality: compression)
        guard data.count > maxLength else { return data }
        print("Before compressing quality, image size =", data.count / 1024, "KB")
        
        // Compress by size
        var max: CGFloat = 1
        var min: CGFloat = 0
        for _ in 0 ..< 6 {
            compression = (max + min) / 2
            data = base.hub.jpegData(compressionQuality: compression)
            print("Compression =", compression)
            print("In compressing quality loop, image size =", data.count / 1024, "KB")
            if CGFloat(data.count) < CGFloat(maxLength) * 0.9 {
                min = compression
            } else if data.count > maxLength {
                max = compression
            } else {
                break
            }
        }
        
        print("After compressing quality, image size =", data.count / 1024, "KB")
        guard var resultImage = UIImage.init(data: data) else { throw PEError.custom("压缩图片失败")}
        if data.count < maxLength { return data }
        
        // Compress by size
        var lastDataLength: Int = 0
        while data.count > maxLength, data.count != lastDataLength {
            try autoreleasepool {
                lastDataLength = data.count
                let ratio = CGFloat(maxLength) / CGFloat(data.count)
                print("Ratio =", ratio)
                let size: CGSize = CGSize(width: Int(resultImage.size.width * sqrt(ratio)), height: Int(resultImage.size.height * sqrt(ratio)))
                UIGraphicsBeginImageContext(size)
                resultImage.draw(in: .init(x: 0.0, y: 0.0, width: size.width, height: size.height))
                guard let img = UIGraphicsGetImageFromCurrentImageContext() else {
                    UIGraphicsEndImageContext()
                    throw PEError.custom("图片压缩失败")
                }
                UIGraphicsEndImageContext()
                resultImage = img
                data = resultImage.hub.jpegData(compressionQuality: 1.0)
                print("In compressing size loop, image size =", data.count / 1024, "KB", "width=", size.width, "height=", size.height)
            }
        }
        print("After compressing size loop, image size =", data.count / 1024, "KB", "width=", resultImage.size.width, "height=", resultImage.size.height)
        return data
    }
    
    /// compressImage
    /// - Parameter maxLength: Int
    /// - Returns: UIImage
    internal func compressImage(toByte maxLength: Int) throws -> UIImage {
        let data: Data = try compressData(toByte: maxLength)
        if let img: UIImage = .init(data: data) {
            return img
        } else {
            throw PEError.custom("压缩后，生成图片失败")
        }
    }
}
