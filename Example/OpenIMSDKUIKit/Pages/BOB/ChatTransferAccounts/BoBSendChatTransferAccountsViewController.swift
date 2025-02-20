//
//  BoBSendChatTransferAccountsViewController.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/12/3.
//  Copyright © 2024 rentsoft. All rights reserved.
//
import Foundation
import OUICore
import RxSwift
import RxCocoa
import RxGesture
import OUIIM
import ProgressHUD
import IQKeyboardManagerSwift
import TangramKit

class BoBSendChatTransferAccountsViewController: BaseTitleController {
    var cionType = "C"
    var receiveUserId = ""
    var groupId = ""
    var sendTransferAccountsAction:((_ transferAccountsJson:String)->())!
    var chooseCionTypeModel:CionTypeModel?
    var cionTypeArray:[CionTypeModel] = []
    var transferAccountsType:Int = 0 //0是私聊转账，1是群转账
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
        initLinearLayoutSafeArea()
        title = "转账"
        chooseCionTypeModel = CionTypeModel(icon: "", currency: cionType, quota: 0.00, handlingCharge: 0.00, minimumCommission: 0.00, cionType: "0", money:0.00, type: 0, isSelect: true,exchangeRate:1.00)
        container.tg_padding = UIEdgeInsets(top: PADDING_OUTER, left: PADDING_OUTER, bottom: PADDING_OUTER, right: PADDING_OUTER)
        transferAccountsType = groupId.isEmpty ? 0 : 1
        container.addSubview(transferCountView)
        if transferAccountsType == 1  {
            container.addSubview(choosePeopleView)
        }
        container.addSubview(descView)
        container.addSubview(bottomView)
        container.addSubview(sureBtn)
        transferCountView.snp_makeConstraints { make in
            make.top.equalTo(8)
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.height.equalTo(118)
        }
        if transferAccountsType == 1  {
            choosePeopleView.snp_makeConstraints { make in
                make.left.right.equalTo(transferCountView)
                make.top.equalTo(transferCountView.snp_bottom).offset(12)
                make.height.equalTo(88)
            }
            descView.snp_makeConstraints { make in
                make.left.right.height.equalTo(choosePeopleView)
                make.top.equalTo(choosePeopleView.snp_bottom).offset(12)
            }
        }else{
            descView.snp_makeConstraints { make in
                make.left.right.equalTo(transferCountView)
                make.top.equalTo(transferCountView.snp_bottom).offset(12)
                make.height.equalTo(88)
            }
        }
        
        bottomView.snp_makeConstraints { make in
            make.left.right.equalTo(descView)
            make.top.equalTo(descView.snp_bottom).offset(30)
            make.height.equalTo(102)
        }
        sureBtn.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.height.equalTo(56)
            make.top.equalTo(bottomView.snp_bottom).offset(25)
        }
        bindBtnData()
        loadData()
    }
    private func bindBtnData() {
        Observable.combineLatest(countTF.rx.text.orEmpty, nameTF.rx.text.orEmpty) {
            if self.transferAccountsType == 0{
                $0.count > 0 && $1.count >= 0
            }else{
                $0.count > 0 && $1.count > 0
            }
            
        }
        .bind(to: sureBtn.rx.isEnabled)
        .disposed(by:rx.disposeBag)
    }
    func loadData(){
        BoBRedPacketModel.TransferMoneyInnerSHomeRequest(){data in
            IMController.shared.isSetPayPassWord = data.secure ?? false
            IMController.shared.certificationLevel = data.certificationLevel ?? 0
            for item in data.expenditureHomePagePOS{
                let model1 = CionTypeModel(icon: item.icon, currency: item.currency, quota: item.quota, handlingCharge: 0.00, minimumCommission: 0.00, cionType: "0", money: item.t0, type: 0, isSelect: true,exchangeRate:item.exchangeRate)
                let model2 = CionTypeModel(icon: item.icon, currency: item.currency, quota: item.quota, handlingCharge: 0.00, minimumCommission: 0.00, cionType: "1", money: item.t1, type: 1, isSelect: false,exchangeRate:item.exchangeRate)
                self.cionTypeArray.append(model1)
                self.cionTypeArray.append(model2)
            }
            if self.cionTypeArray.count > 0{
                self.chooseCionTypeModel = self.cionTypeArray[0]
                self.refreshUI()
            }
        } completionHandler: {errCode,errMsg in
            if errCode == -1{
                SuperToast.show(title: errMsg)
            }else{
                SuperToast.show(title: String(errCode) + "：" + String(errCode).localized())
            }
        }
    }
    func refreshUI(){
        cionNameLabel.text = chooseCionTypeModel?.currency
        if chooseCionTypeModel?.type == 0{
            self.walletType.text = "T+0钱包"
            self.walletType.textColor = .init(hexString: "#00AA3C")
            self.walletType.backgroundColor = .init(hexString: "#E5F6EB")
        }else{
            self.walletType.text = "T+1钱包"
            self.walletType.textColor = .init(hexString: "#FFA756")
            self.walletType.backgroundColor = .init(hexString: "#FFF7E5")
        }
        self.exchangeRateLabel.text = "汇率: " + String(format: "%.2f",(chooseCionTypeModel?.exchangeRate)!)
        
        let str = "可用余额 " + String(format: "%.2f ",(chooseCionTypeModel?.money)!) + (chooseCionTypeModel?.currency)!
        let attributedString = NSMutableAttributedString(string: str)
        attributedString.addAttribute(.foregroundColor, value: UIColor.primaryColor, range: NSRange(location: 5, length: str.length-6))
        self.totalMoneyLabel.attributedText = attributedString
        self.cionImageView.sd_setImage(with: URL(string: chooseCionTypeModel?.icon))
        self.cionLabel.text = chooseCionTypeModel?.currency
        self.calculationMoney()
    }
    func calculationMoney(){
        self.totalLabel.text = "0.00"
        self.moneyLabel.text = "≈￥0.00"
        if let doubleValue = Double(countTF.text ?? "0") {
            if doubleValue > 0{
                self.totalLabel.text = countTF.text
                self.moneyLabel.text = String(format: "≈￥%.2f",(chooseCionTypeModel?.exchangeRate)!*doubleValue)
            }
        }
    }
    lazy var transferCountView: UIView = {
        let r = UIView()
        let v = UILabel()
        v.textColor = .black333
        v.font = .semiboldFont(16)
        v.text = "转账数量"
        r.addSubview(v)
        v.snp_makeConstraints { make in
            make.left.top.right.equalTo(0)
            make.height.equalTo(38)
        }
        r.addSubview(countView)
        r.addSubview(cionTypeView)
        r.addSubview(exchangeRateLabel)
        r.addSubview(totalMoneyLabel)
        countView.snp_makeConstraints { make in
            make.left.equalTo(0)
            make.top.equalTo(v.snp_bottom)
            make.height.equalTo(50)
            make.right.equalTo(cionTypeView.snp_left).offset(-10)
        }
        cionTypeView.snp_makeConstraints { make in
            make.right.equalTo(0)
            make.top.height.equalTo(countView)
            make.width.equalTo(128)
        }
        exchangeRateLabel.snp_makeConstraints { make in
            make.left.bottom.equalTo(0)
            make.width.equalTo(100)
            make.height.equalTo(18)
        }
        totalMoneyLabel.snp_makeConstraints { make in
            make.right.bottom.equalTo(0)
            make.left.equalTo(exchangeRateLabel.snp_right).offset(5)
            make.height.equalTo(18)
        }
        return r
    }()
    lazy var cionTypeView: UIView = {
        let r = UIView()
        r.backgroundColor = .white
        r.corner(8)
        r.addSubview(cionNameLabel)
        r.addSubview(walletType)
        let rightIcon = UIImageView(image: UIImage(named: "SuperChevronRight"))
        rightIcon.tintColor = .black80
        rightIcon.contentMode = .scaleAspectFit
        r.addSubview(rightIcon)
        cionNameLabel.snp_makeConstraints { make in
            make.left.equalTo(10)
            make.centerY.equalTo(r)
        }
        walletType.snp_makeConstraints { make in
            make.left.equalTo(cionNameLabel.snp_right).offset(7)
            make.centerY.equalTo(cionNameLabel)
            make.width.equalTo(62)
            make.height.equalTo(26)
        }
        rightIcon.snp_makeConstraints { make in
            make.right.equalTo(-16)
            make.centerY.equalTo(r)
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
        }
        r.addGestureRecognizer(tap)
       return r
    }()
    lazy var cionNameLabel: UILabel = {
        let r = UILabel()
        r.font = .mediumFont(16)
        r.text = cionType
        r.textColor = .black333
        return r
    }()
    lazy var walletType: UILabel = {
        let r = UILabel()
        r.textColor = .init(hexString: "#00AA3C")
        r.backgroundColor = .init(hexString: "#E5F6EB")
        r.corner(13)
        r.font = .regularFont(12)
        r.text = "T+0钱包"
        r.textAlignment = .center
        return r
    }()
    lazy var exchangeRateLabel: UILabel = {
        let r = UILabel()
        r.font = .regularFont(14)
        r.textColor = .black666
        r.text = "汇率: 0.00"

        return r
    }()
    lazy var totalMoneyLabel: UILabel = {
        let r = UILabel()
        r.font = .regularFont(14)
        r.textColor = .black666
        r.textAlignment = .right
        let str = "可用余额 0.00 " + cionType
        let attributedString = NSMutableAttributedString(string: str)
        attributedString.addAttribute(.foregroundColor, value: UIColor.primaryColor, range: NSRange(location: 5, length: str.length-6))
        r.attributedText = attributedString
        return r
    }()
    
    lazy var countView: UIView = {
        let r = UIView()
        r.backgroundColor = .white
        r.corner(8)
        r.addSubview(countTF)
        countTF.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.centerY.equalTo(r)
            make.right.equalTo(-16)
        }
        return r
    }()
    lazy var countTF: QMUITextField = {
        let r = QMUITextField()
        r.font = .regularFont(16)
        r.tintColor = .black333
        r.keyboardType = .decimalPad
        r.setPlaceHolderTextColor(.black999)
        r.placeholder = "输入数量"
        r.rx.controlEvent(.editingChanged).subscribe(onNext: { [unowned self] in
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
            self.calculationMoney()
        }).disposed(by: rx.disposeBag)
        return r
    }()
    lazy var choosePeopleView: UIView = {
        let r = UIView()
        let v = UILabel()
        v.textColor = .black333
        v.font = .semiboldFont(16)
        v.text = "转账给谁"
        r.addSubview(v)
        v.snp_makeConstraints { make in
            make.left.top.right.equalTo(0)
            make.height.equalTo(38)
        }
        
        let bgView = UIView()
        bgView.backgroundColor = .white
        bgView.corner(8)
        r.addSubview(bgView)
        bgView.snp_makeConstraints { make in
            make.left.right.equalTo(r)
            make.bottom.equalTo(0)
            make.height.equalTo(50)
        }
        bgView.addSubview(nameTF)
        let rightIcon = UIImageView(image: UIImage(named: "SuperChevronRight"))
        rightIcon.tintColor = .black80
        rightIcon.contentMode = .scaleAspectFit
        bgView.addSubview(rightIcon)
        rightIcon.snp_makeConstraints { make in
            make.right.equalTo(-16)
            make.centerY.equalTo(bgView)
            make.width.height.equalTo(15)
        }
        nameTF.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.centerY.equalTo(bgView)
            make.right.equalTo(rightIcon.snp_left).offset(-16)
        }
        let tap = UITapGestureRecognizer()
        tap.rx.event.subscribe {  _ in
            
            
            
            let vc = MentionViewController(types: [.members], sourceID: self.groupId, allowsMultipleSelection: false)
            vc.selectedContact(hasSelected: []) { [self] _, infos in
                if let firstObj = infos.first{
                    self.receiveUserId = firstObj.ID ?? ""
                    self.nameTF.text = firstObj.name
                }
                dismiss(animated: true)
            }
            let nav = UINavigationController(rootViewController: vc)
            self.present(nav, animated: true)
        }.disposed(by: rx.disposeBag)
        bgView.addGestureRecognizer(tap)
        return r
    }()
    lazy var nameTF: QMUITextField = {
        let r = QMUITextField()
        r.font = .regularFont(16)
        r.tintColor = .black333
        r.setPlaceHolderTextColor(.black999)
        r.placeholder = "选择转账对象"
        r.isUserInteractionEnabled = false
        return r
    }()
    lazy var descView: UIView = {
        let r = UIView()
        let v = UILabel()
        v.textColor = .black333
        v.font = .semiboldFont(16)
        v.text = "转账说明"
        r.addSubview(v)
        v.snp_makeConstraints { make in
            make.left.top.right.equalTo(0)
            make.height.equalTo(38)
        }
        
        let bgView = UIView()
        bgView.backgroundColor = .white
        bgView.corner(8)
        r.addSubview(bgView)
        bgView.snp_makeConstraints { make in
            make.left.right.equalTo(r)
            make.bottom.equalTo(0)
            make.height.equalTo(50)
        }
        bgView.addSubview(descTF)
        descTF.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.centerY.equalTo(bgView)
            make.right.equalTo(-16)
        }
        return r
    }()
    lazy var descTF: QMUITextField = {
        let r = QMUITextField()
        r.font = .regularFont(16)
        r.tintColor = .black333
        r.isUserInteractionEnabled = true
        r.keyboardType = .default
        r.returnKeyType = .default
        r.setPlaceHolderTextColor(.black999)
        r.maximumTextLength = 20
        r.placeholder = "请输入转账说明"
        return r
    }()
    lazy var bottomView:UIView = {
        let r = UIView()
        r.addSubview(bottomView1)
        r.addSubview(totalLabel)
        r.addSubview(moneyLabel)
        totalLabel.snp_makeConstraints { make in
            make.left.right.equalTo(0)
            make.top.equalTo(bottomView1.snp_bottom).offset(9)
            make.height.equalTo(46)
        }
        moneyLabel.snp_makeConstraints { make in
            make.left.right.equalTo(0)
            make.top.equalTo(totalLabel.snp_bottom).offset(5)
            make.height.equalTo(16)
        }
        return r
    }()
    lazy var bottomView1: TGLinearLayout = {
        let r = TGLinearLayout(.horz)
        r.tg_width.equal(.wrap)
        r.tg_height.equal(26)
        r.tg_centerX.equal(0)
        r.tg_space = 9
        r.tg_gravity = .vert.center
        r.tg_top.equal(0)
        r.addSubview(cionImageView)
        r.addSubview(cionLabel)
        return r
    }()
    lazy var cionImageView: UIImageView = {
        let r = UIImageView(image: UIImage(named: "mine_home_cion_c_icon"))
        r.tg_width.equal(26)
        r.tg_height.equal(26)
        return r
    }()
    lazy var cionLabel: UILabel = {
        let r = UILabel()
        r.tg_width.equal(.wrap)
        r.tg_height.equal(.wrap)
        r.textColor = .black333
        r.font = .mediumFont(16)
        r.text =  cionType
        return r
    }()
    lazy var totalLabel: UILabel = {
        let r = UILabel()
        r.textAlignment = .center
        r.textColor = .black333
        r.font = .regularFont(46)
        r.text = "0.00"
        return r
    }()
    lazy var moneyLabel: UILabel = {
        let r = UILabel()
        r.textAlignment = .center
        r.textColor = .primaryColor
        r.font = .regularFont(16)
        r.text = "≈￥0.00"
        return r
    }()
    lazy var sureBtn: QMUIButton = {
        let r = ViewFactoryUtil.linkButton("确认转账".localized())
        r.setTitleColor(.white, for: .normal)
        r.corner(28)
        r.titleLabel?.font = .semiboldFont(14)
        r.backgroundColor = .primaryColor
        r.rx.tap.subscribe(onNext: { [self] in
            
            if IMController.shared.certificationLevel == 0 {
                let alert = UIAlertController(title: "提示", message: "请先进行实名认证".innerLocalized(), preferredStyle: .alert)
                // 创建UIAlertAction，用于处理用户的选择
                let cancleAction = UIAlertAction(title: "取消", style: .default) { _ in
                }
                let okAction = UIAlertAction(title: "去认证", style: .default) { _ in
                    let vc =  BoBRealNameMainViewController()
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                // 将action添加到alertController上
                alert.addAction(cancleAction)
                alert.addAction(okAction)
                // 弹出alert
                self.present(alert, animated: true, completion: nil)
            }else{
                if IMController.shared.isSetPayPassWord {
                    let passWordView = BoBPayPassWordView()
                    passWordView.tg_width.equal(.fill)
                    passWordView.tg_height.equal(210)
                    passWordView.payBtnClickBlock = { [weak self] passWord in
                        
                        BoBRedPacketModel.SendTransferMoneyRequest(receiverUserId: self?.receiveUserId, currency: self?.chooseCionTypeModel?.currency, issuingPartyWallet: self?.chooseCionTypeModel?.cionType, transferAmount:self?.countTF.text ?? "0.00" ,instructions:self?.descTF.text ?? "", passWord: passWord, transferAccountsType: self?.transferAccountsType,groupId: self?.groupId ?? ""){ [weak self] data in
                            SuperToast.show(title:"转账成功")
                            let sendUserId = data.issuingPartyUserId ?? ""
                            let sendUserName = data.issuingPartyUserNickName ?? ""
                            let receiverId = data.receiverUserId ?? ""
                            let receiverName = data.nickName ?? ""
                            let code = data.transferCode ?? ""
                            let transferAccountsType = data.transferAccountsType ?? 0
                            let instructions = data.instructions ?? ""
                            let currency = data.currency ?? ""
                            let money = data.transferAmount ?? 0.00

                            if self?.sendTransferAccountsAction != nil{
                                let param1 = ["sendUserId": sendUserId,
                                              "sendUserName":sendUserName,
                                              "receiverId":receiverId,
                                              "receiverName":receiverName,
                                              "code":code,
                                              "transferAccountsType":transferAccountsType,
                                              "instructions":instructions,
                                              "currency":currency,
                                              "money":money
                                              ]
                                if let jsonData = try? JSONSerialization.data(withJSONObject: param1, options: []) {
                                    // 尝试将Data转换成字符串
                                    if let jsonString = String(data: jsonData, encoding: .utf8) {
                                        self?.sendTransferAccountsAction(jsonString)
                                    }
                                }
                            }
                            self?.navigationController?.popViewController(animated: true)
                            }completionHandler:{errCode,errMsg in
                                if errCode == -1{
                                    SuperToast.show(title: errMsg)
                                }else{
                                    SuperToast.show(title: String(errCode) + "：" + String(errCode).localized())
                                }
                        }
                    }

                    GKCover.cover(from: self.view.window, contentView: passWordView, style: .translucent, showStyle: .center, showAnimStyle: .bottom, hideAnimStyle: .bottom, notClick: false)
                    
                }else{
                    let alert = UIAlertController(title: "提示", message: "为了您的财产安全，请设置安全密码".innerLocalized(), preferredStyle: .alert)
                    // 创建UIAlertAction，用于处理用户的选择
                    let cancleAction = UIAlertAction(title: "取消", style: .default) { _ in
                    }
                    let okAction = UIAlertAction(title: "去设置", style: .default) { _ in
                        let vc = BoBChangePayPassWordViewController()
                        vc.passWordType = 0
                        self.navigationController?.pushViewController(vc,animated: true)
                    }
                    // 将action添加到alertController上
                    alert.addAction(cancleAction)
                    alert.addAction(okAction)
                    // 弹出alert
                    self.present(alert, animated: true, completion: nil)
                }
                
            }
        }).disposed(by: rx.disposeBag)
        return r
    }()
    
}
