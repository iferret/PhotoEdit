//
//  PEImageEditViewController.swift
//  
//
//  Created by iferret on 2024/5/8.
//

import UIKit
import SnapKit

/// PEImageEditViewController
class PEImageEditViewController: UIViewController {
    
    // MARK: 私有属性
    
    /// UIImage
    private let originImage: UIImage
    /// UIImage
    private var editImage: UIImage
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
}
