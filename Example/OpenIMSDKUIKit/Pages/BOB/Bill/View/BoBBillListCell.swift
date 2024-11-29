//
//  BoBBillListCell.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/11/29.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Foundation
class BoBBillListCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = .white
        contentView.addSubview(billNameLabel)
        contentView.addSubview(countLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(lineView)
        billNameLabel.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.top.equalTo(12)
        }
        countLabel.snp_makeConstraints { make in
            make.right.equalTo(-16)
            make.top.equalTo(17)
            make.width.equalTo(160)
        }
        timeLabel.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.bottom.equalTo(-13)
        }
        lineView.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.bottom.right.equalTo(contentView)
            make.height.equalTo(1)
        }
        
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var billNameLabel:  UILabel = {
        let v = UILabel()
        v.font = .semiboldFont(16)
        v.textColor = .black333
        return v
    }()
    lazy var countLabel: UILabel = {
        let v = UILabel()
        v.font = .mediumFont(16)
        v.textColor = .black333
        v.textAlignment = .right
        return v
    }()
    lazy var timeLabel: UILabel = {
        let v = UILabel()
        v.font = .regularFont(14)
        v.textColor = .black666
        return v
    }()
    lazy var lineView: UIView = {
        let v = UIView()
        v.backgroundColor = .colorDivider
        return v
    }()
}
