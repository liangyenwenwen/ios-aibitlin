//
//  BoBOrderListCell.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/11/19.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Foundation
class BoBOrderListCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        self.backgroundColor = .colorBackgroundAPP
        contentView.backgroundColor = .clear
        contentView.addSubview(bgView)
        bgView.addSubview(cionImageView)
        bgView.addSubview(adTypeNameLabel)
        bgView.addSubview(statusLabel)
        bgView.addSubview(moneyLabel)
        bgView.addSubview(exchangeRateTitleLabel)
        bgView.addSubview(exchangeRateLabel)
        bgView.addSubview(lineView)
        bgView.addSubview(orderNumberLabel)
        bgView.addSubview(timeLabel)
        bgView.addSubview(appealStatusLabel)
        bgView.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.top.equalTo(0)
            make.bottom.equalTo(-12)
        }
        cionImageView.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.top.equalTo(11)
            make.width.height.equalTo(26)
        }
        adTypeNameLabel.snp_makeConstraints { make in
            make.left.equalTo(cionImageView.snp_right).offset(8)
            make.centerY.equalTo(cionImageView)
            make.right.equalTo(statusLabel.snp_left).offset(-16)
        }
        statusLabel.snp_makeConstraints { make in
            make.right.equalTo(-16)
            make.top.equalTo(15)
            make.width.equalTo(60)
            make.height.equalTo(22)
        }
        moneyLabel.snp_makeConstraints { make in
            make.left.equalTo(adTypeNameLabel)
            make.top.equalTo(cionImageView.snp_bottom).offset(12)
            make.height.equalTo(20)
        }
        exchangeRateTitleLabel.snp_makeConstraints { make in
            make.left.equalTo(moneyLabel)
            make.top.equalTo(moneyLabel.snp_bottom).offset(7)
            make.height.equalTo(17)
        }
        exchangeRateLabel.snp_makeConstraints { make in
            make.left.equalTo(exchangeRateTitleLabel.snp_right).offset(4)
            make.centerY.equalTo(exchangeRateTitleLabel)
            make.width.equalTo(60)
        }
        lineView.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.bottom.equalTo(-40)
            make.height.equalTo(1)
        }
        orderNumberLabel.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.bottom.equalTo(-12)
            make.height.equalTo(17)
            make.right.equalTo(timeLabel.snp_left).offset(-5)
        }
        timeLabel.snp_makeConstraints { make in
            make.right.equalTo(-16)
            make.centerY.equalTo(orderNumberLabel)
            make.width.equalTo(135)
        }
        appealStatusLabel.snp_makeConstraints { make in
            make.right.equalTo(-16)
            make.top.equalTo(statusLabel.snp_bottom).offset(35)
            make.height.equalTo(18)
            make.left.equalTo(150)
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var bgView: UIView = {
        let r = UIView()
        r.backgroundColor = .white
        r.corner(14)
        return r
    }()
    
    lazy var cionImageView: UIImageView = {
        let r = UIImageView()
        return r
    }()
    lazy var adTypeNameLabel:  UILabel = {
        let r = UILabel()
        r.font = .mediumFont(16)
        r.textColor = .black333
        return r
    }()
    lazy var statusLabel:  UILabel = {
        let r = UILabel()
        r.font = .regularFont(12)
        r.textColor = .white
        r.corner(6)
        r.textAlignment = .center
        return r
    }()
    lazy var moneyLabel: UILabel = {
        let r = UILabel()
        r.font = .mediumFont(20)
        r.textColor = .primaryColor
        return r
    }()
    lazy var exchangeRateTitleLabel: UILabel = {
        let r = UILabel()
        r.font = .regularFont(12)
        r.textColor = .black999
        r.text = "汇率"
        return r
    }()
    lazy var exchangeRateLabel: UILabel = {
        let r = UILabel()
        r.font = .regularFont(12)
        r.textColor = .black333
        return r
    }()
    lazy var lineView: UIView = {
        let r = UIView()
        r.backgroundColor = .init(hexString: "#EAEAEA")
        return r
    }()
    lazy var orderNumberLabel: UILabel = {
        let r = UILabel()
        r.font = .regularFont(12)
        r.textColor = .black999
        return r
    }()
    
    lazy var timeLabel: UILabel = {
        let r = UILabel()
        r.font = .regularFont(12)
        r.textColor = .black999
        r.textAlignment = .right
        return r
    }()
    lazy var appealStatusLabel: UILabel = {
        let r = UILabel()
        r.font = .regularFont(12)
        r.textAlignment = .right
        return r
    }()
}
