//
//  YFBillRecordView.swift
//  Alamofire
//
//  Created by mac on 2024/11/30.
//

import Foundation

class YFBillRecordView: UIView{
    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func initViews(){
        addSubview(titleLabel)
        addSubview(moneyLabel)
        addSubview(typTitleLabel)
        addSubview(lineView)
        addSubview(addressTitleLabel)
        addSubview(addressLabel)
        addSubview(orderTitleLabel)
        addSubview(orderLabel)
        addSubview(timeTitleLabel)
        addSubview(timeLabel)
        addSubview(serviceChargeTitleLabel)
        addSubview(serviceChargeLabel)
        titleLabel.snp_makeConstraints { make in
            make.left.right.equalTo(16)
            make.top.equalTo(12)
            make.right.equalTo(-16)
        }
        moneyLabel.snp_makeConstraints { make in
            make.left.right.equalTo(titleLabel)
            make.top.equalTo(52)
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
        addressTitleLabel.snp_makeConstraints { make in
            make.left.equalTo(titleLabel)
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
        serviceChargeTitleLabel.snp_makeConstraints { make in
            make.left.right.equalTo(addressTitleLabel)
            make.top.equalTo(timeLabel.snp_bottom).offset(10)
        }
        serviceChargeLabel.snp_makeConstraints { make in
            make.left.right.equalTo(addressLabel)
            make.centerY.equalTo(serviceChargeTitleLabel)
        }
    }
    func updateUI(billInfo:BillMessageSource){
        titleLabel.text = billInfo.title
        moneyLabel.text = (billInfo.externalTransferMessageVO?.direction ?? "") + String(format: "%.2f",(billInfo.externalTransferMessageVO?.amount ?? 0.00))
        if billInfo.externalTransferMessageVO?.direction == "+"{
            moneyLabel.textColor = .init(hexString: "#FA7225")
        }else{
            moneyLabel.textColor = .init(hexString: "#333333")
        }
        switch billInfo.externalTransferMessageVO?.type {
        case 1:
            typTitleLabel.text = "转账"
            addressTitleLabel.isHidden = false
            addressLabel.isHidden = false
            orderTitleLabel.isHidden = false
            orderLabel.isHidden = false
            timeTitleLabel.isHidden = false
            timeLabel.isHidden = false
            serviceChargeTitleLabel.isHidden = false
            serviceChargeLabel.isHidden = false
            addressTitleLabel.text = "对方地址"
            addressLabel.numberOfLines = 2
            addressLabel.text =  billInfo.externalTransferMessageVO?.counterpartyAddress ?? " "
            orderTitleLabel.text = "订单编号"
            orderLabel.text = billInfo.externalTransferMessageVO?.orderNumber
            timeTitleLabel.text = "交易时间"
            timeLabel.text = billInfo.externalTransferMessageVO?.tradingTime
            serviceChargeTitleLabel.text = "手续费"
            serviceChargeLabel.text = String(format: "%.2f ",(billInfo.externalTransferMessageVO?.handlingCharge ?? 0.00)) + (billInfo.externalTransferMessageVO?.currency ?? "")
        case 2,3,4:
            if billInfo.externalTransferMessageVO?.type == 2{
                typTitleLabel.text = "收款"
            }else if billInfo.externalTransferMessageVO?.type == 3{
                typTitleLabel.text = "购买"
            }else{
                typTitleLabel.text = "出售"
            }
            addressTitleLabel.isHidden = false
            addressLabel.isHidden = false
            orderTitleLabel.isHidden = false
            orderLabel.isHidden = false
            timeTitleLabel.isHidden = false
            timeLabel.isHidden = false
            serviceChargeTitleLabel.isHidden = true
            serviceChargeLabel.isHidden = true
            addressTitleLabel.text = "对方地址"
            addressLabel.numberOfLines = 2
            addressLabel.text =  billInfo.externalTransferMessageVO?.counterpartyAddress ?? " "
            orderTitleLabel.text = "订单编号"
            orderLabel.text = billInfo.externalTransferMessageVO?.orderNumber
            timeTitleLabel.text = "交易时间"
            timeLabel.text = billInfo.externalTransferMessageVO?.tradingTime
        case 10,11,12:
            if billInfo.externalTransferMessageVO?.type == 10{
                typTitleLabel.text = "红包-退回"
            }else{
                typTitleLabel.text = "转账-退回"
            }
            addressTitleLabel.isHidden = false
            addressLabel.isHidden = false
            orderTitleLabel.isHidden = false
            orderLabel.isHidden = false
            timeTitleLabel.isHidden = false
            timeLabel.isHidden = false
            serviceChargeTitleLabel.isHidden = true
            serviceChargeLabel.isHidden = true
            addressTitleLabel.text = "退款单号"
            addressLabel.numberOfLines = 1
            addressLabel.text =  billInfo.externalTransferMessageVO?.orderNumberBack ?? " "
            orderTitleLabel.text = "退款时间"
            orderLabel.text = billInfo.externalTransferMessageVO?.returnBackTime
            timeTitleLabel.text = "原订单号"
            timeLabel.text = billInfo.externalTransferMessageVO?.orderNumber
        default: break
            
        }
    }
    lazy var titleLabel: UILabel = {
        let r = UILabel()
        r.textColor = .init(hexString: "#666666")
        r.font = .init(name: "PingFangSC-Medium", size: 14)
        return r
    }()
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
        r.text = " "
        r.numberOfLines = 2
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
