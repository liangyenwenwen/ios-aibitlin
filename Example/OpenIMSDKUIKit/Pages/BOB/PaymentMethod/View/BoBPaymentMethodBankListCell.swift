//
//  BoBPaymentMethodBankListCell.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/11/25.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Foundation
class BoBPaymentMethodBankListCell: UITableViewCell {
    var editBlock:(()->Void)!
    var deleteBlock:(()->Void)!
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        accessoryType = .disclosureIndicator
        contentView.backgroundColor = .colorBackgroundAPP
        contentView.addSubview(bankContentView)
        bankContentView.addSubview(bankIcon)
        bankContentView.addSubview(bankNameLabel)
        bankContentView.addSubview(nameLabel)
        bankContentView.addSubview(bankNumberLabel)
        bankContentView.addSubview(editBtn)
        bankContentView.addSubview(deleteBtn)
        bankContentView.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.top.equalTo(0)
            make.bottom.equalTo(-12)
        }
        bankIcon.snp_makeConstraints { make in
            make.left.equalTo(15)
            make.top.equalTo(16)
            make.width.height.equalTo(24)
        }
        bankNameLabel.snp_makeConstraints { make in
            make.left.equalTo(bankIcon.snp_right).offset(8)
            make.centerY.equalTo(bankIcon.snp_centerY)
            make.right.equalTo(nameLabel.snp_left).offset(-10)
        }
        nameLabel.snp_makeConstraints { make in
            make.right.equalTo(-20)
            make.centerY.equalTo(bankIcon.snp_centerY)
        }
        bankNumberLabel.snp_makeConstraints { make in
            make.left.equalTo(bankIcon)
            make.right.equalTo(nameLabel)
            make.centerY.equalTo(bankContentView.snp_centerY)
        }
        editBtn.snp_makeConstraints { make in
            make.left.equalTo(bankIcon)
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
    lazy var bankContentView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.corner(8)
        return v
    }()
    lazy var bankIcon: UIImageView = {
        let v = UIImageView()
        v.corner(4)
        return v
    }()
    lazy var bankNameLabel: UILabel = {
        let v = UILabel()
        v.font = UIFont(name: "PingFangSC-Regular", size: 18)
        v.textColor = .black333
        return v
    }()

    let nameLabel: UILabel = {
        let v = UILabel()
        v.font = UIFont(name: "PingFangSC-Regular", size: 16)
        v.textColor = .black333
        return v
    }()
    lazy var bankNumberLabel: UILabel = {
        let v = UILabel()
        v.font = UIFont(name: "PingFangSC-Medium", size: 24)
        v.textColor = .black333
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
