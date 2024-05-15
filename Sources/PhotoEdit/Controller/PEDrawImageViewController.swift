//
//  PEDrawImageViewController.swift
//  
//
//  Created by iferret on 2024/5/8.
//

import UIKit
import ZLPhotoBrowser
import SnapKit

/// ZLEditImageViewController
class PEDrawImageViewController: ZLEditImageViewController {

    // MARK: 私有属性
    
    /// UIView
    private lazy var bottomView: PEGradientView = {
        let _bottomView: PEGradientView = .init(frame: .zero)
        _bottomView.colors = [.hex("#141414", alpha: 0.0), .hex("#141414", alpha: 0.9)]
        _bottomView.backgroundColor = .clear
        _bottomView.startPoint = .init(x: 1.0, y: 0.0)
        _bottomView.endPoint = .init(x: 1.0, y: 1.0)
        return _bottomView
    }()
    
    /// 底部工具栏
    private lazy var bottomBar: UIToolbar = {
        let _toolbar: UIToolbar = .init(frame: .init(x: 0.0, y: 0.0, width: view.bounds.width, height: 52.0))
        _toolbar.standardAppearance = .init()
        _toolbar.standardAppearance.configureWithOpaqueBackground()
        _toolbar.standardAppearance.backgroundColor = .clear
        _toolbar.standardAppearance.shadowColor = .clear
        _toolbar.backgroundColor = .clear
        _toolbar.items = [backItem, .flexible(), undoItem, .flexible(), confirmItem]
        return _toolbar
    }()
    
    /// 返回
    private lazy var backItem: UIBarButtonItem = {
        let _item: UIBarButtonItem = .init(title: "返回", style: .plain, target: self, action: #selector(itemActionHandler(_:)))
        _item.setTitleTextAttributes([.font: PEConfiguration.default().barItemFont, .foregroundColor: UIColor.hex("#FFFFFF")], for: .normal)
        _item.setTitleTextAttributes([.font: PEConfiguration.default().barItemFont, .foregroundColor: UIColor.hex("#FFFFFF")], for: .highlighted)
        return _item
    }()
    
    /// 还原
    private lazy var undoItem: UIBarButtonItem = {
        let _item: UIBarButtonItem = .init(title: "还原", style: .plain, target: self, action: #selector(itemActionHandler(_:)))
        _item.setTitleTextAttributes([.font: PEConfiguration.default().barItemFont, .foregroundColor: UIColor.hex("#FFFFFF")], for: .normal)
        _item.setTitleTextAttributes([.font: PEConfiguration.default().barItemFont, .foregroundColor: UIColor.hex("#FFFFFF", alpha: 0.4)], for: .disabled)
        _item.setTitleTextAttributes([.font: PEConfiguration.default().barItemFont, .foregroundColor: UIColor.hex("#FFFFFF")], for: .highlighted)
        _item.isEnabled = false
        return _item
    }()
    
    /// 确认
    private lazy var confirmItem: UIBarButtonItem = {
        let _item: UIBarButtonItem = .init(title: "确认", style: .plain, target: self, action: #selector(itemActionHandler(_:)))
        _item.setTitleTextAttributes([.font: PEConfiguration.default().barItemFont, .foregroundColor: UIColor.hex("#FFFFFF")], for: .normal)
        _item.setTitleTextAttributes([.font: PEConfiguration.default().barItemFont, .foregroundColor: UIColor.hex("#FFFFFF", alpha: 0.4)], for: .disabled)
        _item.setTitleTextAttributes([.font: PEConfiguration.default().barItemFont, .foregroundColor: UIColor.hex("#FFFFFF")], for: .highlighted)
        // _item.isEnabled = false
        return _item
    }()
    
    /// 向后一步
    private lazy var backwardItem: UIBarButtonItem = {
        let _img: Optional<UIImage> = .moduleImage("draw_backward_disabled")?.withRenderingMode(.alwaysOriginal)
        let _item: UIBarButtonItem = .init(image: _img, style: .plain, target: self, action: #selector(itemActionHandler(_:)))
        _item.isEnabled = false
        return _item
    }()
    
    /// 向前一步
    private lazy var forewardItem: UIBarButtonItem = {
        let _img: Optional<UIImage> = .moduleImage("draw_foreward_disabled")?.withRenderingMode(.alwaysOriginal)
        let _item: UIBarButtonItem = .init(image: _img, style: .plain, target: self, action: #selector(itemActionHandler(_:)))
        _item.isEnabled = false
        return _item
    }()
    
    /// UIToolbar
    private lazy var toolbar: UIToolbar = {
        let _toolbar: UIToolbar = .init(frame: .init(x: 0.0, y: 0.0, width: view.bounds.width, height: 32.0))
        _toolbar.standardAppearance = .init()
        _toolbar.standardAppearance.configureWithTransparentBackground()
        _toolbar.backgroundColor = .clear
        _toolbar.items = [.flexible(), backwardItem, .fixed(18.0), forewardItem, .flexible()]
        return _toolbar
    }()
    
    /// Bool
    private var beforeNavigationBarHidden: Bool = false
    /// UIImage
    private let originImage: UIImage
    /// DrawType
    private let drawType: DrawType
    /// Optional<(_ newImage: UIImage) -> Void>
    private var completionHandler: Optional<(_ newImage: UIImage) -> Void> = .none
    
    // MARK: 生命周期
    
    /// 构建
    /// - Parameters:
    ///   - uiImage: UIImage
    ///   - drawType: DrawType
    internal init(uiImage: UIImage, drawType: DrawType) {
        self.originImage = uiImage
        self.drawType = drawType
        super.init(image: uiImage, editModel: .default(editRect: .init(origin: .zero, size: uiImage.size)))
    }
    
    /// viewDidLoad
    internal override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // 初始化
        initialize()
        // reload
        reloadWith(drawType)
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
    
    /// editorUpdate
    /// - Parameters:
    ///   - actions: [ZLEditorAction]
    ///   - redoActions: [ZLEditorAction]
    internal override func editorUpdate(didUpdateActions actions: [ZLEditorAction], redoActions: [ZLEditorAction]) {
        super.editorUpdate(didUpdateActions: actions, redoActions: redoActions)
        // next
        if actions.isEmpty == false {
            backwardItem.isEnabled = true
            backwardItem.image = .moduleImage("draw_backward_normal")?.withRenderingMode(.alwaysOriginal)
        } else {
            backwardItem.isEnabled = false
            backwardItem.image = .moduleImage("draw_backward_disabled")?.withRenderingMode(.alwaysOriginal)
        }
        // next
        if actions.count != redoActions.count {
            forewardItem.isEnabled = true
            forewardItem.image = .moduleImage("draw_foreward_normal")?.withRenderingMode(.alwaysOriginal)
        } else {
            forewardItem.isEnabled = false
            forewardItem.image = .moduleImage("draw_foreward_disabled")?.withRenderingMode(.alwaysOriginal)
        }
        // next
        undoItem.isEnabled = actions.isEmpty == false
    }
    
    deinit {
        xprint(#function, #file.hub.lastPathComponent)
    }
}

extension PEDrawImageViewController {
    
    /// 初始化
    private func initialize() {
        // coding here ...
        view.backgroundColor = .hex("#000000")
        topShadowView.isHidden = true
        
        // 布局
        
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
    
    /// reloadWith
    /// - Parameter drawType: DrawType
    private func reloadWith(_ drawType: DrawType) {
        switch drawType {
        case .draw:         drawActionHandler()
        case .imageSticker: stickImageActionHandler()
        case .textSticker:  stickTextActionHanler()
        case .mosaic:       mosaicActionHandler()
        case .filter:       filterActionHanler()
        case .adjust:       adjustActionHanler()
        }
    }
    
    /// itemActionHandler
    /// - Parameter item: UIBarButtonItem
    @objc private func itemActionHandler(_ item: UIBarButtonItem) {
        switch item {
        case backItem: // 返回操作
            navigationController?.popViewController(animated: true)
        case backwardItem: // 向后一步
            undoActionHandler()
        case forewardItem: // 向前一步
            redoActionHandler()
        case undoItem: // 还原
            var controllers: Array<UIViewController> = navigationController?.viewControllers.dropLast() ?? []
            let controller: PEDrawImageViewController = .init(uiImage: originImage, drawType: drawType)
            controller.completionHandler = completionHandler
            controllers.append(controller)
            navigationController?.setViewControllers(controllers, animated: false)
        case confirmItem: // 完成操作
            doneActionHandler {[weak self] newImage in
                DispatchQueue.global().async {
                    do {
                        let newImage: UIImage = try newImage.hub.compressImage(toByte: PEConfiguration.default().maxImageBytes)
                        DispatchQueue.main.async {[weak self] in
                            guard let this = self else { return }
                            this.navigationController?.popViewController(animated: true)
                            this.completionHandler?(newImage)
                        }
                    } catch {
                        DispatchQueue.main.async {[weak self] in
                            guard let this = self else { return }
                            this.navigationController?.popViewController(animated: true)
                            this.completionHandler?(newImage)
                        }
                    }
                }
            }
            
        default: break
        }
    }
    
    /// completionHandler
    /// - Parameter handler: Optional<(UIImage) -> Void>
    internal func completionHandler(_ handler: Optional<(UIImage) -> Void>) {
        self.completionHandler = handler
    }
}

extension PEDrawImageViewController {
    
    /// DrawType
   public enum DrawType {
       case draw
       case imageSticker
       case textSticker
       case mosaic
       case filter
       case adjust
    }
}
