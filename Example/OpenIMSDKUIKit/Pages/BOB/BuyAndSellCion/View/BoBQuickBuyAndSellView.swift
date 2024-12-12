//
//  BoBQuickBuyAndSellView.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/12/10.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Foundation
import JXSegmentedView

class BoBQuickBuyAndSellView: UIView {
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
extension BoBQuickBuyAndSellView: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return self
    }
}
