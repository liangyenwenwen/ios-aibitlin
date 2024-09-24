//
//  UserMessageContactView.swift
//  MyCloudMusic
//
//  Created by mac on 2024/5/7.
//

import UIKit
import TangramKit

class UserMessageContactView: TGLinearLayout {

    
    init() {
        super.init(frame: .zero, orientation: .horz)
        innerInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        innerInit()
    }
    
    func innerInit() {
        
        tg_gravity = .vert.center
        tg_space = 7
        
        addSubview(leftImg)
        addSubview(contactLbl)
        addSubview(rightImg)
    }
    
    lazy var leftImg: UIImageView = {
        let r = ViewFactoryUtil.defalutImgView(R.image.email_icon()!, 20)
        return r
    }()
    
    lazy var contactLbl: UILabel = {
        let r = ViewFactoryUtil.sectionTilteLbael("672222222@gmail.com")
        r.textColor = .colorOnBackground
        r.font = UIFont(name: "PingFangSC-Medium", size: 14)
        return r
    }()
    
    func bindData(data: String, isPhone: Bool = true) {
        contactLbl.text = data
        leftImg.image = isPhone ? R.image.phone_icon() : R.image.email_icon()
    }
    
    lazy var rightImg: UIImageView = {
        let r = ViewFactoryUtil.defalutImgView(R.image.copy_icon()!, 20)
        return r
    }()
}
