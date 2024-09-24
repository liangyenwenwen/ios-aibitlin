//
//  YFMineHomeBuyVipView.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/9/7.
//  Copyright © 2024 rentsoft. All rights reserved.
//


import UIKit
import TangramKit

class YFMineHomeBuyVipCell: BaseTableViewCell {

    override func initViews() {
        super.initViews()
        container.tg_padding = UIEdgeInsets(top: PADDING_OUTER, left: PADDING_OUTER, bottom: 0, right: PADDING_OUTER)
        
        container.addSubview(bokeIcon)
        
        container.addSubview(bokeMessageContainer)
        bokeMessageContainer.addSubview(bokeTitle)
        bokeMessageContainer.addSubview(bokeContent)
        
        container.backgroundColor = .white
    }

    lazy var bokeIcon: UIImageView = {
        let r = ViewFactoryUtil.cornerImgView(R.image.defaultAvatar()!, 60)
        r.tg_centerY.equal(0)
        return r
    }()

    lazy var bokeMessageContainer: TGLinearLayout = {
        let r = TGLinearLayout(.vert)
        r.tg_width.equal(.fill)
        r.tg_height.equal(.wrap)
        r.tg_space = PADDING_MEDDLE
        r.clipsToBounds = true
        return r
    }()
    
    lazy var bokeTitle: UILabel = {
        let r = ViewFactoryUtil.normalLbael()
        r.text = "标题"
        r.font = .systemFont(ofSize: TEXT_MEDDLE)
        return r
    }()
    
    lazy var bokeContent: UILabel = {
        let r = ViewFactoryUtil.normalLbael()
        r.text = "博客内容博客内容博客内容博客内容博客内容博客内容博客内容博客内容博客内容博客内容"
        r.numberOfLines = 1
        r.tg_width.equal(.fill)
        r.font = .systemFont(ofSize: TEXT_MEDDLE)
        return r
    }()

    lazy var cardBg: TGLinearLayout = {
        let r = TGLinearLayout(.vert)
        r.tg_width.equal(.fill)
        r.tg_height.equal(.wrap)
        r.corner(12)
        r.border(.init(hexString: "#DBE0E5"))
        return r
    }()
    
    lazy var vipRankView: TGLinearLayout = {
        let r = TGLinearLayout(.horz)
        r.tg_width.equal(.fill)
        r.tg_height.equal(.wrap)
        return r
    }()
    
    
}

