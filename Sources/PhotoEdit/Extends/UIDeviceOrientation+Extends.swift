//
//  File.swift
//  
//
//  Created by iferret on 2024/5/20.
//

import UIKit
import AVFoundation

extension UIDeviceOrientation: CompatibleValue {}
extension CompatibleWrapper where Base == UIDeviceOrientation {
    
    /// AVCaptureVideoOrientation
    internal var videoOrientation: Optional<AVCaptureVideoOrientation> {
        switch base {
        case .unknown:              return .none
        case .portrait:             return .portrait
        case .portraitUpsideDown:   return .portraitUpsideDown
        case .landscapeLeft:        return .landscapeLeft
        case .landscapeRight:       return .landscapeRight
        case .faceUp:               return .none
        case .faceDown:             return .none
        @unknown default:           return .none
        }
    }
}
