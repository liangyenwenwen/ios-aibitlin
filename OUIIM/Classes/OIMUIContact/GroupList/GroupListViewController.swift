
import OUICore
import OUICoreView
import RxSwift
import ProgressHUD

class GroupListViewController: UIViewController {
    
    var selectCallBack: (([GroupInfo]) -> Void)?
    var chooseType:Int = 0
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.hidesSearchBarWhenScrolling = false
        
        navigationController?.navigationBar.isHidden = false
    
       
    }

    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationItem.hidesSearchBarWhenScrolling = true
        navigationController?.navigationBar.isHidden = false
//        navigationController?.setNavigationBarHidden(false, animated: false)
        
    }

    private lazy var createChatBtn: UIBarButtonItem = {
        let v = UIBarButtonItem()
        v.title = "发起群聊".innerLocalized()
        v.rx.tap.subscribe(onNext: { [weak self] in
            self?.newGroup(groupType: .working)
        }).disposed(by: _disposeBag)
        return v
    }()
    
    func newGroup(groupType: GroupType = .normal) {
        
        let vc = SelectContactsViewController()
        vc.selectedContact(hasSelected: []) { [weak self] (_, r: [ContactInfo]) in
            guard let sself = self else { return }
            
            let users = r.map{UserInfo(userID: $0.ID!, nickname: $0.name, faceURL: $0.faceURL)}
            let vc = NewGroupViewController(users: users, groupType: groupType)
            sself.navigationController?.pushViewController(vc, animated: true)
        }
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "我的群聊".localized()
        view.backgroundColor = .viewBackgroundColor
        
        initView()
        bindData()
        _viewModel.getMyGroups()
        navigationItem.rightBarButtonItem = addChatBtn
    }
    private lazy var addChatBtn: UIBarButtonItem = {
        let v = UIBarButtonItem()
        v.title = "创建".innerLocalized()
        v.tintColor = .init(hexString: "#388CEF")
        v.rx.tap.subscribe(onNext: { [weak self] in
            if self?.chooseType == 0{
                //创建
                self?.creatGroupChat(groupType: .working)
            }else{
                //添加
                let vc = SearchGroupViewController()
                vc.hidesBottomBarWhenPushed = true
                self?.navigationController?.pushViewController(vc, animated: true)
                vc.didSelectedItem = { [weak self] id in
                    let vc = GroupDetailViewController(groupId: id)
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            }
            
        }).disposed(by: _disposeBag)
        return v
    }()
    private lazy var tableView: UITableView = {
        let v = UITableView()
        v.register(FriendListUserTableViewCell.self, forCellReuseIdentifier: FriendListUserTableViewCell.className)
        v.backgroundColor = .clear
        v.rowHeight = 64.h
        v.separatorColor = .clear
        if #available(iOS 15.0, *) {
            v.sectionHeaderTopPadding = 0
        }
        return v
    }()

    private let iCreateBtn: UnderlineButton = {
        let v = UnderlineButton(frame: .zero)
        v.setTitle("我创建的".innerLocalized(), for: .normal)
        v.setTitleColor(.c0C1C33, for: .normal)
        v.titleLabel?.font = .f17
        v.isSelected = true
        v.underLineWidth = 20
        
        return v
    }()

    private let iJoinBtn: UnderlineButton = {
        let v = UnderlineButton(frame: .zero)
        v.setTitle("我加入的".innerLocalized(), for: .normal)
        v.setTitleColor(.c0C1C33, for: .normal)
        v.titleLabel?.font = .f17
        v.underLineWidth = 20
        
        return v
    }()

    private lazy var resultC = GroupListResultViewController()

    private func initView() {
        let searchC: UISearchController = {
            let v = UISearchController(searchResultsController: resultC)
            v.searchResultsUpdater = resultC
            v.searchBar.placeholder = "搜索".innerLocalized()
            v.obscuresBackgroundDuringPresentation = true

            return v
        }()
        navigationItem.searchController = searchC
        
        resultC.selectUserCallBack = { [weak self] gid in 
            guard let `self` = self else { return }
            
            let groupInfo = self._viewModel.myGroupsRelay.value.first{ $0.groupID == gid }
            self.toConversation(groupInfo!)
        }
        
        let btnStackView: UIStackView = {
            
            let line = UIView()
            line.backgroundColor = .sepratorColor
            let hStack = UIStackView(arrangedSubviews: [iCreateBtn, iJoinBtn])
            hStack.distribution = .fillEqually
            
            let v = UIStackView(arrangedSubviews: [hStack, line])
            v.axis = .vertical
            v.spacing = 4
            v.backgroundColor = .cellBackgroundColor
            
            line.snp.makeConstraints { make in
                make.height.equalTo(1)
            }
            
            return v
        }()

        view.addSubview(btnStackView)
        btnStackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(btnStackView.snp.bottom)
            make.leading.bottom.trailing.equalToSuperview()
        }
    }

    private let _viewModel = GroupListViewModel()
    private let _disposeBag = DisposeBag()
    private func bindData() {
        _viewModel.loading.asDriver().drive(onNext: { isLoading in
            if isLoading {
                ProgressHUD.animate()
            } else {
                ProgressHUD.dismiss()
            }
        }).disposed(by: _disposeBag)
        
        iCreateBtn.rx.tap.subscribe(onNext: { [weak self] in
            self?._viewModel.isICreateTableSelected.accept(true)
            self?.chooseType = 0
            self?.addChatBtn.title = "创建".innerLocalized()
        }).disposed(by: _disposeBag)

        iJoinBtn.rx.tap.subscribe(onNext: { [weak self] in
            self?._viewModel.isICreateTableSelected.accept(false)
            self?.chooseType = 1
            self?.addChatBtn.title = "添加".innerLocalized()
        }).disposed(by: _disposeBag)

        _viewModel.isICreateTableSelected
            .bind(to: iCreateBtn.rx.isSelected)
            .disposed(by: _disposeBag)

        _viewModel.isICreateTableSelected
            .map { !$0 }
            .bind(to: iJoinBtn.rx.isSelected)
            .disposed(by: _disposeBag)

        _viewModel.items.bind(to: tableView.rx.items(cellIdentifier: FriendListUserTableViewCell.className, cellType: FriendListUserTableViewCell.self)) { _, model, cell in
            cell.titleLabel.text = model.groupName
     
            cell.subtitleLabel.text = "\(model.memberCount)人"
//            cell.avatarImageView.setAvatar(url: model.faceURL, text: nil, placeHolder: "contact_my_group_icon", onTap: nil)
            cell.avatarImageView.setGroupInfoImg(item: model)
            
        }.disposed(by: _disposeBag)

        tableView.rx.modelSelected(GroupInfo.self).subscribe(onNext: { [weak self] (groupInfo: GroupInfo) in
            if let handler = self?.selectCallBack {
                handler([groupInfo])
            } else {
                self?.toConversation(groupInfo)
            }
        }).disposed(by: _disposeBag)

        _viewModel.myGroupsRelay
            .asDriver(onErrorJustReturn: [])
            .drive(onNext: { [weak self] groups in
                self?.resultC.dataList = groups
            }).disposed(by: _disposeBag)
    }
    
    func toConversation(_ groupInfo: GroupInfo) {
        IMController.shared.getConversation(sessionType: .superGroup, sourceId: groupInfo.groupID) { [weak self] (conversation: ConversationInfo?) in
            guard let conversation else { return }
            let vc = ChatViewControllerBuilder().build(conversation)
            self?.navigationController?.pushViewController(vc, animated: true)
        }
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
}
