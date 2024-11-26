//
//  BoBPaymentMethodListCell.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/11/25.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Foundation
class BoBPaymentMethodListCell: UITableViewCell {
    var editBlock:(()->Void)!
    var deleteBlock:(()->Void)!
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        accessoryType = .disclosureIndicator
        contentView.backgroundColor = .colorBackgroundAPP
        contentView.addSubview(paymentContentView)
        paymentContentView.addSubview(paymentMethodIcon)
        paymentContentView.addSubview(paymentMethodLabel)
        paymentContentView.addSubview(nameLabel)
        paymentContentView.addSubview(nickNameLabel)
        paymentContentView.addSubview(qrCodeImageView)
        paymentContentView.addSubview(editBtn)
        paymentContentView.addSubview(deleteBtn)
        paymentContentView.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.top.equalTo(0)
            make.bottom.equalTo(-12)
        }
        paymentMethodIcon.snp_makeConstraints { make in
            make.left.equalTo(15)
            make.top.equalTo(16)
            make.width.height.equalTo(24)
        }
        paymentMethodLabel.snp_makeConstraints { make in
            make.left.equalTo(paymentMethodIcon.snp_right).offset(8)
            make.centerY.equalTo(paymentMethodIcon.snp_centerY)
            make.right.equalTo(qrCodeImageView.snp_left).offset(-10)
        }
        nameLabel.snp_makeConstraints { make in
            make.left.equalTo(paymentMethodIcon)
            make.centerY.equalTo(paymentContentView.snp_centerY)
        }
        nickNameLabel.snp_makeConstraints { make in
            make.left.equalTo(nameLabel.snp_right).offset(8)
            make.centerY.equalTo(nameLabel.snp_centerY)
            make.right.equalTo(paymentMethodLabel.snp_right)
        }
        qrCodeImageView.snp_makeConstraints { make in
            make.right.equalTo(-16)
            make.centerY.equalTo(paymentContentView.snp_centerY)
            make.width.height.equalTo(124)
        }
        editBtn.snp_makeConstraints { make in
            make.left.equalTo(paymentMethodIcon)
            make.width.height.equalTo(20)
            make.bottom.equalTo(-16)
        }
        deleteBtn.snp_makeConstraints { make in
            make.left.equalTo(editBtn.snp_right).offset(20)
            make.width.height.bottom.equalTo(editBtn)
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var paymentContentView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.corner(8)
        return v
    }()
    lazy var paymentMethodIcon: UIImageView = {
        let v = UIImageView()
        v.corner(4)
        return v
    }()
    lazy var paymentMethodLabel: UILabel = {
        let v = UILabel()
        v.font = UIFont(name: "PingFangSC-Regular", size: 18)
        v.textColor = .init(hexString: "#277FE6")
        return v
    }()

    let nameLabel: UILabel = {
        let v = UILabel()
        v.font = UIFont(name: "PingFangSC-Regular", size: 16)
        v.textColor = .black333
        return v
    }()
    lazy var nickNameLabel: UILabel = {
        let v = UILabel()
        v.font = UIFont(name: "PingFangSC-Regular", size: 13)
        v.textColor = .black333
        return v
    }()
    lazy var qrCodeImageView: UIImageView = {
        let v = UIImageView()
        return v
    }()
    lazy var editBtn: QMUIButton = {
        let r = ViewFactoryUtil.imageBtn(UIImage(named: "mine_payment_method_edit_icon")!)
        r.rx.tap.subscribe(onNext: { [self] in
            //编辑
            if editBlock != nil{
                editBlock()
            }
        }).disposed(by: rx.disposeBag)
        return r
    }()
    lazy var deleteBtn: QMUIButton = {
        let r = ViewFactoryUtil.imageBtn(UIImage(named: "mine_payment_method_delete_icon")!)
        r.rx.tap.subscribe(onNext: { [self] in
           //删除
            if deleteBlock != nil{
                deleteBlock()
            }
        }).disposed(by: rx.disposeBag)
        return r
    }()
}
