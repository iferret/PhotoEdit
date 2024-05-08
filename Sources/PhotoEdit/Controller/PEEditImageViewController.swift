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
    
    /// UIScrollView
    private lazy var scrollView: UIScrollView = {
        let _scrolView: UIScrollView = .init(frame: .zero)
        _scrolView.showsVerticalScrollIndicator = false
        _scrolView.showsHorizontalScrollIndicator = false
        _scrolView.contentInsetAdjustmentBehavior = .never
        _scrolView.minimumZoomScale = 1.0
        _scrolView.maximumZoomScale = 5.0
        _scrolView.delegate = self
        return _scrolView
    }()
    
    /// UIImageView
    private lazy var imgView: UIImageView = {
        let _imgView: UIImageView = .init(image: editImage)
        _imgView.contentMode = .scaleAspectFit
        _imgView.hero.id = "preview_layer"
        // _imgView.backgroundColor = .random
        return _imgView
    }()
    
    /// 取消
    private lazy var cancelItem: UIBarButtonItem = {
        let _item: UIBarButtonItem = .init(title: "取消", style: .plain, target: self, action: #selector(itemActionHandler(_:)))
        _item.setTitleTextAttributes([.font: UIFont.pingfang(ofSize: 18.0), .foregroundColor: UIColor.hex("#FFFFFF")], for: .normal)
        _item.setTitleTextAttributes([.font: UIFont.pingfang(ofSize: 18.0), .foregroundColor: UIColor.hex("#FFFFFF")], for: .highlighted)
        return _item
    }()
        /// 重置
    private lazy var undoItem: UIBarButtonItem = {
        let _item: UIBarButtonItem = .init(title: "重置", style: .plain, target: self, action: #selector(itemActionHandler(_:)))
        _item.setTitleTextAttributes([.font: UIFont.pingfang(ofSize: 18.0), .foregroundColor: UIColor.hex("#FFFFFF")], for: .normal)
        _item.setTitleTextAttributes([.font: UIFont.pingfang(ofSize: 18.0), .foregroundColor: UIColor.hex("#FFFFFF")], for: .highlighted)
        _item.setTitleTextAttributes([.font: UIFont.pingfang(ofSize: 18.0), .foregroundColor: UIColor.hex("#FFFFFF", alpha: 0.4)], for: .disabled)
        _item.isEnabled = false
        return _item
    }()
    
    /// 完成
    private lazy var doneItem: UIBarButtonItem = {
        let _item: UIBarButtonItem = .init(title: "完成", style: .plain, target: self, action: #selector(itemActionHandler(_:)))
        _item.setTitleTextAttributes([.font: UIFont.pingfang(ofSize: 18.0), .foregroundColor: UIColor.hex("#FFFFFF")], for: .normal)
        _item.setTitleTextAttributes([.font: UIFont.pingfang(ofSize: 18.0), .foregroundColor: UIColor.hex("#FFFFFF")], for: .highlighted)
        _item.setTitleTextAttributes([.font: UIFont.pingfang(ofSize: 18.0), .foregroundColor: UIColor.hex("#FFFFFF", alpha: 0.4)], for: .disabled)
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
    
    /// 点击手势
    private lazy var tapGesture: UITapGestureRecognizer = {
        let _tap: UITapGestureRecognizer = .init(target: self, action: #selector(tapActionHandler(_:)))
        _tap.numberOfTapsRequired = 2
        return _tap
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
    
}

extension PEEditImageViewController {
    
    /// 初始化
    private func initialize() {
        // coding here ...
        view.backgroundColor = .hex("#000000")
        navigationItem.leftBarButtonItem = .disabled
        scrollView.addGestureRecognizer(tapGesture)
        // imgView.isUserInteractionEnabled = true
        
        // 布局
        imgView.frame = view.bounds
        scrollView.contentSize = view.bounds.size
        scrollView.addSubview(imgView)
        
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
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
            navigationController?.popViewController(animated: true)
        case doneItem:
            completionHandler?(.photo(editImage))
            navigationController?.popViewController(animated: true)
        case undoItem:
            self.editImage = originImage
            self.imgView.image = originImage
            self.undoItem.isEnabled = false
            // self.doneItem.isEnabled = false
            
        case clipItem: // 裁剪
            let editRect: CGRect = .init(x: 0.0, y: 0.0, width: editImage.size.width, height: editImage.size.height)
            let controller: PEClipImageViewController = .init(image: editImage, status: .default(editRect: editRect))
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
            navigationController?.pushViewController(controller, animated: true)
            
        default: break
        }
    }
    
    /// tapActionHandler
    /// - Parameter sender: UITapGestureRecognizer
    @objc private func tapActionHandler(_ sender: UITapGestureRecognizer) {
        let zoomScale: CGFloat = (1.0 ..< 2.0).contains(scrollView.zoomScale) == true ? 2.0 : 1.0
        let newRect: CGRect = zoomRectWith(zoomScale, center: sender.location(in: .none))
        scrollView.zoom(to: newRect, animated: true)
    }
    
    /// zoomRectWith
    /// - Parameters:
    ///   - scale: CGFloat
    ///   - center: CGPoint
    /// - Returns: CGRect
    private func zoomRectWith(_ scale: CGFloat, center: CGPoint) -> CGRect {
        let newHeight: CGFloat = scrollView.bounds.height / scale
        let newWidth: CGFloat = scrollView.bounds.width / scale
        return .init(x: center.x - newWidth * 0.5, y: center.y - newHeight * 0.5, width: newWidth, height: newHeight)
    }
    
    /// completionHandler
    /// - Parameter handler: Optional<(ResultType) -> Void>
    internal func completionHandler(_ handler: Optional<(ResultType) -> Void>) {
        self.completionHandler = handler
    }
    
}

// MARK: - UIScrollViewDelegate
extension PEEditImageViewController: UIScrollViewDelegate {
    
    /// viewForZooming
    /// - Parameter scrollView: UIScrollView
    /// - Returns: UIView
    internal func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imgView
    }
    
}
