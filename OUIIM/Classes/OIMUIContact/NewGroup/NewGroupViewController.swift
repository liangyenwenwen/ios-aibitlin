
import OUICore
import OUICoreView
import RxSwift
import RxCocoa
import RxRelay
import ProgressHUD
import Photos

class NewGroupViewController: UIViewController {
    private let _viewModel = NewGroupViewModel()
    private let _disposeBag = DisposeBag()
    private var hasSelectedItems: [ContactInfo] = []
    private var maxCount: Int = 999
    private var searchResult: [ContactInfo] = []
    private var searchStr:String = ""
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "创建群聊".innerLocalized()
        navigationController?.navigationBar.isOpaque = false
        configureView()
        _viewModel.groupType = .working
        let tap = UITapGestureRecognizer()
        tap.cancelsTouchesInView = false
        tap.rx.event.subscribe(onNext: { [weak self] _ in
            self?.view.endEditing(true)
        }).disposed(by: _disposeBag)
        
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tap)
        _viewModel.getMyFriendList()
        _viewModel.loadingSubject.subscribe(onNext: { loading in
            loading ? ProgressHUD.animate() : ProgressHUD.dismiss()
        }).disposed(by: _disposeBag)
        _viewModel.lettersRelay.distinctUntilChanged().subscribe(onNext: { [weak self] (values: [String]) in
            guard let self, !values.isEmpty else { return }
            self.tableView.sc_indexViewDataSource = values
            self.tableView.sc_startSection = 0
            self.tableView.reloadData()
        }).disposed(by: _disposeBag)
    }
    
    private func configureView() {
        view.backgroundColor = .bgColor
        view.addSubview(headView)
        view.addSubview(chooseMemberView)
        view.addSubview(searchBgView)
        view.addSubview(tableView)
        view.addSubview(bottomView)
        headView.snp_makeConstraints { make in
            make.top.equalTo(44 + kStatusBarHeight+16)
            make.left.equalTo(16)
            make.width.equalTo(kScreenWidth-32)
            make.height.equalTo(50)
        }
        chooseMemberView.snp_makeConstraints { make in
            make.left.right.equalTo(headView)
            make.top.equalTo(headView.snp_bottom).offset(12)
            make.height.equalTo(8+18+8+70+8)
        }
        searchBgView.snp_makeConstraints { make in
            make.top.equalTo(chooseMemberView.snp.bottom).offset(12)
            make.left.right.equalTo(0)
            make.height.equalTo(66)
        }
        tableView.snp_makeConstraints { make in
            make.top.equalTo(searchBgView.snp.bottom)
            make.left.right.equalTo(0)
            make.bottom.equalTo(bottomView.snp_top)
        }
        bottomView.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview()
            make.height.equalTo(UIApplication.safeAreaInsets.bottom + 80)
        }
    }
    lazy var headView: UIView = {
        let r = UIView()
        r.backgroundColor = .white
        r.layer.masksToBounds = true
        r.layer.cornerRadius = 12
        r.layer.borderWidth = 1
        r.layer.borderColor = UIColor.c0089FF.cgColor
        r.addSubview(nameTextFiled)
        nameTextFiled.snp_makeConstraints { make in
            make.top.equalTo(8)
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.bottom.equalTo(-8)
        }
        return r
    }()
    lazy var nameTextFiled: UITextField = {
        let v = UITextField()
        v.placeholder = "填写群名称".innerLocalized()
        v.rx.text.map({ [weak self] text in
            guard let self, let text else { return "" }
            self.createButton.isEnabled = text.length > 0 && self.hasSelectedItems.count > 1
            return String(text.prefix(16))
        }).bind(to: v.rx.text).disposed(by: _disposeBag)
        
        return v
    }()
    lazy var chooseMemberView: UIView = {
        let r = UIView()
        r.backgroundColor = .white
        r.layer.masksToBounds = true
        r.layer.cornerRadius = 12
        r.addSubview(titleLabel)
        r.addSubview(countLabel)
        r.addSubview(memberCollectionView)
        titleLabel.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.top.equalTo(8)
            make.height.equalTo(18)
        }
        countLabel.snp_makeConstraints { make in
            make.right.equalTo(-16)
            make.top.equalTo(8)
            make.height.equalTo(18)
        }
        memberCollectionView.snp_makeConstraints { make in
            make.top.equalTo(titleLabel.snp_bottom).offset(8)
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.height.equalTo(70)
        }
        return r
    }()
    let titleLabel: UILabel = {
        let r = UILabel()
        r.font = UIFont.f17
        r.textColor = .c8E9AB0
        r.text = "群成员".innerLocalized()
        return r
    }()

    let countLabel: UILabel = {
        let r = UILabel()
        r.font = UIFont.f17
        r.textColor = .c8E9AB0
        r.text = "\("nPerson".innerLocalizedFormat(arguments: 0))"
        return r
    }()
    lazy var memberCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: StandardUI.avatarWidth, height: 70)
        let r = UICollectionView(frame: .zero, collectionViewLayout: layout)
        r.register(ChooseUserCollectionViewCell.self, forCellWithReuseIdentifier: ChooseUserCollectionViewCell.className)
        r.backgroundColor = .clear
        r.dataSource = self
        r.showsHorizontalScrollIndicator = false
        return r
    }()
    lazy var searchBgView: UIView = {
        let r = UIView()
        r.backgroundColor = .white
        r.addSubview(searchView)
        searchView.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.top.equalTo(14)
            make.height.equalTo(38)
        }
        return r
    }()
    lazy var searchView: UIView = {
        let r = UIView()
        r.layer.masksToBounds = true
        r.layer.cornerRadius = 8
        r.backgroundColor = .bgColor
        let icon = UIImageView(image: UIImage(named: "search_gray"))
        r.addSubview(icon)
        r.addSubview(searchTextFiled)
        icon.snp_makeConstraints { make in
            make.left.equalTo(8)
            make.centerY.equalTo(r)
            make.width.height.equalTo(16)
        }
        searchTextFiled.snp_makeConstraints { make in
            make.left.equalTo(icon.snp_right).offset(8)
            make.top.bottom.equalTo(r)
            make.right.equalTo(-8)
        }
        return r
    }()
    lazy var searchTextFiled: UITextField = {
        let r = UITextField()
        r.clearButtonMode = .always
        r.placeholder = "搜索".innerLocalized()
        r.font = UIFont(name: "PingFangSC-Regular", size: 17)
        r.returnKeyType = .search
        r.rx.controlEvent(.editingChanged).subscribe(onNext: { [unowned self] in
            self.searchStr = r.text ?? ""
            if self.searchStr.length == 0{
                self.searchResult.removeAll()
                self.tableView.sc_indexViewDataSource = _viewModel.lettersRelay.value
                self.tableView.reloadData()
            }else{
                self.searchMember()
            }
        }).disposed(by: _disposeBag)
        r.rx.controlEvent(.editingDidEndOnExit).asObservable().subscribe(onNext: { _ in
                print("Search button clicked")
            })
            .disposed(by: _disposeBag)
        return r
    }()
    lazy var tableView: UITableView = {
        let v = UITableView()
        let config = SCIndexViewConfiguration(indexViewStyle: SCIndexViewStyle.default)!
        config.indexItemRightMargin = 8
        config.indexItemTextColor = UIColor(hexString: "#555555")
        config.indexItemSelectedBackgroundColor = UIColor(hexString: "#57be6a")
        config.indexItemsSpace = 4
        v.sc_indexViewConfiguration = config
        v.sc_translucentForTableViewInNavigationBar = true
        v.register(SelectMemberTableViewCell.self, forCellReuseIdentifier: SelectMemberTableViewCell.className)
        v.dataSource = self
        v.delegate = self
        v.backgroundColor = .white
        
        if #available(iOS 15.0, *) {
            v.sectionHeaderTopPadding = 0
        }
        return v
    }()
    lazy var bottomView: UIView = {
        let r = UIView()
        r.backgroundColor = .white
        r.addSubview(createButton)
        createButton.snp_makeConstraints { make in
            make.leading.top.trailing.equalToSuperview().inset(16)
            make.height.equalTo(44)
        }
        return r
    }()
    private lazy var createButton: UIButton = {
        let v = UIButton(type: .system)
        v.setTitle("completeCreation".innerLocalized(), for: .normal)
        v.setTitleColor(.white, for: .normal)
        v.isEnabled = false
        v.layer.masksToBounds = true
        v.layer.cornerRadius = 6
        v.setBackgroundColor(.c0089FF, for: .normal)
        v.setBackgroundColor(.c0089FF.withAlphaComponent(0.5), for: .disabled)
        v.rx.tap.subscribe(onNext: { [weak self] _ in
            self?.createGroup()
        }).disposed(by: _disposeBag)
        
        return v
    }()
    
    private func createGroup() {
        ProgressHUD.animate()
        _viewModel.createGroup(users:hasSelectedItems,groupName:nameTextFiled.text ?? "") { [weak self] conversation in
            ProgressHUD.dismiss()
            if let conversation {
                self?.toChat(conversation: conversation)
            } else {
                self?.presentAlert(title: "创建失败".innerLocalized())
            }
        }
    }
    private func searchMember(){
        self.searchResult.removeAll()
        self.searchResult = _viewModel.contacts.filter { $0.name!.localizedCaseInsensitiveContains(searchStr) }
        self.tableView.sc_indexViewDataSource = []
        self.tableView.reloadData()
    }
    private func toChat(conversation: ConversationInfo) {
        
        let chatVC = ChatViewControllerBuilder().build(conversation)
        chatVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(chatVC, animated: true)
        if let root = navigationController?.viewControllers.first {
            navigationController?.viewControllers.removeAll(where: { controller in
                controller != root && controller != chatVC
            })
        }
    }
    // 增加选中的元素
    private func appendSelectedItems(_ contact: ContactInfo) {
//        hasSelectedItems.append(contact)
        hasSelectedItems.insert(contact, at: 0)
        memberCollectionView.reloadData()
        countLabel.text = "\("nPerson".innerLocalizedFormat(arguments: hasSelectedItems.count))"
        createButton.isEnabled = nameTextFiled.text != nil && !nameTextFiled.text!.isEmpty && hasSelectedItems.count > 1
    }
    // 移除选择的元素
    private func removeSelectedItems(_ contact: ContactInfo) {
        hasSelectedItems.removeAll(where: {$0.ID == contact.ID})
        memberCollectionView.reloadData()
        countLabel.text = "\("nPerson".innerLocalizedFormat(arguments: hasSelectedItems.count))"  
        createButton.isEnabled = nameTextFiled.text != nil && !nameTextFiled.text!.isEmpty && hasSelectedItems.count > 1
    }
    deinit {
#if DEBUG
        print("\(#function) - \(type(of: self))")
#endif
    }
}
extension NewGroupViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hasSelectedItems.count
    }
    
    final public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChooseUserCollectionViewCell.className, for: indexPath) as! ChooseUserCollectionViewCell
        let item = hasSelectedItems[indexPath.row]
        cell.avatarView.setAvatar(url: item.faceURL, text: item.name)
        cell.nameLabel.text = item.name
        return cell
    }
}
extension NewGroupViewController: UITableViewDataSource, UITableViewDelegate {
    public func numberOfSections(in _: UITableView) -> Int {
        return searchStr.length > 0 ? 1 :_viewModel.lettersRelay.value.count
    }
    
    public func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  searchStr.length > 0 ? searchResult.count : _viewModel.contactsSections[section].count
    }
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 58
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SelectMemberTableViewCell.className) as! SelectMemberTableViewCell
        let contact = getContacts(by: indexPath)
        if hasSelectedItems.contains(where: {(item) -> Bool in return item.ID == contact.ID}) {
            cell.stateImageView.isHighlighted = true
        } else {
            cell.stateImageView.isHighlighted = false
        }
        cell.titleLabel.text = contact.name
        cell.avatarImageView.setAvatar(url: contact.faceURL, text: contact.name, placeHolder: "contact_my_friend_icon")
        return cell
    }
    
    public func tableView(_: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        var userID = getContacts(by: indexPath).ID!
        if hasSelectedItems.count + 1 > maxCount {
            presentAlert(title: "selectedMaxCount".innerLocalizedFormat(arguments: maxCount))
            
            return nil
        }
        
        return indexPath
    }
    public func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! SelectMemberTableViewCell
        let contact = getContacts(by: indexPath)
        if cell.stateImageView.isHighlighted{
            //已选中
            removeSelectedItems(contact)
            cell.stateImageView.isHighlighted = false
        }else{
            //未选中
            appendSelectedItems(contact)
            cell.stateImageView.isHighlighted = true
        }

    }
    public func tableView(_: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if searchStr.length > 0{
            return UIView()
        }else{
            let name = _viewModel.lettersRelay.value[section]
            let header = ViewUtil.createSectionHeaderWith(text: name)
            return header
        }
        
    }
    
    public func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        return searchStr.length > 0 ? 0.01 : 33
    }
    
    public func tableView(_: UITableView, heightForFooterInSection _: Int) -> CGFloat {
        CGFloat.leastNormalMagnitude
    }
    
    private func getContacts(by indexPath: IndexPath) -> ContactInfo {
        return searchStr.length > 0 ? searchResult[indexPath.row] : _viewModel.contactsSections[indexPath.section][indexPath.row]
    }
}
class ChooseUserCollectionViewCell: UICollectionViewCell {
    
    let avatarView = AvatarView()
    
    let nameLabel: UILabel = {
        let v = UILabel()
        v.font = .f12
        v.textColor = .c8E9AB0
        
        return v
    }()
    
    let levelLabel: UILabel = {
        let v = UILabel()
        v.backgroundColor = .cE8EAEF
        v.textColor = .c6085B1
        v.font = .f12
        v.textAlignment = .center
        return v
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let vStack = UIStackView(arrangedSubviews: [avatarView, nameLabel])
        vStack.axis = .vertical
        vStack.spacing = 4
        vStack.alignment = .center
        
        contentView.addSubview(vStack)
        vStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        avatarView.addSubview(levelLabel)
        avatarView.layer.cornerRadius = 22
        levelLabel.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(avatarView)
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        levelLabel.text = nil
        avatarView.reset()
    }
}
class SelectMemberTableViewCell: UITableViewCell {

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .cellBackgroundColor
        contentView.addSubview(stateImageView)
        contentView.addSubview(avatarImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(lineView)
        stateImageView.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.centerY.equalTo(contentView)
            make.width.height.equalTo(22)
        }
        avatarImageView.snp_makeConstraints { make in
            make.left.equalTo(stateImageView.snp_right).offset(4)
            make.centerY.equalTo(stateImageView)
            make.width.height.equalTo(40)
        }
        titleLabel.snp_makeConstraints { make in
            make.left.equalTo(avatarImageView.snp_right).offset(4)
            make.centerY.equalTo(stateImageView)
            make.right.equalTo(-16)
        }
        lineView.snp_makeConstraints { make in
            make.left.equalTo(stateImageView)
            make.right.equalTo(titleLabel)
            make.bottom.equalTo(contentView)
            make.height.equalTo(1)
        }
    }
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var stateImageView: UIImageView = {
        let v = UIImageView()
        v.image = UIImage(nameInBundle: "common_checkbox_unselected")
        v.highlightedImage = UIImage(nameInBundle: "common_checkbox_selected")

        return v
    }()
    lazy var avatarImageView: AvatarView = {
        let v = AvatarView()
        v.layer.cornerRadius = 20
        return v
    }()
    lazy var titleLabel: UILabel = {
        let v = UILabel()
        v.font =  UIFont(name: "PingFangSC-Medium", size: 18)
        v.textColor = .init(hexString: "#333333")
        return v
    }()
    lazy var lineView: UIView = {
        let r = UIView()
        r.backgroundColor = .init(hexString: "#d9d9d9")
        return r
    }()
}

