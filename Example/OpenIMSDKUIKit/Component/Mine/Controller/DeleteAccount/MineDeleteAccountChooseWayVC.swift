//
//  MineDeleteAccountChooseWayVC.swift
//  MyCloudMusic
//
//  Created by mac on 2024/5/6.
//

import UIKit
import TangramKit

class MineDeleteAccountChooseWayVC: BaseTitleController {

    override func initViews() {
        super.initViews()
        setBackGroundColor(.colorBackgroundAPP)
        initLinearLayoutSafeArea()
    
        title = R.string.localizable.identityVerification()
        
        container.tg_padding = UIEdgeInsets(top: PADDING_MEDDLE, left: PADDING_MEDDLE, bottom: PADDING_MEDDLE, right: PADDING_MEDDLE)
        container.tg_space = PADDING_OUTER
        

        container.addSubview(chooseView)

        
    }
    
    
    lazy var chooseView: TGLinearLayout = {
        let r = TGLinearLayout(.vert)
        r.tg_width.equal(.fill)
        r.tg_height.equal(.wrap)
        r.tg_space = 1
        r.corner(MEDDLE_RADIUS)
        r.backgroundColor = .white
        
        r.addSubview(phoneView)
        r.addSubview(ViewFactoryUtil.smallDivider())
        r.addSubview(emailView)
        
        return r
    }()
    
    
    lazy var phoneView: SuperSettingView = {
        let r = SuperSettingView.createNoromalView(R.string.localizable.phoneVerification()) { [weak self] data in
            self?.toDeleteAcountAuthenticationVC(.usePhone)
        }
        r.isMediumFont()
        return r
    }()
    
    lazy var emailView: SuperSettingView = {
        let r = SuperSettingView.createNoromalView(R.string.localizable.emailVerification()) { [weak self] data in
            self?.toDeleteAcountAuthenticationVC(.useEmail)
        }
        r.isMediumFont()
        return r
    }()
    
    
    func toDeleteAcountAuthenticationVC(_ style: MyStyle) {
        let vc = MineDeleteAcountAuthenticationVC()
        vc.vcType = style
        self.gotoController(vc)
    }
    
 
}
