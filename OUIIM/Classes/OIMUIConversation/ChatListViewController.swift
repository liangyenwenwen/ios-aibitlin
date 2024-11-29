
import OUICore
import OUICoreView
import ProgressHUD
import RxSwift
import Localize_Swift

#if ENABLE_CALL
import OUICalling
#endif

#if ENABLE_LIVE_ROOM
import OUILive
#endif

open class ChatListViewController: UIViewController, UITableViewDelegate {
    
    public var tapTab = false
    
    private var scrolledIndex = 0
    
    var timer: Timer? = nil
    
    public func scrollToUnreadItem() {
        let conversations = _viewModel.conversationsRelay.value
        var currentIndex = 0
        
        for(i, item) in conversations.enumerated() {
            if item.unreadCount > 0, i > scrolledIndex {
                currentIndex = i
                break
            }
        }
        scrolledIndex = currentIndex
        
        _tableView.scrollToRow(at: IndexPath(row: scrolledIndex, section: 0), at: .top, animated: true)
    }
    
    public func refreshConversations() {
//        _viewModel.getAllConversations()
        
        _headerView.searchView.titleLbl.text = "搜索".innerLocalized()
        emptyView._titleStr = "空空如也".innerLocalized() as NSString
        netWorkTipView.titleLbl.text = "请检查网络是否可用！".innerLocalized()
    }
    
    public func refreshUserInfo(userInfo: UserInfo? = nil) {
//        _headerView.avatarImageView.setAvatar(url: userInfo?.faceURL?.defaultThumbnailURLString, text: userInfo?.nickname)
//        _headerView.nameLabel.text = userInfo?.nickname
    }
    
    public func clearRecord() {
        _viewModel.conversationsRelay.accept([])
    }
    
//    private lazy var _headerView: ChatListHeaderView = {
//        let v = ChatListHeaderView()
////        let tap = UITapGestureRecognizer()
////        tap.rx.event.subscribe(onNext: { [weak self] _ in
////            let vc = GlobalSearchViewController()
////            vc.hidesBottomBarWhenPushed = true
////            self?.navigationController?.pushViewController(vc, animated: true)
////        }).disposed(by: _disposeBag)
////        v.searchView.addGestureRecognizer(tap)
//        
//        #if ENABLE_CALL
//        v.callBtn.rx.tap.subscribe(onNext: { [weak self] in
//            let vc = CallRecordsViewController()
//            vc.hidesBottomBarWhenPushed = true
//            self?.navigationController?.pushViewController(vc, animated: true)
//        }).disposed(by: _disposeBag)
//        #endif
//        
//        return v
//    }()
    
    lazy var _headerView: YFChatHomeSearchNav = {
        let r =  YFChatHomeSearchNav()
        r.backgroundColor = .white
        r.searchView.searchBlock = { [weak self]  in
            let vc = GlobalSearchViewController()
            vc.hidesBottomBarWhenPushed = true
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        r.searchView.btnClickBlock = { [weak self] in
            guard let self else { return }
            let popover = PopoverTableViewController(items: createMenuItems())
            popover.topInset = 0
            popover.show(in: self, sender: _headerView.searchView.rightImg, permittedArrowDirections: [])
        }
        return r
    }()
    
    lazy var netWorkTipView:ABLNotNetTopTipView = {
        let r = ABLNotNetTopTipView()
        r.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: 44)
        return r
    }()

    private lazy var _tableView: UITableView = {
        let v = UITableView(frame: view.frame, style: .plain)
        v.register(ChatTableViewCell.self, forCellReuseIdentifier: ChatTableViewCell.className)
        v.delegate = self
        v.separatorStyle = .none
        v.rowHeight = 72
        v.contentInsetAdjustmentBehavior = .never
        
        let refresh: UIRefreshControl = {
            let v = UIRefreshControl(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
            v.rx.controlEvent(.valueChanged).subscribe(onNext: { [weak self, weak v] in
                self?._viewModel.getSelfInfo()
                v?.endRefreshing()
            }).disposed(by: _disposeBag)
            return v
        }()
//        refresh.backgroundColor = .green
        v.refreshControl = refresh
        v.backgroundColor = .clear
        
        return v
    }()
    
    func tableViewAddEmptyView() {
        _tableView.ly_emptyView = emptyView
    }
    
    lazy var emptyView:HDEmptyView  = {
        let emptyV:HDEmptyView = HDEmptyView.emptyActionViewWithImageStr(imageStr: "custom_blank_icon", titleStr: "空空如也".localized() as NSString, detailStr: "", btnTitleStr: "", target: self, action: #selector(reloadBtnAction)) as! HDEmptyView
        
        emptyV.titleLabTextColor = UIColor.red
        emptyV.actionBtnFont = UIFont.systemFont(ofSize: 19)
        emptyV.contentViewY = -90
        emptyV.actionBtnIsHidden = true
        emptyV.titleLabFont = UIFont(name: "PingFangSC-Medium", size: 16)!
        emptyV.titleLabTextColor =  UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
        return emptyV
    }()
    
    
    
    @objc func reloadBtnAction() {
        
    }
    
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        if tapTab {
            navigationController?.setNavigationBarHidden(true, animated: false)
            tapTab = false
        }
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !tapTab {
            navigationController?.setNavigationBarHidden(true, animated: true)
        }
        self.refreshConversations()
//        
//        _tableView.reloadData()
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.getUnReadTotalCount()
        self.timeCountDown()
    }
    
    
    
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ProgressHUD.dismiss()
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    private func createMenuItems() -> [PopoverTableViewController.MenuItem] {
      
        let scanItem = PopoverTableViewController.MenuItem(title: "扫一扫".innerLocalized(), icon: UIImage(named: "chat_menu_scan_icon")) { [weak self] in
            let vc = ScanViewController()
            vc.scanDidComplete = { [weak self] (result: String) in
                if result.contains(IMController.addFriendPrefix) {
                    self?.navigationController?.popViewController(animated: false)
                    let uid = result.replacingOccurrences(of: IMController.addFriendPrefix, with: "")
                    if let handler = OIMApi.gotoUserMessageHandle {
                        handler(self!, uid, "", "",{res in

                        })
                    }
                    
                } else if result.contains(IMController.joinGroupPrefix) {
                    self?.navigationController?.popViewController(animated: false)

                    let groupID = result.replacingOccurrences(of: IMController.joinGroupPrefix, with: "")
                    let vc = GroupDetailViewController(groupId: groupID)
                    vc.hidesBottomBarWhenPushed = true
                    self?.navigationController?.pushViewController(vc, animated: true)
                } else if result.contains(IMController.walletTransferPrefix) {
                    //转账
                    self?.navigationController?.popViewController(animated: false)
                    let address = result.replacingOccurrences(of: IMController.walletTransferPrefix, with: "")
                    if let handler = OIMApi.gotoBoBTransferAccountsHandle {
                        handler(self!, address,{res in

                        })
                    }
                }else {
                    if let handler = OIMApi.showTipHandle {
                                    
                        handler("unrecognized".innerLocalized(), { res in
                           
                        })
                    }
                    self?.navigationController?.popViewController(animated: true)
                }
            }
            vc.hidesBottomBarWhenPushed = true
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        let addFriendItem = PopoverTableViewController.MenuItem(title: "添加好友".innerLocalized(), icon: UIImage(named: "chat_menu_add_friend_icon")) { [weak self] in
            let vc = SearchFriendViewController()
            vc.hidesBottomBarWhenPushed = true
            self?.navigationController?.pushViewController(vc, animated: true)
            vc.didSelectedItem = { [weak self] id in
                if let handler = OIMApi.gotoUserMessageHandle {
                    handler(self!, id, "", "",{res in

                    })
                }
            }
        }

        let addGroupItem = PopoverTableViewController.MenuItem(title: "添加群聊".innerLocalized(), icon: UIImage(named: "chat_menu_add_group_icon")) { [weak self] in
            let vc = SearchGroupViewController()
            vc.hidesBottomBarWhenPushed = true
            self?.navigationController?.pushViewController(vc, animated: true)
            vc.didSelectedItem = { [weak self] id in
                let vc = GroupDetailViewController(groupId: id)
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
        let createGroupItem = PopoverTableViewController.MenuItem(title: "创建群聊".localized(), icon: UIImage(named: "chat_menu_create_group_icon")) { [weak self] in
            self?.creatGroupChat(groupType: .working)
        }
        return [scanItem, addFriendItem, addGroupItem, createGroupItem]
    }
    
    private let _disposeBag = DisposeBag()
    private let _viewModel = ChatListViewModel()
    private let _contactViewModel = ContactsViewModel()

    override open func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        NotificationCenter.default.addObserver(self, selector: #selector(setText), name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)

        initView()
        bindData()
        
        tableViewAddEmptyView()
        actionAboutApp()
    }
    
    @objc private func setText() {
        _tableView.reloadData()
    }

    private func initView() {
        
        
//        let header = UIView()
//        _tableView.tableHeaderView = header
        
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
        view.addSubview(_headerView)
        view.addSubview(_tableView)
        _headerView.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
        }
        if IMController.shared.netWorkStatus == "hasNetWork"{
            _tableView.tableHeaderView = nil
            
        }else{
            _tableView.tableHeaderView = netWorkTipView
        }
        _tableView.snp.makeConstraints { make in
//            make.top.equalTo(kStatusBarHeight + 15)
            make.top.equalTo(_headerView.snp_bottom)
            make.leading.bottom.trailing.equalToSuperview()
        }
        
//        timeCountDown()
        NotificationCenter.default.addObserver(self, selector: #selector(refreshNetWorkStatus(_:)), name: Notification.Name("netWorkStatus"), object: nil)
        
        
        
    }
    private func toChat(conversation: ConversationInfo) {
        let vc = ChatViewControllerBuilder().build(conversation, hiddenInputBar: conversation.conversationType == .notification)
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    private func creatGroupChat(groupType: GroupType = .normal) {
        
#if ENABLE_ORGANIZATION
        let vc = MyContactsViewController(types: [.friends, .staff], multipleSelected: true)
#else
        let vc = MyContactsViewController(types: [.friends], multipleSelected: true, enableChangeSelectedModel: true)
#endif
        vc.selectedContact(blocked: [IMController.shared.uid]) { [weak self] (r: [ContactInfo]) in
            guard let self else { return }
            
            let users = r.map {UserInfo(userID: $0.ID!, nickname: $0.name, faceURL: $0.faceURL)}
            
            if users.count > 1 {
                let vc = NewGroupViewController(users: users, groupType: .working)
                navigationController?.pushViewController(vc, animated: true)
            } else {
                guard let userID = users.first?.userID else { return }
                ProgressHUD.animate()
                createSingleChat(userID: userID) { [self] c in
                    ProgressHUD.dismiss()
                    let vc = ChatViewControllerBuilder().build(c, hiddenInputBar: c.conversationType == .notification)
                    vc.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func createSingleChat(userID: String, onComplete: @escaping (ConversationInfo) -> Void) {
        
        IMController.shared.getConversation(sessionType: .c2c, sourceId: userID) { [weak self] (conversation: ConversationInfo?) in
            guard let conversation else { return }
            
            onComplete(conversation)
        }
    }

    private func bindData() {
        
        IMController.shared.connectionRelay.subscribe(onNext: { [weak self] status in
//            if status == .connectFailure || status == .syncComplete || status == .syncFailure || status == .kickedOffline {
//                ProgressHUD.dismiss()
//            }
            
//            self?._headerView.updateConnectionStatus(status: status)
        })
        
        /// 显示弹窗
//        _headerView.addBtn.rx.tap.subscribe(onNext: { [weak self] in
//            guard let self else { return }
//            let popover = PopoverTableViewController(items: createMenuItems())
//            popover.topInset = 0
//            popover.show(in: self, sender: _headerView.addBtn, permittedArrowDirections: [])
//        }).disposed(by: _disposeBag)
        
        

        _viewModel.conversationsRelay.bind(to: _tableView.rx.items(cellIdentifier: ChatTableViewCell.className, cellType: ChatTableViewCell.self)) { (row, item, cell) in
            
            cell.updateUI(item: item)
//            cell.backgroundColor = .red
            
        }.disposed(by: _disposeBag)

        _tableView.backgroundColor = .white
        _tableView.rx.modelSelected(ConversationInfo.self).subscribe(onNext: { [weak self] (conversation: ConversationInfo) in
            
            self?.toChat(conversation: conversation)
            
        }).disposed(by: _disposeBag)
        _tableView.rx.itemSelected.subscribe(onNext: {[weak self] (indexPath) in
            print("点击\(indexPath)")
            self?._tableView.deselectRow(at: indexPath, animated: true)
        }).disposed(by: _disposeBag)

        _viewModel.loginUserPublish.subscribe(onNext: { [weak self] (userInfo: UserInfo?) in
//            self?._headerView.avatarImageView.setAvatar(url: userInfo?.faceURL?.defaultThumbnailURLString, text: userInfo?.nickname, onTap: nil)
//            self?._headerView.nameLabel.text = userInfo?.nickname
            self?._contactViewModel.getFriendApplications()
            self?._contactViewModel.getGroupApplications()
        }).disposed(by: _disposeBag)
    }

    public func tableView(_: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let item = _viewModel.conversationsRelay.value[indexPath.row]

        var actions: [UIContextualAction] = []
        
        let deleteAction = UIContextualAction(style: .destructive, title: "deleteChat".innerLocalized()) { [weak self] _, _, completion in
            self?._viewModel.deleteConversation(conversationID: item.conversationID, completion: { _ in
                completion(true)
            })
        }
        deleteAction.backgroundColor = UIColor.cFF381F
        
        actions.append(deleteAction)
        
        if item.unreadCount > 0 {
            let markReadTitle = "markHasRead".innerLocalized()
            let markReadAction = UIContextualAction(style: .normal, title: markReadTitle) { [weak self] _, _, completion in
                ProgressHUD.animate()
                self?._viewModel.markReaded(id: item.conversationID, onSuccess: { res in
                    ProgressHUD.dismiss()
                    completion(res)
                })
            }
            markReadAction.backgroundColor = UIColor.c8E9AB0
            
            actions.append(markReadAction)
        }

        
        let pinActionTitle = item.isPinned ? "cancelTop".innerLocalized() : "top".innerLocalized()
        let setTopAction = UIContextualAction(style: .normal, title: pinActionTitle) { [weak self] _, _, completion in
            ProgressHUD.animate()
            self?._viewModel.pinConversation(id: item.conversationID, isPinned: !item.isPinned, onSuccess: { res in
                ProgressHUD.dismiss()
                completion(res)
            })
        }
        setTopAction.backgroundColor = UIColor.c0089FF
        
        actions.append(setTopAction)
        
        let configure = UISwipeActionsConfiguration(actions: actions)
        
        return configure
    }
    
//    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let r  = tableHeaderSearchView()
//        let tap = UITapGestureRecognizer()
//        tap.rx.event.subscribe(onNext: { [weak self] _ in
//            let vc = GlobalSearchViewController()
//            vc.hidesBottomBarWhenPushed = true
//            self?.navigationController?.pushViewController(vc, animated: true)
//        }).disposed(by: _disposeBag)
//        r.addGestureRecognizer(tap)
//        return r
//    }
//    
//    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 52
//    }
    
    // MARK: - 张亚飞打的标记  业务层调用SDK里面的页面
    func actionAboutApp() {
        
        OIMApi.addFriendhandle = { (vc , userid, completion: @escaping (String) -> Void) in
            
            let apply = ApplyViewController(userID: userid)
            vc.navigationController?.pushViewController(apply, animated: true)
        }
        
    }
    
    
    private func getUnReadTotalCount() {
        
        IMController.shared.getTotalUnreadMsgCount { [weak self] count in
            print(count)
            IMController.shared.unChatMessageCount = count
            UIApplication.shared.applicationIconBadgeNumber = IMController.shared.unChatMessageCount + IMController.shared.unCallPhoneMessageCount + IMController.shared.unContactMessageCount
            let root = self?.tabBarController
            let tabBarItem = root?.tabBar.items![0]
            if count > 0 {
                tabBarItem?.badgeValue = count > 99 ? "99+" : "\(count)"
            } else {
                tabBarItem?.badgeValue = nil
            }
        }
    }
    @objc func refreshNetWorkStatus(_ notidication: Notification) {
            if  let userinfo = notidication.userInfo, let netWorkStatus = userinfo["value"] as? String {
                if netWorkStatus == "hasNetWork"{
                    _tableView.tableHeaderView = nil
                }else{
                    _tableView.tableHeaderView = netWorkTipView
                }
            }
        }
    
    /// 原本为了解决个人头像和群头像问题
    func timeCountDown() {
//        var count = 0
//        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
//            
//                if count % 10 == 0 {
//                    self._tableView.reloadData()
//                    if count > 20 {
//                        timer.invalidate()
//                    }
//                }
//            
//            count += 1
//        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        if timer != nil {
            timer?.invalidate()
        }
    }
    
}

extension ChatListViewController {

}
