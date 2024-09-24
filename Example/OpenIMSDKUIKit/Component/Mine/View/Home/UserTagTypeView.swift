//
//  UserTagTypeView.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/8/30.
//  Copyright © 2024 rentsoft. All rights reserved.
//


import UIKit
import TangramKit

enum userTagType:Int {
    
    case vip = 0
    case blog
    case company
    
}


class UserTagTypeView: TGLinearLayout {

    var tagType : userTagType = .vip
    
    init() {
        super.init(frame: .zero, orientation: .horz)
        innerInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        innerInit()
    }
    
    func bindData(title: String, image: String) {
        contactLbl.text = title
        leftImg.image = .init(named: "\(image)")
    }
    
    func innerInit() {
        
        corner(6)
        tg_width.equal(.fill)
        tg_height.equal(12)
        tg_space = PADDING_SMALL
        tg_gravity = .vert.center
//        backgroundColor = .purple
        
        addSubview(leftImg)
        addSubview(contactLbl)
    }
    
    lazy var leftImg: UIImageView = {
        let r = ViewFactoryUtil.defalutImgView(R.image.facebook_icon()!, 8)
        r.tg_left.equal(4)
        return r
    }()
    
    lazy var contactLbl: UILabel = {
        let r = ViewFactoryUtil.customBoldTilteLable("VIP2",font: TEXT_TAG,textColor: .white)
        r.tg_width.equal(.wrap)
        r.tg_right.equal(4)
        return r
    }()
    
//    let imageArr = ["tag_vip", "tag_blog", "tag_company", "youtube"]
//    let dataArr = ["VIP2", "博客".innerLocalized(), "企业".innerLocalized(), "YouTube"]

    func updateUI() {
        switch tagType {
        case .vip:
            leftImg.image = R.image.tag_vip()!
             backgroundColor = .init(hexString: "#7238EF")
            contactLbl.text = "VIP"
        case .blog:
            leftImg.image = R.image.tag_blog()!
            backgroundColor = .init(hexString: "#EA896A")
            contactLbl.text = "博客".innerLocalized()
        case .company:
            leftImg.image = R.image.tag_company()!
            backgroundColor = .init(hexString: "#388CEF")
            contactLbl.text = "企业".innerLocalized()
        }
    }
    
    
}
