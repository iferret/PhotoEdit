//
//  PEImageEditViewController.swift
//  
//
//  Created by iferret on 2024/5/8.
//

import UIKit
import SnapKit
import Hero
import ZLPhotoBrowser

/// PEImageEditViewController
class PEImageEditViewController: UIViewController {
    // next
    typealias ResultType = PhotoEditViewController.ResultType
    
    // MARK: 私有属性
    
    /// UIImageView
    private lazy var imgView: UIImageView = {
        let _imgView: UIImageView = .init(image: editImage)
        _imgView.contentMode = .scaleAspectFit
        _imgView.hero.id = "preview_layer"
        return _imgView
    }()
    
    /// 取消
    private lazy var cancelItem: UIBarButtonItem = {
        let _item: UIBarButtonItem = .init(title: "取消", style: .plain, target: self, action: #selector(itemActionHandler(_:)))
        _item.setTitleTextAttributes([.font: UIFont.pingfang(ofSize: 18.0), .foregroundColor: UIColor.hex("#FFFFFF")], for: .normal)
        _item.setTitleTextAttributes([.font: UIFont.pingfang(ofSize: 18.0), .foregroundColor: UIColor.hex("#FFFFFF")], for: .highlighted)
        return _item
    }()
    
    /// 完成
    private lazy var doneItem: UIBarButtonItem = {
        let _item: UIBarButtonItem = .init(title: "完成", style: .plain, target: self, action: #selector(itemActionHandler(_:)))
        _item.setTitleTextAttributes([.font: UIFont.pingfang(ofSize: 18.0), .foregroundColor: UIColor.hex("#FFFFFF")], for: .normal)
        _item.setTitleTextAttributes([.font: UIFont.pingfang(ofSize: 18.0), .foregroundColor: UIColor.hex("#FFFFFF")], for: .highlighted)
        _item.setTitleTextAttributes([.font: UIFont.pingfang(ofSize: 18.0), .foregroundColor: UIColor.hex("#666666")], for: .disabled)
        _item.isEnabled = false
        return _item
    }()
    
    /// 底部工具栏
    private lazy var bottomBar: UIToolbar = {
        let _toolbar: UIToolbar = .init(frame: .init(x: 0.0, y: 0.0, width: view.bounds.width, height: 52.0))
        _toolbar.standardAppearance = .init()
        _toolbar.standardAppearance.configureWithOpaqueBackground()
        _toolbar.standardAppearance.backgroundColor = .hex("#141414")
        _toolbar.backgroundColor = .hex("#141414")
        _toolbar.items = [cancelItem, .flexible(), doneItem]
        return _toolbar
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
    
    /// 重置
    private lazy var undoItem: UIBarButtonItem = {
        let _item: UIBarButtonItem = .init(title: "重置", style: .plain, target: self, action: #selector(itemActionHandler(_:)))
        _item.setTitleTextAttributes([.font: UIFont.pingfang(ofSize: 18.0), .foregroundColor: UIColor.hex("#FFFFFF")], for: .normal)
        _item.setTitleTextAttributes([.font: UIFont.pingfang(ofSize: 18.0), .foregroundColor: UIColor.hex("#FFFFFF")], for: .highlighted)
        _item.setTitleTextAttributes([.font: UIFont.pingfang(ofSize: 18.0), .foregroundColor: UIColor.hex("#666666")], for: .disabled)
        _item.isEnabled = false
        return _item
    }()
    
    /// UIImage
    private let originImage: UIImage
    /// UIImage
    private var editImage: UIImage {
        didSet { undoItem.isEnabled = true; doneItem.isEnabled = true }
    }
    /// Optional<(ResultType) -> Void>
    private var completionHandler: Optional<(ResultType) -> Void> = .none
    /// ZLEditImageModel
    private lazy var editModel: ZLEditImageModel = .default(editRect: .init(x: 0.0, y: 0.0, width: editImage.size.width, height: editImage.size.height))
    
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
    
}

extension PEImageEditViewController {
    
    /// 初始化
    private func initialize() {
        // coding here ...
        view.backgroundColor = .hex("#000000")
        navigationItem.leftBarButtonItem = .disabled
        navigationItem.rightBarButtonItem = undoItem
        
        // 布局
        view.addSubview(bottomBar)
        bottomBar.snp.makeConstraints {
            $0.left.right.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(52.0)
        }
        
        view.addSubview(toolbar)
        toolbar.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.bottom.equalTo(bottomBar.snp.top).offset(-24.0)
            $0.height.equalTo(32.0)
        }
        
        view.addSubview(imgView)
        imgView.snp.makeConstraints {
            $0.left.right.top.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(toolbar.snp.top).offset(-28.0)
        }
        
    }
    
    /// itemActionHandler
    /// - Parameter sender: UIBarButtonItem
    @objc private func itemActionHandler(_ sender: UIBarButtonItem) {
        switch sender {
        case cancelItem:
            navigationController?.popViewController(animated: true)
        case doneItem:
            completionHandler?(.photo(editImage))
            navigationController?.popViewController(animated: true)
        case undoItem:
            self.editImage = originImage
            self.imgView.image = originImage
            self.undoItem.isEnabled = false
            self.doneItem.isEnabled = false
            
        case clipItem: // 裁剪
            let controller: PEClipImageViewController = .init(image: editImage, status: editModel.clipStatus)
            controller.completionHandler {[weak self] result in
                guard let this = self else { return }
                switch result {
                case .photo(let newImage):
                    this.editImage = newImage
                    this.imgView.image = newImage
                    this.undoItem.isEnabled = true
                    this.doneItem.isEnabled = true
                default: break
                }
            }
            navigationController?.pushViewController(controller, animated: true)
        case drawItem: // 涂鸦
            break
        default: break
        }
    }
    
    /// completionHandler
    /// - Parameter handler: Optional<(ResultType) -> Void>
    internal func completionHandler(_ handler: Optional<(ResultType) -> Void>) {
        self.completionHandler = handler
    }
    
}
