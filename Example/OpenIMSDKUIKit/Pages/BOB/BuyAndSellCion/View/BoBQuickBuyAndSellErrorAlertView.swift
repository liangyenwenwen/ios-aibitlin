//
//  BoBQuickBuyAndSellErrorAlertView.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/12/29.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import MMBAlertsPickers
import OUICore
import ProgressHUD
import RxCocoa
import RxSwift
import TangramKit
import UIKit
class BoBQuickBuyAndSellErrorAlertView: TGLinearLayout {
    
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
        addSubview(errorIcon)
        addSubview(contentLabel)
        addSubview(errorLabel)
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
        errorIcon.snp_makeConstraints { make in
            make.centerX.equalTo(self)
            make.top.equalTo(66)
            make.width.height.equalTo(38)
        }
        contentLabel.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.height.equalTo(20)
            make.top.equalTo(errorIcon.snp_bottom).offset(18)
        }
        errorLabel.snp_makeConstraints { make in
            make.left.right.equalTo(contentLabel)
            make.height.equalTo(18)
            make.top.equalTo(contentLabel.snp_bottom).offset(7)
        }
    }
    lazy var titleLbl: UILabel = {
        let r = ViewFactoryUtil.customTilteLabelFill("提示", font: 18, textColor: .black333)
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
    lazy var errorIcon: UIImageView = {
        let r = UIImageView(image: UIImage(named: "quick_buy_or_sell_error_icon"))
        return r
    }()
    lazy var contentLabel: UILabel = {
        let r = UILabel()
        r.textColor = .black333
        r.font = .mediumFont(16)
        r.textAlignment = .center
        return r
    }()
    lazy var errorLabel: UILabel = {
        let r = UILabel()
        r.textColor = .init(hexString: "#F32525")
        r.font = .mediumFont(14)
        r.textAlignment = .center
        r.text = "暂无匹配的广告，请重新选择"
        return r
    }()
}
