//
//  PEVideoPreviewView.swift
//
//
//  Created by iferret on 2024/5/7.
//

import UIKit
import AVFoundation
import SnapKit

/// PEVideoPreviewView
class PEVideoPreviewView: UIView {
    
    // MARK: 公开属性
    
    /// AnyClass
    internal override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    /// AVCaptureVideoPreviewLayer
    internal var previewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
    
    // MARK: 私有属性
    
    /// UIVisualEffectView
    private lazy var effectView: UIVisualEffectView = {
        let _effectView: UIVisualEffectView = .init(effect: UIBlurEffect.init(style: .dark))
        _effectView.alpha = 0.0
        return _effectView
    }()
    
    // MARK: 生命周期
    
    /// 构建
    /// - Parameter session: AVCaptureSession
    internal init(session: AVCaptureSession) {
        super.init(frame: .zero)
        self.previewLayer.session = session
        // 初始化
        initialize()
    }
    
    /// 构建
    /// - Parameter coder: NSCoder
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension PEVideoPreviewView {
    
    /// 初始化
    private func initialize() {
        // coding here ...
        addSubview(effectView)
        effectView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    /// blured
    internal func blured() {
        UIView.animate(withDuration: 0.25) {
            self.effectView.alpha = 1.0
        }
    }
    
    /// unblured
    internal func unblured() {
        UIView.animate(withDuration: 0.25) {
            self.effectView.alpha = 0.0
        }
    }
}

extension PEVideoPreviewView {
    
    /// Optional<AVCaptureSession>
    internal var session: Optional<AVCaptureSession> {
        get { previewLayer.session }
        set { previewLayer.session = newValue }
    }
    
    /**
     method setSessionWithNoConnection:
     @abstract
     Attaches the receiver to a given session without implicitly forming a connection to the first eligible video AVCaptureInputPort. Only use this setter if you intend to manually form a connection between a desired AVCaptureInputPort and the receiver using AVCaptureSession's -addConnection: method.
     
     @discussion
     The session is retained by the preview layer.
     */
    @available(iOS 8.0, *)
    internal func setSessionWithNoConnection(_ session: AVCaptureSession) {
        previewLayer.setSessionWithNoConnection(session)
    }
    
    /**
     @property connection
     @abstract
     The AVCaptureConnection instance describing the AVCaptureInputPort to which the receiver is connected.
     
     @discussion
     When calling initWithSession: or setSession: with a valid AVCaptureSession instance, a connection is formed to the first eligible video AVCaptureInput. If the receiver is detached from a session, the connection property becomes nil.
     */
    @available(iOS 6.0, *)
    internal var connection: Optional<AVCaptureConnection> {
        return previewLayer.connection
    }
    
    /**
     @property videoGravity
     @abstract
     A string defining how the video is displayed within an AVCaptureVideoPreviewLayer bounds rect.
     
     @discussion
     Options are AVLayerVideoGravityResize, AVLayerVideoGravityResizeAspect and AVLayerVideoGravityResizeAspectFill. AVLayerVideoGravityResizeAspect is default. See <AVFoundation/AVAnimation.h> for a description of these options.
     */
    internal var videoGravity: AVLayerVideoGravity {
        get { previewLayer.videoGravity }
        set { previewLayer.videoGravity = newValue }
    }
    
    /**
     @property previewing
     @abstract
     A BOOL value indicating whether the receiver is currently rendering video frames from its source.
     
     @discussion
     An AVCaptureVideoPreviewLayer begins previewing when -[AVCaptureSession startRunning] is called. When associated with an AVCaptureMultiCamSession, all video preview layers are guaranteed to be previewing by the time the blocking call to -startRunning or -commitConfiguration returns. While a session is running, you may enable or disable a video preview layer's connection to re-start or stop the flow of video to the layer. Once you've set enabled to YES, you can observe this property changing from NO to YES and synchronize any UI to take place precisely when the video resumes rendering to the video preview layer.
     */
    @available(iOS 13.0, *)
    internal var isPreviewing: Bool {
        return previewLayer.isPreviewing
    }
    
    /**
     @method captureDevicePointOfInterestForPoint:
     @abstract
     Converts a point in layer coordinates to a point of interest in the coordinate space of the capture device providing input to the layer.
     
     @param pointInLayer
     A CGPoint in layer coordinates.
     @result
     A CGPoint in the coordinate space of the capture device providing input to the layer.
     
     @discussion
     AVCaptureDevice pointOfInterest is expressed as a CGPoint where {0,0} represents the top left of the picture area, and {1,1} represents the bottom right on an unrotated picture. This convenience method converts a point in the coordinate space of the receiver to a point of interest in the coordinate space of the AVCaptureDevice providing input to the receiver. The conversion takes frameSize and videoGravity into consideration.
     */
    @available(iOS 6.0, *)
    internal func captureDevicePointConverted(fromLayerPoint pointInLayer: CGPoint) -> CGPoint {
        return previewLayer.captureDevicePointConverted(fromLayerPoint: pointInLayer)
    }
    
    /**
     @method pointForCaptureDevicePointOfInterest:
     @abstract
     Converts a point of interest in the coordinate space of the capture device providing input to the layer to a point in layer coordinates.
     
     @param captureDevicePointOfInterest
     A CGPoint in the coordinate space of the capture device providing input to the layer.
     @result
     A CGPoint in layer coordinates.
     
     @discussion
     AVCaptureDevice pointOfInterest is expressed as a CGPoint where {0,0} represents the top left of the picture area, and {1,1} represents the bottom right on an unrotated picture. This convenience method converts a point in the coordinate space of the AVCaptureDevice providing input to the coordinate space of the receiver. The conversion takes frame size and videoGravity into consideration.
     */
    @available(iOS 6.0, *)
    internal func layerPointConverted(fromCaptureDevicePoint captureDevicePointOfInterest: CGPoint) -> CGPoint {
        return previewLayer.layerPointConverted(fromCaptureDevicePoint: captureDevicePointOfInterest)
    }
    
    /**
     @method metadataOutputRectOfInterestForRect:
     @abstract
     Converts a rectangle in layer coordinates to a rectangle of interest in the coordinate space of an AVCaptureMetadataOutput whose capture device is providing input to the layer.
     
     @param rectInLayerCoordinates
     A CGRect in layer coordinates.
     @result
     A CGRect in the coordinate space of the metadata output whose capture device is providing input to the layer.
     
     @discussion
     AVCaptureMetadataOutput rectOfInterest is expressed as a CGRect where {0,0} represents the top left of the picture area, and {1,1} represents the bottom right on an unrotated picture. This convenience method converts a rectangle in the coordinate space of the receiver to a rectangle of interest in the coordinate space of an AVCaptureMetadataOutput whose AVCaptureDevice is providing input to the receiver. The conversion takes frame size and videoGravity into consideration.
     */
    @available(iOS 7.0, *)
    internal func metadataOutputRectConverted(fromLayerRect rectInLayerCoordinates: CGRect) -> CGRect {
        return previewLayer.metadataOutputRectConverted(fromLayerRect: rectInLayerCoordinates)
    }
    
    /**
     @method rectForMetadataOutputRectOfInterest:
     @abstract
     Converts a rectangle of interest in the coordinate space of an AVCaptureMetadataOutput whose capture device is providing input to the layer to a rectangle in layer coordinates.
     
     @param rectInMetadataOutputCoordinates
     A CGRect in the coordinate space of the metadata output whose capture device is providing input to the layer.
     @result
     A CGRect in layer coordinates.
     
     @discussion
     AVCaptureMetadataOutput rectOfInterest is expressed as a CGRect where {0,0} represents the top left of the picture area, and {1,1} represents the bottom right on an unrotated picture. This convenience method converts a rectangle in the coordinate space of an AVCaptureMetadataOutput whose AVCaptureDevice is providing input to the coordinate space of the receiver. The conversion takes frame size and videoGravity into consideration.
     */
    @available(iOS 7.0, *)
    internal func layerRectConverted(fromMetadataOutputRect rectInMetadataOutputCoordinates: CGRect) -> CGRect {
        return previewLayer.layerRectConverted(fromMetadataOutputRect: rectInMetadataOutputCoordinates)
    }
    
    /**
     @method transformedMetadataObjectForMetadataObject:
     @abstract
     Converts an AVMetadataObject's visual properties to layer coordinates.
     
     @param metadataObject
     An AVMetadataObject originating from the same AVCaptureInput as the preview layer.
     @result
     An AVMetadataObject whose properties are in layer coordinates.
     
     @discussion
     AVMetadataObject bounds may be expressed as a rect where {0,0} represents the top left of the picture area, and {1,1} represents the bottom right on an unrotated picture. Face metadata objects likewise express yaw and roll angles with respect to an unrotated picture. -transformedMetadataObjectForMetadataObject: converts the visual properties in the coordinate space of the supplied AVMetadataObject to the coordinate space of the receiver. The conversion takes orientation, mirroring, layer bounds and videoGravity into consideration. If the provided metadata object originates from an input source other than the preview layer's, nil will be returned.
     */
    @available(iOS 6.0, *)
    internal func transformedMetadataObject(for metadataObject: AVMetadataObject) -> AVMetadataObject? {
        return previewLayer.transformedMetadataObject(for: metadataObject)
    }
}
