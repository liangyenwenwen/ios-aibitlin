//
//  BoBChooseBankListViewController.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/11/25.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Foundation
import OUICore

class BoBChooseBankListViewController:UIViewController, UISearchBarDelegate{
    var allArray:[paymentBankData] = []
    var listArray:[paymentBankData] = []
    var chooseBankBlock: ((_ bankName: String)->Void)!
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "选择银行"
        let searchBarController = UISearchController(searchResultsController: nil)
        searchBarController.searchResultsUpdater = self as? UISearchResultsUpdating
        searchBarController.searchBar.delegate = self
        searchBarController.searchBar.placeholder = "输入银行名称查询"
        if #available(iOS 11, *) {
            self.navigationItem.searchController = searchBarController
            self.navigationItem.searchController?.isActive = true
            self.navigationItem.hidesSearchBarWhenScrolling = false
        } else {
            tableView.tableHeaderView = searchBarController.searchBar
        }
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.bottom.trailing.equalToSuperview()
        }
        loadBankList()
    }
    private lazy var tableView: UITableView = {
        let v = UITableView()
        v.register(BoBChooseBankListCell.self, forCellReuseIdentifier: BoBChooseBankListCell.className)
        v.delegate = self
        v.dataSource = self
        v.tableFooterView = UIView()
        v.backgroundColor = .clear
        v.separatorColor = .cE8EAEF
        if #available(iOS 15.0, *) {
            v.sectionHeaderTopPadding = 0
        }
        return v
    }()
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        listArray = allArray
        tableView.reloadData()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        listArray.removeAll()
        listArray = allArray.filter({ (item) -> Bool in
            if item.name!.lowercased().contains(searchText.lowercased()) || searchText == ""{
                    return true
                }else{
                    return false
                }
            })
        tableView.reloadData()
    }
    func loadBankList(){
        BoBPaymentModel.GetBankList(userId: IMController.shared.uid){ data in
            self.allArray = data
            self.listArray = data
            self.tableView.reloadData()
        } completionHandler: {errCode,errMsg in
            SuperToast.show(title: String(errCode).localized())
        }
    }

}
extension BoBChooseBankListViewController: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listArray.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = listArray[indexPath.row]
        
        let cell =  tableView.dequeueReusableCell(withIdentifier: BoBChooseBankListCell.className, for: indexPath) as! BoBChooseBankListCell
        cell.bankIcon.sd_setImage(with: URL(string: item.icon))
        cell.bankNameLabel.text = item.name
        return cell
        
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.h
    }
    
    public func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = listArray[indexPath.row]
        if chooseBankBlock != nil{
            chooseBankBlock(item.name!)
        }
        self.navigationController?.popViewController(animated: true)
    }
}
