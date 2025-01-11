//
//  BoBQuickBuyAndSellView.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/12/10.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Foundation
import JXSegmentedView
import OUICore


class BoBQuickBuyAndSellView: UIView {
    var currentVC:UIViewController?
    var homeData:BoBBuyAndSellHomeData?
    var dailyLimitModel:DailyLimitModel?
    var titleArray = ["100","500","1000","3000","5000","10000","20000","30000"]
    var chooseMoney = ""
    var currency:String? //币种
    var currencyIcon:String? //图标
    var type:Int = 1 //1是购买，2是出售
    var choosePaymentMethod:stringAndDatePOS?//选中的支付方式
    var selectBtn = QMUIButton()
    var chooseCionTypeModel:CionTypeModel?
    var cionTypeArray:[CionTypeModel] = []
    var btnArray = [QMUIButton]()
    var isRefresh:Bool = false
    init(data: BoBBuyAndSellHomeData?,viewType:Int,currentCurrency:String?,currentCurrencyIcon:String?) {
        super.init(frame: .zero)
         homeData = data
        type = viewType
        currency = currentCurrency
        currencyIcon = currentCurrencyIcon
        chooseCionTypeModel = CionTypeModel(icon: "", currency: currency, quota: 0.00, handlingCharge: 0.00, minimumCommission: 0.00, cionType:"0", money:0.00, type: 0, isSelect: true,exchangeRate:1.00)
        self.backgroundColor = .clear
        addSubview(bgView)
        addSubview(titleLabel)
        addSubview(buyTypeBtn)
        addSubview(countView)
        addSubview(lineView)
        addSubview(typeView)
        addSubview(paymentMethodView)
        addSubview(buyBtn)
        bgView.snp_makeConstraints { make in
            make.left.right.equalTo(0)
            if(type == 1){
                make.top.equalTo(typeView.snp_bottom)
                make.height.equalTo(20)
            }else{
                make.top.equalTo(189)
                make.height.equalTo(40)
            }
            
        }
        titleLabel.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.top.equalTo(13)
            make.height.equalTo(20)
            make.width.equalTo(120)
        }
        buyTypeBtn.snp_makeConstraints { make in
            make.right.equalTo(-16)
            make.centerY.equalTo(titleLabel)
            make.height.equalTo(30)
            make.left.equalTo(titleLabel.snp_right).offset(15)
        }
        countView.snp_makeConstraints { make in
            make.top.equalTo(titleLabel.snp_bottom).offset(5)
            make.left.right.equalTo(0)
            make.height.equalTo(28)
        }
        lineView.snp_makeConstraints { make in
            make.left.right.equalTo(0)
            make.top.equalTo(countView.snp_bottom).offset(5)
            make.height.equalTo(1)
        }
        if type == 1{
            typeView.snp_makeConstraints { make in
                make.top.equalTo(lineView.snp_bottom).offset(12)
                make.left.equalTo(16)
                make.right.equalTo(-16)
                make.height.equalTo(88)
            }
        }else{
            addSubview(moneyTitleLabel)
            addSubview(moneyLabel)
            moneyTitleLabel.snp_makeConstraints { make in
                make.right.equalTo(moneyLabel.snp_left)
                make.top.equalTo(lineView.snp_bottom).offset(12)
                make.height.equalTo(16)
            }
            moneyLabel.snp_makeConstraints { make in
                make.right.equalTo(-16)
                make.top.equalTo(lineView.snp_bottom).offset(12)
                make.height.equalTo(16)
            }
            typeView.snp_makeConstraints { make in
                make.top.equalTo(moneyTitleLabel.snp_bottom).offset(16)
                make.left.equalTo(16)
                make.right.equalTo(-16)
                make.height.equalTo(88)
            }
            loadData()
        }
        
        if homeData != nil{
            exchangeRateLabel.text = "参考汇率 ￥" + String(format: "%.2f", homeData?.exchangeRate ?? 1.00)
            buyBtn.setTitle((type == 1 ? "购买": "出售") + (currency ?? ""), for: .normal)
            cionImageView.sd_setImage(with: URL(string:currencyIcon))
            if homeData?.payment == true{
                addView.hide()
                choosePaymentView.hide()
                choosePaymentMethodView.show()
                paymentMethodView.snp_makeConstraints { make in
                    make.left.right.equalTo(0)
                    make.top.equalTo(bgView.snp_bottom).offset(12)
                    make.height.equalTo(150)
                }
                paymentBgView.snp_updateConstraints { make in
                    make.height.equalTo(44)
                }
            }else{
                addView.show()
                choosePaymentView.hide()
                choosePaymentMethodView.hide()
                paymentMethodView.snp_makeConstraints { make in
                    make.left.right.equalTo(0)
                    make.top.equalTo(bgView.snp_bottom).offset(12)
                    make.height.equalTo(178)
                }
            }
        }else{
            addView.show()
            choosePaymentView.hide()
            choosePaymentMethodView.hide()
            paymentMethodView.snp_makeConstraints { make in
                make.left.right.equalTo(0)
                make.top.equalTo(bgView.snp_bottom).offset(12)
                make.height.equalTo(178)
            }
        }
        
        buyBtn.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.height.equalTo(50)
            make.top.equalTo(paymentMethodView.snp_bottom).offset(24)
        }
        let tap = UITapGestureRecognizer()
        tap.rx.event.subscribe { [weak self] _ in
            self?.endEditing(true)
        }.disposed(by: rx.disposeBag)
        self.addGestureRecognizer(tap)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshPaymentList(_:)), name: Notification.Name("refreshPaymentList"), object: nil)
//        self.loadDailyLimit()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        // 移除所有通知监听
        NotificationCenter.default.removeObserver(self)
    }
    @objc func refreshPaymentList(_ notidication: Notification) {
            if  let userinfo = notidication.userInfo, let data = userinfo["homeData"] as? BoBBuyAndSellHomeData {
                homeData = data
                if homeData?.payment == true{
                    addView.hide()
                    if choosePaymentMethod != nil{
                        choosePaymentView.show()
                        choosePaymentMethodView.hide()
                        paymentMethodView.snp_updateConstraints { make in
                            make.height.equalTo(178)
                        }
                        paymentBgView.snp_updateConstraints { make in
                            make.height.equalTo(72)
                        }
                    }else{
                        choosePaymentView.hide()
                        choosePaymentMethodView.show()
                        paymentMethodView.snp_updateConstraints { make in
                            make.height.equalTo(150)
                        }
                        paymentBgView.snp_updateConstraints { make in
                            make.height.equalTo(44)
                        }
                    }
                }
            }
        }
    func loadData(){
        BoBBuyAndSellCionModel.QueryBalanceByCurrencyRequest(currency:currency ?? "C"){[weak self] data in
            let model1 = CionTypeModel(icon: data.icon, currency: self?.currency, quota: 0.00, handlingCharge: 0.00, minimumCommission: 0.00, cionType: "0", money: data.t0, type: 0, isSelect: true,exchangeRate:0.00)
            let model2 = CionTypeModel(icon: data.icon, currency: self?.currency, quota: 0.00, handlingCharge: 0.00, minimumCommission: 0.00, cionType: "1", money: data.t1, type: 1, isSelect: false,exchangeRate:0.00)
            self?.cionTypeArray.append(model1)
            self?.cionTypeArray.append(model2)
            if self?.cionTypeArray.count ?? 0 > 0{
                self?.chooseCionTypeModel = self?.cionTypeArray[0]
                self?.refreshUI()
            }
        } completionHandler: {errCode,errMsg in
            SuperToast.show(title: errMsg)
        }
    }
    func loadDailyLimit(){
        BoBBuyAndSellCionModel.QueryDailyLimitRequest(currency:currency ?? "C"){[weak self] data in
            self?.dailyLimitModel = data
            self?.refreshDailyLimitUI()
        } completionHandler: {errCode,errMsg in
            SuperToast.show(title: errMsg)
        }
    }
    func refreshDailyLimitUI(){
        if type == 1{
            //购买
            if buyTypeBtn.isSelected == true{
                //限额¥
                if dailyLimitModel?.dailyLimitBuy == 0{
                    countTF.placeholder = "限额" + "¥0.00"
                }else{
                    countTF.placeholder = "限额" + String(format: "￥0.01~%.2f", (dailyLimitModel?.dailyLimitBuy ?? 0.01)*(homeData?.exchangeRate ?? 1.00))
                }
            }else{
                //限额C
                if dailyLimitModel?.dailyLimitBuy == 0{
                    countTF.placeholder = "限额" + "0.00" + (currency ?? "C")
                }else{
                    countTF.placeholder = "限额" + String(format: "0.01~%.2f", (dailyLimitModel?.dailyLimitBuy ?? 0.01)) + (currency ?? "C")
                }
            }
         }else{
             //出售
             if buyTypeBtn.isSelected == true{
                 //限额¥
                 if dailyLimitModel?.dailyLimitSell == 0{
                     countTF.placeholder = "限额" + "¥0.00"
                 }else{
                     countTF.placeholder = "限额" + String(format: "￥0.01~%.2f", (dailyLimitModel?.dailyLimitSell ?? 0.01)*(homeData?.exchangeRate ?? 1.00))
                 }
             }else{
                 //限额C
                 if dailyLimitModel?.dailyLimitSell == 0{
                     countTF.placeholder = "限额" + "0.00" + (currency ?? "C")
                 }else{
                     countTF.placeholder = "限额" + String(format: "0.01~%.2f", (dailyLimitModel?.dailyLimitSell ?? 0.01)) + (currency ?? "C")
                 }
             }
         }
    }
    func refreshUI(){
        if chooseCionTypeModel?.type == 0{
            self.walletLabel.text = "T+0钱包"
            self.walletLabel.textColor = .init(hexString: "#00AA3C")
            self.walletLabel.backgroundColor = .init(hexString: "#E5F6EB")
        }else{
            self.walletLabel.text = "T+1钱包"
            self.walletLabel.textColor = .init(hexString: "#FFA756")
            self.walletLabel.backgroundColor = .init(hexString: "#FFF7E5")
        }
        moneyLabel.text = String(format: "%.2f",(chooseCionTypeModel?.money)!) + (chooseCionTypeModel?.currency)!
    }
    func choosePaymentMedthodType(){
        let chooseTypeView = BoBChoosePaymentMethodTypeView()
        chooseTypeView.tg_width.equal(.fill)
        chooseTypeView.tg_height.equal(447)
        chooseTypeView.currentVC = currentVC
        chooseTypeView.bindData(type:type,paymentData: homeData?.userBankAndWeiXinAndZFBPO,choosePayment: choosePaymentMethod,isSupportBank: true,isSupportAli: true,isSupportWeixin: true)
        chooseTypeView.choosePaymentMethodTypeBlock = {[weak self] choosePayment,newPaymentMethodData in
            self?.choosePaymentMethod = choosePayment
            self?.homeData?.userBankAndWeiXinAndZFBPO = newPaymentMethodData
            self?.addView.hide()
            self?.choosePaymentView.show()
            self?.choosePaymentMethodView.hide()
            self?.paymentMethodView.snp_updateConstraints { make in
                make.height.equalTo(178)
            }
            self?.paymentBgView.snp_updateConstraints { make in
                make.height.equalTo(72)
            }
            self?.paymentMethodIcon.sd_setImage(with: URL(string: choosePayment.icon))
            if let res = JsonTool.fromJson(choosePayment.stringValue!, toClass: paymentDdetailData.self) {
                if choosePayment.type == "bank"{
                    self?.paymentMethodName.text = res.bankDeposit
                    self?.paymentMethodUserName.text = res.name
                    if res.bankId!.length < 8{
                        self?.paymentMethodNumber.text = res.bankId
                    }else{
                        self?.paymentMethodNumber.text = res.bankId!.prefix(4) + "**********" + res.bankId!.suffix(4)
                    }
                }else{
                    self?.paymentMethodName.text = choosePayment.type == "weiXin" ? "微信" : "支付宝"
                    self?.paymentMethodUserName.text = res.name
                    self?.paymentMethodNumber.text = res.nickName
                    
                }
               
            }
        }
        GKCover.cover(from: self.currentVC?.view.window, contentView: chooseTypeView, style: .translucent, showStyle: .bottom, showAnimStyle: .bottom, hideAnimStyle: .bottom, notClick: false)

    }
    private lazy var titleLabel: UILabel = {
        let r = UILabel()
        r.font = .mediumFont(16)
        r.textColor = .black
        r.text = "数量"
        return r
    }()
    lazy var bgView: UIView = {
        let r = UIView()
        r.backgroundColor = .white
        r.corner(8)
        return r
    }()
    private lazy var buyTypeBtn: UIButton = {
        let r = UIButton()
        r.setImage(UIImage(named: "mine_buy_and_sell_buy_type_icon"), for: .normal)
        r.setTitle(type == 1 ? "按金额购买":"按金额出售", for: .normal)
        r.setTitle(type == 1 ? "按数量购买" :"按数量出售", for: .selected)
        r.isSelected = false
        r.titleLabel?.font = .regularFont(16)
        r.setTitleColor(.primaryColor, for: .normal)
        r.contentHorizontalAlignment = .right
        // 间距可能需要根据图片和文字大小调整
        let spacing: CGFloat = 3
        r.titleEdgeInsets = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: 0)
        r.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: spacing)
        r.rx.tap.subscribe(onNext: { [weak self] in
            self?.endEditing(true)
            r.isSelected = !r.isSelected
            if self?.selectBtn != nil{
                self?.selectBtn.border(.init(hexString: "#EAEAEA"),borderWidth: 1,cornerRadius: 6)
                self?.selectBtn.setTitleColor(.black666, for: .normal)
                self?.selectBtn.backgroundColor = .white
            }
            self?.chooseMoney = ""
            self?.countTF.text = ""
            if r.isSelected{
                self?.titleLabel.text = "金额"
//                self?.countTF.placeholder = "限额￥100~30,000"
                self?.cionImageView.image = UIImage(named: "mine_buy_and_sell_buy_money_icon")
                self?.expectedIncomeLabel.text = "0.00 C"
            }else{
                self?.titleLabel.text = "数量"
//                self?.countTF.placeholder = "限额100~30,000 C"
                if self?.currencyIcon?.isEmpty == true{
                    self?.cionImageView.image = UIImage(named: "mine_home_cion_c_icon")
                }else{
                    self?.cionImageView.sd_setImage(with: URL(string:self?.currencyIcon))
                }
                self?.expectedIncomeLabel.text = "¥0.00"
            }
            self?.refreshDailyLimitUI()
            for i in 0..<(self?.btnArray.count ?? 0) {
                let btn = self?.btnArray[i]
                let titleStr = self?.titleArray[i]
                if r.isSelected{
                    btn?.setTitle("¥" + (titleStr ?? ""), for: .normal)
                }else{
                    btn?.setTitle(titleStr, for: .normal)
                }
            }
            
        }).disposed(by: rx.disposeBag)
        return r
    }()
    lazy var countView: UIView = {
        let r = UIView()
        r.addSubview(cionImageView)
        r.addSubview(countTF)
        cionImageView.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.centerY.equalTo(r)
            make.width.height.equalTo(18)
        }
        if type == 1{
            countTF.snp_makeConstraints { make in
                make.left.equalTo(cionImageView.snp_right).offset(10)
                make.right.equalTo(-16)
                make.centerY.equalTo(r)
            }
        }else{
            r.addSubview(chooseWalletView)
            countTF.snp_makeConstraints { make in
                make.left.equalTo(cionImageView.snp_right).offset(10)
                make.right.equalTo(chooseWalletView.snp_left).offset(-10)
                make.centerY.equalTo(r)
            }
            chooseWalletView.snp_makeConstraints { make in
                make.width.equalTo(80)
                make.height.equalTo(26)
                make.right.equalTo(-16)
                make.centerY.equalTo(r)
            }
            
        }
       
       
        return r
    }()
    private lazy var cionImageView: UIImageView = {
        let r = UIImageView(image: UIImage(named: "mine_home_cion_c_icon"))
        return r
    }()
    private lazy var countTF: QMUITextField = {
        let r = QMUITextField()
        r.tg_height.equal(50)
        r.tg_top.equal(0)
        r.tg_left.equal(16)
        r.tg_width.equal(240)
        r.font = .regularFont(16)
        r.tintColor = .black333
        r.keyboardType = .decimalPad
        r.setPlaceHolderTextColor(.black999)
        r.placeholder = "限额100~30,000 C"
        r.rx.controlEvent(.editingDidEnd).subscribe(onNext: { [weak self] in
//            var count = Int(r.text ?? "0") ?? 0
//            if count < 100 && count > 0{
//                r.text = "100"
//            }else if count > 30000{
//                r.text = "3000"
//            }
            if let doubleValue = Double(r.text ?? "0") {
                if self?.buyTypeBtn.isSelected == true{
                    //金额
                    self?.expectedIncomeLabel.text = String(format: "%.2f C",doubleValue/(self?.homeData?.exchangeRate ?? 1.00))
                    
                }else{
                    //数量
                    self?.expectedIncomeLabel.text = String(format: "￥%.2f",(self?.homeData?.exchangeRate ?? 1.00)*doubleValue)
                }
            }
        }).disposed(by: rx.disposeBag)
        r.rx.controlEvent(.editingChanged).subscribe(onNext: { [weak self] in
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
            if self?.chooseMoney.isEmpty == false && Int(r.text ?? "0") != Int(self?.chooseMoney ?? "0"){
                if self?.selectBtn != nil{
                    self?.selectBtn.border(.init(hexString: "#EAEAEA"),borderWidth: 1,cornerRadius: 6)
                    self?.selectBtn.setTitleColor(.black666, for: .normal)
                    self?.selectBtn.backgroundColor = .white
                }
                self?.chooseMoney = ""
            }
        }).disposed(by: rx.disposeBag)
        return r
    }()
    lazy var chooseWalletView: UIView = {
        let r = UIView()
        let icon = UIImageView(image: UIImage(named: "mine_red_packet_choose_type_icon"))
        r.addSubview(icon)
        r.addSubview(walletLabel)
        icon.snp_makeConstraints { make in
            make.right.equalTo(0)
            make.centerY.equalTo(r)
            make.width.height.equalTo(10)
        }
        walletLabel.snp_makeConstraints { make in
            make.right.equalTo(icon.snp_left).offset(-6)
            make.centerY.equalTo(r)
            make.height.equalTo(26)
            make.width.equalTo(62)
        }
        let tap = UITapGestureRecognizer()
        tap.rx.event.subscribe {[weak self]  _ in
            self?.endEditing(true)
            let chooseTypeView = BoBChooseCionTypeView()
            chooseTypeView.tg_width.equal(.fill)
            chooseTypeView.tg_height.equal(240)
            chooseTypeView.reloadListArray(array: self?.cionTypeArray ?? [])
            chooseTypeView.chooseCionBlock = { [weak self] model,array in
                self?.chooseCionTypeModel = model
                self?.cionTypeArray = array
                self?.refreshUI()
            }
            GKCover.cover(from: self?.currentVC?.view.window, contentView: chooseTypeView, style: .translucent, showStyle: .bottom, showAnimStyle: .bottom, hideAnimStyle: .bottom, notClick: false)
        }.disposed(by: rx.disposeBag)
        r.addGestureRecognizer(tap)
        return r
    }()
    lazy var walletLabel: UILabel = {
        let r = UILabel()
        r.textAlignment = .center
        r.backgroundColor = .init(hexString: "#E5F6EB")
        r.font = .regularFont(12)
        r.text = "T+0钱包"
        r.textColor = .init(hexString: "#00AA3C")
        r.corner(13)
        return r
    }()
    lazy var lineView: UIView = {
        let r = UIView()
        r.backgroundColor = .init(hexString: "#F5F5F5")
        return r
    }()
    lazy var moneyTitleLabel: UILabel = {
        let r = UILabel()
        r.textColor = .black666
        r.font = .regularFont(14)
        r.textAlignment = .right
        r.text = "可用余额："
        return r
    }()
    lazy var moneyLabel: UILabel = {
        let r = UILabel()
        r.textColor = .primaryColor
        r.font = .mediumFont(14)
        r.textAlignment = .right
        r.text = "0.00C"
        return r
    }()
    lazy var typeView: UIView = {
        let r = UIView()
        let width = (kScreenWidth-64-24)/4
        for (index,item) in titleArray.enumerated() {
            let btn = QMUIButton()
            btn.setTitle(item, for: .normal)
            btn.titleLabel?.font = .semiboldFont(16)
            btn.border(.init(hexString: "#EAEAEA"),borderWidth: 1,cornerRadius: 6)
            btn.setTitleColor(.black666, for: .normal)
            btn.backgroundColor = .white
            btn.rx.tap.subscribe(onNext: { [weak self] in
                self?.endEditing(true)
                if self?.selectBtn != btn{
                    if self?.selectBtn != nil{
                        self?.selectBtn.border(.init(hexString: "#EAEAEA"),borderWidth: 1,cornerRadius: 6)
                        self?.selectBtn.setTitleColor(.black666, for: .normal)
                        self?.selectBtn.backgroundColor = .white
                    }
                    btn.border(.primaryColor,borderWidth: 1,cornerRadius: 6)
                    btn.setTitleColor(.primaryColor, for: .normal)
                    btn.backgroundColor = .init(hexString: "#F3F8FF")
                    self?.selectBtn = btn
                    self?.chooseMoney = item
                    self?.countTF.text = item
                    if let doubleValue = Double(item) {
                        if self?.buyTypeBtn.isSelected == true{
                            //金额
                            self?.expectedIncomeLabel.text = String(format: "%.2f C",doubleValue/(self?.homeData?.exchangeRate ?? 1.00))
                        }else{
                            //数量
                            self?.expectedIncomeLabel.text = String(format: "￥%.2f",(self?.homeData?.exchangeRate ?? 1.00)*doubleValue)
                        }
                    }
                }
            }).disposed(by: rx.disposeBag)
            r.addSubview(btn)
            btn.snp_makeConstraints { make in
                make.left.equalTo((Int(width)+8)*(index%4))
                make.top.equalTo(r).offset((40+8)*(index/4))
                make.width.equalTo(width)
                make.height.equalTo(40)
            }
            self.btnArray.append(btn)
        }
        return r
    }()
    private lazy var paymentMethodView: UIView = {
        let r = UIView()
        r.backgroundColor = .white
        r.corner(8)
        r.addSubview(paymentMethodTitleLabel)
        r.addSubview(paymentBgView)
        r.addSubview(exchangeRateView)
        r.addSubview(expectedIncomeLabel)
        r.addSubview(expectedIncomeTitleLabel)
        paymentMethodTitleLabel.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.top.equalTo(14)
            make.height.equalTo(20)
            make.right.equalTo(-16)
        }
        paymentBgView.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.top.equalTo(paymentMethodTitleLabel.snp_bottom).offset(12)
            make.height.equalTo(72)
            make.right.equalTo(-16)
        }
        exchangeRateView.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.height.equalTo(16)
            make.bottom.equalTo(-16)
            make.width.equalTo(124)
        }
        expectedIncomeLabel.snp_makeConstraints { make in
            make.right.equalTo(-16)
            make.centerY.equalTo(exchangeRateView)
        }
        expectedIncomeTitleLabel.snp_makeConstraints { make in
            make.right.equalTo(expectedIncomeLabel.snp_left)
            make.centerY.equalTo(exchangeRateView)
        }
        
        return r
    }()
    private lazy var paymentMethodTitleLabel: UILabel = {
        let r = UILabel()
        r.textColor = .black333
        r.font = .mediumFont(16)
        r.text = type == 1 ? "选择支付方式" : "选择收款方式"
        return r
    }()
    private lazy var paymentBgView: UIView = {
        let r = UIView()
        r.backgroundColor = .init(hexString: "#EAF5FF")
        r.border(.init(hexString: "#BEDFFF"),borderWidth: 1,cornerRadius: 8)
        r.addSubview(addView)
        r.addSubview(choosePaymentView)
        r.addSubview(choosePaymentMethodView)
        addView.snp_makeConstraints { make in
            make.left.right.top.bottom.equalTo(r)
        }
        choosePaymentView.snp_makeConstraints { make in
            make.left.right.top.bottom.equalTo(r)
        }
        choosePaymentMethodView.snp_makeConstraints { make in
            make.left.right.top.bottom.equalTo(r)
        }
        return r
    }()
    private lazy var exchangeRateView: UIView = {
        let r = UIView()
        r.addSubview(exchangeRateLabel)
        r.addSubview(refreshImageView)
        exchangeRateLabel.snp_makeConstraints { make in
            make.left.top.bottom.equalTo(r)
//            make.right.equalTo(refreshImageView.snp_left).offset(-1)
        }
        refreshImageView.snp_makeConstraints { make in
            make.centerY.equalTo(r)
            make.width.equalTo(11)
            make.height.equalTo(11)
            make.left.equalTo(exchangeRateLabel.snp_right).offset(2)
        }
        let tap = UITapGestureRecognizer()
        tap.rx.event.subscribe {[weak self]  _ in
            self?.endEditing(true)
            if self?.isRefresh == false {
                self?.isRefresh = true
                BoBBuyAndSellCionModel.RefreshTheExchangeRateRequest(){data in
                    self?.stopRote()
                    self?.homeData?.exchangeRate = data
                    self?.exchangeRateLabel.text = "参考汇率 ￥" + String(format: "%.2f", data)
                } completionHandler:{errCode,errMsg in
                    self?.stopRote()
                }
                self?.rotateImageView()
            }
        }.disposed(by: rx.disposeBag)
        r.addGestureRecognizer(tap)
        
        return r
    }()
    func stopRote(){
       refreshImageView.layer.removeAllAnimations()
       isRefresh = false
    }
    func rotateImageView() {
        // 定义旋转动画
        refreshImageView.layer.removeAllAnimations()
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = NSNumber(value: Double.pi * 2)
        rotationAnimation.duration = 0.45
        rotationAnimation.isCumulative = true
        rotationAnimation.repeatCount = 140
        rotationAnimation.isRemovedOnCompletion = false
        refreshImageView.layer.add(rotationAnimation, forKey: nil)
        }
    private lazy var exchangeRateLabel: UILabel = {
        let r = UILabel()
        r.textColor = .black333
        r.font = .regularFont(14)
        r.text = "参考汇率 ￥1.00"
        return r
    }()
    private lazy var refreshImageView: UIView = {
        let r = UIImageView(image: UIImage(named: "mine_home_refresh_icon")?.changeImageColor(color: .primaryColor))
        return r
    }()
    private lazy var expectedIncomeTitleLabel: UILabel = {
        let r = UILabel()
        r.textColor = .black333
        r.font = .mediumFont(14)
        r.text = "预计获得："
        r.textAlignment = .right
        return r
    }()
    private lazy var expectedIncomeLabel: UILabel = {
        let r = UILabel()
        r.textColor = .init(hexString: "#F32525")
        r.font = .mediumFont(20)
        r.text = "¥0.00"
        r.textAlignment = .right
        return r
    }()
    
    private lazy var addView: UIView = {
        let r = UIView()
        let label1 = UILabel()
        label1.text = type == 1 ?"添加支付方式":"添加收款方式"
        label1.textColor = .white
        label1.font = .regularFont(14)
        label1.backgroundColor = .init(hexString: "#388CEF")
        label1.textAlignment = .center
        label1.corner(16)
        r.addSubview(label1)
        let label2 = UILabel()
        label2.text = type == 1 ?"请点击按钮添加支付方式":"请点击按钮添加收款方式"
        label2.textColor = .black666
        label2.font = .regularFont(16)
        r.addSubview(label2)
        label1.snp_makeConstraints { make in
            make.right.equalTo(-16)
            make.centerY.equalTo(r)
            make.width.equalTo(107)
            make.height.equalTo(32)
        }
        label2.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.centerY.equalTo(r)
            make.right.equalTo(label1.snp_left).offset(-10)
        }
        let tap = UITapGestureRecognizer()
        tap.rx.event.subscribe { [weak self] _ in
            self?.endEditing(true)
            if IMController.shared.certificationLevel == 0{
                let alert = UIAlertController(title: "提示", message: "请先进行实名认证".innerLocalized(), preferredStyle: .alert)
                // 创建UIAlertAction，用于处理用户的选择
                let cancleAction = UIAlertAction(title: "取消".innerLocalized(), style: .default) { _ in
                }
                let okAction = UIAlertAction(title: "去认证".innerLocalized(), style: .default) { _ in
                    let vc =  BoBRealNameMainViewController()
                    self?.currentVC?.navigationController?.pushViewController(vc, animated: true)
                }
                // 将action添加到alertController上
                alert.addAction(cancleAction)
                alert.addAction(okAction)
                // 弹出alert
                self?.currentVC?.present(alert, animated: true, completion: nil)
            }else{
                let vc = BoBAddPaymentMethodViewController()
                vc.name = self?.homeData?.userBankAndWeiXinAndZFBPO?.name
                self?.currentVC?.navigationController?.pushViewController(vc, animated: true)
            }
        }.disposed(by: rx.disposeBag)
        r.addGestureRecognizer(tap)
        return r
    }()
    private lazy var choosePaymentView: UIView = {
        let r = UIView()
        r.hide()
        let v = UIImageView(image: UIImage(named: "SuperChevronRight")!.changeImageColor(color: .init(hexString: "#7AB4F8")))
        v.contentMode = .scaleAspectFit
        r.addSubview(v)
        r.addSubview(paymentMethodIcon)
        r.addSubview(paymentMethodName)
        r.addSubview(paymentMethodUserName)
        r.addSubview(paymentMethodNumber)
        paymentMethodIcon.snp_makeConstraints { make in
            make.left.equalTo(18)
            make.centerY.equalTo(r)
            make.width.height.equalTo(30)
        }
        paymentMethodName.snp_makeConstraints { make in
            make.top.equalTo(15)
            make.left.equalTo(paymentMethodIcon.snp_right).offset(13)
            make.width.lessThanOrEqualTo(kScreenWidth-32-18-30-13-40-6-80)
            make.height.equalTo(16)
//            make.right.equalTo(-45)
        }
        paymentMethodUserName.snp_makeConstraints { make in
            make.left.equalTo(paymentMethodName.snp_right).offset(6)
            make.bottom.equalTo(paymentMethodName).offset(2)
            make.right.equalTo(-40)
            make.height.equalTo(16)

        }
        paymentMethodNumber.snp_makeConstraints { make in
            make.bottom.equalTo(-15)
            make.left.right.equalTo(paymentMethodName)
            make.height.equalTo(16)
        }
        v.snp_makeConstraints { make in
            make.right.equalTo(-16)
            make.centerY.equalTo(r)
            make.width.height.equalTo(16)
        }
        let tap = UITapGestureRecognizer()
        tap.rx.event.subscribe { [weak self] _ in
            // 选择银行卡
            self?.endEditing(true)
            self?.choosePaymentMedthodType()
        }.disposed(by: rx.disposeBag)
        r.addGestureRecognizer(tap)        
        return r
    }()
    private lazy var paymentMethodIcon: UIImageView = {
        let r = UIImageView()
        
        return r
    }()
    private lazy var paymentMethodName: UILabel = {
        let r = UILabel()
        r.textColor = .black333
        r.font = .mediumFont(16)
        return r
    }()
    private lazy var paymentMethodUserName: UILabel = {
        let r = UILabel()
        r.textColor = .black999
        r.font = .regularFont(12)
        return r
    }()
    
    private lazy var paymentMethodNumber: UILabel = {
        let r = UILabel()
        r.textColor = .black666
        r.font = .regularFont(14)
        return r
    }()
    private lazy var choosePaymentMethodView: UIView = {
        let r = UIView()
        r.hide()
        let v = UIImageView(image: UIImage(named: "SuperChevronRight")!.changeImageColor(color: .init(hexString: "#7AB4F8")))
        v.contentMode = .scaleAspectFit
        r.addSubview(v)
        let label = UILabel()
        label.textColor = .black666
        label.font = .regularFont(16)
        label.text = type == 1 ?"选择支付方式":"选择收款方式"
        r.addSubview(label)
        label.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.centerY.equalTo(r)
            make.right.equalTo(-45)
        }
        v.snp_makeConstraints { make in
            make.right.equalTo(-16)
            make.centerY.equalTo(r)
            make.width.height.equalTo(16)
        }
        let tap = UITapGestureRecognizer()
        tap.rx.event.subscribe { [weak self] _ in
            // 选择银行卡
            self?.endEditing(true)
            self?.choosePaymentMedthodType()
        }.disposed(by: rx.disposeBag)
        r.addGestureRecognizer(tap)
        return r
    }()
    
    private lazy var buyBtn: QMUIButton = {
        let r = ViewFactoryUtil.linkButton("购买C".localized())
        r.setTitleColor(.white, for: .normal)
        r.corner(25)
        r.titleLabel?.font = .semiboldFont(16)
        r.backgroundColor = .primaryColor
        r.rx.tap.subscribe(onNext: { [weak self] in
            self?.endEditing(true)
            if let doubleValue = Double(self?.countTF.text ?? "0") {
                if doubleValue == 0{
                    SuperToast.show(title: "请输入" + (self?.type == 1 ? "购买":"出售") + ((self?.buyTypeBtn.isSelected)! ? "金额":"数量"))
                    return
                }
            }else{
                SuperToast.show(title: "请输入" + (self?.type == 1 ? "购买":"出售") + ((self?.buyTypeBtn.isSelected)! ? "金额":"数量"))
                return
            }
            if self?.choosePaymentMethod == nil{
                SuperToast.show(title: self?.type == 1 ?"请选择支付方式":"请选择收款方式")
                return
            }
            
            if IMController.shared.certificationLevel == 0 {
                let alert = UIAlertController(title: "提示", message: "请先进行实名认证".innerLocalized(), preferredStyle: .alert)
                // 创建UIAlertAction，用于处理用户的选择
                let cancleAction = UIAlertAction(title: "取消", style: .default) { _ in
                }
                let okAction = UIAlertAction(title: "去认证", style: .default) { _ in
                    let vc =  BoBRealNameMainViewController()
                    self?.currentVC?.navigationController?.pushViewController(vc, animated: true)
                }
                // 将action添加到alertController上
                alert.addAction(cancleAction)
                alert.addAction(okAction)
                // 弹出alert
                self?.currentVC?.present(alert, animated: true, completion: nil)
            }else{
                var payment = "1"
                if self?.choosePaymentMethod?.type == "bank"{
                    payment = "1"
                }else if self?.choosePaymentMethod?.type == "weiXin"{
                    payment = "3"
                }else{
                    payment = "2"
                }
                if self?.type == 1{
                    //购买
                    BoBBuyAndSellCionModel.QuickBuyCoinRequest(paymentId: String(self?.choosePaymentMethod?.id ?? 0), payment: payment, amountOrNumber: (self?.buyTypeBtn.isSelected)!  ? "2":"1", input: self?.countTF.text ?? "0", currency: self?.currency ?? "C"){code in
                        let vc = BoBOrderDetailViewController()
                        vc.code = code
                        self?.currentVC?.navigationController?.pushViewController(vc, animated: true)
                    } completionHandler:{errCode,errMsg in
                        if errCode == 20082{
                            self?.errorAlertViewShow()
                        }else{
                            SuperToast.show(title: errMsg)
                        }
                    }
                }else{
                    //出售
                    if IMController.shared.isSetPayPassWord {
                        let passWordView = BoBPayPassWordView()
                        passWordView.tg_width.equal(.fill)
                        passWordView.tg_height.equal(210)
                        passWordView.payBtnClickBlock = { [weak self] passWord in
                            BoBBuyAndSellCionModel.QuickSellCoinRequest(paymentId: String(self?.choosePaymentMethod?.id ?? 0), payment: payment, amountOrNumber: (self?.buyTypeBtn.isSelected)!  ? "2":"1", input: self?.countTF.text ?? "0", currency: self?.currency ?? "C",currencyWallet:self?.chooseCionTypeModel?.cionType ?? "0",passWord:passWord){code in
                                let vc = BoBOrderDetailViewController()
                                vc.code = code
                                self?.currentVC?.navigationController?.pushViewController(vc, animated: true)
                            } completionHandler:{errCode,errMsg in
                                if errCode == 20082{
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        self?.errorAlertViewShow()
                                    }
                                }else{
                                    SuperToast.show(title: errMsg)
                                }
                            }

                        }

                        GKCover.cover(from: self?.currentVC?.view.window, contentView: passWordView, style: .translucent, showStyle: .center, showAnimStyle: .bottom, hideAnimStyle: .bottom, notClick: false)
                        
                    }else{
                        let alert = UIAlertController(title: "提示", message: "为了您的财产安全，请设置安全密码".innerLocalized(), preferredStyle: .alert)
                        // 创建UIAlertAction，用于处理用户的选择
                        let cancleAction = UIAlertAction(title: "取消", style: .default) { _ in
                        }
                        let okAction = UIAlertAction(title: "去设置", style: .default) { _ in
                            let vc = BoBChangePayPassWordViewController()
                            vc.passWordType = 0
                            self?.currentVC?.navigationController?.pushViewController(vc,animated: true)
                        }
                        // 将action添加到alertController上
                        alert.addAction(cancleAction)
                        alert.addAction(okAction)
                        // 弹出alert
                        self?.currentVC?.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }).disposed(by: rx.disposeBag)
        return r
    }()
    
    func errorAlertViewShow(){
        let errorAlertView = BoBQuickBuyAndSellErrorAlertView()
        errorAlertView.tg_width.equal(.fill)
        errorAlertView.tg_height.equal(224)
        errorAlertView.contentLabel.text = (type == 1 ? "购买":"出售") + (buyTypeBtn.isSelected ? "金额: ￥":"数量: ") + (self.countTF.text ?? "0.00") + (buyTypeBtn.isSelected ? "":(currency ?? "C"))
        GKCover.cover(from: self.currentVC?.view.window, contentView: errorAlertView, style: .translucent, showStyle: .bottom, showAnimStyle: .bottom, hideAnimStyle: .bottom, notClick: false)
    }
}

extension BoBQuickBuyAndSellView: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return self
    }
    func listWillAppear() {
        loadDailyLimit()
    }
    func listWillDisappear() {
        self.endEditing(true)
    }
}

