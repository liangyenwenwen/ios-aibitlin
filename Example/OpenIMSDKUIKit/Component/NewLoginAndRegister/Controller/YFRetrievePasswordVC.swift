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
        

        container.addSubview(ViewFactoryUtil.sectionTilteLbael("EnterTheNewPassword".localized()))
        container.addSubview(newPwdContentView)
        container.addSubview(pwdTipLbl)

        
        container.addSubview(nextBtn)
        
        refreshUI()
        bindData()
    }
    
    override func bindData() {
        
      
        Observable
            .combineLatest(useTypeView.textFieldView.rx.text.orEmpty, getCodeView.textFieldView.rx.text.orEmpty,  newPwdView.textFieldView.rx.text.orEmpty, rePwdView.textFieldView.rx.text.orEmpty) {
                $0.count > 0 && $1.count > 0 && $2.count > 0 && $3.count > 0
            }
            .bind(to: nextBtn.rx.isEnabled)
            .disposed(by: rx.disposeBag)
 
       
    }
    
    func refreshUI() {
        
        if isUsePhone {
            sectionLbl.text = "请验证你的手机号".localized()
            useTypeView.changePhoneEmail(true)

        } else {
            sectionLbl.text = "请验证你的邮箱".localized()
            useTypeView.changePhoneEmail(false)

        }
        
        useTypeView.textFieldView.text = ""
        getCodeView.textFieldView.text = ""
        
     
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
        
        r.addSubview(useTypeView)
        r.addSubview(ViewFactoryUtil.smallDivider())
        r.addSubview(getCodeView)
        
        return r
    }()
    
    lazy var useTypeView: SuperSettingView = {
        let r = SuperSettingView.createInputPhone("手机号", placeholder: "请输入手机号")
        r.phoneCodeLbl.font = UIFont(name: "PingFangSC-Medium", size: 16)
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
        AccountViewModel.resetPassword(phone: isUsePhone ? useTypeView.inputText : nil,
                                       areaCode: _areaCode,
                                       email: !isUsePhone ? useTypeView.inputText : nil,
                                       verificationCode: getCodeView.inputText!,
                                       password: newPwdView.inputText!) { [weak self] (errCode, errMsg) in
            
            if errCode == 0, let `self` = self {
//                        ProgressHUD.success("changed".localized() + "success".localized())
                SuperToast.show(title: "changed".localized() + "success".localized())
                self.navigationController?.popToRootViewController(animated: true)
            } else {
//                        ProgressHUD.error(String(errCode).localized())
                SuperToast.show(title: String(errCode).localized())
                
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
            self?.useTypeView.phoneCodeLbl.text = phoneCode
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
        
        if let phone = useTypeView.textFieldView.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines), phone.isEmpty {
            if isUsePhone {
                SuperToast.show(title: "plsEnterRightX".localizedFormat("phoneNumber".localized()))
            } else {
                SuperToast.show(title: "plsEnterRightX".localizedFormat("email".localized()))
            }
            return
        }
        
        let invaitationCode = ""
        startCountDown()
        
        AccountViewModel.requestCode(phone: isUsePhone ? useTypeView.inputText : nil, areaCode: _areaCode, email: !isUsePhone ? useTypeView.inputText : nil, invaitationCode: invaitationCode, useFor: .forgotPassword) { [weak self] errCode, _ in

            guard let sself = self else { return }
            if errCode != 0 {
                SuperToast.show(title: String(errCode).localized())
                CountDownUtil.cancel()
                self?.getCodeView.codeBtn.setTitle("Resend".localized(), for: .normal)
                self?.getCodeView.codeBtn.isEnabled = true
            } else {
                ProgressHUD.dismiss()
            }
            ProgressHUD.dismiss()
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


