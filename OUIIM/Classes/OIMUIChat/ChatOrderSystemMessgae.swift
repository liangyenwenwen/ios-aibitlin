//
//  ChatOrderSystemMessgae.swift
//  OUIIM
//
//  Created by mac on 2024/12/23.
//

import Foundation
import OUICore
import MJRefresh
class ChatOrderSystemMessgae:UIViewController{
    var tableView: UITableView!
    var conversationID:String? = ""
    var startCliendMessageId:String?
    var lastMinMessageSeq:Int? = 0
    var listArray:[orderMessageModel] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    func initView(){
        startCliendMessageId = nil
        view.addSubview(navView)
        view.backgroundColor = .init(hexString: "#F5F5F5")
        navView.snp_makeConstraints { make in
            make.top.left.right.equalTo(0)
            make.height.equalTo(44 + kStatusBarHeight)
        }
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = UIColor.clear
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.register(OrderSystemMessageCell.self, forCellReuseIdentifier: "OrderSystemMessageCell")
        view.addSubview(tableView)
        
        let footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(loadMoreData))
        footer.isAutomaticallyRefresh = false
        footer.setTitle("点击或上拉加载更多".innerLocalized(), for: .idle)
        footer.setTitle("正在加载更多的数据...".innerLocalized(), for: .refreshing)
        tableView.mj_footer = footer
        tableView.snp_makeConstraints { make in
            make.top.equalTo(navView.snp_bottom)
            make.left.right.bottom.equalTo(0)
        }
        getMessageList()
    }
    lazy var navView: BoBCustomNav = {
        let r = BoBCustomNav()
        r.backBlock = {[weak self] in
//            IMController.shared.deleteConversation(conversationID:self?.conversationID ?? ""){_ in 
//                
//            }
            self?.navigationController?.popViewController(animated: true)
        }
        return r
    }()
    @objc func loadMoreData(){
        getMessageList()
    }
    func getMessageList(){
        IMController.shared.getHistoryMessageList(conversationID: conversationID ?? "",
                                                  conversationType: .notification,
                                                  startCliendMsgId: startCliendMessageId,
                                                  lastMinSeq: lastMinMessageSeq ?? 0,
                                                  count: 200) { [weak self] seq, ms in
            self?.lastMinMessageSeq = seq
            self?.startCliendMessageId = ms.first?.clientMsgID
            if ms.count < 200 {
                //
                if var footer = self?.tableView.mj_footer as? MJRefreshAutoNormalFooter {
                    footer.setTitle("加载完成，没有更多了...".innerLocalized(), for: .noMoreData)
                    footer.stateLabel?.textColor = .init(hexString: "#CCCCCC")
                    footer.stateLabel?.font = UIFont(name: "PingFangSC-Medium", size: 16)
                    footer.endRefreshingWithNoMoreData()
                }
            } else {
                self?.tableView.mj_footer?.endRefreshing()
            }
            self?.assemblyData(array: ms)
        }
    }
    func assemblyData(array:[MessageInfo]){
        var tempArray:[orderMessageModel] = []
        for item in array {
            if let model1 = JsonTool.fromJson((item.notificationElem?.detail)!, toClass: orderMessageDetail.self) {
                model1.isRead = item.isRead
                model1.msgID = item.clientMsgID
                let jsonData = model1.text!.data(using: .utf8)
                if (jsonData != nil){
                    do {
                        let user = try JSONDecoder().decode(systemCustomNotitifyItem.self, from: jsonData!)
                        print("+++=====",item.isRead,user.cont)
                        if let detail = JsonTool.fromJson(user.cont!, toClass: orderMessageContentDetail.self){
                            model1.detail = detail
                            print("detail ==== ",detail)
                            var isExit = false
                            for items in tempArray {
                                if items.messageInfo?.detail?.code == model1.detail?.code{
                                    if model1.isRead == false{
                                        items.unReadCount = (items.unReadCount ?? 0) + 1
                                    }
                                    items.subArray.insert(model1, at: 0)
//                                    items.subArray.append(model1)
                                    isExit = true
                                    break
                                }
                            }
                            if isExit == false{
                                var model2 = orderMessageModel()
                                model2.isOpen = false
                                model2.unReadCount = 0
                                model2.messageInfo = model1
                                model2.subArray.insert(model1, at: 0)
                                tempArray.insert(model2, at: 0)
//                                tempArray.append(model2)
                            }
                        }
                    } catch {
                        
                    }
                }
            }
            
        }
//        var tempArray1:[orderMessageModel] = []
        for item in tempArray {
            var isExit = false
            for items in listArray {
                if item.messageInfo?.detail?.code == items.messageInfo?.detail?.code{
                    items.subArray = items.subArray + item.subArray
                    items.unReadCount = (items.unReadCount ?? 0)+(item.unReadCount ?? 0)
                    isExit = true
                    break
                }
            }
            if isExit == false{
                listArray.append(item)
                if item.messageInfo?.isRead == false{
                    item.messageInfo?.isRead = true
                    IMController.shared.imManager.markMessageAsRead(byMsgID: self.conversationID ?? "", clientMsgIDs: [item.messageInfo?.msgID ?? ""]) { str in
                    }
                }
            }
//            else{
//                tempArray1.append(item)
//            }
        }
//        listArray.append(contentsOf: tempArray1)
        tableView.reloadData()
    }
}
extension ChatOrderSystemMessgae: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return listArray.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let model = listArray[section]
        if model.isOpen == true{
            return listArray[section].subArray.count
        }else{
            return 1
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderSystemMessageCell", for: indexPath) as! OrderSystemMessageCell
        let section = indexPath.section
        let row = indexPath.row
        let model = listArray[section]
        let model1 = model.subArray[row]
        cell.moreMessageBlock = {[weak self] in
            model.isOpen = !model.isOpen!
            if model.unReadCount ?? 0 > 0{
                model.unReadCount = 0
                var array:[String] = []
                for item in model.subArray {
                    if item.isRead == false{
                        array.append(item.msgID ?? "")
                        item.isRead = true
                    }
                }
                IMController.shared.imManager.markMessageAsRead(byMsgID: self?.conversationID ?? "", clientMsgIDs: array) { str in
            
                }
            }
            self?.tableView.reloadSections(IndexSet(integer: indexPath.section), with: .fade)
        }
        cell.titleNameLabel.text = model1.notificationName
        cell.orderNumberLabel.text = model1.detail?.code
        cell.timeLabel.text = model1.detail?.changeTime
        cell.icon.image = UIImage(named: model.isOpen == true ? "order_stytem_message_close_icon" : "order_stytem_message_open_icon")
        if row == 0{
//            if model1.isRead == false{
//                IMController.shared.imManager.markMessageAsRead(byMsgID: self.conversationID ?? "", clientMsgIDs: [model1.msgID ?? ""]) { str in
//            
//                }
//            }
            cell.topCornerView.isHidden = true
            if model.isOpen == true{
                cell.bottomView.isHidden = true
                cell.timeBottomCornerView.isHidden = false
            }else{
                cell.timeBottomCornerView.isHidden = true
                if model.subArray.count > 1{
                    cell.bottomView.isHidden = false
                    if model.unReadCount ?? 0 > 0{
                        cell.unReadNumberLabel.isHidden = false
                        cell.unReadNumberLabel.text = String(format: "%d", model.unReadCount ?? 0)
                        cell.messageCountTitleLabel.text = "条未读消息"
                        cell.messageCountTitleLabel.snp_updateConstraints { make in
                            make.left.equalTo(34)
                        }
                    }else{
                        cell.unReadNumberLabel.isHidden = true
                        cell.messageCountTitleLabel.text = "更多消息"
                        cell.messageCountTitleLabel.snp_updateConstraints { make in
                            make.left.equalTo(14)
                        }
                    }
                }else{
                    cell.bottomView.isHidden = true
                }
            }
        }else{
            cell.topCornerView.isHidden = false
            if row == model.subArray.count-1{
                cell.bottomView.isHidden = false
                cell.unReadNumberLabel.isHidden = true
                cell.messageCountTitleLabel.text = "收起"
                cell.messageCountTitleLabel.snp_updateConstraints { make in
                    make.left.equalTo(14)
                }
                cell.timeBottomCornerView.isHidden = true
            }else{
                cell.bottomView.isHidden = true
                cell.timeBottomCornerView.isHidden = false
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = indexPath.section
        let row = indexPath.row
        let model = listArray[section]
        if row == 0{
            if model.isOpen == true{
               return 100
            }else{
                if model.subArray.count > 1{
                    return 141
                }else{
                    return 100
                }
            }
        }else{
            if row == model.subArray.count-1{
                return 141
            }else{
                return 100
            }
        }
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        let row = indexPath.row
        let model = listArray[section]
        let model1 = model.subArray[row]
        if let handler = OIMApi.gotoBoBDetailHandle {
            
            self.view.endEditing(true)
            handler(self, model1.detail?.code ?? "",false, { res in
               
            })
        }
    }
}
class orderMessageModel: Decodable {
    var messageInfo: orderMessageDetail?
    var isOpen:Bool?
    var unReadCount:Int?
    var subArray:[orderMessageDetail]
    init(messageInfo: orderMessageDetail? = nil, isOpen: Bool? = false, unReadCount: Int? = nil, subArray: [orderMessageDetail] = []) {
        self.messageInfo = messageInfo
        self.isOpen = isOpen
        self.unReadCount = unReadCount
        self.subArray = subArray
    }
}
class orderMessageDetail: Decodable {
    var externalUrl: String?
    var mixType:Int?
    var notificationName:String?
    var notificationType:Int?
    var text:String?
    var isRead:Bool?
    var msgID:String?
    var detail:orderMessageContentDetail?
}
class orderMessageContentDetail: Decodable {
    var reminders:Bool?//是否是强提醒,true强提醒
    var code: String?
    var time:String?
    var type:Int?
    var changeTime:String{
        getTime(time: time ?? "")
    }
}
