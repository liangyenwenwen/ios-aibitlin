//
//  UserThridTypeView.swift
//  MyCloudMusic
//
//  Created by mac on 2024/5/7.
//

import UIKit
import TangramKit

class UserMessageThridTypeView: TGLinearLayout {

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
        leftImg.image = .init(named: "\(image)_icon")
    }
    
    func innerInit() {
        
        corner(18)
        tg_width.equal(.fill)
        tg_height.equal(36)
        tg_space = PADDING_SMALL
        tg_gravity = .vert.center
        backgroundColor = .colorBackgroundAPP
        
        addSubview(leftImg)
        addSubview(contactLbl)
    }
    
    lazy var leftImg: UIImageView = {
        let r = ViewFactoryUtil.defalutImgView(R.image.facebook_icon()!, 28)
        r.tg_left.equal(5)
        return r
    }()
    
    lazy var contactLbl: UILabel = {
        let r = ViewFactoryUtil.sectionTilteLbael("Facebook 主页")
        r.textColor = .black43
        return r
    }()

}
