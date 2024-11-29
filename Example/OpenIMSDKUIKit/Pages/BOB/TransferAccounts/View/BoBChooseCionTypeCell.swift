//
//  BoBChooseCionTypeCell.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/11/29.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Foundation
class BoBChooseCionTypeCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = .white
        contentView.addSubview(cionTypeImageView)
        contentView.addSubview(cionNameLabel)
        contentView.addSubview(cionTypeLabel)
        contentView.addSubview(moneyLabel)
        cionTypeImageView.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.centerY.equalTo(contentView)
            make.width.height.equalTo(26)
        }
        cionNameLabel.snp_makeConstraints { make in
            make.left.equalTo(cionTypeImageView.snp_right).offset(10)
            make.centerY.equalTo(cionTypeImageView.snp_centerY)
        }
        cionTypeLabel.snp_makeConstraints { make in
            make.left.equalTo(cionNameLabel.snp_right).offset(7)
            make.centerY.equalTo(cionNameLabel)
            make.width.equalTo(62)
            make.height.equalTo(26)
        }
        moneyLabel.snp_makeConstraints { make in
            make.right.equalTo(-16)
            make.centerY.equalTo(contentView)
        }
        
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var cionTypeImageView: UIImageView = {
        let r = UIImageView()
        return r
    }()
    lazy var cionNameLabel: UILabel = {
        let r = UILabel()
        r.font = .mediumFont(16)
        r.textColor = .black333
        return r
    }()
    lazy var cionTypeLabel: UILabel = {
        let r = UILabel()
        r.textColor = .init(hexString: "#00AA3C")
        r.backgroundColor = .init(hexString: "#E5F6EB")
        r.corner(13)
        r.font = .regularFont(12)
        r.text = "T+0钱包"
        r.textAlignment = .center
        return r
    }()
    lazy var moneyLabel: UILabel = {
        let r = UILabel()
        r.font = .regularFont(14)
        r.textColor = .black666
        r.textAlignment = .right
        return r
    }()
}
