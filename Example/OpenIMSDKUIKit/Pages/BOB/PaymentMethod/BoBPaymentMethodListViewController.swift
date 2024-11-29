//
//  BoBPaymentMethodListViewController.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/11/25.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Foundation
import OUICore
class BoBPaymentMethodListViewController:UIViewController{
    var listArray:[stringAndDatePOS] = []
    var paymentData:PaymentMethodData?
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = false
        reloadBtnAction()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .colorBackgroundAPP
        title = "支付方式"
        let addButton = UIBarButtonItem(title:"添加", style: .done, target: self, action: #selector(addPayMentMethodBtn))
        addButton.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.init(hexString: "#277FE6")], for: .normal)
        navigationItem.setRightBarButtonItems([addButton], animated: false)
        view.addSubview(tableView)
        view.addSubview(emptyView)
        view.addSubview(unRealNameTipView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(8)
            make.leading.bottom.trailing.equalToSuperview()
        }
        emptyView.snp_makeConstraints { make in
            make.edges.equalTo(view)
        }
        unRealNameTipView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.left.right.equalTo(0)
            make.height.equalTo(44)
        }
        
        if IMController.shared.certificationLevel == 0 {
            unRealNameTipView.show()
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
    private lazy var tableView: UITableView = {
        let v = UITableView()
        v.register(BoBPaymentMethodListCell.self, forCellReuseIdentifier: BoBPaymentMethodListCell.className)
        v.register(BoBPaymentMethodBankListCell.self, forCellReuseIdentifier: BoBPaymentMethodBankListCell.className)
        v.delegate = self
        v.dataSource = self
        v.rowHeight = 168.h
        v.tableFooterView = UIView()
        v.backgroundColor = .clear
        v.separatorColor = .cE8EAEF
        if #available(iOS 15.0, *) {
            v.sectionHeaderTopPadding = 0
        }
        return v
    }()
    lazy var emptyView:HDEmptyView  = {
        let emptyV:HDEmptyView = HDEmptyView.emptyActionViewWithImageStr(imageStr: "custom_blank_icon", titleStr: "空空如也".localized() as NSString, detailStr: "", btnTitleStr: "", target: self, action: #selector(reloadBtnAction)) as! HDEmptyView
        
        emptyV.titleLabTextColor = UIColor.red
        emptyV.actionBtnFont = UIFont.systemFont(ofSize: 19)
        emptyV.contentViewY = -90
        emptyV.actionBtnIsHidden = true
        emptyV.titleLabFont = UIFont(name: "PingFangSC-Medium", size: 16)!
        emptyV.titleLabTextColor =  UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
        return emptyV
    }()
    @objc func reloadBtnAction() {
        BoBPaymentModel.QueryUserPaymentList(userId: IMController.shared.uid){data in
            self.paymentData = data
            self.listArray = data.stringAndDatePOS ?? []
            self.tableView.reloadData()
            self.emptyView.isHidden = self.listArray.count > 0
            IMController.shared.certificationLevel = data.i
            if IMController.shared.certificationLevel == 0 {
                self.unRealNameTipView.show()
            }else{
                self.unRealNameTipView.hide()
            }
        } completionHandler: {errCode,errMsg in
            SuperToast.show(title: errMsg)
        }
    }
    @objc func addPayMentMethodBtn() {
        if IMController.shared.certificationLevel == 0{
            let alert = UIAlertController(title: "提示", message: "请先进行实名认证".innerLocalized(), preferredStyle: .alert)
            // 创建UIAlertAction，用于处理用户的选择
            let cancleAction = UIAlertAction(title: "取消".innerLocalized(), style: .default) { _ in
            }
            let okAction = UIAlertAction(title: "去认证".innerLocalized(), style: .default) { _ in
                let vc =  BoBRealNameMainViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            }
            // 将action添加到alertController上
            alert.addAction(cancleAction)
            alert.addAction(okAction)
            // 弹出alert
            self.present(alert, animated: true, completion: nil)
        }else{
            let vc = BoBAddPaymentMethodViewController()
            vc.name = paymentData?.name
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
extension BoBPaymentMethodListViewController: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listArray.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = listArray[indexPath.row]
        
        if item.type == "bank"{
            let cell =  tableView.dequeueReusableCell(withIdentifier: BoBPaymentMethodBankListCell.className, for: indexPath) as! BoBPaymentMethodBankListCell
            if let res = JsonTool.fromJson(item.stringValue!, toClass: paymentDdetailData.self) {
                cell.bankNameLabel.text = res.bankDeposit
                if res.bankId!.length < 8{
                    cell.bankNumberLabel.text = res.bankId
                }else{
                    cell.bankNumberLabel.text = res.bankId!.prefix(4) + " **** **** **** " + res.bankId!.suffix(4)
                }
                cell.nameLabel.text = res.name
            }
            cell.bankIcon.sd_setImage(with: URL(string: item.icon))
            cell.deleteBlock = {
                self.deletePayment(item: item, index: indexPath.row)
            }
            cell.editBlock = {
                let vc = BoBAddPaymentMethodViewController()
                vc.name = self.paymentData?.name
                vc.paymentDetail = item
                self.navigationController?.pushViewController(vc)
            }
            return cell
        }else{
            let cell =  tableView.dequeueReusableCell(withIdentifier: BoBPaymentMethodListCell.className, for: indexPath) as! BoBPaymentMethodListCell
            if let res = JsonTool.fromJson(item.stringValue!, toClass: paymentDdetailData.self) {
                cell.nameLabel.text = res.name
                cell.nickNameLabel.text = res.nickName
                cell.qrCodeImageView.sd_setImage(with: URL(string: res.img))
            }
            cell.paymentMethodIcon.sd_setImage(with: URL(string: item.icon))
            cell.paymentMethodLabel.text = item.type == "weiXin" ? "微信" : "支付宝"
            cell.deleteBlock = {
                self.deletePayment(item: item, index: indexPath.row)
            }
            cell.editBlock = {
                let vc = BoBAddPaymentMethodViewController()
                vc.name = self.paymentData?.name
                vc.paymentDetail = item
                self.navigationController?.pushViewController(vc)
            }
            return cell
        }
        
    }
    func deletePayment(item:stringAndDatePOS,index:Int){
        BoBPaymentModel.DeletePayMentRequest(userId: IMController.shared.uid, id: item.id){errCode,errMsg in 
            if errCode == 20000{
                SuperToast.show(title: "删除成功")
                self.listArray.remove(at: index)
                self.tableView.reloadData()
                self.emptyView.isHidden = self.listArray.count > 0
            }else{
                SuperToast.show(title: errMsg)
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 168.h
    }
    
    public func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
