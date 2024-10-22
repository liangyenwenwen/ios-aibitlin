//
//  YFLoginVC.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/5/9.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import UIKit
import TangramKit
import RxSwift
import RxCocoa
import RxGesture
import BSText
import ProgressHUD

class YFLoginVC: BaseLogicController {

    /// 使用邮箱 或者手机号
    var useType: MyStyle!
    
    private var _areaCode = "+86"
    
    override func initViews() {
        super.initViews()
        useType =  AppDelegate.shared.isChine ? .usePhone : .useEmail
        initRelativeLayoutSafeArea()
        
        bindData()
        
        setBackGroundColor(.white)
        superHeaderContainerContainer.addSubview(chooseHeader)
        
        /// APP分离国内外
        chooseHeader.hide()
        superHeaderContainerContainer.tg_height.equal(50)
        
        container.tg_padding = UIEdgeInsets(top: 0, left: PADDING_LARGE2, bottom: 0, right: PADDING_LARGE2)
        
        container.addSubview(appTitleLbl)
        container.addSubview(tipLbl)
        
        container.addSubview(phoneView)
//        container.addSubview(emailView)
        container.addSubview(pwdView)
        
        
        container.addSubview(loginBtn)
        container.addSubview(registerContainer)
        container.addSubview(forgotButton)
        
        container.addSubview(delegateView)
        
    }

    lazy var chooseHeader: YFLoginChooseHeaderView = {
        let r = YFLoginChooseHeaderView(useType: .useEmail, vcType: .isLogin)
        r.tg_width.equal(.fill)
        r.tg_height.equal(.fill)
        r.changeTypeClick =  { [weak self] type in
            self?.useType = type
            self?.phoneView.changePhoneEmail(type == .usePhone)

        }
        return r
    }()
    
    lazy var appTitleLbl: UILabel = {
        let r = ViewFactoryUtil.customBoldTilteLable("登录哎比邻".localized(), font: TEXT_LARGE4, textColor: .colorOnSurface)
        r.tg_top.equal(84)
        return r
    }()
    
    lazy var tipLbl: UILabel = {
        let r = ViewFactoryUtil.sectionTilteLbael("登录你的账号、与全球用户无障碍聊天。".localized())
        r.tg_top.equal(appTitleLbl.tg_bottom, offset: 10)
        return r
    }()
    
    lazy var phoneView: SuperSettingView = {
        let r = SuperSettingView.createInputPhone("手机号", placeholder: "请输入手机号")
        r.loginUI()
        r.tg_top.equal(tipLbl.tg_bottom, offset: 36)
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
//        r.tg_top.equal(tipLbl.tg_bottom, offset: 36)
//        r.tg_width.equal(.fill)
//        r.hide()
//        return r
//    }()
    
    lazy var pwdView: SuperSettingView = {
        let r = SuperSettingView.createInput("密码".localized())
        r.loginUI()
        r.tg_top.equal(tipLbl.tg_bottom, offset: 102)
        r.tg_width.equal(.fill)
        r.isPwd()
        return r
    }()
    
    // MARK: - 张亚飞打的标记 添加找回密码
    lazy var forgotButton: UIButton = {
        
        let r = ViewFactoryUtil.linkButton("忘记密码".localized())
        r.setTitleColor(.primaryColor, for: .normal)
        r.rx.tap.subscribe(onNext: { [unowned self] _ in
            toForgotPassword()
        }).disposed(by: rx.disposeBag)
        r.tg_top.equal(loginBtn.tg_bottom, offset: 24)
        r.tg_right.equal(pwdView.tg_right)
        return r

    }()
    
    lazy var loginBtn: QMUIButton = {
        let r = ViewFactoryUtil.primaryHalfFilletButton()
        r.setTitle("登录".localized(), for: .normal)
        r.tg_top.equal(pwdView.tg_bottom, offset: 40)
//        r.tg_top.equal(forgotButton.tg_bottom, offset: 20)
        r.addTarget(self, action: #selector(login), for: .touchUpInside)
        return r
    }()
    
    lazy var registerContainer: TGLinearLayout = {
        let r = TGLinearLayout(.horz)
        r.tg_height.equal(.wrap)
        r.tg_width.equal(.fill)
        r.tg_top.equal(loginBtn.tg_bottom, offset: 24)
        r.addSubview(tipLbl_register)
        r.addSubview(registerBtn)
        return r
    }()
    
    lazy var tipLbl_register: UILabel = {
        let  r = ViewFactoryUtil.customTilteLableWrap("I don't have an account".localized(), font: TEXT_MEDDLE, textColor: .black333)
        return r
    }()
    
    lazy var registerBtn: QMUIButton = {
        let r = ViewFactoryUtil.linkButton("Create a new account".localized())
        r.setTitleColor(.primaryColor, for: .normal)
        r.addTarget(self, action: #selector(gotoRegister), for: .touchUpInside)
        return r
    }()
    
    lazy var delegateView: TGLinearLayout = {
        let r = TGLinearLayout(.horz)
        r.tg_height.equal(.wrap)
        r.tg_width.equal(.fill)
        r.tg_bottom.equal(40)
//        r.tg_gravity = .vert.top
        r.tg_space = PADDING_SMALL
        r.clipsToBounds = true
        
        r.addSubview(chooseDelegateBtn)
//        r.addSubview(tipLbl_delegate)
//        r.addSubview(privateDelegateBtn)
//        r.addSubview(registerDelegateBtn)
        
        
        
        r.addSubview(agreementView)
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
        let  r = ViewFactoryUtil.customTilteLableWrap("我已阅读并同意AIbitlin", font: TEXT_MEDDLE, textColor: .black999)
        return r
    }()
    
    lazy var privateDelegateBtn: QMUIButton = {
        let r = ViewFactoryUtil.linkButton("《隐私协议》")
        r.setTitleColor(.primaryColor, for: .normal)
        r.addTarget(self, action: #selector(gotoPrivateDelegate), for: .touchUpInside)
        return r
    }()
    
    lazy var registerDelegateBtn: QMUIButton = {
        let r = ViewFactoryUtil.linkButton("《注册协议》")
        r.setTitleColor(.primaryColor, for: .normal)
        r.addTarget(self, action: #selector(gotoRegisterDelegate), for: .touchUpInside)
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
//        let tap = UITapGestureRecognizer(target: self, action: #selector(changeAgreeState))
//        r.addGestureRecognizer(tap)
        
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
//            print("21313")
            
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
        return nil
    }
    
    override func bindData()  {
        
        Observable.combineLatest(phoneView.textFieldView.rx.text.orEmpty, pwdView.textFieldView.rx.text.orEmpty) {
            $0.count > 0  && $1.count > 7
        }
        .bind(to: loginBtn.rx.isEnabled)
        .disposed(by: rx.disposeBag)
        
        
        
        
    }
    
    
    
    
    
}


extension YFLoginVC {
    

    @objc func changePhoneArea()  {
        let alert = UIAlertController(style: .actionSheet, title: "")
        alert.addLocalePicker(type: .phoneCode) {[weak self] info in
            // action with selected object
            guard let phoneCode = info?.phoneCode else {return}
            self?._areaCode = phoneCode
            self?.phoneView.phoneCodeLbl.text = phoneCode
        }
        
        alert.addAction(title: "cancel".localized(), style: .cancel)
        self.present(alert, animated: true)
    }
    
    
    @objc func gotoRegister() {
        print(#function)
        let vc = YFRegisterVC()
        vc.useType = useType
        gotoController(vc)
    }
    
    @objc func gotoPrivateDelegate() {
        print(#function)
    }
    
    @objc func gotoRegisterDelegate() {
        print(#function)
    }
    
    @objc func chooseDelegate(_ btn: QMUIButton)  {
        btn.isSelected = !btn.isSelected
    }
    
    @objc func login() {
        print(useType!)
        print(#function)
    }
    
    func toForgotPassword() {
        
        let vc = MineDeleteAcountAuthenticationVC()
        vc.vcType = useType == .usePhone ? .forgetPwdbyPhoneBylogin : .forgetPwdByEmailBylogin
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
 
    
}
