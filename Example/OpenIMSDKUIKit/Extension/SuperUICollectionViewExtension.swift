//
//  SuperUICollectionViewExtension.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/5/25.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import UIKit

extension UICollectionView{

    func scrollToLastCell() {
        let section = numberOfSections
        if section < 1 {
            return
        }
        let row = numberOfItems(inSection: section)
        if row < 1 {
            return
        }
        let indexPath = IndexPath(row: row - 1, section: section - 1)
        scrollToItem(at: indexPath, at: .bottom, animated: true)
    }

}
