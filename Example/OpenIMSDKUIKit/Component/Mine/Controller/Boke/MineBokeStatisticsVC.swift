//
//  MineBokeStatisticsVC.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/9/5.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import UIKit
import OUICore
import TangramKit
import DynamicColor

class MineBokeStatisticsVC: BaseTitleController {
    
    var boke : myBlogShowBlogPOModel!
    var dataNumberArr: [Int] = [0, 0, 0, 0, 0, 0, 0]
    var currentTag : Int = 1206
    var chooseTime: String = "1700-01-01"
    var isNeedRefresh: Bool = true
    
//    lazy var scrolllView: UIScrollView = {
//        let r = UIScrollView()
//        return r
//    }()
    
   
    override func initViews() {
        
        super.initViews()
//        initLinearLayoutSafeArea()
//        
//        title = R.string.localizable.blogSituation(boke.userBlogName!)
//        
//        container.tg_padding = UIEdgeInsets(top: PADDING_OUTER, left: PADDING_OUTER, bottom: PADDING_OUTER, right: PADDING_OUTER)
//        container.tg_space = 10
//        
//        container.addSubview(bokeBaseView)
//        container.addSubview(bokeDescription)
//        bokeDescription.tg_bottom.equal(14)
//        
//        container.addSubview(bokeDataView)
//        bokeDescription.tg_bottom.equal(10)
//        container.addSubview(bokeChartView)
//        container.addSubview(visitorView)
//
//        
//        container.addSubview(trueBtn)
        
        initScrollSafeArea(needNetTip: false)
        
        scrollView.delegate = self
        scrollViewContainer.tg_padding = UIEdgeInsets(top: PADDING_OUTER, left: PADDING_OUTER, bottom: PADDING_OUTER, right: PADDING_OUTER)
        scrollViewContainer.tg_space = 10
        
        title = "BlogSituation".localizedFormat(boke.base?.info?.name ?? "")
        
        
        scrollViewContainer.addSubview(bokeBaseView)
        scrollViewContainer.addSubview(bokeDescription)
        bokeDescription.tg_bottom.equal(14)
        
        scrollViewContainer.addSubview(bokeDataView)
        scrollViewContainer.tg_bottom.equal(10)
        scrollViewContainer.addSubview(bokeChartView)
        scrollViewContainer.addSubview(visitorView)

        
        scrollViewContainer.addSubview(trueBtn)
        scrollViewContainer.tg_height.equal(.fill)
        
        updateBokeBase()
        
        showBlogsSurvey()
        
        let header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(showBlogsSurvey))
        header.stateLabel?.isHidden = true
        header.lastUpdatedTimeLabel?.isHidden = true
        scrollView.mj_header = header
        view.addSubview(noNetView)
        noNetView.snp_makeConstraints { make in
            make.top.equalTo(44 + kStatusBarHeight)
            
            make.left.right.equalTo(0)
            make.height.equalTo(44)
        }
        if IMController.shared.netWorkStatus == "hasNetWork"{
            noNetView.isHidden = true
            scrollViewContainer.tg_padding = UIEdgeInsets(top: PADDING_MEDDLE, left: PADDING_OUTER, bottom: PADDING_OUTER, right: PADDING_OUTER)
        }else{
            noNetView.isHidden = false
            scrollViewContainer.tg_padding = UIEdgeInsets(top: PADDING_MEDDLE + 44, left: PADDING_OUTER, bottom: PADDING_OUTER, right: PADDING_OUTER)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(refreshNetWorkStatus(_:)), name: Notification.Name("netWorkStatus"), object: nil)
    }
    
    lazy var bokeBaseView: TGLinearLayout = {
        let r = TGLinearLayout(.horz)
        r.tg_width.equal(.fill)
        r.tg_height.equal(.wrap)
        r.tg_space = 20
        r.tg_gravity = .vert.center

        r.addSubview(bokeIcon)
        r.addSubview(bokeTitleAndStateView)
        r.addSubview(settingBtn)
    
        
        return r
    }()
    
    lazy var bokeIcon: UIImageView = {
        let r = ViewFactoryUtil.defalutImgView(R.image.place_boke_icon()!, 66)
        r.corner(12)
        r.contentMode = .scaleAspectFill
        return r
    }()
    
    lazy var bokeTitleAndStateView: TGLinearLayout = {
        let r = TGLinearLayout(.vert)
        r.tg_width.equal(.fill)
        r.tg_height.equal(.wrap)
        r.tg_space = 14
        
        r.addSubview(bokeTitleView)
        r.addSubview(bokeStateView)
        return r
    }()
    
    lazy var bokeTitleView: UILabel = {
        let r = ViewFactoryUtil.customBoldTilteLable("网站标题")
        return r
    }()
    
    lazy var bokeStateView: TGLinearLayout = {
        let r = TGLinearLayout(.horz)
        r.tg_width.equal(.fill)
        r.tg_height.equal(.wrap)
        r.tg_space = 2
        
        r.addSubview(bokeStateImage)
        r.addSubview(bokeStateLabel)
        return r
    }()
    
    lazy var bokeStateImage: UIImageView = {
        let r = ViewFactoryUtil.defalutImgView(R.image.blog_state_0()!, 14)
        return r
    }()
    
    lazy var bokeStateLabel: UILabel = {
        let r = ViewFactoryUtil.customTilteLableWrap("可访问", font: 13)
        r.textColor = .init(hexString: "#189405")
        return r
    }()
    
    lazy var settingBtn: UIButton = {
        let r = ViewFactoryUtil.imageBtn(R.image.mine_setting_icon()!, 20)
        r.addTarget(self, action: #selector(gotoSettingVC), for: .touchUpInside)
        let rank = UserDefaults.standard.integer(forKey: "vipRank")
        if rank < 3 {
            r.hide()
        }
        return r
    }()
    
    lazy var bokeDescription: UILabel = {
        let r = ViewFactoryUtil.customTilteLableWrap("这是一个位中小型企业和个人提供虚拟币和法定货币交易的应用，全球交易无障碍。", font: 13)
        r.textColor = .black333
        r.tg_width.equal(.fill)
        r.numberOfLines = 0
        r.font =  UIFont(name: "PingFangSC-Regular", size: 13)
        return r
    }()
    
    lazy var bokeDataView: TGLinearLayout = {
        let r = TGLinearLayout(.vert)
        r.tg_width.equal(.fill)
        r.tg_height.equal(.wrap)
        
        r.addSubview(dataTitle)
        r.addSubview(dataNumber)
//        r.addSubview(dataChange)
        return r
    }()
    
    lazy var dataTitle: UILabel = {
        let r = ViewFactoryUtil.customBoldTilteLable("7日访客数据".localized())
        return r
    }()
    
    lazy var dataNumber: UILabel = {
        let r = ViewFactoryUtil.customBoldTilteLable("0", font: 32)
        return r
    }()
    
    lazy var dataChange: UILabel = {
        let r = ViewFactoryUtil.normalLbael("近7日 -15%")
        r.font = UIFont(name: "PingFangSC-Medium", size: 16)
        return r
    }()
    
    
    lazy var bokeChartView: TGLinearLayout = {
        
        let r = TGLinearLayout(.vert)
        r.tg_width.equal(.fill)
        r.tg_height.equal(.wrap)
        r.tg_space = 10
        
        let min = self.dataNumberArr.min()
        let max = self.dataNumberArr.max()
        for i in 0..<7 {
            let rowView = chartRowView()
            rowView.max = max ?? 0
            rowView.min = min ?? 0
            rowView.number = self.dataNumberArr[i]
            rowView.tag = 1200 + i
            rowView.update(currentTag: currentTag)
            rowView.chooseCurrentRow = {[weak self] currenttag , time in
                
                self?.queryShowBlogsSurveyOneDay(time: time, tag: currenttag)
            }
            r.addSubview(rowView)
        }
        return r
    }()
    
    lazy var visitorView: TGLinearLayout = {
        let r = TGLinearLayout(.horz)
        r.tg_width.equal(.fill)
        r.tg_height.equal(62)
        r.tg_space = 10
        r.addSubview(friendView)
        r.addSubview(strangerView)
        
        return r
    }()
    
    lazy var friendView:  bokeVisitorNumberView = {
        let r = bokeVisitorNumberView()
        r.titleLbl.text = "今天好友访客".localized()
        r.gotoVisitorBlock = { [weak self] in
            print("goto  Friends")
            
            let rank = UserDefaults.standard.integer(forKey: "vipRank")
            if rank > 0 {
                let vc = MineBokeVisitorListVC()
                vc.vcType = .bokeVisitorFriend
                vc.boke = self?.boke
                vc.blogTime = self?.chooseTime
                self?.navigationController?.pushViewController(vc)
            } else {
                SuperToast.show(title: "VIP等级不足")
            }
            
        }
        return r
    }()
    
    lazy var strangerView:  bokeVisitorNumberView = {
        
        
        let r = bokeVisitorNumberView()
        r.titleLbl.text = "今天陌生人访客".localized()
        r.gotoVisitorBlock = { [weak self] in
            print("goto  strangers")
            
            let rank = UserDefaults.standard.integer(forKey: "vipRank")
            if rank > 1 {
                let vc = MineBokeVisitorListVC()
                vc.vcType = .bokeVisitorStranger
                vc.boke = self?.boke
                vc.blogTime = self?.chooseTime
                self?.navigationController?.pushViewController(vc)
            } else {
                SuperToast.show(title: "VIP等级不足")
            }
           
        }
        return r
    }()
    
    
    lazy var trueBtn: QMUIButton = {
        let  r = ViewFactoryUtil.primaryHalfFilletButton()
        r.tg_top.equal(20)
        r.setTitle("访问".localized(), for: .normal)
        r.addTarget(self, action: #selector(gotoBlogDetail), for: .touchUpInside)
        return r
    }()
    
    @objc func refreshNetWorkStatus(_ notidication: Notification) {
            if  let userinfo = notidication.userInfo, let netWorkStatus = userinfo["value"] as? String {
                if netWorkStatus == "hasNetWork"{
                    noNetView.isHidden = true
                    scrollViewContainer.tg_padding = UIEdgeInsets(top: PADDING_MEDDLE, left: PADDING_OUTER, bottom: PADDING_OUTER, right: PADDING_OUTER)
                }else{
                    noNetView.isHidden = false
                    scrollViewContainer.tg_padding = UIEdgeInsets(top: PADDING_MEDDLE + 44, left: PADDING_OUTER, bottom: PADDING_OUTER, right: PADDING_OUTER)
                }
            }
        }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension MineBokeStatisticsVC {
    
    @objc func gotoBlogDetail() {
//        SuperWebController.start((self.navigationController!), uri: boke.userBlogUrl)
//        SuperWebController.startAboubBlog(self.navigationController!, blogItem: boke)
        let vc = YFCustomWebViewController()
        vc.appid = boke.hash
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func updateBokeBase() {

        bokeIcon.show(boke.base?.info?.logo)
        bokeTitleView.text = boke.base?.info?.name
        bokeDescription.text = boke.base?.info?.mark
    }
    
    @objc func gotoSettingVC() {
        let vc = MineBokeNotificationSettingVC()
        vc.boke = boke
        navigationController?.pushViewController(vc)
    }
    
    func updateCharts(currentTag: Int) {
        self.currentTag = currentTag
        for i in 0...6 {
            let rowView = view.viewWithTag(1200 + i) as! chartRowView
            rowView.update(currentTag: currentTag)
        }
    }
    
   @objc func showBlogsSurvey() {
        
//        if !NetworkStatus.isReacheable {
//            noNetView.show()
//            isNeedRefresh = true
//            scrollView.mj_header?.endRefreshing()
// 
//            return
//            
//          
//        } else {
//            noNetView.hide()
//        }
        
       let paramters : [String: Any] = ["userId": boke.uid ?? "", "userBlogId": boke.id ?? ""]

        YFMineNetViewModel.queryShowBlogsSurvey(paramters: paramters) { [self] data in
            if let data = data {
//                print(data.friend, data.stranger, data.visitor7Day)
                updateUIWith(data: data)
                
            }
            scrollView.mj_header?.endRefreshing()
        } completionHandler: { errCode, errMsg in
            SuperToast.show(title: errMsg?.localized())
            self.scrollView.mj_header?.endRefreshing()
        }

    }
    
    func queryShowBlogsSurveyOneDay(time: String, tag: Int) {
        
//        if !NetworkStatus.isReacheable {
//            noNetView.show()
//            return
//        } else {
//            noNetView.hide()
//        }
        
        let paramters : [String: Any] = ["time": time, "userId": boke.uid ?? "", "userBlogId": boke.id ?? 0]
        YFMineNetViewModel.queryShowBlogsSurveyOneDay(paramters: paramters) { [self] data in
            if let data = data {
                chooseTime = time
                
                friendView.titleLbl.text =  currentTag != 1206 ?  SuperStringUtil.getWeekDay(dateTime: time, isFriend: true).localized() : "今天好友访客".localized()
                friendView.numberLbl.text = data.friend.string
                strangerView.titleLbl.text =  currentTag != 1206 ?  SuperStringUtil.getWeekDay(dateTime: time, isStranger: true).localized() : "今天陌生人好友访客".localized()
                strangerView.numberLbl.text = data.stranger.string
                
                self.updateCharts(currentTag: tag)
            }
        } completionHandler: { errCode, errMsg in
            SuperToast.show(title: errMsg?.localized())
        }
    }
    
    func updateUIWith(data: BlogSurveyData) {
        friendView.numberLbl.text = data.friend.string
        strangerView.numberLbl.text = data.stranger.string
        dataNumber.text = data.visitor7Day.string
        
        var maxN = 0
        var minN = 0
        let reversedArray = data.visitorPerDay!.reversed()
        for (index, item )in reversedArray.enumerated() {
            let tag = index + 1200
            let itemView = self.view.viewWithTag(tag) as! chartRowView
            
            maxN = max(maxN, item.i)
            minN = min(minN, item.i)
            itemView.number = item.i
            
            if index == 6 {
                self.chooseTime = item.time
            }
        }
        
        for (index, item )in reversedArray.enumerated() {
            let tag = index  + 1200
            let itemView = self.view.viewWithTag(tag) as! chartRowView
            itemView.max = maxN
            itemView.min = minN
            itemView.update(currentTag: currentTag, time: item.time)
        }
        
    }
    
    
    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print(scrollView.contentOffset.y)
//        
//        if isNeedRefresh && scrollView.contentOffset.y < -100 {
//            showBlogsSurvey()
//            isNeedRefresh = false
//        }
//        
//        if scrollView.contentOffset.y < 20 {
//            isNeedRefresh = true
//        }
//
//    }
    
    
}



class chartRowView : TGLinearLayout {
    
    var chooseCurrentRow:((_ currentTag: Int, _ blogTime: String)->())!
    var min:Int = 0
    var max:Int = 0
    var number: Int = 0
    
    var currentTag: Int = 1206
    var blogTime: String  = "1700-01-01"
    
    init() {
        super.init(frame: .zero, orientation: .horz)
        innerInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        innerInit()
    }
    
    func innerInit() {
        tg_width.equal(.fill)
        tg_height.equal(20)
        tg_space = PADDING_SMALL

        
        addSubview(dateLbl)
        addSubview(rowBg)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(chooseCurrentRowAction))
        addGestureRecognizer(tap)
    }
    
    @objc func chooseCurrentRowAction()  {
        chooseCurrentRow(tag, blogTime)
    }
    
    lazy var dateLbl: UILabel = {
        let r = UILabel()
        r.tg_width.equal(40)
        r.tg_height.equal(.fill)
        r.font = UIFont(name: "PingFangSC-Medium", size: 14)
        r.text = "周一"
        return r
    }()
    
    lazy var rowBg: TGLinearLayout = {
        let r = TGLinearLayout(.horz)
        r.tg_width.equal(.fill)
        r.tg_height.equal(.fill)
        
        r.addSubview(chartRowView)
        chartRowView.snp.makeConstraints { make in
            make.left.top.bottom.equalTo(0)
            make.width.equalTo(100)
        }
        return r
    }()
    
    lazy var chartRowView: UIView = {
        let r = UIView()
        r.backgroundColor = .init(hexString: "#F0F2F5")
//        r.backgroundColor = .init(hexString: "#388CEF")

        r.addSubview(rightLineView)
        rightLineView.snp.makeConstraints { make in
            make.right.top.bottom.equalTo(0)
            make.width.equalTo(3)
        }
        
        r.addSubview(chartNumber)
        chartNumber.snp.makeConstraints { make in
            make.right.equalTo(-10)
            make.centerY.equalToSuperview()
        }
        return r
    }()
    
    lazy var rightLineView: UIView = {
        let r  = UIView()
        r.backgroundColor = .black999
        return r
    }()
    
    lazy var chartNumber: UILabel = {
        let r = UILabel()
        r.textColor = .black666
        r.text = String(number)
        r.font = .systemFont(ofSize: TEXT_MEDDLE)
        return r
    }()
    
    func update(currentTag: Int, time: String? = nil) {
        self.chartNumber.text = String(number)
        let allWidth = (UIScreen.main.bounds.width - PADDING_OUTER * 2 - PADDING_SMALL - 40)
        var ratioNumber: CGFloat = 0
        if max == 0 {
            ratioNumber = 0
        } else if max == min {
            ratioNumber = 1
        } else {
            ratioNumber =  CGFloat(number - min) / CGFloat((max - min))
        }
        let width = allWidth * 0.2 + allWidth * 0.8 * ratioNumber
        print(ratioNumber, width)
        chartRowView.snp.updateConstraints { make in
            make.width.equalTo(width)
        }
        
        changeColorUI(currentTag: currentTag)
        
        if (time != nil) {
            blogTime = time!
            let weekDay = SuperStringUtil.getWeekDay(dateTime: time!)
            dateLbl.text = tag == 1206 ? "今天".localized() : weekDay.localized()
        }
    }
    
    func changeColorUI(currentTag: Int) {
        let isCurrent : Bool = currentTag == tag
        dateLbl.textColor = isCurrent ? .init(hexString: "#388CEF") : .black666
        chartRowView.backgroundColor = isCurrent ? .init(hexString: "#388CEF") : .init(hexString: "#F0F2F5")
        chartNumber.textColor = isCurrent ? .white : .black666
    }
}

class bokeVisitorNumberView: TGLinearLayout {
    
    var gotoVisitorBlock:(()->())!
    
    init() {
        super.init(frame: .zero, orientation: .horz)
        innerInit()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(gotoVisitorViewAction))
        addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        innerInit()
        
        
    }
    
    func innerInit() {
        tg_padding = UIEdgeInsets(top: PADDING_MEDDLE, left: PADDING_MEDDLE, bottom: PADDING_MEDDLE, right: PADDING_MEDDLE)
        tg_width.equal(.fill)
        tg_height.equal(.fill)
        tg_space = 12
        tg_gravity = .vert.center
        corner(8)
        border(.init(hexString: "#CCCCCC"))
        
        addSubview(leftView)
        addSubview(rightImg)
    }
    
    lazy var leftView: TGLinearLayout = {
        let r = TGLinearLayout(.vert)
        r.tg_width.equal(.fill)
        r.tg_height.equal(.wrap)
        r.tg_space = 10
        
        r.addSubview(titleLbl)
        r.addSubview(numberLbl)
        
        return r
    }()
    
    lazy var titleLbl: UILabel = {
        let r = ViewFactoryUtil.normalLbael("今日好友访客")
        r.tg_width.equal(.fill)
        r.tg_height.equal(.wrap)
        r.font = UIFont(name: "PingFangSC-Medium", size: 12)
        r.textColor = .black666
        return r
    }()
    
    lazy var numberLbl: UILabel = {
        let r = ViewFactoryUtil.customBoldTilteLable("0", font: 18)
        r.tg_width.equal(.fill)
        r.tg_height.equal(16)
        return r
    }()
    
    lazy var rightImg: UIImageView = {
        let r = ViewFactoryUtil.defalutImgView(R.image.arrow()!, 16)
        return r
    }()
    
    @objc func gotoVisitorViewAction() {
        gotoVisitorBlock()
    }
    
}
