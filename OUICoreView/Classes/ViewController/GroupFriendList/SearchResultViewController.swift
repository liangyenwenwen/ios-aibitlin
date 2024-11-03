import OUICore
import RxSwift
import SnapKit
import ProgressHUD

public class SearchResultViewController: UIViewController, UISearchResultsUpdating, UISearchBarDelegate {
    
    public var didSelectedItem: ((_ ID: String) -> Void)?
    
    
    private lazy var tableView: UITableView = {
        let v = UITableView()
        v.register(SearchResultCell.self, forCellReuseIdentifier: SearchResultCell.className)
        v.register(YFSeacrhFriendListCell.self, forCellReuseIdentifier: YFSeacrhFriendListCell.className)
        v.register(YFSeacrhGroupListCell.self, forCellReuseIdentifier: YFSeacrhGroupListCell.className)
        
        v.rowHeight = UITableView.automaticDimension
        v.dataSource = self
        v.delegate = self
        v.backgroundColor = .clear
        
        if _searchType == .user {
            v.separatorStyle = .none
        }
        
        if #available(iOS 15.0, *) {
            v.sectionHeaderTopPadding = 0
        }
        return v
    }()
    
    private lazy var searchResultEmptyView: UIView = {
        let v = UIView()
        let label: UILabel = {
            let v = UILabel()
            v.text = "noFoundX".innerLocalizedFormat(arguments: _searchType.title)
            v.textColor = .c8E9AB0
            v.font = .f17
            
            return v
        }()
        v.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        v.isHidden = true
        return v
    }()
    
    var dataList = [[String: String]]() {
        willSet {
            dataList = newValue
            tableView.reloadData()
        }
    }
    
    var usersList = [UserInfo]() {
        willSet {
            usersList = newValue
            tableView.reloadData()
        }
    }
    
//    [OIMGroupInfo]?
    
    var groupsList = [GroupInfo]() {
        willSet {
            groupsList = newValue
            tableView.reloadData()
        }
    }
    
    private let _disposebag = DisposeBag()
    private let _searchType: SearchType
    private var userInfo: FullUserInfo?
    public init(searchType: SearchType) {
        _searchType = searchType
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            ProgressHUD.dismiss()
        }



    public override func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = [UIRectEdge.left, .right, .bottom]
        view.backgroundColor = .viewBackgroundColor
        initView()
        bindData()
    }
    private func initView() {
        view.backgroundColor = .groupTableViewBackground
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.bottom.trailing.equalToSuperview()
        }
        
        view.addSubview(searchResultEmptyView)
        searchResultEmptyView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(38.h)
            make.left.right.equalToSuperview()
            make.height.equalTo(60)
        }
    }
    
    private func bindData() {
    }
    
    public enum SearchType {
        /// 群组
        case group
        /// 用户
        case user
        
        var title: String {
            switch self {
            case .group:
                return "群组".innerLocalized()
            case .user:
                return "用户".innerLocalized()
            }
        }
    }
    
    private var keyword: String = ""
    
    
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        search(searchBar.text ?? "")
    }
    public func updateSearchResults(for searchController: UISearchController) {
        let searchStr = searchController.searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        if searchStr == ""{
            self.usersList.removeAll()
            self.groupsList.removeAll()
            self.dataList.removeAll()
            self.tableView .reloadData()
        }
       
    }
    
//    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        
//        lastDate = Date() - 3
//        updateSearchResults(for: seac)
//    }
    
    
    
    
    
    @objc func search(_ keyword: String) {
        
        self.keyword = keyword
        
        switch _searchType {
        case .group:
            
            
            ProgressHUD.animate()
            IMController.shared.getGroupListBy(id: keyword).subscribe(onNext: { [weak self] (groupID: String?) in
                ProgressHUD.dismiss()
                let shouldHideEmptyView = groupID != nil
                let shouldHideResultView = groupID == nil
                
                print("\n\n\n\n\n\n\n\n\n\\n\n\(keyword)-----\(groupID)")
                DispatchQueue.main.async {
                    self?.searchResultEmptyView.isHidden = shouldHideEmptyView
                    self?.tableView.isHidden = shouldHideResultView
                    if groupID != nil {
//                        self?.dataList = [[groupID!: groupID!]]
                        
                        self?.updateGroupMessage(groupID: groupID!)
                    }
                }
            },
            onError:{ [weak self] (error: Error?) in
                ProgressHUD.dismiss()
                OIMApi.showTipHandle
                if let handler = OIMApi.showTipHandle {
                    handler("-1".innerLocalized(), { res in
                    })
                }
            }
            ).disposed(by: _disposebag)
        case .user:
            // 业务层有搜索数据
            if let handler = OIMApi.queryFriendsWithCompletionHandler {
                handler([keyword], {res in
                    let shouldHideEmptyView = !res.isEmpty
                    let shouldHideResultView = res.isEmpty
                    DispatchQueue.main.async { [weak self] in
                        guard let `self` = self else { return }
                        self.searchResultEmptyView.isHidden = shouldHideEmptyView
                        self.tableView.isHidden = shouldHideResultView
                        // 输入的类型
                        let isNumber = keyword.trimmingCharacters(in: .decimalDigits).length == 0
                        let isPhone = self.isPhoneNumber(keyword)
                        let isEmail = self.isEmail(keyword)
                        
                        self.usersList = res
                    }
                })
            } else {
                ProgressHUD.animate()
                IMController.shared.getFriendsBy(id: keyword).subscribe(onNext: { [weak self] (userInfo: FullUserInfo?) in
                    ProgressHUD.dismiss()
                    self?.userInfo = userInfo
                    let uid = userInfo?.userID
                    let shouldHideEmptyView = uid != nil
                    let shouldHideResultView = uid == nil
                    DispatchQueue.main.async {
                        self?.searchResultEmptyView.isHidden = shouldHideEmptyView
                        self?.tableView.isHidden = shouldHideResultView
                        
                        if uid != nil {
                            self?.dataList = [[uid! :uid!]]
                        }
                    }
                },
                onError:{ [weak self] (error: Error?) in
                    ProgressHUD.dismiss()
                    OIMApi.showTipHandle
                    if let handler = OIMApi.showTipHandle {
                        handler("-1".innerLocalized(), { res in
                        })
                    }
                }
                ).disposed(by: _disposebag)
            }
        }
    }
    
    
    // 验证邮箱
    func isEmail(_ email: String) -> Bool {
        if email.count == 0 {
            return false
        }
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest:NSPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: email)
    }
    
    // 验证手机号
    func isPhoneNumber(_ phoneNumber: String) -> Bool {
        if phoneNumber.count == 0 {
            return false
        }
        let mobile = "^1([358][0-9]|4[579]|66|7[0135678]|9[89])[0-9]{8}$"
        let regexMobile = NSPredicate(format: "SELF MATCHES %@",mobile)
        if regexMobile.evaluate(with: phoneNumber) == true {
            return true
        } else {
            return false
        }
    }
}

extension SearchResultViewController: UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        
        if _searchType == .user {
            return usersList.count
        } else if  _searchType == .group {
            return groupsList.count
        } else {
            return dataList.count
        }
        
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if _searchType == .user {
            let cell = tableView.dequeueReusableCell(withIdentifier: YFSeacrhFriendListCell.className, for: indexPath) as! YFSeacrhFriendListCell
            let user = usersList[indexPath.row]
            cell.bindData(user: user)
            return cell
        }
        
        if _searchType == .group {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: YFSeacrhGroupListCell.className, for: indexPath) as! YFSeacrhGroupListCell
            let group = groupsList[indexPath.row]
            cell.bindData(group: group)
            return cell
        }
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultCell.className, for: indexPath) as! SearchResultCell
        let info = dataList[indexPath.row]
        
        let text = info.values.first
        cell.titleLabel.text = text
        
        return cell
    }
    
    public func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if _searchType == .user {
            let user = usersList[indexPath.row]
            didSelectedItem?(user.userID)
        } else if _searchType == .group {
            
            let group = groupsList[indexPath.row]
            didSelectedItem?(group.groupID)
            
        } else {
            let info = dataList[indexPath.row]
            if let id = info.keys.first {
                didSelectedItem?(id)
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func updateGroupMessage(groupID: String) {

        IMController.shared.getGroupInfo(groupIds: [groupID]) { [weak self] (groupInfos: [GroupInfo]) in
            guard let self else { return }
            guard let groupInfo = groupInfos.first else { return }
  
            groupsList = [groupInfo]
        }
    }
    
    
}



class YFSeacrhFriendListCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var leftIconImg: UIImageView = {
        let r = UIImageView()
        r.clipsToBounds = true
        r.layer.cornerRadius = 28
        r.contentMode = .scaleAspectFill
        r.image = .init(named: "DefaultAvatar")
        return r
    }()
    
    lazy var titleLbl: UILabel = {
        let r = UILabel()
        r.text = "username"
        r.textColor = .init(hexString: "#333333")
        r.font = UIFont(name: "PingFangSC-Semibold", size: 16)
        r.textAlignment = .left
        return r
    }()
    
    
    lazy var tagsLbl: UILabel = {
        let r = UILabel()
        r.text = "tag"
        r.textColor = .init(hexString: "#7238EF")
        r.font = UIFont(name: "PingFangSC-Semibold", size: 11)
        r.textAlignment = .left
        return r
    }()

    
    lazy var userIdLbl: UILabel = {
        let r = UILabel()
        r.text = "ID:"
        r.textColor = .init(hexString: "#666666")
        r.font = UIFont(name: "PingFangSC-Regular", size: 14)
        r.textAlignment = .left
        return r
    }()


    func initUI() {
        contentView.addSubview(leftIconImg)
        contentView.addSubview(tagsLbl)
        contentView.addSubview(titleLbl)
        contentView.addSubview(userIdLbl)

        
        
        leftIconImg.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.width.height.equalTo(56)
//            make.centerY.equalToSuperview()
            make.top.equalTo(8)
            make.bottom.equalTo(-8)
        }
        
        tagsLbl.snp.makeConstraints { make in
            make.left.equalTo(leftIconImg.snp_right).offset(13)
            make.centerY.equalTo(leftIconImg)
            make.height.equalTo(12)
        }
        
        titleLbl.snp.makeConstraints { make in
            make.left.equalTo(leftIconImg.snp_right).offset(13)
            make.bottom.equalTo(tagsLbl.snp_top).offset(-7)
            make.height.equalTo(17)
            make.right.equalToSuperview().inset(16)
        }
        
        userIdLbl.snp.makeConstraints { make in
            make.left.equalTo(leftIconImg.snp_right).offset(13)
            make.top.equalTo(tagsLbl.snp_bottom).offset(7)
            make.height.equalTo(14)
            make.right.equalToSuperview().inset(16)
        }
        
    }
    
    
    func  bindData(user: UserInfo) {
        titleLbl.text = SuperStringUtil.getUserState(showname: user.nickname!).n
        titleLbl.textColor = SuperStringUtil.getUserState(showname: user.nickname!).v > 0 ? .init(hexString: "#FF3939") : .init(hexString: "#333333")
        if let tag  = SuperStringUtil.getUserTag(showname: user.nickname!) {
            tagsLbl.text = tag
            tagsLbl.snp.makeConstraints { make in
                make.height.equalTo(12)
            }
            userIdLbl.snp.makeConstraints { make in
                make.top.equalTo(tagsLbl.snp_bottom).offset(7)
            }
            titleLbl.snp.makeConstraints { make in
                make.bottom.equalTo(tagsLbl.snp_top).offset(-7)
            }
        } else {
            tagsLbl.text = nil
            tagsLbl.snp.makeConstraints { make in
                make.height.equalTo(0)
            }
            userIdLbl.snp.makeConstraints { make in
                make.top.equalTo(tagsLbl.snp_bottom).offset(3.5)
            }
            titleLbl.snp.makeConstraints { make in
                make.bottom.equalTo(tagsLbl.snp_top).offset(-3.5)
            }
        }
        leftIconImg.setImageAbout(string: user.faceURL, placeHolder: "DefaultAvatar")
        userIdLbl.text = "ID:\(user.userID!)"
    }
    
}



class YFSeacrhGroupListCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var leftIconImg: UIImageView = {
        let r = UIImageView()
        r.clipsToBounds = true
        r.layer.cornerRadius = 28
        r.contentMode = .scaleAspectFill
        r.image = .init(named: "DefaultAvatar")
        return r
    }()
    
    lazy var titleLbl: UILabel = {
        let r = UILabel()
        r.text = "username"
        r.textColor = .init(hexString: "#333333")
        r.font = UIFont(name: "PingFangSC-Semibold", size: 16)
        r.textAlignment = .left
        return r
    }()
    
    
    lazy var tagLable: UILabel = {
        let v = UILabel()
        v.font = UIFont(name: "PingFangSC-Semibold", size: 11)
        v.textColor = .init(hexString: "#7238EF")
//        v.text = "[企业]".localized()
        v.text = nil
        return v
    }()
    
    lazy var userIdLbl: UILabel = {
        let r = UILabel()
        r.text = "ID:"
        r.textColor = .init(hexString: "#666666")
        r.font = UIFont(name: "PingFangSC-Regular", size: 14)
        r.textAlignment = .left
        return r
    }()


    func initUI() {
        contentView.addSubview(leftIconImg)
        contentView.addSubview(titleLbl)
        contentView.addSubview(tagLable)
        contentView.addSubview(userIdLbl)

        
        
        leftIconImg.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.width.height.equalTo(56)
//            make.centerY.equalToSuperview()
            make.top.equalTo(8)
            make.bottom.equalTo(-8)
        }

        tagLable.snp.makeConstraints { make in
            make.bottom.equalTo(titleLbl.snp_bottom).offset(-2)
            make.right.lessThanOrEqualToSuperview()
        }
        
        
        titleLbl.snp.makeConstraints { make in
            make.left.equalTo(leftIconImg.snp_right).offset(13)
            make.top.equalTo(leftIconImg.snp_top).offset(4)
            make.height.equalTo(22)
            make.right.lessThanOrEqualTo(tagLable.snp_left).offset(-2)
        }
        
        
        
        userIdLbl.snp.makeConstraints { make in
            make.left.equalTo(leftIconImg.snp_right).offset(13)
            make.top.equalTo(titleLbl.snp_bottom).offset(5)
            make.height.equalTo(20)
            make.right.equalToSuperview().inset(16)
        }
        
    }
    
    
    func  bindData(group: GroupInfo) {
        
        titleLbl.text = SuperStringUtil.getUserState(showname: group.groupName!).n

        setGroupImg(groupId: group.groupID)
        userIdLbl.text = "ID:\(group.groupID)"
        tagLable.text = "[\(group.memberCount)]"
        
    }
    
    func setGroupImg(groupId: String) {
       
       
       IMController.shared.getGroupMemberList(groupId: groupId, filter: .all, offset: 0, count: 4) { [self] ms in
               
           var faceUrlArr:[String] = []
           for item in ms {
               faceUrlArr.append(item.faceURL!)
           }
           
           if faceUrlArr.count > 0 {
               AvatarManager.placeholderImage = UIImage(named: "DefaultAvatar")!
               AvatarManager.groupAvatarType = .QQ
               AvatarManager.distanceBetweenAvatar = 1
               leftIconImg.setImageAvatar(groupId: groupId, groupSource: faceUrlArr)
           } else {
               
               leftIconImg.image = .init(named: "friend_list_new_friend_icon")
           }
           
       }
   }
    
}
