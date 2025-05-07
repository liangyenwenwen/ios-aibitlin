//
//  ChatServiceSystemMessgae.swift
//  OUICore
//
//  Created by mac on 2025/4/29.
//

import Foundation
import OUICore
import MJRefresh
class ChatServiceSystemMessgae:UIViewController{
    var tableView: UITableView!
    var conversationID:String? = ""
    var startCliendMessageId:String?
    var lastMinMessageSeq:Int? = 0
    var listArray:[ChatServiceNoticeMessage] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        IMController.shared.imManager.markConversationMessage(asRead: conversationID!, onSuccess: nil, onFailure: nil)
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
        tableView.register(ChatServiceSystemMessgaeCell.self, forCellReuseIdentifier: "ChatServiceSystemMessgaeCell")
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
    lazy var navView: ChatServiceCustomNav = {
        let r = ChatServiceCustomNav()
        r.backBlock = {[weak self] in
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
                                                  count: 20) { [weak self] seq, ms in
            self?.lastMinMessageSeq = seq
            self?.startCliendMessageId = ms.first?.clientMsgID
            if ms.count < 20 {
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
        var list:[ChatServiceNoticeMessage] = []
        for item in array {
            if let model1 = JsonTool.fromJson((item.notificationElem?.detail)!, toClass: ChatServiceNoticeMessage.self) {
                if let detail = JsonTool.fromJson(model1.text ?? "", toClass: ChatServiceNoticeMessageDetail.self){
                    model1.detail = detail
                    model1.msgID = item.clientMsgID
                    model1.conversationID = conversationID ?? ""
                    list.insert(model1, at: 0)
                }
            }
        }
        listArray.append(contentsOf: list)
        tableView.reloadData()
    }
}
extension ChatServiceSystemMessgae: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
            return listArray.count
        }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatServiceSystemMessgaeCell", for: indexPath) as! ChatServiceSystemMessgaeCell
    
        let model = listArray[indexPath.section]
        cell.iconImageView.setImage(url: URL(string: model.detail?.icon ?? "")!, thumbURL: nil)
        cell.titleNameLabel.text = model.detail?.title ?? ""
        cell.contentLabel.text = model.detail?.content ?? ""
        cell.timeLabel.text = model.detail?.date ?? ""
        return cell
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = listArray[indexPath.section]
        
        if let handler = OIMApi.gotoPublicStrongNoticeDetailHandle {
            handler(self, model.detail?.hash ?? "",false, { res in
               
            })
        }
    }
}
class ChatServiceNoticeMessage: Decodable {
    var externalUrl: String?
    var mixType:Int?
    var notificationName:String?
    var notificationType:Int?
    var text:String?
    var isRead:Bool?
    var msgID:String?
    var conversationID:String?
    var detail:ChatServiceNoticeMessageDetail?
    
}
class ChatServiceNoticeMessageDetail: Decodable {
    var type: Int?
    var icon:String?
    var title:String?
    var hash:String?
    var content:String?
    var date:String?
}
