//
//  MineDeleteAccountReasonVC.swift
//  MyCloudMusic
//
//  Created by mac on 2024/5/7.
//

import UIKit
import TangramKit
import RxSwift
import RxCocoa
import ProgressHUD
import OUICore

class MineDeleteAccountReasonVC: BaseTitleController {
    
    var vcType: MyStyle = .usePhone
    private var _areaCode = "+86"
    
    override func initViews() {
        super.initViews()
        setBackGroundColor(.colorBackgroundAPP)
        initLinearLayoutSafeArea()
    
        title = "DeleteAccount".localized()
        
        container.tg_padding = UIEdgeInsets(top: PADDING_MEDDLE, left: PADDING_MEDDLE, bottom: PADDING_MEDDLE, right: PADDING_MEDDLE)
        container.tg_space = PADDING_OUTER
        container.addSubview(sectionLbl)
        container.addSubview(topContentView)
        let characterSet = CharacterSet(charactersIn: "0123456789").inverted
        if AccountViewModel.perLoginAccount?.rangeOfCharacter(from: characterSet, options: .literal, range: nil) == nil{
            //是手机号
            useTypeView.changePhoneEmail(true)
            sectionLbl.text = "请验证你的手机号".localized()
        }else{
            useTypeView.changePhoneEmail(false)
            sectionLbl.text = "请验证你的邮箱".localized()
            container.addSubview(codeTipLbl)
        }
        container.addSubview(ViewFactoryUtil.sectionTilteLbael("ReasonForDelete".localized()))
        container.addSubview(resonContentView)
        
//        container.addSubview(ViewFactoryUtil.blankView(20))
        container.addSubview(nextBtn)
        bindData()
    }
    override func bindData() {
        Observable
            .combineLatest(useTypeView.textFieldView.rx.text.orEmpty, getCodeView.textFieldView.rx.text.orEmpty,  reasonTextView.rx.text.orEmpty) {
                $0.count > 0 && $1.count > 0 && $2.count > 0
            }
            .bind(to: nextBtn.rx.isEnabled)
            .disposed(by: rx.disposeBag)
    }
    lazy var sectionLbl: UILabel = {
        let r = ViewFactoryUtil.sectionTilteLbael("请验证你的手机号".localized())
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
        let tap = UITapGestureRecognizer(target: self, action: #selector(changePhoneArea))
        r.phoneCodeView.addGestureRecognizer(tap)
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
        r.tg_top.equal(-6)
        r.numberOfLines = 0
        return r
    }()
    lazy var resonContentView: TGLinearLayout = {
        let r = TGLinearLayout(.vert)
        r.tg_width.equal(.fill)
        r.tg_height.equal(160)
        r.tg_space = 1
        r.corner(MEDDLE_RADIUS)
        r.backgroundColor = .white
        r.tg_padding = UIEdgeInsets(top: PADDING_MEDDLE, left: PADDING_MEDDLE, bottom: PADDING_MEDDLE, right: PADDING_MEDDLE)
        r.addSubview(reasonTextView)
        
        return r
    }()
    
    lazy var reasonTextView: QMUITextView = {
        let r = ViewFactoryUtil.normalTextView()
        return r
    }()
    
    
    lazy var nextBtn: QMUIButton = {
        let  r = ViewFactoryUtil.primaryHalfFilletButton()
        r.setTitle("DeleteAccount".localized(), for: .normal)
        r.addTarget(self, action: #selector(showSheet), for: .touchUpInside)
        r.tg_top.equal(20)
        return r
    }()
    
    
    @objc func showSheet()  {
        
        let contentView = MineDeleteAccountReasonBottomSheetView()
        contentView.tg_width.equal(.fill)
        // MARK: -    判断语言
        let height = String.getCurrentLanguage().starts(with: "zh") ? view.frame.height / 2 : view.frame.height * 2 / 3
        contentView.tg_height.equal(height)
        contentView.deleteAccountAction = {
            ProgressHUD.animate()
            var cancelSign = 2
            let characterSet = CharacterSet(charactersIn: "0123456789").inverted
            if AccountViewModel.perLoginAccount?.rangeOfCharacter(from: characterSet, options: .literal, range: nil) == nil{
                //是手机号
                cancelSign = 2
            }else{
                cancelSign = 1
            }
            ProgressHUD.animate()
            AccountViewModel.deleteAccount(userID: IMController.shared.uid, cancelSign: cancelSign, reason: self.reasonTextView.text,areaCode:self._areaCode,phoneNumber: self.useTypeView.textFieldView.text,email:self.useTypeView.textFieldView.text, verifyCode: self.getCodeView.textFieldView.text!) { [weak self] errCode, _ in
                ProgressHUD.dismiss()
                guard let sself = self else { return }
                if errCode == 0 {
                    //注销成功
                    SuperToast.show(title: "删除成功".localized())
                    NotificationCenter.default.post(name: .init("deleteAccount"), object: nil)
                    
                }else{
                    SuperToast.show(title: String(errCode) + "：" + String(errCode).localized())
                }
            }
        }
        
        GKCover.cover(from: view, contentView: contentView, style: .translucent, showStyle: .bottom, showAnimStyle: .bottom, hideAnimStyle: .bottom, notClick: false)
    }
}
extension MineDeleteAccountReasonVC{
    @objc func changePhoneArea()  {
        let alert = UIAlertController(style: .actionSheet, title: "")
        alert.addLocalePicker(type: .phoneCode, chooseTitle: "choose".localized(),searchStr: "搜索".localized()) {[weak self] info in
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
            if vcType == .usePhone{
//                ProgressHUD.error("plsEnterRightX".localizedFormat("phoneNumber".localized()))
                SuperToast.show(title: "plsEnterRightX".localizedFormat("phoneNumber".localized()))
            } else {
//                ProgressHUD.error("plsEnterRightX".localizedFormat("email".localized()))
                SuperToast.show(title: "plsEnterRightX".localizedFormat("email".localized()))
            }
            return
        }
        
        let invaitationCode = ""
        ProgressHUD.animate()
        AccountViewModel.requestCode(phone: vcType == .usePhone ? useTypeView.inputText : nil, areaCode: _areaCode, email: vcType == .useEmail ? useTypeView.inputText : nil, invaitationCode: invaitationCode, useFor: .deleteAccount) { [weak self] errCode, _ in
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
