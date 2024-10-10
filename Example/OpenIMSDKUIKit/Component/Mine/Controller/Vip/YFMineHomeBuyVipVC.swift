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
        initScrollSafeArea()
        scrollViewContainer.tg_padding = UIEdgeInsets(top: PADDING_OUTER, left: PADDING_OUTER, bottom: PADDING_OUTER, right: PADDING_OUTER)
        scrollViewContainer.tg_space = 10
//        scrollView.backgroundColor = .red
        title = "购买VIP服务".localized()
        
        scrollViewContainer.addSubview(titleView)
        scrollViewContainer.addSubview(descriptionView)
//        superFooterContainerContainer.tg_bottom.equal(0)
        addVipView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        initVip()
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
        r.tg_bottom.equal(12)
        r.tg_top.equal(6)
        return r
    }()
    
    func addVipView() {
        for index in 1...3 {
            let card = YFMineHomeBuyVipCardView()
            card.tag = 12000 + index
            card.addVipDescription(vipRank: index)
            scrollViewContainer.addSubview(card)
            card.buyVipBlock = { [weak self] vipRank in
                self?.buyVip(vipRank: vipRank)
            }
        }
    }
}

extension YFMineHomeBuyVipVC {
    
    func initVip() {
        if let IMUser = IMController.shared.currentUserRelay.value {
            YFMineNetViewModel.vipPurchaseInitialize(paramters: ["userId": IMUser.userID ?? ""]) { data in
                
                let arr = data.components(separatedBy: ",")
                
                for str in arr {
                    let card = self.view.viewWithTag(Int(str)! + 12000) as! YFMineHomeBuyVipCardView
                    card.buyVip.backgroundColor = .white
                    card.buyVipLbl.text = "生效中".localized()
                    card.buyVipLbl.textColor = .init(hexString: "#999999")
 
                    card.buyVip.layer.borderWidth = 1
                    card.buyVip.layer.borderColor = UIColor.init(hexString: "#999999").cgColor
                    
                    card.buyVip.isUserInteractionEnabled = false
                }
                
            } completionHandler: { errCode, errMsg in
            
            }

        }
    }
    
    func buyVip(vipRank:Int) {
        
        
        if let IMUser = IMController.shared.currentUserRelay.value {
            YFMineNetViewModel.vipPurchaseSucceeds(paramters: ["userId": IMUser.userID ?? "", "vip": vipRank]) { data in
                self.initVip()
                
            } completionHandler: { errCode, errMsg in
            
            }

        }
    }

}
