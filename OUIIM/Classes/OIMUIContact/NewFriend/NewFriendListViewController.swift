
import OUICore
import OUICoreView
import RxSwift
import ProgressHUD

class NewFriendListViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "新的好友请求".innerLocalized()
        view.backgroundColor = .systemGroupedBackground
        
        initView()
        bindData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _viewModel.getNewFriendApplications()
        
        navigationController?.navigationBar.isHidden = false

    }

    override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            navigationController?.navigationBar.isHidden = false
        }
    
    private lazy var tableView: UITableView = {
        let v = UITableView()
        v.register(NewFriendTableViewCell.self, forCellReuseIdentifier: NewFriendTableViewCell.className)
        v.rowHeight = 68.h
        v.tableFooterView = UIView()
        v.backgroundColor = .clear
        v.separatorColor = .cE8EAEF

        if #available(iOS 15.0, *) {
            v.sectionHeaderTopPadding = 0
        }
        return v
    }()

    private func initView() {
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(8)
            make.leading.bottom.trailing.equalToSuperview()
        }
        
        tableViewAddEmptyView()
        
    }

    private func bindData() {
        _viewModel.loading.asDriver().drive(onNext: { isLoading in
            if isLoading {
                ProgressHUD.animate()
            } else {
                ProgressHUD.dismiss()
            }
        }).disposed(by: _disposeBag)
        
        _viewModel.applications.asDriver(onErrorJustReturn: []).drive(tableView.rx.items) { [weak self] tableView, _, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: NewFriendTableViewCell.className) as! NewFriendTableViewCell
            
            guard let self else { return cell }
            
            cell.titleLabel.text = SuperStringUtil.getUserState(showname: item.fromNickname ?? "").n
            cell.subtitleLabel.text = item.reqMsg ?? ""
            if let state = NewFriendTableViewCell.ApplyState(rawValue: item.handleResult.rawValue) {
                cell.setApplyState(state, isSendOut: _viewModel.isSendOut(userID: item.fromUserID))
            }

            cell.avatarView.setAvatar(url: item.fromFaceURL, text: item.fromNickname)

            cell.agreeBtn.rx.tap.subscribe { [weak self] _ in

                let vc = ApplicationViewController(friendApplication: item)
                self?.navigationController?.pushViewController(vc, animated: true)
            }.disposed(by: cell.disposeBag)

            return cell
        }.disposed(by: _disposeBag)

        tableView.rx.modelSelected(FriendApplication.self).subscribe(onNext: { [weak self] (application: FriendApplication) in
            if let state = NewFriendTableViewCell.ApplyState(rawValue: application.handleResult.rawValue), state == .agreed {
//                let vc = UserDetailTableViewController(userId: application.fromUserID, groupId: nil)
//                self?.navigationController?.pushViewController(vc, animated: true)
//                print("背电极 \(application.fromUserID) +++++++  \(application.toUserID))")
                
                // MARK: -    获取会话信息
                IMController.shared.getConversation(sessionType: .c2c, sourceId: application.fromUserID) { [weak self] (conversation: ConversationInfo?) in
                    guard let conversation else { return }

                    let vc = ChatViewControllerBuilder().build(conversation, hiddenInputBar: false)
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
                
            }
        }).disposed(by: _disposeBag)
    }
    
    func tableViewAddEmptyView() {
        let emptyV:HDEmptyView = HDEmptyView.emptyActionViewWithImageStr(imageStr: "custom_blank_icon", titleStr: "空空如也".localized() as NSString, detailStr: "", btnTitleStr: "", target: self, action: #selector(reloadBtnAction)) as! HDEmptyView
        
        emptyV.titleLabTextColor = UIColor.red
        emptyV.actionBtnFont = UIFont.systemFont(ofSize: 19)
        emptyV.contentViewY = -90
        emptyV.actionBtnIsHidden = true
        emptyV.titleLabFont = UIFont(name: "PingFangSC-Medium", size: 16)!
        emptyV.titleLabTextColor =  UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
        
        tableView.ly_emptyView = emptyV
    }
    
    @objc func reloadBtnAction() {
        
    }
    
    private let _viewModel = NewFriendListViewModel()
    private let _disposeBag = DisposeBag()
}
