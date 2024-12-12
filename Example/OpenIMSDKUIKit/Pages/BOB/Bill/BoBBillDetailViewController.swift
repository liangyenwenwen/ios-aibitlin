//
//  BoBBillDetailViewController.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/12/2.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Foundation
import OUICore
class BoBBillDetailViewController: BaseTitleController {
    var changeType:Int = 0//1:转账 2:收款 3:购买 4:出售 5:红包 6:调账 7:私聊转账 8:群聊转账 9:兑换 10:红包退回 11:私聊转账退回 11:群聊转账退回
    var billListData:BillListData?
    var billDetail:BoBBillDetail?
    override func initViews() {
        
        super.initViews()
        view.backgroundColor = .colorBackgroundAPP
        initLinearLayoutSafeArea()
        title = "账单详情"
        container.tg_padding = UIEdgeInsets(top: 0, left: PADDING_OUTER, bottom: 0, right: PADDING_OUTER)
        container.addSubview(moneyLabel)
        container.addSubview(typTitleLabel)
        container.addSubview(lineView)
        moneyLabel.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.top.equalTo(40)
            make.height.equalTo(33)
        }
        typTitleLabel.snp_makeConstraints { make in
            make.left.right.equalTo(moneyLabel)
            make.top.equalTo(moneyLabel.snp_bottom).offset(19)
            make.height.equalTo(15)
        }
        lineView.snp_makeConstraints { make in
            make.left.right.equalTo(typTitleLabel)
            make.top.equalTo(150)
            make.height.equalTo(1)
        }
        if billListData?.changeType == 5 || billListData?.changeType == 6{
            //红包
            container.addSubview(orderTitleLabel)
            container.addSubview(orderLabel)
            container.addSubview(timeTitleLabel)
            container.addSubview(timeLabel)
            orderTitleLabel.snp_makeConstraints { make in
                make.left.equalTo(16)
                make.top.equalTo(lineView.snp_bottom).offset(14)
                make.width.equalTo(80)
            }
            orderLabel.snp_makeConstraints { make in
                make.left.equalTo(orderTitleLabel.snp_right).offset(16)
                make.right.equalTo(lineView)
                make.centerY.equalTo(orderTitleLabel)
            }
            timeTitleLabel.snp_makeConstraints { make in
                make.left.right.equalTo(orderTitleLabel)
                make.top.equalTo(orderLabel.snp_bottom).offset(10)
            }
            timeLabel.snp_makeConstraints { make in
                make.left.right.equalTo(orderLabel)
                make.centerY.equalTo(timeTitleLabel)
            }
            moneyLabel.text = (billListData?.changeZf)! + String(format: "%.2f ",(billListData?.amount)!)
            if billListData?.changeZf == "+"{
                moneyLabel.textColor = .init(hexString: "#FA7225")
                typTitleLabel.text = "红包-收到"
            }else{
                moneyLabel.textColor = .black333
                typTitleLabel.text = "红包"
            }
            if billListData?.changeType == 6{
                typTitleLabel.text = "调账"
            }

        }else{
            container.addSubview(addressTitleLabel)
            container.addSubview(addressLabel)
            container.addSubview(orderTitleLabel)
            container.addSubview(orderLabel)
            container.addSubview(timeTitleLabel)
            container.addSubview(timeLabel)
            addressTitleLabel.snp_makeConstraints { make in
                make.left.equalTo(16)
                make.top.equalTo(lineView.snp_bottom).offset(14)
                make.width.equalTo(80)
            }
            addressLabel.snp_makeConstraints { make in
                make.left.equalTo(addressTitleLabel.snp_right).offset(16)
                make.right.equalTo(lineView)
                make.top.equalTo(addressTitleLabel)
            }
            orderTitleLabel.snp_makeConstraints { make in
                make.left.right.equalTo(addressTitleLabel)
                make.top.equalTo(addressLabel.snp_bottom).offset(10)
            }
            orderLabel.snp_makeConstraints { make in
                make.left.right.equalTo(addressLabel)
                make.centerY.equalTo(orderTitleLabel)
            }
            timeTitleLabel.snp_makeConstraints { make in
                make.left.right.equalTo(addressTitleLabel)
                make.top.equalTo(orderLabel.snp_bottom).offset(10)
            }
            timeLabel.snp_makeConstraints { make in
                make.left.right.equalTo(addressLabel)
                make.centerY.equalTo(timeTitleLabel)
            }
            moneyLabel.text = (billListData?.changeZf)! + String(format: "%.2f ",(billListData?.amount)!)
            if billListData?.changeZf == "+"{
                moneyLabel.textColor = .init(hexString: "#FA7225")
            }else{
                moneyLabel.textColor = .black333
            }
            switch billListData?.changeType {
            case 1:
                typTitleLabel.text = "转账"
            case 2:
                typTitleLabel.text = "收款"
            case 3:
                typTitleLabel.text = "购买"
            case 4:
                typTitleLabel.text = "出售"
            case 7:
                if billListData?.changeZf == "+"{
                    typTitleLabel.text = "私聊-收款"
                }else{
                    typTitleLabel.text = "私聊-转账"
                }
            case 8:
                if billListData?.changeZf == "+"{
                    typTitleLabel.text = "群聊-收款"
                }else{
                    typTitleLabel.text = "群聊-转账"
                }
            case 10:
                typTitleLabel.text = "红包-退款"
                addressTitleLabel.text = "退单编号"
                addressLabel.numberOfLines = 1
                orderLabel.text = "退款时间"
                timeLabel.text = "原订单号"
            case 11:
                typTitleLabel.text = "私聊-退款"
                addressTitleLabel.text = "退单编号"
                addressLabel.numberOfLines = 1
                orderLabel.text = "退款时间"
                timeLabel.text = "原订单号"
                
            case 12:
                typTitleLabel.text = "群聊-退款"
                addressTitleLabel.text = "退单编号"
                addressLabel.numberOfLines = 1
                orderLabel.text = "退款时间"
                timeLabel.text = "原订单号"
            default: break
                
            }
            if billListData?.changeType == 1{
                container.addSubview(serviceChargeTitleLabel)
                container.addSubview(serviceChargeLabel)
                serviceChargeTitleLabel.snp_makeConstraints { make in
                    make.left.right.equalTo(addressTitleLabel)
                    make.top.equalTo(timeLabel.snp_bottom).offset(10)
                }
                serviceChargeLabel.snp_makeConstraints { make in
                    make.left.right.equalTo(addressLabel)
                    make.centerY.equalTo(serviceChargeTitleLabel)
                }
            }
            
        }
        loadData()
    }
    func loadData(){
        BoBPaymentModel.QueryBillDeatilRequest(code: billListData?.code ?? 0){data in
            self.billDetail = data
            self.updateUI()
        } completionHandler:{errCode,errMsg in
            SuperToast.show(title: errMsg)
        }
    }
    
    func updateUI(){
        moneyLabel.text = (billDetail?.direction)! + String(format: "%.2f",(billDetail?.amount)!)
        if billDetail?.direction == "+"{
            moneyLabel.textColor = .init(hexString: "#FA7225")
        }else{
            moneyLabel.textColor = .init(hexString: "#333333")
        }
        switch billDetail?.type {
        case 1:
            addressLabel.attributedText = getAttribute(str:(billDetail?.counterpartyAddress)!)
            orderLabel.attributedText = getAttribute(str:(billDetail?.orderNumber)!)
            timeLabel.text = billDetail?.tradingTime
            serviceChargeLabel.text = String(format: "%.2f",(billDetail?.handlingCharge)!) + " "  + (billDetail?.currency)!
        case 2,3,4:
            addressLabel.attributedText = getAttribute(str:(billDetail?.counterpartyAddress)!)
            orderLabel.attributedText = getAttribute(str:(billDetail?.orderNumber)!)
            timeLabel.text = billDetail?.tradingTime
        case 5,6:
            orderLabel.attributedText = getAttribute(str:(billDetail?.orderNumber)!)
            timeLabel.text = billDetail?.tradingTime
        case 7:
            if billListData?.changeZf == "+"{
                typTitleLabel.text = "私聊-收款"
            }else{
                typTitleLabel.text = "私聊-转账"
            }
            addressLabel.attributedText = getAttribute(str:(billDetail?.counterpartyAddress)!)
            orderLabel.text = billDetail?.orderNumber
            timeLabel.text = billDetail?.tradingTime
        case 8:
            if billListData?.changeZf == "+"{
                typTitleLabel.text = "群聊-收款"
            }else{
                typTitleLabel.text = "群聊-转账"
            }
            addressLabel.attributedText = getAttribute(str:(billDetail?.counterpartyAddress)!)
            orderLabel.text = billDetail?.orderNumber
            timeLabel.text = billDetail?.tradingTime
        case 10:
            typTitleLabel.text = "红包-退款"
            addressTitleLabel.text = "退款单号"
            addressLabel.numberOfLines = 1
            orderTitleLabel.text = "退款时间"
            timeTitleLabel.text = "原订单号"
            addressLabel.attributedText = getAttribute(str:(billDetail?.orderNumberBack)!)
            orderLabel.text = billDetail?.returnBackTime
            timeLabel.attributedText = getAttribute(str:(billDetail?.orderNumber)!)
            timeLabel.textColor = .primaryColor
        case 11:
            typTitleLabel.text = "私聊-退款"
            addressTitleLabel.text = "退款单号"
            addressLabel.numberOfLines = 1
            orderTitleLabel.text = "退款时间"
            timeTitleLabel.text = "原订单号"
            addressLabel.attributedText = getAttribute(str:(billDetail?.orderNumberBack)!)
            orderLabel.text = billDetail?.returnBackTime
            timeLabel.attributedText = getAttribute(str:(billDetail?.orderNumber)!)
            timeLabel.textColor = .primaryColor
            
        case 12:
            typTitleLabel.text = "群聊-退款"
            addressTitleLabel.text = "退款单号"
            addressLabel.numberOfLines = 1
            orderTitleLabel.text = "退款时间"
            timeTitleLabel.text = "原订单号"
            addressLabel.attributedText = getAttribute(str:(billDetail?.orderNumberBack)!)
            orderLabel.text = billDetail?.returnBackTime
            timeLabel.attributedText = getAttribute(str:(billDetail?.orderNumber)!)
            timeLabel.textColor = .primaryColor
        default: break
            
        }
    }
    func copyStr(str:String){
        UIPasteboard.general.string = str
        SuperToast.show(title: "复制成功".localized())
    }
    func getAttribute(str:String) -> NSMutableAttributedString{
        let attachment = NSTextAttachment()
        attachment.image = UIImage(named: "receive_payment_copy_icon")
        attachment.bounds = CGRect(x: 0, y: -3.0, width: 16, height: 16)
        let str1 = str + " "
        let attributedString = NSMutableAttributedString(string: str1)
        let attachmentString = NSAttributedString(attachment: attachment)
        
//        attributedString.append(attachmentString)
        attributedString.insert(attachmentString, at: str1.length)
        return attributedString
    }
    lazy var moneyLabel: UILabel = {
        let r = UILabel()
        r.textColor = .init(hexString: "#FA7225")
        r.font = .init(name: "PingFangSC-Medium", size: 36)
        r.textAlignment = .center
        return r
    }()
    lazy var typTitleLabel: UILabel = {
        let r = UILabel()
        r.textColor = .init(hexString: "#666666")
        r.font = .init(name: "PingFangSC-Medium", size: 16)
        r.textAlignment = .center
        return r
    }()
    lazy var lineView: UIView = {
        let r = UIView()
        r.backgroundColor = .init(hexString: "#EAEAEA")
        return r
    }()
    lazy var addressTitleLabel: UILabel = {
        let r = UILabel()
        r.textColor = .init(hexString: "#999999")
        r.font = .init(name: "PingFangSC-Medium", size: 14)
        r.text = "对方地址"
        return r
    }()
    lazy var addressLabel: UILabel = {
        let r = UILabel()
        r.textColor = .init(hexString: "#333333")
        r.font = .init(name: "PingFangSC-Medium", size: 14)
        r.numberOfLines = 2
        r.isUserInteractionEnabled = true
        r.text = " "
        let tap = UITapGestureRecognizer()
        tap.rx.event.subscribe {  _ in
            if self.billDetail != nil{
                if self.billDetail?.type == 1 || self.billDetail?.type == 2 || self.billDetail?.type == 3 || self.billDetail?.type == 4 || self.billDetail?.type == 7 || self.billDetail?.type == 8{
                    self.copyStr(str: self.billDetail?.counterpartyAddress ?? "")
                }
            }
            
        }.disposed(by: rx.disposeBag)
        r.addGestureRecognizer(tap)
        return r
    }()
    lazy var orderTitleLabel: UILabel = {
        let r = UILabel()
        r.textColor = .init(hexString: "#999999")
        r.font = .init(name: "PingFangSC-Medium", size: 14)
        r.text = "订单编号"
        return r
    }()
    lazy var orderLabel: UILabel = {
        let r = UILabel()
        r.textColor = .init(hexString: "#333333")
        r.font = .init(name: "PingFangSC-Medium", size: 14)
        r.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer()
        tap.rx.event.subscribe {  _ in
            if self.billDetail != nil{
                
                if self.billDetail?.type == 5 || self.billDetail?.type == 6{
                    self.copyStr(str: self.billDetail?.orderNumber ?? "")
                }else if self.billDetail?.type == 10 || self.billDetail?.type == 11 || self.billDetail?.type == 12{
                    self.copyStr(str: self.billDetail?.orderNumberBack ?? "")
                }
            }
            
        }.disposed(by: rx.disposeBag)
        r.addGestureRecognizer(tap)
        return r
    }()
    lazy var timeTitleLabel: UILabel = {
        let r = UILabel()
        r.textColor = .init(hexString: "#999999")
        r.font = .init(name: "PingFangSC-Medium", size: 14)
        r.text = "交易时间"
        return r
    }()
    lazy var timeLabel: UILabel = {
        let r = UILabel()
        r.textColor = .init(hexString: "#333333")
        r.font = .init(name: "PingFangSC-Medium", size: 14)
        let tap = UITapGestureRecognizer()
        tap.rx.event.subscribe {  _ in
            if self.billDetail != nil{
                if self.billDetail?.type == 10 || self.billDetail?.type == 11 || self.billDetail?.type == 12 {
                    self.copyStr(str: self.billDetail?.orderNumber ?? "")
                }
            }
            
        }.disposed(by: rx.disposeBag)
        r.addGestureRecognizer(tap)
        return r
    }()
    lazy var serviceChargeTitleLabel: UILabel = {
        let r = UILabel()
        r.textColor = .init(hexString: "#999999")
        r.font = .init(name: "PingFangSC-Medium", size: 14)
        r.text = "手续费"
        return r
    }()
    lazy var serviceChargeLabel: UILabel = {
        let r = UILabel()
        r.textColor = .init(hexString: "#333333")
        r.font = .init(name: "PingFangSC-Medium", size: 14)
        return r
    }()
}
