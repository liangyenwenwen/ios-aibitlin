//
//  MineSettingVC.swift
//  MyCloudMusic
//
//  Created by mac on 2024/5/6.
//

import UIKit
import TangramKit

class MineSettingVC: BaseTitleController {

    private let _viewModel = MineViewModel()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func initViews() {
        
        super.initViews()
        setBackGroundColor(.colorBackgroundAPP)
        initLinearLayoutSafeArea()
    
        title = R.string.localizable.set()
        
        container.tg_padding = UIEdgeInsets(top: PADDING_MEDDLE, left: PADDING_OUTER, bottom: PADDING_MEDDLE, right: PADDING_OUTER)
        container.tg_space = 12
        
        container.addSubview(topContentView)
        topContentView.addSubview(userMessageView)
        topContentView.addSubview(accountAndSafeView)
        topContentView.addSubview(changeLanguageView)
        topContentView.addSubview(privateView)
        topContentView.addSubview(privateDeletegeView)
        
        container.addSubview(logoOutView)
        
        
    }
    
    lazy var topContentView: TGLinearLayout = {
        let r = TGLinearLayout(.vert)
        r.tg_width.equal(.fill)
        r.tg_height.equal(.wrap)
        r.tg_space = 1
        r.corner(MEDDLE_RADIUS)
        r.backgroundColor = .white
        
        return r
    }()
    
    lazy var userMessageView: SuperSettingView = {
        let r = SuperSettingView.create(icon: R.image.mine_info_icon()!, title: R.string.localizable.myProfile(), click: { [weak self] data in
            print("个人资料")
            self?.navigationController?.pushViewController(MineMessageVC(), animated: true)
        })
        r.isMediumFont()
        return r
    }()
    
    lazy var accountAndSafeView: SuperSettingView = {
        let r = SuperSettingView.create(icon: R.image.mine_safe_icon()!, title: R.string.localizable.accountAndSecurity(), click: { [weak self] data in
            print("账号与安全")
            self?.navigationController?.pushViewController(MineAccountAddSafeVC(), animated: true)
        })
        r.isMediumFont()
        return r
    }()
    
    lazy var changeLanguageView: SuperSettingView = {
        let r = SuperSettingView.create(icon: R.image.mine_language_icon()!, title: "语言和地区".localized(), click: { [weak self] data in
            
            print("测试语言".localizedFormat("啊哈"))
            print("测试语言".localizedFormat("123123"))
//            self?.navigationController?.pushViewController(MineAccountAddSafeVC(), animated: true)
            let vc = LanguageTableViewController()
            self?.navigationController?.pushViewController(vc, animated: true)
        })
        r.isMediumFont()
        return r
    }()
    
    lazy var privateView: SuperSettingView = {
        let r = SuperSettingView.create(icon: R.image.mine_private_icon()!, title: R.string.localizable.personalPrivacy(), click: { [weak self] data in
            print("个人隐私")
            self?.gotoController(YFMineUserPrivateVC.self)
        })
        r.isMediumFont()
        return r
    }()
    
    lazy var privateDeletegeView: SuperSettingView = {
        let r = SuperSettingView.create(icon: R.image.mine_delegate_icon()!, title: R.string.localizable.policiesAndTerms(), click: { [weak self] data in
            let language = String.getCurrentLanguage()
            if language.starts(with: "zh")  {
                SuperWebController.start((self?.navigationController!)!, uri: "https://deal.aibitlin.com/#/pages/privacy/index?lang=zh")
            } else if language.starts(with: "th"){
                SuperWebController.start((self?.navigationController!)!, uri: "https://deal.aibitlin.com/#/pages/privacy/index?lang=Thai")
            } else {
                SuperWebController.start((self?.navigationController!)!, uri: "https://deal.aibitlin.com/#/pages/privacy/index?lang=en")
            }
        })
        r.isMediumFont()
        return r
    }()
    
    
    lazy var logoOutView: SuperSettingView = {
        let r = SuperSettingView.create(icon: R.image.mine_logout_icon()!, title: R.string.localizable.logout(),  ishaveMore:  false, click: { [weak self] data in
            
            self?.logoout()
        })
        r.corner()
        r.isMediumFont()
        return r
    }()
    
    func logoout()  {
        presentAlert(title: "logoutHint".localized()) { [weak self] in
            
            self?._viewModel.logout()
        }
    }
    
}
