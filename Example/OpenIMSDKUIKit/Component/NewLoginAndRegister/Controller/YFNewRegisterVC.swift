//
//  YFNewRegisterVC.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/10/28.
//  Copyright © 2024 rentsoft. All rights reserved.
//


import ProgressHUD
import RxCocoa
import RxGesture
import RxSwift
import TangramKit
import UIKit
import BSText
import GTSDK


class YFNewRegisterVC: BaseLogicController {
    /// 使用邮箱 或者手机号
    var useType: MyStyle = .useEmail
    var phoneStr = ""
    var emailStr = ""
    var _areaCode = "+86"

    override func initViews() {
        super.initViews()
     
        initRelativeLayoutSafeArea()
        
        setBackGroundColor(.white)

        superHeaderContainerContainer.addSubview(chooseHeader)
        superHeaderContainerContainer.tg_height.equal(50)
        
        container.tg_padding = UIEdgeInsets(top: 0, left: PADDING_LARGE2, bottom: 0, right: PADDING_LARGE2)
        
        container.addSubview(appTitleLbl)
        container.addSubview(emailView)
        container.addSubview(phoneView)
        container.addSubview(codeView)
        container.addSubview(codeTipLbl)
        container.addSubview(registerBtn)
        
        bindData()
        if useType == .usePhone{
            chooseHeader.currentIndex = 1
            chooseHeader.refreshUI()
            phoneView.show()
            emailView.hide()
            codeTipLbl.hide()
            registerBtn.tg_top.equal(codeView.tg_bottom, offset: 30)
        }
    }

    lazy var chooseHeader: YFAibitlinHomeChooseHeaderView = {
        let r = YFAibitlinHomeChooseHeaderView(headerType: .register)
        r.tg_width.equal(.fill)
        r.tg_height.equal(.fill)
        r.refreshUI()
        r.back = { [weak self] in
            self?.navigationController?.popViewController()
        }
        r.changeTypeClick =  { [weak self] currentIndex in
            if currentIndex == 0 {
                self?.useType = .useEmail
//                self?.appTitleLbl.text = "使用邮箱注册688".localized()
                self?.phoneView.hide()
                self?.emailView.show()
                self?.codeTipLbl.show()
                self?.registerBtn.tg_top.equal(self?.codeTipLbl.tg_bottom, offset: 20)
                self?.view.layoutIfNeeded()
            } else {
                self?.useType = .usePhone
//                self?.appTitleLbl.text = "使用手机号注册688".localized()
                self?.phoneView.show()
                self?.emailView.hide()
                self?.codeTipLbl.hide()
                self?.registerBtn.tg_top.equal(self?.codeView.tg_bottom, offset: 30)
                self?.view.layoutIfNeeded()
            }
            
            self?.codeView.textView.text = ""
        }
        return r
    }()
    
    lazy var appTitleLbl: UILabel = {
        let r = ViewFactoryUtil.customBoldTilteLable("Create a new account".localized(), font: TEXT_LARGE4, textColor: .black333)
        r.tg_top.equal(84)
        r.font = .semiboldFont(24)
        r.textColor = .black333
        return r
    }()
    
    lazy var phoneView: SuperSettingView = {
        let r = SuperSettingView.createInputPhone("手机号".localized(), placeholder: "请输入手机号".localized())
        r.loginUI()
        r.tg_top.equal(appTitleLbl.tg_bottom, offset: 36)
        r.tg_width.equal(.fill)
        r.phoneCodeLbl.text = _areaCode
        r.textFieldView.text = phoneStr
        r.hide()
        r.changePhoneEmail(true)
        let tap = UITapGestureRecognizer(target: self, action: #selector(changePhoneArea))
        r.phoneCodeView.addGestureRecognizer(tap)
        return r
    }()
    lazy var emailView: SuperSettingView = {
        let r = SuperSettingView.createInputPhone("邮箱".localized(), placeholder: "请输入邮箱".localized())
        r.loginUI()
        r.tg_top.equal(appTitleLbl.tg_bottom, offset: 36)
        r.tg_width.equal(.fill)
        r.textFieldView.text = emailStr
        r.changePhoneEmail(false)
        r.titleView.hide()
        return r
    }()

    
    lazy var codeView: SuperSettingView = {
        let r = SuperSettingView.createInputAboutCode("Code".localized())
        r.loginUI()
        r.tg_top.equal(appTitleLbl.tg_bottom, offset: 102)
        r.tg_width.equal(.fill)
        r.codeBtn.addTarget(self, action: #selector(sendClick(_:)), for: .touchUpInside)
        r.isCode()
        r.titleView.hide()
        return r
    }()
    lazy var codeTipLbl: UILabel = {
        let r = ViewFactoryUtil.sectionTilteLbael()
        r.text = "codeFormat".localized()
        r.tg_top.equal(codeView.tg_bottom).offset(10)
        r.numberOfLines = 0
        return r
    }()
    lazy var registerBtn: QMUIButton = {
        let r = ViewFactoryUtil.primaryHalfFilletButton()
        r.setTitle("注册".localized(), for: .normal)
        r.tg_top.equal(codeTipLbl.tg_bottom, offset: 20)
        r.addTarget(self, action: #selector(register), for: .touchUpInside)
        return r
    }()
    
    var phone: String? {
        return phoneView.textFieldView.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    var email: String?{
        return emailView.textFieldView.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    override func bindData() {
        Observable.combineLatest(emailView.textFieldView.rx.text.orEmpty,phoneView.textFieldView.rx.text.orEmpty, codeView.textFieldView.rx.text.orEmpty) {
            if self.useType == .usePhone {
                $0.count >= 0 && $1.count > 0 && $2.count > 0
            }else{
                $0.count > 0 && $1.count >= 0 && $2.count > 0
            }
            
        }
        .bind(to: registerBtn.rx.isEnabled)
        .disposed(by: rx.disposeBag)
        
        
    }
    deinit {
        //保证定时器释放
        CountDownUtil.cancel()
        print(#file)
    }
}

extension YFNewRegisterVC {
    /// 请求验证码
    func requestCode() {
        view.endEditing(true)
        if useType == .usePhone {
            if phone!.isEmpty{
                SuperToast.show(title: "plsEnterRightX".localizedFormat("phoneNumber".localized()))
                return
            }
        } else {
            if email!.isEmpty{
                SuperToast.show(title: "plsEnterRightX".localizedFormat("email".localized()))
                return
            }
        }
        let invaitationCode = ""
        startCountDown()
        
        AccountViewModel.requestCode(phone: useType == .usePhone ? phone : nil, areaCode: _areaCode, email: useType == .useEmail ? email : nil, invaitationCode: invaitationCode, useFor: .register) { [weak self] errCode, _ in

            guard let sself = self else { return }
            if errCode != 0 {
//                ProgressHUD.error(String(errCode).localized())
                SuperToast.show(title: String(errCode).localized())
                CountDownUtil.cancel()
                self?.codeView.codeBtn.setTitle("Resend".localized(), for: .normal)
                self?.codeView.codeBtn.isEnabled = true
            } else {
                ProgressHUD.dismiss()
            }
            ProgressHUD.dismiss()
        }
    }
    
    @objc func sendClick(_ sender: QMUIButton) {
        requestCode()
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
    
    @objc func changePhoneArea() {
        let alert = UIAlertController(style: .actionSheet, title: "")
        alert.addLocalePicker(type: .phoneCode, chooseTitle: "choose".localized(),searchStr: "搜索".localized()) { [weak self] info in
            // action with selected object
            guard let phoneCode = info?.phoneCode else { return }
            self?._areaCode = phoneCode
            self?.phoneView.phoneCodeLbl.text = phoneCode
        }
        
        alert.addAction(title: "cancel".localized(), style: .cancel)
        present(alert, animated: true)
    }
    
    @objc func gotoRegister() {
        print(#function)
        gotoController(YFRegisterVC())
    }
    
    @objc func gotoRegisterDelegate() {
        print(#function)
//        SuperWebController.start((self.navigationController!), uri: "http://bitswith.com/ys/#/userAgreement")
        if String.getCurrentLanguage().starts(with: "zh")  {
            SuperWebController.start((self.navigationController!), uri: "https://deal.aibitlin.com/#/pages/registration/index?lang=zh")
        } else if String.getCurrentLanguage().starts(with: "th") {
            SuperWebController.start((self.navigationController!), uri: "https://deal.aibitlin.com/#/pages/registration/index?lang=Thai")
        } else {
            SuperWebController.start((self.navigationController!), uri: "https://deal.aibitlin.com/#/pages/registration/index?lang=en")
        }
    }
    
    @objc func chooseDelegate(_ btn: QMUIButton) {
        btn.isSelected = !btn.isSelected
    }

    
    @objc func register() {
        toComplate()
    }
    
    /// 验证邀请码
    func toVerifyCode() {
        AccountViewModel.verifyCode(phone: useType == .usePhone ? phone : nil, areaCode: _areaCode, email: useType == .useEmail ? phone : nil, useFor: .register, verificationCode: "") { [weak self] errCode, _ in
            
            guard let self else { return }
            
            if errCode != 0 {
//                ProgressHUD.error(String(errCode).localized())
                SuperToast.show(title: String(errCode).localized())
            } else {
//                basicInfo["verCode"] = code
//                let vc = InputPasswordViewController(usedFor: usedFor, operateType: operateType)
//                vc.basicInfo = basicInfo
//                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    /// 完成注册
    func toComplate() {
        view.endEditing(true)
        ProgressHUD.animate()
        let tabController = UIApplication.shared.keyWindow?.rootViewController as? MainTabViewController
        AccountViewModel.registerAccount(phone: useType == .usePhone ? phone : nil,
                                         areaCode: _areaCode,
                                         verificationCode: codeView.inputText!,
                                         password: "",
                                         faceURL: "",
                                         nickName: "",
                                         email: useType == .useEmail ? email : nil,
                                         invitationCode: "",
                                         registerType:useType == .usePhone ? 1 : 2)
        { errCode, errMsg in
            
            if errMsg != nil {
                ProgressHUD.dismiss()
                SuperToast.show(title: String(errCode).localized())
            } else {
                AccountViewModel.loginIM(uid: AccountViewModel.baseUser.userID,
                                         imToken: AccountViewModel.baseUser.imToken,
                                         chatToken: AccountViewModel.baseUser.chatToken)
                { [weak self] _, _ in
                    
                    if let userID = AccountViewModel.userID {
                        GeTuiSdk.bindAlias(userID, andSequenceNum: "im")
                    }
                    UserDefaults.standard.setValue(self?.useType.rawValue, forKey: loginTypeKey)
                    UserDefaults.standard.synchronize()
                    AccountViewModel.savePreLoginAccount(self?.useType == .usePhone ? self?.phone : self?.email)
                    AccountViewModel.updateUserInfo(userID: AccountViewModel.userID!) { _, _ in
                        tabController?.loginSuccess(dismiss: true)
                    }
                }
            }
            
        }
    }
}

