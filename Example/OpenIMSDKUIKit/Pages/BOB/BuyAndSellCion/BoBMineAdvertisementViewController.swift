//
//  BoBMineAdvertisementViewController.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/12/18.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Foundation
import TangramKit
import OUICore
class BoBMineAdvertisementViewController:BaseTitleController {
    var homeData:BoBBuyAndSellHomeData?
    var chooseAdType:Int = 0 //0全部，1出售，2购买
    var chooseAdStatus:Int = 0 //0全部，1上架中，2已下架
    var page:Int = 1
    var currency:String = "C" //币种
    var listArray:[BoBMineAdList] = []
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func initViews() {
        super.initViews()
        setBackGroundColor(.colorBackgroundAPP)
        initTableViewSafeAre()
        title = "我的广告"
        addRightTextButton("创建广告", color: .primaryColor)
        container.addSubview(headView)
        superFooterContainerContainer.tg_bottom.equal(0)
        headView.snp_makeConstraints { make in
            make.left.right.top.equalTo(0)
            make.height.equalTo(78)
        }
        tableView.tg_top.equal(78)
        tableView.register(BoBMineAdvertisementCell.self, forCellReuseIdentifier: BoBMineAdvertisementCell.className)
        let header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(refreshData))

        tableView.mj_header = header
        let footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(loadMoreData))
        footer.isAutomaticallyRefresh = false
        footer.setTitle("点击或上拉加载更多".innerLocalized(), for: .idle)
        footer.setTitle("正在加载更多的数据...".innerLocalized(), for: .refreshing)
        tableView.mj_footer = footer
        tableView.mj_header?.beginRefreshing()
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshPaymentList(_:)), name: Notification.Name("refreshPaymentList"), object: nil)
    }
    deinit {
        // 移除所有通知监听
        NotificationCenter.default.removeObserver(self)
    }
    @objc func refreshPaymentList(_ notidication: Notification) {
        if let userinfo = notidication.userInfo, let data = userinfo["homeData"] as? BoBBuyAndSellHomeData {
            homeData = data
        }
    }
    override func rightBtnClick(_ sender: QMUIButton){
        if IMController.shared.certificationLevel == 0 {
            let alert = UIAlertController(title: "提示", message: "请先进行实名认证".innerLocalized(), preferredStyle: .alert)
            // 创建UIAlertAction，用于处理用户的选择
            let cancleAction = UIAlertAction(title: "取消", style: .default) { _ in
            }
            let okAction = UIAlertAction(title: "去认证", style: .default) { _ in
                let vc =  BoBRealNameMainViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            }
            // 将action添加到alertController上
            alert.addAction(cancleAction)
            alert.addAction(okAction)
            // 弹出alert
            self.present(alert, animated: true, completion: nil)
            return
        }
        if homeData?.payment == false{
            let alert = UIAlertController(title: "提示", message: "您还没有支付方式，请添加支付方式".innerLocalized(), preferredStyle: .alert)
            // 创建UIAlertAction，用于处理用户的选择
            let cancleAction = UIAlertAction(title: "取消", style: .default) { _ in
            }
            let okAction = UIAlertAction(title: "去添加", style: .default) { _ in
                let vc = BoBAddPaymentMethodViewController()
                vc.name = self.homeData?.userBankAndWeiXinAndZFBPO?.name
                self.navigationController?.pushViewController(vc, animated: true)
            }
            // 将action添加到alertController上
            alert.addAction(cancleAction)
            alert.addAction(okAction)
            // 弹出alert
            self.present(alert, animated: true, completion: nil)
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
                self.navigationController?.pushViewController(vc,animated: true)
            }
            // 将action添加到alertController上
            alert.addAction(cancleAction)
            alert.addAction(okAction)
            // 弹出alert
            self.present(alert, animated: true, completion: nil)
            return
        }
        if (homeData?.advertisingName ?? "").isEmpty == true{
            creatAdNameAlertView()
            return
        }
        if (homeData?.needRegistrationDay ?? 0 > homeData?.mregistrationDay ?? 0) || (homeData?.needAuthenticationDay ?? 0 > homeData?.mauthenticationDay ?? 0) || IMController.shared.certificationLevel == 0{
            warnAlertView()
            return
        }
        creatAd()
    }
    func creatAd(){
        let choosePushAdTypeView = BoBChoosePushAdTypeView()
        choosePushAdTypeView.tg_width.equal(.fill)
        choosePushAdTypeView.tg_height.equal(193)
        choosePushAdTypeView.drawUI(array: ["购买","出售"])
        choosePushAdTypeView.choosePushAdTypeBlock = { [weak self] typeIndex in
            let vc = BoBCreatAdvertisementViewController()
            vc.homeData = self?.homeData
            vc.advertisementType = typeIndex == 0 ? 2 :1
            vc.updateAdData = { [weak self] adDetailData in
                self?.refreshData()
            }
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        GKCover.cover(from: self.view.window, contentView: choosePushAdTypeView, style: .translucent, showStyle: .bottom, showAnimStyle: .bottom, hideAnimStyle: .bottom, notClick: false)
    }
    func warnAlertView(){
        let warnView = BoBCreatAdWarnAlertView()
        warnView.tg_width.equal(290)
        warnView.tg_height.equal(.wrap)
        warnView.tg_centerY.equal(0)
        warnView.bindData(homeData: homeData)
        GKCover.cover(from: self.view.window, contentView: warnView, style: .translucent, showStyle: .center, showAnimStyle: .bottom, hideAnimStyle: .bottom, notClick: true)
    }
    func creatAdNameAlertView(){
        let adNameView = BoBCreatAdNameAlertView()
        adNameView.tg_width.equal(293)
        adNameView.tg_height.equal(.wrap)
        adNameView.bindData(adName: homeData?.advertisingName)
        adNameView.updateAdvertisingName = { [weak self] adName in
            self?.homeData?.advertisingName = adName
            self?.adNameLabel.textColor = .black333
            self?.adNameLabel.text = adName
        }
        GKCover.cover(from: self.view.window, contentView: adNameView, style: .translucent, showStyle: .center, showAnimStyle: .bottom, hideAnimStyle: .bottom, notClick: true)
    }
    @objc func refreshData(){
        loadData(pageNum:1)
    }
    @objc func loadMoreData(){
        loadData(pageNum: page+1)
    }
    func loadData(pageNum:Int){
        BoBBuyAndSellCionModel.MyAdvertisementListRequest(currency: currency,type: chooseAdType,state: chooseAdStatus,pageNum: pageNum, pageSize: 20) { data in
            self.page = pageNum
            if pageNum == 1{
                self.listArray.removeAll()
            }
            self.listArray.append(contentsOf: data)
            self.tableView.reloadData()
            self.tableView.mj_header?.endRefreshing()
            if data.count < 20{
                if var footer = self.tableView.mj_footer as? MJRefreshAutoNormalFooter {
                    footer.setTitle("加载完成，没有更多了...".innerLocalized(), for: .noMoreData)
                    footer.stateLabel?.textColor = .init(hexString: "#CCCCCC")
                    footer.stateLabel?.font = .mediumFont(16)
                    footer.endRefreshingWithNoMoreData()
                }
            }else{
                self.tableView.mj_footer?.endRefreshing()
            }
        }completionHandler: {errCode,errMsg in
            SuperToast.show(title: String(errCode) + "：" + String(errCode).localized())
            self.tableView.mj_header?.endRefreshing()
            self.tableView.mj_footer?.endRefreshing()

        }
    }
    lazy var headView: UIView = {
        let r = UIView()
        r.addSubview(adNameView)
        r.addSubview(adTypeView)
        r.addSubview(adStatusView)
        adNameView.snp_makeConstraints { make in
            make.left.right.top.equalTo(0)
            make.height.equalTo(44)
        }
        adTypeView.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.height.equalTo(32)
            make.top.equalTo(adNameView.snp_bottom)
        }
        adStatusView.snp_makeConstraints { make in
            make.left.equalTo(adTypeView.snp_right).offset(20)
            make.top.height.equalTo(adTypeView)
        }
        return r
    }()
    lazy var adNameView: UIView = {
        let r = UIView()
        r.backgroundColor = .init(hexString: "#EAEAEA")
        r.addSubview(adNameTitleLabel)
        r.addSubview(adNameLabel)
        r.addSubview(editBtn)
        adNameTitleLabel.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.centerY.equalTo(r)
        }
        adNameLabel.snp_makeConstraints { make in
            make.left.equalTo(adNameTitleLabel.snp_right)
            make.centerY.equalTo(r)
            make.right.equalTo(editBtn.snp_left).offset(-10)
        }
        editBtn.snp_makeConstraints { make in
            make.right.equalTo(-16)
            make.centerY.equalTo(r)
            make.height.equalTo(24)
            make.width.equalTo(44)
        }
        let tap = UITapGestureRecognizer()
        tap.rx.event.subscribe {[weak self]  _ in
            self?.creatAdNameAlertView()
        }.disposed(by: rx.disposeBag)
        r.addGestureRecognizer(tap)
        return r
    }()
    lazy var adNameTitleLabel: UILabel = {
        let r = UILabel()
        r.textColor = .black333
        r.font = .regularFont(16)
        r.text = "广告商名称  |  "
        return r
    }()
    lazy var adNameLabel: UILabel = {
        let r = UILabel()
        r.textColor = (homeData?.advertisingName ?? "").length > 0 ? .black333 : .black999
        r.font = .regularFont(16)
        r.text = (homeData?.advertisingName ?? "").length > 0 ? (homeData?.advertisingName ?? "") :"未设置广告商名称"
        return r
    }()
    lazy var editBtn: QMUIButton = {
        let r = QMUIButton()
        r.backgroundColor = .primaryColor
        r.setTitle((homeData?.advertisingName ?? "").isEmpty ? "创建":"修改", for: .normal)
        r.setTitleColor(.white, for: .normal)
        r.titleLabel?.font = .regularFont(12)
        r.isUserInteractionEnabled = false
        r.corner(12)
        return r
    }()
    lazy var adTypeView: UIView = {
        let r = UIView()
        r.addSubview(adTypeLabel)
        adTypeLabel.snp_makeConstraints { make in
            make.left.centerY.equalTo(r)
            make.height.equalTo(16)
            make.right.equalTo(r)
        }
        let tap = UITapGestureRecognizer()
        tap.rx.event.subscribe {[weak self]  _ in
            let choosePushAdTypeView = BoBChoosePushAdTypeView()
            choosePushAdTypeView.tg_width.equal(.fill)
            choosePushAdTypeView.tg_height.equal(245)
            let array = ["全部","出售","购买"]
            choosePushAdTypeView.drawUI(array:array )
            choosePushAdTypeView.choosePushAdTypeBlock = { [weak self] typeIndex in
                self?.chooseAdType = typeIndex
                if typeIndex == 0{
                    self?.adTypeLabel.textColor = .black999
                    self?.adTypeLabel.attributedText = self?.getAttribute(str: "全部类型", image: UIImage(named: "mine_buy_and_sell_free_choose_icon")!)
                }else{
                    self?.adTypeLabel.textColor = .primaryColor
                    self?.adTypeLabel.attributedText = self?.getAttribute(str: array[typeIndex], image: UIImage(named: "mine_red_packet_choose_type_icon")!)
                }
                self?.refreshData()
            }
            GKCover.cover(from: self?.view.window, contentView: choosePushAdTypeView, style: .translucent, showStyle: .bottom, showAnimStyle: .bottom, hideAnimStyle: .bottom, notClick: false)
        }.disposed(by: rx.disposeBag)
        r.addGestureRecognizer(tap)
        return r
    }()
    private lazy var adTypeLabel: UILabel = {
        let r = UILabel()
        r.font = .regularFont(14)
        r.textColor = .black999
        r.attributedText = getAttribute(str: "全部类型", image: UIImage(named: "mine_buy_and_sell_free_choose_icon")!)
        return r
    }()
    private lazy var adStatusView: UIView = {
        let r = UIView()
        r.addSubview(adStatusLabel)
        adStatusLabel.snp_makeConstraints { make in
            make.left.centerY.equalTo(r)
            make.height.equalTo(16)
            make.right.equalTo(r)
        }
        let tap = UITapGestureRecognizer()
        tap.rx.event.subscribe {[weak self]  _ in
            let choosePushAdTypeView = BoBChoosePushAdTypeView()
            choosePushAdTypeView.tg_width.equal(.fill)
            choosePushAdTypeView.tg_height.equal(245)
            let array = ["全部","上架中","已下架"]
            choosePushAdTypeView.drawUI(array:array )
            choosePushAdTypeView.choosePushAdTypeBlock = { [weak self] typeIndex in
                self?.chooseAdType = typeIndex
                if typeIndex == 0{
                    self?.adStatusLabel.textColor = .black999
                    self?.adStatusLabel.attributedText = self?.getAttribute(str: "全部状态", image: UIImage(named: "mine_buy_and_sell_free_choose_icon")!)
                }else{
                    self?.adStatusLabel.textColor = .primaryColor
                    self?.adStatusLabel.attributedText = self?.getAttribute(str: array[typeIndex], image: UIImage(named: "mine_red_packet_choose_type_icon")!)
                }
                self?.refreshData()
            }
            GKCover.cover(from: self?.view.window, contentView: choosePushAdTypeView, style: .translucent, showStyle: .bottom, showAnimStyle: .bottom, hideAnimStyle: .bottom, notClick: false)
        }.disposed(by: rx.disposeBag)
        r.addGestureRecognizer(tap)
        return r
    }()
    private lazy var adStatusLabel: UILabel = {
        let r = UILabel()
        r.font = .regularFont(14)
        r.textColor = .black999
        r.attributedText = getAttribute(str: "全部状态", image: UIImage(named: "mine_buy_and_sell_free_choose_icon")!)
        return r
    }()
    func getAttribute(str:String,image:UIImage) -> NSMutableAttributedString{
        let attachment = NSTextAttachment()
        attachment.image = image
        attachment.bounds = CGRect(x: 0, y: 1, width: 10, height: 10)
        let str1 = str + " "
        let attributedString = NSMutableAttributedString(string: str1)
        let attachmentString = NSAttributedString(attachment: attachment)
        attributedString.insert(attachmentString, at: str1.length)
        return attributedString
    }
}
extension BoBMineAdvertisementViewController{
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listArray.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BoBMineAdvertisementCell", for: indexPath) as! BoBMineAdvertisementCell
        let item = listArray[indexPath.row]
        cell.cionImageView.sd_setImage(with: URL(string: item.icon))
        cell.adTypeNameLabel.text = (item.advertisingType == 1 ? "出售":"购买") + " " + (item.advertisingCurrency ?? "C")
        if item.advertisingState == 1{
            //上架中
            cell.statusLabel.text = "上架中"
            cell.statusLabel.backgroundColor = .init(hexString: "#3ACC9B")
        }else{
            //已下架
            cell.statusLabel.text = "已下架"
            cell.statusLabel.backgroundColor = .init(hexString: "#FFA756")
        }
//        cell.exchangeRateLabel.text = item.exchangeRateType == 1 ? String(format: "¥%.2f", item.floatingIndex ?? 1.00) : String(format: "¥%.2f", item.setExchangeRate ?? 1.00)
        cell.exchangeRateLabel.text = String(format: "¥%.2f", item.setExchangeRate ?? 1.00)
        cell.countLabel.text = String(format: "%.2f ", item.surplusQuantity ?? 0.00) +  (item.advertisingCurrency ?? "C")
        cell.limitCountLabel.text = String(format: "%.2f-%.2f CNY", item.quotaMin ?? 0.00,item.quotaMax ?? 0.00)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 137
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = listArray[indexPath.row]
        let chooseTypeView = BoBChoosePushAdTypeView()
        chooseTypeView.tg_width.equal(.fill)
        chooseTypeView.tg_height.equal(item.advertisingState == 1 ? 141:245)
        let array = item.advertisingState == 1 ? ["下架"]:["编辑","上架","删除"]
        chooseTypeView.drawUI(array:array )
        chooseTypeView.choosePushAdTypeBlock = { [weak self] typeIndex in
            if item.advertisingState == 1{
                //上架中
                if typeIndex == 0{
                    //去下架
                    self?.mineAdvertisementChange(type: 0, indexPath: indexPath)
                }
            }else{
                if typeIndex == 0{
                    //去编辑
                    if self?.homeData?.payment == false{
                        let alert = UIAlertController(title: "提示", message: "您还没有支付方式，请添加支付方式".innerLocalized(), preferredStyle: .alert)
                        // 创建UIAlertAction，用于处理用户的选择
                        let cancleAction = UIAlertAction(title: "取消", style: .default) { _ in
                        }
                        let okAction = UIAlertAction(title: "去添加", style: .default) { _ in
                            let vc = BoBAddPaymentMethodViewController()
                            vc.name = self?.homeData?.userBankAndWeiXinAndZFBPO?.name
                            self?.navigationController?.pushViewController(vc, animated: true)
                        }
                        // 将action添加到alertController上
                        alert.addAction(cancleAction)
                        alert.addAction(okAction)
                        // 弹出alert
                        self?.present(alert, animated: true, completion: nil)
                        return
                    }
                    
                    let vc = BoBCreatAdvertisementViewController()
                    vc.adDetailData = item
                    vc.homeData = self?.homeData
                    vc.updateAdData = { [weak self] adDetailData in
                        self?.listArray[indexPath.row] = adDetailData
                        self?.tableView.reloadRows(at: [indexPath], with: .none)
                    }
                    self?.navigationController?.pushViewController(vc, animated: true)
                    
                }else if typeIndex == 1{
                    //去上架
                    self?.mineAdvertisementChange(type: 1, indexPath: indexPath)
                }else if typeIndex == 2{
                    //去删除
                    let alert = UIAlertController(title: "提示", message: "是否确定删除该广告？", preferredStyle: .alert)
                    // 创建UIAlertAction，用于处理用户的选择
                    let cancleAction = UIAlertAction(title: "取消", style: .default) { _ in
                    }
                    let okAction = UIAlertAction(title: "确定", style: .default) { _ in
                        self?.mineAdvertisementChange(type: 2, indexPath: indexPath)
                    }
                    // 将action添加到alertController上
                    alert.addAction(cancleAction)
                    alert.addAction(okAction)
                    // 弹出alert
                    self?.present(alert, animated: true, completion: nil)
                }
            }
        }
        GKCover.cover(from: self.view.window, contentView: chooseTypeView, style: .translucent, showStyle: .bottom, showAnimStyle: .bottom, hideAnimStyle: .bottom, notClick: false)
    }
    func mineAdvertisementChange(type:Int,indexPath: IndexPath){
        let item = listArray[indexPath.row]
        BoBBuyAndSellCionModel.MyAdvertisementChangeRequest(type: type, code: item.code ?? ""){[weak self] errCode, errMsg in
            if errCode == 620000{
                if type == 0{
                    SuperToast.show(title:"下架成功")
                    item.advertisingState = 2
                    self?.listArray[indexPath.row] = item
                    self?.tableView.reloadRows(at: [indexPath], with: .none)
                }else if type == 1{
                    SuperToast.show(title:"上架成功")
                    item.advertisingState = 1
                    self?.listArray[indexPath.row] = item
                    self?.tableView.reloadRows(at: [indexPath], with: .none)
                }else if type == 2{
                    SuperToast.show(title:"删除成功")
                    self?.listArray.remove(at: indexPath.row)
                    self?.tableView.reloadData()
                }
                
            }else{
                SuperToast.show(title: String(errCode) + "：" + String(errCode).localized())
            }
        }
    }

}
