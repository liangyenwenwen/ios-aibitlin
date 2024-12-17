//
//  BoBCreatAdvertisementViewController.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/12/17.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Foundation
import TangramKit
import OUICore
import RxSwift
import RxCocoa
import RxGesture
import OUIIM
import IQKeyboardManagerSwift
class BoBCreatAdvertisementViewController: BaseTitleController {
    var advertisementType:Int = 1 //1出售，2购买
    var paymentType:Int = 1 //1银行卡，2支付宝，3微信
    var exchangeRateType:Int = 2 //1浮动，2固定
    var currency = "C"
    var chooseCionTypeModel:CionTypeModel?
    var cionTypeArray:[CionTypeModel] = []
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        IQKeyboardManager.shared.enable = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enable = false
    }
    override func initViews() {
        super.initViews()
        setBackGroundColor(.colorBackgroundAPP)
        initScrollSafeArea()
        title = "创建广告"
        chooseCionTypeModel = CionTypeModel(icon: "", currency: currency, quota: 0.00, handlingCharge: 0.00, minimumCommission: 0.00, cionType:"0", money:0.00, type: 0, isSelect: true,exchangeRate:1.00)
        scrollViewContainer.tg_padding = UIEdgeInsets(top: 0, left: PADDING_OUTER, bottom: PADDING_OUTER, right: PADDING_OUTER)
        superFooterContainerContainer.tg_bottom.equal(0)
        scrollViewContainer.addSubview(currencyView)
        scrollViewContainer.addSubview(paymentView)
        scrollViewContainer.addSubview(exchangeRateTypeView)
        
        let tap = UITapGestureRecognizer()
        tap.rx.event.subscribe {  _ in
            self.view.endEditing(true)
        }.disposed(by: rx.disposeBag)
        scrollViewContainer.addGestureRecognizer(tap)
    }
    func calculationExchangeRate(){
    }
    private lazy var currencyView:  TGLinearLayout = {
        let r = TGLinearLayout(.horz)
        r.tg_top.equal(10)
        r.tg_left.equal(0)
        r.tg_right.equal(0)
        r.tg_height.equal(44)
        let label = UILabel()
        label.tg_left.equal(0)
        label.tg_centerY.equal(r)
        label.tg_height.equal(44)
        label.tg_width.equal(.wrap)
        label.textColor = .black333
        label.font = .mediumFont(16)
        label.text = advertisementType == 1 ? "我要出售":"我要购买"
        r.addSubview(label)
        r.addSubview(currencyBtn)
        return r
    }()
    private lazy var currencyBtn: ChooseBtn = {
        let r = ChooseBtn()
        r.tg_left.equal(12)
        r.tg_height.equal(44)
        r.tg_width.equal(147)
        r.btn.contentHorizontalAlignment = .left
        r.btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 17, bottom: 0, right: 0)
        r.btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 11, bottom: 0, right: 17)
        r.backgroundColor = .init(hexString: "#F3F7FB")
        r.bindData(title: currency, icon: UIImage(named: "mine_home_cion_c_icon")!)
        r.border(.init(hexString: "#277FE6"),borderWidth: 1,cornerRadius: 8)
        r.selectStatusImageView.show()
        r.btn.rx.tap.subscribe(onNext: { [self] in

        }).disposed(by: rx.disposeBag)
        return r
    }()
    private lazy var paymentView:  TGLinearLayout = {
        let r = TGLinearLayout(.vert)
        r.tg_top.equal(22)
        r.tg_left.equal(0)
        r.tg_right.equal(0)
        r.tg_height.equal(68)
        let label = UILabel()
        label.tg_left.equal(0)
        label.tg_top.equal(0)
        label.tg_height.equal(18)
        label.tg_width.equal(.wrap)
        label.textColor = .black333
        label.font = .mediumFont(16)
        label.text = advertisementType == 1 ? "收款方式":"支付方式"
        r.addSubview(label)
        r.addSubview(paymentMethodView)
        return r
    }()
    private lazy var paymentMethodView:  TGLinearLayout = {
        let r = TGLinearLayout(.horz)
        r.tg_top.equal(10)
        r.tg_left.equal(0)
        r.tg_right.equal(0)
        r.tg_height.equal(40)
        r.addSubview(bankBtn)
        r.addSubview(aliBtn)
        r.addSubview(weixinBtn)
        return r
    }()
    lazy var bankBtn: ChooseBtn = {
        let r = ChooseBtn()
        r.tg_top.equal(0)
        r.tg_left.equal(0)
        r.tg_height.equal(40)
        r.tg_width.equal((kScreenWidth-32-34)/3)
        r.backgroundColor = .init(hexString: "#F3F7FB")
        r.bindData(title: "银行卡", icon: UIImage(named: "mine_payment_method_bank_icon")!)
        r.border(.init(hexString: "#277FE6"),borderWidth: 1,cornerRadius: 8)
        r.selectStatusImageView.show()
        r.btn.rx.tap.subscribe(onNext: { [weak self] in
            if self?.paymentType != 1{
                self?.paymentType = 1
                r.border(.init(hexString: "#277FE6"),borderWidth: 1,cornerRadius: 8)
                r.backgroundColor = .init(hexString: "#F3F7FB")
                r.selectStatusImageView.show()
                self?.aliBtn.border(.white,borderWidth: 1,cornerRadius: 8)
                self?.aliBtn.selectStatusImageView.hide()
                self?.aliBtn.backgroundColor = .white
                self?.weixinBtn.border(.white,borderWidth: 1,cornerRadius: 8)
                self?.weixinBtn.selectStatusImageView.hide()
                self?.weixinBtn.backgroundColor = .white
            }
        }).disposed(by: rx.disposeBag)
        return r
    }()
    lazy var aliBtn: ChooseBtn = {
        let r = ChooseBtn()
        r.tg_top.equal(0)
        r.tg_left.equal(17)
        r.tg_height.equal(40)
        r.tg_width.equal((kScreenWidth-32-34)/3)
        r.backgroundColor = .white
        r.bindData(title: "支付宝", icon: UIImage(named: "mine_payment_method_ali_icon")!)
        r.btn.rx.tap.subscribe(onNext: { [weak self] in
            if self?.paymentType != 2{
                self?.paymentType = 2
                r.border(.init(hexString: "#277FE6"),borderWidth: 1,cornerRadius: 8)
                r.backgroundColor = .init(hexString: "#F3F7FB")
                r.selectStatusImageView.show()
                self?.bankBtn.border(.white,borderWidth: 1,cornerRadius: 8)
                self?.bankBtn.selectStatusImageView.hide()
                self?.bankBtn.backgroundColor = .white
                self?.weixinBtn.border(.white,borderWidth: 1,cornerRadius: 8)
                self?.weixinBtn.selectStatusImageView.hide()
                self?.weixinBtn.backgroundColor = .white
            }
        }).disposed(by: rx.disposeBag)
        return r
    }()
    lazy var weixinBtn: ChooseBtn = {
        let r = ChooseBtn()
        r.tg_top.equal(0)
        r.tg_left.equal(17)
        r.tg_height.equal(40)
        r.tg_width.equal((kScreenWidth-32-34)/3)
        r.backgroundColor = .white
        r.border(.white,borderWidth: 1,cornerRadius: 8)
        r.bindData(title: "微信", icon: UIImage(named: "mine_payment_method_weixin_icon")!)
        r.btn.rx.tap.subscribe(onNext: { [weak self] in
            if self?.paymentType != 3{
                self?.paymentType = 3
                r.border(.init(hexString: "#277FE6"),borderWidth: 1,cornerRadius: 8)
                r.backgroundColor = .init(hexString: "#F3F7FB")
                r.selectStatusImageView.show()
                self?.bankBtn.border(.white,borderWidth: 1,cornerRadius: 8)
                self?.bankBtn.selectStatusImageView.hide()
                self?.bankBtn.backgroundColor = .white
                self?.aliBtn.border(.white,borderWidth: 1,cornerRadius: 8)
                self?.aliBtn.selectStatusImageView.hide()
                self?.aliBtn.backgroundColor = .white
            }
        }).disposed(by: rx.disposeBag)
        return r
    }()
    lazy var exchangeRateTypeView: TGLinearLayout = {
        let r = TGLinearLayout(.vert)
        r.tg_top.equal(22)
        r.tg_left.equal(0)
        r.tg_right.equal(0)
        r.tg_height.equal(76)
        let label = UILabel()
        label.tg_left.equal(0)
        label.tg_top.equal(0)
        label.tg_height.equal(18)
        label.tg_width.equal(.wrap)
        label.textColor = .black333
        label.font = .mediumFont(16)
        label.text = "汇率类型"
        r.addSubview(label)
        r.addSubview(choosExchangeRateTypeView)
        return r
    }()
    lazy var choosExchangeRateTypeView: UIView = {
        let r = UIView()
        r.tg_top.equal(10)
        r.tg_left.equal(0)
        r.tg_right.equal(0)
        r.tg_height.equal(48)
        r.backgroundColor = .white
        r.corner(8)
        let icon = UIImageView(image: UIImage(named: "mine_red_packet_choose_type_icon"))
        r.addSubview(icon)
        icon.snp_makeConstraints { make in
            make.right.equalTo(-16)
            make.centerY.equalTo(r)
            make.width.height.equalTo(10)
        }
        r.addSubview(exchangeRateTypeLabel)
        exchangeRateTypeLabel.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.centerY.equalTo(r)
            make.right.equalTo(icon.snp_left).offset(-15)
        }
        return r
    }()
    lazy var exchangeRateTypeLabel:UILabel = {
       let r = UILabel()
        r.textColor = .black333
        r.font = .mediumFont(16)
        r.text = exchangeRateType == 1 ? "浮动": "固定"
        return r
    }()
    lazy var exchangeRateView: TGLinearLayout = {
        let r = TGLinearLayout(.vert)
        r.tg_top.equal(22)
        r.tg_left.equal(0)
        r.tg_right.equal(0)
        r.tg_height.equal(124)
        r.addSubview(exchangeRateTitleLabel)
        let bgView = TGLinearLayout(.horz)
        bgView.tg_top.equal(10)
        bgView.tg_left.equal(0)
        bgView.tg_height.equal(48)
        bgView.tg_left.equal(0)
        bgView.tg_gravity = .horz.between
        bgView.backgroundColor = .white
        bgView.corner(8)
        r.addSubview(bgView)
        bgView.addSubview(reduceBtn)
        bgView.addSubview(exchangeRateTF)
        bgView.addSubview(addBtn)
        return r
    }()
    lazy var exchangeRateTitleLabel:UILabel = {
       let r = UILabel()
        r.tg_left.equal(0)
        r.tg_top.equal(0)
        r.tg_height.equal(18)
        r.tg_width.equal(.wrap)
        r.textColor = .black333
        r.font = .mediumFont(16)
        r.text = exchangeRateType == 1 ? "浮动指数" : "固定汇率"
        return r
    }()
    lazy var reduceBtn: QMUIButton = {
        let r =  ViewFactoryUtil.imageBtn(UIImage(named: "mine_red_packet_count_reduce_icon")!, 34)
        r.tg_left.equal(7)
        r.tg_width.equal(34)
        r.tg_height.equal(34)
        r.tg_centerY.equal(0)
        r.rx.tap.subscribe(onNext: { [weak self] in
            if let doubleValue = Double(self?.exchangeRateTF.text ?? "0.01") {
                if doubleValue == 0.01{
                    return
                }else{
                    self?.exchangeRateTF.text = String(format: "%.2f",doubleValue - 0.01)
                }
            }else{
                self?.exchangeRateTF.text = "1.00"
            }
            self?.calculationExchangeRate()
        }).disposed(by: rx.disposeBag)
        return r
    }()
    lazy var addBtn: QMUIButton = {
        let r =  ViewFactoryUtil.imageBtn(UIImage(named: "mine_red_packet_count_add_icon")!, 34)
        r.tg_right.equal(7)
        r.tg_width.equal(34)
        r.tg_height.equal(34)
        r.tg_centerY.equal(0)
        r.rx.tap.subscribe(onNext: { [weak self] in
            if let doubleValue = Double(self?.exchangeRateTF.text ?? "0.01") {
                self?.exchangeRateTF.text = String(format: "%.2f",doubleValue + 0.01)
            }else{
                self?.exchangeRateTF.text = "1.00"
            }
            self?.calculationExchangeRate()
        }).disposed(by: rx.disposeBag)
        return r
    }()
    
    lazy var exchangeRateTF: QMUITextField = {
        let r = QMUITextField()
        r.tg_height.equal(50)
        r.tg_width.equal(kScreenWidth-32-82-30)
        r.font = .regularFont(16)
        r.tintColor = .black333
        r.textAlignment = .center
        r.keyboardType = .asciiCapableNumberPad
        r.setPlaceHolderTextColor(.black999)
        r.placeholder = "输入汇率"
        r.text = "1"
        r.rx.controlEvent(.editingDidEnd).subscribe(onNext: {  [weak self] in
            if self?.redPacketType != 2{
                if ((r.text?.range(of:".")) != nil){
                    //带小数点
                    if r.text!.filter({ "." == $0 }).count == 2{
                        guard let range = r.text!.range(of: ".", options: [.backwards, .caseInsensitive], range: nil, locale: nil) else {
                            return
                        }
                        r.text =  r.text!.replacingCharacters(in: range, with: "")
                    }else if r.text!.filter({ "." == $0 }).count > 2{
                        r.text = ""
                    }
                    let arr = r.text?.components(separatedBy: ".")
                    if arr![1].count > 2{
                        r.text = arr![0] + "." + arr![1].prefix(2)
                    }
                }else{
                    if r.text!.length > 1 {
                        let str = r.text?.prefix(1)
                        if str == "0"{
                            r.text = "0"
                        }
                    }
                }
                self?.calculationExchangeRate()
        }).disposed(by: rx.disposeBag)
        return r
    }()
    
}
