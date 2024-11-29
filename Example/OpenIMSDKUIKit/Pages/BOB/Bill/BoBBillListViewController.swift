//
//  BoBBillListViewController.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/11/29.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Foundation
import JXSegmentedView
import OUICore


class BoBBillListViewController: BaseTitleController {
    var titles = ["全部","转账","收款","购买","出售","红包","调账","私聊转账","群聊转账"]
    let segmentedDataSource = JXSegmentedTitleDataSource()
    let segmentedView = JXSegmentedView()
    lazy var listContainerView: JXSegmentedListContainerView! = {
        return JXSegmentedListContainerView(dataSource: self)
    }()
    override func initViews() {
        
        super.initViews()
        view.backgroundColor = .colorBackgroundAPP
        initLinearLayoutSafeArea()
        title = "账单"
        container.tg_padding = UIEdgeInsets(top: 0, left: PADDING_OUTER, bottom: 0, right: PADDING_OUTER)

        //配置数据源
        segmentedDataSource.isTitleColorGradientEnabled = true
        segmentedDataSource.titles = titles
        segmentedDataSource.titleNormalColor = .black999
        segmentedDataSource.titleSelectedColor = .black333
        segmentedDataSource.titleNormalFont = .mediumFont(16)
        segmentedDataSource.titleSelectedFont = .mediumFont(16)
        //配置指示器
        let indicator = JXSegmentedIndicatorLineView()
        indicator.indicatorWidth = 55
        indicator.indicatorColor = .black333
        indicator.lineStyle = .lengthen

        //segmentedViewDataSource一定要通过属性强持有！！！！！！！！！
        segmentedView.dataSource = segmentedDataSource
        segmentedView.indicators = [indicator]
//        segmentedView.frame = CGRect(x: 0, y: 0, width: view.bounds.size.width, height: 44)
        segmentedView.backgroundColor = UIColor.white
        container.addSubview(bgView)
        bgView.addSubview(segmentedView)
        segmentedView.listContainer = listContainerView
        bgView.addSubview(listContainerView)
        bgView.snp_makeConstraints { make in
            make.top.equalTo(0)
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.bottom.equalTo(container.snp_bottomMargin)
        }
        segmentedView.snp_makeConstraints { make in
            make.top.equalTo(0)
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.height.equalTo(60)
        }
        listContainerView.snp_makeConstraints { make in
            make.left.right.equalTo(0)
            make.bottom.equalTo(0)
            make.top.equalTo(segmentedView.snp_bottom)
        }
        bgView.addSubview(lineView)
        lineView.snp_makeConstraints { make in
            make.left.right.equalTo(0)
            make.bottom.equalTo(segmentedView)
            make.height.equalTo(1)
        }
        
    }
    lazy var bgView: UIView = {
        let r = UIView()
        r.backgroundColor = .white
        r.corner(14)
        return r
    }()
    lazy var lineView: UIView = {
        let r = UIView()
        r.backgroundColor = .colorDivider
        return r
    }()
}

extension BoBBillListViewController: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return view
    }
}

extension BoBBillListViewController: JXSegmentedListContainerViewDataSource {
    func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
        if let titleDataSource = segmentedView.dataSource as? JXSegmentedBaseDataSource {
            return titleDataSource.dataSource.count
        }
        return 0
    }

    func listContainerView(_ listContainerView: JXSegmentedListContainerView, initListAt index: Int) -> JXSegmentedListContainerViewListDelegate {
        return BoBBillListView()
    }
}
