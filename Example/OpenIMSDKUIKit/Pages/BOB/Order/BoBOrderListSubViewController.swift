//
//  BoBOrderListSubViewController.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/11/19.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Foundation
import JXSegmentedView

class BoBOrderListSubViewController: UIViewController {
    var titles = [String]()
    let segmentedDataSource = JXSegmentedTitleDataSource()
    let segmentedView = JXSegmentedView()
    lazy var listContainerView: JXSegmentedListContainerView! = {
        return JXSegmentedListContainerView(dataSource: self)
    }()
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .colorBackgroundAPP
        
        //配置数据源
        segmentedDataSource.isTitleColorGradientEnabled = true
        segmentedDataSource.titles = titles
        segmentedDataSource.titleNormalColor = .black999
        segmentedDataSource.titleSelectedColor = .init(hexString: "#388CEF")
        segmentedDataSource.titleNormalFont = UIFont(name: "PingFangSC-Regular", size: 16)!
        //配置指示器
        let indicator = JXSegmentedIndicatorLineView()
        indicator.indicatorWidth = JXSegmentedViewAutomaticDimension
        indicator.indicatorColor = .init(hexString: "#388CEF")
        indicator.lineStyle = .lengthen

        //segmentedViewDataSource一定要通过属性强持有！！！！！！！！！
        segmentedView.dataSource = segmentedDataSource
        segmentedView.indicators = [indicator]
        segmentedView.frame = CGRect(x: 0, y: 0, width: view.bounds.size.width, height: 44)
        segmentedView.backgroundColor = UIColor.white
        view.addSubview(segmentedView)

        segmentedView.listContainer = listContainerView
        view.addSubview(listContainerView)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        listContainerView.frame = CGRect(x: 0, y: 44, width: view.bounds.size.width, height: view.bounds.size.height - 44)
    }
}

extension BoBOrderListSubViewController: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return view
    }
}

extension BoBOrderListSubViewController: JXSegmentedListContainerViewDataSource {
    func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
        if let titleDataSource = segmentedView.dataSource as? JXSegmentedBaseDataSource {
            return titleDataSource.dataSource.count
        }
        return 0
    }

    func listContainerView(_ listContainerView: JXSegmentedListContainerView, initListAt index: Int) -> JXSegmentedListContainerViewListDelegate {
        return BoBOrderListView()
    }
}
