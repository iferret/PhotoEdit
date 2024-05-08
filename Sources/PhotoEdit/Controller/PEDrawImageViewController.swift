//
//  PEDrawImageViewController.swift
//  
//
//  Created by iferret on 2024/5/8.
//

import UIKit
import ZLPhotoBrowser

/// ZLEditImageViewController
class PEDrawImageViewController: ZLEditImageViewController {
    
    // MARK: 私有属性
    
    /// Bool
    private var beforeNavigationBarHidden: Bool = false
    /// DrawType
    private let drawType: DrawType
    
    // MARK: 生命周期
    
    /// 构建
    /// - Parameters:
    ///   - uiImage: UIImage
    ///   - drawType: DrawType
    internal init(uiImage: UIImage, drawType: DrawType) {
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
    
    
}

extension PEDrawImageViewController {
    
    /// 初始化
    private func initialize() {
        // coding here ...
        view.backgroundColor = .hex("#000000")
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
