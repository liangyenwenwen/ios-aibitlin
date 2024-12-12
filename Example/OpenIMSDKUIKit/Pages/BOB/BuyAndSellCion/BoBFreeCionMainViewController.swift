//
//  BoBFreeCionMainViewController.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/12/10.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Foundation
import JXSegmentedView
import OUICore


class BoBFreeCionMainViewController: UIViewController {
    var currentVC:UIViewController?
    var titles = ["购买", "出售"]
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
        segmentedDataSource.titleNormalColor = .black666
        segmentedDataSource.titleSelectedColor = .primaryColor
        segmentedDataSource.titleNormalFont = .mediumFont(18)
        segmentedDataSource.titleSelectedFont = .mediumFont(20)
        segmentedDataSource.isItemSpacingAverageEnabled = false

        //segmentedViewDataSource一定要通过属性强持有！！！！！！！！！
        segmentedView.dataSource = segmentedDataSource
        segmentedView.frame = CGRect(x: 16, y: 5, width: view.bounds.size.width-32, height: 30)
//        segmentedView.backgroundColor = UIColor.white
        segmentedView.contentEdgeInsetLeft = 0
        view.addSubview(segmentedView)
//        segmentedView.snp_makeConstraints { make in
//            make.left.equalTo(16)
//            make.top.equalTo(5)
//            make.height.equalTo(30)
//            make.right.equalTo(-16)
//        }

        segmentedView.listContainer = listContainerView
        view.addSubview(listContainerView)
        view.addSubview(rightView)
        rightView.snp_makeConstraints { make in
            make.right.equalTo(-16)
            make.height.centerY.equalTo(segmentedView)
        }
        
    }
    func creatAd(){
        let choosePushAdTypeView = BoBChoosePushAdTypeView()
        choosePushAdTypeView.tg_width.equal(.fill)
        choosePushAdTypeView.tg_height.equal(193)
        choosePushAdTypeView.drawUI(array: ["购买","出售"])
        choosePushAdTypeView.choosePushAdTypeBlock = { [weak self] typeIndex in
            if typeIndex == 0{
                //购买
            }else if typeIndex == 1{
                //出售
            }
        }
        GKCover.cover(from: self.view.window, contentView: choosePushAdTypeView, style: .translucent, showStyle: .bottom, showAnimStyle: .bottom, hideAnimStyle: .bottom, notClick: false)
    }
    func warnAlertView(){
        let warnView = BoBCreatAdWarnAlertView()
        warnView.tg_width.equal(290)
        warnView.tg_height.equal(.wrap)
        warnView.tg_centerY.equal(0)
        GKCover.cover(from: currentVC?.view, contentView: warnView, style: .translucent, showStyle: .center, showAnimStyle: .bottom, hideAnimStyle: .bottom, notClick: true)
    }
    lazy var rightView: UIView = {
        let r = UIView()
        let imageView = UIImageView(image: UIImage(named: "mine_buy_and_sell_push_left_icon"))
        r.addSubview(imageView)
        imageView.snp_makeConstraints { make in
            make.centerY.right.equalTo(r)
            make.width.height.equalTo(18)
        }
        r.addSubview(bgImageView)
        bgImageView.snp_makeConstraints { make in
            make.left.equalTo(r)
            make.right.equalTo(imageView.snp_left).offset(-6)
            make.height.equalTo(18)
            make.centerY.equalTo(r)
        }
        let tap = UITapGestureRecognizer()
        tap.rx.event.subscribe {  _ in
            //选择
            let choosePushAdTypeView = BoBChoosePushAdTypeView()
            choosePushAdTypeView.tg_width.equal(.fill)
            choosePushAdTypeView.tg_height.equal(245)
            choosePushAdTypeView.drawUI(array: ["创建广告","我的广告","订单"])
            choosePushAdTypeView.choosePushAdTypeBlock = { [weak self] typeIndex in
                if typeIndex == 0{
                    //创建广告
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                        self?.creatAd()
                        self?.warnAlertView()
                    }
                    
                }else if typeIndex == 1{
                    //我的广告
                    
                }else{
                    //订单
                    
                }
            }
            GKCover.cover(from: self.view.window, contentView: choosePushAdTypeView, style: .translucent, showStyle: .bottom, showAnimStyle: .bottom, hideAnimStyle: .bottom, notClick: false)
        }.disposed(by: rx.disposeBag)
        r.addGestureRecognizer(tap)
        return r
    }()
    lazy var bgImageView: UIImageView = {
        let r = UIImageView()
        let image = UIImage(named: "mine_buy_and_sell_push_right_icon")!
        let capInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 8)
        // 创建拉伸的图像
        let resizableImage = image.resizableImage(withCapInsets: capInsets, resizingMode: .stretch)
        r.image = resizableImage
        r.addSubview(titleLabel)
        titleLabel.snp_makeConstraints { make in
            make.left.equalTo(4)
            make.right.equalTo(-8)
            make.top.equalTo(3)
            make.bottom.equalTo(-3)
        }
        return r
    }()
    lazy var titleLabel:UILabel = {
        let r = UILabel()
        r.font = .regularFont(12)
        r.textColor = .white
        r.text = "发布广告"
//        r.textAlignment = .center
        return r
    }()
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        listContainerView.frame = CGRect(x: 0, y: 40, width: view.bounds.size.width, height: view.bounds.size.height - 40)
    }
}

extension BoBFreeCionMainViewController: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return view
    }
}

extension BoBFreeCionMainViewController: JXSegmentedListContainerViewDataSource {
    func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
        if let titleDataSource = segmentedView.dataSource as? JXSegmentedBaseDataSource {
            return titleDataSource.dataSource.count
        }
        return 0
    }

    func listContainerView(_ listContainerView: JXSegmentedListContainerView, initListAt index: Int) -> JXSegmentedListContainerViewListDelegate {
        let vc = BoBFreeCionTypeMainViewController()
        vc.currentVC = currentVC
        return vc
    }
}
