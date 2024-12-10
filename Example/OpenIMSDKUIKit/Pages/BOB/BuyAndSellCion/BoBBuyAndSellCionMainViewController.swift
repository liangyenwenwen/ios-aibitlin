//
//  BoBBuyAndSellCionMainViewController.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/12/10.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Foundation
import JXSegmentedView

class BoBBuyAndSellCionMainViewController: BaseTitleController {
    let segmentedDataSource = JXSegmentedTitleDataSource()
    let segmentedView = JXSegmentedView()
    lazy var listContainerView: JXSegmentedListContainerView! = {
        return JXSegmentedListContainerView(dataSource: self)
    }()
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func initViews() {
        super.initViews()
        view.backgroundColor = .colorBackgroundAPP
        initLinearLayoutSafeArea()
        container.tg_padding = UIEdgeInsets(top: PADDING_OUTER, left: PADDING_OUTER, bottom: PADDING_OUTER, right: PADDING_OUTER)
        let totalItemWidth: CGFloat = 175
        let titles = ["快捷区", "自选区"]
        //segmentedViewDataSource一定要通过属性强持有！！！！！！！！！
        segmentedDataSource.itemWidth = totalItemWidth/CGFloat(titles.count)
        segmentedDataSource.titles = titles
        segmentedDataSource.isTitleMaskEnabled = true
        segmentedDataSource.titleNormalColor = .white
        segmentedDataSource.titleSelectedColor = .white
        segmentedDataSource.titleNormalFont = .semiboldFont(16)
        segmentedDataSource.titleSelectedFont = .semiboldFont(16)
        segmentedDataSource.itemSpacing = 2

        let indicator = JXSegmentedIndicatorBackgroundView()
        indicator.indicatorHeight = 36
        indicator.indicatorCornerRadius = 18
        indicator.indicatorWidthIncrement = 0
        indicator.indicatorColor = .init(hexString: "#0D5FBE")
        indicator.alpha = 0.2
        segmentedView.layer.masksToBounds = true
        segmentedView.layer.cornerRadius = 20
        segmentedView.backgroundColor = .init(hexString: "#0D5FBE")
        segmentedView.dataSource = segmentedDataSource
        segmentedView.indicators = [indicator]
        view.addSubview(navBgView)
        navBgView.snp_makeConstraints { make in
            make.left.top.right.equalTo(0)
            make.bottom.equalTo(navView)
        }
        view.addSubview(segmentedView)
        segmentedView.snp_makeConstraints { make in
            make.centerX.equalTo(view)
            make.width.equalTo(totalItemWidth+10)
            make.height.equalTo(40)
            make.bottom.equalTo(navView.snp_bottom).offset(-6)
        }

        segmentedView.listContainer = listContainerView
        container.addSubview(listContainerView)
        listContainerView.snp_makeConstraints { make in
            make.top.equalTo(0)
            make.left.right.bottom.equalTo(0)
        }
       
    }
    lazy var navBgView: UIView = {
        let r = UIView()
        r.backgroundColor = .primaryColor
        r.layer.zPosition = -1
        return r
    }()
}

extension BoBBuyAndSellCionMainViewController: JXSegmentedListContainerViewDataSource {
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
