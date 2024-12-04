//
//  BoBRedPacketTypeView.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/12/4.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import MMBAlertsPickers
import OUICore
import ProgressHUD
import RxCocoa
import RxSwift
import TangramKit
import UIKit
class BoBRedPacketTypeView: TGLinearLayout {
    var chooseRedPacketTypeBlock:((_ typeTitle:String,_ typeIndex:Int)->())!
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
        addSubview(btn1)
        addSubview(btn2)
        addSubview(btn3)
        addSubview(ViewFactoryUtil.smallDivider())
        addSubview(cancleBtn)
    }
    lazy var btn1: QMUIButton = {
        let r = ViewFactoryUtil.linkButton("拼手气红包")
        r.tg_width.equal(kScreenWidth-32)
        r.tg_height.equal(52)
        r.setTitleColor(.black333, for: .normal)
        r.titleLabel?.font = .mediumFont(16)
        r.rx.tap.subscribe(onNext: {[self] in
            if chooseRedPacketTypeBlock != nil{
                chooseRedPacketTypeBlock("拼手气红包",0)
            }
            GKCover.hide()
        })
        .disposed(by: rx.disposeBag)
        return r
    }()
    lazy var btn2: QMUIButton = {
        let r = ViewFactoryUtil.linkButton("普通红包")
        r.tg_width.equal(kScreenWidth-32)
        r.tg_height.equal(52)
        r.setTitleColor(.black333, for: .normal)
        r.titleLabel?.font = .mediumFont(16)
        r.rx.tap.subscribe(onNext: {[self] in
            if chooseRedPacketTypeBlock != nil{
                chooseRedPacketTypeBlock("普通红包",1)
            }
            GKCover.hide()
        })
        .disposed(by: rx.disposeBag)
        return r
    }()
    lazy var btn3: QMUIButton = {
        let r = ViewFactoryUtil.linkButton("专属红包")
        r.tg_width.equal(kScreenWidth-32)
        r.tg_height.equal(52)
        r.setTitleColor(.black333, for: .normal)
        r.titleLabel?.font = .mediumFont(16)
        r.rx.tap.subscribe(onNext: { [self] in
            if chooseRedPacketTypeBlock != nil{
                chooseRedPacketTypeBlock("专属红包",2)
            }
            GKCover.hide()
        })
        .disposed(by: rx.disposeBag)
        return r
    }()
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



