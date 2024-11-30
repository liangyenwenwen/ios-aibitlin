//
//  BoBBillListView.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/11/29.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Foundation
import JXSegmentedView
import OUICore

class BoBBillListView: UIView {
    var tableView: UITableView!
    var chooseType:Int = 0
    var timeStart:String = ""
    var timeEnd:String = ""
    var page:Int = 1
    var listArray:[BillListData] = []
    override init(frame: CGRect) {
        super.init(frame: frame)

        tableView = UITableView(frame: frame, style: .plain)
        tableView.backgroundColor = UIColor.white
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(BoBBillListCell.self, forCellReuseIdentifier: "cell")
        addSubview(tableView)
        
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

    override func layoutSubviews() {
        super.layoutSubviews()

        tableView.frame = bounds
    }
    @objc func refreshData(){
        loadData(pageNum:1)
    }
    @objc func loadMoreData(){
        loadData(pageNum: page+1)
    }
    func loadData(pageNum:Int){
        BoBPaymentModel.GetMyBillList(userId: IMController.shared.uid, tpye: chooseType, timeStart: timeStart, timeEnd: timeEnd, currency: "C", pageSize: 20, pageNum: pageNum) { data in
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

extension BoBBillListView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! BoBBillListCell
        let item = listArray[indexPath.row]
        cell.billNameLabel.text = item.show
        cell.timeLabel.text = item.time
        cell.countLabel.text = item.changeZf! + String(format: "%.2f ",item.amount!)
        if item.changeZf == "+"{
            cell.countLabel.textColor = .init(hexString: "#FA7225")
        }else{
            cell.countLabel.textColor = .black333
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }

}

extension BoBBillListView: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return self
    }
}
