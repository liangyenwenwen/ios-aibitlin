//
//  BoBBuyAndSellCionDetailViewController.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/12/19.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Foundation
import JXSegmentedView
import TangramKit
import OUICore
class BoBBuyAndSellCionDetailViewController: BaseTitleController {
    var detailData:BoBBuyAndSellFreeAreaList?
    var homeData:BoBBuyAndSellHomeData?
    var isRefresh:Bool = false
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
        setBackGroundColor(.white)
        initLinearLayoutSafeArea()
        title = (detailData?.advertisingType == 1 ? "出售" : "买入") + (detailData?.advertisingCurrency ?? "C")
        container.tg_padding = UIEdgeInsets(top: 0, left: 0, bottom: 15, right: 0)
        container.addSubview(exchangeRateView)
        let titles = ["按金额购买", "按数量购买"]
        //segmentedViewDataSource一定要通过属性强持有！！！！！！！！！
//        segmentedDataSource.titles = titles
//        segmentedDataSource.isTitleMaskEnabled = true
//        segmentedDataSource.titleNormalColor = .black999
//        segmentedDataSource.titleSelectedColor = .primaryColor
//        segmentedDataSource.titleNormalFont = .mediumFont(16)
//        segmentedDataSource.titleSelectedFont = .mediumFont(16)
//        segmentedDataSource.itemSpacing = 70
        
//        segmentedDataSource.isTitleColorGradientEnabled = true
        segmentedDataSource.titles = titles
        segmentedDataSource.titleNormalColor = .black666
        segmentedDataSource.titleSelectedColor = .primaryColor
        segmentedDataSource.titleNormalFont = .mediumFont(16)
        segmentedDataSource.titleSelectedFont = .mediumFont(16)
        segmentedDataSource.itemSpacing = 20
        
        //配置指示器
        let indicator = JXSegmentedIndicatorLineView()
        indicator.indicatorWidth = JXSegmentedViewAutomaticDimension
        indicator.indicatorColor = .init(hexString: "#388CEF")
        indicator.lineStyle = .lengthen

        //segmentedViewDataSource一定要通过属性强持有！！！！！！！！！
        
        segmentedView.dataSource = segmentedDataSource
        segmentedView.indicators = [indicator]
        segmentedView.frame = CGRect(x: 0, y: 37, width: view.bounds.size.width, height: 48)
        container.addSubview(segmentedView)
        segmentedView.listContainer = listContainerView
        container.addSubview(listContainerView)
        container.addSubview(lineView)
        listContainerView.snp_makeConstraints { make in
            make.top.equalTo(segmentedView.snp_bottom)
            make.left.right.bottom.equalTo(0)
        }
        lineView.snp_makeConstraints { make in
            make.left.right.equalTo(0)
            make.bottom.equalTo(segmentedView)
            make.height.equalTo(1)
        }
    }
    lazy var exchangeRateView: UIView = {
        let r = UIView()
        r.tg_top.equal(0)
        r.tg_left.equal(0)
        r.tg_width.equal(kScreenWidth)
        r.tg_height.equal(37)
        r.backgroundColor = .init(hexString: "#F5F5F5")
        r.addSubview(exchangeRateCionImageView)
        r.addSubview(exchangeRateLabel)
        r.addSubview(refreshImageView)
        exchangeRateCionImageView.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.centerY.equalTo(r)
            make.width.height.equalTo(20)
        }
        exchangeRateLabel.snp_makeConstraints { make in
            make.left.equalTo(exchangeRateCionImageView.snp_right).offset(2)
            make.centerY.equalTo(r)
        }
        refreshImageView.snp_makeConstraints { make in
            make.centerY.equalTo(r)
            make.width.equalTo(12)
            make.height.equalTo(12)
            make.left.equalTo(exchangeRateLabel.snp_right).offset(7)
        }
        let tap = UITapGestureRecognizer()
        tap.rx.event.subscribe {[weak self]  _ in
            if self?.isRefresh == false {
                self?.isRefresh = true
                BoBBuyAndSellCionModel.RefreshTheExchangeRateRequest(){data in
                    self?.stopRote()
                    self?.exchangeRateLabel.text = "单价" + String(format: " ￥%.2f", data)
                } completionHandler:{errCode,errMsg in
                    self?.stopRote()
                }
                self?.rotateImageView()
            }
        }.disposed(by: rx.disposeBag)
        r.addGestureRecognizer(tap)
        
        return r
    }()
    func stopRote(){
       refreshImageView.layer.removeAllAnimations()
       isRefresh = false
    }
    func rotateImageView() {
        // 定义旋转动画
        refreshImageView.layer.removeAllAnimations()
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = NSNumber(value: Double.pi * 2)
        rotationAnimation.duration = 0.45
        rotationAnimation.isCumulative = true
        rotationAnimation.repeatCount = 140
        rotationAnimation.isRemovedOnCompletion = false
        refreshImageView.layer.add(rotationAnimation, forKey: nil)
        }
    lazy var exchangeRateCionImageView:UIImageView = {
        let r = UIImageView(image: UIImage(named: "mine_home_cion_c_icon"))
        return r
    }()
    lazy var exchangeRateLabel:UILabel = {
        let r = UILabel()
        r.textColor = .black666
        r.font = .mediumFont(14)
        r.text = "单价" + " ￥1.00"
        return r
    }()
    private lazy var refreshImageView: UIView = {
        let r = UIImageView(image: UIImage(named: "mine_home_refresh_icon")?.changeImageColor(color: .primaryColor))
        return r
    }()
    lazy var lineView: UIView = {
        let r = UIView()
        r.backgroundColor = .init(hexString: "#EAEAEA")
        return r
    }()
}
extension BoBBuyAndSellCionDetailViewController: JXSegmentedListContainerViewDataSource {
    func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
        if let titleDataSource = segmentedView.dataSource as? JXSegmentedBaseDataSource {
            return titleDataSource.dataSource.count
        }
        return 0
    }

    func listContainerView(_ listContainerView: JXSegmentedListContainerView, initListAt index: Int) -> JXSegmentedListContainerViewListDelegate {
        let vc = BoBBuyAndSellCionSubDetailViewController()
        vc.homeData = homeData
        vc.detailData = detailData
        return vc
    }
}
