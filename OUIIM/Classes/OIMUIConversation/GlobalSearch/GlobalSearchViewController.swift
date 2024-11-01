
import OUICore
import OUICoreView
import JXSegmentedView
import RxSwift
import RxCocoa
import RxDataSources
import ProgressHUD

class GlobalSearchViewController: UIViewController {
    
    var segmentedDataSource: JXSegmentedTitleDataSource = JXSegmentedTitleDataSource()
    let segmentedView = JXSegmentedView()
    
    lazy var listContainerView: JXSegmentedListContainerView! = {
        return JXSegmentedListContainerView(dataSource: self)
    }()
    
    //通过参数searchResultsController传nil来初始化UISearchController，意思是我们告诉search controller我们会用相同的视图控制器来展示我们的搜索结果，如果我们想要指定一个不同的view controller，那就会被替代为显示搜索结果。
    lazy var searchController: UISearchController = {
        let t = UISearchController(searchResultsController: nil)
        t.hidesNavigationBarDuringPresentation = false
        t.obscuresBackgroundDuringPresentation = false
        t.dimsBackgroundDuringPresentation = false
        t.searchBar.searchBarStyle = .prominent
        t.searchBar.sizeToFit()
        t.isActive = true
        t.searchBar.searchTextField.isUserInteractionEnabled = true
        t.searchBar.rx.cancelButtonClicked.subscribe(onNext: { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }).disposed(by: disposeBag)
        t.searchBar.rx.searchButtonClicked.subscribe(onNext: { [weak self] in
            print("click search")
            if let query = t.searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
//                ProgressHUD.animate()

                self?.viewModel.searchAll(query: query) {
//                    ProgressHUD.dismiss()
                }
            }
        }).disposed(by: disposeBag)
        return t
    }()
    
    let viewModel = GlobalSearchViewModel()
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemGroupedBackground
        navigationItem.titleView = searchController.searchBar
       
        definesPresentationContext = true
        
        
        
        //配置数据源相关配置属性
        segmentedDataSource.titles = ["综合".innerLocalized(),
                                      "联系人".innerLocalized(),
                                      "群组".innerLocalized(),
                                      "聊天记录".innerLocalized(),
                                      "文件".innerLocalized()]
        segmentedDataSource.titleNormalFont = .f17
        segmentedDataSource.titleSelectedFont = .f17
        segmentedDataSource.titleNormalColor = .c8E9AB0
        segmentedDataSource.titleSelectedColor = .c0089FF
        segmentedDataSource.isTitleColorGradientEnabled = true
        
        //segmentedViewDataSource一定要通过属性强持有！！！！！！！！！
        segmentedView.dataSource = segmentedDataSource
        segmentedView.delegate = self
        segmentedView.backgroundColor = .tertiarySystemBackground
        
        let indicator = JXSegmentedIndicatorLineView()
        indicator.indicatorColor = .c0089FF
        segmentedView.indicators = [indicator]
        view.addSubview(segmentedView)
        
        segmentedView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(50)
        }
        
        segmentedView.listContainer = listContainerView
        view.addSubview(listContainerView)
        
        listContainerView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(segmentedView.snp_bottom)
        }
        
//        __weak typeof(self) weakself = self;
//           if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
//               self.interactivePopGestureRecognizer.delegate = (id)weakself;
//           }
//      popGestureOpen()
    }
    
//    func popGestureOpen() {
//          if let ges = self.navigationController?.interactivePopGestureRecognizer?.view?.gestureRecognizers {
//              for item in ges {
//                  item.isEnabled = true
//              }
//          }
//      }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = (segmentedView.selectedIndex == 0)
        navigationController?.navigationBar.isHidden = false
        

    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        DispatchQueue.main.async { [self] in
 
            searchController.searchBar.becomeFirstResponder()
        }
        navigationController?.navigationBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    
}

extension GlobalSearchViewController: JXSegmentedViewDelegate {
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        if let dotDataSource = segmentedDataSource as? JXSegmentedDotDataSource {
            //先更新数据源的数据
            dotDataSource.dotStates[index] = false
            //再调用reloadItem(at: index)
            segmentedView.reloadItem(at: index)
        }
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = (segmentedView.selectedIndex == 0)
    }
    
    
}

extension GlobalSearchViewController: JXSegmentedListContainerViewDataSource {
    func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
        if let titleDataSource = segmentedView.dataSource as? JXSegmentedBaseDataSource {
            return titleDataSource.dataSource.count
        }
        return 0
    }
    
    func listContainerView(_ listContainerView: JXSegmentedListContainerView, initListAt index: Int) -> JXSegmentedListContainerViewListDelegate {
        return ListBaseViewController(index: index, viewModel: viewModel, listContainerView: listContainerView, segmentedView: segmentedView)
    }
}

class ListBaseViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    private let cellIdentifier = "cellIdentifier"
    private let cellIMoredentifier = "cellIMoredentifier"
    
    var listIndex = 0
    var searchViewModel: GlobalSearchViewModel = GlobalSearchViewModel()
    private var listContainerView: JXSegmentedListContainerView!
    private var segmentedView: JXSegmentedView!
    
    init(index: Int = 0, viewModel: GlobalSearchViewModel, listContainerView: JXSegmentedListContainerView, segmentedView: JXSegmentedView) {
        super.init(nibName: nil, bundle: nil)
        listIndex = index
        searchViewModel = viewModel
        self.listContainerView = listContainerView
        self.segmentedView = segmentedView
    }
    
    private var sectionItems: [[GlobalSearchRowType]] = [
        [.all],
        [.friends],
        [.groups],
        [.text],
        [.file],
    ]
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var allTableView: UITableView = {
        
        let t = UITableView(frame: .zero, style: .insetGrouped)
        t.register(FriendListUserTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        t.register(UITableViewCell.self, forCellReuseIdentifier: cellIMoredentifier)
        t.delegate = self
        t.tableFooterView = UIView()
        t.backgroundColor = .clear
        t.keyboardDismissMode = .onDrag
        t.sectionFooterHeight = 4
        t.sectionHeaderHeight = 26
        
        return t
    }()
    
    private let allBlankView: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        v.isHidden = true
        let lable = UILabel()
        lable.text = "searchNotFound".innerLocalized()
        lable.font = .f17
        lable.textColor = .c8E9AB0
        v.addSubview(lable)
        
        lable.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        return v
    }()
    
    lazy var friendsTableView: UITableView = {
        
        let t = UITableView()
        t.register(FriendListUserTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        t.tableFooterView = UIView()
        t.backgroundColor = .clear
        t.keyboardDismissMode = .onDrag
        
        return t
    }()
    
    private let friendsBlankView: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        v.isHidden = true
        let lable = UILabel()
        lable.text = "searchNotFound".innerLocalized()
        lable.font = .f17
        lable.textColor = .c8E9AB0
        v.addSubview(lable)
        
        lable.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        return v
    }()
    
    lazy var groupsTableView: UITableView = {
        
        let t = UITableView()
        t.register(FriendListUserTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        t.tableFooterView = UIView()
        t.backgroundColor = .clear
        t.keyboardDismissMode = .onDrag
        
        return t
    }()
    
    private let groupsBlankView: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        v.isHidden = true
        let lable = UILabel()
        lable.text = "searchNotFound".innerLocalized()
        lable.font = .f17
        lable.textColor = .c8E9AB0
        v.addSubview(lable)
        
        lable.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        return v
    }()
    
    lazy var textTableView: UITableView = {
        
        let t = UITableView()
        t.register(FriendListUserTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        t.tableFooterView = UIView()
        t.backgroundColor = .clear
        t.keyboardDismissMode = .onDrag
        
        return t
    }()
    
    private let textBlankView: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        v.isHidden = true
        let lable = UILabel()
        lable.text = "searchNotFound".innerLocalized()
        lable.font = .f17
        lable.textColor = .c8E9AB0
        v.addSubview(lable)
        
        lable.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        return v
    }()
    
    lazy var filesTableView: UITableView = {
        
        let t = UITableView()
        t.register(FriendListUserTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        t.tableFooterView = UIView()
        t.backgroundColor = .clear
        t.keyboardDismissMode = .onDrag
        
        return t
    }()
    
    private let filesBlankView: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        v.isHidden = true
        
        let lable = UILabel()
        lable.text = "searchNotFound".innerLocalized()
        lable.font = .f17
        lable.textColor = .c8E9AB0
        v.addSubview(lable)
        
        lable.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        return v
    }()
    
    private var searched: Bool {
        searchViewModel.searchedText != nil
    }
    
    private func initView() {
        allTableView.addSubview(allBlankView)
        allBlankView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(58.h)
        }
        
        friendsTableView.addSubview(friendsBlankView)
        friendsBlankView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(58.h)
        }
        
        groupsTableView.addSubview(groupsBlankView)
        groupsBlankView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(58.h)
        }
        
        textTableView.addSubview(textBlankView)
        textBlankView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(58.h)
        }
        
        filesTableView.addSubview(filesBlankView)
        filesBlankView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(58.h)
        }
    }
    
    func bindData() {
        
        let allDataSource = RxTableViewSectionedReloadDataSource<SectionModel<GlobalSearchRowType, Any>>(
            configureCell: {[weak self] (t, tv, indexPath, element) in
                let cell = tv.dequeueReusableCell(withIdentifier: self!.cellIdentifier) as! FriendListUserTableViewCell

                guard element != nil, let self else { return cell }
                
                if let info = element as? SearchUserInfo {
                    if info.userID == "-1" {
                        let c = tv.dequeueReusableCell(withIdentifier: cellIMoredentifier) as! UITableViewCell
                        c.accessoryType = .disclosureIndicator
                        c.textLabel?.text = info.nickname
                        c.textLabel?.font = .f17
                        c.textLabel?.textColor = .c0089FF
                        
                        return c
                    } else {
                        cell.titleLabel.text = info.nickname
                        cell.subtitleLabel.text = info.remark?.isEmpty == false ? ("备注：".innerLocalized() + (info.remark ?? "")) : nil
                        cell.avatarImageView.setAvatar(url: info.faceURL, text: info.nickname, onTap: nil)
                    }
                } else if let info = element as? GroupInfo {
                    if info.groupID == "-1" {
                        let c = tv.dequeueReusableCell(withIdentifier: cellIMoredentifier) as! UITableViewCell
                        c.accessoryType = .disclosureIndicator
                        c.textLabel?.text = info.groupName
                        c.textLabel?.font = .f17
                        c.textLabel?.textColor = .c0089FF
                        
                        return c
                    } else {
                        cell.titleLabel.text = info.groupName
                        cell.subtitleLabel.text = info.groupName?.isEmpty == false ? ("群ID：".innerLocalized() + info.groupID) : nil
                        cell.avatarImageView.setAvatar(url: info.faceURL, text: info.groupName, onTap: nil)
                    }
                } else {
                    if let info = element as? SearchResultItemInfo {
                        if info.conversationID == "-1" {
                            let c = tv.dequeueReusableCell(withIdentifier: cellIMoredentifier) as! UITableViewCell
                            c.accessoryType = .disclosureIndicator
                            c.textLabel?.text = info.showName
                            c.textLabel?.font = .f17
                            c.textLabel?.textColor = .c0089FF
                            
                            return c
                        } else {
                            cell.titleLabel.text = info.showName
                            cell.subtitleLabel.text = "\(info.messageCount)条相关的聊天记录"
                            cell.avatarImageView.setAvatar(url: info.faceURL, text: info.showName, onTap: nil)
                        }
                    }
                }
                
                return cell
            },
            titleForHeaderInSection: { dataSource, sectionIndex in
                return dataSource[sectionIndex].model.title
            }
        )
        
        searchViewModel.allRelay
            .bind(to: allTableView.rx.items(dataSource: allDataSource))
            .disposed(by: disposeBag)
        
        searchViewModel.allRelay
            .asObservable()
            .subscribe(onNext: { [weak self] items in
                guard let self, searched else { return}
                
                allBlankView.isHidden = !items.isEmpty
            })
            .disposed(by: disposeBag)
        
        searchViewModel.friendsRelay.bind(to: friendsTableView.rx.items(cellIdentifier: cellIdentifier, cellType: FriendListUserTableViewCell.self)) { (row, item, cell) in
            cell.titleLabel.text = item.nickname
            cell.subtitleLabel.text = item.remark?.isEmpty == false ? ("备注：".innerLocalized() + (item.remark ?? "")) : nil
            cell.avatarImageView.setAvatar(url: item.faceURL, text: item.nickname, onTap: nil)
        }.disposed(by: disposeBag)
        
        searchViewModel.friendsRelay
            .asObservable()
            .subscribe(onNext: { [weak self] items in
                guard let self, searched else { return}

                friendsBlankView.isHidden = !items.isEmpty
            })
            .disposed(by: disposeBag)
        
        friendsTableView.rx.modelSelected(SearchUserInfo.self).subscribe(onNext: { [weak self] (user: SearchUserInfo) in
//            let vc = UserDetailTableViewController(userId: user.userID!)
//            self?.navigationController?.pushViewController(vc, animated: true)
            if let handler = OIMApi.gotoUserMessageHandle {
                handler(self!, user.userID!, user.showName, user.faceURL ?? "",{res in
                })
            }
        }).disposed(by: disposeBag)
        
        searchViewModel.groupsRelay.bind(to: groupsTableView.rx.items(cellIdentifier: cellIdentifier, cellType: FriendListUserTableViewCell.self)) { (row, item, cell) in
            cell.titleLabel.text = item.groupName
            cell.subtitleLabel.text = "群ID：".innerLocalized() + item.groupID
            cell.avatarImageView.setAvatar(url: item.faceURL, text: item.groupName, onTap: nil)
        }.disposed(by: disposeBag)
        
        searchViewModel.groupsRelay
            .asObservable()
            .subscribe(onNext: { [weak self] items in
                guard let self, searched else { return}

                groupsBlankView.isHidden = !items.isEmpty
            })
            .disposed(by: disposeBag)
        
        groupsTableView.rx.modelSelected(GroupInfo.self).subscribe(onNext: { [weak self] (group: GroupInfo) in
            self?.toChatView(groupID: group.groupID)
        }).disposed(by: disposeBag)
        
        searchViewModel.textRelay.bind(to: textTableView.rx.items(cellIdentifier: cellIdentifier, cellType: FriendListUserTableViewCell.self)) { (row, item, cell) in
            cell.titleLabel.text = item.showName
            cell.subtitleLabel.text = "\(item.messageCount)条相关的聊天记录"
            cell.avatarImageView.setAvatar(url: item.faceURL, text: item.showName, onTap: nil)
        }.disposed(by: disposeBag)
        
        searchViewModel.textRelay
            .asObservable()
            .subscribe(onNext: { [weak self] items in
                guard let self, searched else { return}

                textBlankView.isHidden = !items.isEmpty
            })
            .disposed(by: disposeBag)
        
        textTableView.rx.modelSelected(SearchResultItemInfo.self).subscribe(onNext: { [weak self] (info: SearchResultItemInfo) in
                        
            if info.messageCount > 1 {
                let vc = MoreRecordsViewController(result: info, conversationID: info.conversationID, searchText: self?.searchViewModel.searchedText)
                self?.navigationController?.pushViewController(vc, animated: true)
            } else {
                let msg = info.messageList[0]
                self?.toChatView(conversationID: info.conversationID, anchorMessage: msg)
            }
        }).disposed(by: disposeBag)
        
        searchViewModel.filesRelay.bind(to: filesTableView.rx.items(cellIdentifier: cellIdentifier, cellType: FriendListUserTableViewCell.self)) { (row, item, cell) in
            cell.titleLabel.text = item.showName
            cell.subtitleLabel.text = "\(item.messageCount)条相关的聊天记录"
            cell.avatarImageView.setAvatar(url: item.faceURL, text: item.showName, onTap: nil)
        }.disposed(by: disposeBag)
        
        searchViewModel.filesRelay
            .asObservable()
            .subscribe(onNext: { [weak self] items in
                guard let self, searched else { return}

                filesBlankView.isHidden = !items.isEmpty
            })
            .disposed(by: disposeBag)
        
        filesTableView.rx.modelSelected(SearchResultItemInfo.self).subscribe(onNext: { [weak self] (info: SearchResultItemInfo) in
            self?.toChatView(conversationID: info.conversationID)
        }).disposed(by: disposeBag)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ProgressHUD.dismiss()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
        bindData()
        view.backgroundColor = .viewBackgroundColor
    }
    
    func toChatView(conversationID: String = "", groupID: String = "", anchorMessage: MessageInfo? = nil) {
        
        assert(conversationID.isEmpty || groupID.isEmpty)
        
        if !conversationID.isEmpty {
            IMController.shared.getConversation(conversationID: conversationID) { [weak self] (conversation: ConversationInfo?) in
                guard let self, let conversation else { return }

                var vc: UIViewController?
                
                if let anchorMessage {
                    vc = ChatViewControllerBuilder().build(conversation, anchorMessage: anchorMessage, hiddenInputBar: true)
                } else {
                    vc = ChatViewControllerBuilder().build(conversation)
                }
                
                vc!.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(vc!, animated: true)
                if let root = navigationController?.viewControllers.first {
                    navigationController?.viewControllers.removeAll(where: { controller in
                        controller != root && controller != vc!
                    })
                }
            }
        } else {
            IMController.shared.getConversation(sessionType: .superGroup, sourceId: groupID) { [weak self] conversation in
                guard let self, let conversation else { return }

                var vc = ChatViewControllerBuilder().build(conversation)
                vc.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(vc, animated: true)
                if let root = navigationController?.viewControllers.first {
                    navigationController?.viewControllers.removeAll(where: { controller in
                        controller != root && controller != vc
                    })
                }
            }
        }
    }
}

extension ListBaseViewController: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        if listIndex == 0 {
            return allTableView
        } else if listIndex == 1 {
            return friendsTableView
        } else if listIndex == 2 {
            return groupsTableView
        } else if listIndex == 3 {
            return textTableView
        } else if listIndex == 4 {
            return filesTableView
        }
        
        return view
    }
}

extension ListBaseViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let info = searchViewModel.allRelay.value[indexPath.section]
        if info.model == .friends {
            
            let friend = info.items[indexPath.row] as! SearchUserInfo
            guard let userID = friend.userID, userID != "-1" else {
                segmentedView.selectItemAt(index: 1)
                listContainerView.didClickSelectedItem(at: 1)
                return
            }
            
//            let vc = UserDetailTableViewController(userId: userID, groupId: nil)
//            self.navigationController?.pushViewController(vc, animated: true)
            if let handler = OIMApi.gotoUserMessageHandle {
                handler(self, userID, "", "",{res in
                })
            }
            
        } else if info.model == .groups {
            
            let group = info.items[indexPath.row] as! GroupInfo
            let groupID = group.groupID
            
            guard groupID != "-1" else {
                segmentedView.selectItemAt(index: 2)
                listContainerView.didClickSelectedItem(at: 2)
                return
            }
            toChatView(groupID: groupID)
        } else if info.model == .text {
            
            let info = info.items[indexPath.row] as! SearchResultItemInfo
            let conversationID = info.conversationID
            
            guard conversationID != "-1" else {
                segmentedView.selectItemAt(index: 3)
                listContainerView.didClickSelectedItem(at: 3)
                return
            }
            if info.messageCount > 1 {
                let vc = MoreRecordsViewController(result: info, conversationID: info.conversationID, searchText: searchViewModel.searchedText)
                navigationController?.pushViewController(vc, animated: true)
            } else {
                let msg = info.messageList[0]
                toChatView(conversationID: conversationID, anchorMessage: msg)
            }
        } else {
            let info = info.items[indexPath.row] as! SearchResultItemInfo

            let conversationID = info.conversationID
            
            guard conversationID != "-1" else {
                segmentedView.selectItemAt(index: 4)
                listContainerView.didClickSelectedItem(at: 4)
                return
            }
            let msg = info.messageList[indexPath.row]
            toChatView(conversationID: conversationID, anchorMessage: msg)
        }
    }
}
