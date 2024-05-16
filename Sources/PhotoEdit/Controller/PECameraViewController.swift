//
//  PECameraViewController.swift
//
//
//  Created by iferret on 2024/5/6.
//

import UIKit
import AVFoundation
import SnapKit
import CoreMotion
import Hero

/// PECameraViewControllerDelegate
protocol PECameraViewControllerDelegate: AnyObject {
    
    /// shouldEditImage
    /// - Parameters:
    ///   - controller: PECameraViewController
    ///   - uiImage: UIImage
    /// - Returns: Bool
    func controller(_ controller: PECameraViewController, shouldEditImage uiImage: UIImage) -> Bool
}

extension PECameraViewControllerDelegate {
    /// shouldEditImage
    internal func controller(_ controller: PECameraViewController, shouldEditImage uiImage: UIImage) -> Bool { true }
}

/// PECameraViewController
class PECameraViewController: UIViewController {
    // next
    typealias ResultType = PhotoEditViewController.ResultType
    
    // MARK: 公开属性
    
    /// Optional<PECameraViewControllerDelegate>
    internal weak var delegate: Optional<PECameraViewControllerDelegate> = .none
    
    // MARK: 私有属性
    
    /// 闪光灯
    private lazy var flashItem: UIBarButtonItem = {
        let _img: Optional<UIImage> = .moduleImage("camera_flash_auto")?.withRenderingMode(.alwaysTemplate)
        let _item: UIBarButtonItem = .init(image: _img, style: .plain, target: self, action: #selector(itemActionHandler(_:)))
        _item.tag = AVCaptureDevice.FlashMode.auto.rawValue
        _item.tintColor = .hex("#FFE27E")
        return _item
    }()
    
    /// 照明
    private lazy var torchItem: UIBarButtonItem = {
        let _img: Optional<UIImage> = .moduleImage("camera_flash_off")?.withRenderingMode(.alwaysTemplate)
        let _item: UIBarButtonItem = .init(image: _img, style: .plain, target: self, action: #selector(itemActionHandler(_:)))
        _item.tag = AVCaptureDevice.TorchMode.off.rawValue
        _item.tintColor = .hex("#FFFFFF")
        return _item
    }()
    
    /// PEVideoPreviewView
    private lazy var previewView: PEVideoPreviewView = {
        let _previewView: PEVideoPreviewView = .init(session: session)
        _previewView.backgroundColor = .hex("#000000")
        _previewView.videoGravity = .resizeAspectFill
        _previewView.hero.id = "preview_layer"
        _previewView.delegate = self
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
        _factorView.backgroundColor = .hex("#000000", alpha: 0.2)
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
    
    /// 拍摄视频按钮
    private lazy var recordBtn: UIButton = {
        let _button: UIButton = .init(type: .custom)
        _button.setBackgroundImage(.moduleImage("camera_record_normal"), for: .normal)
        _button.setBackgroundImage(.moduleImage("camera_record_selected"), for: .selected)
        _button.addTarget(self, action: #selector(buttonActionHandler(_:)), for: .touchUpInside)
        _button.isHidden = true
        return _button
    }()
    
    /// 取消按钮
    private lazy var cancelBtn: UIButton = {
        let _button: UIButton = .init(type: .custom)
        _button.setTitle("取消", for: .normal)
        _button.setTitleColor(.hex("#F9F9F9"), for: .normal)
        _button.titleLabel?.font = PEConfiguration.default().buttonFont
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
    
    /// 时间
    private lazy var timeLabel: UILabel = {
        let _label: UILabel = .init(frame: .zero)
        _label.textColor = .hex("#FFFFFF")
        _label.font = .systemFont(ofSize: 17.0, weight: .medium)
        _label.textAlignment = .center
        return _label
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
    private var videoInput: Optional<AVCaptureDeviceInput> = .none
    /// Optional<AVCaptureDeviceInput>
    private var audioInput: Optional<AVCaptureDeviceInput> = .none
    /// Optional<AVCapturePhotoOutput>
    private var photoOutput: Optional<AVCapturePhotoOutput> = .none
    /// Optional<AVCaptureMovieFileOutput>
    private var videoOutput: Optional<AVCaptureMovieFileOutput> = .none
    /// AVCaptureDevice.Position
    private var postion: AVCaptureDevice.Position { videoInput?.device.position ?? .back }
    /// AVCaptureDevice.FlashMode
    private var flashMode: AVCaptureDevice.FlashMode {
        if flashItem.isEnabled == true {
            return .init(rawValue: flashItem.tag) ?? .auto
        } else {
            return .off
        }
    }
    /// AVCaptureDevice.TorchMode
    private var torchMode: AVCaptureDevice.TorchMode {
        if torchItem.isEnabled == true {
            return .init(rawValue: torchItem.tag) ?? .auto
        } else {
            return .off
        }
    }

    /// Optional<Timer>
    private var timer: Optional<Timer> = .none
    
    /// Bool
    private var isReady: Bool = false
    
    /// Array<UIView>
    private var videoHiddens: Array<UIView> {
        return [presetView, cancelBtn, reverseBtn]
    }
    
    /// Optional<(_ result: ResultType) -> Void>
    private var completionHandler: Optional<(_ result: ResultType) -> Void> = .none
    
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
                    // reloadWith
                    this.reloadWith(this.videoInput)
                    // 开启设备
                    this.session.hub.startRunning()
                    // 标记
                    this.isReady = true
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
    
    /// viewWillAppear
    /// - Parameter animated: Bool
    internal override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
        // start running
        if isReady == true {
            session.hub.startRunning()
        }
    }
   
    deinit {
        timer?.invalidate()
        timer = .none
        xprint(#function, #file.hub.lastPathComponent)
    }
}

extension PECameraViewController {
    
    /// completionHandler
    /// - Parameter handler: Optional<(ResultType) -> Void>
    internal func completionHandler(_ handler: Optional<(ResultType) -> Void>) {
        self.completionHandler = handler
    }
}

extension PECameraViewController {
    
    /// 初始化
    private func initialize() {
        // coding here ...
        navigationItem.leftBarButtonItem = flashItem
        navigationItem.titleView = timeLabel
        view.backgroundColor = .hex("#000000")
        // 布局
        view.addSubview(previewView)
        previewView.snp.makeConstraints {
            if view.safeAreaInsets.bottom == 0.0 {
                $0.top.equalTo(view.safeAreaLayoutGuide)
            } else {
                $0.top.equalTo(view.safeAreaLayoutGuide).offset(50.0)
            }
            $0.left.right.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(view.bounds.width * (4.0 / 3.0))
        }
        
        view.addSubview(lineView)
        lineView.snp.makeConstraints {
            $0.left.right.equalTo(view.safeAreaLayoutGuide)
            if view.safeAreaInsets.bottom == 0.0 {
                $0.top.equalTo(view.safeAreaLayoutGuide).offset(view.bounds.width / 0.75)
            } else {
                $0.top.equalTo(view.safeAreaLayoutGuide).offset(view.bounds.width / 0.75 + 50.0)
            }
            $0.height.equalTo(0.0)
        }
        
        view.addSubview(presetView)
        presetView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.top.equalTo(lineView.snp.bottom).offset(4.0)
            $0.height.equalTo(36.0)
        }
  
        view.addSubview(takeBtn)
        takeBtn.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(presetView.snp.bottom).offset(10.0)
            $0.height.width.equalTo(68.0)
        }
        
        view.addSubview(recordBtn)
        recordBtn.snp.makeConstraints {
            $0.edges.equalTo(takeBtn)
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
            $0.bottom.equalTo(lineView.snp.top).offset(-10.0)
        }
    }
    
    /// itemActionHandler
    /// - Parameter sender: UIBarButtonItem
    @objc private func itemActionHandler(_ sender: UIBarButtonItem) {
        switch sender {
        case flashItem where flashItem.tag == AVCaptureDevice.FlashMode.auto.rawValue:
            flashItem.image = .moduleImage("camera_flash_on")?.withRenderingMode(.alwaysTemplate)
            flashItem.tintColor = .hex("#FFE27E")
            flashItem.tag = AVCaptureDevice.FlashMode.on.rawValue
        case flashItem where flashItem.tag == AVCaptureDevice.FlashMode.on.rawValue:
            flashItem.image = .moduleImage("camera_flash_off")?.withRenderingMode(.alwaysTemplate)
            flashItem.tintColor = .hex("#FFFFFF")
            flashItem.tag = AVCaptureDevice.FlashMode.off.rawValue
        case flashItem where flashItem.tag == AVCaptureDevice.FlashMode.off.rawValue:
            flashItem.image = .moduleImage("camera_flash_auto")?.withRenderingMode(.alwaysTemplate)
            flashItem.tintColor = .hex("#FFE27E")
            flashItem.tag = AVCaptureDevice.FlashMode.auto.rawValue
            
        case torchItem where torchItem.tag == AVCaptureDevice.TorchMode.auto.rawValue:
            torchItem.image = .moduleImage("camera_flash_on")?.withRenderingMode(.alwaysTemplate)
            torchItem.tintColor = .hex("#FFE27E")
            torchItem.tag = AVCaptureDevice.TorchMode.on.rawValue
            guard let videoInput = videoInput else { return }
            reloadWith(videoInput)
        case torchItem where torchItem.tag == AVCaptureDevice.TorchMode.on.rawValue:
            torchItem.image = .moduleImage("camera_flash_off")?.withRenderingMode(.alwaysTemplate)
            torchItem.tintColor = .hex("#FFFFFF")
            torchItem.tag = AVCaptureDevice.TorchMode.off.rawValue
            guard let videoInput = videoInput else { return }
            reloadWith(videoInput)
        case torchItem where torchItem.tag == AVCaptureDevice.TorchMode.off.rawValue:
            torchItem.image = .moduleImage("camera_flash_auto")?.withRenderingMode(.alwaysTemplate)
            torchItem.tintColor = .hex("#FFE27E")
            torchItem.tag = AVCaptureDevice.TorchMode.auto.rawValue
            guard let videoInput = videoInput else { return }
            reloadWith(videoInput)
            
        default: break
            
        }
    }
    
    /// buttonActionHandler
    /// - Parameter sender: UIButton
    @objc private func buttonActionHandler(_ sender: UIButton) {
        switch sender {
        case cancelBtn: // 关闭当前页面
            (navigationController ?? self).dismiss(animated: true, completion: .none)
        case reverseBtn where postion == .back: // 切换摄像头
            try? configureWith(mediaType: mediaType, position: .front)
            // reloadZoomFactorWith
            reloadWith(videoInput)
            // transition
            UIView.transition(with: previewView, duration: 0.25, options: [.transitionFlipFromLeft], animations: .none)
        case reverseBtn where postion == .front: // // 切换摄像头
            try? configureWith(mediaType: mediaType, position: .back)
            // reloadZoomFactorWith
            reloadWith(videoInput)
            // transition
            UIView.transition(with: previewView, duration: 0.25, options: [.transitionFlipFromLeft], animations: .none)
            
        case takeBtn: // 拍照
            guard let input: AVCaptureDeviceInput = videoInput, let output: AVCapturePhotoOutput = photoOutput else { return }
            // 屏蔽用户交互
            (navigationController ?? self).view.isUserInteractionEnabled = false
            // AVCaptureConnection
            if let connection: AVCaptureConnection = output.connection(with: .video) {
                // 修复镜像问题
                if input.device.position == .front, connection.isVideoMirroringSupported == true {
                    connection.isVideoMirrored = true
                }
                // 设置方向
                if #available(iOS 17.0, *) {
                    connection.videoRotationAngle = previewView.videoRotationAngle
                } else {
                    connection.videoOrientation = previewView.videoOrientation
                }
            }
            // AVCapturePhotoSettings
            let settings: AVCapturePhotoSettings = .init(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
            // 设置闪光灯
            settings.flashMode = input.device.hasFlash == true ? flashMode : .off
            // capturePhoto
            session.hub.startRunning(callbackQueue: .main) {[weak self, weak output] in
                guard let this = self, let output = output else { return }
                // capturePhoto
                output.capturePhoto(with: settings, delegate: this)
            }
            
        case recordBtn where recordBtn.isSelected == false: // 记录视频
            guard let input: AVCaptureDeviceInput = videoInput, let output: AVCaptureMovieFileOutput = videoOutput else { return }
            // next
            if let connection: AVCaptureConnection = output.connection(with: .video) {
                connection.videoScaleAndCropFactor = 1.0
                // 设置方向
                if #available(iOS 17.0, *) {
                    connection.videoRotationAngle = previewView.videoRotationAngle
                } else {
                    connection.videoOrientation = previewView.videoOrientation
                }
                // 解决不同系统版本,因为录制视频编码导致安卓端无法播放的问题
                if output.availableVideoCodecTypes.contains(.h264) == true {
                    output.setOutputSettings([AVVideoCodecKey: AVVideoCodecType.h264], for: connection)
                }
                // 解决前置摄像头录制视频时候左右颠倒的问题
                if input.device.position == .front, connection.isVideoMirroringSupported == true {
                    connection.isVideoMirrored = true
                }
            }
            // 设置照明
            do {
                if input.device.hasTorch == true {
                    try input.device.lockForConfiguration()
                    input.device.torchMode = torchMode
                    input.device.unlockForConfiguration()
                }
            } catch {
                xprint("设置照明", error)
            }
            // 开始记录视频
            // next
            UIView.animate(withDuration: 0.25) {
                self.recordBtn.isSelected.toggle()
                self.videoHiddens.forEach { $0.alpha = 0.0 }
                self.zoomFactorView.transform = .init(translationX: 0.0, y: 34.0)
            } completion: {[weak output, weak self] _ in
                guard let this = self, let output = output else { return }
                let uuid: String = UUID().hub.simpleID
                let fileExt: String = "mov"
                let fileURL: URL = FileManager.default.hub.temporaryURL(for: uuid, fileExt: fileExt)
                this.session.hub.startRunning(callbackQueue: .main) {[weak this, weak output] in
                    guard let this = this, let output = output, output.isRecording == false else { return }
                    // startRecording
                    output.startRecording(to: fileURL, recordingDelegate: this)
                }
            }
            
        case recordBtn where recordBtn.isSelected == true: // 停止记录
            guard let output: AVCaptureMovieFileOutput = videoOutput else { return }
            // next
            UIView.animate(withDuration: 0.25) {
                self.recordBtn.isSelected.toggle()
                self.videoHiddens.forEach { $0.alpha = 1.0 }
                self.zoomFactorView.transform = .identity
            } completion: {[weak output] _ in
                guard let output = output else { return }
                if output.isRecording == true {
                    // stopRecording
                    output.stopRecording()
                }
            }
            
        default: break
        }
    }
    
    /// reloadWith
    /// - Parameter flashMode: AVCaptureDevice.FlashMode
    private func reloadWith(flashMode: AVCaptureDevice.FlashMode) {
        switch (flashItem.isEnabled == true, flashMode) {
        case (true, .auto):
            flashItem.image = .moduleImage("camera_flash_auto")?.withRenderingMode(.alwaysTemplate)
            flashItem.tintColor = .hex("#FFE27E")
        case (true, .on):
            flashItem.image = .moduleImage("camera_flash_on")?.withRenderingMode(.alwaysTemplate)
            flashItem.tintColor = .hex("#FFE27E")
        case (true, .off):
            flashItem.image = .moduleImage("camera_flash_off")?.withRenderingMode(.alwaysTemplate)
            flashItem.tintColor = .hex("#FFFFFF")
        case (false, _):
            flashItem.image = .moduleImage("camera_flash_off")?.withRenderingMode(.alwaysTemplate)
            flashItem.tintColor = .hex("#FFFFFF")
        }
    }
    
    /// reloadWith
    /// - Parameter torchMode: AVCaptureDevice.TorchMode
    private func reloadWith(torchMode: AVCaptureDevice.TorchMode) {
        switch (torchItem.isEnabled == true, torchMode) {
        case (true, .auto):
            torchItem.image = .moduleImage("camera_flash_auto")?.withRenderingMode(.alwaysTemplate)
            torchItem.tintColor = .hex("#FFE27E")
        case (true, .on):
            torchItem.image = .moduleImage("camera_flash_on")?.withRenderingMode(.alwaysTemplate)
            torchItem.tintColor = .hex("#FFE27E")
        case (true, .off):
            torchItem.image = .moduleImage("camera_flash_off")?.withRenderingMode(.alwaysTemplate)
            torchItem.tintColor = .hex("#FFFFFF")
        case (false, _):
            torchItem.image = .moduleImage("camera_flash_off")?.withRenderingMode(.alwaysTemplate)
            torchItem.tintColor = .hex("#FFFFFF")
        }
    }
    
    /// reloadWith
    /// - Parameter flashMode: Optional<AVCaptureDeviceInput>
    private func reloadWith(_ videoInput: Optional<AVCaptureDeviceInput>) {
        guard let videoInput = videoInput else { return }
        do {
            // videoZoomFactor
            zoomFactorView.maxAvailableVideoZoomFactor = videoInput.device.maxAvailableVideoZoomFactor
            zoomFactorView.minAvailableVideoZoomFactor = videoInput.device.minAvailableVideoZoomFactor
            zoomFactorView.videoZoomFactor = videoInput.device.videoZoomFactor
            // next
            switch mediaType {
            case .photo where videoInput.device.hasFlash == true:
                navigationItem.leftBarButtonItem = flashItem
                navigationItem.leftBarButtonItem?.isEnabled = true
            case .photo:
                navigationItem.leftBarButtonItem = flashItem
                navigationItem.leftBarButtonItem?.isEnabled = false
            case .video where videoInput.device.hasTorch == true:
                navigationItem.leftBarButtonItem = torchItem
                navigationItem.leftBarButtonItem?.isEnabled = true
                try videoInput.device.lockForConfiguration()
                videoInput.device.torchMode = torchMode
                videoInput.device.unlockForConfiguration()
            case .video:
                navigationItem.leftBarButtonItem = torchItem
                navigationItem.leftBarButtonItem?.isEnabled = false
                
            default: break
            }
        } catch {
            xprint(#function, error)
        }
    }
    
    /// configureWith
    /// - Parameters:
    ///   - mediaType: PEMediaType
    ///   - position: AVCaptureDevice.Position
    private func configureWith(mediaType: PEMediaType, position: AVCaptureDevice.Position) throws {
        switch mediaType {
        case .video:
            session.beginConfiguration()
            if session.canSetSessionPreset(.hd1920x1080) == true {
                session.sessionPreset = .hd1920x1080
            }
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
            if session.canSetSessionPreset(.photo) == true {
                session.sessionPreset = .photo
            }
            // 添加视频采集设备
            let obj: AVCaptureDevice.DiscoverySession = .init(deviceTypes: [.builtInDualCamera, .builtInWideAngleCamera], mediaType: .video, position: position)
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

// MARK: - PEVideoPreviewViewDelegate
extension PECameraViewController: PEVideoPreviewViewDelegate {
    
    /// focusActionHandler
    /// - Parameters:
    ///   - previewView: PEVideoPreviewView
    ///   - location: CGPoint
    internal func previewView(_ previewView: PEVideoPreviewView, focusActionHandler location: CGPoint) {
        guard let videoInput = videoInput else { return }
        do {
            try videoInput.device.lockForConfiguration()
            if videoInput.device.isFocusModeSupported(.autoFocus) == true {
                videoInput.device.focusMode = .autoFocus
            }
            if videoInput.device.isFocusPointOfInterestSupported == true {
                videoInput.device.focusPointOfInterest = location
            }
            if videoInput.device.isExposureModeSupported(.autoExpose) == true  {
                videoInput.device.exposureMode = .autoExpose
            }
            if videoInput.device.isExposurePointOfInterestSupported == true  {
                videoInput.device.exposurePointOfInterest = location
            }
            videoInput.device.unlockForConfiguration()
        } catch {
            xprint("相机聚焦设置失败 =>", error.localizedDescription)
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
            (navigationController ?? self).view.isUserInteractionEnabled = false
            DispatchQueue.global().async {[weak self] in
                guard let this = self else { return }
                try? this.configureWith(mediaType: .video, position: this.postion)
                DispatchQueue.main.async {[weak this] in
                    guard let this = this else { return }
                    this.mediaType = .video
                    this.reloadWith(this.videoInput)
                    this.reloadWith(torchMode: .off)
                    this.previewView.snp.updateConstraints {
                        if this.view.safeAreaInsets.bottom == 0.0 {
                            $0.top.equalTo(this.view.safeAreaLayoutGuide)
                        } else {
                            $0.top.equalTo(this.view.safeAreaLayoutGuide).offset(16.0)
                        }
                        $0.height.equalTo(this.view.bounds.width * (16.0 / 9.0))
                    }
                    this.recordBtn.isHidden = false
                    this.takeBtn.isHidden = true
                    this.view.layoutIfNeeded()
                    (this.navigationController ?? this).view.isUserInteractionEnabled = true
                }
            }
            
        case .photo where session.sessionPreset == .hd1920x1080:
            (navigationController ?? self).view.isUserInteractionEnabled = false
            DispatchQueue.global().async {[weak self] in
                guard let this = self else { return }
                try? this.configureWith(mediaType: .photo, position: this.postion)
                DispatchQueue.main.async {[weak this] in
                    guard let this = this else { return }
                    this.mediaType = .photo
                    this.reloadWith(this.videoInput)
                    this.reloadWith(flashMode: .auto)
                    this.previewView.snp.updateConstraints { 
                        if this.view.safeAreaInsets.bottom == 0.0 {
                            $0.top.equalTo(this.view.safeAreaLayoutGuide)
                        } else {
                            $0.top.equalTo(this.view.safeAreaLayoutGuide).offset(50.0)
                        }
                        $0.height.equalTo(this.view.bounds.width * (4.0 / 3.0))
                    }
                    this.recordBtn.isHidden = true
                    this.takeBtn.isHidden = false
                    this.view.layoutIfNeeded()
                    (this.navigationController ?? this).view.isUserInteractionEnabled = true
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

// MARK: - AVCapturePhotoCaptureDelegate
extension PECameraViewController: AVCapturePhotoCaptureDelegate {
    
    /// willBeginCaptureFor
    /// - Parameters:
    ///   - output: AVCapturePhotoOutput
    ///   - resolvedSettings: AVCaptureResolvedPhotoSettings
    internal func photoOutput(_ output: AVCapturePhotoOutput, willBeginCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        xprint(#function)
    }
    
    /// willCapturePhotoFor
    /// - Parameters:
    ///   - output: AVCapturePhotoOutput
    ///   - resolvedSettings: AVCaptureResolvedPhotoSettings
    internal func photoOutput(_ output: AVCapturePhotoOutput, willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        xprint(#function)
        previewView.hood()
    }
    
    /// didCapturePhotoFor
    /// - Parameters:
    ///   - output: AVCapturePhotoOutput
    ///   - resolvedSettings: AVCaptureResolvedPhotoSettings
    internal func photoOutput(_ output: AVCapturePhotoOutput, didCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        xprint(#function)
    }
    
    /// didFinishProcessingPhoto
    /// - Parameters:
    ///   - output: AVCapturePhotoOutput
    ///   - photo: AVCapturePhoto
    ///   - error: Error
    internal func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: (any Error)?) {
        xprint(#function, error)
        // next
        if let error = error { // 发生了错误
            DispatchQueue.execute(inQueue: .main) {[weak self, weak output] in
                guard let this = self, let output = output else { return }
                this.photoOutput(output, didFinishProcessingPhoto: .failure(error))
            }
        } else if let newData: Data = photo.fileDataRepresentation(), let uiImage: UIImage = .init(data: newData) { // 提取图片
            // 修复图片
            let newImage: UIImage = uiImage.hub.fixOrientation()
            // next
            DispatchQueue.execute(inQueue: .main) {[weak self, weak output] in
                guard let this = self, let output = output else { return }
                this.photoOutput(output, didFinishProcessingPhoto: .success(newImage))
            }
        } else {
            let error: PEError = .custom("图片生成失败")
            DispatchQueue.execute(inQueue: .main) {[weak self, weak output] in
                guard let this = self, let output = output else { return }
                this.photoOutput(output, didFinishProcessingPhoto: .failure(error))
            }
        }
    }
    
    /// didFinishProcessingPhoto
    /// - Parameters:
    ///   - output: AVCapturePhotoOutput
    ///   - result: Result<UIImage, Error>
    private func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto result: Result<UIImage, Error>) {
        // 开启交互
        (navigationController ?? self).view.isUserInteractionEnabled = true
        // next
        switch result {
        case .success(let newImage):
            session.hub.stopRunning()
            // 进入预览页
            let controller: PEImageViewController = .init(uiImage: newImage)
            controller.delegate = self
            controller.completionHandler(completionHandler)
            navigationController?.pushViewController(controller, animated: true)
            self.previewView.unhood()
            
        case .failure(let error):
            let controller: UIAlertController = .init(title: "操作提醒", message: error.localizedDescription, preferredStyle: .alert)
            controller.hub.addAction(title: "关闭") {[unowned self] action in
                self.session.hub.startRunning()
                self.previewView.unhood()
            }
            self.present(controller, animated: true, completion: .none)
        }
    }
}

// MARK: - AVCaptureFileOutputRecordingDelegate
extension PECameraViewController: AVCaptureFileOutputRecordingDelegate {
    
    /// didStartRecordingTo
    /// - Parameters:
    ///   - output: AVCaptureFileOutput
    ///   - fileURL: URL
    ///   - connections: [AVCaptureConnection]
    internal func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        DispatchQueue.execute(inQueue: .main) {[weak self] in
            self?.handleFileOutput(output, didStartRecordingTo: fileURL, from: connections)
        }
    }
    
    /// didFinishRecordingTo
    /// - Parameters:
    ///   - output: AVCaptureFileOutput
    ///   - outputFileURL: URL
    ///   - connections: [AVCaptureConnection]
    ///   - error: Error
    internal func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: (any Error)?) {
        DispatchQueue.execute(inQueue: .main) {[weak self] in
            self?.handleFileOutput(output, didFinishRecordingTo: outputFileURL, from: connections, error: error)
        }
    }
    
    /// didStartRecordingTo
    /// - Parameters:
    ///   - output: AVCaptureFileOutput
    ///   - fileURL: URL
    ///   - connections: [AVCaptureConnection]
    private func handleFileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        xprint(#function)
        timer?.invalidate()
        timer = .scheduledTimer(withTimeInterval: 0.5, repeats: true, block: {[weak self, weak output] _ in
            guard let this = self, let output else { return }
            this.timeLabel.text = output.recordedDuration.hub.readable
            this.timeLabel.sizeToFit()
            this.timeLabel.isHidden = false
        })
    }
    
    /// didFinishRecordingTo
    /// - Parameters:
    ///   - output: AVCaptureFileOutput
    ///   - outputFileURL: URL
    ///   - connections: [AVCaptureConnection]
    ///   - error: Error
    private func handleFileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: (any Error)?) {
        xprint(#function)
        timer?.invalidate()
        timer = .none
        if let error = error {
            let controller: UIAlertController = .init(title: "操作提醒", message: error.localizedDescription, preferredStyle: .alert)
            controller.hub.addAction(title: "关闭")
            self.present(controller, animated: true, completion: .none)
            session.hub.startRunning()
            timeLabel.isHidden = true
            timeLabel.text = .none
            // clearup
            try? FileManager.default.removeItem(at: outputFileURL)
        } else {
            // next
            let controller: PEVideoViewController = .init(fileURL: outputFileURL)
            controller.completionHandler(completionHandler)
            navigationController?.pushViewController(controller, animated: true)
            // next
            session.hub.stopRunning()
            timeLabel.isHidden = true
            timeLabel.text = .none
        }
    }
}

// MARK: - PEImageViewControllerDelegate
extension PECameraViewController: PEImageViewControllerDelegate {
    
    /// shouldEditImage
    /// - Parameters:
    ///   - controller: PEImageViewController
    ///   - uiImage: UIImage
    /// - Returns: Bool
    internal func controller(_ controller: PEImageViewController, shouldEditImage uiImage: UIImage) -> Bool {
        return delegate?.controller(self, shouldEditImage: uiImage) ?? true
    }
}
