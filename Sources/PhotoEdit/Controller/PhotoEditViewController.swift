// The Swift Programming Language
// https://docs.swift.org/swift-book

import UIKit
import ZLPhotoBrowser
import Hero

/// PhotoEditViewControllerDelegate
public protocol PhotoEditViewControllerDelegate : AnyObject  {
    
    /// shouldEditImage
    /// - Parameters:
    ///   - cameraViewController: PhotoEditViewController
    ///   - uiImage: UIImage
    /// - Returns: Bool
    func controller(_ controller: PhotoEditViewController, shouldEditImage uiImage: UIImage) -> Bool
}

extension PhotoEditViewControllerDelegate {
    /// shouldEditImage
    func controller(_ controller: PhotoEditViewController, shouldEditImage uiImage: UIImage) -> Bool { true }
}


/// PhotoEditViewController
public class PhotoEditViewController: UINavigationController {
    
    // MARK: 公开属性
    
    /// Bool
    public override var shouldAutorotate: Bool { false }
    /// UIInterfaceOrientationMask
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }
    /// UIInterfaceOrientation
    public override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation { .portrait }
    /// SourceType
    public let sourceType: SourceType
    /// 保存到相册
    public var saveToAlbum: Bool = true
    /// 自动关闭
    public var closeWhenFinished: Bool = true {
        didSet { closeWhenFinishedWith(closeWhenFinished) }
    }
    /// Optional<PhotoEditViewControllerDelegate>
    public weak var photoEditDelegate: Optional<PhotoEditViewControllerDelegate> = .none 
    /// maxImageBytes
    public var maxImageBytes: Int = 1024 * 1024 * 2 
    // MARK: 生命周期
    
    /// 构建
    /// - Parameter sourceType: SourceType
    public init(sourceType: SourceType) {
        self.sourceType = sourceType
        let controller: UIViewController
        switch sourceType {
        case .camera:
            controller = PECameraViewController()
            (controller as! PECameraViewController).closeWhenFinished = closeWhenFinished
            (controller as! PECameraViewController).maxImageBytes = maxImageBytes
            super.init(rootViewController: controller)
            (controller as! PECameraViewController).delegate = self
        case .photo(let uiImage):
            controller = PEEditImageViewController(uiImage: uiImage)
            (controller as! PEEditImageViewController).closeWhenFinished = closeWhenFinished
            (controller as! PEEditImageViewController).maxImageBytes = maxImageBytes
            super.init(rootViewController: controller)
        }
        // next
        self.overrideUserInterfaceStyle = .dark
        self.modalPresentationStyle = .fullScreen
        self.interactivePopGestureRecognizer?.isEnabled = false
        self.navigationBar.standardAppearance = .transparent()
        self.navigationBar.scrollEdgeAppearance = .transparent()
        self.navigationBar.compactAppearance = .transparent()
        if #available(iOS 15.0, *) {
            self.navigationBar.compactScrollEdgeAppearance = .transparent()
        } else {
            // Fallback on earlier versions
        }
        self.hero.modalAnimationType = .selectBy(presenting: .cover(direction: .up), dismissing: .uncover(direction: .down))
        self.hero.navigationAnimationType = .fade
        self.hero.isEnabled = true
    }
    
    /// 构建
    /// - Parameter aDecoder: NSCoder
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// viewDidLoad
    public override func viewDidLoad() {
        super.viewDidLoad()
        // 初始化
        initialize()
    }
    
    deinit {
        xprint(#function, #file.hub.lastPathComponent)
    }
}

extension PhotoEditViewController {
    
    /// 初始化
    private func initialize() {
        // coding here ...
        view.backgroundColor = .hex("#000000")
    }
    
    /// completionHandler
    /// - Parameter handler: ResultType
    public func completionHandler(_ handler: Optional<(_ result: ResultType) -> Void>) {
        // 关联相机
        if let first = viewControllers.first as? PECameraViewController {
            first.completionHandler {[weak self] result in
                guard let this = self else { return }
                // 保存到相册
                if this.saveToAlbum == true {
                    this.saveToAlbumWith(result)
                }
                // next
                handler?(result)
            }
        }
        // 关联图片编辑
        if let first = viewControllers.first as? PEEditImageViewController {
            first.completionHandler {[weak self] result in
                guard let this = self else { return }
                // 保存到相册
                if this.saveToAlbum == true {
                    this.saveToAlbumWith(result)
                }
                // next
                handler?(result)
            }
        }
    }
    
    /// saveToAlbumWith
    /// - Parameter result: ResultType
    private func saveToAlbumWith(_ result: ResultType) {
        switch result {
        case .photo(let uiImage):
            UIImageWriteToSavedPhotosAlbum(uiImage, .none, .none, .none)
        case .video(let fileURL):
            UISaveVideoAtPathToSavedPhotosAlbum(fileURL.path, .none, .none, .none)
        }
    }
    
    /// closeWhenFinishedWith
    /// - Parameter closeWhenFinished: Bool
    private func closeWhenFinishedWith(_ closeWhenFinished: Bool) {
        viewControllers.forEach { controller in
            if let controller = controller as? PEEditImageViewController {
                controller.closeWhenFinished = closeWhenFinished
            } else if let controller = controller as? PEImageViewController {
                controller.closeWhenFinished = closeWhenFinished
            } else if let controller = controller as? PEVideoViewController {
                controller.closeWhenFinished = closeWhenFinished
            }
        }
    }
    
}

// MARK: - PECameraViewControllerDelegate
extension PhotoEditViewController: PECameraViewControllerDelegate {
    
    /// shouldEditImage
    /// - Parameters:
    ///   - controller: PECameraViewController
    ///   - uiImage: UIImage
    /// - Returns: Bool
    internal func controller(_ controller: PECameraViewController, shouldEditImage uiImage: UIImage) -> Bool {
        return photoEditDelegate?.controller(self, shouldEditImage: uiImage) ?? true
    }
}
