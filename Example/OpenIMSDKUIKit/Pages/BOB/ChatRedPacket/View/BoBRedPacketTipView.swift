//
//  BoBRedPacketTipView.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/12/6.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import MMBAlertsPickers
import OUICore
import RxCocoa
import RxSwift
import RxGesture
import TangramKit
import UIKit
class BoBRedPacketTipView: TGLinearLayout {
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
        tg_padding = UIEdgeInsets(top: 0, left: PADDING_OUTER, bottom: PADDING_MEDDLE, right: PADDING_OUTER)
        backgroundColor = .white
        addSubview(titleLabel)
        addSubview(contentLabel)
        addSubview(closeBtn)
        closeBtn.snp_makeConstraints { make in
            make.centerX.equalTo(self)
            make.bottom.equalTo(-28)
            make.width.equalTo(160)
            make.height.equalTo(46)
        }
       
    }
    func bindData(redPacketInfo:RedPacketMessageStatus){
        titleLabel.text =  (redPacketInfo.data?.sendUserName ?? "") + "发的红包"
        contentLabel.text =  (redPacketInfo.data?.sendUserName ?? "") + "发的专属红包仅限" + (redPacketInfo.data?.receiverName ?? "") + "领取"
    }
    func bindTransferAccountData(transferInfo:TransferAccountsMessageStatus){
        titleLabel.text =  (transferInfo.data?.sendUserName ?? "") + "的转账"
        contentLabel.text =  (transferInfo.data?.sendUserName ?? "") + "的转账仅限" + (transferInfo.data?.receiverName ?? "") + "领取"
    }
    lazy var titleLabel: UILabel = {
        let r = UILabel()
        r.tg_left.equal(20)
        r.tg_right.equal(20)
        r.tg_height.equal(18)
        r.tg_top.equal(27)
        r.textColor = .black333
        r.font = .semiboldFont(18)
        r.textAlignment = .center
        return r
    }()
    lazy var contentLabel: UILabel = {
        let r = UILabel()
        r.tg_left.equal(20)
        r.tg_right.equal(20)
        r.tg_top.equal(16)
        r.tg_height.equal(.wrap)
        r.textColor = .black666
        r.font = .regularFont(14)
        r.textAlignment = .center
        return r
    }()
    lazy var closeBtn: QMUIButton = {
        let r = ViewFactoryUtil.linkButton("我知道了")
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
