//
//  BoBChoosePaymentMethodTypeCell.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/12/16.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Foundation
class BoBChoosePaymentMethodTypeCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = .clear
        contentView.addSubview(bgView)
        bgView.addSubview(iconImageView)
        bgView.addSubview(paymentNameLabel)
        bgView.addSubview(userNameLabel)
        bgView.addSubview(numberLabel)
        bgView.addSubview(selectStatusImageView)
        bgView.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.top.equalTo(0)
            make.bottom.equalTo(-12)
        }
        iconImageView.snp_makeConstraints { make in
            make.left.equalTo(21)
            make.centerY.equalTo(bgView)
            make.width.height.equalTo(30)
        }
        paymentNameLabel.snp_makeConstraints { make in
            make.top.equalTo(10)
            make.left.equalTo(iconImageView.snp_right).offset(14)
        }
        userNameLabel.snp_makeConstraints { make in
            make.left.equalTo(paymentNameLabel.snp_right).offset(2)
            make.bottom.equalTo(paymentNameLabel)
        }
        numberLabel.snp_makeConstraints { make in
            make.left.equalTo(paymentNameLabel)
            make.bottom.equalTo(-10)
            make.right.equalTo(-30)
        }
        selectStatusImageView.snp_makeConstraints { make in
            make.right.bottom.equalTo(bgView)
            make.width.height.equalTo(20)
        }
        
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var bgView: UIView = {
        let r = UIView()
        r.backgroundColor = .white
        r.border(.init(hexString: "#D6DEE6"), borderWidth: 1, cornerRadius: 8)
        return r
    }()
    
    lazy var iconImageView:  UIImageView = {
        let r = UIImageView()
        return r
    }()
    lazy var paymentNameLabel:  UILabel = {
        let r = UILabel()
        r.font = .mediumFont(16)
        r.textColor = .black333
        return r
    }()
    lazy var userNameLabel:  UILabel = {
        let r = UILabel()
        r.font = .regularFont(12)
        r.textColor = .black999
        return r
    }()
    
    
    
    lazy var numberLabel: UILabel = {
        let r = UILabel()
        r.font = .regularFont(14)
        r.textColor = .black666
        r.textAlignment = .left
        return r
    }()
    
    lazy var selectStatusImageView: UIImageView = {
        let r = UIImageView(image: UIImage(named: "mine_payment_method_btn_select_icon"))
        r.hide()
        return r
    }()
}

