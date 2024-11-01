//
//  YFAibitlinHomeChooseHeaderView.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/10/28.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Foundation
import TangramKit

enum AibitlinHomeChooseHeaderType {
    case login
    case register
    case findPwd
}

class YFAibitlinHomeChooseHeaderView: TGRelativeLayout {
    var changeTypeClick:((Int)->Void)!
    var back:(()->Void)?
    
    var headerType: AibitlinHomeChooseHeaderType!
    var currentIndex: Int = 0
    
    init(headerType: AibitlinHomeChooseHeaderType) {
        super.init(frame: CGRect.zero)
        self.headerType = headerType
       
        initViews()
        updateTitle()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initViews()  {
        
        tg_width.equal(.fill)
        tg_height.equal(.fill)
        
        addSubview(bottomLine)
        addSubview(container)

        container.addSubview(leftContainer)
        
        container.addSubview(centerContainer)
        centerContainer.addSubview(leftView)
        centerContainer.addSubview(rightView)
        
        addLeftImageButton(R.image.arrowLeft()!.withTintColor())
        
        container.addSubview(rightContainer)
      
        
        refreshUI()
        
    }
    
    lazy var container: TGLinearLayout = {
        let r = TGLinearLayout(.horz)
        r.tg_width.equal(.fill)
        r.tg_height.equal(.fill)
        return r
    }()
    
    lazy var bottomLine: UIView = {
        let r = UIView()
        r.tg_bottom.equal(0)
        r.tg_width.equal(.fill)
        r.tg_height.equal(1)
        r.backgroundColor = .init(hexString: "#EAEAEA")
        return r
    }()
    
    
    private lazy var leftContainer: TGLinearLayout = {
        let r=TGLinearLayout(.horz)
        r.tg_gravity = TGGravity.vert.center
        r.tg_space = PADDING_SMALL
        r.tg_left.equal(12)
        r.tg_height.equal(.fill)
        r.tg_width.equal(40)
        return r
    }()
    
    private lazy var rightContainer: TGLinearLayout = {
        let r=TGLinearLayout(.horz)
        r.tg_gravity = [TGGravity.vert.center,TGGravity.horz.right]
        r.tg_space = PADDING_SMALL
        r.tg_right.equal(12)
        r.tg_height.equal(.fill)
        r.tg_space = PADDING_MEDDLE
        r.tg_width.equal(40)
        return r
    }()
    
    
    private lazy var centerContainer: TGLinearLayout = {
        let r = TGLinearLayout(.horz)
        r.tg_width.equal(.fill)
//        r.tg_left.equal(70)
//        r.tg_right.equal(70)
        r.tg_height.equal(.fill)
        r.tg_space = PADDING_LARGE2
        return r
    }()
    
    lazy var leftView: YFTitleAddUnderlineChooseView = {
        let r = YFTitleAddUnderlineChooseView()
        r.tg_width.equal(.fill)
        r.tg_height.equal(.fill)
        r.setData("UseEmail".localized())
        r.viewClick = { [weak self] in
            self?.currentIndex = 0
            self?.refreshUI()
            self?.changeTypeClick(0)
        }
        return r
    }()
    
    lazy var rightView: YFTitleAddUnderlineChooseView = {
        let r = YFTitleAddUnderlineChooseView()
        r.tg_width.equal(.fill)
        r.tg_height.equal(.fill)
//        r.setData(vcType == .isLogin ? "使用手机号登录" : "使用手机号注册", true)
        r.setData("UsePhone".localized())
        r.viewClick = { [weak self] in
            self?.currentIndex = 1
            self?.refreshUI()
            self?.changeTypeClick(1)
        }
        return r
    }()
    
    
    
    @discardableResult
    func addLeftImageButton(_ data:UIImage) -> QMUIButton {
        let r = ViewFactoryUtil.imageBtn(data)
        r.addTarget(self, action: #selector(leftBtnClick(_:)), for: .touchUpInside)
        leftContainer.addSubview(r)
        return r
    }
   

    
}

extension YFAibitlinHomeChooseHeaderView {
    
    func updateTitle() {
        switch self.headerType {
        case .login:
            leftView.setData("验证码登录".localized())
            rightView.setData("密码登录".localized())
        case .register:
            leftView.setData("使用邮箱注册".localized())
            rightView.setData("使用手机号注册".localized())
        case .findPwd:
            leftView.setData("使用邮箱找回".localized())
            rightView.setData("使用手机号找回".localized())
        case .none:
            break
        }
    }
    
    func refreshUI()  {
        leftView.refresUI(currentIndex == 0)
        rightView.refresUI(currentIndex == 1)
        
        
    }
    
    @objc func leftBtnClick(_ sender: QMUIButton) {
        print(#function)
        CountDownUtil.cancel()
        back?()
    }
}
