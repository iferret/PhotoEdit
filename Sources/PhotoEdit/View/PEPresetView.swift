//
//  PEPresetView.swift
//  
//
//  Created by iferret on 2024/5/7.
//

import UIKit
import SnapKit

/// PEPresetViewDelegate
protocol PEPresetViewDelegate: AnyObject {
    
    /// selectedActionHandler
    /// - Parameters:
    ///   - presetView: PEPresetView
    ///   - sender: PEPresetItem
    func presetView(_ presetView: PEPresetView, selectedActionHandler sender: PEPresetItem)
}

/// PEPresetView
class PEPresetView: UIView {
    
    // MARK: 公开属性
    
    /// Optional<PEPresetItem>
    internal private(set) var selectedItem: Optional<PEPresetItem> = .photo
    /// Optional<PEPresetViewDelegate>
    internal weak var delegate: Optional<PEPresetViewDelegate> = .none
    
    // MARK: 私有属性
    
    /// UICollectionView
    private lazy var collectionView: UICollectionView = {
        let _flowlayout: UICollectionViewFlowLayout = .init()
        _flowlayout.scrollDirection = .horizontal
        _flowlayout.minimumLineSpacing = 0.0
        _flowlayout.minimumInteritemSpacing = 0.0
        let _collectionView: UICollectionView = .init(frame: .zero, collectionViewLayout: _flowlayout)
        _collectionView.hub.register(PEPresetItemCell.self)
        _collectionView.backgroundColor = .clear
        _collectionView.dataSource = self
        _collectionView.delegate = self
        _collectionView.showsHorizontalScrollIndicator = false
        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.showsLargeContentViewer = false
        _collectionView.isScrollEnabled = false
        return _collectionView
    }()
    
    /// Array<PEPresetItem>
    private let items: Array<PEPresetItem>
    
    // MARK: 生命周期
    
    /// 构建
    /// - Parameter items: Array<PEPresetItem>
    internal init(items: Array<PEPresetItem>) {
        self.items = items
        super.init(frame: .zero)
        // 初始化
        initialize()
    }
    
    /// 构建
    /// - Parameter coder: NSCoder
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// layoutSubviews
    internal override func layoutSubviews() {
        super.layoutSubviews()
        // 滚动到指定位置
        if collectionView.indexPathsForSelectedItems?.isEmpty == true, items.isEmpty == false {
            if let selectedItem = selectedItem, let firstIndex: Int = items.firstIndex(of: selectedItem) {
                let indexPath: IndexPath = .init(item: firstIndex, section: 0)
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredHorizontally)
            } else {
                let indexPath: IndexPath = .init(item: items.count - 1, section: 0)
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredHorizontally)
            }
        } else if let indxPath: IndexPath = collectionView.indexPathsForSelectedItems?.first {
            collectionView.scrollToItem(at: indxPath, at: .centeredHorizontally, animated: false)
        }
    }
}

extension PEPresetView {
    
    /// 初始化
    private func initialize() {
        // coding here ...
        // 布局
        addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

// MARK: - UICollectionViewDataSource
extension PEPresetView: UICollectionViewDataSource {
    
    /// numberOfItemsInSection
    /// - Parameters:
    ///   - collectionView: UICollectionView
    ///   - section: Int
    /// - Returns: Int
    internal func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    /// cellForItemAt
    /// - Parameters:
    ///   - collectionView: UICollectionView
    ///   - indexPath: IndexPath
    /// - Returns: UICollectionViewCell
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: PEPresetItemCell = collectionView.hub.dequeueReusableCel(for: indexPath)
        cell.item = items[indexPath.item]
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension PEPresetView: UICollectionViewDelegateFlowLayout {
    
    /// minimumLineSpacingForSectionAt
    /// - Parameters:
    ///   - collectionView: UICollectionView
    ///   - collectionViewLayout: UICollectionViewLayout
    ///   - section: Int
    /// - Returns: CGFloat
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                                 minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 24.0
    }
    
    /// minimumInteritemSpacingForSectionAt
    /// - Parameters:
    ///   - collectionView: UICollectionView
    ///   - collectionViewLayout: UICollectionViewLayout
    ///   - section: Int
    /// - Returns: CGFloat
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                                 minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    /// insetForSectionAt
    /// - Parameters:
    ///   - collectionView: UICollectionView
    ///   - collectionViewLayout: UICollectionViewLayout
    ///   - section: Int
    /// - Returns: UIEdgeInsets
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                                 insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 0.0, left: ceil(collectionView.bounds.width), bottom: 0.0, right: ceil(collectionView.bounds.width))
    }
    
    /// sizeForItemAt
    /// - Parameters:
    ///   - collectionView: UICollectionView
    ///   - collectionViewLayout: UICollectionViewLayout
    ///   - indexPath: IndexPath
    /// - Returns: CGSize
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                                 sizeForItemAt indexPath: IndexPath) -> CGSize {
        let preferredWidth: CGFloat = PEPresetItemCell.preferredWidth(for: items[indexPath.item])
        return .init(width: preferredWidth, height: collectionView.bounds.height)
    }
    
    /// didSelectItemAt
    /// - Parameters:
    ///   - collectionView: UICollectionView
    ///   - indexPath: IndexPath
    internal func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedItem = items[indexPath.item]
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        // next
        delegate?.presetView(self, selectedActionHandler: items[indexPath.item])
    }
}
