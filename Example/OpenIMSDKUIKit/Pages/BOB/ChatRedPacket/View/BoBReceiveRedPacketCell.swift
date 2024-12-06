//
//  BoBReceiveRedPacketCell.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/12/6.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Foundation
class BoBReceiveRedPacketCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = .colorBackgroundAPP
        contentView.addSubview(userImageView)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(moneyLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(bestLabel)
        contentView.addSubview(lineView)

        userImageView.snp_makeConstraints { make in
            make.left.equalTo(0)
            make.centerY.equalTo(contentView)
            make.width.height.equalTo(56)
        }
        userNameLabel.snp_makeConstraints { make in
            make.left.equalTo(userImageView.snp_right).offset(13)
            make.top.equalTo(12)
            make.height.equalTo(22)
            make.right.equalTo(moneyLabel.snp_left).offset(-5)
        }
        moneyLabel.snp_makeConstraints { make in
            make.right.equalTo(0)
            make.centerY.equalTo(userNameLabel)
            make.width.equalTo(140)
        }
        timeLabel.snp_makeConstraints { make in
            make.left.equalTo(userNameLabel)
            make.bottom.equalTo(-12)
            make.width.equalTo(140)
            make.height.equalTo(22)
        }
        bestLabel.snp_makeConstraints { make in
            make.right.equalTo(moneyLabel)
            make.left.equalTo(timeLabel.snp_right).offset(10)
            make.centerY.equalTo(timeLabel)
        }
        lineView.snp_makeConstraints { make in
            make.left.right.bottom.equalTo(0)
            make.height.equalTo(1)
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var userImageView: UIImageView = {
        let r = UIImageView()
        r.corner(28)
        return r
    }()
    lazy var userNameLabel: UILabel = {
        let r = UILabel()
        r.font = .semiboldFont(16)
        r.textColor = .black333
        return r
    }()
    lazy var timeLabel: UILabel = {
        let r = UILabel()
        r.textColor = .black666
        r.font = .regularFont(14)
        return r
    }()
    lazy var moneyLabel: UILabel = {
        let r = UILabel()
        r.font = .mediumFont(14)
        r.textColor = .primaryColor
        r.textAlignment = .right
        return r
    }()
    lazy var bestLabel: UILabel = {
        let r = UILabel()
        r.font = .mediumFont(14)
        r.textColor = .init(hexString: "#FFDA71")
        r.textAlignment = .right
        return r
    }()
    lazy var lineView: UIView = {
        let r = ViewFactoryUtil.smallDivider()
        return r
    }()
}
