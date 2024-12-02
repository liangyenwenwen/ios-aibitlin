//
//  BoBMineAssetsViewController.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/12/2.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Foundation
import TangramKit
import JXSegmentedView
import OUICore
extension JXPagingListContainerView: JXSegmentedViewListContainer {}

class BoBMineAssetsViewController: BaseTitleController {
    var quantityOfMoneyPOS:QuantityOfMoneyPOS?
    
    var pagingView: JXPagingView!
    var segmentedView: JXSegmentedView!
    var titles = ["全部","转账","收款","购买","出售","红包","调账","私聊转账","群聊转账"]
    
    
    var segmentedDataSource: JXSegmentedTitleDataSource!

    override func initViews() {
        
        super.initViews()
        view.backgroundColor = .colorBackgroundAPP
        initLinearLayoutSafeArea()
        title = quantityOfMoneyPOS?.currency
        container.tg_padding = UIEdgeInsets(top: 0, left: PADDING_OUTER, bottom: 82, right: PADDING_OUTER)
        container.tg_bottom.equal(50+10)
        view.addSubview(bottomView)
        bottomView.snp_makeConstraints { make in
            make.left.right.bottom.equalTo(0)
            make.top.equalTo(container.snp_bottom).offset(10)
        }

        //配置数据源
        segmentedDataSource = JXSegmentedTitleDataSource()
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
        segmentedView = JXSegmentedView(frame: CGRect(x: 0, y: 0, width: kScreenWidth-32, height: 60))
        segmentedView.dataSource = segmentedDataSource
        segmentedView.indicators = [indicator]
        segmentedView.backgroundColor = UIColor.white
        let corner: UIRectCorner = [.topLeft, .topRight]
        //frame可以先计算完成  避免圆角拉伸
        let rect = CGRect(x: 0, y: 0, width: kScreenWidth - 32, height: 60)
        let path: UIBezierPath = UIBezierPath(roundedRect: rect, byRoundingCorners: corner, cornerRadii: CGSize(width: 14, height: 14))
        let maskLayer: CAShapeLayer = CAShapeLayer()
        maskLayer.frame = rect;
        maskLayer.path = path.cgPath
        segmentedView.layer.mask = maskLayer;
        
        
        
        pagingView = JXPagingView(delegate: self)
        pagingView.corner(14)
        pagingView.backgroundColor = .colorBackgroundAPP

        container.addSubview(pagingView)
        
        
        segmentedView.listContainer = pagingView.listContainerView
        pagingView.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.top.bottom.equalTo(0)
        }
        segmentedView.addSubview(lineView)
        lineView.snp_makeConstraints { make in
            make.left.right.equalTo(0)
            make.bottom.equalTo(segmentedView)
            make.height.equalTo(1)
        }

    }
    lazy var headView: BoBMineAssetsViewHeadView = {
        let r = BoBMineAssetsViewHeadView()
        r.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: 240)
        r.bindData(quantityOfMoneyPOS: quantityOfMoneyPOS)
        return r
    }()
    lazy var lineView: UIView = {
        let r = UIView()
        r.backgroundColor = .colorDivider
        return r
    }()
    lazy var bottomView: UIView = {
        let r = UIView()
        r.backgroundColor = .white
        r.addSubview(buyCoinBtn)
        r.addSubview(paymentBtn)
        r.addSubview(transferAccountsBtn)
        buyCoinBtn.snp_makeConstraints { make in
            make.top.left.equalTo(0)
            make.width.equalTo(kScreenWidth/3.0)
            make.height.equalTo(48)
        }
        paymentBtn.snp_makeConstraints { make in
            make.top.width.height.equalTo(buyCoinBtn)
            make.left.equalTo(buyCoinBtn.snp_right)
        }
        transferAccountsBtn.snp_makeConstraints { make in
            make.top.width.height.equalTo(buyCoinBtn)
            make.right.equalTo(0)
        }
        let line1 = UIView()
        line1.backgroundColor = .init(hexString: "#EAEAEA")
        r.addSubview(line1)
        line1.snp_makeConstraints { make in
            make.top.left.height.equalTo(paymentBtn)
            make.width.equalTo(1)
        }
        let line2 = UIView()
        line2.backgroundColor = .init(hexString: "#EAEAEA")
        r.addSubview(line2)
        line2.snp_makeConstraints { make in
            make.top.left.height.equalTo(transferAccountsBtn)
            make.width.equalTo(1)
        }
        return r
    }()
    lazy var buyCoinBtn: UIButton = {
        let r = UIButton()
        r.setImage(UIImage(named: "mine_assets_buy_coin_icon"), for: .normal)
        r.setTitle("买卖币", for: .normal)
        r.titleLabel?.font = .regularFont(16)
        r.setTitleColor(.primaryColor, for: .normal)
        r.contentHorizontalAlignment = .center
        // 间距可能需要根据图片和文字大小调整
        let spacing: CGFloat = 10.0
        r.titleEdgeInsets = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: 0)
        r.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: spacing)
        r.rx.tap.subscribe(onNext: { [self] in
            SuperToast.show(title: "开发中")
        }).disposed(by: rx.disposeBag)
        return r
    }()
    lazy var paymentBtn: UIButton = {
        let r = UIButton()
        r.setImage(UIImage(named: "mine_assets_payment_icon"), for: .normal)
        r.setTitle("收款", for: .normal)
        r.titleLabel?.font = .regularFont(16)
        r.setTitleColor(.primaryColor, for: .normal)
        r.contentHorizontalAlignment = .center
        // 间距可能需要根据图片和文字大小调整
        let spacing: CGFloat = 10.0
        r.titleEdgeInsets = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: 0)
        r.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: spacing)
        r.rx.tap.subscribe(onNext: { [self] in
            self.gotoController(BoBReceivePaymentViewController.self)
            
        }).disposed(by: rx.disposeBag)
        return r
    }()
    lazy var transferAccountsBtn: UIButton = {
        let r = UIButton()
        r.setImage(UIImage(named: "mine_assets_transfer_accounts_icon"), for: .normal)
        r.setTitle("转账", for: .normal)
        r.titleLabel?.font = .regularFont(16)
        r.setTitleColor(.primaryColor, for: .normal)
        r.contentHorizontalAlignment = .center
        // 间距可能需要根据图片和文字大小调整
        let spacing: CGFloat = 10.0
        r.titleEdgeInsets = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: 0)
        r.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: spacing)
        r.rx.tap.subscribe(onNext: { [self] in
            self.gotoController(BoBTransferAccountsViewController.self)
        }).disposed(by: rx.disposeBag)
        return r
    }()
}
extension BoBMineAssetsViewController: JXPagingViewDelegate {

    func tableHeaderViewHeight(in pagingView: JXPagingView) -> Int {
        return 240
    }

    func tableHeaderView(in pagingView: JXPagingView) -> UIView {
        return headView
    }

    func heightForPinSectionHeader(in pagingView: JXPagingView) -> Int {
        return 60
    }

    func viewForPinSectionHeader(in pagingView: JXPagingView) -> UIView {
        return segmentedView
    }

    func numberOfLists(in pagingView: JXPagingView) -> Int {
        return titles.count
    }

    func pagingView(_ pagingView: JXPagingView, initListAtIndex index: Int) -> JXPagingViewListViewDelegate {
        let list = PagingListBaseView()
        list.timeStart = ""
        list.timeEnd = ""
        list.chooseType = index
        list.currentVC = self
        list.beginFirstRefresh()
        return list
    }
}


