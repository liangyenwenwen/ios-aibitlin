
import OUICore
import RxSwift
import SnapKit
import ProgressHUD
#if ENABLE_ORGANIZATION
import OUIOrganization
#endif

public typealias SelectedContactsHandler = ((_ pop: Bool, [ContactInfo]) -> Void)

open class SelectContactsViewController: UIViewController {
    
    public var maxCount: Int = 999 {
        didSet {
            bottomBar.maxCount = maxCount
        }
    }
    
    public var allowsSelecteAll: Bool = true {
        didSet {
            selecteAllView.isHidden = !allowsSelecteAll
        }
    }
    
    public var completionHandler: (() -> Void)?
    
    // 选择后的回调
    private var selectedHandler: SelectedContactsHandler?
    private var contacTypes: [ContactType] = []
    private var sourceID: String? // 可能是群ID，可能是部门ID
    private var hasSelectedItems: [ContactInfo] = [] // 上一次已经选择过的ID
    private var blockedIDs: [String] = [] // 不能选择的ID
    private var allowsMultipleSelection = true
    private var enableChangeSelectedModel = false
    
    public init(types: [ContactType] = [.friends], sourceID: String? = nil, allowsMultipleSelection: Bool = true, enableChangeSelectedModel: Bool = false) {
        super.init(nibName: nil, bundle: nil)
        self.contacTypes = types
        self.sourceID = sourceID
        self.allowsMultipleSelection = allowsMultipleSelection
        self.enableChangeSelectedModel = enableChangeSelectedModel
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
#if ENABLE_ORGANIZATION
        departmentViewController = nil
#endif
        print("SelectContactsViewController deinit")
    }
    
    // 设置其它选项
    public func selectedContact<T>(hasSelected: [T]? = nil, blocked: [String]? = nil, selectedHandler: SelectedContactsHandler?) {
        
        if let temp = hasSelected as? [ContactInfo] {
            self.hasSelectedItems = temp
        } else if let temp = hasSelected as? [String] {
            self.hasSelectedItems = temp.map{ContactInfo(ID: $0)}
        }
        self.blockedIDs = blocked ?? []
        self.selectedHandler = selectedHandler
    }
    
    open lazy var tableView: UITableView = {
        let v = UITableView()
        let config = SCIndexViewConfiguration(indexViewStyle: SCIndexViewStyle.default)!
        config.indexItemRightMargin = 8
        config.indexItemTextColor = UIColor(hexString: "#555555")
        config.indexItemSelectedBackgroundColor = UIColor(hexString: "#57be6a")
        config.indexItemsSpace = 4
        v.sc_indexViewConfiguration = config
        v.sc_translucentForTableViewInNavigationBar = true
        v.register(SelectUserTableViewCell.self, forCellReuseIdentifier: SelectUserTableViewCell.className)
        v.dataSource = self
        v.delegate = self
        v.rowHeight = UITableView.automaticDimension
        v.allowsMultipleSelection = true
        v.backgroundColor = .clear
        
        if #available(iOS 15.0, *) {
            v.sectionHeaderTopPadding = 0
        }
        return v
    }()
    
    private lazy var selecteAllButton: UIButton = {
        let v = UIButton(type: .custom)
        v.setImage(UIImage(nameInBundle: "common_checkbox_unselected"), for: .normal)
        v.setImage(UIImage(nameInBundle: "common_checkbox_selected"), for: .selected)
        v.setTitle(" " + "selectAll".innerLocalized(), for: .normal)
        v.setTitleColor(.c0C1C33, for: .normal)
        
        v.rx.tap.subscribe(onNext: { [weak self] _ in
            self?.selecteAll()
        }).disposed(by: _disposeBag)
        
        return v
    }()
    
    private lazy var selecteAllView: UIView = {
        let v = UIView()
        v.backgroundColor = .cellBackgroundColor
        let tap = UITapGestureRecognizer()
        tap.rx.event.subscribe(onNext: { [weak self] _ in
            self?.selecteAll()
        }).disposed(by: _disposeBag)
        v.addGestureRecognizer(tap)
        
        v.addSubview(selecteAllButton)
        selecteAllButton.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview().inset(16)
        }
        
        return v
    }()
    
    // contacTypes 存在多个元素，才会出现按钮
    private let friendsButton: UnderlineButton = {
        let v = UnderlineButton(frame: .zero)
        v.setTitle("我的好友".innerLocalized(), for: .normal)
        v.setTitleColor(.c0C1C33, for: .normal)
        v.titleLabel?.font = .f14
        v.isSelected = true
        v.underLineWidth = 30
        return v
    }()
    
    private let groupsButton: UnderlineButton = {
        let v = UnderlineButton(frame: .zero)
        v.setTitle("我的群组".innerLocalized(), for: .normal)
        v.setTitleColor(.c0C1C33, for: .normal)
        v.titleLabel?.font = .f14
        v.underLineWidth = 30
        return v
    }()
    
    private let staffButton: UnderlineButton = {
        let v = UnderlineButton(frame: .zero)
        v.setTitle("组织架构".innerLocalized(), for: .normal)
        v.setTitleColor(.c0C1C33, for: .normal)
        v.titleLabel?.font = .f14
        v.underLineWidth = 30
        return v
    }()
#if ENABLE_ORGANIZATION
    var departmentViewController: DepartmentViewController?
#endif
    
    private let _viewModel = SelectContactsViewModel()
    private var searchResultViewController: SearchContactsViewController?
    private let _disposeBag: DisposeBag = DisposeBag()
    private var isSingleList: Bool {
        contacTypes.first == .groups
    }
    
    public lazy var bottomBar: SelectBottomBar = {
        let v = SelectBottomBar()
        v.maxCount = maxCount
        
        v.onTap = { [weak self] type in
            switch type {
            case .selected:
                self?.showSelectedItem()
            case .complete:
                self?.completionAction()
            }
        }
        return v
    }()
    
    private lazy var searchBar: UISearchBar = {
        let v = UISearchBar(frame: CGRectZero)
        v.searchBarStyle = .minimal
        v.placeholder = "搜索".innerLocalized()
        v.searchTextField.isEnabled = false
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .cellBackgroundColor
        
        let tap = UITapGestureRecognizer()
        tap.rx.event.subscribe(onNext: { [weak self] _ in
            
            self?.pushToSearchViewController()
        }).disposed(by: _disposeBag)
        v.addGestureRecognizer(tap)
        
        return v
    }()
    
    public lazy var contentStack: UIStackView = {
        let v = UIStackView(arrangedSubviews: [selecteAllView, tableView])
        v.axis = .vertical
        v.spacing = 10
        
        return v
    }()
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .viewBackgroundColor
        navigationItem.title = "choose".localized()
#if ENABLE_ORGANIZATION
        departmentViewController = DepartmentViewController(department: nil,
                                                            name: "组织架构".innerLocalized(),
                                                            showCheckBox: allowsMultipleSelection,
                                                            showSearchBar: false)
        departmentViewController!.onTap = { [weak self] user in
            guard let self else { return }
            if !allowsMultipleSelection {
                selectedHandler?([user])
            }
        }
#endif
        initView()
        bindData()
        loadData()
    }
    
    private func initView() {
        let backButton = UIBarButtonItem(image: UIImage(nameInBundle: "common_back_icon"), style: .done, target: nil, action: nil)
        navigationItem.leftBarButtonItem = backButton
        backButton.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let self else { return }
            selectedAction(pop: true)
        }).disposed(by: _disposeBag)
        
        view.addSubview(searchBar)
        searchBar.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        
        if allowsMultipleSelection {
            view.addSubview(bottomBar)
            bottomBar.snp.makeConstraints { make in
                make.leading.trailing.bottom.equalToSuperview()
            }
        }
        
        // 切换tab
        if contacTypes.count > 1 {
            let row = UIStackView()
            row.alignment = .center
            row.distribution = .fillEqually
            
            if contacTypes.contains(.friends) {
                row.addArrangedSubview(friendsButton)
            }
            if contacTypes.contains(.groups) {
                row.addArrangedSubview(groupsButton)
            }
            if contacTypes.contains(.staff) {
                row.addArrangedSubview(staffButton)
            }
            
            view.addSubview(row)
            row.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview()
                make.top.equalTo(searchBar.snp.bottom)
            }
            
            view.addSubview(tableView)
            tableView.snp.makeConstraints { make in
                make.top.equalTo(row.snp.bottom).offset(16)
                make.leading.trailing.equalToSuperview()
                !allowsMultipleSelection ? make.bottom.equalToSuperview() : make.bottom.equalTo(bottomBar.snp.top)
            }
        } else {
            // v3 以后选择改成了单列表
            if contacTypes.first == .staff {
                showOrg(true)
            } else {
                view.addSubview(contentStack)
                contentStack.snp.makeConstraints { make in
                    make.top.equalTo(searchBar.snp.bottom).offset(10)
                    make.leading.trailing.equalToSuperview()
                    !allowsMultipleSelection ? make.bottom.equalToSuperview() : make.bottom.equalTo(bottomBar.snp.top)
                }
            }
        }
    }
    
    private func bindData() {
        _viewModel.loadingSubject.subscribe(onNext: { loading in
            loading ? ProgressHUD.animate() : ProgressHUD.dismiss()
        }).disposed(by: _disposeBag)
        _viewModel.lettersRelay.distinctUntilChanged().subscribe(onNext: { [weak self] (values: [String]) in
            guard let self, !values.isEmpty else { return }
            if !isSingleList {
                self.tableView.sc_indexViewDataSource = values
                self.tableView.sc_startSection = 0
            }
            self.tableView.reloadData()
            // 选中
            if !hasSelectedItems.isEmpty {
                self.defaultSelectedItems()
                
                let isAll = _viewModel.contacts.allSatisfy { contact in
                    self.hasSelectedItems.contains(where: { $0.ID == contact.ID })
                }
                
                selecteAllButton.isSelected = isAll
            }
            // 上个页面传下来的有可能是别的类型，比如这里是friend，但是可能group也在里面
//            hasSelectedItems.removeAll(where: { $0.name == nil })
        }).disposed(by: _disposeBag)
        // 搜索数据
        _viewModel.searchResult.subscribe(onNext: { [weak self] r in
            self?.searchResultViewController?.dataList = r
            self?.searchResultViewController?.updateSearchResults(text: self?.navigationItem.searchController?.searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines))
        }).disposed(by: _disposeBag)
        
//        bottomBar.completeBtn.rx.tap
//            .throttle(.seconds(2), latest: false, scheduler: MainScheduler.instance)
//            .subscribe(onNext: { [weak self] in
//                guard let `self` = self else { return }
//                self.selectedHandler?(self.hasSelectedItems)
//            }).disposed(by: _disposeBag)
        
        friendsButton.rx.tap.subscribe(onNext: { [weak self] in
            self?.showOrg(false)
            self?._viewModel.tabSelected.accept(.friends)
        }).disposed(by: _disposeBag)
        
        groupsButton.rx.tap.subscribe(onNext: { [weak self] in
            self?.showOrg(false)
            self?._viewModel.tabSelected.accept(.groups)
        }).disposed(by: _disposeBag)
        
        staffButton.rx.tap.subscribe(onNext: { [weak self] in
            // 把组织架构的界面加载进来
            guard let `self` = self else { return }
            self.showOrg(false)
        }).disposed(by: _disposeBag)
        
        // 如果只选择好友/或者群， 直接刷新界面
        if contacTypes.count == 1 {
            return _viewModel.tabSelected.accept(.undefine)
        }
        
        _viewModel.tabSelected
            .map({ type in
                return type == .friends || type == .members
            })
            .bind(to: friendsButton.rx.isSelected)
            .disposed(by: _disposeBag)
        _viewModel.tabSelected
            .map({ type in
                return type == .groups
            })
            .bind(to: groupsButton.rx.isSelected)
            .disposed(by: _disposeBag)
        _viewModel.tabSelected
            .map({ type in
                return type == .staff
            })
            .bind(to: staffButton.rx.isSelected)
            .disposed(by: _disposeBag)
    }
    
    private func showOrg(_ show: Bool = false) {
#if ENABLE_ORGANIZATION
        if show {
            self.view.addSubview(self.departmentViewController!.view)
            self.addChild(departmentViewController!)
            self.departmentViewController!.view.snp.makeConstraints { make in
                if contacTypes.count == 1, contacTypes.first == .staff {
                    make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
                    make.leading.trailing.equalToSuperview()
                    make.bottom.equalTo(allowsMultipleSelection ? bottomBar.snp.top : view.safeAreaLayoutGuide.snp.bottom)
                } else {
                    make.edges.equalTo(self.tableView)
                    make.top.equalTo(self.staffButton.snp.bottom)
                }
            }

            departmentViewController!.selectContact(hasSelected: self.hasSelectedItems, blocked: self.blockedIDs) { [weak self] (contacs: [ContactInfo]) in
                guard let `self` = self else { return }
                for (i, item) in contacs.enumerated() {
                    if !self.hasSelectedItems.contains(where: {$0.ID == item.ID}) {
                        self.hasSelectedItems.append(item)
                    }
                }
                self.updateSelectedResult()
            } removeCallback: { [weak self] contacs in
                guard let self else { return }
                hasSelectedItems = hasSelectedItems.filter { c in
                    contacs.contains(where: { $0.ID != c.ID })
                }
                self.updateSelectedResult()
            }
        } else {
            self.departmentViewController?.view.removeFromSuperview()
            departmentViewController?.removeFromParent()
        }
        if allowsMultipleSelection {
            let count = hasSelectedItems.count
            bottomBar.selectedCount = count
            bottomBar.names = hasSelectedItems.compactMap({ $0.name }).joined(separator: "、")
            
            let type: ContactItemType = contacTypes.first == .groups ? .group : .user

            selecteAllButton.isSelected = hasSelectedItems.filter({ $0.type == type }).count == _viewModel.contacts.count
        }
#endif
    }
    
    private func loadData() {
        
        if contacTypes.contains(.friends) {
            _viewModel.getMyFriendList()
        }
        if contacTypes.contains(.groups) {
            _viewModel.getGroups()
        }
        if contacTypes.contains(.members) {
            _viewModel.getGroupMemberList(groupID: sourceID!)
        }
    }
    
    private func selecteAll() {
        selecteAllButton.isSelected = !selecteAllButton.isSelected
        
        let type: ContactItemType = contacTypes.first == .groups ? .group : .user
            
        hasSelectedItems.removeAll { contact in
            _viewModel.contacts.contains(where: { $0.ID == contact.ID })
        }

        if selecteAllButton.isSelected {
            hasSelectedItems += _viewModel.contacts
            hasSelectedItems = hasSelectedItems.filter { info in
                !blockedIDs.contains(where: { $0 == info.ID })
            }
        } else {
            tableView.reloadData()
        }
        
        defaultSelectedItems()
    }
    
    // 把默认的元素选中
    private func defaultSelectedItems() {
        for(i, item) in hasSelectedItems.enumerated() {
            if isSingleList {
                if let row = _viewModel.contacts.firstIndex(where: { $0.ID == item.ID }) {
                    let indexPath = IndexPath(row: row, section: 0)
                    tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                }
            } else {
#if ENABLE_ORGANIZATION
                if let indexPath = _viewModel.getContactIndexPath(by: item.ID!) {
                    
                    tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                    hasSelectedItems[i] = _viewModel.getContactAt(indexPaths: [indexPath]).first!
                }
#else
                if let indexPath = _viewModel.getContactIndexPath(by: item.ID!) {
                    tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                    hasSelectedItems[i] = _viewModel.getContactAt(indexPaths: [indexPath]).first!
                }
#endif
            }
        }
        
        updateSelectedResult()
    }
    
    // 增加选中的元素
    private func appendSelectedItems(_ contact: ContactInfo) {
        hasSelectedItems.append(contact)
        updateSelectedResult()
    }
    // 移除选择的元素
    private func removeSelectedItems(_ contact: ContactInfo) {
        hasSelectedItems.removeAll(where: {$0.ID == contact.ID})
        updateSelectedResult()
    }
    
    private func updateSelectedResult() {
        if allowsMultipleSelection {
            let count = self.hasSelectedItems.count
            bottomBar.selectedCount = count
            bottomBar.names = hasSelectedItems.compactMap({ $0.name }).joined(separator: "、")
            
            let type: ContactItemType = contacTypes.first == .groups ? .group : .user
            let items = hasSelectedItems.filter({ $0.type == type })
            
            var selectedIDs = items.map { $0.ID }
            
            if type == .user {
                blockedIDs.forEach { id in
                    if !selectedIDs.contains(id) {
                        selectedIDs.append(id)
                    }
                }
                
                var isSelectedAll = true
                for (i, item) in _viewModel.contacts.enumerated() {
                    if !selectedIDs.contains(where: { $0 == item.ID }) {
                        isSelectedAll = false
                        break
                    }
                }
                
                selecteAllButton.isSelected = isSelectedAll
            } else {
                selecteAllButton.isSelected = selectedIDs.count == _viewModel.contacts.count
            }
        } else {
            selectedAction()
        }
    }
    
    private func completionAction() {
        selectedAction(pop: true)
        completionHandler?()
    }
    
    private func selectedAction(pop: Bool = false) {
//        selectedHandler?( hasSelectedItems.filter({ $0.type == contacTypes.first }))
        selectedHandler?(pop, hasSelectedItems)
    }
    
    @objc private func showSelectedItem() {
        let vc = ShowSelectedUserViewController(users: hasSelectedItems) { [weak self] items in
            guard let `self` = self else { return }
            // 将需要移除的item都执行下选中函数
            items.forEach { user in
                if let indexPath = self._viewModel.getContactIndexPath(by: user.ID!) {
                    self.tableView.deselectRow(at: indexPath, animated: false)
                    self.removeSelectedItems(user)
                } else {
                    // 可能是从组织架构获取的
#if ENABLE_ORGANIZATION
                    self.removeSelectedItems(user)
                    self.departmentViewController?.deSelectContact(user)
#endif
                }
            }
        }
        
        present(vc, animated: true)
    }
    
    private func pushToSearchViewController() {
        searchResultViewController = SearchContactsViewController(enableChangeSelectedModel: enableChangeSelectedModel,selectedCallback: { [weak self] items in
            guard let self, let item = items.first else { return }
            
            if hasSelectedItems.count + 1 > maxCount {
                presentAlert(title: "selectedMaxCount".innerLocalizedFormat(arguments: maxCount))
                return
            }
            
            if let indexPath = self._viewModel.getContactIndexPath(by: item.ID!) {
                self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
                self.appendSelectedItems(item)
                
                if !allowsMultipleSelection {
                    navigationController?.popViewController(animated: true)
                }
            }
        }, removeCallback: { [weak self] items in
            guard let self, !items.isEmpty else { return }
            // 将需要移除的item都执行下选中函数
            items.forEach { user in
                if let indexPath = self._viewModel.getContactIndexPath(by: user.ID!) {
                    self.tableView.deselectRow(at: indexPath, animated: true)
                    self.removeSelectedItems(user)
                } else {
                    // 移除组织架构选中的成员
#if ENABLE_ORGANIZATION
                    self.departmentViewController?.deSelectContact(user)
#endif
                }
            }
            
            if !allowsMultipleSelection {
                navigationController?.popViewController(animated: true)
            }
        })
        
        searchResultViewController!.selectedUsers = hasSelectedItems
        
        navigationController?.pushViewController(searchResultViewController!, animated: true)
    }
}

extension SelectContactsViewController: UITableViewDataSource, UITableViewDelegate {
    public func numberOfSections(in _: UITableView) -> Int {
        isSingleList ? 1 : _viewModel.lettersRelay.value.count
    }
    
    public func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        isSingleList ? _viewModel.contacts.count : _viewModel.contactsSections[section].count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SelectUserTableViewCell.className) as! SelectUserTableViewCell
        let contact = getContacts(by: indexPath)
        
        cell.titleLabel.text = contact.name
//        cell.titleLabel.text = SuperStringUtil.getUserState(showname: contact.name ?? "").n
        cell.trainingLabel.text = contact.sub
        cell.trainingLabel.textColor = .c8E9AB0
        cell.trainingLabel.font = .f17
//        cell.avatarImageView.setAvatar(url: contact.faceURL, text: contact.name)
        if contact.type == .group {

            cell.avatarImageView.setGroupImg(groupID: contact.ID!)

        } else {
            
            cell.avatarImageView.setAvatar(url: contact.faceURL, text: contact.name, placeHolder: "contact_my_friend_icon")
        }
        
        cell.showSelectedIcon = allowsMultipleSelection
        
        if blockedIDs.contains(contact.ID!) {
            cell.canBeSelected = false
        }
        
        return cell
    }
    
    public func tableView(_: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        var userID = getContacts(by: indexPath).ID!
        
        if blockedIDs.contains(userID) {
            return nil
        }
        
        if hasSelectedItems.count + 1 > maxCount {
            presentAlert(title: "selectedMaxCount".innerLocalizedFormat(arguments: maxCount))
            
            return nil
        }
        
        return indexPath
    }
    
    public func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let contact = getContacts(by: indexPath)
        appendSelectedItems(contact)
    }
    
    public func tableView(_: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let contact = getContacts(by: indexPath)
        removeSelectedItems(contact)
    }
    
    public func tableView(_: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard !isSingleList else { return nil }
        
        let name = _viewModel.lettersRelay.value[section]
        let header = ViewUtil.createSectionHeaderWith(text: name)
        
        return header
    }
    
    public func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        isSingleList ? CGFloat.leastNormalMagnitude : 33
    }
    
    public func tableView(_: UITableView, heightForFooterInSection _: Int) -> CGFloat {
        CGFloat.leastNormalMagnitude
    }
    
    private func getContacts(by indexPath: IndexPath) -> ContactInfo {
        isSingleList ? _viewModel.contacts[indexPath.row] : _viewModel.contactsSections[indexPath.section][indexPath.row]
    }
}

extension SelectContactsViewController: UISearchResultsUpdating {
    public func updateSearchResults(for searchController: UISearchController) {
        if let keyword = searchController.searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
            _viewModel.search(keyword: keyword, type: contacTypes)
        }
    }
}



class SuperStringUtil {
    
    /// 获取用户的信息  博客 公司 vip 名字
    static func getUserState(showname: String) -> UserState {
        guard let jsonData = showname.data(using: .utf8) else { return UserState(b: 0, e: 0, v: 0, n: showname)}
        do {
            let user = try JSONDecoder().decode(UserState.self, from: jsonData)
            return user
        } catch {
            return  UserState(b: 0, e: 0, v: 0, n: showname)
        }
    }
    
    static func getUserShowname(showname: String) -> String  {
        let user = getUserState(showname: showname)
        return user.n
    }
    /// 获取用户的tag
    static func getUserTag(showname: String) -> String? {
        guard let jsonData = showname.data(using: .utf8) else { return nil}
        do {
            let user = try JSONDecoder().decode(UserState.self, from: jsonData)
            var reslut = ""
            if user.v > 0 {
                reslut.append("V\(user.v)")
            }
            
            if user.b > 0 {
                reslut.append(reslut.count == 0 ? "\("博客".localized())" : "、\("博客".localized())")
            }
            
            if user.e > 0 {
                reslut.append(reslut.count == 0 ? "\("企业".localized())" : "、\("企业".localized())")
            }
            
            return reslut.count == 0 ? nil : "[\(reslut)]"
        } catch {
            return  nil
        }
    }
    
}


struct UserState: Codable {
    let b: Int
    let e: Int
    let v: Int
    let n: String
}
