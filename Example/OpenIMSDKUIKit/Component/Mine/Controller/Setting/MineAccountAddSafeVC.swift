//
//  MineAccountAddSafeVC.swift
//  MyCloudMusic
//
//  Created by mac on 2024/5/6.
//

import UIKit
import TangramKit
import OUICore

class MineAccountAddSafeVC: BaseTitleController {

    override func initViews() {
        super.initViews()
        setBackGroundColor(.colorBackgroundAPP)
        initLinearLayoutSafeArea()
    
        title =  "AccountAndSecurity".localized()
        
        container.tg_padding = UIEdgeInsets(top: PADDING_MEDDLE, left: PADDING_MEDDLE, bottom: PADDING_MEDDLE, right: PADDING_MEDDLE)
        container.tg_space = PADDING_OUTER
        
        container.addSubview(titleView(type: 0))
        container.addSubview(accountMessageView)
        
//        container.addSubview(titleView(type: 1))
//        container.addSubview(bindMessageView)
        
        container.addSubview(titleView(type: 2))
        container.addSubview(deleteView)
        
    }
    
    
    lazy var accountMessageView: TGLinearLayout = {
        let r = TGLinearLayout(.vert)
        r.tg_width.equal(.fill)
        r.tg_height.equal(.wrap)
        r.tg_space = 1
        r.corner(MEDDLE_RADIUS)
        r.backgroundColor = .white
        
        r.addSubview(changePwdView)
        r.addSubview(ViewFactoryUtil.smallDivider())
        
        /// APP分离国内外
        if AppDelegate.shared.isChine {
            r.addSubview(changePhoneView)
        } else {
            r.addSubview(changeEmailView)
        }
//        r.addSubview(changeEmailView)
//        r.addSubview(ViewFactoryUtil.smallDivider())
//        r.addSubview(changePhoneView)
        
        return r
    }()
    
    
    lazy var changePwdView: SuperSettingView = {
        let r = SuperSettingView.createSetTitleAddContentView("ChangePassword".localized(), "") { [weak self] data in
            self?.gotoController(YFMineChangePasswordVC.self)
        }
        r.isMediumFont()
        return r
    }()
    
    lazy var changeEmailView: SuperSettingView = {
        let r = SuperSettingView.createSetTitleAddContentView("ChangeEmail".localized(), "") { [weak self] data in
//            self?.toDeleteAcountAuthenticationVC(.changeEmail)
            SuperToast.show(title: "开发中".localized())
        }
        r.isMediumFont()
        return r
    }()
    
    
    lazy var changePhoneView: SuperSettingView = {
        let r = SuperSettingView.createSetTitleAddContentView("ChangePhone".localized(), " ") { [weak self] data in
//            self?.toDeleteAcountAuthenticationVC(.changePhone)
            SuperToast.show(title: "开发中".localized())
        }
        r.isMediumFont()
        return r
    }()
    
    
    lazy var bindMessageView: TGLinearLayout = {
        let r = TGLinearLayout(.vert)
        r.tg_width.equal(.fill)
        r.tg_height.equal(.wrap)
        r.tg_space = 1
        r.corner(MEDDLE_RADIUS)
        r.backgroundColor = .white
        
        r.addSubview(bindFacebookView)
        r.addSubview(ViewFactoryUtil.smallDivider())
        r.addSubview(bindGoogleView)
        r.addSubview(ViewFactoryUtil.smallDivider())
        r.addSubview(bindAppleView)
        
        return r
    }()
    
    
    lazy var bindFacebookView: SuperSettingView = {
        let r = SuperSettingView.createSetTitleAddContentView("Facebook", "已绑定") { data in
            
        }
        r.isMediumFont()
        return r
    }()
    
    lazy var bindGoogleView: SuperSettingView = {
        let r = SuperSettingView.createSetTitleAddContentView("修改手机号", "未绑定") { data in
            
        }
        r.isMediumFont()
        return r
    }()
    
    
    lazy var bindAppleView: SuperSettingView = {
        let r = SuperSettingView.createSetTitleAddContentView("Apple", "已绑定") { data in
            
        }
        r.isMediumFont()
        return r
    }()
    
    
    lazy var deleteView: SuperSettingView = {
        let r = SuperSettingView.smallWithIcon(title: "DeleteAccount".localized()) { [weak self] data in
            self?.navigationController?.pushViewController(MineDeleteAccountReasonVC(), animated: true)
//            let characterSet = CharacterSet(charactersIn: "0123456789").inverted
//            if AccountViewModel.perLoginAccount?.rangeOfCharacter(from: characterSet, options: .literal, range: nil) == nil{
//                //是手机号
//                self?.toDeleteAcountAuthenticationVC(.usePhone)
//            }else{
//                self?.toDeleteAcountAuthenticationVC(.useEmail)
//            }
            
        }
        r.corner()
        r.isMediumFont()
        return r
    }()

    
    func titleView(type: Int) -> UILabel {
        let r = ViewFactoryUtil.normalLbael()
        switch type {
        case 0:
            r.text = "AccountInformation".localized()
        case 1:
            r.text = "BindingThirdPartyAccounts".localized()
        case 2:
            r.text = "DeleteAccount".localized()
        default:
            r.text = ""
        }
        r.textColor = .lightGray
        r.font = .systemFont(ofSize: TEXT_SMALL)
        return r
    }
    
    func toDeleteAcountAuthenticationVC(_ style: MyStyle) {
        let vc = MineDeleteAcountAuthenticationVC()
        vc.vcType = style
        self.gotoController(vc)
    }
    
    deinit {
        print(#function)
    }
}
