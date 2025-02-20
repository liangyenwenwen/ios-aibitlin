//
//  PagingListBaseView.swift
//  JXPagingView
//
//  Created by jiaxin on 2018/5/28.
//  Copyright © 2018年 jiaxin. All rights reserved.
//

import UIKit
import OUICore

@objc public class PagingListBaseView: UIView {
    @objc public var tableView: UITableView!
    var listViewDidScrollCallback: ((UIScrollView) -> ())?
    
    var currentVC: UIViewController?
    var chooseType:Int = 0
    var timeStart:String = ""
    var timeEnd:String = ""
    var page:Int = 1
    var listArray:[BillListData] = []
    
    private var isHeaderRefreshed: Bool = false
    deinit {
        listViewDidScrollCallback = nil
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        tableView = UITableView(frame: frame, style: .plain)
        tableView.backgroundColor = UIColor.white
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(BoBBillListCell.self, forCellReuseIdentifier: "BoBBillListCell")
        addSubview(tableView)
        let footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(loadMoreData))
        footer.isAutomaticallyRefresh = false
        footer.setTitle("点击或上拉加载更多".innerLocalized(), for: .idle)
        footer.setTitle("正在加载更多的数据...".innerLocalized(), for: .refreshing)

        tableView.mj_footer = footer
    }
    @objc func loadMoreData(){
        loadData(pageNum: page+1)
    }
    func loadData(pageNum:Int){
        BoBPaymentModel.GetMyBillList(tpye: chooseType, timeStart: timeStart, timeEnd: timeEnd, currency: "C", pageSize: 20, pageNum: pageNum) { data in
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
            if errCode == -1{
                SuperToast.show(title: errMsg)
            }else{
                SuperToast.show(title: String(errCode) + "：" + String(errCode).localized())
            }
            self.tableView.mj_header?.endRefreshing()
            self.tableView.mj_footer?.endRefreshing()

        }
    }
    func beginFirstRefresh() {
        loadData(pageNum:1)
    }


    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        tableView.frame = self.bounds
    }

}

extension PagingListBaseView: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listArray.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BoBBillListCell", for: indexPath) as! BoBBillListCell
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

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = BoBBillDetailViewController()
        vc.billListData = listArray[indexPath.row]
        currentVC?.navigationController?.pushViewController(vc, animated: true)
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.listViewDidScrollCallback?(scrollView)
    }
}

extension PagingListBaseView: JXPagingViewListViewDelegate {
    public func listView() -> UIView {
        return self
    }
    
    public func listViewDidScrollCallback(callback: @escaping (UIScrollView) -> ()) {
        self.listViewDidScrollCallback = callback
    }

    public func listScrollView() -> UIScrollView {
        return self.tableView
    }
}
