//
//  MineGeneralSettingVC.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2025/3/11.
//  Copyright © 2025 rentsoft. All rights reserved.
//

import UIKit
import TangramKit
import ProgressHUD
import OUICore

class MineGeneralSettingVC: BaseTitleController {

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
    
        title = "通用设置".localized()
        
        container.tg_padding = UIEdgeInsets(top: PADDING_MEDDLE, left: PADDING_OUTER, bottom: PADDING_MEDDLE, right: PADDING_OUTER)
        container.tg_space = 12
        
        container.addSubview(topContentView)
        
        topContentView.addSubview(aboutUsView)
        topContentView.addSubview(ViewFactoryUtil.smallDivider())
        topContentView.addSubview(clearChatHistoryView)
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
    
    lazy var aboutUsView: SuperSettingView = {
        let r = SuperSettingView.create(title: "关于我们".localized(), click: { [weak self] data in
            self?.navigationController?.pushViewController(MineAboutUsVC(), animated: true)
        })
        r.isMediumFont()
        return r
    }()
    lazy var clearChatHistoryView: SuperSettingView = {
        let r = SuperSettingView.create(title: "ClearChatHistory".localized(), click: { [weak self] data in
            self?.presentAlert(title: "ConfirmClearChatHistory".localized()) {
                ProgressHUD.animate(interaction: false)
                IMController.shared.deleteAllMsgFromLocalAndSvr(){res in
                    if res != nil {
                        ProgressHUD.success("ClearChatHistorySuccess".localized())
                    } else {
                        ProgressHUD.error("ClearChatHistoryFail".localized())
                    }
                }
            }
        })
        r.corner()
        r.isMediumFont()
        return r
    }()
}

