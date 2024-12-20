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
    var updateAdData:((_ adDetailData:BoBMineAdList)->())!
    var homeData:BoBBuyAndSellHomeData?
    var advertisementType:Int = 1 //1出售，2购买
//    var paymentType:Int = 1 //1银行卡，2支付宝，3微信
    var isChooseBank:Bool = false
    var isChooseAli:Bool = false
    var isChooseWx:Bool = false
    var exchangeRateType:Int = 2 //1浮动，2固定
    var advertisingName:String? //广告商名字
    var code = "000"//广告编号
    var currency = "C"
    var chooseCionTypeModel:CionTypeModel?
    var cionTypeArray:[CionTypeModel] = []
    var adDetailData:BoBMineAdList?
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
        if adDetailData != nil{
            title = "修改广告"
            advertisementType = adDetailData?.advertisingType ?? 1
            exchangeRateType = adDetailData?.exchangeRateType ?? 2
            code = adDetailData?.code ?? ""
            currency = adDetailData?.advertisingCurrency ?? "C"
        }else{
            title = "创建广告"
        }
        advertisingName = homeData?.advertisingName
        chooseCionTypeModel = CionTypeModel(icon: "", currency: currency, quota: 0.00, handlingCharge: 0.00, minimumCommission: 0.00, cionType:"0", money:0.00, type: 0, isSelect: true,exchangeRate:1.00)
        scrollViewContainer.tg_padding = UIEdgeInsets(top: 0, left: PADDING_OUTER, bottom: PADDING_OUTER, right: PADDING_OUTER)
        superFooterContainerContainer.tg_bottom.equal(0)
        scrollViewContainer.addSubview(currencyView)
        scrollViewContainer.addSubview(paymentView)
        scrollViewContainer.addSubview(exchangeRateTypeView)
        scrollViewContainer.addSubview(exchangeRateView)
        if advertisementType == 1{
            scrollViewContainer.addSubview(walletView)
            loadData()
        }
        scrollViewContainer.addSubview(advertisementCountView)
        scrollViewContainer.addSubview(limitMoneyView)
        scrollViewContainer.addSubview(limitRegisterView)
        scrollViewContainer.addSubview(statusView)
        scrollViewContainer.addSubview(sureBtn)
        let tap = UITapGestureRecognizer()
        tap.rx.event.subscribe {  _ in
            self.view.endEditing(true)
        }.disposed(by: rx.disposeBag)
        scrollViewContainer.addGestureRecognizer(tap)
        if adDetailData != nil{
            if exchangeRateType == 1{
                //浮动
                exchangeRateTF.text = String(format: "%.2f", adDetailData?.floatingIndex ?? 1.00)
            }else{
                //固定
                exchangeRateTF.text = String(format: "%.2f", adDetailData?.setExchangeRate ?? 1.00)
            }
            if advertisementType == 1{
                chooseCionTypeModel = CionTypeModel(icon: adDetailData?.icon, currency: currency, quota: 0.00, handlingCharge: 0.00, minimumCommission: 0.00, cionType:String(format: "%d", adDetailData?.currencyWallet ?? 0), money:0.00, type: adDetailData?.currencyWallet ?? 0, isSelect: true,exchangeRate:1.00)
                cionTypeImageView.sd_setImage(with: URL(string: chooseCionTypeModel?.icon))
                cionNameLabel.text = chooseCionTypeModel?.currency
                if chooseCionTypeModel?.type == 0{
                    walletType.text = "T+0钱包"
                    walletType.textColor = .init(hexString: "#00AA3C")
                    walletType.backgroundColor = .init(hexString: "#E5F6EB")
                }else{
                    walletType.text = "T+1钱包"
                    walletType.textColor = .init(hexString: "#FFA756")
                    walletType.backgroundColor = .init(hexString: "#FFF7E5")
                }
            }
            advertisementCountTF.text = String(format: "%.2f", adDetailData?.surplusQuantity ?? 0.00)
            advertisementCountTF.isUserInteractionEnabled = false
            limitMixMoneyTF.text = String(format: "%.2f", adDetailData?.quotaMin ?? 0.00)
            limitMaxMoneyTF.text = String(format: "%.2f", adDetailData?.quotaMax ?? 0.00)
            if adDetailData?.termsOfTradeZc ?? 0 > 0{
                limitRegisterTF.text = String(format: "%d", adDetailData?.termsOfTradeZc ?? 0)
                limitRegisterBtn.isSelected = true
            }
            calculationExchangeRate()
        }
        for i in 0..<(homeData?.userBankAndWeiXinAndZFBPO?.stringAndDatePOS?.count ?? 0) {
            let data = (homeData?.userBankAndWeiXinAndZFBPO?.stringAndDatePOS![safe: i]!)! as stringAndDatePOS
            if data.type == "bank"{
                isChooseBank = true
            }else if data.type == "weiXin"{
               isChooseWx = true
            }else{
                isChooseAli = true
            }
            if isChooseBank && isChooseWx && isChooseAli{
                break
            }
        }
        bankBtn.alpha = isChooseBank ? 1 : 0.5
        bankBtn.isUserInteractionEnabled = isChooseBank
        bankBtn.border(isChooseBank ? .init(hexString: "#277FE6") : .white,borderWidth: 1,cornerRadius: 8)
        bankBtn.backgroundColor = isChooseBank ? .init(hexString: "#F3F7FB") : .white
        bankBtn.selectStatusImageView.isHidden = !isChooseBank
        aliBtn.alpha = isChooseAli ? 1 : 0.5
        aliBtn.isUserInteractionEnabled = isChooseAli
        aliBtn.border(isChooseAli ? .init(hexString: "#277FE6") : .white,borderWidth: 1,cornerRadius: 8)
        aliBtn.backgroundColor = isChooseAli ? .init(hexString: "#F3F7FB") : .white
        aliBtn.selectStatusImageView.isHidden = !isChooseAli
        weixinBtn.alpha = isChooseWx ? 1 : 0.5
        weixinBtn.isUserInteractionEnabled = isChooseWx
        weixinBtn.border(isChooseWx ? .init(hexString: "#277FE6") : .white,borderWidth: 1,cornerRadius: 8)
        weixinBtn.backgroundColor = isChooseWx ? .init(hexString: "#F3F7FB") : .white
        weixinBtn.selectStatusImageView.isHidden = !isChooseWx
    }
    func loadData(){
        BoBBuyAndSellCionModel.QueryBalanceByCurrencyRequest(currency:currency){[weak self] data in
            let model1 = CionTypeModel(icon: data.icon, currency: self?.currency, quota: 0.00, handlingCharge: 0.00, minimumCommission: 0.00, cionType: "0", money: data.t0, type: 0, isSelect: true,exchangeRate:0.00)
            let model2 = CionTypeModel(icon: data.icon, currency: self?.currency, quota: 0.00, handlingCharge: 0.00, minimumCommission: 0.00, cionType: "1", money: data.t1, type: 1, isSelect: false,exchangeRate:0.00)
            self?.cionTypeArray.append(model1)
            self?.cionTypeArray.append(model2)
            if self?.chooseCionTypeModel?.type == model1.type{
                self?.chooseCionTypeModel = model1
            }else{
                self?.chooseCionTypeModel = model2
            }
            self?.refreshUI()
        } completionHandler: {errCode,errMsg in
            SuperToast.show(title: errMsg)
        }
    }
    func refreshUI(){
        cionTypeImageView.sd_setImage(with: URL(string: chooseCionTypeModel?.icon))
        cionNameLabel.text = chooseCionTypeModel?.currency
        if chooseCionTypeModel?.type == 0{
            walletType.text = "T+0钱包"
            walletType.textColor = .init(hexString: "#00AA3C")
            walletType.backgroundColor = .init(hexString: "#E5F6EB")
        }else{
            walletType.text = "T+1钱包"
            walletType.textColor = .init(hexString: "#FFA756")
            walletType.backgroundColor = .init(hexString: "#FFF7E5")
        }
        let str = "可用余额：" + String(format: "%.2f",(chooseCionTypeModel?.money)!) + (chooseCionTypeModel?.currency)!
        let attributedString = NSMutableAttributedString(string: str)
        attributedString.addAttribute(.foregroundColor, value: UIColor.primaryColor, range: NSRange(location: 5, length: str.length-5))
        totalMoneyLabel.attributedText = attributedString
        cionTypeImageView.sd_setImage(with: URL(string: chooseCionTypeModel?.icon))
        cionNameLabel.text = chooseCionTypeModel?.currency
    }
    func calculationExchangeRate(){
        if let doubleValue = Double(exchangeRateTF.text ?? "0.01") {
            if exchangeRateType == 1{
                //浮动
                setExchangeRateLabel.text = "1 C × " + String(format: "%.0f", doubleValue*100) + "% × " + String(format: "%.0f", (homeData?.exchangeRate ?? 1.00)*100) + "% = " + String(format: "%.2f", doubleValue*(homeData?.exchangeRate ?? 1.00)) + " CNY"
            }else{
                //固定
                setExchangeRateLabel.text = "1 C × " + String(format: "%.0f", doubleValue*100) + "% = " + String(format: "%.2f", doubleValue) + " CNY"
            }
            advertisementMoneyLabel.text = "≈0.00 CNY"
            if let advertisementCount = Double(advertisementCountTF.text ?? "0.00") {
                if exchangeRateType == 1{
                    //浮动
                    advertisementMoneyLabel.text = String(format: "≈%.2f CNY", doubleValue*(homeData?.exchangeRate ?? 1.00)*advertisementCount)
                }else{
                    //固定
                    advertisementMoneyLabel.text = String(format: "≈%.2f CNY", advertisementCount*doubleValue)
                }
            }
            limitMixMoneyLabel.text = "≈0.00 C"
            if let limitMixMoneyCount = Double(limitMixMoneyTF.text ?? "0.00") {
                if exchangeRateType == 1{
                    //浮动
                    limitMixMoneyLabel.text = String(format: "≈%.2f C", limitMixMoneyCount/(doubleValue*(homeData?.exchangeRate ?? 1.00)))
                }else{
                    //固定
                    limitMixMoneyLabel.text = String(format: "≈%.2f C", limitMixMoneyCount/doubleValue)
                }
            }
            limitMaxMoneyLabel.text = "≈0.00 C"
            if let limitMaxMoneyCount = Double(limitMaxMoneyTF.text ?? "0.00") {
                if exchangeRateType == 1{
                    //浮动
                    limitMaxMoneyLabel.text = String(format: "≈%.2f C", limitMaxMoneyCount/(doubleValue*(homeData?.exchangeRate ?? 1.00)))
                }else{
                    //固定
                    limitMaxMoneyLabel.text = String(format: "≈%.2f C", limitMaxMoneyCount/doubleValue)
                }
            }
        }
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
        r.btn.rx.tap.subscribe(onNext: { [weak self] in
            self?.view.endEditing(true)
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
        r.backgroundColor = .white
        r.border(.white,borderWidth: 1,cornerRadius: 8)
        r.bindData(title: "银行卡", icon: UIImage(named: "mine_payment_method_bank_icon")!)
        r.btn.rx.tap.subscribe(onNext: { [weak self] in
            self?.view.endEditing(true)
            self?.isChooseBank = !(self?.isChooseBank ?? false)
            r.border(self?.isChooseBank == true ? .init(hexString: "#277FE6") : .white,borderWidth: 1,cornerRadius: 8)
            r.backgroundColor = self?.isChooseBank == true ? .init(hexString: "#F3F7FB") : .white
            r.selectStatusImageView.isHidden = !(self?.isChooseBank ?? false)
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
        r.border(.white,borderWidth: 1,cornerRadius: 8)
        r.bindData(title: "支付宝", icon: UIImage(named: "mine_payment_method_ali_icon")!)
        r.btn.rx.tap.subscribe(onNext: { [weak self] in
            self?.view.endEditing(true)
            self?.isChooseAli = !(self?.isChooseAli ?? false)
            r.border(self?.isChooseAli == true ? .init(hexString: "#277FE6") : .white,borderWidth: 1,cornerRadius: 8)
            r.backgroundColor = self?.isChooseAli == true ? .init(hexString: "#F3F7FB") : .white
            r.selectStatusImageView.isHidden = !(self?.isChooseAli ?? false)
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
            self?.view.endEditing(true)
            self?.isChooseWx = !(self?.isChooseWx ?? false)
            r.border(self?.isChooseWx == true ? .init(hexString: "#277FE6") : .white,borderWidth: 1,cornerRadius: 8)
            r.backgroundColor = self?.isChooseWx == true ? .init(hexString: "#F3F7FB") : .white
            r.selectStatusImageView.isHidden = !(self?.isChooseWx ?? false)
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
        let icon = UIImageView(image: UIImage(named: "mine_buy_and_sell_free_choose_icon"))
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
        let tap = UITapGestureRecognizer()
        tap.rx.event.subscribe {  _ in
            self.view.endEditing(true)
            //选择
            let choosePushAdTypeView = BoBChoosePushAdTypeView()
            choosePushAdTypeView.tg_width.equal(.fill)
            choosePushAdTypeView.tg_height.equal(193)
            choosePushAdTypeView.drawUI(array: ["固定","浮动"])
            choosePushAdTypeView.choosePushAdTypeBlock = { [weak self] typeIndex in
                if typeIndex == 0{
                    //固定
                    self?.exchangeRateTypeLabel.text = "固定"
                    self?.exchangeRateType = 2
                    self?.exchangeRateTitleLabel.text =  "固定汇率"
                }else if typeIndex == 1{
                    //浮动
                    self?.exchangeRateTypeLabel.text = "浮动"
                    self?.exchangeRateType = 1
                    self?.exchangeRateTitleLabel.text = "浮动指数"
                }
                self?.calculationExchangeRate()
            }
            GKCover.cover(from: self.view.window, contentView: choosePushAdTypeView, style: .translucent, showStyle: .bottom, showAnimStyle: .bottom, hideAnimStyle: .bottom, notClick: false)
        }.disposed(by: rx.disposeBag)
        r.addGestureRecognizer(tap)
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
        bgView.tg_width.equal(kScreenWidth-32)
        bgView.tg_gravity = .horz.between
        bgView.backgroundColor = .white
        bgView.corner(8)
        r.addSubview(bgView)
        bgView.addSubview(reduceBtn)
        bgView.addSubview(exchangeRateTF)
        bgView.addSubview(addBtn)
        r.addSubview(setExchangeRate)
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
            self?.view.endEditing(true)
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
            self?.view.endEditing(true)
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
        r.tg_height.equal(48)
        r.tg_width.equal(kScreenWidth-32-82-30)
        r.font = .regularFont(16)
        r.tintColor = .black333
        r.textAlignment = .center
        r.keyboardType = .decimalPad
        r.setPlaceHolderTextColor(.black999)
        r.placeholder = "输入汇率"
        r.text = "1.00"
        r.rx.controlEvent(.editingDidEnd).subscribe(onNext: { [weak self] in
            if let doubleValue = Double(self?.exchangeRateTF.text ?? "0.01") {
                if doubleValue < 0.01{
                    self?.exchangeRateTF.text = "1.00"
                }
            }else{
                self?.exchangeRateTF.text = "1.00"
            }
            self?.calculationExchangeRate()
        }).disposed(by: rx.disposeBag)
        r.rx.controlEvent(.editingChanged).subscribe(onNext: {  [weak self] in
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
        }).disposed(by: rx.disposeBag)
        return r
    }()
    lazy var setExchangeRate: UIView = {
        let r = UIView()
        r.tg_top.equal(12)
        r.tg_left.equal(0)
        r.tg_width.equal(kScreenWidth-32)
        r.tg_height.equal(36)
        let label1 = UILabel()
        label1.text = "设置汇率"
        label1.textColor = .black666
        label1.font = .regularFont(14)
        r.addSubview(label1)
        label1.snp_makeConstraints { make in
            make.left.top.equalTo(r)
            make.right.equalTo(-225)
            make.height.equalTo(15)
        }
        let label2 = UILabel()
        label2.text = advertisementType == 1 ? "最低广告汇率" :"最高广告汇率"
        label2.textColor = .black666
        label2.font = .regularFont(14)
        r.addSubview(label2)
        label2.snp_makeConstraints { make in
            make.left.bottom.equalTo(r)
            make.right.equalTo(-190)
            make.height.equalTo(15)
        }
        r.addSubview(setExchangeRateLabel)
        r.addSubview(advertisementExchangeRateLabel)
        setExchangeRateLabel.snp_makeConstraints { make in
            make.right.equalTo(0)
            make.centerY.equalTo(label1)
            make.width.equalTo(220)
        }
        advertisementExchangeRateLabel.snp_makeConstraints { make in
            make.right.equalTo(0)
            make.centerY.equalTo(label2)
            make.width.equalTo(180)
        }
        return r
    }()
    lazy var setExchangeRateLabel: UILabel = {
        let r = UILabel()
        r.textAlignment = .right
        r.textColor = .black666
        r.font = .regularFont(14)
        r.text = "1 C × 100% = 1.00 CNY"
        return r
    }()
    lazy var advertisementExchangeRateLabel: UILabel = {
        let r = UILabel()
        r.textAlignment = .right
        r.textColor = .black666
        r.font = .regularFont(14)
        r.text = "1 C = " + String(format: "%.2f", (advertisementType == 1 ? homeData?.minimumAdvertisedRate : homeData?.maximumAdvertisedRate) ?? 1.00) + " CNY"
        return r
    }()
    lazy var walletView: TGLinearLayout = {
        let r = TGLinearLayout(.vert)
        r.tg_top.equal(22)
        r.tg_left.equal(0)
        r.tg_height.equal(76)
        r.tg_width.equal(kScreenWidth-32)
        let label = UILabel()
        label.tg_left.equal(0)
        label.tg_top.equal(0)
        label.tg_height.equal(18)
        label.tg_width.equal(.wrap)
        label.textColor = .black333
        label.font = .mediumFont(16)
        label.text = "钱包"
        r.addSubview(label)
        let v = TGLinearLayout(.horz)
        v.tg_top.equal(10)
        v.tg_left.equal(0)
        v.tg_height.equal(48)
        v.tg_width.equal(kScreenWidth-32)
        v.backgroundColor = .white
        v.corner(8)
        v.addSubview(cionTypeImageView)
        v.addSubview(cionNameLabel)
        v.addSubview(walletType)
        let rightIcon = UIImageView(image: UIImage(named: "SuperChevronRight"))
        rightIcon.tintColor = .black80
        rightIcon.contentMode = .scaleAspectFit
        v.addSubview(rightIcon)
        r.addSubview(v)
        r.addSubview(totalMoneyLabel)
        rightIcon.snp_makeConstraints { make in
            make.centerY.equalTo(v)
            make.right.equalTo(-16)
            make.width.height.equalTo(15)
        }
        totalMoneyLabel.snp_makeConstraints { make in
            make.right.equalTo(0)
            make.left.equalTo(label.snp_right).offset(10)
            make.height.equalTo(18)
            make.centerY.equalTo(label)
        }
        let tap = UITapGestureRecognizer()
        tap.rx.event.subscribe {  _ in
            self.view.endEditing(true)
            let chooseTypeView = BoBChooseCionTypeView()
            chooseTypeView.tg_width.equal(.fill)
            chooseTypeView.tg_height.equal(240)
            chooseTypeView.reloadListArray(array: self.cionTypeArray)
            chooseTypeView.chooseCionBlock = { [weak self] model,array in
                self?.chooseCionTypeModel = model
                self?.cionTypeArray = array
                self?.refreshUI()
            }
            GKCover.cover(from: self.view.window, contentView: chooseTypeView, style: .translucent, showStyle: .bottom, showAnimStyle: .bottom, hideAnimStyle: .bottom, notClick: false)
        }.disposed(by: rx.disposeBag)
        r.addGestureRecognizer(tap)
       return r
    }()
    lazy var cionTypeImageView: UIImageView = {
        let r = UIImageView(image: UIImage(named: "mine_home_cion_c_icon"))
        r.tg_width.equal(26)
        r.tg_height.equal(26)
        r.tg_centerY.equal(0)
        r.tg_left.equal(16)
        return r
    }()
    lazy var cionNameLabel: UILabel = {
        let r = UILabel()
        r.tg_width.equal(.wrap)
        r.tg_height.equal(26)
        r.tg_centerY.equal(0)
        r.tg_left.equal(10)
        r.font = .mediumFont(16)
        r.text = currency
        r.textColor = .black333
        return r
    }()
    lazy var walletType: UILabel = {
        let r = UILabel()
        r.tg_width.equal(62)
        r.tg_height.equal(26)
        r.tg_centerY.equal(0)
        r.tg_left.equal(7)
        r.textColor = .init(hexString: "#00AA3C")
        r.backgroundColor = .init(hexString: "#E5F6EB")
        r.corner(13)
        r.font = .regularFont(12)
        r.text = "T+0钱包"
        r.textAlignment = .center
        return r
    }()
    lazy var totalMoneyLabel: UILabel = {
        let r = UILabel()
        r.font = .regularFont(14)
        r.textColor = .black666
        r.textAlignment = .right
        let str = "可用余额：0.00" + currency
        let attributedString = NSMutableAttributedString(string: str)
        attributedString.addAttribute(.foregroundColor, value: UIColor.primaryColor, range: NSRange(location: 5, length: str.length-5))
        r.attributedText = attributedString
        return r
    }()
    lazy var advertisementCountView: TGLinearLayout = {
        let r = TGLinearLayout(.vert)
        r.tg_top.equal(22)
        r.tg_left.equal(0)
        r.tg_right.equal(0)
        r.tg_height.equal(106)
        let label = UILabel()
        label.tg_left.equal(0)
        label.tg_top.equal(0)
        label.tg_height.equal(18)
        label.tg_width.equal(.wrap)
        label.textColor = .black333
        label.font = .mediumFont(16)
        label.text = "广告数量"
        r.addSubview(label)
        let bgView = UIView()
        bgView.tg_top.equal(10)
        bgView.tg_left.equal(0)
        bgView.tg_height.equal(48)
        bgView.tg_width.equal(kScreenWidth-32)
        bgView.backgroundColor = .white
        bgView.corner(8)
        r.addSubview(bgView)
        r.addSubview(advertisementMoneyLabel)
        bgView.addSubview(advertisementCurrencyLabel)
        bgView.addSubview(advertisementCountTF)
        advertisementCurrencyLabel.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.centerY.equalTo(bgView)
        }
        advertisementCountTF.snp_makeConstraints { make in
            make.left.equalTo(advertisementCurrencyLabel.snp_right).offset(10)
            make.centerY.equalTo(bgView)
            make.right.equalTo(-16)
        }
        return r
    }()
    lazy var advertisementCurrencyLabel: UILabel = {
        let r = UILabel()
        r.textColor = .black333
        r.font = .mediumFont(16)
        r.text = currency
        return r
    }()
    lazy var advertisementCountTF: QMUITextField = {
        let r = QMUITextField()
        r.font = .regularFont(16)
        r.tintColor = .black333
        r.keyboardType = .decimalPad
        r.setPlaceHolderTextColor(.black999)
        r.placeholder = "请输入广告数"
        r.text = ""
        r.rx.controlEvent(.editingDidEnd).subscribe(onNext: { [weak self] in
            if let doubleValue = Double(self?.advertisementCountTF.text ?? "0.00") {
                if doubleValue < 0.01{
                    self?.advertisementCountTF.text = ""
                }
            }else{
                self?.advertisementCountTF.text = ""
            }
            self?.calculationExchangeRate()
        }).disposed(by: rx.disposeBag)
        r.rx.controlEvent(.editingChanged).subscribe(onNext: {  [weak self] in
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
        }).disposed(by: rx.disposeBag)
        return r
    }()
    lazy var advertisementMoneyLabel: UILabel = {
        let r = UILabel()
        r.tg_top.equal(12)
        r.tg_left.equal(0)
        r.tg_width.equal(kScreenWidth-32)
        r.tg_height.equal(18)
        r.textColor = .black666
        r.font = .regularFont(14)
        r.text = "≈0.00 CNY"
        return r
    }()
    lazy var limitMoneyView: TGLinearLayout = {
        let r = TGLinearLayout(.vert)
        r.tg_top.equal(22)
        r.tg_left.equal(0)
        r.tg_width.equal(kScreenWidth-32)
        r.tg_height.equal(106)
        let label = UILabel()
        label.tg_left.equal(0)
        label.tg_top.equal(0)
        label.tg_height.equal(18)
        label.tg_width.equal(.wrap)
        label.textColor = .black333
        label.font = .mediumFont(16)
        label.text = "单笔订单限额"
        r.addSubview(label)
        let icon = UIImageView(image: UIImage(named: "mine_red_packet_count_reduce_icon"))
        r.addSubview(icon)
        r.addSubview(limitMixMoneyView)
        r.addSubview(limitMaxMoneyView)
        r.addSubview(limitMixMoneyLabel)
        r.addSubview(limitMaxMoneyLabel)
        icon.snp_makeConstraints { make in
            make.top.equalTo(label.snp_bottom).offset(17)
            make.left.equalTo((kScreenWidth-32)/2-4-17)
            make.width.height.equalTo(34)
        }
        limitMixMoneyView.snp_makeConstraints { make in
            make.left.equalTo(0)
            make.top.equalTo(label.snp_bottom).offset(10)
            make.height.equalTo(48)
            make.width.equalTo((kScreenWidth-32-42)/2)
        }
        limitMaxMoneyView.snp_makeConstraints { make in
            make.right.equalTo(0)
            make.top.equalTo(label.snp_bottom).offset(10)
            make.height.width.equalTo(limitMixMoneyView)
        }
        limitMixMoneyLabel.snp_makeConstraints { make in
            make.left.right.equalTo(limitMixMoneyView)
            make.top.equalTo(limitMixMoneyView.snp_bottom).offset(12)
            make.height.equalTo(18)
        }
        limitMaxMoneyLabel.snp_makeConstraints { make in
            make.left.right.equalTo(limitMaxMoneyView)
            make.top.equalTo(limitMaxMoneyView.snp_bottom).offset(12)
            make.height.equalTo(18)
        }
        return r
    }()
    lazy var limitMixMoneyView: UIView = {
        let r = UIView()
        r.backgroundColor = .white
        r.corner(8)
        let label = UILabel()
        label.text = "CNY"
        label.textColor = .black333
        label.font = .mediumFont(16)
        r.addSubview(label)
        r.addSubview(limitMixMoneyTF)
        label.snp_makeConstraints { make in
            make.right.equalTo(-16)
            make.centerY.equalTo(r)
        }
        limitMixMoneyTF.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.top.bottom.equalTo(r)
            make.right.equalTo(label.snp_left).offset(-15)
        }
        return r
    }()
    lazy var limitMixMoneyTF: QMUITextField = {
        let r = QMUITextField()
        r.font = .regularFont(16)
        r.tintColor = .black333
        r.keyboardType = .decimalPad
        r.setPlaceHolderTextColor(.black999)
        r.placeholder = "最小限额"
        r.text = ""
        r.rx.controlEvent(.editingDidEnd).subscribe(onNext: { [weak self] in
            if let doubleValue = Double(self?.limitMixMoneyTF.text ?? "0.00") {
                if doubleValue < 0.01{
                    self?.limitMixMoneyTF.text = ""
                }
            }else{
                self?.limitMixMoneyTF.text = ""
            }
            self?.calculationExchangeRate()
        }).disposed(by: rx.disposeBag)
        r.rx.controlEvent(.editingChanged).subscribe(onNext: {  [weak self] in
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
        }).disposed(by: rx.disposeBag)
        return r
    }()
    lazy var limitMaxMoneyView: UIView = {
        let r = UIView()
        r.backgroundColor = .white
        r.corner(8)
        let label = UILabel()
        label.text = "CNY"
        label.textColor = .black333
        label.font = .mediumFont(16)
        r.addSubview(label)
        r.addSubview(limitMaxMoneyTF)
        label.snp_makeConstraints { make in
            make.right.equalTo(-16)
            make.centerY.equalTo(r)
        }
        limitMaxMoneyTF.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.top.bottom.equalTo(r)
            make.right.equalTo(label.snp_left).offset(-15)
        }
        return r
    }()
    lazy var limitMaxMoneyTF: QMUITextField = {
        let r = QMUITextField()
        r.font = .regularFont(16)
        r.tintColor = .black333
        r.keyboardType = .decimalPad
        r.setPlaceHolderTextColor(.black999)
        r.placeholder = "最大限额"
        r.text = ""
        r.rx.controlEvent(.editingDidEnd).subscribe(onNext: { [weak self] in
            if let doubleValue = Double(self?.limitMaxMoneyTF.text ?? "0.00") {
                if doubleValue < 0.01{
                    self?.limitMaxMoneyTF.text = ""
                }
            }else{
                self?.limitMaxMoneyTF.text = ""
            }
            self?.calculationExchangeRate()
        }).disposed(by: rx.disposeBag)
        r.rx.controlEvent(.editingChanged).subscribe(onNext: {  [weak self] in
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
        }).disposed(by: rx.disposeBag)
        return r
    }()
    lazy var limitMixMoneyLabel: UILabel = {
        let r = UILabel()
        r.textColor = .black666
        r.font = .regularFont(14)
        r.text = "≈0.00 C"
        return r
    }()
    lazy var limitMaxMoneyLabel: UILabel = {
        let r = UILabel()
        r.textColor = .black666
        r.font = .regularFont(14)
        r.text = "≈0.00 C"
        return r
    }()
    lazy var limitRegisterView: TGLinearLayout = {
        let r = TGLinearLayout(.vert)
        r.tg_top.equal(22)
        r.tg_left.equal(0)
        r.tg_right.equal(0)
        r.tg_height.equal(84)
        let label = UILabel()
        label.tg_left.equal(0)
        label.tg_top.equal(0)
        label.tg_height.equal(18)
        label.tg_width.equal(.wrap)
        label.textColor = .black333
        label.font = .mediumFont(16)
        label.text = "交易用户条件"
        r.addSubview(label)
        r.addSubview(limitRegisterTipLabel)
        r.addSubview(limitRegisterContentView)
        return r
    }()
    lazy var limitRegisterTipLabel: UILabel = {
        let r = UILabel()
        r.tg_left.equal(0)
        r.tg_top.equal(9)
        r.tg_height.equal(14)
        r.tg_width.equal(kScreenWidth-32)
        r.textColor = .black666
        r.font = .regularFont(12)
        r.text = "增加交易用户限制，会减少您的广告展示的机会"
        return r
    }()
    lazy var limitRegisterContentView: UIView = {
        let r = UIView()
        r.tg_left.equal(0)
        r.tg_top.equal(11)
        r.tg_height.equal(32)
        r.tg_width.equal(kScreenWidth-32)
        r.addSubview(limitRegisterBtn)
        limitRegisterBtn.snp_makeConstraints { make in
            make.left.centerY.equalTo(r)
            make.width.height.equalTo(20)
        }
        let label1 = UILabel()
        label1.textColor = .black333
        label1.font = .regularFont(14)
        label1.text = "完成注册"
        let label2 = UILabel()
        label2.textColor = .black333
        label2.font = .regularFont(14)
        label2.text = "天"
        r.addSubview(label1)
        r.addSubview(limitRegisterTF)
        r.addSubview(label2)
        label1.snp_makeConstraints { make in
            make.left.equalTo(limitRegisterBtn.snp_right).offset(8)
            make.centerY.equalTo(r)
        }
        limitRegisterTF.snp_makeConstraints { make in
            make.left.equalTo(label1.snp_right).offset(8)
            make.top.bottom.equalTo(r)
            make.width.equalTo(50)
        }
        label2.snp_makeConstraints { make in
            make.left.equalTo(limitRegisterTF.snp_right).offset(8)
            make.centerY.equalTo(r)
        }
        return r
    }()
    lazy var limitRegisterBtn: QMUIButton = {
        let r = QMUIButton()
//        r.setImage(UIImage(named: "check"), for: .normal)
//        r.setImage(UIImage(named: "checked"), for: .selected)
        r.setImage(R.image.checked()!, for: .selected)
        r.setImage(R.image.check()!, for: .normal)
        r.isSelected = false
        r.rx.tap.subscribe(onNext: { [self] in
            r.isSelected = !r.isSelected
        }).disposed(by: rx.disposeBag)
        return r
    }()
    lazy var limitRegisterTF: QMUITextField = {
        let r = QMUITextField()
        r.font = .regularFont(16)
        r.tintColor = .black333
        r.textAlignment = .center
        r.keyboardType = .asciiCapableNumberPad
        r.setPlaceHolderTextColor(.black999)
        r.border(.init(hexString: "#CCCCCC"),borderWidth: 1,cornerRadius: 8)
        r.rx.controlEvent(.editingDidEnd).subscribe(onNext: { [weak self] in
            if r.text?.isEmpty == false{
                if let count = Int(r.text ?? "0"){
                    
                }else{
                    r.text = ""
                }
            }
        }).disposed(by: rx.disposeBag)
        return r
    }()
    lazy var statusView: TGLinearLayout = {
        let r = TGLinearLayout(.horz)
        r.tg_top.equal(20)
        r.tg_left.equal(0)
        r.tg_right.equal(0)
        r.tg_height.equal(28)
        let label = UILabel()
        label.textColor = .black333
        label.font = .mediumFont(16)
        label.text = "状态"
        r.addSubview(label)
        label.snp_makeConstraints { make in
            make.centerY.left.equalTo(r)
            make.width.equalTo(60)
        }
        r.addSubview(nowCommitBtn)
        r.addSubview(laterCommitBtn)
        laterCommitBtn.snp_makeConstraints { make in
            make.width.equalTo(135)
            make.top.bottom.right.equalTo(r)
        }
        nowCommitBtn.snp_makeConstraints { make in
            make.width.equalTo(120)
            make.top.bottom.equalTo(r)
            make.right.equalTo(laterCommitBtn.snp_left)
        }
        return r
    }()
    lazy var nowCommitBtn: UIButton = {
        let r = UIButton()
        r.setImage(UIImage(named: "mine_buy_and_sell_check_icon"), for: .normal)
        r.setImage(UIImage(named: "mine_buy_and_sell_checked_icon"), for: .selected)
        r.isSelected = true
        r.setTitle("立即上架", for: .normal)
        r.titleLabel?.font = .regularFont(14)
        r.setTitleColor(.black666, for: .normal)
        r.contentHorizontalAlignment = .right
        // 间距可能需要根据图片和文字大小调整
        let spacing: CGFloat = 8.0
        r.titleEdgeInsets = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: 0)
        r.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: spacing)
        r.rx.tap.subscribe(onNext: { [weak self] in
            r.isSelected = true
            self?.laterCommitBtn.isSelected = false
        }).disposed(by: rx.disposeBag)
        return r
    }()
    lazy var laterCommitBtn: UIButton = {
        let r = UIButton()
        r.setImage(UIImage(named: "mine_buy_and_sell_check_icon"), for: .normal)
        r.setImage(UIImage(named: "mine_buy_and_sell_checked_icon"), for: .selected)
        r.isSelected = false
        r.setTitle("稍后手动上架", for: .normal)
        r.titleLabel?.font = .regularFont(14)
        r.setTitleColor(.black666, for: .normal)
        r.contentHorizontalAlignment = .right
        // 间距可能需要根据图片和文字大小调整
        let spacing: CGFloat = 8.0
        r.titleEdgeInsets = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: 0)
        r.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: spacing)
        r.rx.tap.subscribe(onNext: { [weak self] in
            r.isSelected = true
            self?.nowCommitBtn.isSelected = false
        }).disposed(by: rx.disposeBag)
        return r
    }()
    private lazy var sureBtn: QMUIButton = {
        let r = ViewFactoryUtil.linkButton("确定")
        r.tg_top.equal(26)
        r.tg_left.equal(0)
        r.tg_width.equal(kScreenWidth-32)
        r.tg_height.equal(56)
        r.setTitleColor(.white, for: .normal)
        r.corner(28)
        r.titleLabel?.font = .semiboldFont(16)
        r.backgroundColor = .primaryColor
        r.rx.tap.subscribe(onNext: { [weak self] in
            if self?.isChooseBank == false && self?.isChooseAli == false && self?.isChooseWx == false{
                SuperToast.show(title: "请选择支付方式")
                return
            }
            if let doubleValue = Double(self?.advertisementCountTF.text ?? "0") {
                if doubleValue == 0{
                    SuperToast.show(title: "请输入广告数")
                    return
                }
            }else{
                SuperToast.show(title: "请输入广告数")
                return
            }
            if let mixMoneyCount = Double(self?.limitMixMoneyTF.text ?? "0") {
                if mixMoneyCount == 0{
                    SuperToast.show(title: "请输入最小限额")
                    return
                }
            }else{
                SuperToast.show(title: "请输入最小限额")
                return
            }
            if let maxMoneyCount = Double(self?.limitMaxMoneyTF.text ?? "0") {
                if maxMoneyCount == 0{
                    SuperToast.show(title: "请输入最大限额")
                    return
                }else{
                    if let mixMoneyCount = Double(self?.limitMixMoneyTF.text ?? "0") {
                        if mixMoneyCount > maxMoneyCount{
                            SuperToast.show(title: "最小限额不能大于最大限额")
                            return
                        }
                    }
                }
            }else{
                SuperToast.show(title: "请输入最大限额")
                return
            }
            var limitRegisterDate = "0"
            if self?.limitRegisterBtn.isSelected == true && self?.limitRegisterTF.text?.isEmpty == false{
                limitRegisterDate = self?.limitRegisterTF.text ?? "0"
            }
            var payment = ""
            if self?.isChooseBank == true{
                payment = "1"
            }
            if self?.isChooseAli == true{
                payment = payment + (payment.isEmpty ? "2" : ",2")
            }
            if self?.isChooseWx == true{
                payment = payment + (payment.isEmpty ? "3" : ",3")
            }
            if self?.advertisementType == 1{
                //出售
                let passWordView = BoBPayPassWordView()
                passWordView.tg_width.equal(.fill)
                passWordView.tg_height.equal(210)
                passWordView.payBtnClickBlock = { [weak self] passWord in
                    var param : [String: Any]
                    let advertisingCurrency = self?.currency ?? "C"
                    let currencyWallet = self?.chooseCionTypeModel?.cionType ?? "0"
                    let advertisingType = String(format: "%d", self?.advertisementType ?? 1)
                    let transactionMode = payment
                    let exchangeRateType = String(format: "%d", self?.exchangeRateType ?? 2)
                    let setExchangeRate = self?.exchangeRateTF.text ?? ""
                    let floatingIndex = self?.exchangeRateTF.text ?? ""
                    let surplusQuantity = self?.advertisementCountTF.text ?? ""
                    let quotaMin = self?.limitMixMoneyTF.text ?? ""
                    let quotaMax = self?.limitMaxMoneyTF.text ?? ""
                    let advertisingName = self?.advertisingName ?? ""
                    let timestamp = String(Int(Date().timeIntervalSince1970 * 1000))
                    let state = self?.nowCommitBtn.isSelected == true ? "1" : "2"
                    let code = self?.code ?? "000"
                    var pwd = (IMController.shared.payPassWordSonKey + passWord).md5                    
                    let sign = (advertisingCurrency + currencyWallet + advertisingType + transactionMode + exchangeRateType + setExchangeRate + floatingIndex + surplusQuantity + quotaMin + quotaMax + limitRegisterDate + advertisingName + timestamp + state + code + pwd).md5
                    
                    param = ["advertisingCurrency":advertisingCurrency,"currencyWallet":currencyWallet,"advertisingType": advertisingType,"transactionMode":transactionMode,"exchangeRateType":exchangeRateType,"setExchangeRate":setExchangeRate,"floatingIndex":floatingIndex,"surplusQuantity":surplusQuantity,"quotaMin":quotaMin,"quotaMax":quotaMax,"termsOfTradeZc":limitRegisterDate,"advertisingName":advertisingName,"timestamp":timestamp,"state":state,"code":code,"sign":sign]
                    self?.CreatAdvertisement(type: 1, param: param)
                }

                GKCover.cover(from: self?.view.window, contentView: passWordView, style: .translucent, showStyle: .center, showAnimStyle: .bottom, hideAnimStyle: .bottom, notClick: false)
            }else{
                //购买
                var param : [String: Any]
                let advertisingCurrency = self?.currency ?? "C"
                let advertisingType = String(format: "%d", self?.advertisementType ?? 1)
                let transactionMode = payment
                let exchangeRateType = String(format: "%d", self?.exchangeRateType ?? 2)
                let setExchangeRate = self?.exchangeRateTF.text ?? ""
                let floatingIndex = self?.exchangeRateTF.text ?? ""
                let surplusQuantity = self?.advertisementCountTF.text ?? ""
                let quotaMin = self?.limitMixMoneyTF.text ?? ""
                let quotaMax = self?.limitMaxMoneyTF.text ?? ""
                let advertisingName = self?.advertisingName ?? ""
                let state = self?.nowCommitBtn.isSelected == true ? "1" : "2"
                let code = self?.code ?? "000"
                param = ["advertisingCurrency":advertisingCurrency,"advertisingType": advertisingType,"transactionMode":transactionMode,"exchangeRateType":exchangeRateType,"setExchangeRate":setExchangeRate,"floatingIndex":floatingIndex,"surplusQuantity":surplusQuantity,"quotaMin":quotaMin,"quotaMax":quotaMax,"termsOfTradeZc":limitRegisterDate,"advertisingName":advertisingName,"state":state,"code":code]
                self?.CreatAdvertisement(type: 2, param: param)
            }
           
        }).disposed(by: rx.disposeBag)
        return r
    }()
    func CreatAdvertisement(type:Int?,param:[String:Any]){
        BoBBuyAndSellCionModel.CreatAdvertisementRequest(type: type, param: param){[weak self] errCode, errMsg in
            if errCode == 20000{
                if self?.code ?? "000" == "000"{
                    SuperToast.show(title:"创建成功")
                }else{
                    SuperToast.show(title:"修改成功")
                    self?.adDetailData?.transactionMode = param["transactionMode"] as? String
                    self?.adDetailData?.exchangeRateType = self?.exchangeRateType ?? 2
                    self?.adDetailData?.floatingIndex = Double(self?.exchangeRateTF.text ?? "0.01")
                    if self?.exchangeRateType ?? 2 == 1{
                        //浮动
                        self?.adDetailData?.setExchangeRate =  (Double(self?.exchangeRateTF.text ?? "0.01") ?? 1.00)*(self?.homeData?.exchangeRate ?? 1.00)
                    }else{
                        //固定
                        self?.adDetailData?.setExchangeRate = Double(self?.exchangeRateTF.text ?? "0.01")
                    }
                    self?.adDetailData?.quotaMin = Double(self?.limitMixMoneyTF.text ?? "0.01")
                    self?.adDetailData?.quotaMax = Double(self?.limitMaxMoneyTF.text ?? "0.01")
                    self?.adDetailData?.termsOfTradeZc = Int((param["termsOfTradeZc"] as? String) ?? "0")
                    self?.adDetailData?.advertisingState = self?.nowCommitBtn.isSelected == true ? 1 : 2
                    if self?.updateAdData != nil{
                        self?.updateAdData((self?.adDetailData!)!)
                    }
                }
                self?.navigationController?.popViewController(animated: true)
            }else{
                SuperToast.show(title: errMsg)
            }
        }
    }
}
