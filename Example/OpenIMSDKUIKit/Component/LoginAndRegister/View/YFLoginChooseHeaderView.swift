//
//  YFLoginChooseHeaderView.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/5/9.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import UIKit
import TangramKit

class YFLoginChooseHeaderView: TGRelativeLayout {
    
    var changeTypeClick:((MyStyle)->Void)!
    var back:(()->Void)!
    
    /// 使用邮箱 或者手机号
    var useType: MyStyle!
    /// 注册还是登录
    var vcType: MyStyle!
    
    init(useType: MyStyle = .usePhone, vcType: MyStyle = .isLogin) {
        super.init(frame: CGRect.zero)
        self.useType = useType
        self.vcType = vcType
        initViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initViews()  {
        
        tg_width.equal(.fill)
        tg_height.equal(.fill)
        
        addSubview(bottomLine)
        addSubview(container)
        if vcType == .isLogin {
            container.addSubview(centerContainer)
            centerContainer.addSubview(emailView)
            centerContainer.addSubview(phoneView)
        } else {
            container.addSubview(leftContainer)
            
            container.addSubview(centerContainer)
            centerContainer.addSubview(emailView)
            centerContainer.addSubview(phoneView)
            addLeftImageButton(R.image.arrowLeft()!.withTintColor())
            
            container.addSubview(rightContainer)
        }
        
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
        r.backgroundColor = .placeholder
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
        r.tg_height.equal(.fill)
        
        if vcType == .isRegister {
            r.tg_space = PADDING_LARGE2
        }
        return r
    }()
    
    lazy var emailView: YFTitleAddUnderlineChooseView = {
        let r = YFTitleAddUnderlineChooseView()
        r.tg_width.equal(.fill)
        r.tg_height.equal(.fill)
//        r.setData(vcType == .isLogin ? "使用邮箱登录" : "使用邮箱注册")
        r.setData("UseEmail".localized())
        r.viewClick = { [weak self] in
            self?.useType = .useEmail
            self?.refreshUI()
            self?.changeTypeClick(.useEmail)
        }
        return r
    }()
    
    lazy var phoneView: YFTitleAddUnderlineChooseView = {
        let r = YFTitleAddUnderlineChooseView()
        r.tg_width.equal(.fill)
        r.tg_height.equal(.fill)
//        r.setData(vcType == .isLogin ? "使用手机号登录" : "使用手机号注册", true)
        r.setData("UsePhone".localized())
        r.viewClick = { [weak self] in
            self?.useType = .usePhone
            self?.refreshUI()
//            self?.changeTypeClick(.usePhone)
        }
        return r
    }()
    
    func refreshUI()  {
        emailView.refresUI(useType == .useEmail)
        phoneView.refresUI(useType == .usePhone)
    }
    
    @discardableResult
    func addLeftImageButton(_ data:UIImage) -> QMUIButton {
        let r = ViewFactoryUtil.imageBtn(data)
        r.addTarget(self, action: #selector(leftBtnClick(_:)), for: .touchUpInside)
        leftContainer.addSubview(r)
        return r
    }
    
    @objc func leftBtnClick(_ sender: QMUIButton) {
        print(#function)
        CountDownUtil.cancel()
        back()
    }

}
