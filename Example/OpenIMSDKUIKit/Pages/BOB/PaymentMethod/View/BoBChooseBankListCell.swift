//
//  BoBChooseBankListCell.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/11/27.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Foundation
class BoBChooseBankListCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = .white
        contentView.addSubview(bankIcon)
        contentView.addSubview(bankNameLabel)
        contentView.addSubview(lineView)
        bankIcon.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.centerY.equalTo(contentView)
            make.width.height.equalTo(24)
        }
        bankNameLabel.snp_makeConstraints { make in
            make.left.equalTo(bankIcon.snp_right).offset(8)
            make.centerY.equalTo(bankIcon.snp_centerY)
            make.right.equalTo(-16)
        }
        lineView.snp_makeConstraints { make in
            make.left.equalTo(bankNameLabel)
            make.bottom.right.equalTo(contentView)
            make.height.equalTo(1)
        }
        
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var bankIcon: UIImageView = {
        let v = UIImageView()
        return v
    }()
    lazy var bankNameLabel: UILabel = {
        let v = UILabel()
        v.font = UIFont(name: "PingFangSC-Regular", size: 18)
        v.textColor = .black333
        return v
    }()
    lazy var lineView: UIView = {
        let v = UIView()
        v.backgroundColor = .colorDivider
        return v
    }()
}
