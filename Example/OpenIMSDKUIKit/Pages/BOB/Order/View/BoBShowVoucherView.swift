//
//  BoBShowVoucherView.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/12/25.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import MMBAlertsPickers
import OUICore
import ProgressHUD
import RxCocoa
import RxSwift
import TangramKit
import UIKit
class BoBShowVoucherView: TGLinearLayout {
    
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
        tg_gravity = .horz.center
        tg_padding = UIEdgeInsets(top: 0, left: PADDING_OUTER, bottom: 0, right: PADDING_OUTER)
        addSubview(voucherImageView)
        addSubview(closeBtn)
    }
    lazy var voucherImageView: UIImageView = {
        let r = UIImageView()
        r.tg_width.equal(300)
        r.tg_height.equal(649)
        r.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer()
        tap.rx.event.subscribe { [weak self] _ in
            GKCover.hide()
        }.disposed(by: rx.disposeBag)
        r.addGestureRecognizer(tap)
        return r
    }()
    lazy var closeBtn: QMUIButton = {
        let r = QMUIButton()
        r.tg_top.equal(20)
        r.tg_width.equal(44)
        r.tg_height.equal(44)
        r.setImage(UIImage(named: "order_detail_show_voucher_close_icon"), for: .normal)
        r.rx.tap.subscribe(onNext: { [weak self] in
            GKCover.hide()
        }).disposed(by: rx.disposeBag)
        return r
    }()
}
