//
//  BoBChangePayPassWordViewController.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/11/29.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import UIKit
import TangramKit
import RxSwift
import RxCocoa
import ProgressHUD
import OUICore
class BoBChangePayPassWordViewController: BaseTitleController {
    var passWordType:Int = 0 // 0是设置，1是修改
    var changeSuccessBlock: ((_ changePayPassWord: Bool)->Void)!
    override func initViews() {
        
        super.initViews()
        setBackGroundColor(.colorBackgroundAPP)
        initLinearLayoutSafeArea()
        
        title = passWordType == 0 ? "设置安全密码" : "修改安全密码"
        
        container.tg_padding = UIEdgeInsets(top: PADDING_MEDDLE, left: PADDING_OUTER, bottom: PADDING_MEDDLE, right: PADDING_OUTER)
        container.tg_space = PADDING_OUTER
        if passWordType == 1{
            container.addSubview(sectionLbl)
            container.addSubview(topContentView)
        }
        

        container.addSubview(ViewFactoryUtil.sectionTilteLbael("输入新安全密码".localized()))
        container.addSubview(newPwdContentView)
        container.addSubview(nextBtn)
        
        bindData()
        
    }
    override func bindData() {
        Observable
            .combineLatest(oldPwdContentView.textFieldView.rx.text.orEmpty, newPwdView.textFieldView.rx.text.orEmpty, rePwdView.textFieldView.rx.text.orEmpty) {
                if self.passWordType == 0{
                   $0.count >= 0 && $1.count >= 6 && $2.count >= 6
                }else{
                    $0.count >= 6 && $1.count >= 6 && $2.count >= 6
                }
                
            }
            .bind(to: nextBtn.rx.isEnabled)
            .disposed(by: rx.disposeBag)
 
       
    }

    lazy var sectionLbl: UILabel = {
        let r = ViewFactoryUtil.sectionTilteLbael("输入原安全密码")
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
        r.addSubview(oldPwdContentView)
        return r
    }()
    
    lazy var oldPwdContentView: SuperSettingView = {
        let r = SuperSettingView.createInput("原密码".localized(),placeholder: "请输入原6位安全密码".localized())
        r.isMediumFont()
        r.isPwd()
        r.needLimitLength(length: 6)
        r.textFieldView.keyboardType = .asciiCapableNumberPad
        r.textFieldView.placeholder = "请输入原6位安全密码".localized()
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
        let r = SuperSettingView.createInput("新密码".localized(),placeholder: "请输入新6位安全密码".localized())
        r.isMediumFont()
        r.isPwd()
        r.needLimitLength(length: 6)
        r.textFieldView.keyboardType = .asciiCapableNumberPad
        r.textFieldView.placeholder = "请输入新6位安全密码".localized()
        return r
    }()
    
    
    lazy var rePwdView: SuperSettingView = {
        let r = SuperSettingView.createInput("再次输入".localized(),placeholder: "请输入新6位安全密码".localized())
        r.isMediumFont()
        r.isPwd()
        r.needLimitLength(length: 6)
        r.textFieldView.keyboardType = .asciiCapableNumberPad
        r.textFieldView.placeholder = "请输入新6位安全密码".localized()
        return r
    }()
    
    lazy var nextBtn: QMUIButton = {
        let  r = ViewFactoryUtil.primaryHalfFilletButton()
        r.setTitle("确认".localized(), for: .normal)
        r.addTarget(self, action: #selector(resetPwdAction), for: .touchUpInside)
        r.tg_top.equal(20)
        return r
    }()
    
    @objc func resetPwdAction()  {
        if newPwdView.inputText != rePwdView.inputText {
            SuperToast.show(title: "twicePwdNoSame".localized())
            return
        }
        ProgressHUD.animate()
        BoBPaymentModel.SetSecurityCodeRequest(userId: IMController.shared.uid, oldSecurityCode: oldPwdContentView.inputText ?? "", newSecurityCode: newPwdView.inputText ?? "", securityCode: newPwdView.inputText ?? "", type: passWordType){errCode,errMsg in
            if errCode == 20000{
                if self.passWordType == 0{
                    SuperToast.show(title:"设置成功")
                }else{
                    SuperToast.show(title:"修改成功")
                }
                if self.changeSuccessBlock != nil {
                    self.changeSuccessBlock(true)
                }
                self.navigationController?.popViewController(animated: true)
            }else{
                SuperToast.show(title: errMsg)
            }
        }
        
    }
}
