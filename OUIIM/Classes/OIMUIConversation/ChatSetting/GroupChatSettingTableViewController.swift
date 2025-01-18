
import RxSwift
import ProgressHUD
import OUICore
import OUICoreView
import Photos

class GroupChatSettingTableViewController: UITableViewController {
    private let _viewModel: GroupChatSettingViewModel
    private let _disposeBag = DisposeBag()
    init(conversation: ConversationInfo, groupInfo: GroupInfo? = nil, style: UITableView.Style) {
        _viewModel = GroupChatSettingViewModel(conversation: conversation, groupInfo: groupInfo)
        super.init(style: .insetGrouped)
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var sectionItems: [[RowType]]!
    
    private lazy var _photoHelper: PhotoHelper = {
        let v = PhotoHelper()
        v.setConfigToPickAvatar()
        v.didPhotoSelected = { [weak self] (images: [UIImage], _: [PHAsset]) in
            guard var first = images.first else { return }
            ProgressHUD.animate()
            first = first.compress(expectSize: 3000 * 1024)
            let result = FileHelper.shared.saveImage(image: first)
            
            if result.isSuccess {
                self?._viewModel.uploadFile(fullPath: result.fullPath, onProgress: { [weak self] progress in
                    ProgressHUD.progress(progress)
                }, onComplete: {
//                    ProgressHUD.success("头像上传成功".innerLocalized())
                    ProgressHUD.dismiss()
                    if let handler = OIMApi.showTipHandle {
                                    
                        handler("头像上传成功".innerLocalized(), { res in
                           
                        })
                    }
                })
            } else {
                ProgressHUD.dismiss()
            }
        }
        
        v.didCameraFinished = { [weak self] (photo: UIImage?, _: URL?) in
            guard let sself = self else { return }
            if var photo {
                photo = photo.compress(expectSize: 3000 * 1024)
                let result = FileHelper.shared.saveImage(image: photo)
                if result.isSuccess {
                    self?._viewModel.uploadFile(fullPath: result.fullPath, onProgress: { [weak self] progress in
                        ProgressHUD.progress(progress)
                    }, onComplete: {
//                        ProgressHUD.success("头像上传成功".innerLocalized())
                        ProgressHUD.dismiss()
                        if let handler = OIMApi.showTipHandle {
                                        
                            handler("头像上传成功".innerLocalized(), { res in
                               
                            })
                        }
                    })
                }
            }
        }
        return v
    }()
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ProgressHUD.dismiss()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "群聊设置".innerLocalized()
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        configureTableView()
        initView()
        bindData()
        
        navigationController!.navigationBar.backItem?.title = ""

        
    }
    
    


    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _viewModel.getConversationInfo()
        navigationController?.navigationBar.isHidden = false
    }
    
    private var defaultSectionItems: [[RowType]] {
        [
            [.header],
            [.members],
            [.chatRecord],
            [.groupAnnounce],
            [.myNameInGroup],
            [.setTopOn, .setDisturbOn],
            [.report],
            [.regularlyDelete],
            [.clearRecord, .quitGroup],
        ]
    }
    
    private var notInGroupSectionItems: [[RowType]] {
        [
            [.chatRecord],
            [.groupAnnounce],
            [.myNameInGroup],
            [.setTopOn, .setDisturbOn],
            [.report],
            [.regularlyDelete],
            [.clearRecord, .quitGroup],
        ]
    }
    
    private func configureTableView() {
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }

        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorInset = .zero
        tableView.register(GroupBasicInfoCell.self, forCellReuseIdentifier: GroupBasicInfoCell.className)
        tableView.register(GroupChatMemberTableViewCell.self, forCellReuseIdentifier: GroupChatMemberTableViewCell.className)
        tableView.register(SwitchTableViewCell.self, forCellReuseIdentifier: SwitchTableViewCell.className)
        tableView.register(OptionTableViewCell.self, forCellReuseIdentifier: OptionTableViewCell.className)
        tableView.register(OptionImageTableViewCell.self, forCellReuseIdentifier: OptionImageTableViewCell.className)
        tableView.register(QuitTableViewCell.self, forCellReuseIdentifier: QuitTableViewCell.className)
        tableView.register(SingleChatRecordTableViewCell.self, forCellReuseIdentifier: SingleChatRecordTableViewCell.className)
    }
    
    private func initView() {}
    
    private func bindData() {
        sectionItems = defaultSectionItems
        
        _viewModel.isInGroupRelay.subscribe(onNext: { [weak self] isIn in
            guard let self else { return }
            
            sectionItems = isIn ? sectionItems : notInGroupSectionItems
            
            tableView.reloadData()
        }).disposed(by: _disposeBag)
        
        _viewModel.groupInfoRelay.subscribe(onNext: { [weak self] (groupInfo: GroupInfo?) in
            guard let self else { return }
            tableView.reloadData()
        }).disposed(by: _disposeBag)
        
        _viewModel.myInfoInGroup.subscribe(onNext: { [weak self] (memberInfo: GroupMemberInfo?) in
            guard let self else { return }
            
            let index = _viewModel.isInGroupRelay.value ? 3 : 1
            
            if let info = memberInfo {
                if info.roleLevel == .owner {
                    sectionItems[index] = [.groupAnnounce, .manage];
                } else {
                    sectionItems[index] = [.groupAnnounce];
                }
                
                tableView.reloadData()
            }
        }).disposed(by: _disposeBag)
        
        _viewModel.regularlyDeleteRelay.subscribe(onNext: { [weak self] on in
            guard let self else { return }
            
            let index = self._viewModel.isInGroupRelay.value ? 7 : 5
            
            if on {
                self.sectionItems[index] = [.regularlyDelete, .regularlyDuration]
            } else {
                self.sectionItems[index] = [.regularlyDelete]
            }
            tableView.reloadData()
        }).disposed(by: _disposeBag)
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
        
        if rowType == .chatRecord || rowType == .members || rowType == .header {
            return UITableView.automaticDimension
        }
        
        return 60
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
        case .header:
            let cell = tableView.dequeueReusableCell(withIdentifier: GroupBasicInfoCell.className, for: indexPath) as! GroupBasicInfoCell
            let groupInfo = _viewModel.groupInfoRelay.value
            let isAdmin = _viewModel.myInfoInGroup.value?.isOwnerOrAdmin == true;
            
            cell.avatarView.setGroupInfoImg(item: groupInfo!)
//            cell.avatarView.setAvatar(url: groupInfo?.faceURL, text: groupInfo?.groupName, showEdit: false, onTap: { [weak self] in
//                guard let self, isAdmin else { return }
//                
//                presentSelectedPictureActionSheet { [weak self] in
//                    guard let self else { return }
//                    
//                    _photoHelper.presentPhotoLibrary(byController: self)
//                } cameraHandler: { [weak self] in
//                    guard let self else { return }
//                    
//                    _photoHelper.presentCamera(byController: self)
//                }
//            })
            
            
            
            
            
            
            let count = groupInfo?.memberCount ?? 0
            cell.titleLabel.text = groupInfo?.groupName?.append(string: "(\(count))")
            cell.subLabel.text = groupInfo?.groupID
            cell.enableInput = isAdmin

            cell.inputHandler = { [weak self] in
                if isAdmin == false {
                    return
                }
                
                let vc = ModifyNicknameViewController()
                vc.titleLabel.text = "修改群聊名称".innerLocalized()
                vc.subtitleLabel.text = "修改群聊名称后，将在群内通知其他成员。".innerLocalized()
                vc.avatarView.setAvatar(url: self?._viewModel.groupInfoRelay.value?.faceURL, text: self?._viewModel.groupInfoRelay.value?.groupName)
                vc.nameTextField.text = self?._viewModel.groupInfoRelay.value?.groupName
          
                vc.completeBtn.rx.tap.subscribe(onNext: { [weak self, weak vc] in
                    guard let text = vc?.nameTextField.text, !text.isEmpty else { return }
                    ProgressHUD.animate()
                    self?._viewModel.updateGroupName(text, onSuccess: { _ in
                        ProgressHUD.success()
                        vc?.navigationController?.popViewController(animated: true)
                    })
                }).disposed(by: vc.disposeBag)
                self?.navigationController?.pushViewController(vc, animated: true)
            }
            
            cell.QRCodeTapHandler = { [weak self] in
                guard let self else { return }
                let vc = QRCodeViewController(idString: IMController.joinGroupPrefix.append(string: self._viewModel.conversation.groupID))
                vc.groupID = self._viewModel.conversation.groupID ?? ""
                vc.groupName = self._viewModel.conversation.showName ?? ""
                vc.groupImage = self._viewModel.conversation.faceURL ?? ""
                vc.groupDetailInfo = groupInfo ?? GroupInfo()
//                vc.avatarView.setAvatar(url: self._viewModel.conversation.faceURL, text: self._viewModel.conversation.showName)
//                vc.nameLabel.text = self._viewModel.conversation.showName
//                vc.tipLabel.text = "groupQrcodeHint".innerLocalized()
                self.navigationController?.pushViewController(vc, animated: true)
            }
            return cell
        case .members:
            let cell = tableView.dequeueReusableCell(withIdentifier: GroupChatMemberTableViewCell.className) as! GroupChatMemberTableViewCell
            cell.memberCollectionView.dataSource = nil
            _viewModel.membersRelay.asDriver(onErrorJustReturn: []).drive(cell.memberCollectionView.rx.items) { (collectionView: UICollectionView, row, item: GroupMemberInfo) in
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GroupChatMemberTableViewCell.ImageCollectionViewCell.className, for: IndexPath(row: row, section: 0)) as! GroupChatMemberTableViewCell.ImageCollectionViewCell
                cell.avatarView.layer.borderColor = UIColor.clear.cgColor
                cell.avatarView.layer.borderWidth = 2
                if item.isAddButton {
                    cell.avatarView.setAvatar(url: nil, text: nil, placeHolder: "setting_add_btn_icon")
                    cell.avatarView.layer.borderColor = UIColor.init(hexString: "#F5F5F5")?.cgColor
                } else if item.isRemoveButton {
                    cell.avatarView.setAvatar(url: nil, text: nil, placeHolder: "setting_remove_btn_icon")
                } else {
                    cell.avatarView.setAvatar(url: item.faceURL, text: item.nickname)
                    cell.levelLabel.text = item.roleLevelString
                }
                
                cell.nameLabel.text = SuperStringUtil.getUserState(showname: item.nickname ?? "").n
                
                return cell
            }.disposed(by: cell.disposeBag)
            
            cell.reloadData()
            
            _viewModel.membersCountRelay.map { "（\($0)）" }.bind(to: cell.countLabel.rx.text).disposed(by: cell.disposeBag)
            cell.titleLabel.text = rowType.title
            
            cell.memberCollectionView.rx.modelSelected(GroupMemberInfo.self).subscribe(onNext: { [weak self, weak cell] (userInfo: GroupMemberInfo) in
                guard let sself = self else { return }
                if userInfo.isAddButton || userInfo.isRemoveButton {
                    if userInfo.isAddButton {
#if ENABLE_ORGANIZATION
                        let vc = MyContactsViewController(types: [.friends, .staff], multipleSelected: true)
#else
                        let vc = MyContactsViewController(types: [.friends], multipleSelected: true)
#endif
                        vc.title = "邀请群成员".innerLocalized()
                        let blocked = sself._viewModel.allMembers + [IMController.shared.uid]

                        vc.selectedContact(blocked: blocked) { [weak self] (r: [ContactInfo]) in
                            guard let self else { return }
                            
                            ProgressHUD.animate()
                            _viewModel.inviteUsersToGroup(uids: r.compactMap({ $0.ID })) { [weak cell, weak vc] in
//                                ProgressHUD.success("invitationSuccessful".innerLocalized())
                                
                                ProgressHUD.dismiss()
                                if let handler = OIMApi.showTipHandle {
                                                
                                    handler("invitationSuccessful".innerLocalized(), { res in
                                       
                                    })
                                }
                                
                                cell?.reloadData()
                                vc?.navigationController?.popViewController(animated: true)
                            }
                        }
                        
                        self?.navigationController?.pushViewController(vc, animated: true)

                        return
                    }
#if ENABLE_ORGANIZATION
                    let vc = SelectContactsViewController(types: [.friends, .staff])
#else
                    let vc = SelectContactsViewController(types: [.members], sourceID: sself._viewModel.groupInfoRelay.value?.groupID)
#endif
                    vc.title = "移除群成员".innerLocalized()
                    
                    let blocked = sself._viewModel.myInfoInGroup.value?.roleLevel == .owner ? nil : sself._viewModel.superAndAdmins
                    
                    vc.selectedContact(hasSelected: [],
                                       blocked: blocked?.compactMap({ $0.userID })) { [weak vc] (_, r: [ContactInfo]) in
                        guard let sself = self, let groupID = sself._viewModel.groupInfoRelay.value?.groupID else { return }
                        
                        ProgressHUD.animate()
                        let uids = r.compactMap { $0.ID }
               
                        sself._viewModel.kickGroupMember(uids: uids) { [weak cell] in
                            ProgressHUD.dismiss()
                            cell?.reloadData()
                            vc?.navigationController?.popViewController(animated: true)
                        }
                        
                    }
                    self?.navigationController?.pushViewController(vc, animated: true)
                } else {
                    if self?._viewModel.groupInfoRelay.value?.lookMemberInfo == 0 {
                        
                        if let handler = OIMApi.gotoUserMessageHandle {
                            handler(self!, String(userInfo.userID!), userInfo.nickname ?? "", userInfo.faceURL ?? "",{res in

                            })
                        }
                        
//                        let vc = UserDetailTableViewController(userId: userInfo.userID!, groupId: sself._viewModel.conversation.groupID, groupInfo: sself._viewModel.groupInfoRelay.value!, groupMemberInfo: userInfo, userInfo: userInfo.toSimpleFullUserInfo())
//                        self?.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }).disposed(by: cell.disposeBag)
            
            return cell
        case .chatRecord:
            let cell = tableView.dequeueReusableCell(withIdentifier: SingleChatRecordTableViewCell.className, for: indexPath) as! SingleChatRecordTableViewCell
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
        case .groupAnnounce, .manage, .clearRecord,.report:
            let cell = tableView.dequeueReusableCell(withIdentifier: OptionTableViewCell.className, for: indexPath) as! OptionTableViewCell
            cell.titleLabel.text = rowType.title
            return cell
        case .myNameInGroup:
            let cell = tableView.dequeueReusableCell(withIdentifier: OptionTableViewCell.className, for: indexPath) as! OptionTableViewCell
            _viewModel.myInfoInGroup.subscribe(onNext: { [weak cell] (memberInfo: GroupMemberInfo?) in
                cell?.subtitleLabel.text = SuperStringUtil.getUserState(showname: memberInfo?.nickname ?? "").n
            }).disposed(by: cell.disposeBag)
            cell.titleLabel.text = rowType.title
            return cell
        case .setTopOn:
            let cell = tableView.dequeueReusableCell(withIdentifier: SwitchTableViewCell.className, for: indexPath) as! SwitchTableViewCell
            _viewModel.setTopContactRelay.bind(to: cell.switcher.rx.isOn).disposed(by: cell.disposeBag)
            cell.switcher.rx.controlEvent(.valueChanged).subscribe(onNext: { [weak self] in
                self?._viewModel.toggleTopContacts()
            }).disposed(by: cell.disposeBag)
            cell.titleLabel.text = rowType.title
            return cell
        case .setDisturbOn:
            let cell = tableView.dequeueReusableCell(withIdentifier: SwitchTableViewCell.className, for: indexPath) as! SwitchTableViewCell
            _viewModel.noDisturbRelay.bind(to: cell.switcher.rx.isOn).disposed(by: cell.disposeBag)
            cell.switcher.rx.controlEvent(.valueChanged).subscribe(onNext: { [weak self, weak cell] in
                guard let scell = cell else { return }
                // the state has been changed
                if !scell.switcher.isOn {
                    self?._viewModel.setNoDisturbOff()
                    return
                }
                self?._viewModel.setNoDisturbWithNotNotify()
                 
            }).disposed(by: cell.disposeBag)
            cell.titleLabel.text = rowType.title
            return cell
        case .regularlyDelete:
            let cell = tableView.dequeueReusableCell(withIdentifier: SwitchTableViewCell.className, for: indexPath) as! SwitchTableViewCell
            _viewModel.regularlyDeleteRelay.bind(to: cell.switcher.rx.isOn).disposed(by: cell.disposeBag)
            cell.switcher.rx.controlEvent(.valueChanged).subscribe(onNext: { [weak self] in
                ProgressHUD.animate()
                self?._viewModel.toggleRegularlyDelete() { _ in
                    ProgressHUD.dismiss()
                }
            }).disposed(by: cell.disposeBag)
            cell.titleLabel.text = rowType.title
            return cell
        case .regularlyDuration:
            let cell = tableView.dequeueReusableCell(withIdentifier: OptionTableViewCell.className, for: indexPath) as! OptionTableViewCell
            _viewModel.regularlyDurationRelay.subscribe (onNext: { [weak cell, weak self] seconds in
                cell?.subtitleLabel.text = self?.durationString(seconds: Int(seconds))
            }).disposed(by: cell.disposeBag)
            cell.titleLabel.text = rowType.title
            return cell
        case .quitGroup:
            let cell = tableView.dequeueReusableCell(withIdentifier: OptionTableViewCell.className, for: indexPath) as! OptionTableViewCell
            cell.titleLabel.textColor = .cFF381F
            _viewModel.isInGroupRelay.map({ [weak self] isIn -> String in
                if isIn {
                    return self?._viewModel.myInfoInGroup.value?.roleLevel == .owner ? "解散群聊".innerLocalized() : "退出群聊".innerLocalized()
                } else {
                    return "delete".innerLocalized()
                }
            }).bind(to: cell.titleLabel.rx.text).disposed(by: cell.disposeBag)
                
            return cell
        }
    }
    
    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let rowType = sectionItems[indexPath.section][indexPath.row]
        switch rowType {
        case .members:
            let vc = MemberListViewController(viewModel: MemberListViewModel(groupInfo: _viewModel.groupInfoRelay.value!))
            navigationController?.pushViewController(vc, animated: true)
        case .myNameInGroup:
            let vc = ModifyNicknameViewController()
//            vc.nameTextField.text = _viewModel.myInfoInGroup.value?.nickname
            vc.nameTextField.text = SuperStringUtil.getUserState(showname: _viewModel.myInfoInGroup.value?.nickname ?? "").n
            vc.avatarView.setAvatar(url: _viewModel.myInfoInGroup.value?.faceURL, text: _viewModel.myInfoInGroup.value?.nickname)
            vc.completeBtn.rx.tap.subscribe(onNext: { [weak self, weak vc] in
                let text = vc?.nameTextField.text ?? ""
                
                ProgressHUD.animate()
                self?._viewModel.updateMyNicknameInGroup(text, onSuccess: {
                    ProgressHUD.success()
                    vc?.navigationController?.popViewController(animated: true)
                })
            }).disposed(by: vc.disposeBag)
            navigationController?.pushViewController(vc, animated: true)
        case .groupAnnounce:
            guard let memberInfo = _viewModel.myInfoInGroup.value, let groupInfo = _viewModel.groupInfoRelay.value else { return }
            if memberInfo.isOwnerOrAdmin == true {
                let vc = GroupAnnounceViewController(groupInfo: groupInfo, notificationUserInfo: memberInfo)
                navigationController?.pushViewController(vc, animated: true)
            } else {
                presentAlert(title: "只有群主或者管理员才能设置群公告".innerLocalized())
            }
        case .chatRecord:
            let vc = SearchContainerViewController(conversation: _viewModel.conversation)
            navigationController?.pushViewController(vc, animated: true)
        case .manage:
            let vc = GroupSettingManageTableViewController(groupInfo: _viewModel.groupInfoRelay.value!)
            navigationController?.pushViewController(vc, animated: true)
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
        case .report:
            if let handler = OIMApi.reportChatGroupHandle {
                
                handler(self, _viewModel.conversation, { res in
                    
                })
            }
        case .quitGroup:
            if !_viewModel.isInGroupRelay.value {
                ProgressHUD.animate()
                
                _viewModel.removeConversation { [weak self] r in
                    if r {
                        ProgressHUD.animate()
                        self?.navigationController?.popToRootViewController(animated: true)
                    } else {
                        if let handler = OIMApi.showTipHandle {
                            handler("networkError".innerLocalized(), { res in
                               
                            })
                        }
//                        ProgressHUD.error("networkError".innerLocalized())
                    }
                }
                return
            }
            if let role = _viewModel.myInfoInGroup.value?.roleLevel, role == .owner {
                presentAlert(title: "解散群聊后，将失去和群成员的联系。".innerLocalized()) {
                    self._viewModel.dismissGroup(onSuccess: {
                        self.navigationController?.popToRootViewController(animated: true)
                    })
                }
            } else {
                presentAlert(title: "退出群聊后，将不再接收此群聊信息。".innerLocalized()) {
                    self._viewModel.quitGroup(onSuccess: {
                        self.navigationController?.popToRootViewController(animated: true)
                    })
                }
            }
        case .regularlyDuration:
            showRegularlyDeleteView()
        default:
            break
        }
    }
    
    enum RowType {
        case header
        case members
        case groupAnnounce
        case myNameInGroup
        case manage
        case chatRecord
        case setTopOn
        case setDisturbOn
        case clearRecord
        case quitGroup
        case regularlyDelete
        case regularlyDuration
        case report
        
        var title: String {
            switch self {
            case .header:
                return ""
            case .members:
                return "查看全部群成员".innerLocalized()
            case .myNameInGroup:
                return "我在群里的昵称".innerLocalized()
            case .groupAnnounce:
                return "群公告".innerLocalized()
            case .manage:
                return "群管理".innerLocalized()
            case .chatRecord:
                return "chatContent".innerLocalized()
            case .setTopOn:
                return "聊天置顶".innerLocalized()
            case .setDisturbOn:
                return "消息免打扰".innerLocalized()
            case .clearRecord:
                return "清空聊天记录".innerLocalized()
            case .quitGroup:
                return "退出群聊".innerLocalized()
            case .regularlyDelete:
                return "定期删除".innerLocalized()
            case .regularlyDuration:
                return "定期删除时长设置".innerLocalized()
            case .report:
                return "举报".innerLocalized()
            }
        }
    }
    
    deinit {
#if DEBUG
        print("dealloc \(type(of: self))")
#endif
    }
}
