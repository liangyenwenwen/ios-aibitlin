//
//  YFRegisterVC.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/5/9.
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


class YFRegisterVC: BaseTitleController {
    /// 使用邮箱 或者手机号
    var useType: MyStyle = .useEmail
    
    private var _areaCode = "+86"

    override func initViews() {
        super.initViews()
     
        initRelativeLayoutSafeArea()
        
        setBackGroundColor(.white)
//        setBackGroundColor(.white)
//        superHeaderContainerContainer.addSubview(chooseHeader)
//        /// APP分离国内外
//        chooseHeader.hide()
//        superHeaderContainerContainer.tg_height.equal(50)
        
        container.tg_padding = UIEdgeInsets(top: 0, left: PADDING_LARGE2, bottom: 0, right: PADDING_LARGE2)
        
        container.addSubview(appTitleLbl)
        container.addSubview(phoneView)
        container.addSubview(codeView)
        container.addSubview(pwdView)
        container.addSubview(pwdTipLbl)
        container.addSubview(rePwdView)
        container.addSubview(nicknameView)
        container.addSubview(registerBtn)
        container.addSubview(delegateView)
        
        bindData()
    }

    lazy var chooseHeader: YFLoginChooseHeaderView = {
        let r = YFLoginChooseHeaderView(useType: useType, vcType: .isRegister)
        r.tg_width.equal(.fill)
        r.tg_height.equal(.fill)
        r.changeTypeClick = { [weak self] type in
            self?.useType = type
            self?.phoneView.changePhoneEmail(type == .usePhone)
        }
        r.back = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        return r
    }()
    
    lazy var appTitleLbl: UILabel = {
        let r = ViewFactoryUtil.customBoldTilteLable("注册哎比邻".localized(), font: TEXT_LARGE4, textColor: .black333)
        r.tg_top.equal(84)
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
    
//    lazy var emailView: SuperSettingView = {
//        let r = SuperSettingView.createInput("输入邮箱", placeholder: "请输入邮箱")
//        r.loginUI()
//        r.tg_top.equal(appTitleLbl.tg_bottom, offset: 36)
//        r.tg_width.equal(.fill)
//        r.hide()
//        return r
//    }()
    
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
        let r = SuperSettingView.createInput("password".localized())
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
        let r = SuperSettingView.createInput("Name".localized())
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
    
    lazy var delegateView: TGLinearLayout = {

        let r = TGLinearLayout(.horz)
        r.tg_height.equal(.wrap)
        r.tg_width.equal(.fill)
        r.tg_bottom.equal(40)

        r.tg_space = PADDING_SMALL
        r.clipsToBounds = true
        
        r.addSubview(chooseDelegateBtn)
        r.addSubview(agreementView)
        return r
    }()
    
    lazy var agreementView: BSLabel = {
        let r = BSLabel()
        r.tg_top.equal(2)
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
        
        let agreementString = "我已阅读并同意AIbitlin《注册协议》".localized()
        let agreeStr = NSMutableAttributedString(string: agreementString, attributes: attributes)
        agreeStr.bs_font = .systemFont(ofSize: TEXT_MEDDLE)
        agreeStr.bs_color = .placeholder
//        var range = agreementString.range(of: "《隐私协议》".localized())!
//        agreeStr.bs_set(textHighlightRange: agreementString.nsRange(from: range), color: .primaryColor, backgroundColor: nil) { [weak self] containerView, text, range, rect in
////            ProgressHUD.succeed("隐私协议")
//            SuperWebController.start((self?.navigationController!)!, uri: "http://bitswith.com/ys/#/privacyAgreement")
//        }
//        
        
        // MARK: - 张亚飞打的标记  点击协议内容切换是否同意协议
        var range1 = agreementString.range(of: "我已阅读并同意AIbitlin《注册协议》".localized())!
        agreeStr.bs_set(textHighlightRange: agreementString.nsRange(from: range1), color: .placeholder, backgroundColor: nil) { [weak self] _, _, _, _ in
            
            if self?.chooseDelegateBtn != nil  {
                self?.chooseDelegateBtn.isSelected = !(self?.chooseDelegateBtn.isSelected)!
            }
            
        }
        
        var  range = agreementString.range(of: "《注册协议》".localized())!
        agreeStr.bs_set(textHighlightRange: agreementString.nsRange(from: range), color: .primaryColor, backgroundColor: nil) { [weak self]  containerView, text, range, rect in
//            ProgressHUD.succeed("注册协议")
//            if String.getCurrentLanguage().starts(with: "zh")  {
//                SuperWebController.start((self?.navigationController!)!, uri: "http://bitswith.com/ys/#/userZH")
//            } else {
//                SuperWebController.start((self?.navigationController!)!, uri: "http://bitswith.com/ys/#/userAgreement")
//            }
            
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
        let r = ViewFactoryUtil.imageBtn(R.image.checked()!, 20)
        r.setImage(R.image.checked()!, for: .selected)
        r.setImage(R.image.check()!, for: .normal)
        r.addTarget(self, action: #selector(chooseDelegate(_:)), for: .touchUpInside)
        return r
    }()
    
    lazy var tipLbl_delegate: UILabel = {
        let r = ViewFactoryUtil.customTilteLableWrap("我已阅读并同意UnityChat".localized(), font: TEXT_MEDDLE, textColor: .black999)
        let tap = UITapGestureRecognizer(target: self, action: #selector(chooseStateChange))
        r.addGestureRecognizer(tap)
        r.isUserInteractionEnabled = true
        return r
    }()
    
    lazy var registerDelegateBtn: QMUIButton = {
        let r = ViewFactoryUtil.linkButton("《注册协议》".localized())
        r.setTitleColor(.primaryColor, for: .normal)
        r.addTarget(self, action: #selector(gotoRegisterDelegate), for: .touchUpInside)
        return r
    }()
    
    var phone: String? {
        return phoneView.textFieldView.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    override func bindData() {
        Observable.combineLatest(phoneView.textFieldView.rx.text.orEmpty, codeView.textFieldView.rx.text.orEmpty, pwdView.textFieldView.rx.text.orEmpty, rePwdView.textFieldView.rx.text.orEmpty, nicknameView.textFieldView.rx.text.orEmpty) {
            $0.count > 0 && $1.count > 4 && $2.count > 0 && $3.count > 0 && $4.count > 0
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

extension YFRegisterVC {
    /// 请求验证码
    func requestCode() {
        view.endEditing(true)
        
        if let phone = phoneView.textFieldView.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines), phone.isEmpty {
            if useType == .usePhone {
//                ProgressHUD.error("plsEnterRightX".localizedFormat("phoneNumber".localized()))
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
    
    @objc func chooseStateChange() {
        chooseDelegateBtn.isSelected = !chooseDelegateBtn.isSelected
    }
    
    @objc func register() {
        if !chooseDelegateBtn.isSelected {
//            ProgressHUD.error("请勾选协议".localized())
            SuperToast.show(title: "请勾选协议".localized())
            return
        }
        if !pwdView.textFieldView.text!.validatePassword() {
//            ProgressHUD.error("plsEnterRightX".localizedFormat("password".localized()))
            SuperToast.show(title: "plsEnterRightX".localizedFormat("password".localized()))
            return
        }
        
        if pwdView.inputText != rePwdView.inputText {
            print(pwdView.inputText, rePwdView.inputText)
//            ProgressHUD.error("twicePwdNoSame".localized())
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
//                ProgressHUD.error(String(errCode).localized())
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
                    AccountViewModel.savePreLoginAccount(self?.phone)
                    AccountViewModel.updateUserInfo(userID: AccountViewModel.userID!) { _, _ in
                        tabController?.loginSuccess(dismiss: true)
                    }
                }
            }
            
        }
    }
}
