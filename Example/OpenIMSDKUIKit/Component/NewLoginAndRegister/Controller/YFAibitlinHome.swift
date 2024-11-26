//
//  YFAibitlinHome.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/10/28.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Foundation
import TangramKit
import BSText
import UIKit
import IQKeyboardManagerSwift

class YFAibitlinHome: BaseLogicController {
    
//    var loginArr: [HomeLoginType] = [.phone, .email, .facebook, .apple, .google, .sacnCode]
//    var chinaArr: [HomeLoginType] = [.phone, .email, .apple, .sacnCode]
//    var isChina: Bool = false
    var loginArr: [HomeLoginType] = [.email,.phone,.register]
    var facebookView:YFAibitlinHomeLoginTypeView?
    var googleView:YFAibitlinHomeLoginTypeView?
    
    override func initViews() {
        super.initViews()
        setBackGroundColor(.white)
        initLinearLayoutSafeArea()
        container.tg_padding = UIEdgeInsets(top: 0, left: PADDING_LARGE_HOME, bottom: 0, right: PADDING_LARGE_HOME)
        container.tg_space = 14
        
        container.addSubview(appIcon)
        container.addSubview(tipLbl)
        
        
        
        for (index, type) in loginArr.enumerated() {
            let typeView = YFAibitlinHomeLoginTypeView.bulidWith(loginType: type)
            typeView.tag = 10000 + index
            typeView.selectBlock = { [weak self] type in
                if self?.chooseDelegateBtn.isSelected == false {
                    
                    let alertView = YFAibitlinAgreementAlert()
                    alertView.tg_width.equal(.fill)
                    alertView.tg_height.equal(.wrap)
//                    alertView.tg_centerY.equal(0)
                    alertView.tg_height.equal(230)
                    alertView.currentVC = self
                    alertView.agreementBlock = {
                        self?.chooseDelegate(self!.chooseDelegateBtn)
                        self?.loginTypeDidSelect(loginType: type)
                    }
                    GKCover.cover(from: self?.view, contentView: alertView, style: .translucent, showStyle: .center, showAnimStyle: .bottom, hideAnimStyle: .bottom, notClick: false)
                }else{
                    self?.loginTypeDidSelect(loginType: type)
                }
            }
            
            if type == .google {
                googleView = typeView
            }
            
            if type == .facebook {
                facebookView = typeView
            }
            
            container.addSubview(typeView)
        }
        
//        container.addSubview(thridView)
//       
//        
//        let lineView = UIView()
//        lineView.backgroundColor = .init(hexString: "#F5F5F5")
//        lineView.tg_width.equal(.fill)
//        lineView.tg_height.equal(1)
//        lineView.tg_top.equal(10)
//        container.addSubview(lineView)
        
        container.addSubview(forgotButton)
        
        superFooterContainerContainer.tg_padding = UIEdgeInsets(top: 0, left: PADDING_LARGE_HOME, bottom: 0, right: PADDING_LARGE_HOME)
        superFooterContainerContainer.addSubview(delegateView)
        superFooterContainer.backgroundColor  = .white
        
        IQKeyboardManager.shared.enable = true
        
//        refrehUI()
        
    }
    
    lazy var appIcon: UIImageView = {
        let r = UIImageView()
        r.tg_width.equal(100)
        r.tg_height.equal(44)
        r.tg_top.equal(116)
        r.tg_centerX.equal(0)
        r.image = .init(named: "app_icon_home")
        return r
    }()
    
    lazy var tipLbl: UILabel = {
        let r = UILabel()
        r.text = "登录你的账号、与全球用户无障碍聊天。".localized()
        r.numberOfLines = 0
        r.textColor = .init(hexString: "#999999")
        r.font = .mediumFont(14)
        r.tg_top.equal(10)
        r.tg_bottom.equal(40)
        r.tg_left.equal(27)
        r.tg_right.equal(-27)
        r.tg_width.equal(.wrap)
        r.tg_height.equal(.wrap)
        return r
    }()
    
    lazy var thridView: YFAibitlinHomeLoginThridView = {
        let r = YFAibitlinHomeLoginThridView()
        r.tg_top.equal(20)
        r.selectBlock = { [weak self] type in
            self?.loginTypeDidSelect(loginType: type)
        }
        return r
    }()
    
    // MARK: - 张亚飞打的标记 添加找回密码
    lazy var forgotButton: UIButton = {
        
        let r = ViewFactoryUtil.linkButton("忘记密码".localized())
        r.tg_right.equal(0)
        r.setTitleColor(.primaryColor, for: .normal)
        r.rx.tap.subscribe(onNext: { [unowned self] _ in
            toForgotPassword()
        }).disposed(by: rx.disposeBag)
        return r

    }()
    
    
    lazy var delegateView: TGLinearLayout = {
        let r = TGLinearLayout(.horz)
        r.tg_height.equal(.wrap)
        r.tg_width.equal(.fill)
//        r.tg_bottom.equal(40)

        r.tg_space = PADDING_SMALL
        r.clipsToBounds = true
        
        r.addSubview(chooseDelegateBtn)

        r.addSubview(agreementView)
        return r
    }()
    
    lazy var agreementView: BSLabel = {
        let r = BSLabel()
        r.tg_top.equal(4)
        r.tg_width.equal(.fill)
        r.tg_height.equal(.wrap)
        r.textAlignment = .left
        r.numberOfLines = 0
        r.isUserInteractionEnabled = true
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 3 // 自定义行间距值
        let attributes: [NSAttributedString.Key: Any] = [
            .paragraphStyle: paragraphStyle,
        ]
        
        let agreementString = "我已阅读并同意AIbitlin《隐私协议》《注册协议》".localized()
        let agreeStr = NSMutableAttributedString(string: agreementString, attributes: attributes)
        agreeStr.bs_font = .systemFont(ofSize: TEXT_MEDDLE)
        agreeStr.bs_color = .placeholder
        
        
        // MARK: - 张亚飞打的标记  点击协议内容切换是否同意协议
        var range = agreementString.range(of: "我已阅读并同意AIbitlin《隐私协议》《注册协议》".localized())!
        agreeStr.bs_set(textHighlightRange: agreementString.nsRange(from: range), color: .placeholder, backgroundColor: nil) { [weak self] _, _, _, _ in
            
            if self?.chooseDelegateBtn != nil  {
                self?.chooseDelegateBtn.isSelected = !(self?.chooseDelegateBtn.isSelected)!
            }
            
        }
        
        
        range = agreementString.range(of: "《隐私协议》".localized())!
        agreeStr.bs_set(textHighlightRange: agreementString.nsRange(from: range), color: .primaryColor, backgroundColor: nil) { [weak self] containerView, text, range, rect in
//            ProgressHUD.succeed("隐私协议")
            
            let language = String.getCurrentLanguage()
            if language.starts(with: "zh")  {
                SuperWebController.start((self?.navigationController!)!, uri: "https://deal.aibitlin.com/#/pages/privacy/index?lang=zh")
            } else if language.starts(with: "th"){
                SuperWebController.start((self?.navigationController!)!, uri: "https://deal.aibitlin.com/#/pages/privacy/index?lang=Thai")
            } else {
                SuperWebController.start((self?.navigationController!)!, uri: "https://deal.aibitlin.com/#/pages/privacy/index?lang=en")
            }
            

        }
        
        range = agreementString.range(of: "《注册协议》".localized())!
        agreeStr.bs_set(textHighlightRange: agreementString.nsRange(from: range), color: .primaryColor, backgroundColor: nil) { [weak self]  containerView, text, range, rect in

            let language = String.getCurrentLanguage()
            if language.starts(with: "zh")  {
                SuperWebController.start((self?.navigationController!)!, uri: "https://deal.aibitlin.com/#/pages/registration/index?lang=zh")
            } else if language.starts(with: "th"){
                SuperWebController.start((self?.navigationController!)!, uri: "https://deal.aibitlin.com/#/pages/registration/index?lang=Thai")
            } else {
                SuperWebController.start((self?.navigationController!)!, uri: "https://deal.aibitlin.com/#/pages/registration/index?lang=en")
            }
        }
       
        r.attributedText = agreeStr
        
        return r
    }()
    
    
    lazy var chooseDelegateBtn: QMUIButton = {
        let r = ViewFactoryUtil.imageBtn(R.image.checked()!, 35)
        r.setImage(R.image.checked()!, for: .selected)
        r.setImage(R.image.check()!, for: .normal)
        r.tg_top.equal(-5)
        r.addTarget(self, action: #selector(chooseDelegate(_:)), for: .touchUpInside)
//        r.isSelected = UserDefaults.standard.string(forKey: "AppAgreementSelectStatus") as Bool ?? false
        r.isSelected = UserDefaults.standard.bool(forKey: "AppAgreementSelectStatus")

        return r
    }()
    
}

extension YFAibitlinHome {
    
    @objc func chooseDelegate(_ btn: QMUIButton)  {
        btn.isSelected = !btn.isSelected
        UserDefaults.standard.set(btn.isSelected, forKey: "AppAgreementSelectStatus")
    }
    
    func loginTypeDidSelect(loginType: HomeLoginType) {
        print(loginType.titleName)
        switch loginType {
        case .phone:
            phoneLoginAction()
        case .email:
            emailLoginAction()
        case .register:
            registerAction()
        default:
            SuperToast.show(title: "开发中".localized())
        }
    }
    
//    func refrehUI() {
//        if isChina {
//            facebookView?.hide()
//            googleView?.hide()
//            thridView.show()
//        } else {
//            facebookView?.show()
//            googleView?.show()
//            thridView.hide()
//        }
//    }
    func phoneLoginAction() {
        gotoController(YFPhoneLoginVC.self)
    }
    
    func emailLoginAction() {
        gotoController(YFEmailLoginVC.self)
    }
    
    func toForgotPassword() {
        gotoController(YFRetrievePasswordVC.self)
    }
    func registerAction(){
        let vc = YFNewRegisterVC()
        vc.useType = .usePhone
        self.navigationController?.pushViewController(vc, animated: true)
//        gotoController(vc)
//        
//        gotoController(YFNewRegisterVC.self)
    }
    
}
