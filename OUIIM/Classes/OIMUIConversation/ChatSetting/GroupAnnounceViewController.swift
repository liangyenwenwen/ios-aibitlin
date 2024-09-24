
import RxSwift
import ProgressHUD
import OUICore

class GroupAnnounceViewController: UIViewController {
    private let avatarView = AvatarView()
    
    private let nameLabel: UILabel = {
        let v = UILabel()
        v.font = .f17
        v.textColor = .c0C1C33
        return v
    }()
    
    private let timeLabel: UILabel = {
        let v = UILabel()
        v.font = .f12
        v.textColor = .c8E9AB0
        return v
    }()
    
    private let contentTextView: UITextView = {
        let v = UITextView()
        v.font = .f17
        v.textColor = .c0C1C33
        v.isEditable = false
        v.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        return v
    }()
    
    private let tipsView: SeparatorView = {
        let v = SeparatorView()
        v.titleLabel.textColor = .c8E9AB0
        v.titleLabel.font = .f12
        v.titleLabel.text = "groupAcPermissionTips".innerLocalized()
        
        return v
    }()
    
    private lazy var headerContainer: UIView = {
        let v = UIView()
        v.addSubview(avatarView)
        avatarView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(StandardUI.margin_22)
            make.top.bottom.equalToSuperview().inset(10)
        }
        v.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(avatarView.snp.right).offset(18)
            make.top.equalTo(avatarView).offset(2)
            make.right.lessThanOrEqualToSuperview().offset(-10)
        }
        v.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { make in
            make.left.equalTo(nameLabel)
            make.top.equalTo(nameLabel.snp.bottom).offset(2)
        }
        let separatorLine: UIView = {
            let v = UIView()
            v.backgroundColor = .cF0F0F0
            return v
        }()
        v.addSubview(separatorLine)
        separatorLine.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(1)
        }
        
        v.isHidden = true
        
        return v
    }()
    
    private lazy var editBtn: UIBarButtonItem = {
        let v = UIBarButtonItem()
        v.title = "编辑".innerLocalized()
        return v
    }()
    
    private let _disposeBag = DisposeBag()
    private var notificationUserInfo: GroupMemberInfo?
    private var groupInfo: GroupInfo!
    
    init(groupInfo: GroupInfo, notificationUserInfo: GroupMemberInfo? = nil) {
        self.notificationUserInfo = notificationUserInfo
        self.groupInfo = groupInfo
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .viewBackgroundColor
        
        if notificationUserInfo?.isOwnerOrAdmin == true {
            navigationItem.rightBarButtonItem = editBtn
            tipsView.isHidden = true
        } else {
            IMController.shared.getGroupMemberList(groupId: groupInfo.groupID, filter: .superAndAdmin, offset: 0, count: 100) { [weak self] ms in
                guard let self else { return }
                notificationUserInfo = ms.first(where: { $0.userID == self.groupInfo.notificationUserID })
                let isOwnerOrAdmin = notificationUserInfo?.userID == IMController.shared.uid
                
                contentTextView.isEditable = isOwnerOrAdmin
                if isOwnerOrAdmin {
                    navigationItem.rightBarButtonItem = editBtn
                    tipsView.isHidden = true
                } else {
                    headerContainer.isHidden = false
                }
                
                if notificationUserInfo != nil {
                    avatarView.setAvatar(url: notificationUserInfo?.faceURL, text: notificationUserInfo?.nickname)
                    nameLabel.text = notificationUserInfo?.nickname
                    setNotificationUpdateTime()
                }
            }
        }

        initView()
        bindData()
    }

    private func initView() {
        navigationItem.title = "群公告".innerLocalized()
        let vStack: UIStackView = {
            let v = UIStackView(arrangedSubviews: [headerContainer, contentTextView])
            v.axis = .vertical
            v.layer.cornerRadius = 6
            v.layer.masksToBounds = true
            v.backgroundColor = .cellBackgroundColor
            
            return v
        }()
        view.addSubview(vStack)
        vStack.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(8)
            make.leading.trailing.equalToSuperview().inset(8)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }
        
        view.addSubview(tipsView)
        tipsView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }
    }

    private func bindData() {
        contentTextView.text = groupInfo.notification
        editBtn.rx.tap.subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            
            self.contentTextView.isEditable = true
            
            if self.editBtn.title == "编辑" {
                self.contentTextView.becomeFirstResponder()
            } else {
                self.contentTextView.resignFirstResponder()
                presentAlert(title: "该公告会通知全部群成员，是否发布？".innerLocalized()) { [weak self] in
                    guard let self else { return }
                    
                    let group = GroupInfo(groupID: groupInfo.groupID)
                    group.notification = contentTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    IMController.shared.setGroupInfo(group: group) { _ in
                        ProgressHUD.success(nil)
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
            
            self.editBtn.title = "发布".innerLocalized()
            
        }).disposed(by: _disposeBag)

        contentTextView.rx.didChange.subscribe(onNext: { [weak self] in
            guard let sself = self else { return }
            self?.editBtn.isEnabled = !sself.contentTextView.text.isEmpty
        }).disposed(by: _disposeBag)
    }
    
    private func setNotificationUpdateTime() {
        timeLabel.text = "更新于".innerLocalized() + Date.timeString(timeInterval: TimeInterval(groupInfo.notificationUpdateTime))
    }

    class SeparatorView: UIView {
        let titleLabel: UILabel = {
            let v = UILabel()
            v.textAlignment = .center
            v.translatesAutoresizingMaskIntoConstraints = false
            v.setContentHuggingPriority(.defaultLow, for: .horizontal)
            
            return v
        }()

        override init(frame: CGRect) {
            super.init(frame: frame)
            let leftIcon = UIView()
            leftIcon.backgroundColor = .c8E9AB0
            let rightIcon = UIView()
            rightIcon.backgroundColor = .c8E9AB0
            
            let hStack: UIStackView = {
                let v = UIStackView(arrangedSubviews: [leftIcon, titleLabel, rightIcon])
                v.spacing = 8
                v.alignment = .center
                v.distribution = .fillProportionally
                
                return v
            }()
            addSubview(hStack)
            hStack.snp.makeConstraints { make in
                make.edges.equalToSuperview()
                make.height.equalTo(30)
                make.width.equalTo(260)
            }
            
            leftIcon.snp.makeConstraints { make in
                make.height.equalTo(1)
                make.width.equalTo(30)
            }
            
            rightIcon.snp.makeConstraints { make in
                make.height.equalTo(1)
                make.width.equalTo(30)
            }
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
