
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
        _viewModel.getAllConversations()
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
    
    

    private lazy var _tableView: UITableView = {
        let v = UITableView(frame: view.frame, style: .grouped)
        v.register(ChatTableViewCell.self, forCellReuseIdentifier: ChatTableViewCell.className)
        v.delegate = self
        v.separatorStyle = .none
        v.rowHeight = 68.h
        
        let refresh: UIRefreshControl = {
            let v = UIRefreshControl(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
            v.rx.controlEvent(.valueChanged).subscribe(onNext: { [weak self, weak v] in
                self?._viewModel.getSelfInfo()
                v?.endRefreshing()
            }).disposed(by: _disposeBag)
            return v
        }()
        v.refreshControl = refresh
        v.backgroundColor = .clear
        
        return v
    }()
    
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
        
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.getUnReadTotalCount()
//        self.timeCountDown()
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    private func createMenuItems() -> [PopoverTableViewController.MenuItem] {
      
        let scanItem = PopoverTableViewController.MenuItem(title: "扫一扫".innerLocalized(), icon: UIImage(named: "chat_menu_scan_icon")) { [weak self] in
            let vc = ScanViewController()
            vc.scanDidComplete = { [weak self] (result: String) in
                if result.contains(IMController.addFriendPrefix) {
//                    self?.navigationController?.popViewController(animated: false)
//
//                    let uid = result.replacingOccurrences(of: IMController.addFriendPrefix, with: "")
//                    let vc = UserDetailTableViewController(userId: uid, groupId: nil)
//                    vc.hidesBottomBarWhenPushed = true
//                    self?.navigationController?.pushViewController(vc, animated: true)
                    
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
                } else {
                    ProgressHUD.error("unrecognized".innerLocalized())
                    self?.navigationController?.popViewController(animated: true)
                }
            }
            vc.hidesBottomBarWhenPushed = true
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        let addFriendItem = PopoverTableViewController.MenuItem(title: "添加好友".innerLocalized(), icon: UIImage(named: "chat_menu_add_friend_icon")) { [weak self] in
            let vc = SearchFriendIndexViewController()
            vc.hidesBottomBarWhenPushed = true
            vc.title = "添加好友".innerLocalized()
            self?.navigationController?.pushViewController(vc, animated: true)
            vc.didSelectedItem = { [weak self] id in
//                let vc = UserDetailTableViewController(userId: id, groupId: nil)
//                self?.navigationController?.pushViewController(vc, animated: true)
                
                if let handler = OIMApi.gotoUserMessageHandle {
                                    handler(self!, id, "", "",{res in

                                    })
                                }
            }
        }

        let addGroupItem = PopoverTableViewController.MenuItem(title: "添加群聊".innerLocalized(), icon: UIImage(named: "chat_menu_add_group_icon")) { [weak self] in
            let vc = SearchGroupIndexViewController()
            vc.hidesBottomBarWhenPushed = true
            self?.navigationController?.pushViewController(vc, animated: true)
            vc.title = "添加群聊".innerLocalized()
            vc.didSelectedItem = { [weak self] id in
                let vc = GroupDetailViewController(groupId: id)
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
        let createGroupItem = PopoverTableViewController.MenuItem(title: "发起群聊".innerLocalized(), icon: UIImage(named: "chat_menu_create_group_icon")) { [weak self] in
            let vc = SelectContactsViewController()
            vc.title = "发起群聊".innerLocalized()
            vc.selectedContact(hasSelected: []) { [weak vc, weak self] (_, r: [ContactInfo]) in
                guard let sself = self else { return }
                let users = r.map {UserInfo(userID: $0.ID!, nickname: $0.name, faceURL: $0.faceURL)}
                let vc = NewGroupViewController(users: users, groupType: .normal)
                self?.navigationController?.pushViewController(vc, animated: true)
            }
            vc.hidesBottomBarWhenPushed = true
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        
        let createWorkGroupItem = PopoverTableViewController.MenuItem(title: "创建大群".innerLocalized(), icon: UIImage(named: "chat_menu_create_work_group_icon")) { [weak self] in
            #if ENABLE_ORGANIZATION
            let vc = MyContactsViewController(types: [.friends, .staff], multipleSelected: true)
            #else
            let vc = MyContactsViewController(types: [.friends], multipleSelected: true, enableChangeSelectedModel: true)
            #endif
            vc.title = "创建大群".innerLocalized()
            vc.selectedContact(blocked: [IMController.shared.uid]) { [weak self] (r: [ContactInfo]) in
                guard let sself = self else { return }
                
                let users = r.map {UserInfo(userID: $0.ID!, nickname: $0.name, faceURL: $0.faceURL)}
                
                if users.count > 1 {
                    let vc = NewGroupViewController(users: users, groupType: .working)
                    self?.navigationController?.pushViewController(vc, animated: true)
                } else {
                    guard let userID = users.first?.userID else { return }
                    ProgressHUD.animate()
                    sself._viewModel.createSingleChat(userID: userID) { [sself] conversation in
                        ProgressHUD.dismiss()
                        sself.toChat(conversation: conversation)
                    }
                }
            }
            vc.hidesBottomBarWhenPushed = true
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        var items = [scanItem, addFriendItem, addGroupItem, createWorkGroupItem]
        
#if ENABLE_LIVE_ROOM
        let meetingItem = PopoverTableViewController.MenuItem(title: "视频会议".innerLocalized(), icon: UIImage(named: "chat_menu_create_live_room_icon")) { [weak self] in
            let vc = LiveRecordsViewController()
            vc.hidesBottomBarWhenPushed = true
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        items.append(meetingItem)
#endif
        return items
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
        
        actionAboutApp()
    }
    
    @objc private func setText() {
        _tableView.reloadData()
    }

    private func initView() {
        view.addSubview(_headerView)
//        _headerView.backgroundColor = .red
        _headerView.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
        }
        view.addSubview(_tableView)
        _tableView.snp.makeConstraints { make in
            make.top.equalTo(_headerView.snp.bottom)
            make.leading.bottom.trailing.equalToSuperview()
        }
        
        timeCountDown()
        
        
        
    }
    
    private func toChat(conversation: ConversationInfo) {
        let vc = ChatViewControllerBuilder().build(conversation, hiddenInputBar: conversation.conversationType == .notification)
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
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
            
        }.disposed(by: _disposeBag)

        _tableView.backgroundColor = .white
        _tableView.rx.modelSelected(ConversationInfo.self).subscribe(onNext: { [weak self] (conversation: ConversationInfo) in
            
            self?.toChat(conversation: conversation)
            
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
            let root = self?.tabBarController
            let tabBarItem = root?.tabBar.items![0]
            if count > 0 {
                tabBarItem?.badgeValue = count > 99 ? "99+" : "\(count)"
            } else {
                tabBarItem?.badgeValue = nil
            }
        
            
            
//            self?._tableView.reloadData()
            
        }
    }
    
    
    func timeCountDown() {
        var count = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            
                if count % 50 == 0 {
                    self._tableView.reloadData()
                }
            
            count += 1
        }
    }
    
    deinit {
        if timer != nil {
            timer?.invalidate()
        }
    }
    
}

extension ChatListViewController {

}
