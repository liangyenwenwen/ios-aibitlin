//
//  AuthorizedLoginAlertView.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2025/4/7.
//  Copyright © 2025 rentsoft. All rights reserved.
//

import MMBAlertsPickers
import OUICore
import ProgressHUD
import RxCocoa
import RxSwift
import TangramKit
import UIKit
class AuthorizedLoginAlertView: TGLinearLayout {
    var h5DetailInfo:h5Model?
    var authLoginAction: (() -> ())!
    var cancleAuthLoginAction: (() -> ())!
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
        backgroundColor = .colorBackgroundAPP
        tg_width.equal(.fill)
        tg_height.equal(.wrap)
        tg_gravity = .horz.left
        tg_padding = UIEdgeInsets(top: 20, left: PADDING_OUTER, bottom: 10, right: PADDING_OUTER)
        addSubview(titlelabel)
        addSubview(descLabel)
        addSubview(centerContainer)
        addSubview(sureBtn)
        addSubview(cancleBtn)
        sureBtn.snp_remakeConstraints{ make in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.height.equalTo(44)
            make.bottom.equalTo(cancleBtn.snp_top).offset(-10)
        }
        cancleBtn.snp_remakeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.height.equalTo(44)
            make.bottom.equalTo(self).offset(-(kSafeAreaBottomHeight + 10))
        }
    }
    func updateContentUI(model:h5Model){
        h5DetailInfo = model
        //auth_login_cricle
//        for item in model.data?.extend?.app?.permission ?? [] {
//            if item == "userinfo"{
                centerContainer.addSubview(drawAuthLabel(attributedText: getAttribute(str:"获取您的ID、手机号码、邮箱")))
//            }else if item == "friend"{
                centerContainer.addSubview(drawAuthLabel(attributedText: getAttribute(str:"获取您的好友列表")))
//            }else if item == "group"{
                centerContainer.addSubview(drawAuthLabel(attributedText: getAttribute(str: "获取您的群组列表")))
//            }
//        }
        descLabel.text = "使用哎比邻登录" + (model.data?.info?.name ?? "") + "，将授权以下信息"
    }
    func getAttribute(str:String) -> NSMutableAttributedString{
        let attachment = NSTextAttachment()
        attachment.image = UIImage(named: "auth_login_cricle")
        attachment.bounds = CGRect(x: 0, y: 1.0, width: 8, height: 8)
        let str1 = " " + str
        let attributedString = NSMutableAttributedString(string: str1)
        let attachmentString = NSAttributedString(attachment: attachment)
        
//        attributedString.append(attachmentString)
        attributedString.insert(attachmentString, at: 0)
        return attributedString
    }
    private func drawAuthLabel(attributedText:NSMutableAttributedString)->UILabel{
        let r = UILabel()
        r.tg_top.equal(6)
        r.tg_width.equal(.fill)
        r.tg_height.equal(.wrap)
        r.textColor = .black666
        r.font = .regularFont(14)
        r.numberOfLines = 0
        r.attributedText = attributedText
        return r
    }
    lazy var titlelabel: UILabel = {
        let r = UILabel()
        r.tg_width.equal(.fill)
        r.tg_height.equal(.wrap)
        r.textColor = .black333
        r.font = .mediumFont(18)
        r.text = "授权登录"
        return r
    }()
    lazy var descLabel: UILabel = {
        let r = UILabel()
        r.tg_top.equal(15)
        r.tg_width.equal(.fill)
        r.tg_height.equal(.wrap)
        r.textColor = .black333
        r.font = .mediumFont(16)
        r.numberOfLines = 0
        return r
    }()
    lazy var centerContainer: TGLinearLayout = {
        let r = TGLinearLayout(.vert)
        r.tg_top.equal(2)
        r.tg_width.equal(.fill)
        r.tg_height.equal(120)
        return r
    }()
    lazy var sureBtn: QMUIButton = {
        let r = QMUIButton()
        r.backgroundColor = .primaryColor
        r.setTitleColor(.white, for: .normal)
        r.titleLabel?.font = .regularFont(18)
        r.setTitle("授权登录".localized(), for: .normal)
        r.corner(22)
        r.rx.tap.subscribe(onNext: { [weak self] in
            if self?.authLoginAction != nil {
                self?.authLoginAction()
            }
            GKCover.hide()
        }).disposed(by: rx.disposeBag)
        return r
    }()
    lazy var cancleBtn: QMUIButton = {
        let r = QMUIButton()
        r.setTitleColor(.black999, for: .normal)
        r.titleLabel?.font = .regularFont(18)
        r.setTitle("取消".localized(), for: .normal)
        r.corner(22)
        r.rx.tap.subscribe(onNext: { [weak self] in
            GKCover.hideWithoutAnimation()
            if self?.cancleAuthLoginAction != nil {
                self?.cancleAuthLoginAction()
            }
        }).disposed(by: rx.disposeBag)
        return r
    }()
}

