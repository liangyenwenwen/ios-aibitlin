//
//  YFAibitlinHomeView.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/10/28.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Foundation
import TangramKit

enum HomeLoginType {
    case phone
    case email
    case facebook
    case apple
    case google
    case sacnCode
    case wechat
    case qq
    case ali
    
    var imagename: String {
        switch self{
            
        case .phone:
            return "login_type_phone"
        case .email:
            return "login_type_email"
        case .facebook:
            return "login_type_facebook"
        case .apple:
            return "login_type_apple"
        case .google:
            return "login_type_google"
        case .sacnCode:
            return "login_type_scan"
        case .wechat:
            return "login_type_wechat"
        case .qq:
            return "login_type_qq"
        case .ali:
            return "login_type_ali"
        }
    }
    
    var titleName: String {
        switch self{
            
        case .phone:
            return "使用手机登录"
        case .email:
            return "使用邮箱登录"
        case .facebook:
            return "使用Facebook登录"
        case .apple:
            return "使用Apple登录"
        case .google:
            return "使用Google登录"
        case .sacnCode:
            return "扫码登录"
        case .wechat:
            return "使用微信登录"
        case .qq:
            return "使用qq登录"
        case .ali:
            return "使用阿里登录"
        }
    }
}

class YFAibitlinHomeLoginTypeView: TGRelativeLayout {
    
    var selectBlock:((HomeLoginType) -> Void)?
    var loginType: HomeLoginType = .phone
    
    init() {
        super.init(frame: CGRect.zero)
        initViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initViews()  {
        
        backgroundColor = .init(hexString: "#F5F5F5")
        
        tg_width.equal(.fill)
        tg_height.equal(48)
        corner(6)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(gotoLinke))
        addGestureRecognizer(tap)
        
        addSubview(leftImg)
        addSubview(centerLbl)
        
        leftImg.tg_centerY.equal(0)
        leftImg.tg_left.equal(10)
        
        centerLbl.tg_centerY.equal(0)
        centerLbl.tg_left.equal(50)
        centerLbl.tg_right.equal(50)
        centerLbl.tg_height.equal(.wrap)
    }
    
    lazy var leftImg: UIImageView = {
        let r = UIImageView()
        r.tg_width.equal(28)
        r.tg_height.equal(28)
        r.corner(4)
        return r
    }()
    
    lazy var centerLbl: UILabel = {
        let r = UILabel()
        r.textColor = .black333
        r.font = .mediumFont(13)
        r.numberOfLines = 1
        r.textAlignment = .center
        return r
    }()
    
    
    @objc func gotoLinke() {
        self.selectBlock?(loginType)
    }
}


extension YFAibitlinHomeLoginTypeView {
    
    static func bulidWith(loginType: HomeLoginType) -> YFAibitlinHomeLoginTypeView {
        let r = YFAibitlinHomeLoginTypeView()
        r.loginType = loginType
        r.leftImg.image = .init(named: loginType.imagename)
        r.centerLbl.text = loginType.titleName
        return r
    }
}

class YFAibitlinHomeLoginThridView: TGLinearLayout {
    
    var selectBlock:((HomeLoginType) -> Void)?
    
    init() {
        super.init(frame: .zero, orientation: .horz)
        initViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initViews()
    }
    
    func initViews() {
        tg_space = 40
        tg_width.equal(.wrap)
        tg_height.equal(.wrap)
        tg_centerX.equal(0)
        
        var arr:[HomeLoginType] = [.wechat, .qq, .ali]
        for item in arr {
            let r = ItemView.bulidView(loginType: item)
            addSubview(r)
            r.selectBlock = { [weak self] type in
                self?.selectBlock?(type)
            }
        }
        
    }
    
    
    class ItemView: TGLinearLayout {
        
        var loginType: HomeLoginType = .wechat
        var selectBlock:((HomeLoginType) -> Void)?
        
        init() {
            super.init(frame: .zero, orientation: .horz)
            tg_width.equal(.wrap)
            tg_height.equal(.wrap)
            
            addSubview(typeImg)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    
        lazy var typeImg: UIImageView = {
            let r = UIImageView()
            r.tg_width.equal(48)
            r.tg_height.equal(48)
            let tap = UITapGestureRecognizer(target: self, action: #selector(gotoLinke))
            r.isUserInteractionEnabled = true
            r.addGestureRecognizer(tap)
            return r
        }()
        
        @objc func gotoLinke() {
            self.selectBlock?(loginType)
        }
        
        static func bulidView(loginType: HomeLoginType) -> ItemView {
            let r = ItemView()
            r.loginType = loginType
            r.typeImg.image = .init(named: loginType.imagename)
            return r
        }
        
    }
    
    
}
