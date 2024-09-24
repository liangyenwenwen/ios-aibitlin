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
    
    override func initViews() {
        super.initViews()
        setBackGroundColor(.colorBackgroundAPP)
        initLinearLayoutSafeArea()
    
        title = R.string.localizable.changePassword()
        
        container.tg_padding = UIEdgeInsets(top: PADDING_MEDDLE, left: PADDING_OUTER, bottom: PADDING_MEDDLE, right: PADDING_OUTER)
        container.tg_space = PADDING_OUTER
        
        container.addSubview(originalPasswordHeader)
        container.addSubview(oldPwdView)
        
        container.addSubview(ViewFactoryUtil.sectionTilteLbael(R.string.localizable.enterTheNewPassword()))
        container.addSubview(newPwdContentView)
        
        container.addSubview(pwdTipLbl)
        
        container.addSubview(trueBtn)
        
        updateUI()
        bindData()
    }
    
    
    lazy var originalPasswordHeader: UILabel = {
        let r = ViewFactoryUtil.sectionTilteLbael(R.string.localizable.enterTheOriginalPassword())
        return r
    }()
    
    
    
    
    
    lazy var oldPwdView: SuperSettingView = {
        let r = SuperSettingView.createInput(R.string.localizable.originalPassword(), placeholder: R.string.localizable.pleaseFillIn())
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
        let r = SuperSettingView.createInput(R.string.localizable.newPassword(), placeholder: R.string.localizable.pleaseFillIn())
        r.isMediumFont()
        r.isPwd()
        return r
    }()
    
    
    lazy var rePwdView: SuperSettingView = {
        let r = SuperSettingView.createInput(R.string.localizable.enterAgain(), placeholder: R.string.localizable.pleaseFillIn())
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
        r.setTitle(R.string.localizable.confirm(), for: .normal)
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
               $0.count > 0 && $1.count > 0
            }
            .bind(to: trueBtn.rx.isEnabled)
            .disposed(by: rx.disposeBag)
        } else  {
            Observable.combineLatest(oldPwdView.textFieldView.rx.text.orEmpty, newPwdView.textFieldView.rx.text.orEmpty, rePwdView.textFieldView.rx.text.orEmpty) {
                $0.count > 0 && $1.count > 0 && $2.count > 0
            }
            .bind(to: trueBtn.rx.isEnabled)
            .disposed(by: rx.disposeBag)
        }
        
    }
    
}


extension YFMineChangePasswordVC{
    
    func updateUI() {
        if vcType == .forgetPwdByEmail || vcType == .forgetPwdByEmail   {
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
            ProgressHUD.error("plsEnterRightX".localizedFormat("password".localized()))
            return
        }
        
        if newPwdView.inputText != rePwdView.inputText {
            ProgressHUD.error("twicePwdNoSame".localized())
            return
        }
        
        toComplate()
        
    }
    
    
    func toComplate() {
        
        if vcType == .forgetPwdByEmail || vcType == .forgetPwdByEmail {
            print("重置密码")
            self.navigationController?.popToRootViewController(animated: true)
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
