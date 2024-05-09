//
//  PEClipImageViewController.swift
//  
//
//  Created by iferret on 2024/5/8.
//

import UIKit
import ZLPhotoBrowser
import SnapKit
import Hero

/// PEClipImageViewController
class PEClipImageViewController: ZLClipImageViewController {
    // MARK: 私有属性
    
    /// 返回
    private lazy var backItem: UIBarButtonItem = {
        let _item: UIBarButtonItem = .init(title: "返回", style: .plain, target: self, action: #selector(itemActionHandler(_:)))
        _item.setTitleTextAttributes([.font: UIFont.pingfang(ofSize: 18.0), .foregroundColor: UIColor.hex("#FFFFFF")], for: .normal)
        _item.setTitleTextAttributes([.font: UIFont.pingfang(ofSize: 18.0), .foregroundColor: UIColor.hex("#FFFFFF")], for: .highlighted)
        return _item
    }()
    
    /// 还原
    private lazy var undoItem: UIBarButtonItem = {
        let _item: UIBarButtonItem = .init(title: "还原", style: .plain, target: self, action: #selector(itemActionHandler(_:)))
        _item.setTitleTextAttributes([.font: UIFont.pingfang(ofSize: 18.0), .foregroundColor: UIColor.hex("#FFFFFF")], for: .normal)
        _item.setTitleTextAttributes([.font: UIFont.pingfang(ofSize: 18.0), .foregroundColor: UIColor.hex("#FFFFFF", alpha: 0.4)], for: .disabled)
        _item.setTitleTextAttributes([.font: UIFont.pingfang(ofSize: 18.0), .foregroundColor: UIColor.hex("#FFFFFF")], for: .highlighted)
        _item.isEnabled = false
        return _item
    }()
    
    /// 完成
    private lazy var doneItem: UIBarButtonItem = {
        let _item: UIBarButtonItem = .init(title: "完成", style: .plain, target: self, action: #selector(itemActionHandler(_:)))
        _item.setTitleTextAttributes([.font: UIFont.pingfang(ofSize: 18.0), .foregroundColor: UIColor.hex("#FFFFFF")], for: .normal)
        _item.setTitleTextAttributes([.font: UIFont.pingfang(ofSize: 18.0), .foregroundColor: UIColor.hex("#FFFFFF", alpha: 0.4)], for: .disabled)
        _item.setTitleTextAttributes([.font: UIFont.pingfang(ofSize: 18.0), .foregroundColor: UIColor.hex("#FFFFFF")], for: .highlighted)
        // _item.isEnabled = false
        return _item
    }()
    
    /// 工具栏
    private lazy var bottomBar: UIToolbar = {
        let _toolbar: UIToolbar = .init(frame: .init(x: 0.0, y: 0.0, width: view.bounds.width, height: 52.0))
        _toolbar.standardAppearance = .init()
        _toolbar.standardAppearance.configureWithTransparentBackground()
        _toolbar.backgroundColor = .clear
        _toolbar.items = [backItem, .flexible(), undoItem, .flexible(), doneItem]
        return _toolbar
    }()
    
    /// UIView
    private lazy var bottomView: PEGradientView = {
        let _bottomView: PEGradientView = .init(frame: .zero)
        _bottomView.colors = [.hex("#141414", alpha: 0.0), .hex("#141414", alpha: 0.9)]
        _bottomView.backgroundColor = .clear
        _bottomView.startPoint = .init(x: 1.0, y: 0.0)
        _bottomView.endPoint = .init(x: 1.0, y: 1.0)
        return _bottomView
    }()
    
    /// 旋转
    private lazy var rotationItem: UIBarButtonItem = {
        let _img: Optional<UIImage> = .moduleImage("camera_img_rotation")?.withRenderingMode(.alwaysOriginal)
        let _item: UIBarButtonItem = .init(image: _img, style: .plain, target: self, action: #selector(itemActionHandler(_:)))
        return _item
    }()
    
    /// UIToolbar
    private lazy var toolbar: UIToolbar = {
        let _toolbar: UIToolbar = .init(frame: .init(x: 0.0, y: 0.0, width: view.bounds.width, height: 32.0))
        _toolbar.standardAppearance = .init()
        _toolbar.standardAppearance.configureWithTransparentBackground()
        _toolbar.backgroundColor = .clear
        _toolbar.items = [.flexible(), rotationItem, .flexible()]
        return _toolbar
    }()
    
    /// Bool
    private var beforeNavigationBarHidden: Bool = false
    /// Optional<(_ newImage: UIImage) -> Void>
    private var completionHandler: Optional<(_ newImage: UIImage) -> Void> = .none
    /// UIImage
    private let origiImage: UIImage
    
    // MARK: 生命周期
    
    /// 构建
    /// - Parameters:
    ///   - image: UIImage
    internal init(image: UIImage) {
        self.origiImage = image
        super.init(image: image, status: .default(editRect: .init(origin: .zero, size: image.size)))
    }
    
    /// viewDidLoad
    internal override func viewDidLoad() {
        super.viewDidLoad()
        // 初始化
        initialize()
    }
    
    /// viewWillAppear
    /// - Parameter animated: Bool
    internal override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        beforeNavigationBarHidden = navigationController?.isNavigationBarHidden == true
        navigationController?.isNavigationBarHidden = true
    }
    
    /// viewWillDisappear
    /// - Parameter animated: Bool
    internal override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = beforeNavigationBarHidden
    }
    
    /// startEditingActionHandler
    internal override func startEditingActionHandler() {
        super.startEditingActionHandler()
    }
    
    /// endEditingActionHandler
    internal override func endEditingActionHandler() {
        super.endEditingActionHandler()
        undoItem.isEnabled = true
        doneItem.isEnabled = true
    }
    
    deinit {
        xprint(#function, #file.hub.lastPathComponent)
    }
}

extension PEClipImageViewController {
    
    /// 初始化
    private func initialize() {
        // coding here ...
        view.backgroundColor = .hex("#000000")
        navigationItem.leftBarButtonItem = .disabled
        // bottomToolView.isHidden = true
        
        // 布局
        
        view.addSubview(bottomView)
        bottomView.snp.makeConstraints {
            $0.left.right.bottom.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-52.0)
        }
        
        bottomView.addSubview(bottomBar)
        bottomBar.snp.makeConstraints {
            $0.left.right.top.equalToSuperview()
            $0.height.equalTo(52.0)
        }
        
        view.addSubview(toolbar)
        toolbar.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.bottom.equalTo(bottomBar.snp.top).offset(-16.0)
            $0.height.equalTo(32.0)
        }
    }
    
    /// itemActionHandler
    /// - Parameter sender: UIBarButtonItem
    @objc private func itemActionHandler(_ sender: UIBarButtonItem) {
        switch sender {
        case backItem:
            navigationController?.popViewController(animated: true)
        case undoItem:
            undoActionHandler()
            undoItem.isEnabled = false
            // doneItem.isEnabled = false
        case rotationItem:
            rotateActionHandler()
        case doneItem:
            let newImage: UIImage = clipImageWith(origiImage)
            completionHandler?(newImage)
            navigationController?.popViewController(animated: true)
            
        default: break
        }
    }
    
    /// completionHandler
    /// - Parameter handler: Optional<(UIImage) -> Void>
    internal func completionHandler(_ handler: Optional<(UIImage) -> Void>) {
        self.completionHandler = handler
    }
}
