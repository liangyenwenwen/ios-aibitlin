//
//  YFMineHomeBuyVipVC.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/9/7.
//  Copyright © 2024 rentsoft. All rights reserved.
//


import OUICore
import OUIIM
import TangramKit
import UIKit

class YFMineHomeBuyVipVC: BaseTitleController {


    override func initViews() {
        super.initViews()
        initLinearLayoutSafeArea()
        container.tg_padding = UIEdgeInsets(top: PADDING_OUTER, left: PADDING_OUTER, bottom: PADDING_OUTER, right: PADDING_OUTER)
        container.tg_space = 10
        
        title = "购买VIP服务".localized()
        
        container.addSubview(titleView)
        container.addSubview(descriptionView)
        addVipView()
    }
    
    lazy var titleView: UILabel = {
        let r = UILabel()
        r.tg_width.equal(.fill)
        r.tg_height.equal(.wrap)
        r.text = "购买VIP服务".localized()
        r.textColor = .black333
        r.font = .semiboldFont(22)
        return r
    }()
    
    lazy var descriptionView: UILabel = {
        let r = UILabel()
        r.tg_width.equal(.fill)
        r.tg_height.equal(.wrap)
        r.text = "会员服务永久有效，根据您的需要选择适合您的会员服务。".localized()
        r.textColor = .black333
        r.font = .mediumFont(16)
        return r
    }()
    
    func addVipView() {
        for index in 1...3 {
            let card = YFMineHomeBuyVipCardView()
            card.addVipDescription(vipRank: index)
            container.addSubview(card)
        }
    }
}
