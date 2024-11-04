//
//  YFEmailLoginVC.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/10/28.
//  Copyright © 2024 rentsoft. All rights reserved.
//


import Foundation
import TangramKit
import RxSwift
import RxCocoa
import RxGesture
import BSText
import ProgressHUD


class YFEmailLoginVC: BaseLogicController {


    
    private var _areaCode = "+86"
    var isUseCode: Bool = true
    
    override func initViews() {
        super.initViews()
        initRelativeLayoutSafeArea()
        
        bindData()
        
        setBackGroundColor(.white)
        superHeaderContainerContainer.addSubview(chooseHeader)
        superHeaderContainerContainer.tg_height.equal(50)
        

        container.tg_padding = UIEdgeInsets(top: 0, left: PADDING_LARGE2, bottom: 0, right: PADDING_LARGE2)
        
        container.addSubview(appTitleLbl)
        container.addSubview(tipLbl)
        
        container.addSubview(emailView)
        container.addSubview(pwdView)
        container.addSubview(codeView)
 
        container.addSubview(loginBtn)

        
    }

    lazy var chooseHeader: YFAibitlinHomeChooseHeaderView = {
        let r = YFAibitlinHomeChooseHeaderView(headerType: .login)
        r.tg_width.equal(.fill)
        r.tg_height.equal(.fill)
        r.refreshUI()
        r.back = { [weak self] in
            self?.navigationController?.popViewController()
        }
        r.changeTypeClick =  { [weak self] currentIndex in
            self?.isUseCode = currentIndex == 0
            if currentIndex == 0 {
                self?.pwdView.hide()
                self?.codeView.show()
                self?.pwdView.textFieldView.text = ""
                self?.appTitleLbl.text = "验证码登录哎比邻".localized()
            } else {
                self?.pwdView.show()
                self?.codeView.hide()
                self?.codeView.textFieldView.text = ""
                self?.appTitleLbl.text = "密码登录哎比邻".localized()
            }
                
        }
        return r
    }()
    
    lazy var appTitleLbl: UILabel = {
        let r = ViewFactoryUtil.customBoldTilteLable("验证码登录哎比邻".localized(), font: TEXT_LARGE4, textColor: .colorOnSurface)
        r.tg_top.equal(84)
        return r
    }()
    
    lazy var tipLbl: UILabel = {
        let r = ViewFactoryUtil.sectionTilteLbael("登录你的账号、与全球用户无障碍聊天。".localized())
        r.tg_top.equal(appTitleLbl.tg_bottom, offset: 10)
        return r
    }()
    
    lazy var emailView: SuperSettingView = {
        let r = SuperSettingView.createInputPhone("手机号".localized(), placeholder: "请输入手机号".localized())
        r.loginUI()
        r.tg_top.equal(tipLbl.tg_bottom, offset: 36)
        r.tg_width.equal(.fill)
        r.changePhoneEmail(false)
        r.titleView.hide()
        return r
    }()

    
    lazy var pwdView: SuperSettingView = {
        let r = SuperSettingView.createInput("密码".localized())
        r.loginUI()
        r.tg_top.equal(tipLbl.tg_bottom, offset: 102)
        r.tg_width.equal(.fill)
        r.isPwd()
        r.titleView.hide()
        return r
    }()
    
    lazy var codeView: SuperSettingView = {
        let r = SuperSettingView.createInputAboutCode("Code".localized())
        r.loginUI()
        r.tg_top.equal(tipLbl.tg_bottom, offset: 102)
        r.tg_width.equal(.fill)
        r.codeBtn.addTarget(self, action: #selector(sendClick(_:)), for: .touchUpInside)
        r.isCode()
        r.titleView.hide()
        return r
    }()

    
    lazy var loginBtn: QMUIButton = {
        let r = ViewFactoryUtil.primaryHalfFilletButton()
        r.setTitle("登录".localized(), for: .normal)
        r.tg_top.equal(tipLbl.tg_bottom, offset: 188)
        r.addTarget(self, action: #selector(login), for: .touchUpInside)
        return r
    }()
  
    
    
    
    var email:String? {
        return emailView.textFieldView.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    var password: String? {
        return pwdView.textFieldView.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    var areaCode: String? {
        return _areaCode
    }
    
    var verificationCode: String? {
        return nil
    }
    
    override func bindData()  {
        
        Observable.combineLatest(emailView.textFieldView.rx.text.orEmpty, emailView.textFieldView.rx.text.orEmpty, codeView.textFieldView.rx.text.orEmpty) { [self] in
            if isUseCode {
                
                return $0.count > 1  && $1.count >= 0 && $2.count >= 1
            } else {
                return $0.count > 1  && $1.count > 1 && $2.count >= 0
            }
        }
        .bind(to: loginBtn.rx.isEnabled)
        .disposed(by: rx.disposeBag)

    }

    
}


extension YFEmailLoginVC {
    
    @objc func sendClick(_ sender: QMUIButton) {
//        requestCode()
    }
    
    
    @objc func chooseDelegate(_ btn: QMUIButton)  {
        btn.isSelected = !btn.isSelected
    }
    
    @objc func login() {
//        print(useType!)
        print(#function)
    }

    
    
 
    
}




