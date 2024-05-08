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
    // next
    typealias ResultType = PhotoEditViewController.ResultType
    
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
        _item.setTitleTextAttributes([.font: UIFont.pingfang(ofSize: 18.0), .foregroundColor: UIColor.hex("#666666")], for: .disabled)
        _item.setTitleTextAttributes([.font: UIFont.pingfang(ofSize: 18.0), .foregroundColor: UIColor.hex("#FFFFFF")], for: .highlighted)
        _item.isEnabled = false
        return _item
    }()
    
    /// 完成
    private lazy var doneItem: UIBarButtonItem = {
        let _item: UIBarButtonItem = .init(title: "完成", style: .plain, target: self, action: #selector(itemActionHandler(_:)))
        _item.setTitleTextAttributes([.font: UIFont.pingfang(ofSize: 18.0), .foregroundColor: UIColor.hex("#FFFFFF")], for: .normal)
        _item.setTitleTextAttributes([.font: UIFont.pingfang(ofSize: 18.0), .foregroundColor: UIColor.hex("#666666")], for: .disabled)
        _item.setTitleTextAttributes([.font: UIFont.pingfang(ofSize: 18.0), .foregroundColor: UIColor.hex("#FFFFFF")], for: .highlighted)
        _item.isEnabled = false
        return _item
    }()
    
    /// 工具栏
    private lazy var bottomBar: UIToolbar = {
        let _toolbar: UIToolbar = .init(frame: .init(x: 0.0, y: 0.0, width: view.bounds.width, height: 52.0))
        _toolbar.standardAppearance = .init()
        _toolbar.standardAppearance.configureWithOpaqueBackground()
        _toolbar.standardAppearance.backgroundColor = .clear
        _toolbar.backgroundColor = .clear
        _toolbar.items = [backItem, .flexible(), undoItem, .flexible(), doneItem]
        return _toolbar
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
    /// Optional<(ResultType) -> Void>
    private var completionHandler: Optional<(ResultType) -> Void> = .none
    /// UIImage
    private let origiImage: UIImage
    
    // MARK: 生命周期
    
    /// 构建
    /// - Parameters:
    ///   - image: UIImage
    ///   - status: ZLClipStatus
    internal override init(image: UIImage, status: ZLClipStatus) {
        self.origiImage = image
        super.init(image: image, status: status)
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
}

extension PEClipImageViewController {
    
    /// 初始化
    private func initialize() {
        // coding here ...
        view.backgroundColor = .hex("#000000")
        navigationItem.leftBarButtonItem = .disabled
        bottomToolView.backgroundColor = .hex("#141414")
        
        // 布局
        bottomToolView.addSubview(bottomBar)
        bottomBar.snp.makeConstraints {
            $0.left.right.top.equalToSuperview()
            $0.height.equalTo(52.0)
        }
        
        view.addSubview(toolbar)
        toolbar.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.bottom.equalTo(bottomBar.snp.top).offset(-24.0)
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
            doneItem.isEnabled = false
        case rotationItem:
            rotateActionHandler()
        case doneItem:
            let newImage: UIImage = clipImageWith(origiImage)
            completionHandler?(.photo(newImage))
            navigationController?.popViewController(animated: true)
            
        default: break
        }
    }
    
    /// completionHandler
    /// - Parameter handler: Optional<(ResultType) -> Void>
    internal func completionHandler(_ handler: Optional<(ResultType) -> Void>) {
        self.completionHandler = handler
    }
}
