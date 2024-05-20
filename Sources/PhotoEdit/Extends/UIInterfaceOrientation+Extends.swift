//
//  File.swift
//  
//
//  Created by iferret on 2024/5/20.
//

import UIKit
import AVFoundation

extension UIInterfaceOrientation: CompatibleValue {}
extension CompatibleWrapper where Base == UIInterfaceOrientation {
    
    /// Optional<AVCaptureVideoOrientation>
    internal var videoOrientation: Optional<AVCaptureVideoOrientation> {
        switch base {
        case .unknown:              return .none
        case .portrait:             return .portrait
        case .portraitUpsideDown:   return .portraitUpsideDown
        case .landscapeLeft:        return .landscapeLeft
        case .landscapeRight:       return .landscapeRight
        default:                    return .none
        }
    }
}

