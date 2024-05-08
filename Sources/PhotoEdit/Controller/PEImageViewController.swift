//
//  PEImageViewController.swift
//
//
//  Created by iferret on 2024/5/7.
//

import UIKit
import SnapKit
import Hero

/// PEImageViewController
class PEImageViewController: UIViewController {
    typealias ResultType = PhotoEditViewController.ResultType
    
    // MARK: 私有属性
    
    /// UIImageView
    private lazy var imgView: UIImageView = {
        let _imgView: UIImageView = .init(image: uiImage)
        _imgView.contentMode = .scaleAspectFit
        _imgView.hero.id = "preview_layer"
        return _imgView
    }()
    
    /// 重拍
    private lazy var redoItem: UIBarButtonItem = {
        let _item: UIBarButtonItem = .init(title: "重拍", style: .plain, target: self, action: #selector(itemActionHandler(_:)))
        _item.setTitleTextAttributes([.font: UIFont.pingfang(ofSize: 18.0), .foregroundColor: UIColor.hex("#FFFFFF")], for: .normal)
        _item.setTitleTextAttributes([.font: UIFont.pingfang(ofSize: 18.0), .foregroundColor: UIColor.hex("#FFFFFF")], for: .highlighted)
        return _item
    }()
    
    /// 编辑
    private lazy var editItem: UIBarButtonItem = {
        let _item: UIBarButtonItem = .init(title: "编辑", style: .plain, target: self, action: #selector(itemActionHandler(_:)))
        _item.setTitleTextAttributes([.font: UIFont.pingfang(ofSize: 18.0), .foregroundColor: UIColor.hex("#FFFFFF")], for: .normal)
        _item.setTitleTextAttributes([.font: UIFont.pingfang(ofSize: 18.0), .foregroundColor: UIColor.hex("#FFFFFF")], for: .highlighted)
        return _item
    }()
    
    /// 使用照片
    private lazy var useItem: UIBarButtonItem = {
        let _item: UIBarButtonItem = .init(title: "使用照片", style: .plain, target: self, action: #selector(itemActionHandler(_:)))
        _item.setTitleTextAttributes([.font: UIFont.pingfang(ofSize: 18.0), .foregroundColor: UIColor.hex("#FFFFFF")], for: .normal)
        _item.setTitleTextAttributes([.font: UIFont.pingfang(ofSize: 18.0), .foregroundColor: UIColor.hex("#FFFFFF")], for: .highlighted)
        return _item
    }()
    
    /// 工具栏
    private lazy var toolbar: UIToolbar = {
        let _toolbar: UIToolbar = .init(frame: .init(x: 0.0, y: 0.0, width: view.bounds.width, height: 52.0))
        _toolbar.standardAppearance = .init()
        _toolbar.standardAppearance.configureWithTransparentBackground()
        _toolbar.backgroundColor = .clear
        _toolbar.items = [redoItem, .flexible(), editItem, .flexible(), useItem]
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
    
    /// UIImage
    private var uiImage: UIImage
    /// Optional<(ResultType) -> Void>
    private var completionHandler: Optional<(ResultType) -> Void> = .none
    
    // MARK: 生命周期
    
    /// 构建
    /// - Parameter uiImage: UIImage
    internal init(uiImage: UIImage) {
        self.uiImage = uiImage
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
        navigationController?.isNavigationBarHidden = false
    }
    
}

extension PEImageViewController {
    
    /// 初始化
    private func initialize() {
        // coding here ...
        view.backgroundColor = .hex("#000000")
        navigationItem.leftBarButtonItem = .disabled
        
        // 布局
        view.addSubview(imgView)
        imgView.snp.makeConstraints {
            $0.left.right.top.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(view.safeAreaLayoutGuide.snp.width).multipliedBy(uiImage.size.height / uiImage.size.width)
        }
        
        view.addSubview(bottomView)
        bottomView.snp.makeConstraints {
            $0.left.right.bottom.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-52.0)
        }
        
        bottomView.addSubview(toolbar)
        toolbar.snp.makeConstraints {
            $0.left.right.top.equalToSuperview()
            $0.height.equalTo(52.0)
        }
    }
    
    /// itemActionHandler
    /// - Parameter item: UIBarButtonItem
    @objc private func itemActionHandler(_ item: UIBarButtonItem) {
        switch item {
        case redoItem:
            navigationController?.popViewController(animated: true)
        case editItem:
            let controller: PEEditImageViewController = .init(uiImage: uiImage)
            controller.completionHandler {[weak self] result in
                guard let this = self else { return }
                switch result {
                case .photo(let uiImage):
                    this.uiImage = uiImage
                    this.imgView.image = uiImage
                default: break
                }
            }
            navigationController?.pushViewController(controller, animated: true)
        case useItem:
            // dismiss
            navigationController?.dismiss(animated: true, completion: .none)
            // next
            completionHandler?(.photo(uiImage))
        default: break
        }
    }
    
    /// completionHandler
    /// - Parameter handler: Optional<(ResultType) -> Void>
    internal func completionHandler(_ handler: Optional<(ResultType) -> Void>) {
        self.completionHandler = handler
    }
}
