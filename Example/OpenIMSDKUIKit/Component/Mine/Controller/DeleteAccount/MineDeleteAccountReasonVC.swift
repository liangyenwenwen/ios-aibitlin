//
//  MineDeleteAccountReasonVC.swift
//  MyCloudMusic
//
//  Created by mac on 2024/5/7.
//

import UIKit
import TangramKit

class MineDeleteAccountReasonVC: BaseTitleController {
    
    var vcType: MyStyle = .usePhone
    
    override func initViews() {
        super.initViews()
        setBackGroundColor(.colorBackgroundAPP)
        initLinearLayoutSafeArea()
    
        title = R.string.localizable.deleteAccount()
        
        container.tg_padding = UIEdgeInsets(top: PADDING_MEDDLE, left: PADDING_MEDDLE, bottom: PADDING_MEDDLE, right: PADDING_MEDDLE)
        container.tg_space = PADDING_OUTER
        
        container.addSubview(ViewFactoryUtil.sectionTilteLbael(R.string.localizable.reasonForDelete()))
        container.addSubview(topContentView)
        
//        container.addSubview(ViewFactoryUtil.blankView(20))
        container.addSubview(nextBtn)
    }
    
    lazy var topContentView: TGLinearLayout = {
        let r = TGLinearLayout(.vert)
        r.tg_width.equal(.fill)
        r.tg_height.equal(160)
        r.tg_space = 1
        r.corner(MEDDLE_RADIUS)
        r.backgroundColor = .white
        r.tg_padding = UIEdgeInsets(top: PADDING_MEDDLE, left: PADDING_MEDDLE, bottom: PADDING_MEDDLE, right: PADDING_MEDDLE)
        r.addSubview(reasonTextView)
        
        return r
    }()
    
    lazy var reasonTextView: QMUITextView = {
        let r = ViewFactoryUtil.normalTextView()
        return r
    }()
    
    
    lazy var nextBtn: QMUIButton = {
        let  r = ViewFactoryUtil.primaryHalfFilletButton()
        r.setTitle(R.string.localizable.deleteAccount(), for: .normal)
        r.addTarget(self, action: #selector(showSheet), for: .touchUpInside)
        r.tg_top.equal(20)
        return r
    }()
    
    
    @objc func showSheet()  {
        let contentView = MineDeleteAccountReasonBottomSheetView()
        contentView.tg_width.equal(.fill)
        // MARK: - 张亚飞打的标记  判断语言
        var height = String.getCurrentLanguage().starts(with: "zh") ? view.frame.height / 2 : view.frame.height * 2 / 3
        contentView.tg_height.equal(height)
        GKCover.cover(from: view, contentView: contentView, style: .translucent, showStyle: .bottom, showAnimStyle: .bottom, hideAnimStyle: .bottom, notClick: false)
    }
    
}
