//
//  MineChooseBottomSheetView.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/5/15.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import UIKit
import TangramKit
import RxSwift
import RxCocoa

class UserMessageBottomSheetView: TGLinearLayout {

    var chooseTitle:((String)->())!
    
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
        tg_space = PADDING_MEDDLE
        tg_gravity = .horz.center
        tg_padding = UIEdgeInsets(top: PADDING_OUTER, left: PADDING_OUTER, bottom: PADDING_MEDDLE, right: PADDING_OUTER)
        backgroundColor = .colorBackgroundAPP
        
        addSubview(topView)
        
        addSubview(userIdLbl)
        
        addSubview(topContainer)
    }
    
    lazy var topView: TGLinearLayout = {
        let r = TGLinearLayout(.horz)
        r.tg_width.equal(.fill)
        r.tg_height.equal(.wrap)
        r.tg_gravity = .vert.center
        r.addSubview(titleLbl)
        r.addSubview(closeBtn)
        return r
    }()
    
    lazy var titleLbl: UILabel = {
        let r = ViewFactoryUtil.customTilteLabelFill("荷包蛋小朋友", font: 16, textColor: .colorOnBackground)
        r.font = UIFont(name: "PingFangSC-Medium", size: 16)
        return r
    }()
    
    lazy var closeBtn: QMUIButton = {
        let r = ViewFactoryUtil.imageBtn(R.image.close_cirle_icon()!, 28)
        r.rx.tap.subscribe(onNext: {
            GKCover.hide()
        })
        .disposed(by: rx.disposeBag)
        return r
    }()
    
    lazy var userIdLbl: UILabel = {
        let r = ViewFactoryUtil.sectionTilteLbael("ID:783957t89459")
        r.tg_top.equal(-5)
        return r
    }()

    lazy var topContainer: TGLinearLayout = {
        let r = TGLinearLayout(.vert)
        r.tg_width.equal(.fill)
        r.tg_height.equal(.wrap)
        r.backgroundColor = .white
        r.corner()
        r.hide()
        return r
    }()
    
    func addReportUI() {
        topContainer.show()
        let titleArr = ["发布不适当内容对我造成骚扰", "钱财欺诈", "怀疑账号被盗用", "其他"]
        for i in titleArr.indices {
            let settingView = SuperSettingView.onlylTitle(titleArr[i]) { [weak self] _ in
                self?.chooseTitle(titleArr[i])
            }
            settingView.isMediumFont()
            topContainer.addSubview(settingView)
            if i != titleArr.count - 1 {
                topContainer.addSubview(ViewFactoryUtil.smallDivider())
            }
        }
    }
    
    
    deinit {
        print(#file)
    }
    
}
