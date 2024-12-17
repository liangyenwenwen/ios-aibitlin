//
//  BoBFreeBuyAndSellCell.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/12/11.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Foundation
class BoBFreeBuyAndSellCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        self.backgroundColor = .colorBackgroundAPP
        contentView.backgroundColor = .clear
        contentView.addSubview(bgView)
        bgView.addSubview(shortNameLabel)
        bgView.addSubview(nameLabel)
        bgView.addSubview(saleResultLabel)
        bgView.addSubview(unitLabel)
        bgView.addSubview(freeMoneyLabel)
        bgView.addSubview(countTitleLabel)
        bgView.addSubview(countLabel)
        bgView.addSubview(limitTitleLabel)
        bgView.addSubview(limitCountLabel)
        bgView.addSubview(saleBtn)
        bgView.addSubview(paymentMethodType1)
        bgView.addSubview(paymentMethodType2)
        bgView.addSubview(paymentMethodType3)

        bgView.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.top.equalTo(0)
            make.bottom.equalTo(-12)
        }
        shortNameLabel.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.top.equalTo(14)
            make.width.height.equalTo(18)
        }
        nameLabel.snp_makeConstraints { make in
            make.left.equalTo(shortNameLabel.snp_right).offset(4)
            make.centerY.equalTo(shortNameLabel)
            make.right.equalTo(-16)
        }
        saleResultLabel.snp_makeConstraints { make in
            make.left.equalTo(shortNameLabel)
            make.top.equalTo(shortNameLabel.snp_bottom).offset(5)
            make.height.equalTo(16)
            make.right.equalTo(-110)
        }
        unitLabel.snp_makeConstraints { make in
            make.left.equalTo(shortNameLabel)
            make.bottom.equalTo(freeMoneyLabel)
            make.height.equalTo(13)
        }
        freeMoneyLabel.snp_makeConstraints { make in
            make.left.equalTo(unitLabel.snp_right)
            make.top.equalTo(saleResultLabel.snp_bottom).offset(14)
            make.right.equalTo(saleResultLabel)
            make.height.equalTo(20)
        }
        countTitleLabel.snp_makeConstraints { make in
            make.left.equalTo(shortNameLabel)
            make.top.equalTo(freeMoneyLabel.snp_bottom).offset(10)
            make.height.equalTo(15)
        }
        countLabel.snp_makeConstraints { make in
            make.left.equalTo(countTitleLabel.snp_right).offset(4)
            make.centerY.height.equalTo(countTitleLabel)
//            make.right.equalTo(freeMoneyLabel)
        }
        limitTitleLabel.snp_makeConstraints { make in
            make.left.equalTo(shortNameLabel)
            make.top.equalTo(countTitleLabel.snp_bottom).offset(5)
            make.height.equalTo(15)
        }
        limitCountLabel.snp_makeConstraints { make in
            make.left.equalTo(limitTitleLabel.snp_right).offset(4)
            make.centerY.height.equalTo(limitTitleLabel)
//            make.right.equalTo(freeMoneyLabel)
        }
        saleBtn.snp_makeConstraints { make in
            make.right.equalTo(-16)
            make.bottom.equalTo(limitTitleLabel)
            make.width.equalTo(80)
            make.height.equalTo(30)
        }
        paymentMethodType1.snp_makeConstraints { make in
            make.right.equalTo(saleBtn)
            make.bottom.equalTo(saleBtn.snp_top).offset(-6)
            make.height.equalTo(14)
            make.width.equalTo(84)
        }
        paymentMethodType2.snp_makeConstraints { make in
            make.left.right.height.equalTo(paymentMethodType1)
            make.bottom.equalTo(paymentMethodType1.snp_top).offset(-4)
        }
        paymentMethodType3.snp_makeConstraints { make in
            make.left.right.height.equalTo(paymentMethodType1)
            make.bottom.equalTo(paymentMethodType2.snp_top).offset(-4)
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
    
    lazy var shortNameLabel:  UILabel = {
        let v = UILabel()
        v.font = .lightFont(12)
        v.textColor = .white
        v.corner(9)
        v.textAlignment = .center
        return v
    }()
    lazy var nameLabel:  UILabel = {
        let v = UILabel()
        v.font = .mediumFont(14)
        v.textColor = .black333
        return v
    }()
    lazy var saleResultLabel:  UILabel = {
        let v = UILabel()
        v.font = .regularFont(12)
        v.textColor = .black999
        return v
    }()
    lazy var unitLabel: UILabel = {
        let v = UILabel()
        v.font = .mediumFont(13)
        v.textColor = .black333
        v.text = "￥"
        return v
    }()
    lazy var freeMoneyLabel: UILabel = {
        let v = UILabel()
        v.font = .mediumFont(24)
        v.textColor = .black333
        return v
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
    lazy var saleBtn: QMUIButton = {
        let r = ViewFactoryUtil.linkButton("出售")
        r.setTitleColor(.white, for: .normal)
        r.titleLabel?.font = .regularFont(12)
        r.backgroundColor = .init(hexString: "#EF5938")
        r.corner(15)
        r.rx.tap.subscribe(onNext: { [self] in
        }).disposed(by: rx.disposeBag)
        return r
    }()
    lazy var paymentMethodType1: PaymentMethodTypeView = {
        let r = PaymentMethodTypeView()
        r.hide()
        return r
    }()
    lazy var paymentMethodType2: PaymentMethodTypeView = {
        let r = PaymentMethodTypeView()
        r.hide()
        return r
    }()
    lazy var paymentMethodType3: PaymentMethodTypeView = {
        let r = PaymentMethodTypeView()
        r.hide()
        return r
    }()
}
class PaymentMethodTypeView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(paymentMethodNameLabel)
        addSubview(lineView)
        paymentMethodNameLabel.snp_makeConstraints { make in
            make.left.top.bottom.equalTo(0)
            make.right.equalTo(lineView.snp_left).offset(-4)
            
        }
        lineView.snp_makeConstraints { make in
            make.right.equalTo(0)
            make.width.equalTo(3)
            make.height.equalTo(10)
            make.centerY.equalTo(paymentMethodNameLabel)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   
    lazy var paymentMethodNameLabel: UILabel = {
        let r = UILabel()
        r.textColor = .black999
        r.font = .regularFont(12)
        r.textAlignment = .right
        return r
    }()
    lazy var lineView: UIView = {
        let r = UIView()
        r.corner(1.5)
        return r
    }()
}

