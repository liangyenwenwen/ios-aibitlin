//
//  YFChooseShareTypeView.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2025/4/29.
//  Copyright © 2025 rentsoft. All rights reserved.
//

import MMBAlertsPickers
import OUICore
import ProgressHUD
import RxCocoa
import RxSwift
import TangramKit
import UIKit
class YFChooseShareTypeView: TGLinearLayout {
    var choosePushAdTypeBlock:((_ typeIndex:Int)->())!
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
//        tg_space = PADDING_MEDDLE
        tg_gravity = .horz.center
        tg_padding = UIEdgeInsets(top: PADDING_OUTER, left: PADDING_OUTER, bottom: PADDING_MEDDLE, right: PADDING_OUTER)
        backgroundColor = .white
    }
    func drawUI(array:[String]){
        for (index ,item) in array.enumerated() {
            let r = ViewFactoryUtil.linkButton(item)
            r.tg_width.equal(kScreenWidth-32)
            r.tg_height.equal(52)
            r.setTitleColor(.black333, for: .normal)
            r.titleLabel?.font = .mediumFont(16)
            r.rx.tap.subscribe(onNext: {[self] in
                if choosePushAdTypeBlock != nil{
                    choosePushAdTypeBlock(index)
                }
                GKCover.hide()
            }).disposed(by: rx.disposeBag)
            addSubview(r)
        }
        addSubview(ViewFactoryUtil.smallDivider())
        addSubview(cancleBtn)
    }
    lazy var cancleBtn: QMUIButton = {
        let r = ViewFactoryUtil.linkButton("取消")
        r.tg_width.equal(kScreenWidth-32)
        r.tg_height.equal(52)
        r.setTitleColor(.black333, for: .normal)
        r.titleLabel?.font = .mediumFont(16)
        r.rx.tap.subscribe(onNext: {
            GKCover.hide()
        })
        .disposed(by: rx.disposeBag)
        return r
    }()
}





