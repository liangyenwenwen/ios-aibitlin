
import RxSwift
import ProgressHUD
import OUICore
import OUICoreView

class SingleChatSettingTableViewController: UITableViewController {
    private let _viewModel: SingleChatSettingViewModel
    
    init(viewModel: SingleChatSettingViewModel, style: UITableView.Style) {
        _viewModel = viewModel
        super.init(style: .insetGrouped)
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "聊天设置".innerLocalized()
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        configureTableView()
        bindData()
        initView()
        _viewModel.getConversationInfo()
    }
    
    private var sectionItems: [[RowType]] = [
        [.members],
        [.chatRecord],
        [.setTopOn, .setDisturbOn],
        [.burnAfterReading],
        [.regularlyDelete],
        [.changeChatBackground],
        [.clearRecord],
    ]
    
    private let _disposeBag = DisposeBag()
    
    
    private func configureTableView() {
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        
        tableView.register(SingleChatMemberTableViewCell.self, forCellReuseIdentifier: SingleChatMemberTableViewCell.className)
        tableView.register(SingleChatRecordTableViewCell.self, forCellReuseIdentifier: SingleChatRecordTableViewCell.className)
        tableView.register(SwitchTableViewCell.self, forCellReuseIdentifier: SwitchTableViewCell.className)
        tableView.register(OptionTableViewCell.self, forCellReuseIdentifier: OptionTableViewCell.className)
    }

    
    private func bindData() {
        _viewModel.burnAfterReadingRelay.subscribe { [weak self] on in
            self?.tableView.performBatchUpdates {
                if on {
                    self?.sectionItems[3] = [.burnAfterReading, .burnDuration]
                } else {
                    self?.sectionItems[3] = [.burnAfterReading]
                }
                
                self?.tableView.reloadSections([3], animationStyle: .automatic)
            }
        }.disposed(by: _disposeBag)
        
        _viewModel.regularlyDeleteRelay.subscribe(onNext: { [weak self] on in
            guard let self else { return }
            
            tableView.performBatchUpdates { [self] in
                if on {
                    self.sectionItems[4] = [.regularlyDelete, .regularlyDuration]
                } else {
                    self.sectionItems[4] = [.regularlyDelete]
                }
                
                self.tableView.reloadSections([4], animationStyle: .automatic)
            }
        }).disposed(by: _disposeBag)
    }
    
    private func initView() {}
    
    deinit {
        print("deinit")
    }
    
    func newGroup() {
        let vc = SelectContactsViewController()
        vc.selectedContact(hasSelected: _viewModel.membesRelay.value.compactMap({ $0.userID })) { [weak self] _, r in
            guard let self else { return }
            let users = r.map {UserInfo(userID: $0.ID!, nickname: $0.name, faceURL: $0.faceURL)}
            let vc = NewGroupViewController(users: users, groupType: .working)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func showBurnTimeView() {
        let values = [30, 5, 1, 1]
        let units = ["seconds".innerLocalized(), "minute".innerLocalized(), "hours".innerLocalized(), "day".innerLocalized()]
        
        let v = DurationPickerView(values: values, units: units, column: 1)
        v.titleLabel.text = "burnAfterReading".innerLocalized()
        v.descLabel.text = "burnAfterReadingDescription".innerLocalized()
        
        v.show()
        v.durationSelectionHandler = { [weak self] value, unit in
            var seconds = 0
            
            switch unit {
            case "seconds".innerLocalized():
                seconds = value
            case "minute".innerLocalized():
                seconds = value * 60
            case "hours".innerLocalized():
                seconds = value * 60 * 60
            case "day".innerLocalized():
                seconds = value * 24 * 60 * 60
            default:
                seconds = 0
            }
            
            self?.setBurnDuration(seconds: seconds)
        }
    }
    
    func setBurnDuration(seconds: Int) {
        ProgressHUD.animate()
        _viewModel.setBurnDuration(seconds) { [weak self] r in
            ProgressHUD.dismiss()
            self?.dismiss(animated: true, completion: nil)
        }
    }
    
    func durationString(seconds: Int) -> String {
        DurationPickerView.durationString(seconds: seconds)
    }
    
    private func showRegularlyDeleteView() {
        let values = Array(1...6)
        let units = ["day".innerLocalized(), "周".innerLocalized(), "月".innerLocalized()]
        
        let v = DurationPickerView(values: values, units: units, column: 2)
        v.titleLabel.text = "periodicallyDeleteMessage".innerLocalized()
        v.descLabel.text = "periodicallyDeleteMessageDescription".innerLocalized()
        
        v.show()
        v.durationSelectionHandler = { [weak self] value, unit in
            var seconds = 0
            
            switch unit {
            case "day".innerLocalized():
                seconds = value * 24 * 60 * 60
            case "周".innerLocalized():
                seconds = value * 7 * 24 * 60 * 60
            case "月".innerLocalized():
                // 这里的计算可以是一个近似值，因为每个月的天数不同
                seconds = value * 30 * 24 * 60 * 60
            default:
                seconds = 0
            }
            
            self?.setRegularlyDuration(seconds: seconds)
        }
    }
    
    func setRegularlyDuration(seconds: Int) {
        ProgressHUD.animate()
        _viewModel.setRegularlyDuration(seconds) { [weak self] _ in
            
            ProgressHUD.dismiss()
            self?.dismiss(animated: true, completion: nil)
        }
    }
    
    enum RowType: CaseIterable {
        case members
        case chatRecord
        case setTopOn
        case setDisturbOn
        case burnAfterReading
        case burnDuration
        case regularlyDelete
        case regularlyDuration
//        case complaint
        case clearRecord
        case changeChatBackground
        
        var title: String {
            switch self {
            case .members:
                return ""
            case .chatRecord:
                return "chatContent".innerLocalized()
            case .setTopOn:
                return "置顶联系人".innerLocalized()
            case .setDisturbOn:
                return "消息免打扰".innerLocalized()
            case .burnAfterReading:
                return "阅后即焚".innerLocalized()
            case .burnDuration:
                return "阅后即焚时长设置".innerLocalized()
            case .regularlyDelete:
                return "定期删除".innerLocalized()
            case .regularlyDuration:
                return "定期删除时长设置".innerLocalized()
//            case .complaint:
//                return "投诉".innerLocalized()
            case .clearRecord:
                return "清空聊天记录".innerLocalized()
            case .changeChatBackground:
                return "设置聊天背景".innerLocalized()
            }
        }
        
        var subTitle: String {
            switch self {
            case .setDisturbOn:
                return "messageNotDisturbHint".innerLocalized()
            default:
                return ""
            }
        }
    }
    
    override func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        return 12
    }
    
    override func tableView(_: UITableView, viewForHeaderInSection _: Int) -> UIView? {
        return UIView()
    }
    
    override func tableView(_: UITableView, viewForFooterInSection _: Int) -> UIView? {
        return UIView()
    }
    
    override func tableView(_: UITableView, heightForFooterInSection _: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let rowType = sectionItems[indexPath.section][indexPath.row]
        
        if rowType == .members || rowType == .chatRecord {
            return UITableView.automaticDimension
        }
        
        return 60
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    
    override func numberOfSections(in _: UITableView) -> Int {
        return sectionItems.count
    }
    
    override func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionItems[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowType = sectionItems[indexPath.section][indexPath.row]
        switch rowType {
        case .members:
            let cell = tableView.dequeueReusableCell(withIdentifier: SingleChatMemberTableViewCell.className) as! SingleChatMemberTableViewCell
            _viewModel.membesRelay.asDriver(onErrorJustReturn: []).drive(cell.memberCollectionView.rx.items) { (collectionView, row, item: UserInfo) in
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SingleChatMemberTableViewCell.MemberCell.className, for: IndexPath(row: row, section: 0)) as! SingleChatMemberTableViewCell.MemberCell
                if item.isAddButton {
                    cell.avatarView.setAvatar(url: nil, text: nil, placeHolder: "setting_add_btn_icon")
                } else {
                    cell.avatarView.setAvatar(url: item.faceURL, text: item.nickname, placeHolder: "contact_my_friend_icon")
                }
                cell.nameLabel.text = item.nickname

                return cell
            }.disposed(by: cell.disposeBag)
            
            cell.memberCollectionView.rx.modelSelected(UserInfo.self).subscribe(onNext: { [weak self] (userInfo: UserInfo) in
                guard let sself = self else { return }
                if userInfo.isAddButton {
                    sself.newGroup()
                } else {
                    let info = FullUserInfo(userID: userInfo.userID, showName: userInfo.nickname, faceURL: userInfo.faceURL)
                    let vc = UserDetailTableViewController(userId: userInfo.userID, groupId: sself._viewModel.conversation.groupID, userInfo: info)
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            }).disposed(by: cell.disposeBag)
            return cell
        case .chatRecord:
            let cell = tableView.dequeueReusableCell(withIdentifier: SingleChatRecordTableViewCell.className) as! SingleChatRecordTableViewCell
            cell.titleLabel.text = rowType.title
            
            cell.searchTextBtn.tap.rx.event.subscribe(onNext: { [weak self] _ in
                guard let sself = self else { return }
                let vc = SearchContainerViewController(conversation: sself._viewModel.conversation)
                self?.navigationController?.pushViewController(vc, animated: true)
            }).disposed(by: cell.disposeBag)
            
            cell.searchImageBtn.tap.rx.event.subscribe(onNext: { [weak self] _ in
                guard let sself = self else { return }
                let searchViewModel = SearchRecordViewModel(conversation: sself._viewModel.conversation)
                let vc = ImageRecordViewController(viewModel: searchViewModel, viewType: .image)
                self?.navigationController?.pushViewController(vc, animated: true)
            }).disposed(by: cell.disposeBag)
            
            cell.searchVideoBtn.tap.rx.event.subscribe(onNext: { [weak self] _ in
                guard let sself = self else { return }
                let searchViewModel = SearchRecordViewModel(conversation: sself._viewModel.conversation)
                let vc = ImageRecordViewController(viewModel: searchViewModel, viewType: .video)
                self?.navigationController?.pushViewController(vc, animated: true)
            }).disposed(by: cell.disposeBag)
            
            cell.searchFileBtn.tap.rx.event.subscribe(onNext: { [weak self] _ in
                guard let sself = self else { return }
                let viewModel = SearchRecordViewModel(conversation: sself._viewModel.conversation)
                let vc = FileRecordViewController(viewModel: viewModel)
                self?.navigationController?.pushViewController(vc, animated: true)
            }).disposed(by: cell.disposeBag)
            return cell
        case .setTopOn:
            let cell = tableView.dequeueReusableCell(withIdentifier: SwitchTableViewCell.className) as! SwitchTableViewCell
            _viewModel.setTopContactRelay.bind(to: cell.switcher.rx.isOn).disposed(by: cell.disposeBag)
            cell.switcher.rx.controlEvent(.valueChanged).subscribe(onNext: { [weak self] in
                self?._viewModel.toggleTopContacts()
            }).disposed(by: cell.disposeBag)
            cell.titleLabel.text = rowType.title
            return cell
        case .setDisturbOn:
            let cell = tableView.dequeueReusableCell(withIdentifier: SwitchTableViewCell.className) as! SwitchTableViewCell
            _viewModel.noDisturbRelay.bind(to: cell.switcher.rx.isOn).disposed(by: cell.disposeBag)
            cell.switcher.rx.controlEvent(.valueChanged).subscribe(onNext: { [weak self] in
                self?._viewModel.toggleNoDisturb()
            }).disposed(by: cell.disposeBag)
            cell.titleLabel.text = rowType.title
            cell.subTitleLabel.text = rowType.subTitle
            
            return cell
        case .burnAfterReading:
            let cell = tableView.dequeueReusableCell(withIdentifier: SwitchTableViewCell.className) as! SwitchTableViewCell
            _viewModel.burnAfterReadingRelay.bind(to: cell.switcher.rx.isOn).disposed(by: cell.disposeBag)
            cell.switcher.rx.controlEvent(.valueChanged).subscribe(onNext: { [weak self] in
                ProgressHUD.animate()
                self?._viewModel.togglePrivateChat() { _ in
                    ProgressHUD.dismiss()
                }
            }).disposed(by: cell.disposeBag)
            cell.titleLabel.text = rowType.title
            return cell
        case .burnDuration:
            let cell = tableView.dequeueReusableCell(withIdentifier: OptionTableViewCell.className) as! OptionTableViewCell
            _viewModel.burnDurationRelay.subscribe (onNext: { [weak cell, weak self] seconds in
                cell?.subtitleLabel.text = self?.durationString(seconds: Int(seconds))
            }).disposed(by: cell.disposeBag)
            cell.titleLabel.text = rowType.title
            return cell
            //        case .complaint:
            //            let cell = tableView.dequeueReusableCell(withIdentifier: OptionTableViewCell.className) as! OptionTableViewCell
            //            cell.titleLabel.text = rowType.title
            //            return cell
        case .regularlyDelete:
            let cell = tableView.dequeueReusableCell(withIdentifier: SwitchTableViewCell.className) as! SwitchTableViewCell
            _viewModel.regularlyDeleteRelay.bind(to: cell.switcher.rx.isOn).disposed(by: cell.disposeBag)
            cell.switcher.rx.controlEvent(.valueChanged).subscribe(onNext: { [weak self] in
                ProgressHUD.animate()
                self?._viewModel.toggleRegularlyDelete() { r in
                    ProgressHUD.dismiss()
                }
            }).disposed(by: cell.disposeBag)
            cell.titleLabel.text = rowType.title
            return cell
        case .regularlyDuration:
            let cell = tableView.dequeueReusableCell(withIdentifier: OptionTableViewCell.className) as! OptionTableViewCell
            _viewModel.regularlyDurationRelay.subscribe (onNext: { [weak cell, weak self] seconds in
                cell?.subtitleLabel.text = self?.durationString(seconds: Int(seconds))
            }).disposed(by: cell.disposeBag)
            cell.titleLabel.text = rowType.title
            return cell
        case .changeChatBackground:
            let cell = tableView.dequeueReusableCell(withIdentifier: OptionTableViewCell.className) as! OptionTableViewCell
            cell.titleLabel.text = rowType.title
            
            return cell
        case .clearRecord:
            let cell = tableView.dequeueReusableCell(withIdentifier: OptionTableViewCell.className) as! OptionTableViewCell
            cell.titleLabel.text = rowType.title
            cell.titleLabel.textColor = .cFF381F
            
            return cell
        }
    }
    
    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let rowType: RowType = sectionItems[indexPath.section][indexPath.row]
        switch rowType {
            //        case .complaint:
            //            ProgressHUD.animateInfo(withStatus: "参考商业版本".innerLocalized())
            //            print("跳转投诉页面")
        case .clearRecord:
            presentAlert(title: "确认清空所有聊天记录吗？".innerLocalized()) {
                ProgressHUD.animate(interaction: false)
                self._viewModel.clearRecord(completion: { _ in
                    NotificationCenter.default.post(name: Notification.Name.clearRecord, object: nil)
//                    ProgressHUD.success("清空成功".innerLocalized())
                    ProgressHUD.dismiss()
                    if let handler = OIMApi.showTipHandle {
                                    
                        handler("清空成功".innerLocalized(), { res in
                           
                        })
                    }
                })
            }
        case .burnDuration:
            showBurnTimeView()
        case .regularlyDuration:
            showRegularlyDeleteView()
        case .changeChatBackground:
            let vc = SetChatBackgroundViewController(conversationID: _viewModel.conversation.conversationID)
            
            navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
}
