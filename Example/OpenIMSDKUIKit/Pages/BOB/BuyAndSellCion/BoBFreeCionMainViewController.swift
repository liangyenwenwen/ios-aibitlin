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
    var homeData:BoBBuyAndSellHomeData?
    let segmentedDataSource = JXSegmentedTitleDataSource()
    let segmentedView = JXSegmentedView()
    var buyVC:BoBFreeCionTypeMainViewController?
    var sellVC:BoBFreeCionTypeMainViewController?
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
    func reloadVCData(data:BoBBuyAndSellHomeData){
        homeData = data
        if buyVC != nil{
            buyVC?.reloadVCData(data: data)
        }
        if sellVC != nil{
            sellVC?.reloadVCData(data: data)
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
                let vc = BoBCreatAdvertisementViewController()
                vc.homeData = self?.homeData
                vc.advertisementType = 2
                self?.currentVC?.navigationController?.pushViewController(vc, animated: true)
            }else if typeIndex == 1{
                //出售
                let vc = BoBCreatAdvertisementViewController()
                vc.homeData = self?.homeData
                vc.advertisementType = 1
                self?.currentVC?.navigationController?.pushViewController(vc, animated: true)
            }
        }
        GKCover.cover(from: self.view.window, contentView: choosePushAdTypeView, style: .translucent, showStyle: .bottom, showAnimStyle: .bottom, hideAnimStyle: .bottom, notClick: false)
    }
    func warnAlertView(){
        let warnView = BoBCreatAdWarnAlertView()
        warnView.tg_width.equal(290)
        warnView.tg_height.equal(.wrap)
        warnView.tg_centerY.equal(0)
        warnView.bindData(homeData: homeData)
        GKCover.cover(from: currentVC?.view, contentView: warnView, style: .translucent, showStyle: .center, showAnimStyle: .bottom, hideAnimStyle: .bottom, notClick: true)
    }
    func creatAdNameAlertView(){
        let adNameView = BoBCreatAdNameAlertView()
        adNameView.tg_width.equal(293)
        adNameView.tg_height.equal(.wrap)
        adNameView.tg_centerY.equal(0)
        adNameView.bindData(adName: homeData?.advertisingName)
        adNameView.updateAdvertisingName = { [weak self] adName in
            self?.homeData?.advertisingName = adName
        }
        GKCover.cover(from: currentVC?.view, contentView: adNameView, style: .translucent, showStyle: .center, showAnimStyle: .bottom, hideAnimStyle: .bottom, notClick: true)
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
                        if IMController.shared.certificationLevel == 0 {
                            let alert = UIAlertController(title: "提示", message: "请先进行实名认证".innerLocalized(), preferredStyle: .alert)
                            // 创建UIAlertAction，用于处理用户的选择
                            let cancleAction = UIAlertAction(title: "取消", style: .default) { _ in
                            }
                            let okAction = UIAlertAction(title: "去认证", style: .default) { _ in
                                let vc =  BoBRealNameMainViewController()
                                self?.currentVC?.navigationController?.pushViewController(vc, animated: true)
                            }
                            // 将action添加到alertController上
                            alert.addAction(cancleAction)
                            alert.addAction(okAction)
                            // 弹出alert
                            self?.currentVC?.present(alert, animated: true, completion: nil)
                            return
                        }
                        if self?.homeData?.payment == false{
                            let alert = UIAlertController(title: "提示", message: "您还没有支付方式，请添加支付方式".innerLocalized(), preferredStyle: .alert)
                            // 创建UIAlertAction，用于处理用户的选择
                            let cancleAction = UIAlertAction(title: "取消", style: .default) { _ in
                            }
                            let okAction = UIAlertAction(title: "去添加", style: .default) { _ in
                                let vc = BoBAddPaymentMethodViewController()
                                vc.name = self?.homeData?.userBankAndWeiXinAndZFBPO?.name
                                self?.currentVC?.navigationController?.pushViewController(vc, animated: true)
                            }
                            // 将action添加到alertController上
                            alert.addAction(cancleAction)
                            alert.addAction(okAction)
                            // 弹出alert
                            self?.currentVC?.present(alert, animated: true, completion: nil)
                            return
                        }
                        if IMController.shared.isSetPayPassWord == false{
                            let alert = UIAlertController(title: "提示", message: "为了您的财产安全，请设置安全密码".innerLocalized(), preferredStyle: .alert)
                            // 创建UIAlertAction，用于处理用户的选择
                            let cancleAction = UIAlertAction(title: "取消", style: .default) { _ in
                            }
                            let okAction = UIAlertAction(title: "去设置", style: .default) { _ in
                                let vc = BoBChangePayPassWordViewController()
                                vc.passWordType = 0
                                self?.currentVC?.navigationController?.pushViewController(vc,animated: true)
                            }
                            // 将action添加到alertController上
                            alert.addAction(cancleAction)
                            alert.addAction(okAction)
                            // 弹出alert
                            self?.currentVC?.present(alert, animated: true, completion: nil)
                            return
                        }
                        if (self?.homeData?.advertisingName ?? "").isEmpty == true{
                            self?.creatAdNameAlertView()
                            return
                        }
                        if (self?.homeData?.needRegistrationDay ?? 0 > self?.homeData?.mregistrationDay ?? 0) || (self?.homeData?.needAuthenticationDay ?? 0 > self?.homeData?.mauthenticationDay ?? 0) || IMController.shared.certificationLevel == 0{
                            self?.warnAlertView()
                            return
                        }
                        self?.creatAd()
                    }
                    
                    
                }else if typeIndex == 1{
                    //我的广告
                    let vc = BoBMineAdvertisementViewController()
                    vc.homeData = self?.homeData
                    self?.currentVC?.navigationController?.pushViewController(vc, animated: true)
                }else{
                    //订单
                    let vc = BoBOrderListMainViewController()
                    self?.currentVC?.navigationController?.pushViewController(vc, animated: true)
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
        if index == 0{
            if buyVC == nil{
                buyVC = BoBFreeCionTypeMainViewController()
                buyVC!.currentVC = self
                buyVC!.homeData = homeData
                buyVC!.type = 1
            }
            return buyVC!
        }else{
            if sellVC == nil{
                sellVC = BoBFreeCionTypeMainViewController()
                sellVC!.currentVC = self
                sellVC!.homeData = homeData
                sellVC!.type = 2
            }
            return sellVC!
        }
    }
}
