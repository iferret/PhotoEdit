//
//  PECameraViewController.swift
//
//
//  Created by iferret on 2024/5/6.
//

import UIKit
import AVFoundation
import SnapKit

/// PECameraViewController
class PECameraViewController: UIViewController {
    
    // MARK: 私有属性
    
    /// 闪光灯
    private lazy var flashItem: UIBarButtonItem = {
        let _img: Optional<UIImage> = .moduleImage("camera_flash_auto")?.withRenderingMode(.alwaysTemplate)
        let _item: UIBarButtonItem = .init(image: _img, style: .plain, target: self, action: .none)
        _item.tintColor = .hex("#FFE27E")
        return _item
    }()
    
    /// PEVideoPreviewView
    private lazy var previewView: PEVideoPreviewView = {
        let _previewView: PEVideoPreviewView = .init(session: session)
        _previewView.backgroundColor = .hex("#000000")
        _previewView.videoGravity = .resizeAspectFill
        return _previewView
    }()
    
    /// UIView
    private lazy var lineView: UIView = {
        let _lineView: UIView = .init(frame: .zero)
        _lineView.backgroundColor = .random
        return _lineView
    }()
    
    /// PEZoomFactorView
    private lazy var zoomFactorView: PEZoomFactorView = {
        let _factorView: PEZoomFactorView = .init(frame: .zero)
        _factorView.backgroundColor = .hex("#000000", alpha: 0.1)
        _factorView.cornerRadius = 22.0
        _factorView.masksToBounds = true
        _factorView.delegate = self
        return _factorView
    }()
    
    /// PEPresetView
    private lazy var presetView: PEPresetView = {
        let _presetView: PEPresetView = .init(items: [.video, .photo])
        _presetView.backgroundColor = .clear
        _presetView.delegate = self
        return _presetView
    }()
    
    /// 拍摄照片按钮
    private lazy var takeBtn: UIButton = {
        let _button: UIButton = .init(type: .custom)
        _button.setBackgroundImage(.moduleImage("camera_takephoto")?.withRenderingMode(.alwaysTemplate), for: .normal)
        _button.setBackgroundImage(.moduleImage("camera_takephoto_highlight")?.withRenderingMode(.alwaysTemplate), for: .highlighted)
        _button.tintColor = .hex("#FFFFFF")
        _button.addTarget(self, action: #selector(buttonActionHandler(_:)), for: .touchUpInside)
        return _button
    }()
    
    /// 取消按钮
    private lazy var cancelBtn: UIButton = {
        let _button: UIButton = .init(type: .custom)
        _button.setTitle("取消", for: .normal)
        _button.setTitleColor(.hex("#F9F9F9"), for: .normal)
        _button.titleLabel?.font = .pingfang(ofSize: 18.0)
        _button.addTarget(self, action: #selector(buttonActionHandler(_:)), for: .touchUpInside)
        return _button
    }()
    
    /// 切换摄像头
    private var reverseBtn: UIButton = {
        let _button: UIButton = .init(type: .custom)
        _button.setBackgroundImage(.moduleImage("camera_reverse"), for: .normal)
        _button.addTarget(self, action: #selector(buttonActionHandler(_:)), for: .touchUpInside)
        return _button
    }()
    
    /// AVCaptureSession
    private let session: AVCaptureSession = {
        let _session: AVCaptureSession = .init()
        _session.sessionPreset = .photo
        return _session
    }()
    
    /// PEMediaType
    private var mediaType: PEMediaType = .photo
    
    /// Optional<AVCaptureDeviceInput>
    private var videoInput: Optional<AVCaptureDeviceInput> = .none {
        didSet { reloadZoomFactorWith(videoInput) }
    }
    /// Optional<AVCaptureDeviceInput>
    private var audioInput: Optional<AVCaptureDeviceInput> = .none
    /// Optional<AVCapturePhotoOutput>
    private var photoOutput: Optional<AVCapturePhotoOutput> = .none
    /// Optional<AVCaptureMovieFileOutput>
    private var videoOutput: Optional<AVCaptureMovieFileOutput> = .none
    /// AVCaptureDevice.Position
    private var postion: AVCaptureDevice.Position { videoInput?.device.position ?? .back }
    
    // MARK: 生命周期
    
    /// viewDidLoad
    internal override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // 初始化
        initialize()
        // 获取授权
        session.hub.requestAuthorization(for: .video, callbackQueue: .main) {[weak self] status in
            guard let this = self else { return }
            switch status {
            case .authorized:
                do {
                    // 配置参数
                    try this.configureWith(mediaType: this.mediaType, position: this.postion)
                    // 开启设备
                    this.session.hub.startRunning()
                } catch {
                    let controller: UIAlertController = .init(title: "操作提醒", message: error.localizedDescription, preferredStyle: .alert)
                    controller.hub.addAction(title: "关闭") {[weak this] action in
                        (this?.navigationController ?? this)?.dismiss(animated: true, completion: .none)
                    }
                }
            default:
                let message: String = "需要您授权后才可以使用相机功能"
                let controller: UIAlertController = .init(title: "操作提醒", message: message, preferredStyle: .alert)
                controller.hub.addAction(title: "关闭", titleColor: .hex("#000000"), style: .default) {[weak this] action in
                    (this?.navigationController ?? this)?.dismiss(animated: true, completion: .none)
                }
                controller.hub.addAction(title: "授权", titleColor: .hex("#000000"), style: .cancel) {[weak this] action in
                    guard let this = self else { return }
                    guard let url: URL = .init(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) else { return }
                    UIApplication.shared.open(url, options: [:], completionHandler: .none)
                }
                this.present(controller, animated: true, completion: .none)
            }
        }
    }
    
    deinit {
        xprint(#function, #file.hub.lastPathComponent)
    }
}

extension PECameraViewController {
    
    /// 初始化
    private func initialize() {
        // coding here ...
        navigationItem.leftBarButtonItem = flashItem
        view.backgroundColor = .hex("#000000")
        // 布局
        view.addSubview(previewView)
        previewView.snp.makeConstraints {
            $0.left.right.top.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(view.bounds.width * (4.0 / 3.0))
        }
        
        view.addSubview(lineView)
        lineView.snp.makeConstraints {
            $0.left.right.equalTo(view.safeAreaLayoutGuide)
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(view.bounds.width / 0.75)
            $0.height.equalTo(0.0)
        }
        
        view.addSubview(presetView)
        presetView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.top.equalTo(lineView.snp.bottom).offset(10.0)
            $0.height.equalTo(36.0)
        }
        
        view.addSubview(takeBtn)
        takeBtn.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(presetView.snp.bottom).offset(10.0)
            $0.height.width.equalTo(68.0)
        }
        
        view.addSubview(cancelBtn)
        cancelBtn.snp.makeConstraints {
            $0.centerY.equalTo(takeBtn)
            $0.left.equalToSuperview().offset(16.0)
        }
        
        view.addSubview(reverseBtn)
        reverseBtn.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-16.0)
            $0.centerY.equalTo(takeBtn)
            $0.width.height.equalTo(40.0)
        }
        
        view.addSubview(zoomFactorView)
        zoomFactorView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.width.equalTo(122.0)
            $0.height.equalTo(44.0)
            $0.bottom.equalTo(lineView.snp.top).offset(-16.0)
        }
    }
    
    /// itemActionHandler
    /// - Parameter sender: UIBarButtonItem
    @objc private func itemActionHandler(_ sender: UIBarButtonItem) {
        
    }
    
    /// buttonActionHandler
    /// - Parameter sender: UIButton
    @objc private func buttonActionHandler(_ sender: UIButton) {
        switch sender {
        case cancelBtn: // 关闭当前页面
            (navigationController ?? self).dismiss(animated: true, completion: .none)
        case takeBtn: // 拍照
            break
        case reverseBtn where postion == .back: // 切换摄像头
            try? configureWith(mediaType: mediaType, position: .front)
            // reloadZoomFactorWith
            reloadZoomFactorWith(videoInput)
            // transition
            UIView.transition(with: previewView, duration: 0.25, options: [.transitionFlipFromLeft], animations: .none)
        case reverseBtn where postion == .front: // // 切换摄像头
            try? configureWith(mediaType: mediaType, position: .back)
            // reloadZoomFactorWith
            reloadZoomFactorWith(videoInput)
            // transition
            UIView.transition(with: previewView, duration: 0.25, options: [.transitionFlipFromLeft], animations: .none)
            
        default: break
        }
    }
    
    /// reloadZoomFactorWith
    /// - Parameter input: Optional<AVCaptureDeviceInput>
    private func reloadZoomFactorWith(_ input: Optional<AVCaptureDeviceInput>) {
        guard let device: AVCaptureDevice = input?.device else { return }
        zoomFactorView.maxAvailableVideoZoomFactor = device.maxAvailableVideoZoomFactor
        zoomFactorView.minAvailableVideoZoomFactor = device.minAvailableVideoZoomFactor
        zoomFactorView.videoZoomFactor = device.videoZoomFactor
    }
    
    /// configureWith
    /// - Parameters:
    ///   - mediaType: PEMediaType
    ///   - position: AVCaptureDevice.Position
    private func configureWith(mediaType: PEMediaType, position: AVCaptureDevice.Position) throws {
        switch mediaType {
        case .video:
            session.beginConfiguration()
            // 添加视频采集设备
            var obj: AVCaptureDevice.DiscoverySession = .init(deviceTypes: [.builtInDualCamera, .builtInWideAngleCamera], mediaType: .video, position: position)
            if let first = obj.devices.first, videoInput?.device != first {
                if let videoInput = videoInput {
                    // 移除input
                    session.removeInput(videoInput)
                    // 添加input
                    let newInput: AVCaptureDeviceInput = try .init(device: first)
                    if session.canAddInput(newInput) == true {
                        session.addInput(newInput)
                        self.videoInput = newInput
                    } else {
                        session.addInput(videoInput)
                    }
                } else {
                    // 添加input
                    let newInput: AVCaptureDeviceInput = try .init(device: first)
                    if session.canAddInput(newInput) == true {
                        session.addInput(newInput)
                        self.videoInput = newInput
                    }
                }
            }
            // 添加音频采集设备
            if #available(iOS 17.0, *) {
                obj = .init(deviceTypes: [.microphone], mediaType: .audio, position: .unspecified)
            } else {
                obj = .init(deviceTypes: [.builtInMicrophone], mediaType: .audio, position: .unspecified)
            }
            if let first = obj.devices.first, audioInput?.device != first {
                if let audioInput = audioInput {
                    // 移除input
                    session.removeInput(audioInput)
                    // 添加input
                    let newInput: AVCaptureDeviceInput = try .init(device: first)
                    if session.canAddInput(newInput) == true {
                        session.addInput(newInput)
                        self.audioInput = newInput
                    } else {
                        session.addInput(audioInput)
                    }
                } else {
                    // 添加input
                    let newInput: AVCaptureDeviceInput = try .init(device: first)
                    if session.canAddInput(newInput) == true {
                        session.addInput(newInput)
                        self.audioInput = newInput
                    }
                }
            }
            // 移除 photo output
            if let obj = photoOutput {
                session.removeOutput(obj)
            }
            // 添加输出
            if let videoOutput = videoOutput {
                if session.hub.contains(videoOutput) == false, session.canAddOutput(videoOutput) == true {
                    session.addOutput(videoOutput)
                } else {
                    let newOutput: AVCaptureMovieFileOutput = .init()
                    if session.canAddOutput(newOutput) == true {
                        session.addOutput(newOutput)
                        self.videoOutput = newOutput
                    }
                }
            } else {
                let newOutput: AVCaptureMovieFileOutput = .init()
                if session.canAddOutput(newOutput) == true {
                    session.addOutput(newOutput)
                    self.videoOutput = newOutput
                }
            }
            // commitConfiguration
            session.commitConfiguration()
            
        case .photo:
            // beginConfiguration
            session.beginConfiguration()
            // 添加视频采集设备
            let obj: AVCaptureDevice.DiscoverySession = .init(deviceTypes: [.builtInWideAngleCamera, .builtInDualCamera], mediaType: .video, position: position)
            if let first = obj.devices.first, videoInput?.device != first {
                if let videoInput = videoInput {
                    // 移除input
                    session.removeInput(videoInput)
                    // 添加input
                    let newInput: AVCaptureDeviceInput = try .init(device: first)
                    if session.canAddInput(newInput) == true {
                        session.addInput(newInput)
                        self.videoInput = newInput
                    } else {
                        session.addInput(videoInput)
                    }
                } else {
                    // 添加input
                    let newInput: AVCaptureDeviceInput = try .init(device: first)
                    if session.canAddInput(newInput) == true {
                        session.addInput(newInput)
                        self.videoInput = newInput
                    }
                }
            }
            // 移除音频采集
            if let audioInput = audioInput {
                session.removeInput(audioInput)
            }
            // 移除 video output
            if let obj = videoOutput {
                session.removeOutput(obj)
            }
            // 添加输出
            if let photoOutput = photoOutput {
                if session.hub.contains(photoOutput) == false, session.canAddOutput(photoOutput) == true {
                    session.addOutput(photoOutput)
                } else {
                    let newOutput: AVCapturePhotoOutput = .init()
                    if session.canAddOutput(newOutput) == true {
                        session.addOutput(newOutput)
                        self.photoOutput = newOutput
                    }
                }
            } else {
                let newOutput: AVCapturePhotoOutput = .init()
                if session.canAddOutput(newOutput) == true {
                    session.addOutput(newOutput)
                    self.photoOutput = newOutput
                }
            }
            // commitConfiguration
            session.commitConfiguration()
        }
        
    }
    
}

// MARK: - PEPresetViewDelegate
extension PECameraViewController: PEPresetViewDelegate {
    
    /// selectedActionHandler
    /// - Parameters:
    ///   - presetView: PEPresetView
    ///   - sender: PEPresetItem
    internal func presetView(_ presetView: PEPresetView, selectedActionHandler sender: PEPresetItem) {
        switch sender {
        case .video where session.sessionPreset == .photo && session.canSetSessionPreset(.hd1920x1080) == true:
            DispatchQueue.global().async {[weak self] in
                guard let this = self else { return }
                this.session.beginConfiguration()
                this.session.sessionPreset = .hd1920x1080
                this.session.commitConfiguration()
                DispatchQueue.main.async {[weak this] in
                    guard let this = this else { return }
                    this.previewView.snp.updateConstraints {
                        $0.height.equalTo(this.view.bounds.width * (16.0 / 9.0))
                    }
                    this.view.layoutIfNeeded()
                }
            }
            
        case .photo where session.sessionPreset == .hd1920x1080:
            DispatchQueue.global().async {[weak self] in
                guard let this = self else { return }
                this.session.beginConfiguration()
                this.session.sessionPreset = .photo
                this.session.commitConfiguration()
                DispatchQueue.main.async {[weak this] in
                    guard let this = this else { return }
                    this.previewView.snp.updateConstraints {
                        $0.height.equalTo(this.view.bounds.width * (4.0 / 3.0))
                    }
                    this.view.layoutIfNeeded()
                }
            }
            
        default: break
        }
    }
    
}

// MARK: - PEZoomFactorViewDelegate
extension PECameraViewController: PEZoomFactorViewDelegate {
    
    /// selectedActionHandler
    /// - Parameters:
    ///   - zoomFactorView: PEZoomFactorView
    ///   - videoZoomFactor: CGFloat
    internal func zoomFactorView(_ zoomFactorView: PEZoomFactorView, selectedActionHandler videoZoomFactor: CGFloat) {
        guard let device: AVCaptureDevice = videoInput?.device else { return }
        let videoZoomFactor: CGFloat = max(min(device.maxAvailableVideoZoomFactor, videoZoomFactor), device.minAvailableVideoZoomFactor)
        do {
            try device.lockForConfiguration()
            device.videoZoomFactor = videoZoomFactor
            device.unlockForConfiguration()
        } catch {
            xprint(#function, error)
        }
    }
    
}