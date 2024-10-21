//
//  YFMineChangePasswordVC.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/5/14.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import UIKit
import TangramKit
import RxSwift
import RxCocoa
import ProgressHUD
import OUICore


class YFMineChangePasswordVC: BaseTitleController {

    var vcType: MyStyle?
    
    var areCode: String?
    var phone: String?
    
    var email: String?
    
    var code: String!
    
    
    override func initViews() {
        
        super.initViews()
        setBackGroundColor(.colorBackgroundAPP)
        initLinearLayoutSafeArea()
    
        title = "ChangePassword".localized()
        
        container.tg_padding = UIEdgeInsets(top: PADDING_MEDDLE, left: PADDING_OUTER, bottom: PADDING_MEDDLE, right: PADDING_OUTER)
        container.tg_space = PADDING_OUTER
        
        container.addSubview(originalPasswordHeader)
        container.addSubview(oldPwdView)
        
        container.addSubview(ViewFactoryUtil.sectionTilteLbael("EnterTheNewPassword".localized()))
        container.addSubview(newPwdContentView)
        
        container.addSubview(pwdTipLbl)
        
        container.addSubview(trueBtn)
        
        updateUI()
        bindData()
        
    }
    
    
    lazy var originalPasswordHeader: UILabel = {
        let r = ViewFactoryUtil.sectionTilteLbael("EnterTheOriginalPassword".localized())
        return r
    }()
    
    lazy var oldPwdView: SuperSettingView = {
        let r = SuperSettingView.createInput("OriginalPassword".localized())
        r.isMediumFont()
        r.corner()
        r.tg_bottom.equal(14)
        r.isPwd()
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
        let r = SuperSettingView.createInput("NewPassword".localized())
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
    
    lazy var trueBtn: QMUIButton = {
        let  r = ViewFactoryUtil.primaryHalfFilletButton()
        r.tg_top.equal(24)
        r.setTitle("Confirm".localized(), for: .normal)
        r.addTarget(self, action: #selector(gotoNextVC), for: .touchUpInside)
        
        return r
    }()
    
    deinit {
        //保证定时器释放
        CountDownUtil.cancel()
        print(#file)
    }
    
    override func bindData() {
        
        if vcType == .forgetPwdByEmail || vcType == .forgetPwdByEmail {
            Observable.combineLatest(newPwdView.textFieldView.rx.text.orEmpty, rePwdView.textFieldView.rx.text.orEmpty) {
               $0.count > 7 && $1.count > 7
            }
            .bind(to: trueBtn.rx.isEnabled)
            .disposed(by: rx.disposeBag)
        } else  {
            Observable.combineLatest(oldPwdView.textFieldView.rx.text.orEmpty, newPwdView.textFieldView.rx.text.orEmpty, rePwdView.textFieldView.rx.text.orEmpty) {
                $0.count > 7 && $1.count > 7 && $2.count > 7
            }
            .bind(to: trueBtn.rx.isEnabled)
            .disposed(by: rx.disposeBag)
        }
        
    }
    
}


extension YFMineChangePasswordVC{
    
    func updateUI() {
        if vcType == .forgetPwdByEmailBylogin || vcType == .forgetPwdbyPhoneBylogin   {
            originalPasswordHeader.hide()
            oldPwdView.hide()
        }
        
        if vcType == .forgetPwdbyPhone {
            
        }
        
        if vcType == .forgetPwdByEmail {
            
        }
    }
    
    @objc func gotoNextVC()  {
        
        
        
        if !newPwdView.textFieldView.text!.validatePassword() {
//            ProgressHUD.error("plsEnterRightX".localizedFormat("password".localized()))
            SuperToast.show(title: "plsEnterRightX".localizedFormat("newpassword".localized()))
            return
        }
        
        if newPwdView.inputText != rePwdView.inputText {
//            ProgressHUD.error("twicePwdNoSame".localized())
            SuperToast.show(title: "twicePwdNoSame".localized())
            return
        }
        
        toComplate()
        
    }
    
    
    func toComplate() {
        
        if vcType == .forgetPwdByEmail || vcType == .forgetPwdByEmail {
            print("重置密码")
            self.navigationController?.popToRootViewController(animated: true)
        } else if vcType == .forgetPwdByEmailBylogin || vcType == .forgetPwdByEmailBylogin  {
            print("重置密码")
            ProgressHUD.animate()
            AccountViewModel.resetPassword(phone: vcType == .forgetPwdbyPhoneBylogin ? phone : nil,
                                           areaCode: areCode,
                                           email: vcType == .forgetPwdByEmailBylogin ? email : nil,
                                           verificationCode: code,
                                           password: oldPwdView.inputText!) { [weak self] (errCode, errMsg) in
                
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
        } else  {
            print("修改密码")
            if let IMUser = IMController.shared.currentUserRelay.value {
                
                AccountViewModel.changePassword(userID: IMUser.userID, current: oldPwdView.inputText!, to: newPwdView.inputText!) { errCode, errMsg in
                    print(errCode, errMsg)
                }
            }
        }
        
        
    }

    
}
