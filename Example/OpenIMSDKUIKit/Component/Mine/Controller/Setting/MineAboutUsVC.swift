//
//  MineAboutUsVC.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2025/3/11.
//  Copyright © 2025 rentsoft. All rights reserved.
//

import Foundation
import TangramKit
import OUICore

class MineAboutUsVC: BaseTitleController {
    
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
        
        title = "关于我们".localized()
        
        container.tg_padding = UIEdgeInsets(top: PADDING_MEDDLE, left: PADDING_OUTER, bottom: PADDING_MEDDLE, right: PADDING_OUTER)
        container.tg_space = 12
        container.addSubview(icon)
        container.addSubview(versionLabel)
    }
    lazy var icon: UIImageView = {
        let r = UIImageView(image: UIImage(named: "launch_logo"))
        r.tg_width.equal(100)
        r.tg_height.equal(100)
        r.tg_centerX.equal(0)
        r.tg_top.equal(60)
        return r
    }()
    lazy var versionLabel: UILabel = {
        let r = UILabel()
        r.tg_width.equal(.fill)
        r.tg_height.equal(20)
        r.textAlignment = .center
        r.font = .semiboldFont(18)
        r.textColor = .black333
        let infoDictionary = Bundle.main.infoDictionary
        let displayName = "Aibitlin"
        let majorVersion = infoDictionary!["CFBundleShortVersionString"] as! String
        r.text = "\(displayName) V\(majorVersion)"
        return r
    }()
}
