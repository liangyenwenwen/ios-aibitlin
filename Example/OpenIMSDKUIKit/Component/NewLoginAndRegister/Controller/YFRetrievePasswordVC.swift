//
//  YFRetrievePasswordVC.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/10/28.
//  Copyright © 2024 rentsoft. All rights reserved.
//


import UIKit
import TangramKit
import RxSwift
import RxCocoa
import ProgressHUD

class YFRetrievePasswordVC: BaseLogicController {

    
    private var _areaCode = "+86"
    var isUsePhone: Bool = false
    
    override func initViews() {
        super.initViews()
        setBackGroundColor(.colorBackgroundAPP)
        initLinearLayoutSafeArea()
    
        superHeaderContainerContainer.addSubview(chooseHeader)
        
        container.tg_padding = UIEdgeInsets(top: PADDING_MEDDLE, left: PADDING_OUTER, bottom: PADDING_MEDDLE, right: PADDING_OUTER)
        container.tg_space = PADDING_OUTER
        
        container.addSubview(sectionLbl)
        container.addSubview(topContentView)
        container.addSubview(codeTipLbl)
        

        container.addSubview(ViewFactoryUtil.sectionTilteLbael("EnterTheNewPassword".localized()))
        container.addSubview(newPwdContentView)
        container.addSubview(pwdTipLbl)

        
        container.addSubview(nextBtn)
        
        refreshUI()
        bindData()
    }
    
    override func bindData() {
        
      
        Observable
            .combineLatest(emailView.textFieldView.rx.text.orEmpty,phoneView.textFieldView.rx.text.orEmpty, getCodeView.textFieldView.rx.text.orEmpty,  newPwdView.textFieldView.rx.text.orEmpty, rePwdView.textFieldView.rx.text.orEmpty) {
                if self.isUsePhone{
                   $0.count >= 0 && $1.count > 0 && $2.count > 0 && $3.count > 7 && $4.count > 7
                }else{
                    $0.count > 0 && $1.count >= 0 && $2.count > 0 && $3.count > 7 && $4.count > 7
                }
                
            }
            .bind(to: nextBtn.rx.isEnabled)
            .disposed(by: rx.disposeBag)
 
       
    }
    
    func refreshUI() {
        
        if isUsePhone {
            sectionLbl.text = "请验证你的手机号".localized()
            phoneView.show()
            emailView.hide()
            codeTipLbl.hide()

        } else {
            sectionLbl.text = "请验证你的邮箱".localized()
            phoneView.hide()
            emailView.show()
            codeTipLbl.show()
        }
        getCodeView.textView.text = ""
        
     
    }
    lazy var chooseHeader: YFAibitlinHomeChooseHeaderView = {
        let r = YFAibitlinHomeChooseHeaderView(headerType: .findPwd)
        r.tg_width.equal(.fill)
        r.tg_height.equal(52)
        r.refreshUI()
        r.back = { [weak self] in
            self?.navigationController?.popViewController()
        }
        r.changeTypeClick =  { [weak self] currentIndex in
            self?.isUsePhone = currentIndex == 1
            self?.refreshUI()
        }
        return r
    }()
    
    
    lazy var sectionLbl: UILabel = {
        let r = ViewFactoryUtil.sectionTilteLbael("请验证你的手机号")
        r.textColor = .black666
        r.font = .mediumFont(14)
        return r
    }()
 
    
    lazy var topContentView: TGLinearLayout = {
        let r = TGLinearLayout(.vert)
        r.tg_width.equal(.fill)
        r.tg_height.equal(.wrap)
        r.tg_space = 1
        r.corner(MEDDLE_RADIUS)
        r.backgroundColor = .white
        r.addSubview(emailView)
        r.addSubview(phoneView)
        r.addSubview(ViewFactoryUtil.smallDivider())
        r.addSubview(getCodeView)
        
        return r
    }()
    
    lazy var phoneView: SuperSettingView = {
        let r = SuperSettingView.createInputPhone("手机号".localized(), placeholder: "请输入手机号".localized())
        r.phoneCodeLbl.font = UIFont(name: "PingFangSC-Medium", size: 16)
        r.changePhoneEmail(true)
        r.isMediumFont()
        r.hide()
//        r.changePhoneEmail(true)
        r.phoneCodeLbl.text = _areaCode
        let tap = UITapGestureRecognizer(target: self, action: #selector(changePhoneArea))
        r.phoneCodeView.addGestureRecognizer(tap)
        return r
    }()
    lazy var emailView: SuperSettingView = {
        let r = SuperSettingView.createInputPhone("邮箱".localized(), placeholder: "请输入邮箱".localized())
        r.phoneCodeLbl.font = UIFont(name: "PingFangSC-Medium", size: 16)
        r.changePhoneEmail(false)
        r.isMediumFont()
//        r.changePhoneEmail(true)
        return r
    }()
    
    
    lazy var getCodeView: SuperSettingView = {
        let r = SuperSettingView.createInputAboutCode("Code".localized())
        r.isMediumFont()
        r.isCode()
        r.codeBtn.addTarget(self, action: #selector(getCodeAction), for: .touchUpInside)
        return r
    }()
    lazy var codeTipLbl: UILabel = {
        let r = ViewFactoryUtil.sectionTilteLbael()
        r.text = "codeFormat".localized()
        r.numberOfLines = 0
        return r
    }()
    
    lazy var newPwdContentView: TGLinearLayout = {
        let r = TGLinearLayout(.vert)
        r.tg_width.equal(.fill)
        r.tg_height.equal(.wrap)
        r.tg_space = 1
        r.corner(MEDDLE_RADIUS)
        r.backgroundColor = .white
        
        r.addSubview(newPwdView)
        r.addSubview(ViewFactoryUtil.smallDivider())
        r.addSubview(rePwdView)
        
        return r
    }()
    
    lazy var newPwdView: SuperSettingView = {
        let r = SuperSettingView.createInput("输入密码".localized())
        r.isMediumFont()
        r.isPwd()
        return r
    }()
    
    
    lazy var rePwdView: SuperSettingView = {
        let r = SuperSettingView.createInput("EnterAgain".localized())
        r.isMediumFont()
        r.isPwd()
        return r
    }()
    
    lazy var pwdTipLbl: UILabel = {
        let r = ViewFactoryUtil.sectionTilteLbael()
        r.text = "loginPwdFormat".localized()
        r.tg_top.equal(-6)
        return r
    }()
    
    lazy var nextBtn: QMUIButton = {
        let  r = ViewFactoryUtil.primaryHalfFilletButton()
        r.setTitle("重置密码".localized(), for: .normal)
        r.addTarget(self, action: #selector(resetPwdAction), for: .touchUpInside)
        r.tg_top.equal(20)
        return r
    }()
    
    @objc func resetPwdAction()  {
        if newPwdView.inputText != rePwdView.inputText {
            SuperToast.show(title: "twicePwdNoSame".localized())
            return
        }
        resetPwd()
        
    }
    
    deinit {
        //保证定时器释放
        CountDownUtil.cancel()
        print(#file)
    }
    
    func resetPwd() {
        print("重置密码")
        ProgressHUD.animate()
        AccountViewModel.resetPassword(phone: isUsePhone ? phoneView.inputText : nil,
                                       areaCode: _areaCode,
                                       email: !isUsePhone ? emailView.inputText : nil,
                                       verificationCode: getCodeView.inputText!,
                                       password: newPwdView.inputText!,
                                       resetType: isUsePhone ? 1 : 2) { [weak self] (errCode, errMsg) in
            
            if errCode == 0, let `self` = self {
//                        ProgressHUD.success("changed".localized() + "success".localized())
                SuperToast.show(title: "changed".localized() + "success".localized())
                self.navigationController?.popToRootViewController(animated: true)
            } else {
                if errCode == -1{
                    SuperToast.show(title: errMsg)
                }else{
                    SuperToast.show(title: String(errCode) + "：" + String(errCode).localized())
                }
            }
            ProgressHUD.dismiss()
        }
    }
    
}

extension YFRetrievePasswordVC {
    
    @objc func changePhoneArea()  {
        let alert = UIAlertController(style: .actionSheet, title: "")
        alert.addLocalePicker(type: .phoneCode,chooseTitle: "choose".localized(),searchStr: "搜索".localized()) {[weak self] info in
            // action with selected object
            guard let phoneCode = info?.phoneCode else {return}
            self?._areaCode = phoneCode
            self?.phoneView.phoneCodeLbl.text = phoneCode
        }
        
        alert.addAction(title: "cancel".localized(), style: .cancel)
        self.present(alert, animated: true)
    }
    
    
    @objc func  getCodeAction() {
        requestCodeAboutPwd()
    }
    
    
    
    
    /// 请求验证码
    func requestCodeAboutPwd() {
        view.endEditing(true)
        
        if let phone = phoneView.textFieldView.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines), phone.isEmpty {
            if isUsePhone {
                SuperToast.show(title: "plsEnterRightX".localizedFormat("phoneNumber".localized()))
            } else {
                SuperToast.show(title: "plsEnterRightX".localizedFormat("email".localized()))
            }
            return
        }
        
        let invaitationCode = ""
        ProgressHUD.animate()
        AccountViewModel.requestCode(phone: isUsePhone ? phoneView.inputText : nil, areaCode: _areaCode, email: !isUsePhone ? emailView.inputText : nil, invaitationCode: invaitationCode, useFor: .forgotPassword) { [weak self] errCode, _ in
            ProgressHUD.dismiss()
            guard let sself = self else { return }
            if errCode != 0 {
                SuperToast.show(title: String(errCode) + "：" + String(errCode).localized())
                self?.getCodeView.codeBtn.setTitle("Resend".localized(), for: .normal)
                self?.getCodeView.codeBtn.isEnabled = true
            } else {
                self?.startCountDown()
            }
        }
    }
    
    /// 开始倒计时
    func startCountDown() {
        CountDownUtil.countDown(60) { result in
            
            if result == 0 {
                self.getCodeView.codeBtn.setTitle("Resend".localized(), for: .normal)
                self.getCodeView.codeBtn.isEnabled = true
            } else {
                self.getCodeView.codeBtn.setTitle("ResendCount".localizedFormat(result), for: .normal)
            }
            
            self.getCodeView.codeBtn.sizeToFit()
        }
        
        // 禁用按钮
        getCodeView.codeBtn.isEnabled = false
    }
    
}


