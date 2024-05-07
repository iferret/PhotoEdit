//
//  PEZoomFactorView.swift
//  
//
//  Created by iferret on 2024/5/7.
//

import UIKit
import SnapKit

/// PEZoomFactorViewDelegate
protocol PEZoomFactorViewDelegate: AnyObject {
    
    /// selectedActionHandler
    /// - Parameters:
    ///   - zoomFactorView: PEZoomFactorView
    ///   - videoZoomFactor: CGFloat
    func zoomFactorView(_ zoomFactorView: PEZoomFactorView, selectedActionHandler videoZoomFactor: CGFloat)
}

/// PEZoomFactorView
class PEZoomFactorView: UIView {
    
    /// Int
    enum Kind: Int {
        case min
        case mid
        case max
    }
    
    /// (videoZoomFactor: CGFloat, normalText: NSAttributedString, selectedText: NSAttributedString)
    typealias Element = (videoZoomFactor: CGFloat, normalText: NSAttributedString, selectedText: NSAttributedString)

    // MARK: 公开属性
    
    /// CGFloat
    internal var cornerRadius: CGFloat {
        get { layer.cornerRadius }
        set { layer.cornerRadius = newValue; setNeedsUpdateConstraints() }
    }
    
    /// Bool
    internal var masksToBounds: Bool {
        get { layer.masksToBounds }
        set { layer.masksToBounds = newValue }
    }
    
    /// Optional<CGFloat>
    internal var minAvailableVideoZoomFactor: Optional<CGFloat> = .none {
        didSet { reloadWith(minAvailableVideoZoomFactor, maxAvailableVideoZoomFactor, videoZoomFactor) }
    }
    
    /// Optional<CGFloat>
    internal var maxAvailableVideoZoomFactor: Optional<CGFloat> = .none {
        didSet { reloadWith(minAvailableVideoZoomFactor, maxAvailableVideoZoomFactor, videoZoomFactor) }
    }
    
    /// Optional<CGFloat>
    private var _videoZoomFactor: Optional<CGFloat> = .none
    /// Optional<CGFloat>
    internal var videoZoomFactor: Optional<CGFloat> {
        get { _videoZoomFactor }
        set { _videoZoomFactor = newValue; reloadWith(minAvailableVideoZoomFactor, maxAvailableVideoZoomFactor, newValue) }
    }
    
    /// Optional<PEZoomFactorViewDelegate>
    internal weak var delegate: Optional<PEZoomFactorViewDelegate> = .none
    
    // MARK: 私有属性
    
    /// UIButton
    private lazy var minButton: UIButton = {
        let _button: UIButton = .init(type: .custom)
        _button.setBackgroundImage(.moduleImage("camera_zoom_bg_normal"), for: .normal)
        _button.setBackgroundImage(.moduleImage("camera_zoom_bg_selected"), for: .selected)
        _button.addTarget(self, action: #selector(buttonActionHandler(_:)), for: .touchUpInside)
        return _button
    }()
    
    /// UIButton
    private lazy var midButton: UIButton = {
        let _button: UIButton = .init(type: .custom)
        _button.setBackgroundImage(.moduleImage("camera_zoom_bg_normal"), for: .normal)
        _button.setBackgroundImage(.moduleImage("camera_zoom_bg_selected"), for: .selected)
        _button.addTarget(self, action: #selector(buttonActionHandler(_:)), for: .touchUpInside)
        _button.isSelected = true
        return _button
    }()
    
    /// UIButton
    private lazy var maxButton: UIButton = {
        let _button: UIButton = .init(type: .custom)
        _button.setBackgroundImage(.moduleImage("camera_zoom_bg_normal"), for: .normal)
        _button.setBackgroundImage(.moduleImage("camera_zoom_bg_selected"), for: .selected)
        _button.addTarget(self, action: #selector(buttonActionHandler(_:)), for: .touchUpInside)
        return _button
    }()
    /// Dictionary<Kind, Element>
    private var dict: Dictionary<Kind, Element> = [:]

    // MARK: 生命周期
    
    /// 构建
    /// - Parameter frame: CGRect
    internal override init(frame: CGRect) {
        super.init(frame: frame)
        // 初始化
        initialize()
    }
    
    /// 构建
    /// - Parameter coder: NSCoder
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// updateConstraints
    internal override func updateConstraints() {
        defer { super.updateConstraints() }
        // minButton.snp.remakeConstraints
        minButton.snp.remakeConstraints {
            $0.centerX.equalTo(self.snp.left).offset(cornerRadius)
            $0.centerY.equalToSuperview()
        }
        // midButton.snp.remakeConstraints
        midButton.snp.remakeConstraints {
            $0.center.equalToSuperview()
        }
        // maxButton.snp.remakeConstraints
        maxButton.snp.remakeConstraints {
            $0.centerX.equalTo(self.snp.right).offset(-cornerRadius)
            $0.centerY.equalToSuperview()
        }
    }
}

extension PEZoomFactorView {
    
    /// 初始化
    private func initialize() {
        // coding here ...
        
        // 布局
        addSubview(minButton)
        minButton.snp.makeConstraints {
            $0.centerX.equalTo(self.snp.left).offset(cornerRadius)
            $0.centerY.equalToSuperview()
        }
        
        addSubview(midButton)
        midButton.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        addSubview(maxButton)
        maxButton.snp.makeConstraints {
            $0.centerX.equalTo(self.snp.right).offset(-cornerRadius)
            $0.centerY.equalToSuperview()
        }
        
    }
    
    /// buttonActionHandler
    /// - Parameter sender: UIButton
    @objc private func buttonActionHandler(_ sender: UIButton) {
        switch sender {
        case minButton where minButton.isSelected == false:
            guard let val: CGFloat = dict[.min]?.videoZoomFactor else { return }
            // next
            minButton.isSelected = true
            midButton.isSelected = false
            maxButton.isSelected = false
            // next
            minButton.setBackgroundImage(.moduleImage("camera_zoom_bg_normal"), for: .highlighted)
            midButton.setBackgroundImage(.moduleImage("camera_zoom_bg_selected"), for: .highlighted)
            maxButton.setBackgroundImage(.moduleImage("camera_zoom_bg_selected"), for: .highlighted)
            // next
            _videoZoomFactor = val
            // next
            delegate?.zoomFactorView(self, selectedActionHandler: val)
            
        case midButton where midButton.isSelected == false:
            guard let val: CGFloat = dict[.mid]?.videoZoomFactor else { return }
            // next
            minButton.isSelected = false
            midButton.isSelected = true
            maxButton.isSelected = false
            // next
            minButton.setBackgroundImage(.moduleImage("camera_zoom_bg_selected"), for: .highlighted)
            midButton.setBackgroundImage(.moduleImage("camera_zoom_bg_normal"), for: .highlighted)
            maxButton.setBackgroundImage(.moduleImage("camera_zoom_bg_selected"), for: .highlighted)
            // next
            _videoZoomFactor = val
            // next
            delegate?.zoomFactorView(self, selectedActionHandler: val)
            
        case maxButton where maxButton.isSelected == false:
            guard let val: CGFloat = dict[.max]?.videoZoomFactor else { return }
            // next
            minButton.isSelected = false
            midButton.isSelected = false
            maxButton.isSelected = true
            // next
            minButton.setBackgroundImage(.moduleImage("camera_zoom_bg_selected"), for: .highlighted)
            midButton.setBackgroundImage(.moduleImage("camera_zoom_bg_selected"), for: .highlighted)
            maxButton.setBackgroundImage(.moduleImage("camera_zoom_bg_normal"), for: .highlighted)
            // next
            _videoZoomFactor = val
            // next
            delegate?.zoomFactorView(self, selectedActionHandler: val)
            
        default: break
        }
    }
    
    /// reloadWith
    /// - Parameters:
    ///   - minAvailableVideoZoomFactor: Optional<CGFloat>
    ///   - maxAvailableVideoZoomFactor: Optional<CGFloat>
    ///   - videoZoomFactor: Optional<CGFloat>
    private func reloadWith(_ minAvailableVideoZoomFactor: Optional<CGFloat>, _ maxAvailableVideoZoomFactor: Optional<CGFloat>, _ videoZoomFactor: Optional<CGFloat>) {
        guard let minAvailableVideoZoomFactor = minAvailableVideoZoomFactor,
              let maxAvailableVideoZoomFactor = maxAvailableVideoZoomFactor,
              let videoZoomFactor = videoZoomFactor
        else { return }
        //  next
        let kind: Kind
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.pingfang(ofSize: 13.0), .foregroundColor: UIColor.hex("#FFFFFF")]
        let selectedAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.pingfang(ofSize: 14.0), .foregroundColor: UIColor.hex("#FFE27E")]
        if max(0.5, minAvailableVideoZoomFactor) == 0.5 {
            dict[.min] = (0.5, NSAttributedString(string: ".5", attributes: attributes), NSAttributedString(string: ".5x", attributes: selectedAttributes))
            dict[.mid] = (1.0, NSAttributedString(string: "1", attributes: attributes), NSAttributedString(string: "1x", attributes: selectedAttributes))
            dict[.max] = (3.0, NSAttributedString(string: "3", attributes: attributes), NSAttributedString(string: "3x", attributes: selectedAttributes))
            kind = .mid
        } else {
            dict[.min] = (1.0, NSAttributedString(string: "1", attributes: attributes), NSAttributedString(string: "1x", attributes: selectedAttributes))
            dict[.mid] = (2.0, NSAttributedString(string: "2", attributes: attributes), NSAttributedString(string: "2x", attributes: selectedAttributes))
            dict[.max] = (3.0, NSAttributedString(string: "3", attributes: attributes), NSAttributedString(string: "3x", attributes: selectedAttributes))
            kind = .min
        }
        // 更新UI
        minButton.setAttributedTitle(dict[.min]?.normalText, for: .normal)
        minButton.setAttributedTitle(dict[.min]?.selectedText, for: .selected)
        
        midButton.setAttributedTitle(dict[.mid]?.normalText, for: .normal)
        midButton.setAttributedTitle(dict[.mid]?.selectedText, for: .selected)
        
        maxButton.setAttributedTitle(dict[.max]?.normalText, for: .normal)
        maxButton.setAttributedTitle(dict[.max]?.selectedText, for: .selected)
        // next
        switch (dict.first(where: { $0.value.videoZoomFactor == videoZoomFactor })?.key ?? kind) {
        case .min where minButton.isSelected == false:
            minButton.isSelected = true
            midButton.isSelected = false
            maxButton.isSelected = false
            
            minButton.setBackgroundImage(.moduleImage("camera_zoom_bg_normal"), for: .highlighted)
            midButton.setBackgroundImage(.moduleImage("camera_zoom_bg_selected"), for: .highlighted)
            maxButton.setBackgroundImage(.moduleImage("camera_zoom_bg_selected"), for: .highlighted)
            
        case .mid where midButton.isSelected == false:
            minButton.isSelected = false
            midButton.isSelected = true
            maxButton.isSelected = false
            
            minButton.setBackgroundImage(.moduleImage("camera_zoom_bg_selected"), for: .highlighted)
            midButton.setBackgroundImage(.moduleImage("camera_zoom_bg_normal"), for: .highlighted)
            maxButton.setBackgroundImage(.moduleImage("camera_zoom_bg_selected"), for: .highlighted)
            
        case .max where maxButton.isSelected == false:
            minButton.isSelected = false
            midButton.isSelected = false
            maxButton.isSelected = true
            
            minButton.setBackgroundImage(.moduleImage("camera_zoom_bg_selected"), for: .highlighted)
            midButton.setBackgroundImage(.moduleImage("camera_zoom_bg_selected"), for: .highlighted)
            maxButton.setBackgroundImage(.moduleImage("camera_zoom_bg_normal"), for: .highlighted)
            
        default: break
        }
    }
}
