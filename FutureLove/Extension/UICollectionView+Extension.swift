//
//  UICollectionView+Extension.swift
//  FutureLove
//
//  Created by Do Nang Cuong on 15/01/2024.
//

import Foundation


import UIKit

extension UICollectionView {
    func register<T: UICollectionViewCell>(cellType: T.Type, bundle: Bundle? = nil) {
        let className = cellType.className
        let nib = UINib(nibName: className, bundle: bundle)
        register(nib, forCellWithReuseIdentifier: className)
    }

    func dequeueReusableCell<T: UICollectionViewCell>(with type: T.Type, for indexPath: IndexPath) -> T? {
        return self.dequeueReusableCell(withReuseIdentifier: type.className, for: indexPath) as? T
    }
}
