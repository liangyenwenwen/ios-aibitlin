//
//  BoBQuickCionTypeMainViewController.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/12/10.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Foundation
import JXSegmentedView

class BoBQuickCionTypeMainViewController: UIViewController {
    var currentVC:UIViewController?
    var titles = ["C"]
    var type:Int = 1 //1是购买，2是出售
    let segmentedDataSource = JXSegmentedTitleDataSource()
    let segmentedView = JXSegmentedView()
    var homeData:BoBBuyAndSellHomeData?
    lazy var listContainerView: JXSegmentedListContainerView! = {
        return JXSegmentedListContainerView(dataSource: self)
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        if homeData != nil{
            var list: [String] = []
            for item in homeData!.currencyAndIconPO {
                list.append(item.currency ?? "")
            }
            titles = list
        }
        view.backgroundColor = .clear
        //配置数据源
        segmentedDataSource.isTitleColorGradientEnabled = true
        segmentedDataSource.titles = titles
        segmentedDataSource.titleNormalColor = .black666
        segmentedDataSource.titleSelectedColor = .black333
        segmentedDataSource.titleNormalFont = .mediumFont(14)
        segmentedDataSource.titleSelectedFont = .mediumFont(14)
        segmentedDataSource.isItemSpacingAverageEnabled = false
        //配置指示器
        let indicator = JXSegmentedIndicatorLineView()
        indicator.indicatorWidth = JXSegmentedViewAutomaticDimension
        indicator.indicatorColor = .init(hexString: "#388CEF")
        indicator.lineStyle = .lengthen

        //segmentedViewDataSource一定要通过属性强持有！！！！！！！！！
        segmentedView.dataSource = segmentedDataSource
        segmentedView.frame = CGRect(x: 16, y: 5, width: view.bounds.size.width-32, height: 30)
        segmentedView.indicators = [indicator]
        segmentedView.contentEdgeInsetLeft = 0
        view.addSubview(segmentedView)
        segmentedView.listContainer = listContainerView
        view.addSubview(listContainerView)
    }
    func reloadVCData(data:BoBBuyAndSellHomeData){
        if homeData == nil{
            homeData = data
            var list: [String] = []
            for item in data.currencyAndIconPO {
                list.append(item.currency ?? "")
            }
            titles = list
            segmentedDataSource.titles = titles
            segmentedView.reloadData()
        }else{
            homeData = data
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        listContainerView.frame = CGRect(x: 0, y: 40, width: view.bounds.size.width, height: view.bounds.size.height - 40)
    }
}

extension BoBQuickCionTypeMainViewController: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return view
    }
}

extension BoBQuickCionTypeMainViewController: JXSegmentedListContainerViewDataSource {
    func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
        if let titleDataSource = segmentedView.dataSource as? JXSegmentedBaseDataSource {
            return titleDataSource.dataSource.count
        }
        return 0
    }

    func listContainerView(_ listContainerView: JXSegmentedListContainerView, initListAt index: Int) -> JXSegmentedListContainerViewListDelegate {
        var currencyIcon = ""
        if let obj = homeData?.currencyAndIconPO[index]{
            currencyIcon = obj.icon ?? ""
        }
        let vc = BoBQuickBuyAndSellView(data: homeData,viewType: type,currentCurrency: titles[index],currentCurrencyIcon:currencyIcon)
        vc.currentVC = self
        return vc
    }
}
