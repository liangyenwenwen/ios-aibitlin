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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    override func initViews() {
        super.initViews()
        setBackGroundColor(.white)
        initScrollSafeArea()
        title = "订单详情"
        scrollViewContainer.tg_padding = UIEdgeInsets(top: 0, left: PADDING_OUTER, bottom: 0, right: PADDING_OUTER)
        superFooterContainerContainer.addSubview(bottomBtnView)
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
        r.tg_width.equal(.wrap)
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
        let v = UILabel()
        v.font = .regularFont(14)
        v.textColor = .black666
        return v
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
        r.buyCounLabel.text = "20240116235412100321"
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
        r.buyCountTitleLabel.text = "付款方式"
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
        let tap = UITapGestureRecognizer()
        tap.rx.event.subscribe { [weak self] _ in
            
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
    
    lazy var bottomBtnView: TGLinearLayout = {
        let r = TGLinearLayout(.horz)
        r.tg_width.equal(.fill)
//        r.tg_left.equal(16)
//        r.tg_right.equal(16)
        r.tg_height.equal(66)
        r.tg_hspace = 10
        r.tg_padding = UIEdgeInsets(top: 10, left: PADDING_OUTER, bottom: 10, right: PADDING_OUTER)
        r.addSubview(cancleBtn)
        r.addSubview(uploadVoucherBtn)
        cancleBtn.tg_width.equal(114)
        return r
    }()
    lazy var cancleBtn: QMUIButton = {
        let r = ViewFactoryUtil.linkButton("取消订单")
        r.tg_height.equal(48)
        r.tg_width.equal(.fill)
        r.setTitleColor(.black666, for: .normal)
        r.titleLabel?.font = .mediumFont(16)
        r.border(.init(hexString: "#EAEAEA"),borderWidth: 1,cornerRadius: 24)
        r.rx.tap.subscribe(onNext: { [weak self] in
            
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
            uploadVoucherView.bindData(type: 2, code: "")
            uploadVoucherView.currentVC = self
            uploadVoucherView.showMask(view: self!.view.window!)
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
            
        }).disposed(by: rx.disposeBag)
        return r
    }()
    lazy var appealBtn: QMUIButton = {
        let r = ViewFactoryUtil.linkButton("申诉")
        r.tg_height.equal(48)
        r.tg_width.equal(114)
        r.setTitleColor(.black666, for: .normal)
        r.titleLabel?.font = .mediumFont(16)
        r.border(.init(hexString: "#EAEAEA"),borderWidth: 1,cornerRadius: 24)
        r.rx.tap.subscribe(onNext: { [weak self] in
            
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
            
        }).disposed(by: rx.disposeBag)
        return r
    }()
    lazy var checkAppealResultBtn: QMUIButton = {
        let r = ViewFactoryUtil.linkButton("申诉")
        r.tg_height.equal(48)
        r.tg_width.equal(.fill)
        r.setTitleColor(.white, for: .normal)
        r.titleLabel?.font = .mediumFont(16)
        r.backgroundColor = .primaryColor
//        r.backgroundColor = .init(hexString: "#FFA756")
//        r.setTitle("查看申诉结果", for: .normal)
        r.corner(24)
        r.rx.tap.subscribe(onNext: { [weak self] in
            
        }).disposed(by: rx.disposeBag)
        return r
    }()
}

