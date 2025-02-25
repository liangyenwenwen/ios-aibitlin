//
//  QRCodeSaveCardView.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/10/13.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Foundation
import TangramKit

class QRCodeSaveCardView: TGLinearLayout {
    
    var user: QueryUserInfo!
    
    init() {
        super.init(frame: .zero, orientation: .vert)
        innerInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        innerInit()
    }
    
    func innerInit() {
        tg_width.equal(.fill)
        tg_height.equal(.wrap)
        backgroundColor = .white
        addSubview(userCardView)
    }
    
    // MARK: - 张亚飞打的标记 卡片
    /// 用户卡片
    lazy var userCardView: TGLinearLayout = {
        let r = TGLinearLayout(.vert)
//        r.tg_width.equal(.fill)
        r.tg_height.equal(.wrap)
        r.tg_top.equal(2)
        r.tg_left.equal(2)
        r.tg_bottom.equal(2)
        r.tg_right.equal(2)
        r.tg_gravity = .horz.center
        r.backgroundColor = .white
        r.corner(14)
        
        r.addSubview(userShowTitleView)

        r.addSubview(codeView)
        
        codeView.addSubview(codeImgView)
        codeImgView.snp.makeConstraints { make in
            make.top.left.right.bottom.equalToSuperview().inset(10)
        }
        codeView.addSubview(userAvatarImgView)
        userAvatarImgView.snp.makeConstraints { make in
            make.width.height.equalTo(56)
            make.center.equalToSuperview()
        }
        
        
        r.addSubview(userIdTitleView)
        r.addSubview(tipLbl)
        
        r.addSubview(recommendBlogView)
        
        r.addSubview(lineView)
        r.addSubview(appIcon)

        return r
    }()
    
    
    ///未编辑状态的用户名
    lazy var userShowTitleView: TGLinearLayout = {
        let r = TGLinearLayout(.horz)
        r.tg_width.equal(.wrap)
        r.tg_height.equal(40)
        r.tg_space = 7
        r.tg_gravity = .vert.center
        r.tg_top.equal(38)
        r.addSubview(userNicknameLbl)
        return r
    }()
    
    lazy var userNicknameLbl: UILabel = {
        let r = UILabel()
        r.tg_width.equal(.wrap)
        r.tg_height.equal(.wrap)
        r.textColor = .black333
        r.font = .mediumFont(15)
        return r
    }()
    
    lazy var codeView: UIView = {
        let r = UIView()
        r.tg_width.equal(260)
        r.tg_height.equal(260)
        r.border(.init(hexString: "#EAEAEA"), cornerRadius: 8)
        r.tg_top.equal(17)
        return r
    }()
    
    lazy var codeImgView: UIImageView = {
        let r = UIImageView()
        return r
    }()
    
    lazy var userAvatarImgView: UIImageView = {
        let r = UIImageView()
        r.border(.white, borderWidth: 3, cornerRadius: 28)
        r.contentMode = .scaleAspectFill
        return r
    }()
    
    ///用户id展示
    lazy var userIdTitleView: TGLinearLayout = {
        let r = TGLinearLayout(.horz)
        r.tg_width.equal(.wrap)
        
        r.tg_height.equal(22)
        r.tg_space = 7
        r.tg_gravity = .vert.center
        r.tg_top.equal(24)
        

        r.addSubview(userIDLbl)

        return r
    }()
    
    lazy var userIDLbl: UILabel = {
        let lbl = UILabel()
        lbl.tg_width.equal(.wrap)
        lbl.tg_height.equal(.wrap)
        lbl.textColor = .black666
        lbl.font = .regularFont(13)
        return lbl
    }()
    
    
    lazy var tipLbl: UILabel = {
        let r = UILabel()
        r.text = "1.未下载APP的用户，扫你的二维码可直接下载哎比邻。\n2.未注册用户在登录页面扫你的二维码，免注册即可试用哎比邻，并自动收藏您推荐的网站。".localized()
        r.tg_left.equal(16)
        r.tg_right.equal(16)
        r.tg_height.equal(.wrap)
        r.tg_top.equal(19)
        r.font = .regularFont(13)
        r.textColor = .black999
        return r
    }()
    
    lazy var recommendBlogView: TGLinearLayout = {
        let r = TGLinearLayout(.horz)
        r.tg_width.equal(.wrap)
        r.tg_height.equal(.wrap)
        r.tg_space = 25
        r.tg_gravity = .vert.center
        r.tg_top.equal(38)
        
        for index in 0..<3 {
            let itemView  = SectionItemView()
            r.addSubview(itemView)
        }
        
        return r
    }()

    
    lazy var lineView: UIImageView = {
        let r = UIImageView()
        r.image = .init(named: "line_line")
        r.tg_left.equal(52)
        r.tg_right.equal(40)
        r.tg_height.equal(1)
        r.tg_top.equal(30)
        return  r
    }()
    
    lazy var appIcon: UIImageView = {
        let r = UIImageView()
        r.image = .init(named: "appicon_horz")
        r.tg_width.equal(69)
        r.tg_height.equal(24)
        r.tg_top.equal(15)
        r.tg_bottom.equal(19)
        return r
    }()
    
    
    func bindData(showname: String, codeImg: UIImage?, avater: UIImage?, idString: String?) {
        userNicknameLbl.text = showname
        codeImgView.image = codeImg
        userAvatarImgView.image = avater
        userIDLbl.text = idString
        
        refreshRecommend()
        
        layoutIfNeeded()
    }
    
    func refreshRecommend() {
        
        let data = YFFileDataUtil.readDataToFile(.recommend)
        
        if data.count == 0 {
            recommendBlogView.hide()
            return
        } else {
            recommendBlogView.show()
        }
        
        
        for index in recommendBlogView.subviews.indices {
            let item = recommendBlogView.subviews[index] as! SectionItemView
            item.index = index
            if index < data.count {
                item.show()
                item.bindDataNet(data[index])
            } else {
                item.hide()
            }
        }
    }
    
    
}
