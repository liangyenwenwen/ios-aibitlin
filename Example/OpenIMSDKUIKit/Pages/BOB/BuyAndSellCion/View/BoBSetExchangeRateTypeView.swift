//
//  BoBSetExchangeRateTypeView.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/12/21.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import MMBAlertsPickers
import OUICore
import ProgressHUD
import RxCocoa
import RxSwift
import TangramKit
import UIKit
class BoBSetExchangeRateTypeView: TGLinearLayout {
    var chooseTypeBlock:((_ typeIndex:Int)->())!
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
        backgroundColor = .white
        addSubview(titleLbl)
        addSubview(closeBtn)
        addSubview(lineView1)
        addSubview(fixedView)
        addSubview(floatView)
        titleLbl.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(closeBtn.snp_left).offset(-15)
            make.top.equalTo(20)
        }
        
        closeBtn.snp_makeConstraints { make in
            make.right.equalTo(-16)
            make.centerY.equalTo(titleLbl)
            make.width.height.equalTo(28)
        }
        lineView1.snp_makeConstraints { make in
            make.top.equalTo(56)
            make.left.right.equalTo(0)
            make.height.equalTo(1)
        }
        fixedView.snp_makeConstraints { make in
            make.left.right.equalTo(0)
            make.top.equalTo(lineView1.snp_bottom)
            make.height.equalTo(72)
        }
        floatView.snp_makeConstraints { make in
            make.left.right.height.equalTo(fixedView)
            make.top.equalTo(fixedView.snp_bottom)
        }
        
    }
    lazy var titleLbl: UILabel = {
        let r = ViewFactoryUtil.customTilteLabelFill("选择汇率", font: 18, textColor: .black333)
        r.font = .mediumFont(18)
        r.textColor = .black333
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
    lazy var lineView1: UIView = {
        let r = UIView()
        r.backgroundColor = .init(hexString: "#F5F5F5")
        return r
    }()
    lazy var fixedView: UIView = {
        let r = UIView()
        let titleLabel = UILabel()
        titleLabel.textColor = .black333
        titleLabel.font = .mediumFont(16)
        titleLabel.text = "固定"
        r.addSubview(titleLabel)
        titleLabel.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.height.equalTo(18)
            make.top.equalTo(15)
        }
        let tipLabel = UILabel()
        tipLabel.textColor = .black999
        tipLabel.font = .regularFont(14)
        tipLabel.text = "设定不变的的价格，不受市场波动影响"
        r.addSubview(tipLabel)
        tipLabel.snp_makeConstraints { make in
            make.left.right.equalTo(titleLabel)
            make.height.equalTo(16)
            make.top.equalTo(titleLabel.snp_bottom).offset(7)
        }
        let lineView = UIView()
        lineView.backgroundColor = .init(hexString: "#F5F5F5")
        r.addSubview(lineView)
        lineView.snp_makeConstraints { make in
            make.left.right.bottom.equalTo(r)
            make.height.equalTo(1)
        }
        let tap = UITapGestureRecognizer()
        tap.rx.event.subscribe {[weak self]  _ in
            if self?.chooseTypeBlock != nil{
                self?.chooseTypeBlock(0)
            }
            GKCover.hide()
        }.disposed(by: rx.disposeBag)
        r.addGestureRecognizer(tap)
        return r
    }()
    lazy var floatView: UIView = {
        let r = UIView()
        let titleLabel = UILabel()
        titleLabel.textColor = .black333
        titleLabel.font = .mediumFont(16)
        titleLabel.text = "浮动"
        r.addSubview(titleLabel)
        titleLabel.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.height.equalTo(18)
            make.top.equalTo(15)
        }
        let tipLabel = UILabel()
        tipLabel.textColor = .black999
        tipLabel.font = .regularFont(14)
        tipLabel.text = "设定动态汇率。动态汇率＝市场价格×动态指数"
        r.addSubview(tipLabel)
        tipLabel.snp_makeConstraints { make in
            make.left.right.equalTo(titleLabel)
            make.height.equalTo(16)
            make.top.equalTo(titleLabel.snp_bottom).offset(7)
        }
        let lineView = UIView()
        lineView.backgroundColor = .init(hexString: "#F5F5F5")
        r.addSubview(lineView)
        lineView.snp_makeConstraints { make in
            make.left.right.bottom.equalTo(r)
            make.height.equalTo(1)
        }
        let tap = UITapGestureRecognizer()
        tap.rx.event.subscribe {[weak self]  _ in
            if self?.chooseTypeBlock != nil{
                self?.chooseTypeBlock(1)
            }
            GKCover.hide()
        }.disposed(by: rx.disposeBag)
        r.addGestureRecognizer(tap)
        return r
    }()
}
