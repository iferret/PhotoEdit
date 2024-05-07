//
//  PEPresetItemCell.swift
//  
//
//  Created by iferret on 2024/5/7.
//

import UIKit
import SnapKit

/// UICollectionViewCell
class PEPresetItemCell: UICollectionViewCell {
    
    // MARK: 公开属性
    
    /// Optional<PEPresetItem>
    internal var item: Optional<PEPresetItem> = .none {
        didSet { reloadWith(item) }
    }
    
    /// Bool
    internal override var isSelected: Bool {
        didSet { reloadWith(item) }
    }
    
    // MARK: 私有属性
    
    /// UILabel
    private lazy var textLabel: UILabel = {
        let _label: UILabel = .init(frame: .zero)
        _label.textAlignment = .center
        return _label
    }()
    
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
}

extension PEPresetItemCell {
    
    /// 初始化
    private func initialize() {
        // coding here ...
        // 布局
        contentView.addSubview(textLabel)
        textLabel.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    /// reloadWith
    /// - Parameter item: Optional<PEPresetItem>
    private func reloadWith(_ item: Optional<PEPresetItem>) {
        if isSelected == true {
            textLabel.attributedText = item?.hub.selectedText
        } else {
            textLabel.attributedText = item?.hub.normalText
        }
    }
}

extension PEPresetItemCell {
    
    /// preferredWidth
    /// - Parameter item: PEPresetItem
    /// - Returns: CGFloat
    internal static func preferredWidth(for item: PEPresetItem) -> CGFloat {
        let lineHeight: CGFloat = ceil(item.hub.maxfont.lineHeight)
        let size: CGSize = .init(width: .greatestFiniteMagnitude, height: lineHeight)
        return ceil(item.hub.selectedText.boundingRect(with: size, options: .usesLineFragmentOrigin, context: .none).width)
    }
}
