//
//  BoBFreeBuyAndSellView.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/12/11.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Foundation
import JXSegmentedView
import OUICore

class BoBFreeBuyAndSellView: UIView {
    var currentVC:UIViewController?
    var tableView: UITableView!
    var page:Int = 1
    var chooseMoney:String = ""
    var isChooseAll:Bool = true
    var isChooseBank:Bool = false
    var isChooseAli:Bool = false
    var isChooseWx:Bool = false
    var listArray = ["我们","第一个","个体户","你干啥","想去哪","哪也不去","去浙江省杭州市西湖区"]
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        addSubview(moneyCountView)
        addSubview(paymentView)
        moneyCountView.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.height.equalTo(36)
            make.top.equalTo(0)
        }
        paymentView.snp_makeConstraints { make in
            make.left.equalTo(moneyCountView.snp_right).offset(20)
            make.top.height.equalTo(moneyCountView)
        }
        tableView = UITableView(frame: frame, style: .plain)
        tableView.backgroundColor = UIColor.clear
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.register(BoBFreeBuyAndSellCell.self, forCellReuseIdentifier: "BoBFreeBuyAndSellCell")
        addSubview(tableView)
        
        let header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(refreshData))

        tableView.mj_header = header
        let footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(loadMoreData))
        footer.isAutomaticallyRefresh = false
        footer.setTitle("点击或上拉加载更多".innerLocalized(), for: .idle)
        footer.setTitle("正在加载更多的数据...".innerLocalized(), for: .refreshing)

        tableView.mj_footer = footer
        
        
        tableView.mj_header?.beginRefreshing()
        tableView.snp_makeConstraints { make in
            make.left.right.bottom.equalTo(0)
            make.top.equalTo(moneyCountView.snp_bottom)
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    @objc func refreshData(){
        loadData(pageNum:1)
    }
    @objc func loadMoreData(){
        loadData(pageNum: page+1)
    }
    func loadData(pageNum:Int){
        listArray = ["我们","第一个","个体户","你干啥","想去哪","哪也不去","去浙江省杭州市西湖区"]
        tableView.reloadData()
        tableView.mj_header?.endRefreshing()
        tableView.mj_footer?.endRefreshing()
//        BoBPaymentModel.GetMyBillList(tpye: chooseType, timeStart: timeStart, timeEnd: timeEnd, currency: "C", pageSize: 20, pageNum: pageNum) { data in
//            self.page = pageNum
//            if pageNum == 1{
//                self.listArray.removeAll()
//            }
//            self.listArray.append(contentsOf: data)
//            self.tableView.reloadData()
//            self.tableView.mj_header?.endRefreshing()
//            if data.count < 20{
//                if var footer = self.tableView.mj_footer as? MJRefreshAutoNormalFooter {
//                    footer.setTitle("加载完成，没有更多了...".innerLocalized(), for: .noMoreData)
//                    footer.stateLabel?.textColor = .init(hexString: "#CCCCCC")
//                    footer.stateLabel?.font = .mediumFont(16)
//                    footer.endRefreshingWithNoMoreData()
//                }
//            }else{
//                self.tableView.mj_footer?.endRefreshing()
//            }
//        }completionHandler: {errCode,errMsg in
//            SuperToast.show(title: errMsg)
//            self.tableView.mj_header?.endRefreshing()
//            self.tableView.mj_footer?.endRefreshing()
//
//        }
    }
    lazy var moneyCountView: UIView = {
        let r = UIView()
        r.addSubview(moneyLabel)
        moneyLabel.snp_makeConstraints { make in
            make.left.centerY.equalTo(r)
            make.height.equalTo(16)
            make.right.equalTo(r)
        }
        let tap = UITapGestureRecognizer()
        tap.rx.event.subscribe {  _ in
            
            let chooseTypeView = BoBFreeFilterMoneyView(titles:["100","300","500","700","1000","3000","7000","10000","30000"],defaultMoney:self.chooseMoney)
            chooseTypeView.tg_width.equal(.fill)
            chooseTypeView.tg_height.equal(370)
            chooseTypeView.chooseMoneyBlock = {[weak self] money in
                self?.chooseMoney = money
                if money.isEmpty{
                    self?.moneyLabel.textColor = .black999
                    self?.moneyLabel.attributedText = self?.getAttribute(str: "金额", image: UIImage(named: "mine_buy_and_sell_free_choose_icon")!)
                }else{
                    self?.moneyLabel.textColor = .primaryColor
                    self?.moneyLabel.attributedText = self?.getAttribute(str: "¥" + money, image: UIImage(named: "mine_red_packet_choose_type_icon")!)
                }
                self?.refreshData()
            }
            GKCover.cover(from: self.currentVC?.view.window, contentView: chooseTypeView, style: .translucent, showStyle: .bottom, showAnimStyle: .bottom, hideAnimStyle: .bottom, notClick: false)
        }.disposed(by: rx.disposeBag)
        r.addGestureRecognizer(tap)
        return r
    }()
    private lazy var moneyLabel: UILabel = {
        let r = UILabel()
        r.font = .regularFont(14)
        r.textColor = .black999
        //        mine_red_packet_choose_type_icon
        r.attributedText = getAttribute(str: "金额", image: UIImage(named: "mine_buy_and_sell_free_choose_icon")!)
        
        return r
    }()
    lazy var paymentView: UIView = {
        let r = UIView()
        r.addSubview(paymentLabel)
        paymentLabel.snp_makeConstraints { make in
            make.left.centerY.equalTo(r)
            make.height.equalTo(16)
            make.right.equalTo(r)
        }
        let tap = UITapGestureRecognizer()
        tap.rx.event.subscribe {[weak self]  _ in
            let chooseTypeView = BoBFreeFilterPaymentMethodView(titles:["全部","银行卡","支付宝","微信"],isChooseAllBtn: self!.isChooseAll,isChooseBankBtn: self!.isChooseBank,isChooseAliBtn: self!.isChooseAli,isChooseWxBtn: self!.isChooseWx)
            chooseTypeView.tg_width.equal(.fill)
            chooseTypeView.tg_height.equal(265)
            chooseTypeView.chooseMoneyBlock = {[weak self] isChooseAllBtn, isChooseBankBtn,isChooseAliBtn,isChooseWxBtn in
                self?.isChooseAll = isChooseAllBtn
                self?.isChooseBank = isChooseBankBtn
                self?.isChooseAli = isChooseAliBtn
                self?.isChooseWx = isChooseWxBtn
                if self?.isChooseAll == true{
                    self?.paymentLabel.textColor = .black999
                    self?.paymentLabel.attributedText = self?.getAttribute(str: "支付方式", image: UIImage(named: "mine_buy_and_sell_free_choose_icon")!)
                }else{
                    self?.paymentLabel.textColor = .primaryColor
                    var str = isChooseBankBtn ? "银行卡" :""
                    if str.isEmpty{
                        str = isChooseAliBtn ? "支付宝" :""
                    }else{
                        str = str + (isChooseAliBtn ? "、支付宝" :"")
                    }
                    if str.isEmpty{
                        str = isChooseWxBtn ? "微信" :""
                    }else{
                        str = str + (isChooseWxBtn ? "、微信" :"")
                    }
                    self?.paymentLabel.attributedText = self?.getAttribute(str: str, image: UIImage(named: "mine_red_packet_choose_type_icon")!)
                }
                self?.refreshData()
            }
            GKCover.cover(from: self?.currentVC?.view.window, contentView: chooseTypeView, style: .translucent, showStyle: .bottom, showAnimStyle: .bottom, hideAnimStyle: .bottom, notClick: false)
        }.disposed(by: rx.disposeBag)
        r.addGestureRecognizer(tap)
        return r
    }()
    private lazy var paymentLabel: UILabel = {
        let r = UILabel()
        r.font = .regularFont(14)
        r.textColor = .black999
//        mine_red_packet_choose_type_icon
        r.attributedText = getAttribute(str: "支付方式", image: UIImage(named: "mine_buy_and_sell_free_choose_icon")!)
        return r
    }()
    func getAttribute(str:String,image:UIImage) -> NSMutableAttributedString{
        let attachment = NSTextAttachment()
        attachment.image = image
        attachment.bounds = CGRect(x: 0, y: 1, width: 10, height: 10)
        let str1 = str + " "
        let attributedString = NSMutableAttributedString(string: str1)
        let attachmentString = NSAttributedString(attachment: attachment)
        
//        attributedString.append(attachmentString)
        attributedString.insert(attachmentString, at: str1.length)
        return attributedString
    }
}
extension BoBFreeBuyAndSellView: UITableViewDataSource, UITableViewDelegate {
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return listArray.count
}

func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "BoBFreeBuyAndSellCell", for: indexPath) as! BoBFreeBuyAndSellCell
    let name = listArray[indexPath.row]
    cell.shortNameLabel.text = String(name.prefix(1))
    cell.shortNameLabel.backgroundColor = .primaryColor
    cell.nameLabel.text = name
    cell.saleResultLabel.text = "159订单  |  成单率43.12%"
    cell.moneyLabel.text = "88888.88"
    cell.countLabel.text = "27744.00 C"
    cell.limitCountLabel.text = "1998.00-27744.00 CNY"
    cell.paymentMethodType1.show()
    cell.paymentMethodType1.lineView.backgroundColor = .init(hexString: "#15AB43")
    cell.paymentMethodType1.paymentMethodNameLabel.text = "微信"
    cell.paymentMethodType2.show()
    cell.paymentMethodType2.lineView.backgroundColor = .init(hexString: "#277FE6")
    cell.paymentMethodType2.paymentMethodNameLabel.text = "支付宝"
    cell.paymentMethodType3.show()
    cell.paymentMethodType3.lineView.backgroundColor = .init(hexString: "#EF5151")
    cell.paymentMethodType3.paymentMethodNameLabel.text = "银行卡"
    return cell
}

func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 154
}
func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let vc = BoBBillDetailViewController()
    currentVC?.navigationController?.pushViewController(vc, animated: true)
}

}
extension BoBFreeBuyAndSellView: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return self
    }
}
