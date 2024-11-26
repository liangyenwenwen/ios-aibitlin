//
//  BoBOrderListCell.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/11/19.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Foundation
class BoBOrderListCell: UITableViewCell {
    
    private(set) lazy var titleLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        contentView.addSubview(titleLabel)
        
        let leading = NSLayoutConstraint(item: titleLabel, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 10)
        let top = NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: 10)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([leading, top])
    }

}
