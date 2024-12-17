//
//  BoBQuickCionMainViewController.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/12/10.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Foundation
import JXSegmentedView

class BoBQuickCionMainViewController: UIViewController {
    var currentVC:UIViewController?
    var titles = ["购买", "出售"]
    let segmentedDataSource = JXSegmentedTitleDataSource()
    let segmentedView = JXSegmentedView()
    var homeData:BoBBuyAndSellHomeData?
    var buyVC:BoBQuickCionTypeMainViewController?
    var sellVC:BoBQuickCionTypeMainViewController?
    lazy var listContainerView: JXSegmentedListContainerView! = {
        return JXSegmentedListContainerView(dataSource: self)
    }()
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .colorBackgroundAPP
        view.addSubview(bgView)
        bgView.snp_makeConstraints { make in
            make.left.top.equalTo(16)
            make.right.equalTo(-16)
            make.height.equalTo(273)
        }
        
        //配置数据源
        segmentedDataSource.isTitleColorGradientEnabled = true
        segmentedDataSource.titles = titles
        segmentedDataSource.titleNormalColor = .black666
        segmentedDataSource.titleSelectedColor = .primaryColor
        segmentedDataSource.titleNormalFont = .mediumFont(18)
        segmentedDataSource.titleSelectedFont = .mediumFont(20)

        //segmentedViewDataSource一定要通过属性强持有！！！！！！！！！
        segmentedView.dataSource = segmentedDataSource
        segmentedView.contentEdgeInsetLeft = 0
        segmentedView.backgroundColor = .white
        view.addSubview(segmentedView)
        segmentedView.snp_makeConstraints { make in
            make.left.equalTo(bgView).offset(16)
            make.top.equalTo(bgView).offset(5)
            make.height.equalTo(30)
            make.right.equalTo(bgView).offset(-16)
        }
        segmentedView.listContainer = listContainerView
        view.addSubview(listContainerView)
        listContainerView.snp_makeConstraints { make in
            make.left.right.equalTo(bgView)
            make.top.equalTo(segmentedView.snp_bottom)
            make.bottom.equalTo(view)
        }
    }

    lazy var bgView: UIView = {
        let r = UIView()
        r.backgroundColor = .white
        r.corner(8)
        return r
    }()
    func reloadVCData(data:BoBBuyAndSellHomeData){
        homeData = data
        if buyVC != nil{
            buyVC?.reloadVCData(data: data)
        }
        if sellVC != nil{
            sellVC?.reloadVCData(data: data)
        }
    }
}

extension BoBQuickCionMainViewController: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return view
    }
}

extension BoBQuickCionMainViewController: JXSegmentedListContainerViewDataSource {
    func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
        if let titleDataSource = segmentedView.dataSource as? JXSegmentedBaseDataSource {
            return titleDataSource.dataSource.count
        }
        return 0
    }

    func listContainerView(_ listContainerView: JXSegmentedListContainerView, initListAt index: Int) -> JXSegmentedListContainerViewListDelegate {
        if index == 0{
            if buyVC == nil{
                buyVC = BoBQuickCionTypeMainViewController()
                buyVC!.currentVC = self
                buyVC!.homeData = homeData
                buyVC!.type = 1
            }
            return buyVC!
        }else{
            if sellVC == nil{
                sellVC = BoBQuickCionTypeMainViewController()
                sellVC!.currentVC = self
                sellVC!.homeData = homeData
                sellVC!.type = 2
            }
            return sellVC!
        }
    }
}
