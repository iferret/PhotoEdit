//
//  AVCaptureSession+Extends.swift
//
//
//  Created by iferret on 2024/5/7.
//

import AVFoundation

extension AVCaptureSession {
    /// Optional<Void>
    fileprivate static var safeQueueKey: Optional<Void> = .none
    
}

extension AVCaptureSession: Compatible {}
extension CompatibleWrapper where Base: AVCaptureSession {
    
    /// DispatchQueue
    internal var safeQueue: DispatchQueue {
        if let obj = objc_getAssociatedObject(base, &AVCaptureSession.safeQueueKey) as? DispatchQueue {
            return obj
        } else {
            let obj: DispatchQueue = .init(label: "AVCaptureSession.safeQueue", qos: .userInitiated)
            objc_setAssociatedObject(base, &AVCaptureSession.safeQueueKey, obj, .OBJC_ASSOCIATION_RETAIN)
            return obj
        }
    }
    
    /// requestAuthorization
    /// - Parameters:
    ///   - mediaType: AVMediaType
    ///   - callbackQueue: Optional<DispatchQueue>
    ///   - completionHandler: @escaping (_ status: AVAuthorizationStatus) -> Void
    internal func requestAuthorization(for mediaType: AVMediaType,
                                       callbackQueue: Optional<DispatchQueue> = .none,
                                       completionHandler: @escaping (_ status: AVAuthorizationStatus) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: mediaType) {
        case .authorized:
            DispatchQueue.execute(inQueue: callbackQueue) { completionHandler(.authorized) }
        case .denied:
            DispatchQueue.execute(inQueue: callbackQueue) { completionHandler(.denied) }
        case .restricted:
            DispatchQueue.execute(inQueue: callbackQueue) { completionHandler(.restricted) }
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: mediaType) { _ in
                DispatchQueue.execute(inQueue: callbackQueue) { completionHandler(AVCaptureDevice.authorizationStatus(for: mediaType)) }
            }
        }
    }
    
    /// startRunning
    /// - Parameters:
    ///   - callbackQueue: Optional<DispatchQueue>
    ///   - comnpletionHandler: Optional<() -> Void> = .none
    internal func startRunning(callbackQueue: Optional<DispatchQueue> = .none, comnpletionHandler: Optional<() -> Void> = .none) {
        safeQueue.async {[weak base] in
            guard let base = base else { return }
            if base.isRunning == false {
                base.startRunning()
                DispatchQueue.execute(inQueue: callbackQueue) { comnpletionHandler?() }
            } else {
                DispatchQueue.execute(inQueue: callbackQueue) { comnpletionHandler?() }
            }
        }
    }
    
    /// stopRunning
    /// - Parameters:
    ///   - callbackQueue: Optional<DispatchQueue>
    ///   - comnpletionHandler: Optional<() -> Void>
    internal func stopRunning(callbackQueue: Optional<DispatchQueue> = .none, comnpletionHandler: Optional<() -> Void> = .none) {
        safeQueue.async {[weak base] in
            guard let base = base else { return }
            if base.isRunning == true {
                base.stopRunning()
                DispatchQueue.execute(inQueue: callbackQueue) { comnpletionHandler?() }
            } else {
                DispatchQueue.execute(inQueue: callbackQueue) { comnpletionHandler?() }
            }
        }
    }
    
    /// contains
    /// - Parameter input: AVCaptureInput
    /// - Returns: Bool
    internal func contains(_ input: AVCaptureInput) -> Bool {
        return base.inputs.contains(input)
    }
    
    /// contains
    /// - Parameter output: AVCaptureOutput
    /// - Returns: Bool
    internal func contains(_ output: AVCaptureOutput) -> Bool {
        return base.outputs.contains(output)
    }
    
}
