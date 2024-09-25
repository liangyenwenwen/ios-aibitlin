
import RxSwift
import OUICore
import OUICoreView


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

    private let _viewModel = FriendListViewModel()
    public lazy var contactsViewModel = ContactsViewModel()
    private let _disposeBag = DisposeBag()
    private lazy var resultC = FriendListResultViewController()

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationController?.navigationBar.isHidden = false
        
        _viewModel.getMyFriendList()
        contactsViewModel.getFriendApplications()
        contactsViewModel.getGroupApplications()
        contactsViewModel.queryMyDepartmentInfo()
        contactsViewModel.getFrequentUsers()
    }

    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationItem.hidesSearchBarWhenScrolling = true
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "通讯录".localized()
        view.backgroundColor = .white
        
        initView()
        bindData()
        
//        var textAttributes: [NSAttributedString.Key: AnyObject] = [:]
//                
//
//        textAttributes[.foregroundColor] = UIColor.red
//
//        textAttributes[.font] = UIFont.systemFont(ofSize: 18)
//
//        
//        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        
        let titleLbl = UILabel()
        titleLbl.font = UIFont(name: "PingFangSC-Medium", size: 18)
        titleLbl.textColor = .init(hexString: "#333333")
        titleLbl.text =  "通讯录".localized()
        self.navigationItem.titleView = titleLbl
        
        
        let addItem: UIBarButtonItem = {
                    let v = UIBarButtonItem()
                    v.image = UIImage(nameInBundle: "contact_add_icon")
                    v.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)
                    v.rx.tap.subscribe(onNext: { [weak self] in
                        let vc = AddTableViewController()
                        vc.hidesBottomBarWhenPushed = true
                        self?.navigationController?.pushViewController(vc, animated: true)
                    }).disposed(by: _disposeBag)
                    return v
                }()
                
                navigationItem.rightBarButtonItems = [addItem]
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
        
        
        
        
        resultC.selectUserCallBack = { [weak self] uid in
            let vc = UserDetailTableViewController(userId: uid, groupId: nil, userDetailFor: .card)
            self?.navigationController?.pushViewController(vc, animated: true)
        }

        view.addSubview(_tableView)
        _tableView.tableHeaderView = headerView
        _tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    lazy var headerView: listTableHeader = {
        
        let r = listTableHeader(frame: CGRectMake(0, 0, UIScreen.main.bounds.width, 210))
        let data:[listTableHeader.MenuItem] = [listTableHeader.MenuItem(title: "新关注我的朋友".innerLocalized(), icon: UIImage(named: "friend_list_group_icon")),
                                               listTableHeader.MenuItem(title: "群聊".localized(), icon: UIImage(named: "friend_list_new_friend_icon"))]
        r.newFriendView.bindData(item: data[0])
        r.groupView.bindData(item: data[1])
        r.lblClick = { [weak self] index in
            print("-----" , index)
        }
        r.friendClick = { [weak self] in
            
            print("-----" , "friendClick")
            
            ApplicationStorage.lastFriendApplicationReadTime = ApplicationStorage.lastFriendApplicationTime
            
            let vc = NewFriendListViewController()
            vc.hidesBottomBarWhenPushed = true
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        
        r.groupClick = { [weak self] in
            print("-----" , "groupClick")
            
            let vc = GroupListViewController()
            vc.hidesBottomBarWhenPushed = true
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        let tap = UITapGestureRecognizer()
        tap.rx.event.subscribe(onNext: { [weak self] _ in
            let vc = GlobalSearchViewController()
            vc.hidesBottomBarWhenPushed = true
            self?.navigationController?.pushViewController(vc, animated: true)
        }).disposed(by: _disposeBag)
        r.searchView.addGestureRecognizer(tap)
        return r
    }()

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
        
        
        contactsViewModel.newFriendCountRelay.map { $0 == 0 }.bind(to: headerView.newFriendView.badgeLabel.rx.isHidden).disposed(by: _disposeBag)
        contactsViewModel.newGroupCountRelay.map { $0 == 0 }.bind(to: headerView.groupView.badgeLabel.rx.isHidden).disposed(by: _disposeBag)
        contactsViewModel.newFriendCountRelay.map { "\($0)" }.bind(to: headerView.newFriendView.badgeLabel.rx.text).disposed(by: _disposeBag)
        contactsViewModel.newGroupCountRelay.map { "\($0)" }.bind(to: headerView.groupView.badgeLabel.rx.text).disposed(by: _disposeBag)
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
        cell.titleLabel.text = user.nickname!
        cell.avatarImageView.setAvatar(url: user.faceURL, text: user.nickname, onTap: nil)
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
    var friendClick: (() -> Void)!
    var groupClick: (() -> Void)!
    var lblClick: ((Int) -> Void)!
    
   
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        addSubview(newFriendView)
        addSubview(groupView)
        addSubview(searchView)
        addSubview(chooseView)
        searchView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16.w)
            make.top.equalTo(4)
            make.height.equalTo(34)
        }
        
        
        newFriendView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(58)
            make.top.equalTo(50)
        }
        
        groupView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(108)
            make.height.equalTo(58)
        }
        
        chooseView.snp.makeConstraints { make in
            make.top.equalTo(166)
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
    
    lazy var searchView: UIView = {
        let v = UIView()
        v.backgroundColor = .init(hexString: "#F5F5F5")
        v.clipsToBounds = true
        v.layer.cornerRadius = 17.w
        v.isUserInteractionEnabled = true
        
        let searchImg = UIImageView(image: UIImage(named: "search_gray"))
        v.addSubview(searchImg)
        searchImg.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(14.w)
            make.width.height.equalTo(15.w)
            make.centerY.equalToSuperview()
        }
        
        let titleLbl = UILabel()
        titleLbl.text = "search".innerLocalized()
        titleLbl.font = UIFont(name: "PingFangSC-Regular", size: 13)
        titleLbl.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        v.addSubview(titleLbl)
        titleLbl.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(39.w)
            make.centerY.equalToSuperview()
        }
        return v
    }()
    
    
    lazy var newFriendView: ItemView = {
        let r = ItemView()
        r.tag = 2100
        r.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(chooseTopView(_:)))
        r.addGestureRecognizer(tap)
        return r
    }()
    
    lazy var groupView: ItemView = {
        let r = ItemView()
        r.tag = 2101
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
        
        if sender.view?.tag == 2100 {
            friendClick()
        } else {
            groupClick()
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
    
    class ItemView: UIView {
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            addSubview(iconImageView)
            addSubview(titleLabel)
            addSubview(lineView)
            addSubview(badgeLabel)
            
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
            
            badgeLabel.snp.makeConstraints { make in
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
            v.textColor = UIColor(red: 0.533, green: 0.533, blue: 0.533, alpha: 1)
            return v
        }()
        
        let lineView: UIView = {
            let v = UIView()
            v.backgroundColor = .init(hexString: "#d9d9d9")
            return v
        }()

        
        lazy var badgeLabel: UILabel = {
            let r = UILabel()
            r.text = "10"
            r.textColor = .white
            r.backgroundColor = .red
            r.textAlignment = .center
            r.clipsToBounds = true
            r.layer.cornerRadius = 12
            return r
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
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            let Arr = ["MyFriend".localized(), "MeFollow".localized(), "FollowMe".localized()]
            let lblWidth = UIScreen.main.bounds.width / 4
            var lastLbl : UILabel? = nil
            for index  in  0...2 {
                let r = UILabel()
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
            let count = sender.view!.tag - 2000
            refreshUI(count)
            lblClick(count)
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
