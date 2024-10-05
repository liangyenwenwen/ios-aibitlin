//
//  MineBokeVisitorListCell.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/9/6.
//  Copyright © 2024 rentsoft. All rights reserved.
//


import UIKit
import TangramKit
import OUICore
import OUIIM
class MineBokeVisitorListCell: BaseTableViewCell {
    var visitor: BlogVisitorListModel!
    var toChatBlock:((_ sourceId: String)->Void)!
    
    override func initViews() {
        super.initViews()
        container.tg_padding = UIEdgeInsets(top: PADDING_MEDDLE, left: PADDING_OUTER, bottom: PADDING_MEDDLE, right: PADDING_OUTER)
        
        container.tg_gravity = .vert.center
        container.tg_space = 12
        container.addSubview(visitorAvatarView)
        
        let userMessageView = TGLinearLayout(.vert)
        userMessageView.tg_width.equal(.fill)
        userMessageView.tg_height.equal(.wrap)
        userMessageView.tg_space = PADDING_SMALL
        container.addSubview(userMessageView)
        
        userMessageView.addSubview(username)
        userMessageView.addSubview(tagLable)
        userMessageView.addSubview(userScanNumber)
        
//        container.addSubview(sendMessageLbl)
        container.addSubview(sendMessageBtn)
    }

    lazy var visitorAvatarView: TGRelativeLayout = {
        let r = TGRelativeLayout()
        r.tg_width.equal(56)
        r.tg_height.equal(56)
        
        r.addSubview(avatarImg)
        r.addSubview(avatarCompanyLogoImg)
        return r
    }()
    
    lazy var avatarImg: UIImageView = {
        let r = ViewFactoryUtil.defalutImgView(R.image.defaultAvatar()!, 56)
        r.corner(28)
        r.tg_left.equal(0)
        r.tg_top.equal(0)
        return r
    }()
    
    lazy var avatarCompanyLogoImg: UIImageView = {
        let r = ViewFactoryUtil.defalutImgView(R.image.logo()!, 16)
        r.corner(16)
        r.border(.white)
        r.tg_right.equal(0)
        r.tg_bottom.equal(0)
        r.hide()
        return r
    }()
    
    lazy var username: UILabel = {
        let r = ViewFactoryUtil.customBoldTilteLable("用户姓名", font: TEXT_LARGE)
        return r
    }()
    
//    lazy var usertag : UserTagView = {
//       let r = UserTagView()
//        r.addThirdUI()
//        return r
//    }()
    
    lazy var tagLable: UILabel = {
            let v = UILabel()
            v.font = UIFont(name: "PingFangSC-Semibold", size: 11)
            v.textColor = .init(hexString: "#7238EF")
            v.text = "[V4、\("企业".localized())、\("博客".localized())]".localized()
        v.tg_width.equal(.wrap)
        v.tg_height.equal(.wrap)
            return v
        }()
    
    lazy var userScanNumber: UILabel = {
        let r = ViewFactoryUtil.sectionTilteLbael()
        r.text = "1次访问"
        return r
    }()
    
    lazy var sendMessageLbl: UILabel = {
        let r = ViewFactoryUtil.normalLbael("发消息")
        r.qmui_outsideEdge = UIEdgeInsets(top: 7, left: -17, bottom: -7, right: -17)
        r.textColor = .white
        r.backgroundColor = .init(hexString: "#388CEF")
        return r
    }()
    
    lazy var sendMessageBtn: UIView = {
        let r = ViewFactoryUtil.lblViewButton(title: "发消息".localized())
        let tap = UITapGestureRecognizer(target: self, action: #selector(toChat))
        r.addGestureRecognizer(tap)
        return r
    }()
    
    
    func bindData(_ model:BlogVisitorListModel) {
        self.visitor = model
        avatarImg.show(model.lookUserTouXiang, "DefaultAvatar")
        username.text = model.lookUserName
        userScanNumber.text = R.string.localizable.visitorCount(model.ciShu > 99 ? "99+" : "\(model.ciShu)")
    }
    
//    func bindData(_ model:BlogVisitorListModel) {
//        self.visitor = model
//        avatarImg.show(model.lookUserTouXiang, "DefaultAvatar")
//        username.text = model.lookUserName
//        userScanNumber.text = R.string.localizable.visitorCount(model.ciShu > 99 ? "99+" : "\(model.ciShu)")
//    }
    
    func updateAboutChat() {
        userScanNumber.text = "\("关注了你".localized()) 2024-09-03"
        let lbl = sendMessageBtn.viewWithTag(20002) as! UILabel
        lbl.text = "关注".localized()
    }
    
    @objc func toChat()  {
        
        self.toChatBlock(visitor.lookUserId)
        
    }
}

