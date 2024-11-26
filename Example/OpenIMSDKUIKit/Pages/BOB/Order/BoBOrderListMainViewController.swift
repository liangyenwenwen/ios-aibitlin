//
//  BoBOrderListMainViewController.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/11/19.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Foundation
import JXSegmentedView

class BoBOrderListMainViewController: UIViewController {
    let segmentedDataSource = JXSegmentedTitleDataSource()
    let segmentedView = JXSegmentedView()
    lazy var listContainerView: JXSegmentedListContainerView! = {
        return JXSegmentedListContainerView(dataSource: self)
    }()
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .colorBackgroundAPP

        let totalItemWidth: CGFloat = 172
        let titles = ["买入订单", "卖出订单"]
        //segmentedViewDataSource一定要通过属性强持有！！！！！！！！！
        segmentedDataSource.itemWidth = totalItemWidth/CGFloat(titles.count)
        segmentedDataSource.titles = titles
        segmentedDataSource.isTitleMaskEnabled = true
        segmentedDataSource.titleNormalColor = .black333
        segmentedDataSource.titleSelectedColor = .black333
        segmentedDataSource.titleNormalFont = UIFont(name: "PingFangSC-Regular", size: 13)!
        segmentedDataSource.itemSpacing = 2

        let indicator = JXSegmentedIndicatorBackgroundView()
        indicator.indicatorHeight = 28
        indicator.indicatorCornerRadius = 7
        indicator.indicatorWidthIncrement = 0
        indicator.indicatorColor = UIColor.white

        segmentedView.frame = CGRect(x: 0, y: 0, width: totalItemWidth+10, height: 32)
        segmentedView.layer.masksToBounds = true
        segmentedView.layer.cornerRadius = 9
        segmentedView.backgroundColor = .init(hexString: "#E8E8E8")
        segmentedView.dataSource = segmentedDataSource
        segmentedView.indicators = [indicator]
        navigationItem.titleView = segmentedView

        segmentedView.listContainer = listContainerView
        view.addSubview(listContainerView)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

//        listContainerView.frame = view.bounds
        listContainerView.snp_makeConstraints { make in
            make.left.right.bottom.equalTo(0)
            make.top.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
}

extension BoBOrderListMainViewController: JXSegmentedListContainerViewDataSource {
    func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
        if let titleDataSource = segmentedView.dataSource as? JXSegmentedBaseDataSource {
            return titleDataSource.dataSource.count
        }
        return 0
    }

    func listContainerView(_ listContainerView: JXSegmentedListContainerView, initListAt index: Int) -> JXSegmentedListContainerViewListDelegate {
        let vc = BoBOrderListSubViewController()
        vc.titles = ["全部", "待确认", "待付款", "待发货", "已完成"]
        return vc
    }
}
