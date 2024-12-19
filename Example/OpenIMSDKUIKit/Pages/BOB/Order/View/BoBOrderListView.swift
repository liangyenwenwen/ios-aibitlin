//
//  BoBOrderListView.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/11/19.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Foundation
import JXSegmentedView
import OUICore

class BoBOrderListView: UIView {
    var tableView: UITableView!
    var page:Int = 1
    var listArray:[BoBMineAdList] = []
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .colorBackgroundAPP
        tableView = UITableView(frame: frame, style: .plain)
        tableView.backgroundColor = UIColor.clear
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.register(BoBOrderListCell.self, forCellReuseIdentifier: "cell")
        addSubview(tableView)
        tableView.snp_makeConstraints { make in
            make.top.equalTo(12)
            make.left.right.equalTo(0)
            make.bottom.equalTo(self.snp_bottomMargin)
        }
        tableView.register(BoBMineAdvertisementCell.self, forCellReuseIdentifier: BoBMineAdvertisementCell.className)
        let header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(refreshData))

        tableView.mj_header = header
        let footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(loadMoreData))
        footer.isAutomaticallyRefresh = false
        footer.setTitle("点击或上拉加载更多".innerLocalized(), for: .idle)
        footer.setTitle("正在加载更多的数据...".innerLocalized(), for: .refreshing)
        tableView.mj_footer = footer
        tableView.mj_header?.beginRefreshing()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    @objc func refreshData(){
        loadData(pageNum:1)
    }
    @objc func loadMoreData(){
        loadData(pageNum: page+1)
    }
    func loadData(pageNum:Int){
        BoBBuyAndSellCionModel.MyAdvertisementListRequest(currency: "C",type: 0,state: 0,pageNum: pageNum, pageSize: 20) { data in
            self.page = pageNum
            if pageNum == 1{
                self.listArray.removeAll()
            }
            self.listArray.append(contentsOf: data)
            self.tableView.reloadData()
            self.tableView.mj_header?.endRefreshing()
            if data.count < 20{
                if var footer = self.tableView.mj_footer as? MJRefreshAutoNormalFooter {
                    footer.setTitle("加载完成，没有更多了...".innerLocalized(), for: .noMoreData)
                    footer.stateLabel?.textColor = .init(hexString: "#CCCCCC")
                    footer.stateLabel?.font = .mediumFont(16)
                    footer.endRefreshingWithNoMoreData()
                }
            }else{
                self.tableView.mj_footer?.endRefreshing()
            }
        }completionHandler: {errCode,errMsg in
            SuperToast.show(title: errMsg)
            self.tableView.mj_header?.endRefreshing()
            self.tableView.mj_footer?.endRefreshing()

        }
    }
}

extension BoBOrderListView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! BoBOrderListCell
        let item = listArray[indexPath.row]
        cell.cionImageView.sd_setImage(with: URL(string: item.icon))
        cell.adTypeNameLabel.text = (item.advertisingType == 1 ? "出售":"购买") + " " + (item.advertisingCurrency ?? "C")
        cell.appealStatusLabel.text = ""
        if indexPath.row%4 == 0{
            cell.statusLabel.text = "进行中"
            cell.statusLabel.backgroundColor = .init(hexString: "#0079FF")
        }else if indexPath.row%4 == 1{
            cell.statusLabel.text = "已完成"
            cell.statusLabel.backgroundColor = .init(hexString: "#12B366")
            cell.appealStatusLabel.text = "订单申诉已完成"
            cell.appealStatusLabel.textColor = .init(hexString: "#0079FF")
        }else if indexPath.row%4 == 2{
            cell.statusLabel.text = "已取消"
            cell.statusLabel.backgroundColor = .init(hexString: "#FF3B31")
        }else{
            cell.statusLabel.text = "已超时"
            cell.statusLabel.backgroundColor = .init(hexString: "#FFA756")
            cell.appealStatusLabel.text = "订单申诉中，请耐心等待..."
            cell.appealStatusLabel.textColor = .init(hexString: "#F32525")
        }
        cell.moneyLabel.text = "450C"
        cell.exchangeRateLabel.text = String(format: "¥%.2f", item.setExchangeRate ?? 1.00)
        cell.orderNumberLabel.text = "订单编号：202401166784789"
        cell.timeLabel.text = "2024-01-16 15:12:14"
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }

}

extension BoBOrderListView: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return self
    }
}
