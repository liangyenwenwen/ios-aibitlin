//
//  BoBPaymentMethodListViewController.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/11/25.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Foundation
class BoBPaymentMethodListViewController:UIViewController{
    var certificationLevel:Int = 0
    var listArray:[String] = []
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = false
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .colorBackgroundAPP
        title = "支付方式"
        let addButton = UIBarButtonItem(title:"添加", style: .done, target: self, action: #selector(addPayMentMethodBtn))
        addButton.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.init(hexString: "#277FE6")], for: .normal)
        navigationItem.setRightBarButtonItems([addButton], animated: false)
        view.addSubview(tableView)
        view.addSubview(unRealNameTipView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(8)
            make.leading.bottom.trailing.equalToSuperview()
        }
        unRealNameTipView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.left.right.equalTo(0)
            make.height.equalTo(44)
        }
        
        tableViewAddEmptyView()
        if certificationLevel == 0 {
            unRealNameTipView.show()
        }
    }
    lazy var unRealNameTipView: BoBUnRealNameTipView = {
        let v = BoBUnRealNameTipView()
        v.hide()
        let tap = UITapGestureRecognizer()
        tap.rx.event.subscribe {  _ in
            let vc =  BoBRealNameMainViewController()
            vc.certificationLevel = self.certificationLevel
            self.navigationController?.pushViewController(vc, animated: true)
        }
        v.addGestureRecognizer(tap)
        return v
    }()
    private lazy var tableView: UITableView = {
        let v = UITableView()
        v.register(BoBPaymentMethodListCell.self, forCellReuseIdentifier: BoBPaymentMethodListCell.className)
        v.register(BoBPaymentMethodBankListCell.self, forCellReuseIdentifier: BoBPaymentMethodBankListCell.className)
        v.rowHeight = 168.h
        v.tableFooterView = UIView()
        v.backgroundColor = .clear
        v.separatorColor = .cE8EAEF
        if #available(iOS 15.0, *) {
            v.sectionHeaderTopPadding = 0
        }
        return v
    }()
    func tableViewAddEmptyView() {
        let emptyV:HDEmptyView = HDEmptyView.emptyActionViewWithImageStr(imageStr: "custom_blank_icon", titleStr: "空空如也".localized() as NSString, detailStr: "", btnTitleStr: "", target: self, action: #selector(reloadBtnAction)) as! HDEmptyView
        emptyV.titleLabTextColor = UIColor.red
        emptyV.actionBtnFont = UIFont.systemFont(ofSize: 19)
        emptyV.contentViewY = -90
        emptyV.actionBtnIsHidden = true
        emptyV.titleLabFont = UIFont(name: "PingFangSC-Medium", size: 16)!
        emptyV.titleLabTextColor =  UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
        
        tableView.ly_emptyView = emptyV
    }
    @objc func reloadBtnAction() {
        
    }
    @objc func addPayMentMethodBtn() {
        if certificationLevel == 0{
            let alert = UIAlertController(title: "提示", message: "请先进行实名认证".innerLocalized(), preferredStyle: .alert)
            // 创建UIAlertAction，用于处理用户的选择
            let cancleAction = UIAlertAction(title: "取消".innerLocalized(), style: .default) { _ in
            }
            let okAction = UIAlertAction(title: "去认证".innerLocalized(), style: .default) { _ in
                let vc =  BoBRealNameMainViewController()
                vc.certificationLevel = self.certificationLevel
                self.navigationController?.pushViewController(vc, animated: true)
            }
            // 将action添加到alertController上
            alert.addAction(cancleAction)
            alert.addAction(okAction)
            // 弹出alert
            self.present(alert, animated: true, completion: nil)
        }else{
            let vc = BoBAddPaymentMethodViewController()
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: BoBPaymentMethodListCell.className, for: indexPath) as! BoBPaymentMethodListCell

//        cell.titleLabel.text = item.title
//        cell.avatarImageView.image = item.icon
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 168.h
    }
    
    public func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
