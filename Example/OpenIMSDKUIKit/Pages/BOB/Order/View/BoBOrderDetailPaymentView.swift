//
//  BoBOrderDetailPaymentView.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/12/25.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Foundation
import OUICore
import TangramKit
class BoBOrderDetailPaymentView: TGLinearLayout {
    var chooseRedPacketTypeBlock:((_ typeTitle:String,_ typeIndex:Int)->())!
    init() {
        super.init(frame: .zero, orientation: .vert)
        innerInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        innerInit()
    }
    
    func innerInit() {
        tg_width.equal(.fill)
        tg_height.equal(.wrap)
    }
    func bindData(type:Int){
        if type == 1{
            addSubview(bankView)
        }else if type == 2{
            addSubview(aliPayView)
        }else if type == 3{
            addSubview(weixinPayView)
        }
    }
    lazy var bankView: UIView = {
        let r = UIView()
        r.tg_top.equal(0)
        r.tg_left.equal(0)
        r.tg_right.equal(0)
        r.tg_height.equal(90)
        r.backgroundColor = .init(hexString: "#EAF5FF")
        r.border(.init(hexString: "#BEDFFF"),borderWidth: 1,cornerRadius: 8)
        r.addSubview(bankIcon)
        r.addSubview(bankName)
        r.addSubview(bankNumber)
        r.addSubview(bankUserName)
        bankIcon.snp_makeConstraints { make in
            make.top.equalTo(19)
            make.left.equalTo(22)
            make.width.height.equalTo(30)
        }
        bankName.snp_makeConstraints { make in
            make.top.equalTo(14)
            make.left.equalTo(bankIcon.snp_right).offset(14)
            make.height.equalTo(18)
            make.right.equalTo(-22)
        }
        bankNumber.snp_makeConstraints { make in
            make.top.equalTo(bankName.snp_bottom).offset(4)
            make.left.right.equalTo(bankName)
            make.height.equalTo(26)
        }
        bankNumber.snp_makeConstraints { make in
            make.bottom.equalTo(-16)
            make.left.right.equalTo(bankName)
            make.height.equalTo(18)
        }
        return r
    }()
    private lazy var bankIcon: UIImageView = {
        let r = UIImageView()
        
        return r
    }()
    private lazy var bankName: UILabel = {
        let r = UILabel()
        r.textColor = .black333
        r.font = .mediumFont(16)
        return r
    }()
    private lazy var bankNumber: UILabel = {
        let r = UILabel()
        r.textColor = .black333
        r.font = .regularFont(14)
        return r
    }()
    private lazy var bankUserName: UILabel = {
        let r = UILabel()
        r.textColor = .black333
        r.font = .regularFont(16)
        return r
    }()
    lazy var aliPayView: orderDetailPayView = {
        let r = orderDetailPayView()
        r.tg_top.equal(0)
        r.tg_left.equal(0)
        r.tg_right.equal(0)
        r.tg_height.equal(162)
        r.backgroundColor = .init(hexString: "#EAF5FF")
        r.border(.init(hexString: "#BEDFFF"),borderWidth: 1,cornerRadius: 8)
        r.userNameView.buyCountTitleLabel.text = "收款人"
        r.userNickNameView.buyCountTitleLabel.text = "支付宝昵称"
        r.numberView.buyCountTitleLabel.text = "支付宝账号"
        return r
    }()
    lazy var weixinPayView: orderDetailPayView = {
        let r = orderDetailPayView()
        r.tg_top.equal(0)
        r.tg_left.equal(0)
        r.tg_right.equal(0)
        r.tg_height.equal(162)
        r.backgroundColor = .init(hexString: "#EAF5FF")
        r.border(.init(hexString: "#BEDFFF"),borderWidth: 1,cornerRadius: 8)
        r.userNameView.buyCountTitleLabel.text = "收款人"
        r.userNickNameView.buyCountTitleLabel.text = "微信昵称"
        r.numberView.hide()
        return r
    }()
}
class orderDetailPayView: TGLinearLayout {
    init() {
        super.init(frame: .zero, orientation: .horz)
        innerInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        innerInit()
    }
    
    func innerInit() {
        tg_width.equal(.fill)
        tg_height.equal(.wrap)
        tg_space = PADDING_MEDDLE
        tg_gravity = .horz.between
        tg_padding = UIEdgeInsets(top: PADDING_OUTER, left: PADDING_OUTER, bottom: PADDING_OUTER, right: PADDING_OUTER)
        addSubview(leftView)
        addSubview(rightView)
    }
    lazy var leftView: UIView = {
        let r = UIView()
        r.tg_width.equal(130)
        r.tg_right.equal(130)
        r.addSubview(payIcon)
        r.addSubview(icon)
        payIcon.snp_makeConstraints { make in
            make.left.right.top.bottom.equalTo(r)
        }
        icon.snp_makeConstraints { make in
            make.right.bottom.equalTo(-6)
            make.width.height.equalTo(24)
        }
        let tap = UITapGestureRecognizer()
        tap.rx.event.subscribe { [weak self] _ in
            
        }.disposed(by: rx.disposeBag)
        r.addGestureRecognizer(tap)
        return r
    }()
    lazy var payIcon: UIImageView = {
        let r = UIImageView()
        r.corner(8)
        return r
    }()
    lazy var icon: UIImageView = {
        let r = UIImageView(image: UIImage(named: "order_detail_qrcode_big_icon"))
        return r
    }()
    lazy var rightView: TGLinearLayout = {
        let r = TGLinearLayout(.vert)
        r.tg_top.equal(0)
        r.tg_left.equal(12)
        r.tg_right.equal(0)
        r.tg_height.equal(.wrap)
        r.addSubview(userNameView)
        r.addSubview(userNickNameView)
        r.addSubview(numberView)
        r.addSubview(saveBtn)
        saveBtn.snp_makeConstraints { make in
            make.left.bottom.equalTo(0)
            make.width.equalTo(104)
            make.height.equalTo(32)
        }
        return r
    }()
    lazy var userNameView: buyAndSellTitleView = {
        let r = buyAndSellTitleView()
        r.tg_top.equal(0)
        r.tg_left.equal(0)
        r.tg_right.equal(0)
        r.tg_height.equal(16)
        return r
    }()
    lazy var userNickNameView: buyAndSellTitleView = {
        let r = buyAndSellTitleView()
        r.tg_top.equal(0)
        r.tg_left.equal(0)
        r.tg_right.equal(0)
        r.tg_height.equal(16)
        return r
    }()
    lazy var numberView: buyAndSellTitleView = {
        let r = buyAndSellTitleView()
        r.tg_top.equal(0)
        r.tg_left.equal(0)
        r.tg_right.equal(0)
        r.tg_height.equal(16)
        return r
    }()
    lazy var saveBtn: QMUIButton = {
        let r = ViewFactoryUtil.linkButton("保存到相册")
        r.setTitleColor(.white, for: .normal)
        r.titleLabel?.font = .mediumFont(14)
        r.backgroundColor = .primaryColor
        r.corner(16)
        r.rx.tap.subscribe(onNext: { [weak self] in
            
        }).disposed(by: rx.disposeBag)
        return r
    }()
    
}
