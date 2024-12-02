//
//  BoBTransferAccountsViewController.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/11/28.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Foundation
import OUICore
import RxSwift
import RxCocoa
import RxGesture
import OUIIM
import ProgressHUD

class BoBTransferAccountsViewController:BaseTitleController{
    var cionType = "C"
    var address = ""
    var transferAccountsHomeData:TransferAccountsHomeData?
    var chooseCionTypeModel:CionTypeModel?
    var cionTypeArray:[CionTypeModel] = []
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        if IMController.shared.certificationLevel == 0 {
            unRealNameTipView.show()
            unRealNameTipView.snp_remakeConstraints { make in
                make.top.equalTo(0)
                make.left.right.equalTo(0)
                make.height.equalTo(44)
            }
            titleLabel.snp_remakeConstraints { make in
                make.left.equalTo(16)
                make.right.equalTo(-16)
                make.top.equalTo(unRealNameTipView.snp_bottom)
                make.height.equalTo(36)
            }
        }else{
            unRealNameTipView.hide()
            titleLabel.snp_remakeConstraints { make in
                make.left.equalTo(16)
                make.right.equalTo(-16)
                make.top.equalTo(0)
                make.height.equalTo(36)
            }
        }
    }
    override func initViews() {
        super.initViews()
        view.backgroundColor = .colorBackgroundAPP
        initLinearLayoutSafeArea()
        title = "转账"
        container.tg_padding = UIEdgeInsets(top: 0, left: PADDING_OUTER, bottom: 0, right: PADDING_OUTER)
        container.addSubview(unRealNameTipView)
        container.addSubview(titleLabel)
        container.addSubview(cionTypeView)
        container.addSubview(addressContentView)
        container.addSubview(countView)
        container.addSubview(tipLabel1)
        container.addSubview(tipLabel2)
        container.addSubview(tipLabel3)
        container.addSubview(sureBtn)
        titleLabel.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.top.equalTo(0)
            make.height.equalTo(36)
        }
        cionTypeView.snp_makeConstraints { make in
            make.top.equalTo(titleLabel.snp_bottom)
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.height.equalTo(50)
        }
        addressContentView.snp_makeConstraints { make in
            make.left.right.equalTo(cionTypeView)
            make.top.equalTo(cionTypeView.snp_bottom).offset(24)
            make.height.equalTo(76)
        }
        countView.snp_makeConstraints { make in
            make.left.right.equalTo(cionTypeView)
            make.top.equalTo(addressContentView.snp_bottom).offset(24)
            make.height.equalTo(160)
        }
        tipLabel1.snp_makeConstraints { make in
            make.left.right.equalTo(countView)
            make.top.equalTo(countView.snp_bottom).offset(20)
        }
        tipLabel2.snp_makeConstraints { make in
            make.left.right.equalTo(tipLabel1)
            make.top.equalTo(tipLabel1.snp_bottom).offset(5)
        }
        tipLabel3.snp_makeConstraints { make in
            make.left.right.equalTo(tipLabel1)
            make.top.equalTo(tipLabel2.snp_bottom).offset(5)
        }
        sureBtn.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.height.equalTo(56)
            make.bottom.equalTo(view.snp.bottomMargin)
        }
        let tap = UITapGestureRecognizer()
        tap.rx.event.subscribe {  _ in
            self.view.endEditing(true)
        }
        view.addGestureRecognizer(tap)
        bindBtnData()
        loadData()
    }
    private func bindBtnData() {
        Observable.combineLatest(addressTF.rx.text.orEmpty, countTF.rx.text.orEmpty) {
            $0.count > 0 && $1.count > 0
        }
        .bind(to: sureBtn.rx.isEnabled)
        .disposed(by:rx.disposeBag)
    }
    func loadData(){
        BoBPaymentModel.TransferAccountsHomeRequest(userId: IMController.shared.uid){data in
            self.transferAccountsHomeData = data
            IMController.shared.isSetPayPassWord = data.anQuan ?? false
            for item in self.transferAccountsHomeData!.cpos{
                let model1 = CionTypeModel(icon: item.icon, biZhong: item.biZhong, xianE: item.xianE, shouXuFei: item.shouXuFei, zuiXiaoShouXuFei: item.zuiXiaoShouXuFei, cionType: item.biZhong! + "0", money: item.t0, type: 0, isSelect: true)
                let model2 = CionTypeModel(icon: item.icon, biZhong: item.biZhong, xianE: item.xianE, shouXuFei: item.shouXuFei, zuiXiaoShouXuFei: item.zuiXiaoShouXuFei, cionType: item.biZhong! + "1", money: item.t1, type: 1, isSelect: false)
                self.cionTypeArray.append(model1)
                self.cionTypeArray.append(model2)
            }
            if self.cionTypeArray.count > 0{
                self.chooseCionTypeModel = self.cionTypeArray[0]
                self.refreshUI()
            }
            
        }completionHandler: {errCode,errMsg in
            SuperToast.show(title: errMsg)
        }
    }
    func refreshUI(){
        cionTypeImageView.sd_setImage(with: URL(string: chooseCionTypeModel?.icon))
        cionNameLabel.text = chooseCionTypeModel?.biZhong
        if chooseCionTypeModel?.type == 0{
            self.walletType.text = "T+0钱包"
            self.walletType.textColor = .init(hexString: "#00AA3C")
            self.walletType.backgroundColor = .init(hexString: "#E5F6EB")
        }else{
            self.walletType.text = "T+1钱包"
            self.walletType.textColor = .init(hexString: "#FFA756")
            self.walletType.backgroundColor = .init(hexString: "#FFF7E5")
        }
        self.countCionImageView.sd_setImage(with: URL(string: chooseCionTypeModel?.icon))
        let str = "可用余额：" + String(format: "%.2f",(chooseCionTypeModel?.money)!) + (chooseCionTypeModel?.biZhong)!
        let attributedString = NSMutableAttributedString(string: str)
        attributedString.addAttribute(.foregroundColor, value: UIColor.black666, range: NSRange(location: 0, length: 5))
        self.totalLabel.attributedText = attributedString
        if (chooseCionTypeModel?.xianE)! > 0{
            self.countTF.placeholder = "限额" + "0.01~" + String(format: "%.2f ",(chooseCionTypeModel?.xianE)!) + (chooseCionTypeModel?.biZhong)!
        }else{
            self.countTF.placeholder = "限额" + "0.00 " + (chooseCionTypeModel?.biZhong)!
        }
        self.countTitleLabel.text = "到账数量" + String(format: "（%@)",(chooseCionTypeModel?.biZhong)!)
        self.calculationMoney()
        self.tipLabel1.text = "24h转账额度：0.01/" + String(format: "%.2f ",(chooseCionTypeModel?.xianE)!) + (chooseCionTypeModel?.biZhong)!
    }
    func calculationMoney(){
        self.countLabel.text = "0.00"
        self.serviceChargeLabel.text = "手续费" + String(format: "%.2f",(chooseCionTypeModel?.zuiXiaoShouXuFei)!)  + (chooseCionTypeModel?.biZhong)!
        if let doubleValue = Double(countTF.text ?? "0") {
            if doubleValue > 0{
                var count = 0.00
                if (chooseCionTypeModel?.shouXuFei)!*doubleValue > (chooseCionTypeModel?.zuiXiaoShouXuFei)!{
                    self.serviceChargeLabel.text = "手续费" + String(format: "%.2f",(chooseCionTypeModel?.shouXuFei)!*doubleValue)  + (chooseCionTypeModel?.biZhong)!
                    count = doubleValue - (chooseCionTypeModel?.shouXuFei)!*doubleValue
                }else{
                    count = doubleValue - (chooseCionTypeModel?.zuiXiaoShouXuFei)!
                }
                if count > 0{
                    self.countLabel.text = String(format: "%.2f",count)
                }
            }
        }
    }
    lazy var unRealNameTipView: BoBUnRealNameTipView = {
        let v = BoBUnRealNameTipView()
        v.hide()
        let tap = UITapGestureRecognizer()
        tap.rx.event.subscribe {  _ in
            let vc =  BoBRealNameMainViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        v.addGestureRecognizer(tap)
        return v
    }()
    lazy var titleLabel: UILabel = {
        let r = UILabel()
        r.textColor = .black333
        r.font = .semiboldFont(16)
        r.text = "币种"
        return r
    }()
    lazy var cionTypeView: UIView = {
        let r = UIView()
        r.backgroundColor = .white
        r.corner(8)
        r.addSubview(cionTypeImageView)
        r.addSubview(cionNameLabel)
        r.addSubview(walletType)
        let v = UIImageView(image: UIImage(named: "SuperChevronRight"))
        v.tintColor = .black80
        v.contentMode = .scaleAspectFit
        r.addSubview(v)
        cionTypeImageView.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.centerY.equalTo(r)
            make.width.height.equalTo(26)
        }
        cionNameLabel.snp_makeConstraints { make in
            make.left.equalTo(cionTypeImageView.snp_right).offset(10)
            make.centerY.equalTo(cionTypeImageView.snp_centerY)
        }
        walletType.snp_makeConstraints { make in
            make.left.equalTo(cionNameLabel.snp_right).offset(7)
            make.centerY.equalTo(cionNameLabel)
            make.width.equalTo(62)
            make.height.equalTo(26)
        }
        v.snp_makeConstraints { make in
            make.right.equalTo(-16)
            make.centerY.equalTo(r)
            make.width.height.equalTo(15)
        }
        let tap = UITapGestureRecognizer()
        tap.rx.event.subscribe {  _ in
            self.view.endEditing(true)
            let chooseTypeView = BoBChooseCionTypeView()
            chooseTypeView.tg_width.equal(.fill)
            chooseTypeView.tg_height.equal(300)
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
    lazy var cionTypeImageView: UIImageView = {
        let r = UIImageView(image: UIImage(named: "mine_home_cion_c_icon"))
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
    lazy var addressContentView: UIView = {
        let r = UIView()
        let v = UILabel()
        v.textColor = .black333
        v.font = .semiboldFont(16)
        v.text = "地址"
        r.addSubview(v)
        v.snp_makeConstraints { make in
            make.left.top.right.equalTo(r)
        }
        let bgView = UIView()
        bgView.backgroundColor = .white
        bgView.corner(8)
        r.addSubview(bgView)
        bgView.snp_makeConstraints { make in
            make.left.right.bottom.equalTo(r)
            make.height.equalTo(50)
        }
        bgView.addSubview(addressTF)
        bgView.addSubview(pasteBtn)
        bgView.addSubview(scanBtn)
        addressTF.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.centerY.equalTo(bgView)
            make.right.equalTo(pasteBtn.snp_left).offset(-5)
        }
        pasteBtn.snp_makeConstraints { make in
            make.width.equalTo(40)
            make.top.bottom.equalTo(bgView)
            make.right.equalTo(scanBtn.snp_left)
        }
        scanBtn.snp_makeConstraints { make in
            make.width.equalTo(34)
            make.top.bottom.equalTo(bgView)
            make.right.equalTo(-11)
        }
        return r
    }()
    lazy var addressTF: QMUITextField = {
        let r = QMUITextField()
        r.font = .regularFont(16)
        r.tintColor = .black333
        r.setPlaceHolderTextColor(.black999)
        r.placeholder = "输入接收者地址"
        r.text = address
        return r
    }()
    lazy var pasteBtn: QMUIButton = {
        let r = ViewFactoryUtil.linkButton("粘贴".localized())
        r.setTitleColor(.black333, for: .normal)
        r.titleLabel?.font = .regularFont(14)
        r.rx.tap.subscribe(onNext: { [self] in
            let pasteboard = UIPasteboard.general
            if let copiedText = pasteboard.string {
                addressTF.text = copiedText
                addressTF.endEditing(true)
            }
        }).disposed(by: rx.disposeBag)
        return r
    }()
    lazy var scanBtn: QMUIButton = {
        let r = ViewFactoryUtil.imageBtn(UIImage(named: "mine_transfer_accounts_scan_icon")!, 24)
        r.rx.tap.subscribe(onNext: { [self] in
            let vc = ScanViewController()
            vc.scanDidComplete = { [weak self] (result: String) in
                ProgressHUD.dismiss()
                if result.contains(IMController.walletTransferPrefix) {
                    self?.addressTF.text = result.replacingOccurrences(of: IMController.walletTransferPrefix, with: "")
                } else {
                    SuperToast.show(title: "unrecognized".innerLocalized())
                }
                self?.navigationController?.popViewController(animated: true)
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }).disposed(by: rx.disposeBag)
        return r
    }()
    
    lazy var countView: UIView = {
        let r = UIView()
        let v = UILabel()
        v.textColor = .black333
        v.font = .semiboldFont(16)
        v.text = "数量"
        r.addSubview(v)
        v.snp_makeConstraints { make in
            make.left.top.equalTo(r)
            make.width.equalTo(64)
            make.height.equalTo(14)
        }
        r.addSubview(totalLabel)
        totalLabel.snp_makeConstraints { make in
            make.centerY.equalTo(v)
            make.right.equalTo(r)
        }
        
        let bgView = UIView()
        bgView.backgroundColor = .white
        bgView.corner(8)
        r.addSubview(bgView)
        bgView.snp_makeConstraints { make in
            make.left.right.equalTo(r)
            make.top.equalTo(v.snp_bottom).offset(12)
            make.height.equalTo(50)
        }
        bgView.addSubview(countCionImageView)
        bgView.addSubview(countTF)
        bgView.addSubview(allBtn)
        countCionImageView.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.width.height.equalTo(26)
            make.centerY.equalTo(bgView)
        }
        countTF.snp_makeConstraints { make in
            make.left.equalTo(countCionImageView.snp_right).offset(10)
            make.centerY.equalTo(bgView)
            make.right.equalTo(allBtn.snp_left).offset(-5)
        }
        allBtn.snp_makeConstraints { make in
            make.width.equalTo(61)
            make.top.bottom.right.equalTo(bgView)
        }
        let bgView1 = UIView()
        bgView1.backgroundColor = .white
        bgView1.corner(8)
        r.addSubview(bgView1)
        bgView1.addSubview(countTitleLabel)
        bgView1.addSubview(countLabel)
        bgView1.addSubview(serviceChargeLabel)
        bgView1.snp_makeConstraints { make in
            make.left.right.equalTo(r)
            make.bottom.equalTo(r)
            make.height.equalTo(72)
        }
        countTitleLabel.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.top.equalTo(14)
            make.height.equalTo(22)
        }
        countLabel.snp_makeConstraints { make in
            make.right.equalTo(-16)
            make.centerY.equalTo(countTitleLabel)
            make.left.equalTo(countTitleLabel.snp_right).offset(10)
        }
        serviceChargeLabel.snp_makeConstraints { make in
            make.left.equalTo(countTitleLabel)
            make.right.equalTo(countLabel)
            make.bottom.equalTo(-13)
            make.height.equalTo(20)
        }
        return r
    }()
    lazy var totalLabel: UILabel = {
        let r = UILabel()
        r.textColor = .primaryColor
        r.font = .regularFont(14)
        r.textAlignment = .right
        let attributedString = NSMutableAttributedString(string: "可用余额：0.00C")
        attributedString.addAttribute(.foregroundColor, value: UIColor.black666, range: NSRange(location: 0, length: 5))
        r.attributedText = attributedString
        return r
    }()
    lazy var countCionImageView:UIImageView  = {
        let r = UIImageView(image: UIImage(named: "mine_home_cion_c_icon"))
        return r
    }()
    lazy var countTF: QMUITextField = {
        let r = QMUITextField()
        r.font = .regularFont(16)
        r.tintColor = .black333
        r.keyboardType = .decimalPad
        r.setPlaceHolderTextColor(.black999)
        r.placeholder = "限额0.01~100,000 C"
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
    lazy var allBtn: QMUIButton = {
        let r = ViewFactoryUtil.linkButton("全部".localized())
        r.setTitleColor(.primaryColor, for: .normal)
        r.titleLabel?.font = .regularFont(14)
        r.rx.tap.subscribe(onNext: { [self] in
            self.countTF.text = String(format: "%.2f",(chooseCionTypeModel?.money)!)
        }).disposed(by: rx.disposeBag)
        return r
    }()
    lazy var countTitleLabel: UILabel = {
        let r = UILabel()
        r.textColor = .black333
        r.font = .regularFont(16)
        r.text = "到账数量（C）"
        return r
    }()
    lazy var countLabel: UILabel = {
        let r = UILabel()
        r.textColor = .primaryColor
        r.font = .mediumFont(16)
        r.textAlignment = .right
        r.text = "0.00"
        return r
    }()
    lazy var serviceChargeLabel: UILabel = {
        let r = UILabel()
        r.textColor = .black999
        r.font = .regularFont(14)
        r.textAlignment = .right
        r.text = "手续费 0.00 C"
        return r
    }()
    lazy var tipLabel1: UILabel = {
        let r = UILabel()
        r.textColor = .black666
        r.font = .regularFont(14)
        r.numberOfLines = 0
        r.text = "24h转账额度：0.01/800,000.00C"
        return r
    }()
    lazy var tipLabel2: UILabel = {
        let r = UILabel()
        r.textColor = .black666
        r.font = .regularFont(14)
        r.numberOfLines = 0
        r.text = "到账数量=提款数量-手续费。"
        return r
    }()
    lazy var tipLabel3: UILabel = {
        let r = UILabel()
        r.textColor = .black666
        r.font = .regularFont(14)
        r.numberOfLines = 0
        r.text = "请勿用于其他币种，否则资产将不可找回。"
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
                        BoBPaymentModel.SendExternalTransferRequest(userId:IMController.shared.uid, addr: self?.addressTF.text, currency: self?.chooseCionTypeModel?.biZhong, issuingPartyWallet: self?.chooseCionTypeModel?.cionType, transferAmount:self?.countTF.text ?? "0.00" , passWord: passWord){errCode,errMsg in
                            if errCode == 20000{
                                SuperToast.show(title:"转账成功")
                                self?.navigationController?.popViewController(animated: true)
                            }else{
                                SuperToast.show(title: errMsg)
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
