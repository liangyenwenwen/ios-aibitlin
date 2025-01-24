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
    var transferAccountsMessage:TransferAccountsMessageStatus?
    var transferAccountsDetail:BoBSendTransferAccountsData?
    var updateTransferAccountsStatus:((_ status:String)->())!
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
        container.addSubview(sureBtn)
        topLineView.snp_makeConstraints { make in
            make.left.right.top.equalTo(0)
            make.height.equalTo(1)
        }
        sureBtn.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.bottom.equalTo(0)
            make.height.equalTo(56)
        }
        getTransferAccountsDetails()
    }
    func getTransferAccountsDetails(){
        BoBRedPacketModel.TransferAccountsDetailsRequest(code:transferAccountsMessage?.data?.code ?? ""){[weak self] data in
            self?.transferAccountsDetail = data
            self?.moneyLabel.text = String(format: "%.2f ",data.transferAmount ?? 0.00) + (data.currency ?? "")
            self?.descTitleLabel.text = "转账说明"
            self?.descLabel.text = data.instructions ?? ""
            self?.sendTimeTitleLabel.text = "转账时间"
            self?.sendTimeLabel.text = data.sendTime
            var status = "0"
            if data.sign == 1{
                //未领取
                self?.tipLabel.show()
                self?.statusImageView.image = UIImage(named: "mine_transfer_accounts_unreceive_icon")
                if self?.transferAccountsMessage?.data?.sendUserId == IMController.shared.uid{
                    //发送者
                    self?.statusLabel.text = "待" + (data.nickName ?? "") + "收款"
                    self?.tipLabel.text = "24小时内对方未收款将退还给你"
                    status = "0"
                }else{
                    self?.statusLabel.text = "待你收款"
                    self?.tipLabel.text = "24小时内你未收款将退还给对方"
                    self?.sureBtn.show()
                }
            }else if data.sign == 2{
                self?.receiveTimeView.show()
                self?.receiveTimeTitleLabel.text = "到账时间"
                self?.receiveTimeLabel.text = data.receiveTime
                //已领取
                self?.statusImageView.image = UIImage(named: "mine_transfer_accounts_receive_icon")
                if self?.transferAccountsMessage?.data?.sendUserId == IMController.shared.uid{
                    //发送者
                    self?.statusLabel.text = (data.nickName ?? "") + "已收款"
                }else{
                    self?.statusLabel.text = "你已收款"
                }
                status = "1"

            }else if data.sign == 3{
                //已过期
                self?.receiveTimeView.show()
                self?.receiveTimeTitleLabel.text = "退款时间"
                self?.receiveTimeLabel.text = data.returnTime
                self?.statusImageView.image = UIImage(named: "mine_transfer_accounts_expire_icon")
                if self?.transferAccountsMessage?.data?.sendUserId == IMController.shared.uid{
                    //发送者
                    self?.statusLabel.text = (data.nickName ?? "") + "过期未收款，已退还给你"
                }else{
                    self?.statusLabel.text = "你过期未收款，已退还给对方"
                }
                status = "2"
            }
            if self!.updateTransferAccountsStatus != nil{
                self!.updateTransferAccountsStatus(status)
            }
        } completionHandler:{errCode,errMsg in
            SuperToast.show(title: String(errCode) + "：" + String(errCode).localized())
        }
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
        r.hide()
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
//        r.text = "转账说明"
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
//        r.text = "转账时间"
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
        r.hide()
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
//        r.text = "到账时间"
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
    lazy var sureBtn: QMUIButton = {
        let r = ViewFactoryUtil.linkButton("确认收款")
        r.setTitleColor(.white, for: .normal)
        r.corner(28)
        r.hide()
        r.titleLabel?.font = .semiboldFont(14)
        r.backgroundColor = .primaryColor
        r.rx.tap.subscribe(onNext: { [self] in
            BoBRedPacketModel.ReceiveTransferAccountRequest(code:transferAccountsMessage?.data?.code ?? ""){[weak self]data in
                self?.sureBtn.hide()
                self?.transferAccountsDetail = data
                self?.moneyLabel.text = String(format: "%.2f ",data.transferAmount ?? 0.00) + (data.currency ?? "")
                self?.descTitleLabel.text = "转账说明"
                self?.descLabel.text = data.instructions ?? ""
                self?.sendTimeTitleLabel.text = "转账时间"
                self?.sendTimeLabel.text = data.sendTime
                var status = "0"
                if data.sign == 1{
                    //未领取
                    self?.tipLabel.show()
                    self?.statusImageView.image = UIImage(named: "mine_transfer_accounts_unreceive_icon")
                    if self?.transferAccountsMessage?.data?.sendUserId == IMController.shared.uid{
                        //发送者
                        self?.statusLabel.text = "待" + (data.nickName ?? "") + "收款"
                        self?.tipLabel.text = "24小时内对方未收款将退还给你"
                    }else{
                        self?.statusLabel.text = "待你收款"
                        self?.tipLabel.text = "24小时内你未收款将退还给对方"
                        self?.sureBtn.show()
                    }
                    status = "0"
                }else if data.sign == 2{
                    self?.tipLabel.hide()
                    self?.receiveTimeView.show()
                    self?.receiveTimeTitleLabel.text = "到账时间"
                    self?.receiveTimeLabel.text = data.receiveTime
                    //已领取
                    self?.statusImageView.image = UIImage(named: "mine_transfer_accounts_receive_icon")
                    if self?.transferAccountsMessage?.data?.sendUserId == IMController.shared.uid{
                        //发送者
                        self?.statusLabel.text = (data.nickName ?? "") + "已收款"
                    }else{
                        self?.statusLabel.text = "你已收款"
                    }
                    status = "1"
                }else if data.sign == 3{
                    //已过期
                    self?.tipLabel.hide()
                    self?.receiveTimeView.show()
                    self?.receiveTimeTitleLabel.text = "退款时间"
                    self?.receiveTimeLabel.text = data.returnTime
                    self?.statusImageView.image = UIImage(named: "mine_transfer_accounts_expire_icon")
                    if self?.transferAccountsMessage?.data?.sendUserId == IMController.shared.uid{
                        //发送者
                        self?.statusLabel.text = (data.nickName ?? "") + "过期未收款，已退还给你"
                    }else{
                        self?.statusLabel.text = "你过期未收款，已退还给对方"
                    }
                    status = "2"
                }
                if self!.updateTransferAccountsStatus != nil{
                    self!.updateTransferAccountsStatus(status)
                }
                
            }completionHandler: {errCode,errMsg in
                SuperToast.show(title: String(errCode) + "：" + String(errCode).localized())
            }
            
        }).disposed(by: rx.disposeBag)
        return r
    }()
}
