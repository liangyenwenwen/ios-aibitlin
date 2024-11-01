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

class YFNewRegisterVC: BaseLogicController {
    /// 使用邮箱 或者手机号
    var useType: MyStyle = .useEmail
    
    private var _areaCode = "+86"

    override func initViews() {
        super.initViews()
     
        initRelativeLayoutSafeArea()
        
        setBackGroundColor(.white)

        superHeaderContainerContainer.addSubview(chooseHeader)
        superHeaderContainerContainer.tg_height.equal(50)
        
        container.tg_padding = UIEdgeInsets(top: 0, left: PADDING_LARGE2, bottom: 0, right: PADDING_LARGE2)
        
        container.addSubview(appTitleLbl)
        container.addSubview(phoneView)
        container.addSubview(codeView)
        container.addSubview(pwdView)
        container.addSubview(pwdTipLbl)
        container.addSubview(rePwdView)
        container.addSubview(nicknameView)
        container.addSubview(registerBtn)

        
        bindData()
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
                self?.appTitleLbl.text = "使用邮箱注册哎比邻".localized()
                self?.phoneView.changePhoneEmail(false)
            } else {
                self?.useType = .usePhone
                self?.appTitleLbl.text = "使用手机号注册哎比邻".localized()
                self?.phoneView.changePhoneEmail(true)
            }
            
            self?.phoneView.textView.text = ""
            self?.codeView.textView.text = ""
            self?.pwdView.textView.text = ""
            self?.rePwdView.textView.text = ""
            self?.nicknameView.textView.text = ""
    
        }
        return r
    }()
    
    lazy var appTitleLbl: UILabel = {
        let r = ViewFactoryUtil.customBoldTilteLable("使用邮箱注册哎比邻".localized(), font: TEXT_LARGE4, textColor: .black333)
        r.tg_top.equal(84)
        r.font = .semiboldFont(24)
        r.textColor = .black333
        return r
    }()
    
    lazy var phoneView: SuperSettingView = {
        let r = SuperSettingView.createInputPhone("手机号", placeholder: "请输入手机号")
        r.loginUI()
        r.tg_top.equal(appTitleLbl.tg_bottom, offset: 36)
        r.tg_width.equal(.fill)
        r.phoneCodeLbl.text = _areaCode
        let tap = UITapGestureRecognizer(target: self, action: #selector(changePhoneArea))
        r.phoneCodeView.addGestureRecognizer(tap)
        r.changePhoneEmail(useType == .usePhone)
        return r
    }()

    
    lazy var codeView: SuperSettingView = {
        let r = SuperSettingView.createInputAboutCode("Code".localized())
        r.loginUI()
        r.tg_top.equal(appTitleLbl.tg_bottom, offset: 102)
        r.tg_width.equal(.fill)
        r.codeBtn.addTarget(self, action: #selector(sendClick(_:)), for: .touchUpInside)
        r.isCode()
        return r
    }()
    
    lazy var pwdView: SuperSettingView = {
        let r = SuperSettingView.createInput("输入密码".localized())
        r.loginUI()
        r.tg_top.equal(appTitleLbl.tg_bottom, offset: 168)
        r.tg_width.equal(.fill)
        r.isPwd()
        return r
    }()
    
   
    
    lazy var pwdTipLbl: UILabel = {
        let r = ViewFactoryUtil.sectionTilteLbael()
        r.text = "loginPwdFormat".localized()
        r.tg_top.equal(pwdView.tg_bottom).offset(10)
        return r
    }()
    
    lazy var rePwdView: SuperSettingView = {
        let r = SuperSettingView.createInput("EnterAgain".localized())
        r.loginUI()
        r.tg_top.equal(pwdView.tg_bottom, offset: 20)
        r.tg_width.equal(.fill)
        r.isPwd()
        return r
    }()
    
    lazy var nicknameView: SuperSettingView = {
        let r = SuperSettingView.createInput("你的名字".localized())
        r.loginUI()
        r.tg_top.equal(rePwdView.tg_bottom, offset: 20)
        r.tg_width.equal(.fill)
        r.isUserName()
        return r
    }()
    
    lazy var registerBtn: QMUIButton = {
        let r = ViewFactoryUtil.primaryHalfFilletButton()
        r.setTitle("注册".localized(), for: .normal)
        r.tg_top.equal(nicknameView.tg_bottom, offset: 40)
        r.addTarget(self, action: #selector(register), for: .touchUpInside)
        return r
    }()
    
    var phone: String? {
        return phoneView.textFieldView.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    override func bindData() {
        Observable.combineLatest(phoneView.textFieldView.rx.text.orEmpty, codeView.textFieldView.rx.text.orEmpty, pwdView.textFieldView.rx.text.orEmpty, rePwdView.textFieldView.rx.text.orEmpty, nicknameView.textFieldView.rx.text.orEmpty) {
            $0.count > 0 && $1.count > 0 && $2.count > 0 && $3.count > 0 && $4.count > 0
        }
        .bind(to: registerBtn.rx.isEnabled)
        .disposed(by: rx.disposeBag)
        
        
        pwdView.textFieldView.rx.text.orEmpty
            .subscribe(onNext:{ [weak self] in
                print("ttt",$0)
                self?.refresUIAboutPwdTips($0)
            })
            .disposed(by: rx.disposeBag)
        
    }
    
    func refresUIAboutPwdTips(_ pwd:String?) {
        var show = !(pwd?.validatePassword() ?? false)
        if pwd?.count == 0 {
            show = false
        }
        if show {
            self.pwdTipLbl.show()
            self.rePwdView.tg_top.equal(self.pwdTipLbl.tg_bottom, offset: 10)
        } else {
            self.pwdTipLbl.hide()
            self.rePwdView.tg_top.equal(pwdView.tg_bottom, offset: 20)
           
        }
        view.layoutIfNeeded()
    }
    
}

extension YFNewRegisterVC {
    /// 请求验证码
    func requestCode() {
        view.endEditing(true)
        
        if let phone = phoneView.textFieldView.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines), phone.isEmpty {
            if useType == .usePhone {
                SuperToast.show(title: "plsEnterRightX".localizedFormat("phoneNumber".localized()))
            } else {
//                ProgressHUD.error("plsEnterRightX".localizedFormat("email".localized()))
                SuperToast.show(title: "plsEnterRightX".localizedFormat("email".localized()))
            }
            return
        }
        
        let invaitationCode = ""
        startCountDown()
        
        AccountViewModel.requestCode(phone: useType == .usePhone ? phone : nil, areaCode: _areaCode, email: useType == .useEmail ? phone : nil, invaitationCode: invaitationCode, useFor: .register) { [weak self] errCode, _ in

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

        if !pwdView.textFieldView.text!.validatePassword() {
//            ProgressHUD.error("plsEnterRightX".localizedFormat("password".localized()))
            SuperToast.show(title: "plsEnterRightX".localizedFormat("password".localized()))
            return
        }
        
        if pwdView.inputText != rePwdView.inputText {
            print(pwdView.inputText, rePwdView.inputText)
            SuperToast.show(title: "twicePwdNoSame".localized())
            return
        }
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
        
        guard let name = nicknameView.inputText?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty else {
//            ProgressHUD.error("plsEnterYourX".localizedFormat("nickname".localized()))
            SuperToast.show(title: "plsEnterYourX".localizedFormat("nickname".localized()))
            return
        }
        ProgressHUD.animate()
        let tabController = UIApplication.shared.keyWindow?.rootViewController as? MainTabViewController
        AccountViewModel.registerAccount(phone: useType == .usePhone ? phone : nil,
                                         areaCode: _areaCode,
                                         verificationCode: codeView.inputText!,
                                         password: pwdView.inputText!,
                                         faceURL: "",
                                         nickName: name,
                                         email: useType == .useEmail ? phone : nil,
                                         invitationCode: "")
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
                        //                                GeTuiSdk.bindAlias(userID, andSequenceNum: "im")
                    }
                    UserDefaults.standard.setValue(self?.useType.rawValue, forKey: loginTypeKey)
                    UserDefaults.standard.synchronize()
                    AccountViewModel.savePreLoginAccount(self?.phone)
                    AccountViewModel.updateUserInfo(userID: AccountViewModel.userID!) { _, _ in
                        tabController?.loginSuccess(dismiss: true)
                    }
                }
            }
            
        }
    }
}

