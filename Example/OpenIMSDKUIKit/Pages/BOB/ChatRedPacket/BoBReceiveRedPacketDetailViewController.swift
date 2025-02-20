//
//  BoBReceiveRedPacketDetailViewController.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/12/6.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Foundation
import TangramKit
import OUICore


class BoBReceiveRedPacketDetailViewController: BaseTitleController {
    var listArray:[iconTimeAmountCurrencyNamePOS] = []
    var redPacketMessage:RedPacketMessageStatus?
    var redPacketDetail:BoBRedPacketDetailData?
    var updateRedPacketStatus:((_ status:String)->())!
    override func initViews() {
        super.initViews()
        view.backgroundColor = .colorBackgroundAPP
        initTableViewSafeAre()
        title = "红包明细"
        navView.titleView.textColor = .white
        
        container.tg_padding = UIEdgeInsets(top: PADDING_OUTER, left: PADDING_OUTER, bottom: PADDING_OUTER, right: PADDING_OUTER)
        view.addSubview(topImageView)
        topImageView.snp_remakeConstraints { make in
            make.left.top.right.equalTo(0)
            make.height.equalTo(124)
        }
        container.addSubview(topView)
        container.addSubview(tipLabel)
        tableView.separatorStyle = .none
        tableView.register(BoBReceiveRedPacketCell.self, forCellReuseIdentifier: BoBReceiveRedPacketCell.className)
        topView.snp_makeConstraints { make in
            make.top.equalTo(0)
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.height.equalTo(230)
        }
        tableView.snp_makeConstraints { make in
            make.top.equalTo(topView.snp_bottom)
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.bottom.equalTo(tipLabel.snp_top).offset(-10)
        }
        tipLabel.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.bottom.equalTo(0)
            make.height.equalTo(18)
        }
//        userImageView.sd_setImage(with: URL(string: "http://192.168.7.126:10002/object/6150535698/image_2024-12-06-15-54.544.png"))
//        userNameLabel.text = "荷包蛋小朋友的红包"
//        redPacketDescLabel.text = "恭喜发财，大吉大利"
//        totalMoneyLabel.text = "10 C"
//        sectionTitleLabel.text = "已领取 2/10 ，总共10C"
        getRedPacketsDetails()
    }
    func getRedPacketsDetails(){
        BoBRedPacketModel.RedPacketsDetailsRequest(code: redPacketMessage?.data?.code ?? "") {data in
            self.redPacketDetail = data
            self.userImageView.sd_setImage(with: URL(string: data.funderImg))
            self.userNameLabel.text = (data.funderNickName ?? "") + "的红包"
            self.redPacketDescLabel.text = data.instructions
            if data.amountM ?? 0.00 > 0{
                self.totalMoneyLabel.text = String(format: "%.2f ",data.amountM ?? 0.00) + (data.currency ?? "")
            }else{
                self.totalMoneyLabel.text = " "
            }
            let status = self.redPacketMessage?.data?.redPacketType
            if status == 0 || status == 3{
                if self.redPacketMessage?.data?.sendUserId == IMController.shared.uid{
                    self.sectionTitleLabel.show()
                    self.lineView.show()
                    self.tipLabel.show()
                    var str = ""
                    var status = "0"
                    let sign = data.sign ?? 1
                    if sign == 1{
                        str = "未领取"
                        status = "0"
                    }else if sign == 2{
                        str = "已领取"
                        status = "3"
                    }else if sign == 3{
                        str = "已过期"
                        status = "2"
                    }
                    self.sectionTitleLabel.text = "红包数量" + String(format: "%.2f ",data.amountAll ?? 0.00) + (data.currency ?? "") + "，" + str
                    if self.updateRedPacketStatus != nil{
                        self.updateRedPacketStatus(status)
                    }
                    self.listArray = data.iconTimeAmountCurrencyNamePOS
                    self.tableView.reloadData()
                }else{
                    self.totalMoneyLabel.text = String(format: "%.2f ",data.amountM ?? 0.00) + (data.currency ?? "")
                    self.sectionTitleLabel.hide()
                    self.lineView.hide()
                }
            }else{
                if self.redPacketMessage?.data?.sendUserId == IMController.shared.uid || status == 1{
                    self.lineView.show()
                    self.sectionTitleLabel.text = "已领取 " + String(format: "%d/%d",((data.number ?? 0)-(data.residualNumber ?? 0)),data.number ?? 0) + " ，总共" + String(format: "%.2f ",data.amountAll ?? 0.00) + (data.currency ?? "")
                    self.listArray = data.iconTimeAmountCurrencyNamePOS
                    if self.redPacketMessage?.data?.sendUserId == IMController.shared.uid{
                        self.tipLabel.show()
                    }
                    self.tableView.reloadData()
                }else{
                    self.totalMoneyLabel.text = String(format: "%.2f ",data.amountM ?? 0.00) + (data.currency ?? "")
                    self.sectionTitleLabel.hide()
                    self.lineView.hide()
                }
                
            }
        } completionHandler:{errCode,errMsg in
            if errCode == -1{
                SuperToast.show(title: errMsg)
            }else{
                SuperToast.show(title: String(errCode) + "：" + String(errCode).localized())
            }
        }
    }
    lazy var topImageView: UIImageView = {
        let r = UIImageView(image: UIImage(named: "mine_red_packet_detail_top_icon"))
        r.layer.zPosition = -1
        return r
    }()
    lazy var topView: TGLinearLayout = {
        let r = TGLinearLayout(.vert)
        r.tg_gravity = .horz.center
        r.addSubview(userView)
        r.addSubview(redPacketDescLabel)
        r.addSubview(totalMoneyLabel)
        r.addSubview(lineView)
        r.addSubview(sectionTitleLabel)
        return r
    }()
    lazy var userView: TGLinearLayout = {
        let r = TGLinearLayout(.horz)
        r.tg_top.equal(65)
        r.tg_left.equal(0)
        r.tg_height.equal(24)
        r.tg_width.equal(kScreenWidth-32)
        r.tg_gravity = .horz.center
        r.tg_space = 10
        r.addSubview(userImageView)
        r.addSubview(userNameLabel)
        return r
    }()
    lazy var userImageView: UIImageView = {
        let r = UIImageView()
        r.tg_width.equal(24)
        r.tg_height.equal(24)
        r.corner(12)
        return r
    }()
    lazy var userNameLabel: UILabel = {
        let r = UILabel()
        r.tg_width.equal(.wrap)
        r.tg_height.equal(.wrap)
        r.textColor = .black333
        r.font = .mediumFont(18)
        return r
    }()
    lazy var redPacketDescLabel: UILabel = {
        let r = UILabel()
        r.tg_top.equal(10)
        r.tg_width.equal(.wrap)
        r.tg_height.equal(16)
        r.textColor = .black999
        r.font = .regularFont(14)
        return r
    }()
    lazy var totalMoneyLabel: UILabel = {
        let r = UILabel()
        r.tg_top.equal(24)
        r.tg_width.equal(.wrap)
        r.tg_height.equal(32)
        r.textColor = .black333
        r.font = .semiboldFont(36)
        return r
    }()
    lazy var lineView: UIView = {
        let r = ViewFactoryUtil.smallDivider()
        r.tg_top.equal(24)
        return r
    }()
    lazy var sectionTitleLabel: UILabel = {
        let r = UILabel()
        r.tg_top.equal(10)
        r.tg_left.equal(0)
        r.tg_width.equal(kScreenWidth-32)
        r.tg_height.equal(16)
        r.textColor = .black999
        r.font = .regularFont(14)
        return r
    }()
    lazy var tipLabel: UILabel = {
        let r = UILabel()
        r.textColor = .black999
        r.font = .regularFont(14)
        r.text = "未领取的红包，将于24小时自动退回"
        r.textAlignment = .center
        r.hide()
        return r
    }()
}
extension BoBReceiveRedPacketDetailViewController{
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let item = listArray[indexPath.row]
        let cell =  tableView.dequeueReusableCell(withIdentifier: BoBReceiveRedPacketCell.className, for: indexPath) as! BoBReceiveRedPacketCell
        cell.userImageView.sd_setImage(with: URL(string: item.icon))
        cell.userNameLabel.text = item.name
        cell.timeLabel.text = item.receiveTime
        cell.moneyLabel.text = String(format: "%.2f ",item.amount ?? 0.00) + (item.currency ?? "")
        if item.luck ?? false{
            cell.bestLabel.show()
        }else{
            cell.bestLabel.hide()
        }
        if indexPath.row == listArray.count - 1{
            cell.lineView.hide()
        }else{
            cell.lineView.show()
        }
        return cell
        
    }
    override func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
       return listArray.count
   }
   func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72.h
    }
}

