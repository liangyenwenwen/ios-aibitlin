//
//  BoBBuyAndSellCionSubDetailViewController.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/12/19.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Foundation
import TangramKit
import JXSegmentedView
import OUICore

class BoBBuyAndSellCionSubDetailViewController: BaseTitleController {
    var detailData:BoBBuyAndSellFreeAreaList?
    var homeData:BoBBuyAndSellHomeData?
    var intendedOrderHome:IntendedOrderHome?
    var buyType:Int = 1 //按金额购买，2按数量购买
    var type:Int = 1 //1:购买 2:出售
    var currency:String = "C" //币种
    var chooseCionTypeModel:CionTypeModel?
    var cionTypeArray:[CionTypeModel] = []
    var choosePaymentMethod:stringAndDatePOS?//选中的支付方式
    var isSupportBank:Bool = false
    var isSupportAli:Bool = false
    var isSupportWeixin:Bool = false
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    override func initViews() {
        super.initViews()
        setBackGroundColor(.white)
        initScrollSafeArea()
        navView.hide()
        type = detailData?.advertisingType ?? 1
        currency = detailData?.advertisingCurrency ?? "C"
        let arr = detailData?.transactionMode!.components(separatedBy:",")
        if arr?.count == 1{
            if arr?[0] == "1"{
                isSupportBank = true
            }else if arr?[0] == "2"{
                isSupportAli = true
            }else{
                isSupportWeixin = true
            }
        }else if arr?.count == 2{
            if arr?[0] == "1"{
                isSupportBank = true
            }else if arr?[0] == "2"{
                isSupportAli = true
            }else{
                isSupportWeixin = true
            }
            if arr?[1] == "1"{
                isSupportBank = true
            }else if arr?[1] == "2"{
                isSupportAli = true
            }else{
                isSupportWeixin = true
            }
        }else{
            isSupportBank = true
            isSupportAli = true
            isSupportWeixin = true
        }
        chooseCionTypeModel = CionTypeModel(icon: "", currency: currency, quota: 0.00, handlingCharge: 0.00, minimumCommission: 0.00, cionType:"0", money:0.00, type: 0, isSelect: true,exchangeRate:1.00)
        scrollViewContainer.tg_padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        superFooterContainerContainer.tg_bottom.equal(0)
        if type == 2{
            scrollViewContainer.addSubview(walletView)
            loadWalletData()
        }
        scrollViewContainer.addSubview(countView)
        if type == 2{
            scrollViewContainer.addSubview(totalMoneyLabel)
        }
        scrollViewContainer.addSubview(buyCountView)
        scrollViewContainer.addSubview(buyMoneyView)
        scrollViewContainer.addSubview(addView)
        scrollViewContainer.addSubview(choosePaymentView)
        scrollViewContainer.addSubview(choosePaymentMethodView)
        scrollViewContainer.addSubview(buyBtn)
        scrollViewContainer.addSubview(supportPaymentView)
        scrollViewContainer.addSubview(paymentLimitTimeView)
        scrollViewContainer.addSubview(lineView1)
        scrollViewContainer.addSubview(transactionPartyTitlelabel)
        scrollViewContainer.addSubview(completedCountView)
        scrollViewContainer.addSubview(singularizationCountView)
        scrollViewContainer.addSubview(completionRateView)
        scrollViewContainer.addSubview(lineView2)
        scrollViewContainer.addSubview(accountCreatedView)
        scrollViewContainer.addSubview(firstTransactionView)
        scrollViewContainer.addSubview(counterpartyView)
        scrollViewContainer.addSubview(singularizationTotalView)
        scrollViewContainer.addSubview(buyAndSellTotalView)
        let tap = UITapGestureRecognizer()
        tap.rx.event.subscribe { [weak self] _ in
            self?.view.endEditing(true)
        }.disposed(by: rx.disposeBag)
        self.view.addGestureRecognizer(tap)
        if homeData?.payment == true{
            addView.hide()
            choosePaymentMethodView.show()
        }
        loadData()
    }
    func loadData(){
        BoBBuyAndSellCionModel.IntendedOrderHomePageRequest(code:detailData?.code ?? ""){[weak self] data in
            self?.intendedOrderHome = data
            self?.paymentLimitTimeLabel.text = String(format: "%d", data.timeOfPayment ?? 0) + "分钟"
            self?.completedCountView.buyCounLabel.text = String(format: "%d", data.completed ?? 0)
            self?.singularizationCountView.buyCounLabel.text = String(format: "%d", data.order30 ?? 0)
            self?.completionRateView.buyCounLabel.text = String(format: "%.2f",(data.transactionRates30 ?? 0.00)*100) + "%"
            self?.accountCreatedView.buyCounLabel.text = String(format: "%d", data.creationDays ?? 0) + "天"
            self?.firstTransactionView.buyCounLabel.text = String(format: "%d", data.firstTradingTime ?? 0) + "天"
            self?.counterpartyView.buyCounLabel.text = String(format: "%d", data.counterparty ?? 0)
            self?.singularizationTotalView.buyCounLabel.text = String(format: "%d", data.assemblyNumber ?? 0) + "次"
            self?.buyCountLabel.text = "买入" + String(format: "%d", data.buy ?? 0)
            self?.sellCountLabel.text = "卖出" + String(format: "%d", data.sell ?? 0)
        } completionHandler: {errCode,errMsg in
            SuperToast.show(title: errMsg)
        }
    }
    func loadWalletData(){
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
    func reloadVCData(data:BoBBuyAndSellHomeData){
        homeData = data
    }
    func choosePaymentMedthodType(){
        let chooseTypeView = BoBChoosePaymentMethodTypeView()
        chooseTypeView.tg_width.equal(.fill)
        chooseTypeView.tg_height.equal(447)
        chooseTypeView.currentVC = self
        chooseTypeView.bindData(paymentData: homeData?.userBankAndWeiXinAndZFBPO,choosePayment: choosePaymentMethod,isSupportBank: isSupportBank,isSupportAli: isSupportAli,isSupportWeixin: isSupportWeixin)
        chooseTypeView.choosePaymentMethodTypeBlock = {[weak self] choosePayment,newPaymentMethodData in
            self?.choosePaymentMethod = choosePayment
            self?.homeData?.userBankAndWeiXinAndZFBPO = newPaymentMethodData
            self?.addView.hide()
            self?.choosePaymentView.show()
            self?.choosePaymentMethodView.hide()
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
        GKCover.cover(from: self.view.window, contentView: chooseTypeView, style: .translucent, showStyle: .bottom, showAnimStyle: .bottom, hideAnimStyle: .bottom, notClick: false)

    }
    lazy var countView: UIView = {
        let r = UIView()
        if type == 1{
            r.tg_top.equal(16)
        }else{
            r.tg_top.equal(12)
        }
        r.tg_left.equal(16)
        r.tg_right.equal(16)
        r.tg_height.equal(48)
        r.backgroundColor = .init(hexString: "#F5F5F5")
        r.corner(8)
        r.addSubview(currencyLabel)
        r.addSubview(countTF)
        r.addSubview(allBtn)
        currencyLabel.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.centerY.equalTo(r)
        }
        countTF.snp_makeConstraints { make in
            make.left.equalTo(currencyLabel.snp_right).offset(10)
            make.top.bottom.equalTo(r)
            make.right.equalTo(allBtn.snp_left).offset(-10)
        }
        allBtn.snp_makeConstraints { make in
            make.right.equalTo(-16)
            make.top.bottom.equalTo(r)
            make.width.equalTo(50)
        }
        return r
    }()
    lazy var currencyLabel: UILabel = {
        let r = UILabel()
        r.textColor = .black333
        r.font = .mediumFont(16)
        r.text = buyType == 1 ? "¥" : currency
        return r
    }()
    lazy var countTF: QMUITextField = {
        let r = QMUITextField()
        r.font = .regularFont(16)
        r.tintColor = .black333
        r.keyboardType = .decimalPad
        r.setPlaceHolderTextColor(.black999)
        if buyType == 1{
            let quotaMin = (detailData?.quotaMin ?? 0.00)*(detailData?.setExchangeRate ?? 1.00)
            let quotaMax = (detailData?.quotaMax ?? 0.00)*(detailData?.setExchangeRate ?? 1.00)
            r.placeholder = "限额" + String(format: " ¥%.2f~¥%.2f ",quotaMin, quotaMax)
        }else{
            r.placeholder = "限额" + String(format: " %.2f~%.2f ", detailData?.quotaMin ?? 0.00,detailData?.quotaMax ?? 0.00) + (detailData?.advertisingCurrency ?? "C")
        }
        r.text = ""
        r.rx.controlEvent(.editingDidEnd).subscribe(onNext: { [weak self] in
            if let doubleValue = Double(self?.countTF.text ?? "0.00") {
                if doubleValue < 0.01{
                    self?.countTF.text = ""
                    self?.buyCountView.buyCounLabel.text = "0.00"
                    self?.buyMoneyView.buyCounLabel.text = "¥0.00"
                }else{
                    if self?.buyType == 1{
                        self?.buyCountView.buyCounLabel.text = String(format: "%.2f",doubleValue/(self?.detailData?.setExchangeRate ?? 1.00))
                        self?.buyMoneyView.buyCounLabel.text = self?.countTF.text ?? "¥0.00"
                    }else{
                        self?.buyCountView.buyCounLabel.text = self?.countTF.text ?? "0.00"
                        self?.buyMoneyView.buyCounLabel.text = String(format: "%.2f",doubleValue*(self?.detailData?.setExchangeRate ?? 1.00))
                    }
                }
            }else{
                self?.countTF.text = ""
                self?.buyCountView.buyCounLabel.text = "0.00"
                self?.buyMoneyView.buyCounLabel.text = "¥0.00"
            }
           
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
    lazy var allBtn: QMUIButton = {
        let r = ViewFactoryUtil.linkButton("全部".localized())
        r.setTitleColor(.primaryColor, for: .normal)
        r.titleLabel?.font = .regularFont(14)
        r.contentHorizontalAlignment = .right
        r.rx.tap.subscribe(onNext: { [weak self] in
            self?.view.endEditing(true)
            if self?.buyType == 1{
                self?.countTF.text = String(format: "%.2f",(self?.detailData?.quotaMax ?? 0.00)*(self?.detailData?.setExchangeRate ?? 1.00))
                self?.buyCountView.buyCounLabel.text = String(format: "%.2f",self?.detailData?.quotaMax ?? 0.00)
                self?.buyMoneyView.buyCounLabel.text = "¥" + (self?.countTF.text ?? "0.00")
            }else{
                self?.countTF.text = String(format: "%.2f",self?.detailData?.quotaMax ?? 0.00)
                self?.buyCountView.buyCounLabel.text = self?.countTF.text ?? ""
                self?.buyMoneyView.buyCounLabel.text = "¥" + String(format: "%.2f",(self?.detailData?.quotaMax ?? 0.00)*(self?.detailData?.setExchangeRate ?? 1.00))
            }
        }).disposed(by: rx.disposeBag)
        return r
    }()
    lazy var walletView: TGLinearLayout = {
        let r = TGLinearLayout(.horz)
        r.tg_top.equal(16)
        r.tg_left.equal(16)
        r.tg_height.equal(48)
        r.tg_width.equal(kScreenWidth-32)
        r.backgroundColor = .init(hexString: "#F5F5F5")
        r.corner(8)
        r.addSubview(cionTypeImageView)
        r.addSubview(cionNameLabel)
        r.addSubview(walletType)
        let rightIcon = UIImageView(image: UIImage(named: "SuperChevronRight"))
        rightIcon.tintColor = .black80
        rightIcon.contentMode = .scaleAspectFit
        r.addSubview(rightIcon)
        rightIcon.snp_makeConstraints { make in
            make.centerY.equalTo(r)
            make.right.equalTo(-16)
            make.width.height.equalTo(15)
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
        r.tg_top.equal(12)
        r.tg_left.equal(16)
        r.tg_right.equal(16)
        r.tg_height.equal(18)
        r.font = .regularFont(14)
        r.textColor = .black666
        r.textAlignment = .right
        let str = "可用余额：0.00" + currency
        let attributedString = NSMutableAttributedString(string: str)
        attributedString.addAttribute(.foregroundColor, value: UIColor.primaryColor, range: NSRange(location: 5, length: str.length-5))
        r.attributedText = attributedString
        return r
    }()
    lazy var buyCountView: buyAndSellTitleView = {
        let r = buyAndSellTitleView()
        r.tg_top.equal(10)
        r.tg_left.equal(16)
        r.tg_right.equal(16)
        r.tg_height.equal(16)
        r.buyCountTitleLabel.text = (type == 1 ? "购买数量" : "出售数量") + currency
        r.buyCounLabel.text = "0.00"
        return r
    }()
    lazy var buyMoneyView: buyAndSellTitleView = {
        let r = buyAndSellTitleView()
        r.tg_top.equal(10)
        r.tg_left.equal(16)
        r.tg_right.equal(16)
        r.tg_height.equal(16)
        r.buyCountTitleLabel.text = (type == 1 ? "购买金额" : "出售金额") + "(CNY)"
        r.buyCounLabel.text = "¥0.00"
        return r
    }()
    private lazy var addView: UIView = {
        let r = UIView()
        r.tg_top.equal(16)
        r.tg_left.equal(16)
        r.tg_right.equal(16)
        r.tg_height.equal(72)
        r.backgroundColor = .init(hexString: "#EAF5FF")
        r.border(.init(hexString: "#BEDFFF"),borderWidth: 1,cornerRadius: 8)
        let label1 = UILabel()
        label1.text = "添加支付方式"
        label1.textColor = .white
        label1.font = .regularFont(14)
        label1.backgroundColor = .init(hexString: "#388CEF")
        label1.textAlignment = .center
        label1.corner(16)
        r.addSubview(label1)
        let label2 = UILabel()
        label2.text = "请点击按钮添加支付方式"
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
            self?.view.endEditing(true)
            if IMController.shared.certificationLevel == 0{
                let alert = UIAlertController(title: "提示", message: "请先进行实名认证".innerLocalized(), preferredStyle: .alert)
                // 创建UIAlertAction，用于处理用户的选择
                let cancleAction = UIAlertAction(title: "取消".innerLocalized(), style: .default) { _ in
                }
                let okAction = UIAlertAction(title: "去认证".innerLocalized(), style: .default) { _ in
                    let vc =  BoBRealNameMainViewController()
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
                // 将action添加到alertController上
                alert.addAction(cancleAction)
                alert.addAction(okAction)
                // 弹出alert
                self?.present(alert, animated: true, completion: nil)
            }else{
                let vc = BoBAddPaymentMethodViewController()
                vc.name = self?.homeData?.userBankAndWeiXinAndZFBPO?.name
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        }.disposed(by: rx.disposeBag)
        r.addGestureRecognizer(tap)
        return r
    }()
    private lazy var choosePaymentView: UIView = {
        let r = UIView()
        r.tg_top.equal(16)
        r.tg_left.equal(16)
        r.tg_right.equal(16)
        r.tg_height.equal(72)
        r.backgroundColor = .init(hexString: "#EAF5FF")
        r.border(.init(hexString: "#BEDFFF"),borderWidth: 1,cornerRadius: 8)
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
            self?.view.endEditing(true)
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
        r.tg_top.equal(16)
        r.tg_left.equal(16)
        r.tg_right.equal(16)
        r.tg_height.equal(44)
        r.backgroundColor = .init(hexString: "#EAF5FF")
        r.border(.init(hexString: "#BEDFFF"),borderWidth: 1,cornerRadius: 8)
        r.hide()
        let v = UIImageView(image: UIImage(named: "SuperChevronRight")!.changeImageColor(color: .init(hexString: "#7AB4F8")))
        v.contentMode = .scaleAspectFit
        r.addSubview(v)
        let label = UILabel()
        label.textColor = .black666
        label.font = .regularFont(16)
        label.text = "选择支付方式"
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
            self?.view.endEditing(true)
            self?.choosePaymentMedthodType()
        }.disposed(by: rx.disposeBag)
        r.addGestureRecognizer(tap)
        return r
    }()
    
    private lazy var buyBtn: QMUIButton = {
        let r = ViewFactoryUtil.linkButton((type == 1 ? "购买" : "出售") + currency)
        r.tg_top.equal(16)
        r.tg_left.equal(16)
        r.tg_right.equal(16)
        r.tg_height.equal(48)
        r.setTitleColor(.white, for: .normal)
        r.corner(25)
        r.titleLabel?.font = .semiboldFont(16)
        r.backgroundColor = .primaryColor
        r.rx.tap.subscribe(onNext: { [weak self] in
            self?.view.endEditing(true)
            if let doubleValue = Double(self?.countTF.text ?? "0") {
                if doubleValue == 0{
                    SuperToast.show(title: "请输入" + (self?.type == 1 ? "购买":"出售") + (self?.buyType == 1 ? "金额":"数量"))
                    return
                }
            }else{
                SuperToast.show(title: "请输入" + (self?.type == 1 ? "购买":"出售") + (self?.buyType == 1 ? "金额":"数量"))
                return
            }
            if self?.choosePaymentMethod == nil{
                SuperToast.show(title: "请选择支付方式")
                return
            }
            
            if IMController.shared.certificationLevel == 0 {
                let alert = UIAlertController(title: "提示", message: "请先进行实名认证".innerLocalized(), preferredStyle: .alert)
                // 创建UIAlertAction，用于处理用户的选择
                let cancleAction = UIAlertAction(title: "取消", style: .default) { _ in
                }
                let okAction = UIAlertAction(title: "去认证", style: .default) { _ in
                    let vc =  BoBRealNameMainViewController()
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
                // 将action添加到alertController上
                alert.addAction(cancleAction)
                alert.addAction(okAction)
                // 弹出alert
                self?.present(alert, animated: true, completion: nil)
            }else{
                if IMController.shared.isSetPayPassWord {
//                    let confirmPurchaseView = BoBConfirmPurchaseAlertView()
//                    confirmPurchaseView.tg_width.equal(kScreenWidth)
//        //            confirmPurchaseView.tg_height.equal(.wrap)
//                    confirmPurchaseView.tg_height.equal(500)
//                    confirmPurchaseView.currentVC = self
//                    let buyType = self?.buyType ?? 1
//                    let type = self?.type ?? 1
//                    let money = (self?.buyMoneyView.buyCounLabel.text ?? "").replacingOccurrences(of: "¥", with: "")
//                    let walletType = self?.chooseCionTypeModel ?? CionTypeModel()
//                    let paymentType = self?.choosePaymentMethod ?? stringAndDatePOS(id: 0, dateValue: "", type: "")
//                    let unitPrice = String(format: "%.2f", self?.detailData?.setExchangeRate ?? 1.00)
//                    let count = self?.buyCountView.buyCounLabel.text ?? "0.00"
//                    let code = self?.detailData?.code ?? ""
//                    confirmPurchaseView.bindData(buyType: buyType, type: type, walletType: walletType, paymentType: paymentType, unitPrice: unitPrice, money: money, count: count, code: code)
//                    confirmPurchaseView.commitSuccessBlock = {[weak self] in
//                        self?.navigationController?.popViewController(animated: true)
//                    }
//                    GKCover.cover(from: self?.view.window, contentView: confirmPurchaseView, style: .translucent, showStyle: .bottom, showAnimStyle: .bottom, hideAnimStyle: .bottom, notClick: false)
                    let maskView = BoBConfirmPurchaseAlertView()
                    maskView.currentVC = self
                    let buyType = self?.buyType ?? 1
                    let type = self?.type ?? 1
                    let money = (self?.buyMoneyView.buyCounLabel.text ?? "").replacingOccurrences(of: "¥", with: "")
                    let walletType = self?.chooseCionTypeModel ?? CionTypeModel()
                    let paymentType = self?.choosePaymentMethod ?? stringAndDatePOS(id: 0, dateValue: "", type: "")
                    let unitPrice = String(format: "%.2f", self?.detailData?.setExchangeRate ?? 1.00)
                    let count = self?.buyCountView.buyCounLabel.text ?? "0.00"
                    let code = self?.detailData?.code ?? ""
                    maskView.bindData(buyType: buyType, type: type, walletType: walletType, paymentType: paymentType, unitPrice: unitPrice, money: money, count: count, code: code)
                    maskView.commitSuccessBlock = {[weak self] in
                        self?.navigationController?.popViewController(animated: true)
                    }
                    maskView.showMask(view:self!.view.window!)
                }else{
                    let alert = UIAlertController(title: "提示", message: "为了您的财产安全，请设置安全密码".innerLocalized(), preferredStyle: .alert)
                    // 创建UIAlertAction，用于处理用户的选择
                    let cancleAction = UIAlertAction(title: "取消", style: .default) { _ in
                    }
                    let okAction = UIAlertAction(title: "去设置", style: .default) { _ in
                        let vc = BoBChangePayPassWordViewController()
                        vc.passWordType = 0
                        self?.navigationController?.pushViewController(vc,animated: true)
                    }
                    // 将action添加到alertController上
                    alert.addAction(cancleAction)
                    alert.addAction(okAction)
                    // 弹出alert
                    self?.present(alert, animated: true, completion: nil)
                }
                
            }
        }).disposed(by: rx.disposeBag)
        return r
    }()
    lazy var supportPaymentView: TGLinearLayout = {
        let r = TGLinearLayout(.horz)
        r.tg_top.equal(18)
        r.tg_left.equal(16)
        r.tg_right.equal(16)
        r.tg_height.equal(16)
        let label = UILabel()
        label.tg_left.equal(0)
        label.tg_height.equal(16)
        label.tg_width.equal(.wrap)
        label.textColor = .black666
        label.font = .regularFont(14)
        label.text = "支付方式"
        r.addSubview(label)
        if isSupportBank{
            r.addSubview(bankView)
        }
        if isSupportAli{
            r.addSubview(aliView)
        }
        if isSupportWeixin{
            r.addSubview(weixinView)
        }
        return r
    }()
    lazy var bankView: TGLinearLayout = {
        let r = TGLinearLayout(.horz)
        r.tg_left.equal(10)
        r.tg_height.equal(16)
        r.tg_width.equal(.wrap)
        let lineView = UIView()
        lineView.tg_left.equal(0)
        lineView.tg_height.equal(10)
        lineView.tg_width.equal(4)
        lineView.tg_centerY.equal(0)
        lineView.corner(2)
        lineView.backgroundColor = .init(hexString: "#EF5151")
        r.addSubview(lineView)
        let label = UILabel()
        label.tg_left.equal(4)
        label.tg_height.equal(16)
        label.tg_width.equal(.wrap)
        label.textColor = .black333
        label.font = .regularFont(14)
        label.text = "银行卡"
        r.addSubview(label)
        return r
    }()
    lazy var aliView: TGLinearLayout = {
        let r = TGLinearLayout(.horz)
        r.tg_left.equal(10)
        r.tg_height.equal(16)
        r.tg_width.equal(.wrap)
        let lineView = UIView()
        lineView.tg_left.equal(0)
        lineView.tg_height.equal(10)
        lineView.tg_width.equal(4)
        lineView.tg_centerY.equal(0)
        lineView.corner(2)
        lineView.backgroundColor = .init(hexString: "#277FE6")
        r.addSubview(lineView)
        let label = UILabel()
        label.tg_left.equal(4)
        label.tg_height.equal(16)
        label.tg_width.equal(.wrap)
        label.textColor = .black333
        label.font = .regularFont(14)
        label.text = "支付宝"
        r.addSubview(label)
        return r
    }()
    lazy var weixinView: TGLinearLayout = {
        let r = TGLinearLayout(.horz)
        r.tg_left.equal(10)
        r.tg_height.equal(16)
        r.tg_width.equal(.wrap)
        let lineView = UIView()
        lineView.tg_left.equal(0)
        lineView.tg_height.equal(10)
        lineView.tg_width.equal(4)
        lineView.tg_centerY.equal(0)
        lineView.corner(2)
        lineView.backgroundColor = .init(hexString: "#15AB43")
        r.addSubview(lineView)
        let label = UILabel()
        label.tg_left.equal(4)
        label.tg_height.equal(16)
        label.tg_width.equal(.wrap)
        label.textColor = .black333
        label.font = .regularFont(14)
        label.text = "微信"
        r.addSubview(label)
        return r
    }()
    lazy var paymentLimitTimeView: UIView = {
        let r = UIView()
        r.tg_top.equal(10)
        r.tg_left.equal(16)
        r.tg_right.equal(16)
        r.tg_height.equal(16)
        let label = UILabel()
        label.textColor = .black666
        label.font = .regularFont(14)
        label.text = "付款时限"
        r.addSubview(label)
        r.addSubview(paymentLimitTimeLabel)
        label.snp_makeConstraints { make in
            make.left.centerY.equalTo(r)
        }
        paymentLimitTimeLabel.snp_makeConstraints { make in
            make.left.equalTo(label.snp_right).offset(5)
            make.centerY.equalTo(r)
        }
        return r
    }()
    lazy var paymentLimitTimeLabel: UILabel = {
        let r = UILabel()
        r.textColor = .black333
        r.font = .regularFont(14)
        r.text = "15分钟"
        return r
    }()
    lazy var lineView1: UIView = {
        let r = UIView()
        r.tg_top.equal(18)
        r.tg_left.equal(16)
        r.tg_right.equal(16)
        r.tg_height.equal(1)
        r.backgroundColor = .init(hexString: "#F5F5F5")
        return r
    }()
    lazy var transactionPartyTitlelabel: UILabel = {
        let r = UILabel()
        r.tg_top.equal(14)
        r.tg_left.equal(16)
        r.tg_right.equal(16)
        r.tg_height.equal(25)
        r.textColor = .black333
        r.font = .regularFont(14)
        r.text = "交易方信息"
        return r
    }()
    lazy var completedCountView: buyAndSellTitleView = {
        let r = buyAndSellTitleView()
        r.tg_top.equal(12)
        r.tg_left.equal(16)
        r.tg_right.equal(16)
        r.tg_height.equal(16)
        r.buyCountTitleLabel.text = "已完成次数"
        r.buyCounLabel.text = "0"
        r.buyCounLabel.font = .regularFont(14)
        return r
    }()
    lazy var singularizationCountView: buyAndSellTitleView = {
        let r = buyAndSellTitleView()
        r.tg_top.equal(10)
        r.tg_left.equal(16)
        r.tg_right.equal(16)
        r.tg_height.equal(16)
        r.buyCountTitleLabel.text = "30日成单数"
        r.buyCounLabel.text = "0"
        r.buyCounLabel.font = .regularFont(14)
        return r
    }()
    lazy var completionRateView: buyAndSellTitleView = {
        let r = buyAndSellTitleView()
        r.tg_top.equal(10)
        r.tg_left.equal(16)
        r.tg_right.equal(16)
        r.tg_height.equal(16)
        r.buyCountTitleLabel.text = "30日成单率"
        r.buyCounLabel.text = "0%"
        r.buyCounLabel.font = .regularFont(14)
        return r
    }()
    lazy var lineView2: UIView = {
        let r = UIView()
        r.tg_top.equal(12)
        r.tg_left.equal(16)
        r.tg_right.equal(16)
        r.tg_height.equal(1)
        r.backgroundColor = .init(hexString: "#F5F5F5")
        return r
    }()
    lazy var accountCreatedView: buyAndSellTitleView = {
        let r = buyAndSellTitleView()
        r.tg_top.equal(15)
        r.tg_left.equal(16)
        r.tg_right.equal(16)
        r.tg_height.equal(16)
        r.buyCountTitleLabel.text = "账户已创建"
        r.buyCounLabel.text = "0" + "天"
        r.buyCounLabel.font = .regularFont(14)
        return r
    }()
    lazy var firstTransactionView: buyAndSellTitleView = {
        let r = buyAndSellTitleView()
        r.tg_top.equal(15)
        r.tg_left.equal(16)
        r.tg_right.equal(16)
        r.tg_height.equal(16)
        r.buyCountTitleLabel.text = "首次交易至今"
        r.buyCounLabel.text = "0" + "天"
        r.buyCounLabel.font = .regularFont(14)
        return r
    }()
    lazy var counterpartyView: buyAndSellTitleView = {
        let r = buyAndSellTitleView()
        r.tg_top.equal(15)
        r.tg_left.equal(16)
        r.tg_right.equal(16)
        r.tg_height.equal(16)
        r.buyCountTitleLabel.text = "交易对手"
        r.buyCounLabel.text = "0"
        r.buyCounLabel.font = .regularFont(14)
        return r
    }()
    lazy var singularizationTotalView: buyAndSellTitleView = {
        let r = buyAndSellTitleView()
        r.tg_top.equal(15)
        r.tg_left.equal(16)
        r.tg_right.equal(16)
        r.tg_height.equal(16)
        r.buyCountTitleLabel.text = "总成单数"
        r.buyCounLabel.text = "0" + "次"
        r.buyCounLabel.font = .regularFont(14)
        return r
    }()
    lazy var buyAndSellTotalView: UIView = {
        let r = UIView()
        r.tg_top.equal(10)
        r.tg_left.equal(16)
        r.tg_right.equal(16)
        r.tg_height.equal(16)
        let label = UILabel()
        label.textColor = .black999
        label.font = .mediumFont(14)
        label.text = "|"
        label.textAlignment = .center
        r.addSubview(sellCountLabel)
        r.addSubview(label)
        r.addSubview(buyCountLabel)
        sellCountLabel.snp_makeConstraints { make in
            make.right.centerY.equalTo(r)
        }
        label.snp_makeConstraints { make in
            make.right.equalTo(sellCountLabel.snp_left)
            make.centerY.equalTo(r)
            make.width.equalTo(28)
        }
        buyCountLabel.snp_makeConstraints { make in
            make.right.equalTo(label.snp_left)
            make.centerY.equalTo(r)
        }
        return r
    }()
    lazy var buyCountLabel: UILabel = {
        let r = UILabel()
        r.textColor = .black333
        r.font = .mediumFont(14)
        r.textAlignment = .right
        r.text = "买入" + " 0"
        return r
    }()
    lazy var sellCountLabel: UILabel = {
        let r = UILabel()
        r.textColor = .black333
        r.font = .mediumFont(14)
        r.textAlignment = .right
        r.text = "卖出" + " 0"
        return r
    }()
    
}
class buyAndSellTitleView: TGLinearLayout {
    
    
    init() {
        super.init(frame: .zero, orientation: .horz)
        innerInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        innerInit()
    }
    
    func innerInit() {
        tg_width.equal(.fill)
        tg_height.equal(.wrap)
        tg_space = PADDING_MEDDLE
        tg_gravity = .horz.between
        addSubview(buyCountTitleLabel)
        addSubview(buyCounLabel)
    }
    lazy var buyCountTitleLabel: UILabel = {
        let r = UILabel()
        r.tg_width.equal(.wrap)
        r.tg_height.equal(.fill)
        r.textColor = .black666
        r.font = .regularFont(14)
        return r
    }()
    lazy var buyCounLabel: UILabel = {
        let r = UILabel()
        r.tg_width.equal(.wrap)
        r.tg_height.equal(.fill)
        r.textColor = .black333
        r.font = .mediumFont(14)
        return r
    }()
}
extension BoBBuyAndSellCionSubDetailViewController: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return view
    }
}
