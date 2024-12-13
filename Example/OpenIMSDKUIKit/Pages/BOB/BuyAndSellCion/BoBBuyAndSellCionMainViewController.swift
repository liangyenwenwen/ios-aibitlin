//
//  BoBBuyAndSellCionMainViewController.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/12/10.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Foundation
import JXSegmentedView
import OUICore

class BoBBuyAndSellCionMainViewController: BaseTitleController {
    let segmentedDataSource = JXSegmentedTitleDataSource()
    var homeData:BoBBuyAndSellHomeData?
    let segmentedView = JXSegmentedView()
    var quickCionVC:BoBQuickCionMainViewController?
    var freeCionVC:BoBFreeCionMainViewController?

    lazy var listContainerView: JXSegmentedListContainerView! = {
        return JXSegmentedListContainerView(dataSource: self)
    }()
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        reloadRealNameStatusAction()
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
        segmentedDataSource.itemSpacing = 0

        let indicator = JXSegmentedIndicatorImageView()
//        let indicator = JXSegmentedIndicatorBackgroundView()
        indicator.indicatorHeight = 42
        indicator.indicatorWidth = 90
        indicator.indicatorCornerRadius = 20
//        indicator.indicatorWidthIncrement = 30
        indicator.indicatorPosition = .center
        indicator.verticalOffset = 4
        
        let image = UIImage(named: "mine_buy_and_sell_cion_type_icon")!
        let capInsets = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 2)
        // 创建拉伸的图像
        let resizableImage = image.resizableImage(withCapInsets: capInsets, resizingMode: .stretch)
        indicator.image = resizableImage
//        indicator.indicatorColor = .init(hexString: "#0D5FBE")
//        indicator.alpha = 0.2
        segmentedView.layer.masksToBounds = true
        segmentedView.layer.cornerRadius = 20
        segmentedView.backgroundColor = .init(hexString: "#0D5FBE")
        segmentedView.dataSource = segmentedDataSource
        segmentedView.contentEdgeInsetLeft = 0
        segmentedView.contentEdgeInsetRight = 0

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
        container.addSubview(unRealNameTipView)
        container.addSubview(listContainerView)
        unRealNameTipView.snp_makeConstraints { make in
            make.left.right.top.equalTo(0)
            make.height.equalTo(44)
        }
        listContainerView.snp_makeConstraints { make in
            make.top.equalTo(unRealNameTipView.snp_bottom)
            make.left.right.bottom.equalTo(0)
        }
        loadData()
       
    }
    func loadData(){
        BoBBuyAndSellCionModel.BuyingAndSellingCoinsHomeRequest(){[weak self]data in
            self?.homeData = data
        } completionHandler:{errCode,errMsg in
            SuperToast.show(title: errMsg)
        }
    }
    lazy var navBgView: UIView = {
        let r = UIView()
        r.backgroundColor = .primaryColor
        r.isUserInteractionEnabled = false
        r.layer.zPosition = -1
        return r
    }()
    lazy var unRealNameTipView: BoBUnRealNameTipView = {
        let v = BoBUnRealNameTipView()
        v.hide()
        let tap = UITapGestureRecognizer()
        tap.rx.event.subscribe {  _ in
            let vc =  BoBRealNameMainViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by: rx.disposeBag)
        v.addGestureRecognizer(tap)
        return v
    }()
    @objc func reloadRealNameStatusAction() {
        if IMController.shared.certificationLevel == 1 {
            self.unRealNameTipView.show()
            unRealNameTipView.snp_updateConstraints { make in
                make.height.equalTo(44)
            }
        }else{
            self.unRealNameTipView.hide()
            unRealNameTipView.snp_updateConstraints { make in
                make.height.equalTo(0)
            }
        }
    }
}


extension BoBBuyAndSellCionMainViewController: JXSegmentedListContainerViewDataSource {
    func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
        if let titleDataSource = segmentedView.dataSource as? JXSegmentedBaseDataSource {
            return titleDataSource.dataSource.count
        }
        return 0
    }

    func listContainerView(_ listContainerView: JXSegmentedListContainerView, initListAt index: Int) -> JXSegmentedListContainerViewListDelegate {
        if index == 0{
            if quickCionVC == nil{
                quickCionVC = BoBQuickCionMainViewController()
                quickCionVC!.currentVC = self
            }
            return quickCionVC!
        }else{
            if freeCionVC == nil{
                freeCionVC = BoBFreeCionMainViewController()
                freeCionVC!.currentVC = self
            }
            return freeCionVC!
        }
        
    }
}
