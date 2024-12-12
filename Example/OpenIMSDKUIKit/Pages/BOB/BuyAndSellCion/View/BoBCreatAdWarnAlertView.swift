//
//  BoBCreatAdWarnAlertView.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/12/11.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import MMBAlertsPickers
import OUICore
import RxCocoa
import RxSwift
import RxGesture
import TangramKit
import UIKit
class BoBCreatAdWarnAlertView: TGLinearLayout {
    init() {
        super.init(frame: .zero, orientation: .vert)
        innerInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        innerInit()
    }
    
    func innerInit() {
        corner(MEDDLE_RADIUS)
        tg_width.equal(.fill)
        tg_height.equal(.wrap)
//        tg_space = PADDING_MEDDLE
        tg_gravity = .horz.center
        tg_padding = UIEdgeInsets(top: 0, left: 0, bottom: 25, right: 0)
        backgroundColor = .white
        addSubview(warnIcon)
        addSubview(titleLabel)
        addSubview(contentLabel)
        addSubview(registerView)
        addSubview(realNameView)
        addSubview(realNameTimeView)
        addSubview(closeBtn)
    }
    
    lazy var warnIcon: UIImageView = {
        let r = UIImageView(image: UIImage(named: "mine_transfer_accounts_expire_icon"))
        r.tg_top.equal(40)
        r.tg_width.equal(40)
        r.tg_height.equal(40)
        return r
    }()
    lazy var titleLabel: UILabel = {
        let r = UILabel()
        r.tg_left.equal(16)
        r.tg_right.equal(16)
        r.tg_height.equal(.wrap)
        r.tg_top.equal(25)
        r.textColor = .black333
        r.font = .semiboldFont(18)
        r.numberOfLines = 0
        r.text = "您暂时无法发布广告"
        r.textAlignment = .center
        return r
    }()
    lazy var contentLabel: UILabel = {
        let r = UILabel()
        r.tg_left.equal(16)
        r.tg_right.equal(16)
        r.tg_top.equal(10)
        r.tg_height.equal(.wrap)
        r.textColor = .black999
        r.font = .regularFont(14)
        r.text = "为了营造良好的市场环境，您需要达到一定的条件才可以发布广告。"
        r.textAlignment = .center
        return r
    }()
    lazy var registerView: CreatWarnView = {
        let r = CreatWarnView()
        r.tg_left.equal(16)
        r.tg_right.equal(16)
        r.tg_top.equal(15)
        r.tg_height.equal(.wrap)
        r.backgroundColor = .init(hexString: "#D1F9EB")
        r.warnLabel.text = "注册时间>20天"
        r.contentLabel.text = "40天"
        r.icon.image = UIImage(named: "mine_buy_and_sell_cancreat_ad_icon")
        return r
    }()
    lazy var realNameView: CreatWarnView = {
        let r = CreatWarnView()
        r.tg_left.equal(16)
        r.tg_right.equal(16)
        r.tg_top.equal(8)
        r.tg_height.equal(.wrap)
        r.backgroundColor = .init(hexString: "#D1F9EB")
        r.warnLabel.text = "身份认证"
        r.contentLabel.text = ""
        r.icon.image = UIImage(named: "mine_buy_and_sell_cancreat_ad_icon")
        return r
    }()
    lazy var realNameTimeView: CreatWarnView = {
        let r = CreatWarnView()
        r.tg_left.equal(16)
        r.tg_right.equal(16)
        r.tg_top.equal(8)
        r.tg_height.equal(.wrap)
        r.backgroundColor =  .init(hexString: "#FFE8E8")
        r.warnLabel.text = "身份认证时间>20天"
        r.contentLabel.text = "9天"
        r.icon.image = UIImage(named: "mine_buy_and_sell_uncreat_ad_icon")
        return r
    }()
    
    lazy var closeBtn: QMUIButton = {
        let r = ViewFactoryUtil.linkButton("我知道了")
        r.tg_top.equal(17)
        r.tg_left.equal(65)
        r.tg_right.equal(65)
        r.tg_height.equal(46)
        r.setTitleColor(.white, for: .normal)
        r.titleLabel?.font = .mediumFont(16)
        r.backgroundColor = .primaryColor
        r.corner(23)
        r.rx.tap.subscribe(onNext: { [self] in
            GKCover.hideWithoutAnimation()
        }).disposed(by: rx.disposeBag)
        return r
    }()
}
class CreatWarnView: TGLinearLayout {
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
        tg_gravity = .horz.between
        tg_hspace = 15
        tg_padding = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        corner(8)
        addSubview(warnLabel)
        addSubview(rightView)
    }
    lazy var warnLabel: UILabel = {
        let r = UILabel()
        r.tg_left.equal(0)
        r.tg_width.equal(290-32-20-90-15)
        r.tg_height.equal(.wrap)
        r.textColor = .black333
        r.font = .regularFont(14)
        return r
    }()
    lazy var rightView: UIView = {
        let r = UIView()
        r.tg_width.equal(90)
        r.tg_height.equal(.fill)
        r.addSubview(icon)
        r.addSubview(contentLabel)
        icon.snp_makeConstraints { make in
            make.right.equalTo(0)
            make.centerY.equalTo(r)
            make.width.height.equalTo(12)
        }
        contentLabel.snp_makeConstraints { make in
            make.right.equalTo(icon.snp_left).offset(-5)
            make.centerY.equalTo(r)
            make.right.equalTo(r)
        }
        return r
    }()
    lazy var icon: UIImageView = {
        let r = UIImageView()
        
        return r
    }()
    lazy var contentLabel: UILabel = {
        let r = UILabel()
        r.textColor = .black333
        r.font = .regularFont(14)
        r.textAlignment = .right
        return r
    }()
}


