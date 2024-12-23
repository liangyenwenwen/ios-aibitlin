//
//  BoBChoosePaymentMethodTypeView.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/12/16.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import MMBAlertsPickers
import OUICore
import ProgressHUD
import RxCocoa
import RxSwift
import TangramKit
import UIKit
class BoBChoosePaymentMethodTypeView: TGLinearLayout {
    var choosePaymentMethodTypeBlock:((_ choosePayment:stringAndDatePOS,_ newPaymentMethodData:PaymentMethodData)->())!
    var currentVC:UIViewController?
    var listArray:[stringAndDatePOS] = []
    var paymentMethodData:PaymentMethodData?
    var choosePaymentMethod:stringAndDatePOS?
    var bankList:[stringAndDatePOS] = []
    var aliList:[stringAndDatePOS] = []
    var wxList:[stringAndDatePOS] = []
    var isSupportBank:Bool = true
    var isSupportAli:Bool = true
    var isSupportWeixin:Bool = true
    var paymentType:Int = 0 //0银行卡、1支付宝、2微信
    init() {
        super.init(frame: .zero, orientation: .vert)
        innerInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        innerInit()
    }
    
    func innerInit() {
        corner(MEDDLE_RADIUS)
        tg_width.equal(.fill)
        tg_height.equal(.wrap)
        tg_gravity = .horz.center
        tg_padding = UIEdgeInsets(top: PADDING_OUTER, left: PADDING_OUTER, bottom: PADDING_MEDDLE, right: PADDING_OUTER)
        backgroundColor = .white
        addSubview(titleLbl)
        addSubview(closeBtn)
        addSubview(chooseTypeView)
        addSubview(addBtn)
        addSubview(tableView)
        titleLbl.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(closeBtn.snp_left).offset(-15)
            make.top.equalTo(20)
        }
        
        closeBtn.snp_makeConstraints { make in
            make.right.equalTo(-16)
            make.centerY.equalTo(titleLbl)
            make.width.height.equalTo(28)
        }
        chooseTypeView.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.top.equalTo(titleLbl.snp_bottom).offset(25)
            make.height.equalTo(40)
        }
        addBtn.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.height.equalTo(46)
            make.bottom.equalTo(-24)
        }
        tableView.snp_makeConstraints { make in
            make.left.right.equalTo(0)
            make.top.equalTo(chooseTypeView.snp_bottom).offset(20)
            make.bottom.equalTo(addBtn.snp_top).offset(-30)
        }
        
    }
    func bindData(paymentData:PaymentMethodData?,choosePayment:stringAndDatePOS?,isSupportBank:Bool?,isSupportAli:Bool?,isSupportWeixin:Bool?){
        paymentMethodData = paymentData
        choosePaymentMethod = choosePayment
        self.isSupportBank = isSupportBank ?? true
        self.isSupportAli = isSupportAli ?? true
        self.isSupportWeixin = isSupportWeixin ?? true
        bankList.removeAll()
        aliList.removeAll()
        wxList.removeAll()
        for i in 0..<(paymentMethodData?.stringAndDatePOS?.count ?? 0) {
            let data = (paymentMethodData?.stringAndDatePOS![safe: i]!)! as stringAndDatePOS
            if data.type == "bank"{
                bankList.append(data)
            }else if data.type == "weiXin"{
                wxList.append(data)
            }else{
                aliList.append(data)
            }
        }
        if bankList.count > 0 && self.isSupportBank{
            bankBtn.alpha = 1
            bankBtn.isUserInteractionEnabled = true
        }else{
            bankBtn.alpha = 0.5
            bankBtn.isUserInteractionEnabled = false
        }
        if aliList.count > 0 && self.isSupportAli{
            aliBtn.alpha = 1
            aliBtn.isUserInteractionEnabled = true
        }else{
            aliBtn.alpha = 0.5
            aliBtn.isUserInteractionEnabled = false
        }
        if wxList.count > 0 && self.isSupportWeixin{
            weixinBtn.alpha = 1
            weixinBtn.isUserInteractionEnabled = true
        }else{
            weixinBtn.alpha = 0.5
            weixinBtn.isUserInteractionEnabled = false
        }
        if paymentType == 0{
            if bankList.count > 0 && self.isSupportBank{
                listArray = bankList
                bankBtn.border(.init(hexString: "#277FE6"),borderWidth: 1,cornerRadius: 8)
                bankBtn.selectStatusImageView.show()
                aliBtn.border(.init(hexString: "#D6DEE6"),borderWidth: 1,cornerRadius: 8)
                aliBtn.selectStatusImageView.hide()
                weixinBtn.border(.init(hexString: "#D6DEE6"),borderWidth: 1,cornerRadius: 8)
                weixinBtn.selectStatusImageView.hide()
            }else{
                paymentType = 1
            }
        }
        if paymentType == 1{
            if aliList.count > 0 && self.isSupportAli{
                listArray = aliList
                aliBtn.border(.init(hexString: "#277FE6"),borderWidth: 1,cornerRadius: 8)
                aliBtn.selectStatusImageView.show()
                bankBtn.border(.init(hexString: "#D6DEE6"),borderWidth: 1,cornerRadius: 8)
                bankBtn.selectStatusImageView.hide()
                weixinBtn.border(.init(hexString: "#D6DEE6"),borderWidth: 1,cornerRadius: 8)
                weixinBtn.selectStatusImageView.hide()
            }else{
                paymentType = 2
            }
        }
        if paymentType == 2{
            if wxList.count > 0 && self.isSupportWeixin{
                listArray = wxList
                weixinBtn.border(.init(hexString: "#277FE6"),borderWidth: 1,cornerRadius: 8)
                weixinBtn.selectStatusImageView.show()
                bankBtn.border(.init(hexString: "#D6DEE6"),borderWidth: 1,cornerRadius: 8)
                bankBtn.selectStatusImageView.hide()
                aliBtn.border(.init(hexString: "#D6DEE6"),borderWidth: 1,cornerRadius: 8)
                aliBtn.selectStatusImageView.hide()
            }else{
                paymentType = 0
                bankBtn.border(.init(hexString: "#D6DEE6"),borderWidth: 1,cornerRadius: 8)
                bankBtn.selectStatusImageView.hide()
            }
        }
        tableView.reloadData()
    }
    lazy var titleLbl: UILabel = {
        let r = ViewFactoryUtil.customTilteLabelFill("支付方式", font: 18, textColor: .black333)
        r.font = .mediumFont(18)
        r.textColor = .black333
        return r
    }()
    lazy var closeBtn: QMUIButton = {
        let r = ViewFactoryUtil.imageBtn(R.image.close_cirle_icon()!, 28)
        r.rx.tap.subscribe(onNext: {
            GKCover.hide()
        })
        .disposed(by: rx.disposeBag)
        return r
    }()
    lazy var chooseTypeView: UIView = {
        let r = UIView()
        r.addSubview(bankBtn)
        r.addSubview(aliBtn)
        r.addSubview(weixinBtn)
        let width = (kScreenWidth - 32 - 17*2)/3.0
        bankBtn.snp_makeConstraints { make in
            make.left.top.bottom.equalTo(0)
            make.width.equalTo(width)
        }
        aliBtn.snp_makeConstraints { make in
            make.left.equalTo(bankBtn.snp_right).offset(17)
            make.top.width.height.equalTo(bankBtn)
        }
        weixinBtn.snp_makeConstraints { make in
            make.left.equalTo(aliBtn.snp_right).offset(17)
            make.top.width.height.equalTo(bankBtn)
        }
        return r
    }()
    lazy var bankBtn: ChooseBtn = {
        let r = ChooseBtn()
        r.bindData(title: "银行卡", icon: UIImage(named: "mine_payment_method_bank_icon")!)
        r.border(.init(hexString: "#277FE6"),borderWidth: 1,cornerRadius: 8)
        r.selectStatusImageView.show()
        r.btn.rx.tap.subscribe(onNext: { [weak self] in
            if self?.paymentType != 0{
                self?.paymentType = 0
                r.border(.init(hexString: "#277FE6"),borderWidth: 1,cornerRadius: 8)
                r.selectStatusImageView.show()
                self?.aliBtn.border(.init(hexString: "#D6DEE6"),borderWidth: 1,cornerRadius: 8)
                self?.aliBtn.selectStatusImageView.hide()
                self?.weixinBtn.border(.init(hexString: "#D6DEE6"),borderWidth: 1,cornerRadius: 8)
                self?.weixinBtn.selectStatusImageView.hide()
                self?.listArray = self?.bankList ?? []
                self?.tableView.reloadData()
                
            }
        }).disposed(by: rx.disposeBag)
        return r
    }()
    lazy var aliBtn: ChooseBtn = {
        let r = ChooseBtn()
        r.bindData(title: "支付宝", icon: UIImage(named: "mine_payment_method_ali_icon")!)
        r.btn.rx.tap.subscribe(onNext: { [weak self] in
            if self?.paymentType != 1{
                self?.paymentType = 1
                r.border(.init(hexString: "#277FE6"),borderWidth: 1,cornerRadius: 8)
                r.selectStatusImageView.show()
                self?.bankBtn.border(.init(hexString: "#D6DEE6"),borderWidth: 1,cornerRadius: 8)
                self?.bankBtn.selectStatusImageView.hide()
                self?.weixinBtn.border(.init(hexString: "#D6DEE6"),borderWidth: 1,cornerRadius: 8)
                self?.weixinBtn.selectStatusImageView.hide()
                self?.listArray = self?.aliList ?? []
                self?.tableView.reloadData()
            }
        }).disposed(by: rx.disposeBag)
        return r
    }()
    lazy var weixinBtn: ChooseBtn = {
        let r = ChooseBtn()
        r.bindData(title: "微信", icon: UIImage(named: "mine_payment_method_weixin_icon")!)
        r.btn.rx.tap.subscribe(onNext: { [weak self] in
            if self?.paymentType != 2{
                self?.paymentType = 2
                r.border(.init(hexString: "#277FE6"),borderWidth: 1,cornerRadius: 8)
                r.selectStatusImageView.show()
                self?.bankBtn.border(.init(hexString: "#D6DEE6"),borderWidth: 1,cornerRadius: 8)
                self?.bankBtn.selectStatusImageView.hide()
                self?.aliBtn.border(.init(hexString: "#D6DEE6"),borderWidth: 1,cornerRadius: 8)
                self?.aliBtn.selectStatusImageView.hide()
                self?.listArray = self?.wxList ?? []
                self?.tableView.reloadData()
            }
        }).disposed(by: rx.disposeBag)
        return r
    }()
    private lazy var tableView: UITableView = {
        let v = UITableView()
        v.register(BoBChoosePaymentMethodTypeCell.self, forCellReuseIdentifier: BoBChoosePaymentMethodTypeCell.className)
        v.delegate = self
        v.dataSource = self
        v.tableFooterView = UIView()
        v.separatorStyle = .none
        if #available(iOS 15.0, *) {
            v.sectionHeaderTopPadding = 0
        }
        return v
    }()
    lazy var addBtn: QMUIButton = {
        let r = ViewFactoryUtil.linkButton("添加新的支付方式")
        r.corner(23)
        r.backgroundColor = .init(hexString: "#388CEF")
        r.setTitleColor(.white, for: .normal)
        r.titleLabel?.font = .mediumFont(16)
        r.rx.tap.subscribe(onNext: { [weak self] in
            let vc = BoBAddPaymentMethodViewController()
            vc.name = self?.paymentMethodData?.name
            if self?.isSupportBank == true{
                vc.paymentType = 0
            }else{
                if self?.isSupportAli == true{
                    vc.paymentType = 1
                }else{
                    if self?.isSupportWeixin == true{
                        vc.paymentType = 2
                    }
                }
            }
            self?.currentVC?.navigationController?.pushViewController(vc, animated: true)
            GKCover.hide()
        })
        .disposed(by: rx.disposeBag)
        return r
    }()
}
extension BoBChoosePaymentMethodTypeView: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listArray.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = listArray[indexPath.row]
        let cell =  tableView.dequeueReusableCell(withIdentifier: BoBChoosePaymentMethodTypeCell.className, for: indexPath) as! BoBChoosePaymentMethodTypeCell
        cell.iconImageView.sd_setImage(with: URL(string: item.icon))
        if item.type == "bank"{
            if let res = JsonTool.fromJson(item.stringValue!, toClass: paymentDdetailData.self) {
                cell.paymentNameLabel.text = res.bankDeposit
                cell.userNameLabel.text = res.name
                if res.bankId!.length < 8{
                    cell.numberLabel.text = res.bankId
                }else{
                    cell.numberLabel.text = res.bankId!.prefix(4) + "**********" + res.bankId!.suffix(4)
                }
            }
        }else{
            if let res = JsonTool.fromJson(item.stringValue!, toClass: paymentDdetailData.self) {
                cell.userNameLabel.text = res.name
                cell.numberLabel.text = res.nickName
            }
            cell.paymentNameLabel.text = item.type == "weiXin" ? "微信" : "支付宝"
        }
        if choosePaymentMethod != nil && item.id == choosePaymentMethod?.id{
            cell.bgView.border(.init(hexString: "#277FE6"), borderWidth: 1, cornerRadius: 8)
            cell.selectStatusImageView.show()
        }else{
            cell.bgView.border(.init(hexString: "#D6DEE6"), borderWidth: 1, cornerRadius: 8)
            cell.selectStatusImageView.hide()
        }
        return cell
        
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    public func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        choosePaymentMethod = listArray[indexPath.row]
        if choosePaymentMethodTypeBlock != nil{
            choosePaymentMethodTypeBlock(choosePaymentMethod!,paymentMethodData!)
        }
        GKCover.hide()
    }
}
