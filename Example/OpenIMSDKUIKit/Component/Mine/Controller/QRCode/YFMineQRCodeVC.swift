//
//  YFMineQRCodeVC.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/10/9.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Foundation
import TangramKit

class YFMineQRCodeVC: BaseTitleController {
    
     var user: QueryUserInfo!
    
    override func initViews() {
        
        super.initViews()
        initScrollSafeArea()
        scrollViewContainer.tg_padding = UIEdgeInsets(top: PADDING_OUTER, left: PADDING_OUTER, bottom: PADDING_OUTER, right: PADDING_OUTER)
        scrollViewContainer.tg_space = 10
//        scrollView.backgroundColor = .red

        title = "我的二维码".localized()
        
        scrollViewContainer.addSubview(userCardView)

    }
    
    /// 用户卡片
    lazy var userCardView: TGLinearLayout = {
        let r = TGLinearLayout(.vert)
        r.tg_width.equal(.fill)
        r.tg_height.equal(.wrap)
        r.tg_top.equal(30)
        r.tg_gravity = .horz.center
        r.backgroundColor = .white
        r.corner(14)
        
        r.addSubview(userShowTitleView)
        r.addSubview(userEditTitleView)
        r.addSubview(codeView)
        
        return r
    }()
    
    ///未编辑状态的用户名
    lazy var userShowTitleView: TGLinearLayout = {
        let r = TGLinearLayout(.horz)
        r.tg_width.equal(.wrap)
        r.tg_height.equal(40)
        r.tg_space = 7
        r.tg_gravity = .vert.center
//        r.backgroundColor = .yellow
        r.addSubview(userNicknameLbl)
        r.addSubview(ViewFactoryUtil.defalutImgView(R.image.edit_icon()!, 16))
        return r
    }()
    
    lazy var userNicknameLbl: UILabel = {
        let r = UILabel()
        r.tg_width.equal(.wrap)
        r.tg_height.equal(.wrap)
        r.textColor = .black333
        r.font = .mediumFont(15)
        r.text = "用户昵称"
        return r
    }()
    
    ///未编辑状态的用户名
    lazy var userEditTitleView: TGLinearLayout = {
        let r = TGLinearLayout(.horz)
        r.tg_width.equal(.wrap)
        r.tg_height.equal(40)
        r.tg_space = 7
        r.tg_gravity = .vert.center
        r.addSubview(userNicknameTF)
//        r.backgroundColor = .yellow
        
        let chooseBtn = ViewFactoryUtil.imageBtn(R.image.choose_blue()!, 32)
        r.addSubview(chooseBtn)
        
        return r
    }()
    
    lazy var userNicknameTF: UITextField = {
        let r = UITextField()
        r.tg_width.equal(210)
        r.tg_height.equal(32)
        r.backgroundColor = .init(hexString: "#F5F5F5")
        r.corner(8)
        r.text = "111"
        return r
    }()
    
    lazy var codeView: UIView = {
        let r = UIView()
        r.tg_width.equal(260)
        r.tg_height.equal(260)
        r.border(.init(hexString: "#EAEAEA"), cornerRadius: 8)
        return r
    }()
    
    
}
