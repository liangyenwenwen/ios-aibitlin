//
//  YFMineHomeBuyVipCardView.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/9/7.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import UIKit
import TangramKit
class YFMineHomeBuyVipCardView: TGLinearLayout {
    
    init() {
        super.init(frame: .zero, orientation: .vert)
        initViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initViews()
    }
    
    func initViews() {
        corner(12)
        border(.init(hexString: "#DBE0E5"))
        tg_padding = UIEdgeInsets(top: PADDING_LARGE2, left: PADDING_LARGE2, bottom: PADDING_LARGE2, right: PADDING_LARGE2)
        tg_space = 8
        
        tg_width.equal(.fill)
        tg_height.equal(.wrap)
        
        addSubview(vipRanKView)
        addSubview(vipPriceView)
    }
    
    lazy var vipRanKView: TGLinearLayout = {
        let r = TGLinearLayout(.horz)
        
        r.tg_width.equal(.fill)
        r.tg_height.equal(.wrap)
        r.tg_gravity = .vert.center
        
        r.addSubview(vipRank)
        r.addSubview(buyVip)
        
        return r
    }()
    
    lazy var vipRank: UILabel = {
        let r = UILabel()
        r.tg_width.equal(.fill)
        r.tg_height.equal(.wrap)
        r.text = "VIP1"
        r.textColor = .init(hexString: "#388CEF")
        r.font = UIFont(name: "PingFangSC-Semibold", size: 16)
        return r
    }()
    
    lazy var buyVip: TGLinearLayout = {
        let r = TGLinearLayout(.horz)
        
        r.tg_padding = UIEdgeInsets(top: 0, left: PADDING_MEDDLE, bottom: 0, right: PADDING_MEDDLE)
        r.corner(12)
        r.tg_width.equal(.wrap)
        r.tg_height.equal(24)
        r.backgroundColor = .init(hexString: "#388CEF")
        r.tg_gravity = .vert.center
        
        r.addSubview(buyVipLbl)
        return r
    }()
    
    lazy var buyVipLbl: UILabel = {
        let r = UILabel()
        r.tg_width.equal(.wrap)
        r.tg_height.equal(.wrap)
        r.text = "购买".localized()
        r.font = UIFont(name: "PingFangSC-Medium", size: 12)
        r.textAlignment = .center
        r.textColor = .white
        return r
    }()
    
    
    
    lazy var vipPriceView: TGLinearLayout = {
        let r = TGLinearLayout(.horz)
        
        r.tg_gravity = .vert.bottom
        r.tg_width.equal(.fill)
        r.tg_height.equal(.wrap)
        
        r.addSubview(vipPrice)
        r.addSubview(vipTime)
        return r
    }()
    
    lazy var vipPrice: UILabel = {
        let r = UILabel()
        r.text = "$9.99"
        r.textColor  = .black333
        r.font = .semiboldFont(36)
        r.tg_width.equal(.wrap)
        r.tg_height.equal(45)
        return r
    }()
    
    lazy var vipTime: UILabel = {
        let r = UILabel()
        r.text = "/"+"永久生效".localized()
        r.textColor  = .black333
        r.font = .semiboldFont(16)
        r.tg_width.equal(.fill)
        r.tg_height.equal(.wrap)
        r.tg_bottom.equal(6)
        return r
    }()
    
    
    
    
    
    func addVipDescription(vipRank: Int)  {
        switch vipRank {
            case 1:
            self.vipRank.text = "VIP1"
                addSubview(vipContentView(vipDescriptionStr: R.string.localizable.supportShortNumber("8")))
                addSubview(vipContentView(vipDescriptionStr: "支持显示博客7日访客数量并显示好友访问数据".localized()))
            case 2:
            self.vipRank.text = "VIP2"
                addSubview(vipContentView(vipDescriptionStr: R.string.localizable.supportShortNumber("7")))
                addSubview(vipContentView(vipDescriptionStr: "支持显示博客7日访客数量并显示好友访问数据".localized()))
            case 3:
            self.vipRank.text = "VIP3"
                addSubview(vipContentView(vipDescriptionStr: R.string.localizable.supportShortNumber("6")))
                addSubview(vipContentView(vipDescriptionStr: "支持显示博客7日访客数以及全部访客明细".localized()))
                addSubview(vipContentView(vipDescriptionStr: "支持个性化访客通知，帮助获客".localized()))
            default:
                break
        }
    }
}

class vipContentView: TGLinearLayout {
    
    var vipDescriptionStr: String
    
    init(vipDescriptionStr: String) {
        self.vipDescriptionStr = vipDescriptionStr
        super.init(frame: .zero, orientation: .horz)
       
        initViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func initViews() {
        
        tg_width.equal(.fill)
        tg_height.equal(.wrap)
        tg_space = 12
        
        addSubview(leftImg)
        addSubview(vipDescription)
    }
    
    lazy var leftImg: UIImageView = {
        let r = ViewFactoryUtil.defalutImgView(R.image.vip_description()!, 20)
        return r
    }()
    
    lazy var vipDescription: UILabel = {
        let r = UILabel()
        r.textColor = .init(hexString: "#121417")
        r.font = .mediumFont(13)
        r.numberOfLines = 0
        r.text = vipDescriptionStr
        r.tg_width.equal(.fill)
        r.tg_height.equal(.wrap)
        return r
    }()
    
    
}
