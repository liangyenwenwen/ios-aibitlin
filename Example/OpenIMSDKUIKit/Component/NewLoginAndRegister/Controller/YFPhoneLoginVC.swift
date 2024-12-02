//
//  YFPhoneLoginVC.swift
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


class YFPhoneLoginVC: BaseLogicController {


    
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
        
        container.addSubview(phoneView)
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
//                self?.appTitleLbl.text = "验证码登录OTC+IM".localized()
            } else {
                self?.pwdView.show()
                self?.codeView.hide()
                self?.codeView.textFieldView.text = ""
//                self?.appTitleLbl.text = "密码登录OTC+IM".localized()
            }
                
        }
        return r
    }()
    
    lazy var appTitleLbl: UILabel = {
        let r = ViewFactoryUtil.customBoldTilteLable("使用手机登录".localized(), font: TEXT_LARGE4, textColor: .colorOnSurface)
        r.tg_top.equal(84)
        return r
    }()
    
    lazy var tipLbl: UILabel = {
        let r = ViewFactoryUtil.sectionTilteLbael("登录你的账号、与全球用户无障碍聊天。".localized())
        r.tg_top.equal(appTitleLbl.tg_bottom, offset: 10)
        return r
    }()
    
    lazy var phoneView: SuperSettingView = {
        let r = SuperSettingView.createInputPhone("手机号".localized(), placeholder: "请输入手机号".localized())
        r.loginUI()
        r.tg_top.equal(tipLbl.tg_bottom, offset: 36)
        r.tg_width.equal(.fill)
        r.phoneCodeLbl.text = _areaCode
        let tap = UITapGestureRecognizer(target: self, action: #selector(changePhoneArea))
        r.phoneCodeView.addGestureRecognizer(tap)
        r.changePhoneEmail(true)
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
  
    
    
    
    var phone:String? {
        return phoneView.textFieldView.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    var password: String? {
        return pwdView.textFieldView.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    var areaCode: String? {
        return _areaCode
    }
    
    var verificationCode: String? {
        return codeView.textFieldView.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    override func bindData()  {
        
        Observable.combineLatest(phoneView.textFieldView.rx.text.orEmpty, pwdView.textFieldView.rx.text.orEmpty, codeView.textFieldView.rx.text.orEmpty) { [self] in
            if isUseCode {
                
                return $0.count > 1  && $1.count >= 0 && $2.count >= 1
            } else {
                return $0.count > 1  && $1.count > 7 && $2.count >= 0
            }
        }
        .bind(to: loginBtn.rx.isEnabled)
        .disposed(by: rx.disposeBag)

    }
    deinit {
        //保证定时器释放
        CountDownUtil.cancel()
        print(#file)
    }
    
}


extension YFPhoneLoginVC {
    

    @objc func changePhoneArea()  {
        let alert = UIAlertController(style: .actionSheet, title: "")
        alert.addLocalePicker(type: .phoneCode, chooseTitle: "choose".localized(),searchStr: "搜索".localized()) {[weak self] info in
            // action with selected object
            guard let phoneCode = info?.phoneCode else {return}
            self?._areaCode = phoneCode
            self?.phoneView.phoneCodeLbl.text = phoneCode
        }
        alert.addAction(title: "cancel".localized(), style: .cancel)
        self.present(alert, animated: true)
    }
    
    @objc func sendClick(_ sender: QMUIButton) {
        requestCode()
    }
    /// 请求验证码
    func requestCode() {
        view.endEditing(true)
        
        if let phone = phoneView.textFieldView.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines), phone.isEmpty {
            SuperToast.show(title: "plsEnterRightX".localizedFormat("phoneNumber".localized()))
            return
        }
        
        let invaitationCode = ""
        startCountDown()
        
        AccountViewModel.requestCode(phone:phone, areaCode: _areaCode, email: nil, invaitationCode: invaitationCode, useFor: .login) { [weak self] errCode, _ in
            ProgressHUD.dismiss()

            guard let sself = self else { return }
            if errCode != 0 {
                SuperToast.show(title: String(errCode).localized())
                self?.codeView.codeBtn.setTitle("Resend".localized(), for: .normal)
                self?.codeView.codeBtn.isEnabled = true
            }
        }
    }
    /// 开始倒计时
    func startCountDown() {
        CountDownUtil.countDown(60) { result in
            
            if result == 0 {
                self.codeView.codeBtn.setTitle("Resend".localized(), for: .normal)
                self.codeView.codeBtn.isEnabled = true
            } else {
                self.codeView.codeBtn.setTitle("ResendCount".localizedFormat(result), for: .normal)
            }
            
            self.codeView.codeBtn.sizeToFit()
        }
        
        // 禁用按钮
        codeView.codeBtn.isEnabled = false
    }
    @objc func chooseDelegate(_ btn: QMUIButton)  {
        btn.isSelected = !btn.isSelected
    }
    
    @objc func login() {
        //        print(useType!)
        //        print(#function)
        
        ProgressHUD.animate()
        var account: String?
        let tabController = UIApplication.shared.keyWindow?.rootViewController as? MainTabViewController
        let preAccount = AccountViewModel.perLoginAccount
        
        if phone != preAccount {
            tabController?.clearConversation()
        }
        
        AccountViewModel.loginDemo(phone: phone,
                                   account: account,
                                   email:nil,
                                   psw: isUseCode ? nil : password,
                                   verificationCode: isUseCode ? verificationCode : nil,
                                   areaCode: areaCode!,LoginType: isUseCode ? 1:2) {[weak self] (errCode, errMsg) in
            
            
            if errMsg != nil {
                ProgressHUD.dismiss()
                SuperToast.show(title: String(errCode).localized())
            } else {
                AccountViewModel.savePreLoginAccount(self?.phone)
                tabController?.loginSuccess(dismiss: true)
            }
        }
        
    }
    
}


