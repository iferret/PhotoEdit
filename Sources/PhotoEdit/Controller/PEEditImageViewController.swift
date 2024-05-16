//
//  PEEditImageViewController.swift
//
//
//  Created by iferret on 2024/5/8.
//

import UIKit
import SnapKit
import Hero
import ZLPhotoBrowser

/// PEEditImageViewController
class PEEditImageViewController: UIViewController {
    // next
    typealias ResultType = PhotoEditViewController.ResultType

    // MARK: 私有属性
    
    /// UIImageView
    private lazy var imgView: UIImageView = {
        let _imgView: UIImageView = .init(image: editImage)
        _imgView.contentMode = .scaleAspectFit
        _imgView.contentMode = .scaleAspectFit
        _imgView.sizeToFit()
        //_imgView.hero.id = "preview_layer"
        // _imgView.backgroundColor = .random
        return _imgView
    }()
    
    /// 取消
    private lazy var cancelItem: UIBarButtonItem = {
        let _item: UIBarButtonItem = .init(title: "取消", style: .plain, target: self, action: #selector(itemActionHandler(_:)))
        _item.setTitleTextAttributes([.font: PEConfiguration.default().barItemFont, .foregroundColor: UIColor.hex("#FFFFFF")], for: .normal)
        _item.setTitleTextAttributes([.font: PEConfiguration.default().barItemFont, .foregroundColor: UIColor.hex("#FFFFFF")], for: .highlighted)
        return _item
    }()
        /// 重置
    private lazy var undoItem: UIBarButtonItem = {
        let _item: UIBarButtonItem = .init(title: "重置", style: .plain, target: self, action: #selector(itemActionHandler(_:)))
        _item.setTitleTextAttributes([.font: PEConfiguration.default().barItemFont, .foregroundColor: UIColor.hex("#FFFFFF")], for: .normal)
        _item.setTitleTextAttributes([.font: PEConfiguration.default().barItemFont, .foregroundColor: UIColor.hex("#FFFFFF")], for: .highlighted)
        _item.setTitleTextAttributes([.font: PEConfiguration.default().barItemFont, .foregroundColor: UIColor.hex("#FFFFFF", alpha: 0.4)], for: .disabled)
        _item.isEnabled = false
        return _item
    }()
    
    /// 完成
    private lazy var doneItem: UIBarButtonItem = {
        let _item: UIBarButtonItem = .init(title: "完成", style: .plain, target: self, action: #selector(itemActionHandler(_:)))
        _item.setTitleTextAttributes([.font: PEConfiguration.default().barItemFont, .foregroundColor: UIColor.hex("#FFFFFF")], for: .normal)
        _item.setTitleTextAttributes([.font: PEConfiguration.default().barItemFont, .foregroundColor: UIColor.hex("#FFFFFF")], for: .highlighted)
        _item.setTitleTextAttributes([.font: PEConfiguration.default().barItemFont, .foregroundColor: UIColor.hex("#FFFFFF", alpha: 0.4)], for: .disabled)
        // _item.isEnabled = false
        return _item
    }()
    
    /// 底部工具栏
    private lazy var bottomBar: UIToolbar = {
        let _toolbar: UIToolbar = .init(frame: .init(x: 0.0, y: 0.0, width: view.bounds.width, height: 52.0))
        _toolbar.standardAppearance = .init()
        _toolbar.standardAppearance.configureWithOpaqueBackground()
        _toolbar.standardAppearance.backgroundColor = .clear
        _toolbar.standardAppearance.shadowColor = .clear
        _toolbar.backgroundColor = .clear
        _toolbar.items = [cancelItem, .flexible(), undoItem, .flexible(), doneItem]
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
    
    /// 裁剪
    private lazy var clipItem: UIBarButtonItem = {
        let _img: Optional<UIImage> = .moduleImage("camera_img_clip")?.withRenderingMode(.alwaysOriginal)
        let _item: UIBarButtonItem = .init(image: _img, style: .plain, target: self, action: #selector(itemActionHandler(_:)))
        return _item
    }()
    
    /// 涂鸦
    private lazy var drawItem: UIBarButtonItem = {
        let _img: Optional<UIImage> = .moduleImage("camera_img_draw")?.withRenderingMode(.alwaysOriginal)
        let _item: UIBarButtonItem = .init(image: _img, style: .plain, target: self, action: #selector(itemActionHandler(_:)))
        return _item
    }()
    
    /// UIToolbar
    private lazy var toolbar: UIToolbar = {
        let _toolbar: UIToolbar = .init(frame: .init(x: 0.0, y: 0.0, width: view.bounds.width, height: 32.0))
        _toolbar.standardAppearance = .init()
        _toolbar.standardAppearance.configureWithTransparentBackground()
        _toolbar.backgroundColor = .clear
        _toolbar.items = [.flexible(), clipItem, .fixed(18.0), drawItem, .flexible()]
        return _toolbar
    }()
    
    /// UIImage
    private let originImage: UIImage
    /// UIImage
    private var editImage: UIImage {
        didSet { undoItem.isEnabled = true }
    }
    /// Optional<(ResultType) -> Void>
    private var completionHandler: Optional<(ResultType) -> Void> = .none
    
    // MARK: 生命周期
    
    /// 构建
    /// - Parameter uiImage: UIImage
    internal init(uiImage: UIImage) {
        self.originImage = uiImage
        self.editImage = uiImage
        super.init(nibName: .none, bundle: .none)
    }
    
    /// 构建
    /// - Parameter coder: NSCoder
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// viewDidLoad
    internal override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // 初始化
        initialize()
    }
    
    /// viewWillAppear
    /// - Parameter animated: Bool
    internal override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    deinit {
        xprint(#function, #file.hub.lastPathComponent)
    }
    
}

extension PEEditImageViewController {
    
    /// 初始化
    private func initialize() {
        // coding here ...
        view.backgroundColor = .hex("#000000")
        navigationItem.leftBarButtonItem = .disabled
        // imgView.isUserInteractionEnabled = true
        
        // 布局
        view.addSubview(imgView)
        imgView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.edges.lessThanOrEqualToSuperview()
        }
        
        view.addSubview(bottomView)
        bottomView.snp.makeConstraints {
            $0.left.right.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalToSuperview()
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
        case cancelItem:
            guard let navi = navigationController else { return }
            if navi.viewControllers.count > 1 {
                navigationController?.popViewController(animated: true)
            } else {
                navigationController?.dismiss(animated: true, completion: .none)
            }
        case doneItem:
            guard let navi = navigationController else { return }
            if navi.viewControllers.count > 1 {
                navigationController?.popViewController(animated: true)
                completionHandler?(.photo(editImage))
            } else {
                let completionHandler = completionHandler
                let editImage = editImage
                if PEConfiguration.default().closeWhenFinished == true {
                    navigationController?.dismiss(animated: true) {
                        completionHandler?(.photo(editImage))
                    }
                } else {
                    completionHandler?(.photo(editImage))
                }
            }
        case undoItem:
            self.editImage = originImage
            self.imgView.image = originImage
            self.undoItem.isEnabled = false
            // self.doneItem.isEnabled = false
            
        case clipItem: // 裁剪
            let controller: PEClipImageViewController = .init(image: editImage)
            controller.completionHandler {[weak self] newImage in
                guard let this = self else { return }
                this.editImage = newImage
                this.imgView.image = newImage
                this.undoItem.isEnabled = true
                // this.doneItem.isEnabled = true
            }
            navigationController?.pushViewController(controller, animated: true)
     
        case drawItem: // 涂鸦
            let controller: PEDrawImageViewController = .init(uiImage: editImage, drawType: .mosaic)
            controller.completionHandler {[weak self] newImage in
                guard let this = self else { return }
                this.editImage = newImage
                this.imgView.image = newImage
                this.undoItem.isEnabled = true
            }
            navigationController?.pushViewController(controller, animated: true)
            
        default: break
        }
    }
  
    /// completionHandler
    /// - Parameter handler: Optional<(ResultType) -> Void>
    internal func completionHandler(_ handler: Optional<(ResultType) -> Void>) {
        self.completionHandler = handler
    }
    
}
