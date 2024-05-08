// The Swift Programming Language
// https://docs.swift.org/swift-book

import UIKit
import ZLPhotoBrowser
import Hero

/// PhotoEditViewController
public class PhotoEditViewController: UINavigationController {
    
    // MARK: 公开属性
    
    /// SourceType
    internal let sourceType: SourceType
    
    // MARK: 生命周期
    
    /// 构建
    /// - Parameter sourceType: SourceType
    public init(sourceType: SourceType) {
        self.sourceType = sourceType
        let controller: UIViewController
        switch sourceType {
        case .camera:
            controller = PECameraViewController()
        case .photo(let _):
            controller = .init()
        }
        super.init(rootViewController: controller)
        self.overrideUserInterfaceStyle = .dark
        self.modalPresentationStyle = .fullScreen
        self.interactivePopGestureRecognizer?.isEnabled = false
        self.navigationBar.standardAppearance = .init()
        self.navigationBar.standardAppearance.configureWithTransparentBackground()
        self.hero.modalAnimationType = .fade
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
            first.completionHandler(handler)
        }
        // 关联图片编辑
        if let first = viewControllers.first as? PEImageEditViewController {
            first.completionHandler(handler)
        }
    }
    
}
