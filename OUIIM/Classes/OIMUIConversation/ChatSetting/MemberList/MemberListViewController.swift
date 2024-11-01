
import RxSwift
import OUICore
import OUICoreView
import MJRefresh
import ProgressHUD

class MemberListViewController: UIViewController {
    public var onTap: ((GroupMemberInfo) -> Void)?
    
    private lazy var _tableView: UITableView = {
        let v = UITableView()
        //        let config: SCIndexViewConfiguration = {
        //            let v = SCIndexViewConfiguration(indexViewStyle: SCIndexViewStyle.default)!
        //            v.indexItemRightMargin = 8
        //            v.indexItemTextColor = UIColor(hexString: "#555555")
        //            v.indexItemSelectedBackgroundColor = UIColor(hexString: "#57be6a")
        //            v.indexItemsSpace = 4
        //            v.indicatorCenterYOffset = 60
        //            return v
        //        }()
        //        v.sc_indexViewConfiguration = config
        //        v.sc_translucentForTableViewInNavigationBar = true
        v.register(FriendListUserTableViewCell.self, forCellReuseIdentifier: FriendListUserTableViewCell.className)
        //        v.dataSource = self
        //        v.delegate = self
        v.rowHeight = 64.h
        v.separatorColor = .clear
        v.tableFooterView = UIView()
        
        let footer = MJRefreshAutoNormalFooter(refreshingBlock: { [weak self] in
            self?._viewModel.getMoreMembers(completion: { (isNoMore: Bool) in
                if isNoMore {
                    v.mj_footer?.endRefreshingWithNoMoreData()
                } else {
                    v.mj_footer?.endRefreshing()
                }
            })
        })
        footer.isAutomaticallyRefresh = false
        v.mj_footer = footer
        
        if #available(iOS 15.0, *) {
            v.sectionHeaderTopPadding = 0
        }
        
        return v
    }()
    
    lazy var headerTableView: UITableView = {
        let v = UITableView()
        v.register(FriendListUserTableViewCell.self, forCellReuseIdentifier: FriendListUserTableViewCell.className)
        v.separatorColor = .clear
        v.rowHeight = 64.h
        if #available(iOS 15.0, *) {
            v.sectionHeaderTopPadding = 0
        }
        v.tableFooterView = UIView()
        
        return v
    }()
    
    lazy var header: UIView = {
        let v = UIView()
        
        return v
    }()
    
    private let _viewModel: MemberListViewModel
    private let _disposeBag = DisposeBag()
    private lazy var resultC: FriendListResultViewController = {
        let v = FriendListResultViewController()
        v.selectUserCallBack = { [weak self] (userID: String) in
//            let vc = UserDetailTableViewController.init(userId: userID, groupId: self?._viewModel.groupInfo.groupID)
//            self?.navigationController?.pushViewController(vc, animated: true)
            
            if let handler = OIMApi.gotoUserMessageHandle {
                handler(self!, String(userID), "", "",{res in

                })
            }
        }
        
        return v
    }()
    
    
    private lazy var addItem: PopoverTableViewController.MenuItem = {
        let v = PopoverTableViewController.MenuItem(title: "邀请".innerLocalized() + "成员".innerLocalized(), icon: UIImage(nameInBundle: "chat_menu_add_friend_icon")) { [weak self] in
            guard let self else { return }
            
#if ENABLE_ORGANIZATION
            let vc = MyContactsViewController(types: [.friends, .staff], multipleSelected: true)
#else
            let vc = MyContactsViewController(types: [.friends], multipleSelected: true)
#endif
            vc.title = "邀请群成员".innerLocalized()
            let blocked = _viewModel.membersRelay.value.compactMap({ $0.userID }) + [IMController.shared.uid]
            
            vc.selectedContact(blocked: blocked) { [weak self] (r: [ContactInfo]) in
                guard let self else { return }
                
                ProgressHUD.animate()
                let groupID = self._viewModel.groupInfo.groupID
                let uids = r.compactMap { $0.ID }
                IMController.shared.inviteUsersToGroup(groupId: groupID, uids: uids) { [weak vc] in
//                    ProgressHUD.success("invitationSuccessful".innerLocalized())
                    ProgressHUD.dismiss()
                    if let handler = OIMApi.showTipHandle {
                                    
                        handler("invitationSuccessful".innerLocalized(), { res in
                           
                        })
                    }
                    vc?.navigationController?.popViewController(animated: true)
                }
            }
            navigationController?.pushViewController(vc, animated: true)
        }
        
        return v
    }()
    
    private lazy var deleteItem: PopoverTableViewController.MenuItem = {
        let v = PopoverTableViewController.MenuItem(title: "移除".innerLocalized() + "成员".innerLocalized(), icon: UIImage(nameInBundle: "chat_menu_create_work_group_icon")) { [weak self] in
            guard let self else { return }
            
            let vc = SelectContactsViewController(types: [.members], sourceID: self._viewModel.groupInfo.groupID)
            let owner = self._viewModel.ownerAndAdminRelay.value.first(where: { [weak self] m in
                return m.roleLevel == .owner
            })?.userID
            
            var blocked = _viewModel.ownerAndAdminRelay.value.compactMap({ $0.userID })
            
            if owner == IMController.shared.uid {
                blocked = [IMController.shared.uid]
            }
            
            vc.selectedContact(hasSelected: [], blocked: blocked != nil ? blocked : []) { [weak vc] (_, users: [ContactInfo]) in
                let groupID = self._viewModel.groupInfo.groupID
                
                ProgressHUD.animate()
                let uids = users.compactMap { $0.ID }
                IMController.shared.kickGroupMember(groupId: groupID, uids: uids) { _ in
                    ProgressHUD.dismiss()
                    vc?.navigationController?.popViewController(animated: true)
                }
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        return v
    }()
    
    init(viewModel: MemberListViewModel) {
        _viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    private let _menuView = PopoverTableViewController()
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _viewModel.getOwnerAndAdmin()
        navigationController?.navigationBar.isHidden = false
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "groupMember".innerLocalized()
        navigationItem.hidesSearchBarWhenScrolling = false
        
        initView()
        bindData()
        _tableView.mj_footer?.beginRefreshing()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationItem.searchController?.isActive = false
    }
    
    private func initView() {
        let searchC: UISearchController = {
            let v = UISearchController(searchResultsController: resultC)
            v.searchResultsUpdater = resultC
            v.delegate = self
            v.searchBar.placeholder = "search".innerLocalized()
            v.obscuresBackgroundDuringPresentation = false
            
            return v
        }()
        
        definesPresentationContext = true
        navigationItem.searchController = searchC
        
        view.addSubview(_tableView)
        _tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        _tableView.tableHeaderView = headerTableView
        
        _menuView.items = [addItem]
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: .init(nameInBundle: "common_more_btn_icon"), style: .done, target: self, action: #selector(tapMore(_:)))
    }
    
    @objc func tapMore(_ sender: UIBarButtonItem) {
        _menuView.show(in: self, itemSender: sender)
    }
    
    private func bindData() {
        
        _viewModel.ownerAndAdminRelay.subscribe(onNext: { [weak self] infos in
            guard let sself = self else { return }
            var headerFrame = sself.headerTableView.frame
            
            headerFrame.size.height = CGFloat(infos.count) * 64.h
            sself.headerTableView.frame = headerFrame
            sself._tableView.tableHeaderView = sself.headerTableView
            
            if infos.contains(where: { member in
                return member.userID == IMController.shared.uid
            }) {
                sself._menuView.items = [sself.addItem, sself.deleteItem]
            } else {
                sself._menuView.items = [sself.addItem]
            }
        })
        
        _viewModel.ownerAndAdminRelay.bind(to: headerTableView.rx.items(cellIdentifier: FriendListUserTableViewCell.className,
                                                                        cellType: FriendListUserTableViewCell.self)) {[weak self] _, model, cell in
            
            cell.titleLabel.text = SuperStringUtil.getUserState(showname: model.nickname ?? "").n
            // admin or owner
            if model.isOwnerOrAdmin {
                cell.trainingLabel.textColor = .c8E9AB0
                cell.trainingLabel.font = .f17
                cell.trainingLabel.text = model.roleLevelString
            } else {
                cell.trainingLabel.text = nil
            }
            cell.avatarImageView.setAvatar(url: model.faceURL, text: model.nickname)
        }.disposed(by: _disposeBag)
        
        headerTableView.rx.modelSelected(GroupMemberInfo.self).subscribe(onNext: { [weak self] member in
            guard let self, _viewModel.groupInfo.lookMemberInfo == 0 else { return }
            
//            let vc = UserDetailTableViewController(userId: member.userID ?? "", groupId: member.groupID)
//            navigationController?.pushViewController(vc, animated: true)
            
            if let handler = OIMApi.gotoUserMessageHandle {
                handler(self, String(member.userID ?? "”"), member.nickname ?? "", member.faceURL ?? "",{res in

                })
            }
            
        }).disposed(by: _disposeBag)
        
        _viewModel.membersRelay.bind(to: _tableView.rx.items(cellIdentifier: FriendListUserTableViewCell.className,
                                                             cellType: FriendListUserTableViewCell.self)) {[weak self] _, model, cell in
            cell.titleLabel.text = SuperStringUtil.getUserState(showname: model.nickname ?? "").n
            cell.avatarImageView.setAvatar(url: model.faceURL, text: model.nickname)
            
        }.disposed(by: _disposeBag)
        
        _tableView.rx.modelSelected(GroupMemberInfo.self).subscribe(onNext: { [weak self] member in
            guard let self, _viewModel.groupInfo.lookMemberInfo == 0 else { return }
            if onTap != nil {
                onTap!(member)
            } else {
//                let vc = UserDetailTableViewController(userId: member.userID ?? "", groupId: member.groupID)
//                navigationController?.pushViewController(vc, animated: true)
                if let handler = OIMApi.gotoUserMessageHandle {
                    handler(self, String(member.userID ?? "”"), member.nickname ?? "", member.faceURL ?? "",{res in

                    })
                }
            }
        }).disposed(by: _disposeBag)
        
        //        _viewModel.lettersRelay.subscribe(onNext: { [weak self] (values: [String]) in
        //            guard let sself = self else { return }
        //            self?.resultC.dataList = (sself._viewModel.members + sself._viewModel.ownerAndAdminRelay.value).compactMap {
        //                let item = UserInfo(userID: $0.userID!, nickname: $0.nickname, faceURL: $0.faceURL)
        //
        //                return item
        //            }
        //            self?._tableView.sc_indexViewDataSource = values
        //            self?._tableView.sc_refreshCurrentSectionOfIndexView()
        //            self?._tableView.reloadData()
        //        }).disposed(by: _disposeBag)
        //
        //        _viewModel.targetIndexRelay.subscribe(onNext: { [weak self] (index: IndexPath?) in
        //            guard let indexPath = index else { return }
        //            self?._tableView.scrollToRow(at: indexPath, at: UITableView.ScrollPosition.none, animated: false)
        //            self?._tableView.sc_refreshCurrentSectionOfIndexView()
        //        }).disposed(by: _disposeBag)
    }
    
    private func imageWithUIView(view: UIView) -> UIImage {
        UIGraphicsBeginImageContext(view.bounds.size)
        let ctx = UIGraphicsGetCurrentContext()
        view.layer.render(in: ctx!)
        let tImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        return tImage!;
    }
    
    
    deinit {
        print("dealloc \(type(of: self))")
    }
}

extension MemberListViewController: UISearchControllerDelegate {
    func willPresentSearchController(_ searchController: UISearchController) {
        resultC.dataList = (_viewModel.membersRelay.value + _viewModel.ownerAndAdminRelay.value).compactMap({ UserInfo(userID: $0.userID!, nickname: $0.nickname, faceURL: $0.faceURL)})
    }
}

//extension MemberListViewController: UITableViewDataSource, UITableViewDelegate {
//    func numberOfSections(in _: UITableView) -> Int {
//        return _viewModel.lettersRelay.value.count
//    }
//
//    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return _viewModel.contactSections[section].count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: FriendListUserTableViewCell.className) as! FriendListUserTableViewCell
//        let user: GroupMemberInfo = _viewModel.contactSections[indexPath.section][indexPath.row]
//        cell.titleLabel.text = user.nickname
//        cell.avatarImageView.setAvatar(url: user.faceURL, text: user.nickname, onTap: nil)
//        return cell
//    }
//
//    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
//        guard _viewModel.groupInfo.isMine || _viewModel.groupInfo.lookMemberInfo == 0 else { return }
//        let member: GroupMemberInfo = _viewModel.contactSections[indexPath.section][indexPath.row]
//        let vc = UserDetailTableViewController(userId: member.userID ?? "", groupId: member.groupID, groupInfo: self._viewModel.groupInfo)
//        navigationController?.pushViewController(vc, animated: true)
//    }
//
//    func tableView(_: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let name = _viewModel.lettersRelay.value[section]
//        let header = ViewUtil.createSectionHeaderWith(text: name)
//        return header
//    }
//
//    func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
//        return 33
//    }
//
//    func tableView(_: UITableView, heightForFooterInSection _: Int) -> CGFloat {
//        return CGFloat.leastNormalMagnitude
//    }
//}
