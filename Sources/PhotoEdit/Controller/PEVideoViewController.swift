//
//  PEVideoViewController.swift
//  
//
//  Created by iferret on 2024/5/8.
//

import UIKit
import AVKit

/// PEVideoViewController
class PEVideoViewController: UIViewController {
    
    // MARK: 私有属性

    /// 重拍
    private lazy var redoItem: UIBarButtonItem = {
        let _item: UIBarButtonItem = .init(title: "重拍", style: .plain, target: self, action: #selector(itemActionHandler(_:)))
        _item.setTitleTextAttributes([.font: UIFont.pingfang(ofSize: 18.0), .foregroundColor: UIColor.hex("#FFFFFF")], for: .normal)
        _item.setTitleTextAttributes([.font: UIFont.pingfang(ofSize: 18.0), .foregroundColor: UIColor.hex("#FFFFFF")], for: .highlighted)
        return _item
    }()
    
    /// 使用视频
    private lazy var useItem: UIBarButtonItem = {
        let _item: UIBarButtonItem = .init(title: "使用视频", style: .plain, target: self, action: #selector(itemActionHandler(_:)))
        _item.setTitleTextAttributes([.font: UIFont.pingfang(ofSize: 18.0), .foregroundColor: UIColor.hex("#FFFFFF")], for: .normal)
        _item.setTitleTextAttributes([.font: UIFont.pingfang(ofSize: 18.0), .foregroundColor: UIColor.hex("#FFFFFF")], for: .highlighted)
        return _item
    }()
    
    /// 工具栏
    private lazy var toolbar: UIToolbar = {
        let _toolbar: UIToolbar = .init(frame: .init(x: 0.0, y: 0.0, width: view.bounds.width, height: 52.0))
        _toolbar.standardAppearance = .init()
        _toolbar.standardAppearance.configureWithOpaqueBackground()
        _toolbar.standardAppearance.backgroundColor = .hex("#141414")
        _toolbar.backgroundColor = .hex("#141414")
        _toolbar.items = [redoItem, .flexible(), useItem]
        return _toolbar
    }()
    
    /// AVPlayerViewController
    private lazy var controller: AVPlayerViewController = {
        let _controller: AVPlayerViewController = .init()
        _controller.player = .init(url: fileURL)
        _controller.videoGravity = .resizeAspectFill
        return _controller
    }()
    
    /// URL
    private let fileURL: URL
    
    // MARK: 生命周期
    
    /// 构建
    /// - Parameter fileURL: URL
    internal init(fileURL: URL) {
        self.fileURL = fileURL
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

extension PEVideoViewController {
    
    /// 初始化
    private func initialize() {
        // coding here ...
        view.backgroundColor = .hex("#000000")
        navigationItem.leftBarButtonItem = .disabled
        
        // 布局
        view.addSubview(toolbar)
        toolbar.snp.makeConstraints {
            $0.left.right.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(52.0)
        }
        
        view.addSubview(controller.view)
        controller.view.snp.makeConstraints {
            $0.left.right.top.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(toolbar.snp.top)
        }
    }
    
    /// itemActionHandler
    /// - Parameter sender: UIBarButtonItem
    @objc private func itemActionHandler(_ sender: UIBarButtonItem) {
        
    }

    
}
