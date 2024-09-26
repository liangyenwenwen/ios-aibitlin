//
//  UserMessageHeaderView.swift
//  MyCloudMusic
//
//  Created by mac on 2024/5/7.
//

import UIKit
import TangramKit
import OUICore

class UserMessageHeaderView: TGLinearLayout {

    init() {
        super.init(frame: .zero, orientation: .vert)
        innerInit()
        corner()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        innerInit()
    }
    
    func innerInit() {
        
        corner(MEDDLE_RADIUS)
        tg_width.equal(.fill)
        tg_height.equal(.wrap)
        tg_space = PADDING_MEDDLE
        tg_gravity = .horz.center
        tg_padding = UIEdgeInsets(top: PADDING_OUTER, left: PADDING_OUTER, bottom: PADDING_OUTER, right: PADDING_OUTER)
        
        backgroundColor = .init(patternImage: R.image.blur_bg()!)
//        backgroundColor = .green
        
        addTopUserMessage()
        
        addSubview(phoneView)
        addSubview(emailView)
        
        addSubview(userIntroLbl)
        
        addSubview(thridView)
    }
    
    func addTopUserMessage() {
        let userView = TGLinearLayout(.horz)
//        userView.backgroundColor = .white
        userView.corner(MEDDLE_RADIUS)
        userView.tg_width.equal(.fill)
        userView.tg_height.equal(.wrap)
//        userView.tg_padding = UIEdgeInsets(top: 0, left: 0, bottom: PADDING_OUTER, right: 0)
        userView.tg_space = PADDING_MEDDLE
        userView.tg_gravity = .vert.center
        addSubview(userView)
    
//        userView.addSubview(userIcon)
        userView.addSubview(avatarImageView)
        
        let userMessageView = TGLinearLayout(.vert)
        userMessageView.tg_width.equal(.fill)
        userMessageView.tg_height.equal(.wrap)
        userMessageView.tg_space = PADDING_SMALL
        userView.addSubview(userMessageView)
        
        userMessageView.addSubview(username)
        userMessageView.addSubview(usertag)
        userMessageView.addSubview(userID)
        
        
    }

    lazy var userIcon: UIImageView = {
        let r = ViewFactoryUtil.circleImgView(R.image.place_boke_icon()!, 72)
//        r.backgroundColor = .white
        r.border(.white)
        return r
    }()
    
    lazy var avatarImageView: AvatarView = {
           let v = AvatarView()
        v.size = 72
        v.border(.white)
        v.corner(36)
        
           return v
    }()
    
    
    lazy var username: UILabel = {
        let r = ViewFactoryUtil.customBoldTilteLable("荷包蛋小朋友", font: TEXT_LARGE4)
        return r
    }()
    
    lazy var usertag : UserTagView = {
       let r = UserTagView()
        r.addThirdUI()
        return r
    }()
    
    lazy var userID: UILabel = {
        let r = ViewFactoryUtil.sectionTilteLbael()
        r.text = "@Richenda0728"
        return r
    }()
    
    lazy var phoneView: UserMessageContactView = {
        let r = UserMessageContactView()
        r.tg_width.equal(.fill)
        r.tg_height.equal(.wrap)
        r.bindData(data: "+86 17681117999")
        return r
    }()

    lazy var emailView: UserMessageContactView = {
        let r = UserMessageContactView()
        r.tg_width.equal(.fill)
        r.tg_height.equal(.wrap)
        r.bindData(data: "asdwasd111111@gmail.com", isPhone: false)
        return r
    }()
    
    lazy var userIntroLbl: UILabel = {
        let r = ViewFactoryUtil.sectionTilteLbael("梦想是一个人，带上狗狗，驾车环游世界，记录旅途中的美好生活，感受世界的美好。欢迎大家关注我的Ins：Richenda0728")
        r.lineSpace(10)
        r.textColor = .colorOnBackground
        return r
    }()
    
    lazy var thridView: UserMessageThridView = {
        let r = UserMessageThridView()
        r.addThirdUI()
//        r.backgroundColor = .red
        return r
    }()
    
}
