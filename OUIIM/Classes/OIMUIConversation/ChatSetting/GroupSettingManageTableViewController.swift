
import RxSwift
import ProgressHUD
import OUICore
import OUICoreView

class GroupSettingManageTableViewController: UITableViewController {
    private let _viewModel: GroupSettingManageViewModel
    private let _disposeBag = DisposeBag()
    init(groupInfo: GroupInfo, style: UITableView.Style = .insetGrouped) {
        _viewModel = GroupSettingManageViewModel(groupInfo: groupInfo)
        
        super.init(style: style)
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var sectionItems: [[RowType]]!
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ProgressHUD.dismiss()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "群聊设置".innerLocalized()
        navigationController?.navigationBar.isOpaque = false
        
        configureTableView()
        initView()
        bindData()
        _viewModel.initialStatus()
        
        
        navigationController!.navigationBar.backItem?.title = ""
                               
    }
     
   
    
    
    private func defaultSectionItems() -> [[RowType]] {
        return [
            [.muteAll],
            [.canViewProfile, .canAddFriend, .joinAuth],
            [.transferOwner]
        ]
    }
    
    private func configureTableView() {
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        tableView.backgroundColor = .secondarySystemBackground
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.register(SwitchTableViewCell.self, forCellReuseIdentifier: SwitchTableViewCell.className)
        tableView.register(OptionTableViewCell.self, forCellReuseIdentifier: OptionTableViewCell.className)
    }
    
    private func initView() {}
    
    private func bindData() {
        sectionItems = defaultSectionItems()
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
    
    override func numberOfSections(in _: UITableView) -> Int {
        return sectionItems.count
    }
    
    override func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionItems[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowType = sectionItems[indexPath.section][indexPath.row]
        switch rowType {
        case .transferOwner:
            let cell = tableView.dequeueReusableCell(withIdentifier: OptionTableViewCell.className) as! OptionTableViewCell
            cell.titleLabel.text = rowType.title
            return cell
            
        case .joinAuth:
            let cell = tableView.dequeueReusableCell(withIdentifier: OptionTableViewCell.className) as! OptionTableViewCell
            _viewModel.groupInfoRelay.subscribe(onNext: { [weak cell] (groupInfo: GroupInfo?) in
                cell?.subtitleLabel.text = groupInfo?.needVerificationText()
            }).disposed(by: cell.disposeBag)
            cell.titleLabel.text = rowType.title
            return cell

        case .muteAll:
            let cell = tableView.dequeueReusableCell(withIdentifier: SwitchTableViewCell.className) as! SwitchTableViewCell
            _viewModel.mutedAllRelay.bind(to: cell.switcher.rx.isOn).disposed(by: cell.disposeBag)
            cell.switcher.rx.controlEvent(.valueChanged).subscribe(onNext: { [weak self] in
                self?._viewModel.toggleMuteAll()
            }).disposed(by: cell.disposeBag)
            cell.titleLabel.text = rowType.title
            return cell

        case .canViewProfile:
            let cell = tableView.dequeueReusableCell(withIdentifier: SwitchTableViewCell.className) as! SwitchTableViewCell
            _viewModel.canViewProfileRelay.bind(to: cell.switcher.rx.isOn).disposed(by: cell.disposeBag)
            cell.switcher.rx.controlEvent(.valueChanged).subscribe(onNext: { [weak self] in
                self?._viewModel.toggleCanViewProfile()
            }).disposed(by: cell.disposeBag)
            cell.titleLabel.text = rowType.title
            
            return cell
        case .canAddFriend:
            let cell = tableView.dequeueReusableCell(withIdentifier: SwitchTableViewCell.className) as! SwitchTableViewCell
            _viewModel.canAddFriendRelay.bind(to: cell.switcher.rx.isOn).disposed(by: cell.disposeBag)
            cell.switcher.rx.controlEvent(.valueChanged).subscribe(onNext: { [weak self] in
                self?._viewModel.toggleCanAddFriend()
            }).disposed(by: cell.disposeBag)
            cell.titleLabel.text = rowType.title
            
            return cell
        }
    }
    
    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let rowType = sectionItems[indexPath.section][indexPath.row]
        switch rowType {

        case .transferOwner:
            let vc = MemberListViewController(viewModel: MemberListViewModel(groupInfo: _viewModel.groupInfoRelay.value!))

            vc.onTap = {[weak self, weak vc] member in
                guard let self else { return }
     
                presentAlert(title: "confirmTransferGroupToUser".innerLocalizedFormat(arguments: "\(member.nickname ?? "")")) { [self] in
                    self._viewModel.transferOwner(to: member.userID!) {
                        if let toVc = vc?.navigationController?.children.first(where: { $0.isKind(of: GroupChatSettingTableViewController.self)}) {
                            vc?.navigationController?.popToViewController(toVc, animated: true)
                        } else {
                            vc?.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }
            navigationController?.pushViewController(vc, animated: true)
        
        case .joinAuth:
            let alertController = AlertViewController(preferredStyle: .actionSheet)
            alertController.addAction(.init(title: "needVerification".innerLocalized(), style: .default, handler: {[weak self] action in
                self?._viewModel.updateVerificationOption(type: .allNeedVerification)
            }))

            alertController.addAction(.init(title: "allowAnyoneJoinGroup".innerLocalized(), style: .default, handler: {[weak self] action in
                self?._viewModel.updateVerificationOption(type: .directly)
            }))

            alertController.addAction(.init(title: "inviteNotVerification".innerLocalized(), style: .default, handler: {[weak self] action in
                self?._viewModel.updateVerificationOption(type: .applyNeedVerificationInviteDirectly)
            }))

            alertController.addAction(.init(title: "cancel".innerLocalized(), style: .cancel))

            present(alertController, animated: true)
        default:
            break
        }
    }
    
    enum RowType {
        case transferOwner
        case muteAll
        case joinAuth
        case canViewProfile
        case canAddFriend
        
        var title: String {
            switch self {
                
            case .transferOwner:
                return "transferGroupOwnerRight".innerLocalized()
            case .muteAll:
                return "全体禁言".innerLocalized()
            case .joinAuth:
                return "joinGroupSet".innerLocalized()
            case .canViewProfile:
                return "notAllowSeeMemberProfile".innerLocalized()
            case .canAddFriend:
                return "notAllAddMemberToBeFriend".innerLocalized()
            }
        }
    }
    
    deinit {
#if DEBUG
        print("dealloc \(type(of: self))")
#endif
    }
}
