//
//  YFChangeAccountViewController.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2025/1/9.
//  Copyright © 2025 rentsoft. All rights reserved.
//

import UIKit
import TangramKit
import RxSwift
import RxCocoa
import ProgressHUD
import OUICore
class YFChangeAccountViewController: BaseTitleController {
    /// 邮箱 或者手机号
    var useType: MyStyle = .useEmail
    
    private var _areaCode = "+86"
    var changeSuccessBlock:((_ areaCode:String, _ phone:String,_ email:String)->())!
    override func initViews() {
        super.initViews()
     
        setBackGroundColor(.colorBackgroundAPP)
        initLinearLayoutSafeArea()
        container.tg_padding = UIEdgeInsets(top: PADDING_MEDDLE, left: PADDING_OUTER, bottom: PADDING_MEDDLE, right: PADDING_OUTER)
        container.tg_space = PADDING_OUTER
        container.addSubview(sectionLbl)
        container.addSubview(topContentView)
        if useType == .usePhone || useType == .changePhone {
            sectionLbl.text = "请输入".localized()
            useTypeView.changePhoneEmail(true)
            let tap = UITapGestureRecognizer(target: self, action: #selector(changePhoneArea))
            useTypeView.phoneCodeView.addGestureRecognizer(tap)
            sureBtn.setTitle("确定".localized(), for: .normal)
        }else{
            sectionLbl.text = "请输入".localized()
            useTypeView.changePhoneEmail(false)
            sureBtn.setTitle("确定".localized(), for: .normal)
            container.addSubview(codeTipLbl)
        }
        if useType == .usePhone{
            title = "BindPhone".localized()
            sectionLbl.text = "输入您的手机号".localized()
        }else if useType == .changePhone{
            title = "ChangePhone".localized()
            sectionLbl.text = "输入新的手机号".localized()
        }else if useType == .useEmail{
            title = "BindEmail".localized()
            sectionLbl.text = "输入您的邮箱".localized()
        }else{
            title = "ChangeEmail".localized()
            sectionLbl.text = "输入新的邮箱".localized()
        }
        container.addSubview(sureBtn)
        bindData()
    }

    override func bindData() {
        Observable
            .combineLatest(useTypeView.textFieldView.rx.text.orEmpty, getCodeView.textFieldView.rx.text.orEmpty) {
                $0.count > 0 && $1.count > 5
            }
            .bind(to: sureBtn.rx.isEnabled)
            .disposed(by: rx.disposeBag)
    }
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
        let r = SuperSettingView.createInputPhone("手机号".localized(), placeholder: "请输入手机号".localized())
        r.phoneCodeLbl.font = UIFont(name: "PingFangSC-Medium", size: 16)
        r.isMediumFont()
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
        r.tg_top.equal(-6)
        r.numberOfLines = 0
        return r
    }()
    lazy var sureBtn: QMUIButton = {
        let  r = ViewFactoryUtil.primaryHalfFilletButton()
        r.setTitle("确定".localized(), for: .normal)
        r.addTarget(self, action: #selector(sureBtnClick), for: .touchUpInside)
        r.tg_top.equal(20)
        return r
    }()
    
    @objc func sureBtnClick()  {
        view.endEditing(true)
        ProgressHUD.animate()
        AccountViewModel.changeAccountRequest(userID:IMController.shared.uid,phoneNumber: (useType == .usePhone || useType == .changePhone) ? useTypeView.inputText : nil, areaCode: _areaCode, email: (useType == .useEmail || useType == .changeEmail) ? useTypeView.inputText : nil, verifyCode: getCodeView.inputText) { [weak self] errCode, _ in
            ProgressHUD.dismiss()
            guard let sself = self else { return }
            if errCode == 0{
                if self?.useType == .usePhone || self?.useType == .useEmail{
                    SuperToast.show(title: "绑定成功".localized())
                }else{
                    SuperToast.show(title: "修改成功".localized())
                }
                if self?.changeSuccessBlock != nil{

                    self?.changeSuccessBlock(self?._areaCode ?? "",self?.useTypeView.inputText ?? "",self?.useTypeView.inputText ?? "")
                }
                self?.navigationController?.popViewController(animated: true)
            }else{
                SuperToast.show(title: String(errCode) + "：" + String(errCode).localized())
            }
        }
    }
    
    deinit {
        //保证定时器释放
        CountDownUtil.cancel()
        print(#file)
    }
}

extension YFChangeAccountViewController {
    
    @objc func changePhoneArea()  {
        view.endEditing(true)
        let alert = UIAlertController(style: .actionSheet, title: "")
        alert.addLocalePicker(type: .phoneCode,chooseTitle: "choose".localized(),searchStr: "搜索".localized()) {[weak self] info in
            guard let phoneCode = info?.phoneCode else {return}
            self?._areaCode = phoneCode
            self?.useTypeView.phoneCodeLbl.text = phoneCode
        }
        
        alert.addAction(title: "cancel".localized(), style: .cancel)
        self.present(alert, animated: true)
    }
    
    /// 请求验证码
    @objc func getCodeAction() {
        view.endEditing(true)
        
        if let phone = useTypeView.textFieldView.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines), phone.isEmpty {
            if useType == .usePhone{
                SuperToast.show(title: "plsEnterRightX".localizedFormat("phoneNumber".localized()))
            } else {
                SuperToast.show(title: "plsEnterRightX".localizedFormat("email".localized()))
            }
            return
        }
        
        let invaitationCode = ""
        ProgressHUD.animate()
        AccountViewModel.requestCode(phone: (useType == .usePhone || useType == .changePhone) ? useTypeView.inputText : nil, areaCode: _areaCode, email: (useType == .useEmail || useType == .changeEmail) ? useTypeView.inputText : nil, invaitationCode: invaitationCode, useFor: .changeAccount) { [weak self] errCode, _ in
            ProgressHUD.dismiss()
            guard let sself = self else { return }
            if errCode != 0 {
                SuperToast.show(title: String(errCode) + "：" + String(errCode).localized())
                self?.getCodeView.codeBtn.setTitle("Resend".localized(), for: .normal)
                self?.getCodeView.codeBtn.isEnabled = true
            }else{
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
