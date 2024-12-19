//
//  BoBMineAdvertisementCell.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/12/18.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Foundation
class BoBMineAdvertisementCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        self.backgroundColor = .colorBackgroundAPP
        contentView.backgroundColor = .clear
        contentView.addSubview(bgView)
        bgView.addSubview(cionImageView)
        bgView.addSubview(adTypeNameLabel)
        bgView.addSubview(statusLabel)
        bgView.addSubview(exchangeRateLabel)
        bgView.addSubview(countTitleLabel)
        bgView.addSubview(countLabel)
        bgView.addSubview(limitTitleLabel)
        bgView.addSubview(limitCountLabel)
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
            make.height.equalTo(26)
        }
        exchangeRateLabel.snp_makeConstraints { make in
            make.left.equalTo(adTypeNameLabel)
            make.top.equalTo(cionImageView.snp_bottom).offset(12)
            make.height.equalTo(20)
            make.right.equalTo(-16)
        }
        countTitleLabel.snp_makeConstraints { make in
            make.left.equalTo(adTypeNameLabel)
            make.top.equalTo(exchangeRateLabel.snp_bottom).offset(10)
            make.height.equalTo(15)
        }
        countLabel.snp_makeConstraints { make in
            make.left.equalTo(countTitleLabel.snp_right).offset(4)
            make.centerY.height.equalTo(countTitleLabel)
//            make.right.equalTo(freeMoneyLabel)
        }
        limitTitleLabel.snp_makeConstraints { make in
            make.left.equalTo(adTypeNameLabel)
            make.top.equalTo(countTitleLabel.snp_bottom).offset(5)
            make.height.equalTo(15)
        }
        limitCountLabel.snp_makeConstraints { make in
            make.left.equalTo(limitTitleLabel.snp_right).offset(4)
            make.centerY.height.equalTo(limitTitleLabel)
//            make.right.equalTo(freeMoneyLabel)
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
    
    lazy var exchangeRateLabel: UILabel = {
        let r = UILabel()
        r.font = .mediumFont(20)
        r.textColor = .black333
        return r
    }()
    lazy var countTitleLabel: UILabel = {
        let v = UILabel()
        v.font = .regularFont(12)
        v.textColor = .black999
        v.text = "数量"
        return v
    }()
    lazy var countLabel: UILabel = {
        let v = UILabel()
        v.font = .regularFont(12)
        v.textColor = .black333
        v.textAlignment = .left
        return v
    }()
    lazy var limitTitleLabel: UILabel = {
        let v = UILabel()
        v.font = .regularFont(12)
        v.textColor = .black999
        v.text = "限额"
        return v
    }()
    lazy var limitCountLabel: UILabel = {
        let v = UILabel()
        v.font = .regularFont(12)
        v.textColor = .black333
        v.textAlignment = .left
        return v
    }()
}
