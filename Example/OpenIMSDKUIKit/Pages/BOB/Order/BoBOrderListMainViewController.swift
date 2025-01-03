//
//  BoBOrderListMainViewController.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/11/19.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Foundation
import JXSegmentedView
import OUICore

class BoBOrderListMainViewController: BaseTitleController {
    let segmentedDataSource = JXSegmentedTitleDataSource()
    let segmentedView = JXSegmentedView()
    lazy var listContainerView: JXSegmentedListContainerView! = {
        return JXSegmentedListContainerView(dataSource: self)
    }()
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    override func initViews() {
        super.initViews()
        view.backgroundColor = .colorBackgroundAPP
        initLinearLayoutSafeArea()
        container.tg_padding = UIEdgeInsets(top: 0, left: PADDING_OUTER, bottom: 0, right: PADDING_OUTER)
        superFooterContainerContainer.tg_bottom.equal(0)
        let titles = ["买家订单", "卖家订单"]
        //segmentedViewDataSource一定要通过属性强持有！！！！！！！！！
        segmentedDataSource.titles = titles
        segmentedDataSource.isTitleMaskEnabled = true
        segmentedDataSource.titleNormalColor = .black666
        segmentedDataSource.titleSelectedColor = .primaryColor
        segmentedDataSource.titleNormalFont = .mediumFont(18)
        segmentedDataSource.titleSelectedFont = .mediumFont(18)
        segmentedDataSource.itemSpacing = 10
        
        let indicator = JXSegmentedIndicatorBackgroundView()
        indicator.indicatorColor = UIColor.clear
        
//        segmentedView.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: 32)
        segmentedView.dataSource = segmentedDataSource
        segmentedView.indicators = [indicator]
        view.addSubview(segmentedView)
        segmentedView.snp_makeConstraints { make in
            make.centerX.equalTo(view)
            make.width.equalTo(260)
            make.height.equalTo(32)
            make.bottom.equalTo(navView.snp_bottom).offset(-6)
        }
        
        segmentedView.listContainer = listContainerView
        container.addSubview(listContainerView)
        listContainerView.snp_makeConstraints { make in
            make.top.left.right.bottom.equalTo(0)
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
        vc.sign = index+1
        return vc
    }
}
