//
//  File.swift
//  
//
//  Created by iferret on 2024/5/7.
//

import UIKit

extension UICollectionReusableView: Reusable {}

extension UICollectionView: Compatible {}
extension CompatibleWrapper where Base: UICollectionView {
    
    /// register
    /// - Parameter cellClass: T.Type
    internal func register<T>(_ cellClass: T.Type) where T: UICollectionViewCell {
        base.register(cellClass.self, forCellWithReuseIdentifier: cellClass.reusedID)
    }
    
    /// dequeueReusableCel
    /// - Parameter indexPath: IndexPath
    /// - Returns: T
    internal func dequeueReusableCel<T>(for indexPath: IndexPath) -> T where T: UICollectionViewCell {
        return base.dequeueReusableCell(withReuseIdentifier: T.reusedID, for: indexPath) as! T
    }
}
