//
//  MineDeleteAccountReasonBottomSheetView.swift
//  MyCloudMusic
//
//  Created by mac on 2024/5/7.
//

import UIKit
import TangramKit

class MineDeleteAccountReasonBottomSheetView: TGLinearLayout {
    var deleteAccountAction:(()->Void)!
    init() {
        super.init(frame: .zero, orientation: .vert)
        innerInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        innerInit()
    }
    
     func innerInit() {
        
        corner(MEDDLE_RADIUS)
        tg_width.equal(.fill)
        tg_height.equal(.wrap)
        tg_space = PADDING_OUTER
        tg_gravity = .horz.center
        tg_padding = UIEdgeInsets(top: PADDING_LARGE2, left: PADDING_LARGE2, bottom: PADDING_MEDDLE, right: PADDING_LARGE2)
        backgroundColor = .colorBackgroundAPP
        
        addSubview(titleLbl)
        
        addSubview(divideView)
        
        addSubview(tipLbl1)
        addSubview(tipLbl2)
        addSubview(tipLbl3)
        
        addSubview(ViewFactoryUtil.blankView(30))
        addSubview(cancleBtn)
        addSubview(trueBtn)
    }
    @objc func cancleClick(){
        GKCover.hide()
    }
    @objc func deleteAccountClick(){
        deleteAccountAction()
        GKCover.hide()
    }
    
    lazy var titleLbl: UILabel = {
        let r = ViewFactoryUtil.normalLbael()
        r.text = "确定删除你的账号吗".localized()
        return r
    }()
    
    lazy var divideView: UIView = {
        let r = ViewFactoryUtil.smallDivider(space: 20)
        return r
    }()
    
    lazy var tipLbl1: UILabel = {
        let r = ViewFactoryUtil.sectionTilteLbael("删除您的账户，AIbitlin所有服务都将无法继续使用，包括聊天、博客等。".localized())
        r.lineSpace(10)
        return r
    }()
    
    lazy var tipLbl2: UILabel = {
        let r = ViewFactoryUtil.sectionTilteLbael("我们将在7天内删除你的账号并清楚你的所有记录，请7天内不要登录此账号，否则会终止删除账号的进程。".localized())
        r.lineSpace(10)
        return r
    }()
    
    lazy var tipLbl3: UILabel = {
        let r = ViewFactoryUtil.sectionTilteLbael("注意：账号一经删除无法恢复".localized())
        r.textColor = .red
        return r
    }()
    
    lazy var cancleBtn: QMUIButton = {
        let r = ViewFactoryUtil.primaryHalfFilletButton()
        r.setTitle("取消".localized(), for: .normal)
        r.addTarget(self, action: #selector(cancleClick), for: .touchUpInside)
        return r
    }()
    
    lazy var trueBtn: QMUIButton = {
        let r = ViewFactoryUtil.primaryHalfFilletButton()
        r.backgroundColor = .black999
        r.setTitleColor(.black66, for: .normal)
        r.setTitle("DeleteAccount".localized(), for: .normal)
        r.addTarget(self, action: #selector(deleteAccountClick), for: .touchUpInside)
        return r
    }()
    
}
