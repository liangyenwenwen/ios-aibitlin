//
//  MineDeleteCountAuthenticationVC.swift
//  MyCloudMusic
//
//  Created by mac on 2024/5/7.
//

import UIKit
import TangramKit
import RxSwift
import RxCocoa
import ProgressHUD

class MineDeleteAcountAuthenticationVC: BaseTitleController {

    var vcType: MyStyle = .usePhone
    
    private var _areaCode = "+86"
    
    override func initViews() {
        super.initViews()
        setBackGroundColor(.colorBackgroundAPP)
        initLinearLayoutSafeArea()
    
        title = "DeleteAccount".localized()
        
        container.tg_padding = UIEdgeInsets(top: PADDING_MEDDLE, left: PADDING_OUTER, bottom: PADDING_MEDDLE, right: PADDING_OUTER)
        container.tg_space = PADDING_OUTER
        
        container.addSubview(sectionLbl)
        container.addSubview(topContentView)
        
      
        
        
        if vcType == .forgetPwdbyPhoneBylogin || vcType == .forgetPwdByEmailBylogin {
            container.addSubview(ViewFactoryUtil.sectionTilteLbael("EnterTheNewPassword".localized()))
            container.addSubview(newPwdContentView)
            container.addSubview(pwdTipLbl)
        }
        
        container.addSubview(nextBtn)
        
        refreshUI()
        bindData()
    }
    
    override func bindData() {
        
        if vcType == .forgetPwdbyPhoneBylogin || vcType == .forgetPwdByEmailBylogin {
            Observable
                .combineLatest(useTypeView.textFieldView.rx.text.orEmpty, getCodeView.textFieldView.rx.text.orEmpty,  newPwdView.textFieldView.rx.text.orEmpty, rePwdView.textFieldView.rx.text.orEmpty) {
                    $0.count > 0 && $1.count > 3 && $2.count > 7 && $3.count > 7
                }
                .bind(to: nextBtn.rx.isEnabled)
                .disposed(by: rx.disposeBag)
        } else {
            Observable
                .combineLatest(useTypeView.textFieldView.rx.text.orEmpty, getCodeView.textFieldView.rx.text.orEmpty) {
                    $0.count > 0 && $1.count > 3
                }
                .bind(to: nextBtn.rx.isEnabled)
                .disposed(by: rx.disposeBag)
        }
       
    }
    
    func refreshUI() {
        switch vcType {
        case .usePhone:
            title = "DeleteAccount".localized()
            sectionLbl.text = "PleaseFillIn".localized()
            useTypeView.changePhoneEmail(true)
            let tap = UITapGestureRecognizer(target: self, action: #selector(changePhoneArea))
            useTypeView.phoneCodeView.addGestureRecognizer(tap)
            nextBtn.setTitle("nextStep".localized(), for: .normal)
        case .useEmail:
            title = "DeleteAccount".localized()
            sectionLbl.text = "PleaseFillIn".localized()
            useTypeView.changePhoneEmail(false)
            nextBtn.setTitle("nextStep".localized(), for: .normal)
        case .changePhone:
            title = "Phone".localized()
            sectionLbl.text = "PleaseFillIn".localized()
            useTypeView.changePhoneEmail(true)
            let tap = UITapGestureRecognizer(target: self, action: #selector(changePhoneArea))
            useTypeView.phoneCodeView.addGestureRecognizer(tap)
            nextBtn.setTitle("nextStep".localized(), for: .normal)
        case .changeEmail:
            title = "email".localized()
            sectionLbl.text = "PleaseFillIn".localized()
            useTypeView.changePhoneEmail(false)
            nextBtn.setTitle("nextStep".localized(), for: .normal)
        case .forgetPwdbyPhone:
            title = "忘记密码".localized()
            sectionLbl.text = "请验证你的手机号".localized()
            useTypeView.changePhoneEmail(true)
            let tap = UITapGestureRecognizer(target: self, action: #selector(changePhoneArea))
            useTypeView.phoneCodeView.addGestureRecognizer(tap)
            nextBtn.setTitle("nextStep".localized(), for: .normal)
        case .forgetPwdByEmail:
            title = "忘记密码".localized()
            sectionLbl.text = "请验证你的邮箱".localized()
            useTypeView.changePhoneEmail(false)
            nextBtn.setTitle("nextStep".localized(), for: .normal)
        case .forgetPwdbyPhoneBylogin:
            title = "忘记密码".localized()
            sectionLbl.text = "请验证你的手机号".localized()
            useTypeView.changePhoneEmail(true)
            let tap = UITapGestureRecognizer(target: self, action: #selector(changePhoneArea))
            useTypeView.phoneCodeView.addGestureRecognizer(tap)
            nextBtn.setTitle("重置密码".localized(), for: .normal)
        case .forgetPwdByEmailBylogin:
            title = "忘记密码".localized()
            sectionLbl.text = "请验证你的邮箱".localized()
            useTypeView.changePhoneEmail(false)
            nextBtn.setTitle("重置密码".localized(), for: .normal)
        default :
            break
        }
    }
    
//    
//    func getTitle() -> String {
//        switch vcType {
//        case .usePhone, .useEmail:
//            return "删除账号"
//        case .changePhone:
//            return "修改手机号"
//        case .changeEmail:
//            return "修改手机号"
//        default :
//            return ""
//        }
//    }
//    
//    func getSectionTitle() -> String {
//        switch vcType {
//        case .usePhone:
//            return "请验证你的手机号"
//        case .useEmail:
//            return "请验证你的邮箱"
//        case .changePhone:
//            return "输入新的手机号"
//        case .changeEmail:
//            return "输入新的邮箱"
//        default :
//            return ""
//        }
//    }
    
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
        r.setTitle("下一步", for: .normal)
        r.addTarget(self, action: #selector(gotoNextVC), for: .touchUpInside)
        r.tg_top.equal(20)
        return r
    }()
    
    @objc func gotoNextVC()  {
        
        if vcType == .usePhone || vcType == .useEmail {
            let vc = MineDeleteAccountReasonVC()
            vc.vcType = vcType
            self.navigationController?.pushViewController(vc, animated: true)
        } else if vcType == .forgetPwdbyPhoneBylogin || vcType == .forgetPwdByEmailBylogin {
//            let vc = YFMineChangePasswordVC()
//            if vcType == .forgetPwdbyPhoneBylogin {
//                vc.areCode = _areaCode
//                vc.phone = useTypeView.inputText
//            } else {
//                vc.email = useTypeView.inputText
//            }
//            vc.code = getCodeView.inputText
//            vc.vcType = vcType
//            self.navigationController?.pushViewController(vc, animated: true)
            
            resetPwd()
        } else {
            let vc = YFMineChangePasswordVC()
            vc.vcType = vcType
            self.navigationController?.pushViewController(vc, animated: true)
            print("修改绑定")
        }
        
    }
    
    deinit {
        //保证定时器释放
        CountDownUtil.cancel()
        print(#file)
    }
    
    func resetPwd() {
        print("重置密码")
        ProgressHUD.animate()
        AccountViewModel.resetPassword(phone: vcType == .forgetPwdbyPhoneBylogin ? useTypeView.inputText : nil,
                                       areaCode: _areaCode,
                                       email: vcType == .forgetPwdByEmailBylogin ? useTypeView.inputText : nil,
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

extension MineDeleteAcountAuthenticationVC {
    
    @objc func changePhoneArea()  {
        let alert = UIAlertController(style: .actionSheet, title: "")
        alert.addLocalePicker(type: .phoneCode) {[weak self] info in
            // action with selected object
            guard let phoneCode = info?.phoneCode else {return}
            self?._areaCode = phoneCode
            self?.useTypeView.phoneCodeLbl.text = phoneCode
        }
        
        alert.addAction(title: "cancel".localized(), style: .cancel)
        self.present(alert, animated: true)
    }
    
    
    @objc func  getCodeAction() {
        if vcType == .forgetPwdbyPhoneBylogin || vcType == .forgetPwdByEmailBylogin {
            requestCodeAboutPwd()
        }
    }
    
    
    
    
    /// 请求验证码
    func requestCodeAboutPwd() {
        view.endEditing(true)
        
        if let phone = useTypeView.textFieldView.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines), phone.isEmpty {
            if vcType == .forgetPwdbyPhoneBylogin {
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
        
        AccountViewModel.requestCode(phone: vcType == .forgetPwdbyPhoneBylogin ? useTypeView.inputText : nil, areaCode: _areaCode, email: vcType == .forgetPwdByEmailBylogin ? useTypeView.inputText : nil, invaitationCode: invaitationCode, useFor: .forgotPassword) { [weak self] errCode, _ in

            guard let sself = self else { return }
            if errCode != 0 {
//                ProgressHUD.error(String(errCode).localized())
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


