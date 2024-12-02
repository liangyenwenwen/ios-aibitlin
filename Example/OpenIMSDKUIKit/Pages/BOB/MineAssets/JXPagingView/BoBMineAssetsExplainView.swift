//
//  BoBMineAssetsExplainView.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/12/2.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import MMBAlertsPickers
import OUICore
import RxCocoa
import RxSwift
import RxGesture
import TangramKit
import UIKit
class BoBMineAssetsExplainView: TGLinearLayout {
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
        tg_padding = UIEdgeInsets(top: 0, left: PADDING_OUTER, bottom: PADDING_MEDDLE, right: PADDING_OUTER)
        backgroundColor = .white
        addSubview(titleLabel)
        addSubview(contentLabel)
        addSubview(closeBtn)
       
    }
    func bindData(quantityOfMoneyPOS:QuantityOfMoneyPOS?){
        titleLabel.text = "T+1钱包：" + String(format: "%.2f",(quantityOfMoneyPOS?.quantityOfMoney)!) + (quantityOfMoneyPOS?.currency)!
    }
    lazy var titleLabel: UILabel = {
        let r = UILabel()
        r.tg_left.equal(20)
        r.tg_right.equal(20)
        r.tg_height.equal(20)
        r.tg_top.equal(27)
        r.textColor = .black333
        r.font = .systemFont(ofSize: 18)
        r.textAlignment = .center
        return r
    }()
    lazy var contentLabel: UILabel = {
        let r = UILabel()
        r.tg_left.equal(20)
        r.tg_right.equal(20)
        r.tg_top.equal(0)
        r.tg_height.equal(.wrap)
        r.textColor = .black666
        r.font = .regularFont(14)
        r.text = "1.使用CNY在买币入金后、收取红包 后、收到内部转账后，将实行“T+1”加密货币提现限制；\n2.在此期间，您的交易活动（购买、红包、内部转账）不受影响；\n3.内部转账：对APP其他用户转账、对APP合作平台用户转账。"
        return r
    }()
    lazy var closeBtn: QMUIButton = {
        let r = ViewFactoryUtil.linkButton("我知道了")
        r.tg_width.equal(160)
        r.tg_height.equal(46)
        r.setTitleColor(.white, for: .normal)
        r.titleLabel?.font = .mediumFont(16)
        r.backgroundColor = .primaryColor
        r.corner(23)
        r.rx.tap.subscribe(onNext: { [self] in
            GKCover.hide()
        }).disposed(by: rx.disposeBag)
        return r
    }()
}

