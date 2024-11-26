//
//  BoBAddBankPaymentView.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/11/25.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Foundation
import TangramKit
import OUICore


class BoBAddBankPaymentView:TGLinearLayout {
    var chooseBankBlock:(()->Void)!

    init() {
        super.init(frame: .zero, orientation: .vert)
        initViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initViews()
    }

    
    func initViews()  {
        self.tg_width.equal(kScreenWidth-32)
        self.tg_height.equal(.wrap)
        addSubview(nameView)
        addSubview(ViewFactoryUtil.smallDivider())
        addSubview(tipView)
        addSubview(ViewFactoryUtil.smallDivider())
        addSubview(bankNumberView)
        addSubview(ViewFactoryUtil.smallDivider())
        addSubview(bankNameView)
        addSubview(ViewFactoryUtil.smallDivider())
        addSubview(bankSubView)
    }
    lazy var nameView: SuperSettingView = {
        let r = SuperSettingView.createInput("姓名*", placeholder: "请输入姓名")
        r.isMediumFont()
        r.titleView.changeColor(changeColorStr: "*")
        r.textFieldView.textAlignment = .right
        r.textFieldView.isUserInteractionEnabled = false
        r.needLimitLength(length: 50)
        r.textFieldView.tg_right.equal(-10)
        r.textFieldView.textColor = .black666
        r.textFieldView.font = UIFont(name: "PingFangSC-Regular", size: 16)
        return r
    }()
    lazy var tipView: UIView = {
       let r = UIView()
        r.backgroundColor = .white
        r.tg_width.equal(.fill)
        r.tg_height.equal(50)
        r.tg_top.equal(0)
        r.addSubview(tipLabel)
        tipLabel.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.top.equalTo(9)
        }
        return r
    }()
    lazy var tipLabel: UILabel = {
        let r = UILabel()
        r.font =  UIFont(name: "PingFangSC-Regular", size: 12)
        r.textColor = .black666
        r.numberOfLines = 0
        r.text = "姓名与实名认证一致，不可修改"
        return r
    }()
    lazy var bankNumberView: SuperSettingView = {
        let r = SuperSettingView.createInput("银行卡号*", placeholder: "请输入银行卡号")
        r.isMediumFont()
        r.titleView.changeColor(changeColorStr: "*")
        r.textFieldView.font = UIFont(name: "PingFangSC-Regular", size: 16)
        r.needLimitLength(length: 50)
        r.textFieldView.keyboardType = .asciiCapableNumberPad
        r.textFieldView.tg_right.equal(-10)
        r.textFieldView.textAlignment = .right
        r.textFieldView.textColor = .black666
        return r
    }()
    lazy var bankNameView: SuperSettingView = {
        let r = SuperSettingView.createInput("开户银行*", placeholder: "请输入开户银行",ishaveMore: true, click: { [weak self] data in
            if self?.chooseBankBlock != nil{
                self?.chooseBankBlock()
            }
        })
        r.isMediumFont()
        r.titleView.changeColor(changeColorStr: "*")
        r.textFieldView.textAlignment = .right
        r.textFieldView.isUserInteractionEnabled = false
        r.textFieldView.textColor = .black666
        r.textFieldView.font = UIFont(name: "PingFangSC-Regular", size: 16)
        r.needLimitLength(length: 50)
        r.moreIconView.tg_left.equal(0)
        r.tg_space = 0
        return r
    }()
    lazy var bankSubView: SuperSettingView = {
        let r = SuperSettingView.createInput("开户支行", placeholder: "请输入开户支行")
        r.textFieldView.textAlignment = .right
        r.isMediumFont()
        r.needLimitLength(length: 50)
        r.textFieldView.tg_right.equal(-10)
        r.textFieldView.textColor = .black666
        r.textFieldView.font = UIFont(name: "PingFangSC-Regular", size: 16)
        return r
    }()
    
    
}
