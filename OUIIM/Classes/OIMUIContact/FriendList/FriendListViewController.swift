
import RxSwift
import OUICore
import OUICoreView
import ProgressHUD

#if ENABLE_LIVE_ROOM
import OUILive
#endif

open class FriendListViewController: UIViewController {
    var selectCallBack: ((UserInfo) -> Void)?
    
    var messageCount: Int = 0
    
    private lazy var _tableView: UITableView = {
        let v = UITableView()
        let config = SCIndexViewConfiguration(indexViewStyle: SCIndexViewStyle.default)!
        config.indexItemRightMargin = 8
        config.indexItemTextColor = UIColor(hexString: "#999999")
        config.indexItemSelectedTextColor = UIColor(hexString: "#388cef")
        config.indexItemSelectedBackgroundColor = .clear
        config.indexItemsSpace = 4
        v.sc_indexViewConfiguration = config
        v.sc_translucentForTableViewInNavigationBar = true
        v.register(FriendListUserTableViewCell.self, forCellReuseIdentifier: FriendListUserTableViewCell.className)
        v.dataSource = self
        v.delegate = self
        v.rowHeight = UITableView.automaticDimension
        v.backgroundColor = .clear
        v.separatorColor = .clear

        if #available(iOS 15.0, *) {
            v.sectionHeaderTopPadding = 0
        }
        return v
    }()
    
    lazy var _headerNavView: YFChatHomeSearchNav = {
        let r =  YFChatHomeSearchNav()
        r.backgroundColor = .white
        r.searchView.searchBlock = { [weak self]  in
            let vc = GlobalSearchViewController()
            vc.hidesBottomBarWhenPushed = true
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        r.searchView.btnClickBlock = { [weak self] in
            guard let self else { return }
//            let vc = AddTableViewController()
//            vc.hidesBottomBarWhenPushed = true
//            self.navigationController?.pushViewController(vc, animated: true)
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
            //                    ProgressHUD.error("unrecognized".innerLocalized())
                                
                                ProgressHUD.dismiss()
                                
                                if let handler = OIMApi.showTipHandle {
                                                
                                    handler("unrecognized".innerLocalized(), { res in
                                       
                                    })
                                }
                                
                                self?.navigationController?.popViewController(animated: true)
                            }
                        }
                        vc.hidesBottomBarWhenPushed = true
                        self.navigationController?.pushViewController(vc, animated: true)
        }
        return r
    }()
    

    private let _viewModel = FriendListViewModel()
    public lazy var contactsViewModel = ContactsViewModel()
    private let _disposeBag = DisposeBag()
    private lazy var resultC = FriendListResultViewController()

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.hidesSearchBarWhenScrolling = false
//        navigationController?.navigationBar.isHidden = false
        
//        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.navigationBar.isHidden = true
        
        _viewModel.getMyFriendList()
        contactsViewModel.getFriendApplications()
        contactsViewModel.getGroupApplications()
        contactsViewModel.queryMyDepartmentInfo()
        contactsViewModel.getFrequentUsers()
        
        updateLanguage()
    }
    
    func updateLanguage() {
        
        _headerNavView.searchView.titleLbl.text = "搜索".localized()
        headerView.addFriendView.bindData(item: listTableHeader.MenuItem(title: "添加好友".innerLocalized(), icon: UIImage(named: "friend_list_add_friend_icon")))
        headerView.addGroupChatView.bindData(item: listTableHeader.MenuItem(title: "添加群聊".innerLocalized(), icon: UIImage(named: "friend_list_add_group_chat_icon")))
        headerView.creatGroupChatView.bindData(item: listTableHeader.MenuItem(title: "创建群聊".innerLocalized(), icon: UIImage(named: "friend_list_creat_group_chat_icon")))
        headerView.videoMettingView.bindData(item: listTableHeader.MenuItem(title: "视频会议".innerLocalized(), icon: UIImage(named: "friend_list_video_metting_icon")))
        
        let data:[listTableHeader.MenuItem] = [listTableHeader.MenuItem(title: "新的好友".innerLocalized(), icon: UIImage(named: "friend_list_group_icon")),
                                               listTableHeader.MenuItem(title: "newGroup".innerLocalized(), icon: UIImage(named: "friend_list_group_new_icon")),
                                               listTableHeader.MenuItem(title: "群聊".localized(), icon: UIImage(named: "friend_list_new_friend_icon"))]
        headerView.newFriendView.bindData(item: data[0])
        headerView.newGroupView.bindData(item: data[1])
        headerView.groupView.bindData(item: data[2])
        
        headerView.chooseView.firstLbl.text = "MyFriend".localized()
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//            super.viewDidAppear(animated)
//            navigationController?.navigationBar.isHidden = false
//        }
    
//    open override func viewWillLayoutSubviews() {
//        super.viewWillLayoutSubviews()
//        
//        navigationController?.setNavigationBarHidden(true, animated: false)
//        navigationController?.navigationBar.isHidden = true
// 
//    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        navigationController?.setNavigationBarHidden(false, animated: true)
//        navigationController?.navigationBar.isHidden = false
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
//        navigationController?.setNavigationBarHidden(false, animated: true)
//        navigationController?.navigationBar.isHidden = false
        
    }

    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationItem.hidesSearchBarWhenScrolling = true
        navigationController?.navigationBar.isHidden = true
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "通讯录".localized()
        view.backgroundColor = .white
        
        initView()
        bindData()

        
//        let titleLbl = UILabel()
//        titleLbl.font = UIFont(name: "PingFangSC-Medium", size: 18)
//        titleLbl.textColor = .init(hexString: "#333333")
//        titleLbl.text =  "通讯录".localized()
//        self.navigationItem.titleView = titleLbl
//        
//        
//        let addItem: UIBarButtonItem = {
//                    let v = UIBarButtonItem()
//                    v.image = UIImage(nameInBundle: "contact_add_icon")
//                    v.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)
//                    v.rx.tap.subscribe(onNext: { [weak self] in
//                        let vc = AddTableViewController()
//                        vc.hidesBottomBarWhenPushed = true
//                        self?.navigationController?.pushViewController(vc, animated: true)
//                    }).disposed(by: _disposeBag)
//                    return v
//                }()
//                
//                navigationItem.rightBarButtonItems = [addItem]
    }
    
    

    private func initView() {
        
//        let searchC: UISearchController = {
//            let v = UISearchController(searchResultsController: resultC)
//            ///关掉交互 实现自定义跳转
//            v.searchBar.searchTextField.isUserInteractionEnabled = false
//            v.searchResultsUpdater = resultC
//            v.searchBar.placeholder = "搜索".innerLocalized()
//            v.obscuresBackgroundDuringPresentation = false
//            v.isActive = false
//            let tap = UITapGestureRecognizer()
//            tap.rx.event.subscribe(onNext: { [weak self] _ in
//                let vc = GlobalSearchViewController()
//                vc.hidesBottomBarWhenPushed = true
//                self?.navigationController?.pushViewController(vc, animated: true)
//            }).disposed(by: _disposeBag)
//            v.searchBar.addGestureRecognizer(tap)
//            return v
//        }()
//        navigationItem.searchController = searchC
        
        
        
        
//        resultC.selectUserCallBack = { [weak self] uid in
//            let vc = UserDetailTableViewController(userId: uid, groupId: nil, userDetailFor: .card)
//            self?.navigationController?.pushViewController(vc, animated: true)
//        }
        
        view.addSubview(_headerNavView)
//        _headerView.backgroundColor = .red
        _headerNavView.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
        }

        view.addSubview(_tableView)
        _tableView.tableHeaderView = headerView
        _tableView.snp.makeConstraints { make in
            make.top.equalTo(_headerNavView.snp.bottom)
            make.leading.bottom.trailing.equalToSuperview()
        }
    }
    
    lazy var headerView: listTableHeader = {
        
        let r = listTableHeader(frame: CGRectMake(0, 0, UIScreen.main.bounds.width, 252+68))
        r.addFriendView.bindData(item: listTableHeader.MenuItem(title: "添加好友".innerLocalized(), icon: UIImage(named: "friend_list_add_friend_icon")))
        r.addGroupChatView.bindData(item: listTableHeader.MenuItem(title: "添加群聊".innerLocalized(), icon: UIImage(named: "friend_list_add_group_chat_icon")))
        r.creatGroupChatView.bindData(item: listTableHeader.MenuItem(title: "创建群聊".innerLocalized(), icon: UIImage(named: "friend_list_creat_group_chat_icon")))
        r.videoMettingView.bindData(item: listTableHeader.MenuItem(title: "视频会议".innerLocalized(), icon: UIImage(named: "friend_list_video_metting_icon")))
        let data:[listTableHeader.MenuItem] = [listTableHeader.MenuItem(title: "新的好友".innerLocalized(), icon: UIImage(named: "friend_list_group_icon")),
                                               listTableHeader.MenuItem(title: "newGroup".innerLocalized(), icon: UIImage(named: "friend_list_group_new_icon")),
                                               listTableHeader.MenuItem(title: "群聊".localized(), icon: UIImage(named: "friend_list_new_friend_icon"))]
        r.newFriendView.bindData(item: data[0])
        r.newGroupView.bindData(item: data[1])
        r.groupView.bindData(item: data[2])
        r.lblClick = { [weak self] index in
            print("-----" , index)
        }
        r.addFriendClick = { [weak self] in
            
            print("-----" , "addFriendClick")
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
        r.addGroupChatClick = { [weak self] in
            
            print("-----" , "addGroupChatClick")
            let vc = SearchGroupViewController()
            vc.hidesBottomBarWhenPushed = true
            self?.navigationController?.pushViewController(vc, animated: true)
            vc.didSelectedItem = { [weak self] id in
                let vc = GroupDetailViewController(groupId: id)
                self?.navigationController?.pushViewController(vc, animated: true)
            }
            
        }
        r.creatGroupChatClick = { [weak self] in
            
            print("-----" , "creatGroupChatClick")
            self?.creatGroupChat(groupType: .working)
            
        }
        r.videoMettingClick = { [weak self] in
            
            print("-----" , "videoMettingClick")
            let vc = LiveRecordsViewController()
            vc.hidesBottomBarWhenPushed = true
            self?.navigationController?.pushViewController(vc, animated: true)
            
        }
        r.friendClick = { [weak self] in
            
            print("-----" , "friendClick")
            
            ApplicationStorage.lastFriendApplicationReadTime = ApplicationStorage.lastFriendApplicationTime
            
            let vc = NewFriendListViewController()
            vc.hidesBottomBarWhenPushed = true
            self?.navigationController?.pushViewController(vc, animated: true)
            
//            if let handler = OIMApi.gotoNewFriendHandle {
//                
//                handler(self!, { res in
//                   
//                })
//            }
            
        }
        r.newGroupClick = { [weak self] in
            ApplicationStorage.lastGroupApplicationReadTime = ApplicationStorage.lastGroupApplicationTime

            let vc = GroupApplicationTableViewController()
            vc.hidesBottomBarWhenPushed = true
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        r.groupClick = { [weak self] in
            print("-----" , "groupClick")
            
            let vc = GroupListViewController()
            vc.hidesBottomBarWhenPushed = true
            self?.navigationController?.pushViewController(vc, animated: true)
        }
//        let tap = UITapGestureRecognizer()
//        tap.rx.event.subscribe(onNext: { [weak self] _ in
//            let vc = GlobalSearchViewController()
//            vc.hidesBottomBarWhenPushed = true
//            self?.navigationController?.pushViewController(vc, animated: true)
//        }).disposed(by: _disposeBag)
//        r.searchView.addGestureRecognizer(tap)
        return r
    }()
    
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
        
        _viewModel.lettersRelay.distinctUntilChanged().subscribe(onNext: { [weak self] (values: [String]) in
            guard let sself = self else { return }
            self?.resultC.dataList = sself._viewModel.myFriends
            self?._tableView.sc_indexViewDataSource = values
            self?._tableView.sc_startSection = 0
            self?._tableView.reloadData()
        }).disposed(by: _disposeBag)
        
        _viewModel.reloadTab.subscribe(onNext: { [weak self] (values: [UserInfo]) in
            self?._tableView.reloadData()
        }).disposed(by: _disposeBag)
        
        
        contactsViewModel.newFriendCountRelay.map { $0 == 0 }.bind(to: headerView.newFriendView.unreadLabel.rx.isHidden).disposed(by: _disposeBag)
        contactsViewModel.newGroupCountRelay.map { $0 == 0 }.bind(to: headerView.newGroupView.unreadLabel.rx.isHidden).disposed(by: _disposeBag)
        contactsViewModel.newFriendCountRelay.map { "\($0 > 99 ? "99+" : "\($0)")" }.bind(to: headerView.newFriendView.unreadLabel.rx.text).disposed(by: _disposeBag)
        contactsViewModel.newGroupCountRelay.map { "\($0 > 99 ? "99+" : "\($0)")" }.bind(to: headerView.newGroupView.unreadLabel.rx.text).disposed(by: _disposeBag)
        contactsViewModel.frequentContacts.asDriver().drive { [weak self] _ in
//            self?.tableView.reloadData()
        }.disposed(by: _disposeBag)
        contactsViewModel.companyDepartments.asDriver().drive { [weak self] _ in
//            self?.tableView.reloadData()
        }.disposed(by: _disposeBag)
        contactsViewModel.getFriendApplications()
        contactsViewModel.getGroupApplications()
        
    }

    deinit {
        print("dealloc \(type(of: self))")
    }
}

extension FriendListViewController: UITableViewDataSource, UITableViewDelegate {
    public func numberOfSections(in _: UITableView) -> Int {
        return _viewModel.lettersRelay.value.count
    }

    public func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _viewModel.contactSections[section].count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FriendListUserTableViewCell.className) as! FriendListUserTableViewCell
        let user: UserInfo = _viewModel.contactSections[indexPath.section][indexPath.row]
//        cell.titleLabel.text = SuperStringUtil.getUserState(showname: user.nickname!).n
//        cell.avatarImageView.setAvatar(url: user.faceURL, text: user.nickname, onTap: nil)
        cell.bindData(user: user)
        return cell
    }

    public func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user: UserInfo = _viewModel.contactSections[indexPath.section][indexPath.row]
        if let callBack = selectCallBack {
            callBack(user)
            return
        }
//        let vc = UserDetailTableViewController(userId: user.userID, groupId: nil, userDetailFor: .card)
//        navigationController?.pushViewController(vc, animated: true)
        
        if let handler = OIMApi.gotoUserMessageHandle {
            handler(self, String(user.userID), "", "",{res in

            })
        }
        
    }

    public func tableView(_: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let name = _viewModel.lettersRelay.value[section]
        let header = ViewUtil.createSectionHeaderWith(text: name)
        header.backgroundColor = .white
        return header
    }

    public func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        return 33
    }

    public func tableView(_: UITableView, heightForFooterInSection _: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
}



class listTableHeader: UIView {
    var addFriendClick: (() -> Void)!
    var addGroupChatClick: (() -> Void)!
    var creatGroupChatClick: (() -> Void)!
    var videoMettingClick: (() -> Void)!
    var friendClick: (() -> Void)!
    var groupClick: (() -> Void)!
    var lblClick: ((Int) -> Void)!
    var newGroupClick:(() -> ())!
   
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        let width = (UIScreen.main.bounds.size.width - 16*2 - 8*3)/4

        addSubview(addFriendView)
        addSubview(addGroupChatView)
        addSubview(creatGroupChatView)
        addSubview(videoMettingView)
        addSubview(newFriendView)
        addSubview(groupView)
        addSubview(newGroupView)
//        addSubview(searchView)
        addSubview(chooseView)
//        searchView.snp.makeConstraints { make in
//            make.leading.trailing.equalToSuperview().inset(16.w)
//            make.top.equalTo(4)
//            make.height.equalTo(34)
//        }
        
        addFriendView.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.width.equalTo(width)
            make.height.equalTo(58)
            make.top.equalTo(0)
        }
        addGroupChatView.snp.makeConstraints { make in
            make.left.equalTo(addFriendView.snp_right).offset(8)
            make.width.height.top.equalTo(addFriendView)
        }
        creatGroupChatView.snp.makeConstraints { make in
            make.left.equalTo(addGroupChatView.snp_right).offset(8)
            make.width.height.top.equalTo(addFriendView)
        }
        videoMettingView.snp.makeConstraints { make in
            make.left.equalTo(creatGroupChatView.snp_right).offset(8)
            make.width.height.top.equalTo(addFriendView)
        }
        newFriendView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(59)
            make.top.equalTo(addFriendView.snp_bottom).offset(10)
        }
        
        newGroupView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(newFriendView.snp_bottom)
            make.height.equalTo(59)
        }
        
        groupView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(newGroupView.snp_bottom)
            make.height.equalTo(59)
        }
        
        chooseView.snp.makeConstraints { make in
            make.top.equalTo(groupView.snp_bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(44)
        }
        
        
    }
    
    
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
//    lazy var searchBar: UISearchBar = {
//            let v = UISearchBar(frame: CGRectZero)
//            v.searchBarStyle = .minimal
//            v.placeholder = "search".innerLocalized()
//            v.searchTextField.isEnabled = false
//            return v
//        }()
    
//    lazy var searchView: UIView = {
//        let v = UIView()
//        v.backgroundColor = .init(hexString: "#F5F5F5")
//        v.clipsToBounds = true
//        v.layer.cornerRadius = 17.w
//        v.isUserInteractionEnabled = true
//        
//        let searchImg = UIImageView(image: UIImage(named: "search_gray"))
//        v.addSubview(searchImg)
//        searchImg.snp.makeConstraints { make in
//            make.left.equalToSuperview().offset(14.w)
//            make.width.height.equalTo(15.w)
//            make.centerY.equalToSuperview()
//        }
//        
//        let titleLbl = UILabel()
//        titleLbl.text = "search".innerLocalized()
//        titleLbl.font = UIFont(name: "PingFangSC-Regular", size: 13)
//        titleLbl.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
//        v.addSubview(titleLbl)
//        titleLbl.snp.makeConstraints { make in
//            make.left.equalToSuperview().offset(39.w)
//            make.centerY.equalToSuperview()
//        }
//        return v
//    }()
    
    lazy var addFriendView:ButtonItem = {
        let r = ButtonItem()
        r.clipsToBounds = true
        r.layer.cornerRadius = 8
        r.backgroundColor = .init(hexString: "#F3F5F9")
        r.tag = 2096
        r.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(chooseTopView(_:)))
        r.addGestureRecognizer(tap)
        return r
    }()
    
    lazy var addGroupChatView:ButtonItem = {
        let r = ButtonItem()
        r.clipsToBounds = true
        r.layer.cornerRadius = 8
        r.backgroundColor = .init(hexString: "#F3F5F9")
        r.tag = 2097
        r.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(chooseTopView(_:)))
        r.addGestureRecognizer(tap)
        return r
    }()
    
    lazy var creatGroupChatView:ButtonItem = {
        let r = ButtonItem()
        r.clipsToBounds = true
        r.layer.cornerRadius = 8
        r.backgroundColor = .init(hexString: "#F3F5F9")
        r.tag = 2098
        r.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(chooseTopView(_:)))
        r.addGestureRecognizer(tap)
        return r
    }()
    
    lazy var videoMettingView:ButtonItem = {
        let r = ButtonItem()
        r.clipsToBounds = true
        r.layer.cornerRadius = 8
        r.backgroundColor = .init(hexString: "#F3F5F9")
        r.tag = 2099
        r.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(chooseTopView(_:)))
        r.addGestureRecognizer(tap)
        return r
    }()

    
    lazy var newFriendView: ItemView = {
        let r = ItemView()
        r.tag = 2100
        r.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(chooseTopView(_:)))
        r.addGestureRecognizer(tap)
        return r
    }()
    
    lazy var newGroupView: ItemView = {
        let r = ItemView()
        r.tag = 2101
        r.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(chooseTopView(_:)))
        r.addGestureRecognizer(tap)
        return r
    }()
    
    lazy var groupView: ItemView = {
        let r = ItemView()
        r.tag = 2102
        r.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(chooseTopView(_:)))
        r.addGestureRecognizer(tap)
        return r
    }()
    
    lazy var chooseView: ChooseView = {
        let r = ChooseView()
        r.lblClick = { [weak self] index in
            self?.lblClick(index)
        }
        return r
    }()
    
    
    @objc func chooseTopView(_ sender: UITapGestureRecognizer) {
        
        if sender.view?.tag == 2096 {
            addFriendClick()
        }else if sender.view?.tag == 2097 {
            addGroupChatClick()
        } else if sender.view?.tag == 2098 {
            creatGroupChatClick()
        } else if sender.view?.tag == 2099 {
            videoMettingClick()
        }  else if sender.view?.tag == 2100 {
            friendClick()
        }  else if sender.view?.tag == 2102 {
            groupClick()
        } else {
            newGroupClick()
        }
    }
    
    public struct MenuItem {
        let title: String
        let icon: UIImage?
        public init(title: String, icon: UIImage?) {
            self.title = title
            self.icon = icon
        }
    }
    class ButtonItem: UIView{
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            addSubview(iconImageView)
            addSubview(titleLabel)
            
            iconImageView.snp.makeConstraints { make in
                make.top.equalTo(9)
                make.width.height.equalTo(24)
                make.centerX.equalToSuperview()
            }
            
            titleLabel.snp.makeConstraints { make in
                make.top.equalTo(37)
                make.height.equalTo(10)
                make.centerX.equalToSuperview()
            }
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        let iconImageView: UIImageView = {
            let v = UIImageView()
            return v
        }()

        let titleLabel: UILabel = {
            let v = UILabel()
            v.font =  UIFont(name: "PingFangSC-Medium", size: 11)
//            v.textColor = UIColor(red: 0.533, green: 0.533, blue: 0.533, alpha: 1)
            v.textColor = .init(hexString: "#333333")
            return v
        }()
        
        func bindData(item :MenuItem) {
            iconImageView.image = item.icon
            titleLabel.text = item.title
        }
    }
    class ItemView: UIView {
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            addSubview(iconImageView)
            addSubview(titleLabel)
            addSubview(lineView)
            addSubview(unreadLabel)
            
            iconImageView.snp.makeConstraints { make in
                make.left.equalTo(16)
                make.width.height.equalTo(40)
                make.centerY.equalToSuperview()
            }
            
            titleLabel.snp.makeConstraints { make in
                make.left.equalTo(iconImageView.snp_right).offset(12)
                make.centerY.equalToSuperview()
            }
            
            lineView.snp.makeConstraints { make in
                make.left.equalTo(titleLabel.snp_left)
                make.right.equalToSuperview()
                make.bottom.equalToSuperview()
                make.height.equalTo(1)
            }
            
            unreadLabel.snp.makeConstraints { make in
                make.right.equalTo(-10)
                make.centerY.equalToSuperview()
                make.width.equalTo(30)
                make.height.equalTo(24)
            }
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        let iconImageView: UIImageView = {
            let v = UIImageView()
            v.clipsToBounds = true
            v.layer.cornerRadius = 20
            return v
        }()

        let titleLabel: UILabel = {
            let v = UILabel()
            v.font =  UIFont(name: "PingFangSC-Medium", size: 18)
//            v.textColor = UIColor(red: 0.533, green: 0.533, blue: 0.533, alpha: 1)
            v.textColor = .init(hexString: "#333333")
            return v
        }()
        
        let lineView: UIView = {
            let v = UIView()
            v.backgroundColor = .init(hexString: "#d9d9d9")
            return v
        }()

        
//        lazy var badgeLabel: UILabel = {
//            let r = UILabel()
//            r.text = ""
//            r.textColor = .white
//            r.backgroundColor = .red
//            r.textAlignment = .center
//            r.clipsToBounds = true
//            r.layer.cornerRadius = 12
//            r.isHidden = true
//            return r
//        }()
        
        let unreadLabel: RoundCornerLayoutLabel = {
            let v = RoundCornerLayoutLabel(roundCorners: .allCorners, radius: nil)
            v.font = .f12
            v.backgroundColor = .cFF381F
            v.textColor = .white
            v.textAlignment = .center
            v.contentInset = UIEdgeInsets(top: 1, left: 4, bottom: 1, right: 4)
            v.isHidden = true
            return v
        }()
        
        
        func bindData(item :MenuItem, hideline: Bool = false) {
            iconImageView.image = item.icon
            titleLabel.text = item.title
            
            if hideline {
                lineView.isHidden = true
            }
        }
        
        
    }
    
    class ChooseView: UIView {
        
        var index = 0
        var lblClick: ((Int) -> Void)!
        
        var firstLbl: UILabel!
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
//            let Arr = ["MyFriend".localized(), "MeFollow".localized(), "FollowMe".localized()]
            let Arr = ["MyFriend".localized()]
            let lblWidth = UIScreen.main.bounds.width / 4
            var lastLbl : UILabel? = nil
            for index  in  0..<Arr.count {
                let r = UILabel()
                if (index == 0) {
                    firstLbl = r
                }
                r.text = Arr[index]
                r.font = index == 0 ? UIFont(name: "PingFangSC-Medium", size: 18) : UIFont(name: "PingFangSC-Medium", size: 14)
                r.textColor = index == 0 ?  UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1) : UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
                r.textAlignment = .center
                r.tag = 2000 + index
                addSubview(r)
                
                if index != 0 {
                    lastLbl = viewWithTag(1999 + index) as? UILabel
                }
                
                if index == 0 {
                    r.snp.makeConstraints { make in
                        make.left.equalTo(16)
                        make.top.bottom.equalTo(0)
                    }
                } else {
                    r.snp.makeConstraints { make in
                        make.left.equalTo(lastLbl!.snp_right).offset(35)
                        make.top.bottom.equalTo(0)
                    }
                }
                
                
//                r.snp.makeConstraints { make in
//                    make.left.equalTo(lblWidth * CGFloat(index) + 16)
//                    make.top.bottom.equalTo(0)
//                    make.width.equalTo(lblWidth)
//                }
                
                let tap = UITapGestureRecognizer(target: self, action: #selector(changeChooseLbl(sender:)))
                r.addGestureRecognizer(tap)
                r.isUserInteractionEnabled = true
            }
            
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        
        @objc func changeChooseLbl(sender: UITapGestureRecognizer) {
//            let count = sender.view!.tag - 2000
//            refreshUI(count)
//            lblClick(count)
        }
        
        func refreshUI(_ currentIndex: Int) {
            for index  in  0...2 {
                let r = viewWithTag(index + 2000) as! UILabel
                r.font = index == currentIndex ? UIFont(name: "PingFangSC-Medium", size: 18) : UIFont(name: "PingFangSC-Medium", size: 14)
                r.textColor = index == currentIndex ?  UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1) : UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
            }
        }
        
    }
}
