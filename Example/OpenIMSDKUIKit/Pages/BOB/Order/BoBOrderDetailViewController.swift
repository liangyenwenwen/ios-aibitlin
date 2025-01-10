//
//  BoBOrderDetailViewController.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/12/24.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Foundation
import TangramKit
import OUICore


class BoBOrderDetailViewController: BaseTitleController {
    var code:String = ""
    var orderDetail:BoBMineOrderList?
    var countdownTime:Int = 0
    var timeCount:Int = 0
    private var timer: DispatchSourceTimer?
    private var refreshTimer: DispatchSourceTimer?
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    override func leftBtnClick(_ sender: QMUIButton) {
        self.navigationController?.popViewController(animated: true)
        IMController.shared.showStrongNoticeView()
        self.dismiss(animated: true)
        self.stopTimer()
        self.stopRefreshTimer()
    }
    override func initViews() {
        super.initViews()
        setBackGroundColor(.white)
        initScrollSafeArea()
        title = "订单详情"
        addLeftImageButton(R.image.arrowLeft()!.withTintColor())
        scrollViewContainer.tg_padding = UIEdgeInsets(top: 0, left: PADDING_OUTER, bottom: 0, right: PADDING_OUTER)
        superFooterContainerContainer.addSubview(bottomView)
        scrollViewContainer.addSubview(timeView)
        scrollViewContainer.addSubview(orderStatusView)
        scrollViewContainer.addSubview(orderDetailTitleLabel)
        scrollViewContainer.addSubview(orderNumberView)
        scrollViewContainer.addSubview(payMoneyView)
        scrollViewContainer.addSubview(unitPriceView)
        scrollViewContainer.addSubview(countView)
        scrollViewContainer.addSubview(paymentMethodView)
        scrollViewContainer.addSubview(paymentMethodNameView)
        scrollViewContainer.addSubview(payTitleLabel)
        scrollViewContainer.addSubview(payView)
        scrollViewContainer.addSubview(buyVoucherImageView)
        scrollViewContainer.addSubview(creatTimeView)
        scrollViewContainer.addSubview(payTimeView)
        scrollViewContainer.addSubview(dealDoneTimeView)
        scrollViewContainer.addSubview(checkPaymentVoucherLabel)
        scrollViewContainer.addSubview(orderAppealStatus)
        scrollViewContainer.hide()
        bottomView.hide()
        loadData()
    }
    deinit {
        self.stopTimer()
        self.stopRefreshTimer()
    }
    func loadData(){
        BoBBuyAndSellCionModel.OrderDetailsRequest(code: code) {[weak self] data in
            if self?.orderDetail == nil{
                self?.scrollViewContainer.show()
                self?.bottomView.show()
            }
            self?.timeCount = 0
            self?.orderDetail = data
            self?.updateUI()
        } completionHandler:{[weak self] errCode,errMsg in
            if self?.orderDetail == nil{
                SuperToast.show(title: errMsg)
            }
        }
    }
    func updateUI(){
        //进行中1、2、6、7、8、9、10、11才开启刷新
        if orderDetail?.orderStatus != 3 &&  orderDetail?.orderStatus != 4 {
            if refreshTimer == nil{
                startRefreshTimer()
            }
        }else{
            stopRefreshTimer()
        }
        //1:等待用户付款 2:等待商家确认 3:已完成 4:用户取消 5:商家取消 6:等待商家付款 7:等待用户确认 8:等待卖家接单 9:等待买家接单 10:已超时 11:申诉中
        if orderDetail?.orderStatus == 1 || orderDetail?.orderStatus == 6{
            title = orderDetail?.buyOrSell == 1 ? "等待您付款" : "等待买家付款"
            orderStatusLabel.text = orderDetail?.buyOrSell == 1 ? "订单交易资金已锁定，请放心转款" : "等待买家付款"
            orderStatusLabel.textColor = .black666
        }else if orderDetail?.orderStatus == 2 || orderDetail?.orderStatus == 7{
            title = orderDetail?.buyOrSell == 1 ? "等待卖家确认收款" : "请您确认收款"
            orderStatusLabel.text = orderDetail?.buyOrSell == 1 ? "订单交易资金已锁定，等待放款" : "买家已付款，请确认收款"
            orderStatusLabel.textColor = .black666
        }else if orderDetail?.orderStatus == 3{
            title = "交易完成"
            orderStatusLabel.textColor = .black666
            if orderDetail?.buyOrSell == 1{
                let text = "交易完成，查看账单确认资金是否到账"
                let attributedText = setupAttributedText(text: text, targetWords: ["账单"], color: .primaryColor)
                orderStatusLabel.attributedText = attributedText
            }else{
                orderStatusLabel.text = "交易成功，已放币给买家"
            }
            
        }else if orderDetail?.orderStatus == 4 || orderDetail?.orderStatus == 5{
            title = "交易取消"
            orderStatusLabel.text = orderDetail?.buyOrSell == 1 ? "交易取消，您可以选择新的卖家重新发起交易" : "交易取消，您可以选择新的买家重新发起交易"
            orderStatusLabel.textColor = .black666
        }else if orderDetail?.orderStatus == 8{
            title = orderDetail?.buyOrSell == 1 ? "等待卖家接单" : "等待您接单"
            orderStatusLabel.text = orderDetail?.buyOrSell == 1 ? "订单已创建，等待卖家接单" : "订单已创建，等待您接单"
            orderStatusLabel.textColor = .black666
        }else if orderDetail?.orderStatus == 9{
            title = orderDetail?.buyOrSell == 1 ? "等待您接单" : "等待买家接单"
            orderStatusLabel.text = orderDetail?.buyOrSell == 1 ? "订单已创建，等待您接单" : "订单已创建，等待买家接单"
            orderStatusLabel.textColor = .black666
        }else if orderDetail?.orderStatus == 10{
            title = "订单已超时"
            orderStatusLabel.text = "订单已超时，请勿付款"
            orderStatusLabel.textColor = .init(hexString: "#F32525")
        }else if orderDetail?.orderStatus == 11{
            title = "申诉中"
            if orderDetail?.representationType == 1{
                orderStatusLabel.text = "已发起申诉，请耐心等待"
                orderStatusLabel.textColor = .black666
            }else{
                orderStatusLabel.text = "对方发起申诉，请耐心等待"
                orderStatusLabel.textColor = .black666
            }
            
        }
            
        countdownTime = orderDetail?.countdownTime ?? 0
        if countdownTime > 0{
            stopTimer()
            timeView.show()
            timeLabel.text = convertSecondsToMinuteSecondFormat(countdownTime)
            startTimer()
        }else{
            timeView.hide()
        }
        if orderDetail?.buyOrSell == 1{
            //买家
            shortNameLabel.text = String((orderDetail?.advertisingNameSell ?? " ").prefix(1))
            nameLabel.text = orderDetail?.advertisingNameSell ?? ""
            shortNameLabel.backgroundColor = .init(hexString: "#5FA9FF")
            orderDetailTitleLabel.text = "购买" + " " + (orderDetail?.currency ?? "C")
            paymentMethodView.buyCounLabel.textColor = .black333
        }else{
            //卖家
            shortNameLabel.text = String((orderDetail?.advertisingNameBuy ?? " ").prefix(1))
            nameLabel.text = orderDetail?.advertisingNameBuy ?? ""
            shortNameLabel.backgroundColor = .init(hexString: "#FFA741")
            orderDetailTitleLabel.text = "出售" + " " + (orderDetail?.currency ?? "C")
            paymentMethodView.buyCounLabel.textColor = .primaryColor
        }
        orderNumberView.buyCounLabel.attributedText = getAttribute(str:(orderDetail?.orderNumber)!)
        payMoneyView.buyCounLabel.text = String(format: "¥%.2f", orderDetail?.amount ?? 0.00)
        unitPriceView.buyCountTitleLabel.text = "单价" + "(" + (orderDetail?.currency ?? "C") + ")"
        unitPriceView.buyCounLabel.text = String(format: "¥%.2f", orderDetail?.price ?? 0.00)
        countView.buyCountTitleLabel.text = "数量" + "(" + (orderDetail?.currency ?? "C") + ")"
        countView.buyCounLabel.text = String(format: "%.2f", orderDetail?.quantity ?? 0.00)
        paymentMethodView.buyCounLabel.text = orderDetail?.payment == 1 ? "银行卡" : (orderDetail?.payment == 2 ? "支付宝":"微信")
        if orderDetail?.paymentMethodDetails == nil && (orderDetail?.paymentCredentials ?? "").length == 0{
            paymentMethodNameView.hide()
            payTitleLabel.hide()
            payView.hide()
            buyVoucherImageView.hide()
        }else{
            payTitleLabel.show()
            if orderDetail?.buyOrSell == 1{
                paymentMethodNameView.hide()
                payTitleLabel.text = "卖家收款方式"
                payView.show()
                payView.bindData(type: orderDetail?.payment ?? 1 ,data: orderDetail?.paymentMethodDetails ?? paymentDdetailData())
                buyVoucherImageView.hide()
            }else{
                paymentMethodNameView.show()
                paymentMethodNameView.buyCounLabel.text = orderDetail?.payer ?? ""
                if (orderDetail?.paymentCredentials ?? "").length > 0{
                    payView.hide()
                    payTitleLabel.text = "买家支付凭证"
                    buyVoucherImageView.show()
                    buyVoucherImageView.sd_setImage(with: URL(string: orderDetail?.paymentCredentials))
                }else{
                    payTitleLabel.text = "我的收款方式"
                    payView.show()
                    payView.bindData(type: orderDetail?.payment ?? 1 ,data: orderDetail?.paymentMethodDetails ?? paymentDdetailData())
                    buyVoucherImageView.hide()
                }
            }
        }
        if (orderDetail?.payTime ?? "").length > 0{
            creatTimeView.show()
            payTimeView.show()
            creatTimeView.buyCounLabel.text = orderDetail?.creatTime
            payTimeView.buyCounLabel.text = orderDetail?.payTime
        }else{
            creatTimeView.hide()
            payTimeView.hide()
        }
        if (orderDetail?.completeTime ?? "").length > 0{
            dealDoneTimeView.show()
            dealDoneTimeView.buyCountTitleLabel.text = "交易完成时间"
            dealDoneTimeView.buyCounLabel.text = orderDetail?.completeTime
        }else{
            if (orderDetail?.canceTime ?? "").length > 0 && (orderDetail?.payTime ?? "").length > 0{
                dealDoneTimeView.show()
                dealDoneTimeView.buyCountTitleLabel.text = "交易取消时间"
                dealDoneTimeView.buyCounLabel.text = orderDetail?.canceTime
            }else{
                dealDoneTimeView.hide()
            }
        }
        if orderDetail?.buyOrSell == 1 && (orderDetail?.paymentCredentials ?? "").length > 0{
            checkPaymentVoucherLabel.show()
        }else{
            checkPaymentVoucherLabel.hide()
        }
        if orderDetail?.representationType == 1 || orderDetail?.representationTypeOther == 1{
            //申诉中
            orderAppealStatus.show()
            orderAppealStatus.text = "订单申诉中，请耐心等待..."
            orderAppealStatus.textColor = .init(hexString: "#F32525")
        }else if (orderDetail?.representationType == 2 && orderDetail?.representationTypeOther != 1) || (orderDetail?.representationType != 1 && orderDetail?.representationTypeOther == 2){
            //申诉完成
            orderAppealStatus.show()
            orderAppealStatus.text = "订单申诉已完成"
            orderAppealStatus.textColor = .primaryColor
        }else{
            orderAppealStatus.hide()
        }
        if orderDetail?.buyOrSell == 1{
            //买家
            bottomView.show()
            if orderDetail?.orderStatus == 10{
                //已超时
                cancleBtn.hide()
                acceptOrderBtn.hide()
                receivePaymentBtn.hide()
                mineAppealBtn.hide()
                uploadVoucherBtn.show()
                if orderDetail?.representationType ?? 0 == 1{
                    bottomView.tg_height.equal(66)
                    checkOtherAppeal.hide()
                    appealBtn.hide()
                    if orderDetail?.representationTypeOther ?? 0 == 2{
                        checkAppealResultBtn.show()
                        checkAppealResultBtn.tg_width.equal(114)
                    }else{
                        checkAppealResultBtn.hide()
                    }
                }else if orderDetail?.representationType ?? 0 == 2{
                    bottomView.tg_height.equal(66)
                    checkOtherAppeal.hide()
                    appealBtn.hide()
                    checkAppealResultBtn.show()
                    checkAppealResultBtn.tg_width.equal(114)
                }else{
                    appealBtn.tg_width.equal(114)
                    appealBtn.show()
                    checkAppealResultBtn.hide()
                    if orderDetail?.representationTypeOther ?? 0 == 2{
                        bottomView.tg_height.equal(66+48)
                        checkOtherAppeal.show()
                    }else{
                        bottomView.tg_height.equal(66)
                        checkOtherAppeal.hide()
                    }
                }
            }else{
                bottomView.tg_height.equal(66)
                checkOtherAppeal.hide()
                if orderDetail?.orderStatus == 1{
                    //等待用户付款
                    cancleBtn.tg_width.equal(114)
                    cancleBtn.show()
                    uploadVoucherBtn.show()
                    appealBtn.hide()
                    acceptOrderBtn.hide()
                    receivePaymentBtn.hide()
                    checkAppealResultBtn.hide()
                    mineAppealBtn.hide()
                    
                }else if orderDetail?.orderStatus == 2{
                    //等待商家确认
                    bottomView.hide()
                }else if orderDetail?.orderStatus == 3{
                    //已完成
                    cancleBtn.hide()
                    uploadVoucherBtn.hide()
                    appealBtn.hide()
                    acceptOrderBtn.hide()
                    receivePaymentBtn.hide()
                    if orderDetail?.representationType ?? 0 == 2{
                        checkAppealResultBtn.tg_width.equal(.fill)
                        checkAppealResultBtn.show()
                        mineAppealBtn.hide()
                    }else if orderDetail?.representationType ?? 0 == 1{
                        mineAppealBtn.hide()
                        if orderDetail?.representationTypeOther ?? 0 == 2{
                            checkAppealResultBtn.tg_width.equal(.fill)
                            checkAppealResultBtn.show()
                        }else{
                            checkAppealResultBtn.hide()
                        }
                    }else{
                        mineAppealBtn.show()
                        if orderDetail?.representationTypeOther ?? 0 == 2{
                            checkAppealResultBtn.tg_width.equal(114)
                            checkAppealResultBtn.show()
                        }else{
                            checkAppealResultBtn.hide()
                        }
                    }
                }else if orderDetail?.orderStatus == 4 || orderDetail?.orderStatus == 5{
                    if orderDetail?.paymentMethodDetails != nil{
                        cancleBtn.hide()
                        uploadVoucherBtn.hide()
                        appealBtn.hide()
                        acceptOrderBtn.hide()
                        receivePaymentBtn.hide()
                        if orderDetail?.representationType ?? 0 == 2{
                            checkAppealResultBtn.tg_width.equal(.fill)
                            checkAppealResultBtn.show()
                            mineAppealBtn.hide()
                        }else if orderDetail?.representationType ?? 0 == 1{
                            mineAppealBtn.hide()
                            if orderDetail?.representationTypeOther ?? 0 == 2{
                                checkAppealResultBtn.tg_width.equal(.fill)
                                checkAppealResultBtn.show()
                            }else{
                                checkAppealResultBtn.hide()
                            }
                        }else{
                            mineAppealBtn.show()
                            if orderDetail?.representationTypeOther ?? 0 == 2{
                                checkAppealResultBtn.tg_width.equal(114)
                                checkAppealResultBtn.show()
                            }else{
                                checkAppealResultBtn.hide()
                            }
                        }
                    }else{
                        bottomView.hide()
                    }
                }else if orderDetail?.orderStatus == 8{
                    cancleBtn.tg_width.equal(.fill)
                    cancleBtn.show()
                    uploadVoucherBtn.hide()
                    appealBtn.hide()
                    acceptOrderBtn.hide()
                    receivePaymentBtn.hide()
                    checkAppealResultBtn.hide()
                    mineAppealBtn.hide()
                }else if orderDetail?.orderStatus == 9{
                    cancleBtn.tg_width.equal(114)
                    cancleBtn.show()
                    acceptOrderBtn.show()
                    uploadVoucherBtn.hide()
                    appealBtn.hide()
                    receivePaymentBtn.hide()
                    checkAppealResultBtn.hide()
                    mineAppealBtn.hide()
                }else if orderDetail?.orderStatus == 11 {
                    bottomView.hide()
                }
            }
        }else{
            //卖家
            bottomView.tg_height.equal(66)
            bottomView.show()
            checkOtherAppeal.hide()
            if orderDetail?.orderStatus == 1{
                //等待买家付款
                bottomView.hide()
            }else if orderDetail?.orderStatus == 2{
                //请您确认收款
                appealBtn.show()
                receivePaymentBtn.show()
                cancleBtn.hide()
                acceptOrderBtn.hide()
                uploadVoucherBtn.hide()
                checkAppealResultBtn.hide()
                mineAppealBtn.hide()
                
            }else if orderDetail?.orderStatus == 3{
                //已完成
                cancleBtn.hide()
                uploadVoucherBtn.hide()
                appealBtn.hide()
                acceptOrderBtn.hide()
                receivePaymentBtn.hide()
                if orderDetail?.representationType ?? 0 == 2{
                    checkAppealResultBtn.tg_width.equal(.fill)
                    checkAppealResultBtn.show()
                    mineAppealBtn.hide()
                }else if orderDetail?.representationType ?? 0 == 1{
                    mineAppealBtn.hide()
                    if orderDetail?.representationTypeOther ?? 0 == 2{
                        checkAppealResultBtn.tg_width.equal(.fill)
                        checkAppealResultBtn.show()
                    }else{
                        checkAppealResultBtn.hide()
                    }
                }else{
                    mineAppealBtn.show()
                    if orderDetail?.representationTypeOther ?? 0 == 2{
                        checkAppealResultBtn.tg_width.equal(114)
                        checkAppealResultBtn.show()
                    }else{
                        checkAppealResultBtn.hide()
                    }
                }
            }else if orderDetail?.orderStatus == 4 || orderDetail?.orderStatus == 5{
                if orderDetail?.paymentMethodDetails != nil{
                    cancleBtn.hide()
                    uploadVoucherBtn.hide()
                    appealBtn.hide()
                    acceptOrderBtn.hide()
                    receivePaymentBtn.hide()
                    if orderDetail?.representationType ?? 0 == 2{
                        checkAppealResultBtn.tg_width.equal(.fill)
                        checkAppealResultBtn.show()
                        mineAppealBtn.hide()
                    }else if orderDetail?.representationType ?? 0 == 1{
                        mineAppealBtn.hide()
                        if orderDetail?.representationTypeOther ?? 0 == 2{
                            checkAppealResultBtn.tg_width.equal(.fill)
                            checkAppealResultBtn.show()
                        }else{
                            checkAppealResultBtn.hide()
                        }
                    }else{
                        mineAppealBtn.show()
                        if orderDetail?.representationTypeOther ?? 0 == 2{
                            checkAppealResultBtn.tg_width.equal(114)
                            checkAppealResultBtn.show()
                        }else{
                            checkAppealResultBtn.hide()
                        }
                    }
                }else{
                    bottomView.hide()
                }
            }else if orderDetail?.orderStatus == 8{
                //等待您接单
                cancleBtn.tg_width.equal(114)
                cancleBtn.show()
                acceptOrderBtn.show()
                uploadVoucherBtn.hide()
                appealBtn.hide()
                receivePaymentBtn.hide()
                checkAppealResultBtn.hide()
                mineAppealBtn.hide()
            }else if orderDetail?.orderStatus == 9{
                cancleBtn.tg_width.equal(.fill)
                cancleBtn.show()
                acceptOrderBtn.hide()
                uploadVoucherBtn.hide()
                appealBtn.hide()
                receivePaymentBtn.hide()
                checkAppealResultBtn.hide()
                mineAppealBtn.hide()
            }else if orderDetail?.orderStatus == 10{
                //已超时
                cancleBtn.hide()
                uploadVoucherBtn.hide()
                appealBtn.hide()
                acceptOrderBtn.hide()
                receivePaymentBtn.hide()
                if orderDetail?.representationType ?? 0 == 2{
                    checkAppealResultBtn.tg_width.equal(.fill)
                    checkAppealResultBtn.show()
                    mineAppealBtn.hide()
                }else if orderDetail?.representationType ?? 0 == 1{
                    mineAppealBtn.hide()
                    if orderDetail?.representationTypeOther ?? 0 == 2{
                        checkAppealResultBtn.tg_width.equal(.fill)
                        checkAppealResultBtn.show()
                    }else{
                        checkAppealResultBtn.hide()
                    }
                }else{
                    mineAppealBtn.show()
                    if orderDetail?.representationTypeOther ?? 0 == 2{
                        checkAppealResultBtn.tg_width.equal(114)
                        checkAppealResultBtn.show()
                    }else{
                        checkAppealResultBtn.hide()
                    }
                }
            }else if orderDetail?.orderStatus == 11 {
                bottomView.hide()
            }
        }
    }
    
    func setupAttributedText(text: String, targetWords: [String], color: UIColor) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: text)
        for word in targetWords {
            if let range = text.range(of: word) {
                let nsRange = NSRange(range, in: text)
                attributedString.addAttribute(.foregroundColor, value: color, range: nsRange)
            }
        }
        return NSAttributedString(attributedString: attributedString)
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
    func convertSecondsToMinuteSecondFormat(_ totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let remainingSeconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
    func startTimer() {
        // 创建一个基于全局并发队列的定时器源
        timer = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
        // 设置定时器触发间隔为1秒
        timer?.schedule(deadline:.now(), repeating:.seconds(1))
        // 设置定时器触发时执行的闭包
        timer?.setEventHandler {[weak self] in
            if self?.countdownTime == 0{
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self?.stopTimer()
                    self?.loadData()
                }
            }else{
                DispatchQueue.main.async {
                    self?.countdownTime = (self?.countdownTime ?? 0)-1
                    self?.timeLabel.text = self?.convertSecondsToMinuteSecondFormat(self?.countdownTime ?? 0)
                }
            }
        }
        // 启动定时器
        timer?.resume()
    }
    func stopTimer() {
        if timer != nil{
            timer?.cancel()
            timer = nil
        }
    }
    func startRefreshTimer() {
        // 创建一个基于全局并发队列的定时器源
        refreshTimer = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
        // 设置定时器触发间隔为1秒
        refreshTimer?.schedule(deadline:.now(), repeating:.seconds(1))
        // 设置定时器触发时执行的闭包
        refreshTimer?.setEventHandler {[weak self] in
            DispatchQueue.main.async {
                self?.timeCount = (self?.timeCount ?? 0)+1
                if self?.timeCount == 5 {
                    self?.loadData()
                    self?.timeCount = 0
                }
            }
        }
        // 启动定时器
        refreshTimer?.resume()
    }
    func stopRefreshTimer() {
        if refreshTimer != nil{
            refreshTimer?.cancel()
            refreshTimer = nil
            timeCount = 0
        }
    }
    lazy var timeView: TGLinearLayout = {
        let r = TGLinearLayout(.horz)
        r.tg_top.equal(0)
        r.tg_height.equal(48)
        r.tg_centerX.equal(0)
        r.tg_space = 4
        r.tg_gravity = .horz.center
        r.addSubview(timeTitleLabel)
        r.addSubview(timeLabel)
        return r
    }()
    lazy var timeTitleLabel: UILabel = {
        let r = UILabel()
        r.tg_width.equal(.wrap)
        r.tg_height.equal(.fill)
        r.font = .regularFont(16)
        r.textColor = .black333
        r.text = "剩余时间"
        return r
    }()
    lazy var timeLabel: UILabel = {
        let r = UILabel()
        r.tg_width.equal(45)
        r.tg_height.equal(.fill)
        r.font = .mediumFont(16)
        r.textColor = .init(hexString: "#F32525")
        r.text = "14:59"
        return r
    }()
    lazy var orderStatusView: UIView = {
        let r = UIView()
        r.tg_top.equal(0)
        r.tg_left.equal(0)
        r.tg_right.equal(0)
        r.tg_height.equal(68)
        r.corner(8)
        r.backgroundColor = .init(hexString: "#F5F5F5")
        r.addSubview(shortNameLabel)
        r.addSubview(nameLabel)
        r.addSubview(orderStatusLabel)
        shortNameLabel.snp_makeConstraints { make in
            make.left.top.equalTo(12)
            make.width.height.equalTo(18)
        }
        nameLabel.snp_makeConstraints { make in
            make.left.equalTo(shortNameLabel.snp_right).offset(4)
            make.centerY.equalTo(shortNameLabel)
            make.right.equalTo(-12)
        }
        orderStatusLabel.snp_makeConstraints { make in
            make.left.equalTo(shortNameLabel)
            make.right.equalTo(nameLabel)
            make.bottom.equalTo(-14)
            make.height.equalTo(18)
        }
        return r
    }()
    lazy var shortNameLabel:  UILabel = {
        let v = UILabel()
        v.font = .lightFont(12)
        v.textColor = .white
        v.corner(9)
        v.textAlignment = .center
        return v
    }()
    lazy var nameLabel:  UILabel = {
        let v = UILabel()
        v.font = .mediumFont(14)
        v.textColor = .black333
        return v
    }()
    lazy var orderStatusLabel:  UILabel = {
        let r = UILabel()
        r.font = .regularFont(14)
        r.textColor = .black666
        r.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer()
        tap.rx.event.subscribe { [weak self] _ in
            if self?.orderDetail?.orderStatus == 3 && self?.orderDetail?.buyOrSell == 1{
                //跳到账单列表
                let vc = BoBBillListViewController()
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        }.disposed(by: rx.disposeBag)
        r.addGestureRecognizer(tap)
        return r
    }()
    lazy var orderDetailTitleLabel: UILabel = {
        let r = UILabel()
        r.tg_top.equal(20)
        r.tg_width.equal(.wrap)
        r.tg_height.equal(20)
        r.textColor = .black333
        r.font = .mediumFont(20)
        r.text = "出售 C"
        return r
    }()
    
    lazy var orderNumberView: buyAndSellTitleView = {
        let r = buyAndSellTitleView()
        r.tg_top.equal(15)
        r.tg_left.equal(0)
        r.tg_right.equal(0)
        r.tg_height.equal(16)
        r.buyCountTitleLabel.text = "订单号"
        r.buyCounLabel.text = ""
        r.buyCounLabel.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer()
        tap.rx.event.subscribe { [weak self] _ in
            UIPasteboard.general.string = self?.orderDetail?.orderNumber ?? ""
            SuperToast.show(title: "复制成功".localized())
        }.disposed(by: rx.disposeBag)
        r.addGestureRecognizer(tap)
        return r
    }()
    lazy var payMoneyView: buyAndSellTitleView = {
        let r = buyAndSellTitleView()
        r.tg_top.equal(15)
        r.tg_left.equal(0)
        r.tg_right.equal(0)
        r.tg_height.equal(16)
        r.buyCountTitleLabel.text = "付款金额(CNY)"
        r.buyCounLabel.text = "￥100.00"
        r.buyCounLabel.font = .mediumFont(18)
        r.buyCounLabel.textColor = .init(hexString: "#F32525")
        return r
    }()
    lazy var unitPriceView: buyAndSellTitleView = {
        let r = buyAndSellTitleView()
        r.tg_top.equal(15)
        r.tg_left.equal(0)
        r.tg_right.equal(0)
        r.tg_height.equal(16)
        r.buyCountTitleLabel.text = "单价(C)"
        r.buyCounLabel.text = "￥1.00"
        return r
    }()
    lazy var countView: buyAndSellTitleView = {
        let r = buyAndSellTitleView()
        r.tg_top.equal(15)
        r.tg_left.equal(0)
        r.tg_right.equal(0)
        r.tg_height.equal(16)
        r.buyCountTitleLabel.text = "数量(C)"
        r.buyCounLabel.text = "100.00"
        return r
    }()
    lazy var paymentMethodView: buyAndSellTitleView = {
        let r = buyAndSellTitleView()
        r.tg_top.equal(15)
        r.tg_left.equal(0)
        r.tg_right.equal(0)
        r.tg_height.equal(16)
        r.buyCountTitleLabel.text = "支付方式"
        r.buyCounLabel.text = "银行卡"
        r.buyCounLabel.textColor = .init(hexString: "#388CEF")
        return r
    }()
    lazy var paymentMethodNameView: buyAndSellTitleView = {
        let r = buyAndSellTitleView()
        r.tg_top.equal(15)
        r.tg_left.equal(0)
        r.tg_right.equal(0)
        r.tg_height.equal(16)
        r.buyCountTitleLabel.text = "付款人"
        r.buyCounLabel.text = "张菲"
        r.buyCounLabel.textColor = .init(hexString: "#388CEF")
        return r
    }()
    
    lazy var payTitleLabel: UILabel = {
        let r = UILabel()
        r.tg_top.equal(20)
        r.tg_width.equal(.wrap)
        r.tg_height.equal(20)
        r.textColor = .black333
        r.font = .mediumFont(20)
        r.text = "我的收款方式"
        return r
    }()
    lazy var payView:BoBOrderDetailPaymentView = {
        let r = BoBOrderDetailPaymentView()
        r.tg_top.equal(10)
        r.tg_left.equal(0)
        r.tg_right.equal(0)
        r.tg_height.equal(.wrap)
//        r.currentVC = self
        r.showQrCode = {[weak self] imageUrl in
            let voucherView = BoBShowVoucherView()
            voucherView.tg_width.equal(300)
            voucherView.tg_height.equal(.wrap)
            voucherView.tg_centerY.equal(0)
            voucherView.bindData(image:nil, url: imageUrl)
    //        voucherView.voucherImageView.sd_setImage(with: URL(string: paymentDetail?.img))
            GKCover.cover(from: self?.view?.window, contentView: voucherView, style: .translucent, showStyle: .center, showAnimStyle: .bottom, hideAnimStyle: .bottom, notClick: true)
        }
        return r
    }()
    lazy var buyVoucherImageView: UIImageView = {
        let r = UIImageView()
        r.tg_left.equal(0)
        r.tg_top.equal(10)
        r.tg_width.equal(160)
        r.tg_height.equal(160)
        r.border(.init(hexString: "#EAEAEA"),borderWidth: 1,cornerRadius: 4)
        r.isUserInteractionEnabled = true
        let icon = UIImageView(image: UIImage(named: "order_detail_qrcode_big_icon"))
        icon.isUserInteractionEnabled = true
        r.addSubview(icon)
        icon.snp_makeConstraints { make in
            make.right.bottom.equalTo(-8)
            make.width.height.equalTo(24)
        }
        let tap = UITapGestureRecognizer()
        tap.rx.event.subscribe { [weak self] _ in
            let voucherView = BoBShowVoucherView()
            voucherView.tg_width.equal(300)
            voucherView.tg_height.equal(.wrap)
            voucherView.tg_centerY.equal(0)
            voucherView.bindData(image:nil, url: self?.orderDetail?.paymentCredentials)
            GKCover.cover(from: self?.view?.window, contentView: voucherView, style: .translucent, showStyle: .center, showAnimStyle: .bottom, hideAnimStyle: .bottom, notClick: true)
        }.disposed(by: rx.disposeBag)
        r.addGestureRecognizer(tap)
        return r
    }()
    lazy var creatTimeView: buyAndSellTitleView = {
        let r = buyAndSellTitleView()
        r.tg_top.equal(15)
        r.tg_left.equal(0)
        r.tg_right.equal(0)
        r.tg_height.equal(16)
        r.buyCountTitleLabel.text = "创建时间"
        r.buyCounLabel.text = "2024-01-06 15:02:12"
        r.buyCounLabel.font = .regularFont(14)
        return r
    }()
    lazy var payTimeView: buyAndSellTitleView = {
        let r = buyAndSellTitleView()
        r.tg_top.equal(15)
        r.tg_left.equal(0)
        r.tg_right.equal(0)
        r.tg_height.equal(16)
        r.buyCountTitleLabel.text = "付款时间"
        r.buyCounLabel.text = "2024-01-06 15:02:12"
        r.buyCounLabel.font = .regularFont(14)
        return r
    }()
    lazy var dealDoneTimeView: buyAndSellTitleView = {
        let r = buyAndSellTitleView()
        r.tg_top.equal(15)
        r.tg_left.equal(0)
        r.tg_right.equal(0)
        r.tg_height.equal(16)
        r.buyCountTitleLabel.text = "交易完成时间"
        r.buyCounLabel.text = "2024-01-06 15:02:12"
        r.buyCounLabel.font = .regularFont(14)
        return r
    }()
    lazy var checkPaymentVoucherLabel:  UILabel = {
        let r = UILabel()
        r.tg_top.equal(15)
        r.tg_left.equal(0)
        r.tg_right.equal(0)
        r.tg_height.equal(16)
        r.font = .regularFont(14)
        r.textColor = .primaryColor
        r.text = "查看我的支付凭证"
        r.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer()
        tap.rx.event.subscribe { [weak self] _ in
            let voucherView = BoBShowVoucherView()
            voucherView.tg_width.equal(300)
            voucherView.tg_height.equal(.wrap)
            voucherView.tg_centerY.equal(0)
            voucherView.bindData(image:nil, url: self?.orderDetail?.paymentCredentials)
//            voucherView.voucherImageView.sd_setImage(with: URL(string: self?.orderDetail?.paymentCredentials))
            GKCover.cover(from: self?.view?.window, contentView: voucherView, style: .translucent, showStyle: .center, showAnimStyle: .bottom, hideAnimStyle: .bottom, notClick: true)
        }.disposed(by: rx.disposeBag)
        r.addGestureRecognizer(tap)
        return r
    }()
    lazy var orderAppealStatus:  UILabel = {
        let r = UILabel()
        r.tg_top.equal(20)
        r.tg_left.equal(0)
        r.tg_right.equal(0)
        r.tg_height.equal(16)
        r.font = .regularFont(14)
        r.textColor = .primaryColor
        r.text = "订单申诉已完成"
        return r
    }()
    
    lazy var bottomView: TGLinearLayout = {
        let r = TGLinearLayout(.vert)
        r.tg_width.equal(.fill)
//        r.tg_height.equal(66+48)
        r.tg_height.equal(66)
        r.tg_hspace = 0
        r.tg_padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        r.addSubview(checkOtherAppeal)
        r.addSubview(bottomBtnView)
        cancleBtn.tg_width.equal(114)
        return r
    }()
    lazy var checkOtherAppeal: QMUIButton = {
        let r = ViewFactoryUtil.linkButton("申诉结果")
        r.tg_height.equal(48)
        r.tg_width.equal(.fill)
        r.hide()
        r.setTitleColor(.init(hexString: "#FFA756"), for: .normal)
        r.titleLabel?.font = .mediumFont(14)
        r.rx.tap.subscribe(onNext: { [weak self] in
            let vc = BoBAppealResultViewController()
            vc.code = self?.code ?? ""
            self?.navigationController?.pushViewController(vc)
        }).disposed(by: rx.disposeBag)
        return r
    }()
    lazy var bottomBtnView: TGLinearLayout = {
        let r = TGLinearLayout(.horz)
        r.tg_width.equal(.fill)
        r.tg_height.equal(66)
        r.tg_hspace = 10
        r.tg_padding = UIEdgeInsets(top: 10, left: PADDING_OUTER, bottom: 10, right: PADDING_OUTER)
        r.addSubview(cancleBtn)
        r.addSubview(appealBtn)
        r.addSubview(checkAppealResultBtn)
        r.addSubview(acceptOrderBtn)
        r.addSubview(uploadVoucherBtn)
        r.addSubview(receivePaymentBtn)
        r.addSubview(mineAppealBtn)
        return r
    }()
    lazy var cancleBtn: QMUIButton = {
        let r = ViewFactoryUtil.linkButton("取消订单")
        r.tg_height.equal(48)
        r.tg_width.equal(.fill)
        r.setTitleColor(.black666, for: .normal)
        r.titleLabel?.font = .mediumFont(16)
        r.border(.black999,borderWidth: 1,cornerRadius: 24)
        r.rx.tap.subscribe(onNext: { [weak self] in
            BoBBuyAndSellCionModel.CancelOrderRequest(code: self?.code ?? ""){[weak self] errCode,errMsg in
                if errCode == 20000{
                    SuperToast.show(title: "取消成功")
                    self?.loadData()
                }else{
                    SuperToast.show(title: errMsg)
                }
            }
        }).disposed(by: rx.disposeBag)
        return r
    }()
    lazy var uploadVoucherBtn: QMUIButton = {
        let r = ViewFactoryUtil.linkButton("上传凭证，确认付款")
        r.tg_height.equal(48)
        r.tg_width.equal(.fill)
        r.setTitleColor(.white, for: .normal)
        r.titleLabel?.font = .mediumFont(16)
        r.backgroundColor = .primaryColor
        r.corner(24)
        r.rx.tap.subscribe(onNext: { [weak self] in
            let uploadVoucherView = BoBUploadVoucherAlertView()
            uploadVoucherView.bindData(type: self?.orderDetail?.payment ?? 1, code: self?.code ?? "")
            uploadVoucherView.currentVC = self
            uploadVoucherView.uploadVoucherSuccessBlock = {[weak self] in 
                self?.loadData()
            }
            uploadVoucherView.showMask(view: self!.view)
        }).disposed(by: rx.disposeBag)
        return r
    }()
    lazy var acceptOrderBtn: QMUIButton = {
        let r = ViewFactoryUtil.linkButton("立即接单")
        r.tg_height.equal(48)
        r.tg_width.equal(.fill)
        r.setTitleColor(.white, for: .normal)
        r.titleLabel?.font = .mediumFont(16)
        r.backgroundColor = .primaryColor
        r.corner(24)
        r.rx.tap.subscribe(onNext: { [weak self] in
            if self?.orderDetail?.buyOrSell == 1{
                BoBBuyAndSellCionModel.BuyerReceiveOrdersRequest(code: self?.code ?? ""){[weak self] errCode,errMsg in
                    if errCode == 20000{
                        SuperToast.show(title: "接单成功")
                        self?.loadData()
                    }else{
                        SuperToast.show(title: errMsg)
                    }
                }
            }else{
                let choosePaymentTypeView = BoBOrderChoosePaymentTypeView()
                choosePaymentTypeView.currentVC = self
                var isSupportBank = false
                var isSupportAli = false
                var isSupportWeixin = false
                if self?.orderDetail?.payment == 1{
                    isSupportBank = true
                }else if self?.orderDetail?.payment == 2{
                    isSupportAli = true
                }else{
                    isSupportWeixin = true
                }
                choosePaymentTypeView.bindData(code: self?.code ?? "", isSupportBank: isSupportBank, isSupportAli: isSupportAli, isSupportWeixin: isSupportWeixin)
                choosePaymentTypeView.receiveOrderSuccessBlock = {[weak self] in
                    self?.loadData()
                }
                choosePaymentTypeView.showMask(view: self!.view)
            }
        }).disposed(by: rx.disposeBag)
        return r
    }()
    lazy var appealBtn: QMUIButton = {
        let r = ViewFactoryUtil.linkButton("申诉")
        r.tg_height.equal(48)
        r.tg_width.equal(114)
        r.setTitleColor(.black666, for: .normal)
        r.titleLabel?.font = .mediumFont(16)
        r.border(.black999,borderWidth: 1,cornerRadius: 24)
        r.rx.tap.subscribe(onNext: { [weak self] in
            let vc = BoBSendAppealViewController()
            vc.code = self?.code ?? ""
            vc.uploadAppealSuccessBlock = {[weak self] in
                self?.loadData()
            }
            self?.navigationController?.pushViewController(vc)
        }).disposed(by: rx.disposeBag)
        return r
    }()
    lazy var receivePaymentBtn: QMUIButton = {
        let r = ViewFactoryUtil.linkButton("我已收款，通知平台")
        r.tg_height.equal(48)
        r.tg_width.equal(.fill)
        r.setTitleColor(.white, for: .normal)
        r.titleLabel?.font = .mediumFont(16)
        r.backgroundColor = .primaryColor
        r.corner(24)
        r.rx.tap.subscribe(onNext: { [weak self] in
            BoBBuyAndSellCionModel.SellerDepositCoinRequest(code:self?.code ?? ""){errCode,errMsg in
                if errCode == 20000{
                    self?.loadData()
                }else{
                    SuperToast.show(title: errMsg)
                }
            }
        }).disposed(by: rx.disposeBag)
        return r
    }()
    lazy var checkAppealResultBtn: QMUIButton = {
        let r = ViewFactoryUtil.linkButton("申诉结果")
        r.tg_height.equal(48)
        r.tg_width.equal(.fill)
        r.setTitleColor(.white, for: .normal)
        r.titleLabel?.font = .mediumFont(16)
        r.backgroundColor = .init(hexString: "#FFA756")
        r.corner(24)
        r.rx.tap.subscribe(onNext: { [weak self] in
            let vc = BoBAppealResultViewController()
            vc.code = self?.code ?? ""
            self?.navigationController?.pushViewController(vc)
        }).disposed(by: rx.disposeBag)
        return r
    }()
    lazy var mineAppealBtn: QMUIButton = {
        let r = ViewFactoryUtil.linkButton("申诉")
        r.tg_height.equal(48)
        r.tg_width.equal(.fill)
        r.setTitleColor(.white, for: .normal)
        r.titleLabel?.font = .mediumFont(16)
        r.backgroundColor = .primaryColor
        r.corner(24)
        r.rx.tap.subscribe(onNext: { [weak self] in
            let vc = BoBSendAppealViewController()
            vc.code = self?.code ?? ""
            vc.uploadAppealSuccessBlock = {[weak self] in
                self?.loadData()
            }
            self?.navigationController?.pushViewController(vc)
        }).disposed(by: rx.disposeBag)
        return r
    }()
}

