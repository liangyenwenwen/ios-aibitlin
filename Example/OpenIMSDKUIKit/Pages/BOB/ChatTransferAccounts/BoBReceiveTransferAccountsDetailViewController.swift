//
//  BoBReceiveTransferAccountsDetailViewController.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/12/6.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Foundation
import TangramKit
import OUICore
class BoBReceiveTransferAccountsDetailViewController: BaseTitleController {
    override func initViews() {
        super.initViews()
        view.backgroundColor = .colorBackgroundAPP
        //        setBackGroundColor(.colorBackgroundAPP)
        initLinearLayoutSafeArea()
        title = "转账"
        container.tg_padding = UIEdgeInsets(top: 0, left: PADDING_OUTER, bottom: PADDING_OUTER, right: PADDING_OUTER)
        container.addSubview(topLineView)
        container.addSubview(statusImageView)
        container.addSubview(statusLabel)
        container.addSubview(moneyLabel)
        container.addSubview(tipLabel)
        container.addSubview(lineView)
        container.addSubview(descView)
        container.addSubview(sendTimeView)
        container.addSubview(receiveTimeView)
        topLineView.snp_makeConstraints { make in
            make.left.right.top.equalTo(0)
            make.height.equalTo(1)
        }
        
        statusImageView.image = UIImage(named: "mine_transfer_accounts_receive_icon")
        statusLabel.text = "荷包蛋小朋友已收款"
        moneyLabel.text = "1998.67 C "
        tipLabel.text = "一天内对方未收款将退还给你"
        descLabel.text = "欠你的还给你"
        sendTimeLabel.text = "2024-01-26 16:56:34"
        receiveTimeLabel.text = "2024-01-26 16:58:12"
        
    }
    lazy var topLineView: UIView = {
        let r = ViewFactoryUtil.smallDivider()
        return r
    }()
    lazy var statusImageView: UIImageView = {
        let r = UIImageView()
        r.tg_top.equal(40)
        r.tg_width.equal(66)
        r.tg_height.equal(66)
        r.tg_centerX.equal(0)
        return r
    }()
    lazy var statusLabel: UILabel = {
        let r = UILabel()
        r.tg_top.equal(14)
        r.tg_height.equal(16)
        r.tg_width.equal(kScreenWidth-32)
        r.textColor = .black999
        r.font = .mediumFont(16)
        r.textAlignment = .center
        return r
    }()
    lazy var moneyLabel: UILabel = {
        let r = UILabel()
        r.tg_top.equal(20)
        r.tg_height.equal(32)
        r.tg_width.equal(kScreenWidth-32)
        r.textColor = .black333
        r.font = .mediumFont(36)
        r.textAlignment = .center
        return r
    }()
    lazy var tipLabel: UILabel = {
        let r = UILabel()
        r.tg_top.equal(20)
        r.tg_height.equal(16)
        r.tg_width.equal(kScreenWidth-32)
        r.textColor = .black666
        r.font = .mediumFont(16)
        r.textAlignment = .center
        return r
    }()
    lazy var lineView: UIView = {
        let r = ViewFactoryUtil.smallDivider()
        r.tg_top.equal(40)
        r.tg_height.equal(1)
        r.tg_left.equal(0)
        r.tg_width.equal(kScreenWidth-32)
        return r
    }()
    lazy var descView: TGLinearLayout = {
        let r = TGLinearLayout(.horz)
        r.tg_top.equal(12)
        r.tg_left.equal(0)
        r.tg_height.equal(18)
        r.tg_width.equal(kScreenWidth-32)
        r.tg_space = 16
        r.addSubview(descTitleLabel)
        r.addSubview(descLabel)
        return r
    }()
    lazy var descTitleLabel: UILabel = {
        let r = UILabel()
        r.tg_left.equal(0)
        r.tg_height.equal(.wrap)
        r.tg_width.equal(80)
        r.textColor = .black999
        r.font = .mediumFont(14)
        r.text = "转账说明"
        return r
    }()
    lazy var descLabel: UILabel = {
        let r = UILabel()
        r.tg_height.equal(.wrap)
        r.tg_width.equal(.wrap)
        r.textColor = .black333
        r.font = .mediumFont(14)
        return r
    }()
    lazy var sendTimeView: TGLinearLayout = {
        let r = TGLinearLayout(.horz)
        r.tg_top.equal(7)
        r.tg_left.equal(0)
        r.tg_height.equal(18)
        r.tg_width.equal(kScreenWidth-32)
        r.tg_space = 16
        r.addSubview(sendTimeTitleLabel)
        r.addSubview(sendTimeLabel)
        return r
    }()
    lazy var sendTimeTitleLabel: UILabel = {
        let r = UILabel()
        r.tg_left.equal(0)
        r.tg_height.equal(.wrap)
        r.tg_width.equal(80)
        r.textColor = .black999
        r.font = .mediumFont(14)
        r.text = "转账时间"
        return r
    }()
    lazy var sendTimeLabel: UILabel = {
        let r = UILabel()
        r.tg_height.equal(.wrap)
        r.tg_width.equal(.wrap)
        r.textColor = .black333
        r.font = .mediumFont(14)
        return r
    }()
    lazy var receiveTimeView: TGLinearLayout = {
        let r = TGLinearLayout(.horz)
        r.tg_top.equal(7)
        r.tg_left.equal(0)
        r.tg_height.equal(18)
        r.tg_width.equal(kScreenWidth-32)
        r.tg_space = 16
        r.addSubview(receiveTimeTitleLabel)
        r.addSubview(receiveTimeLabel)
        return r
    }()
    lazy var receiveTimeTitleLabel: UILabel = {
        let r = UILabel()
        r.tg_left.equal(0)
        r.tg_height.equal(.wrap)
        r.tg_width.equal(80)
        r.textColor = .black999
        r.font = .mediumFont(14)
        r.text = "到账时间"
        return r
    }()
    lazy var receiveTimeLabel: UILabel = {
        let r = UILabel()
        r.tg_height.equal(.wrap)
        r.tg_width.equal(.wrap)
        r.textColor = .black333
        r.font = .mediumFont(14)
        return r
    }()
}
