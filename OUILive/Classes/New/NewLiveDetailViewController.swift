
import RxSwift
import ProgressHUD
import SnapKit
import OUICore
import OUICoreView
import OUICalling

class NewLiveDetailViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    
    private var meetingInfo: MeetingInfo!
    
    private var viewModel: NewLiveDetailViewModel!
    
    init(meetingInfo: MeetingInfo) {
        super.init(nibName: nil, bundle: nil)
        self.meetingInfo = meetingInfo
        viewModel = NewLiveDetailViewModel(meetingInfo: meetingInfo)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 标题
    lazy var nameLabel: UILabel = {
        let v = UILabel()
        v.font = .f17
        v.textColor = .c0C1C33
        
        return v
    }()
    
    // 开始时间
    lazy var beginTimeLabel: UILabel = {
        let v = UILabel()
        v.font = .f20
        v.textAlignment = .center
        v.textColor = .c0C1C33
        
        return v
    }()
    
    // 开始状态
    lazy var statusLabel: UILabel = {
        let v = UILabel()
        v.font = .f12
        v.backgroundColor = .systemBlue
        v.textColor = .white
        v.layer.masksToBounds = true
        v.layer.cornerRadius = 5
        
        return v
    }()
    
    // 结束时间
    lazy var endTimeLabel: UILabel = {
        let v = UILabel()
        v.font = .f20
        v.textAlignment = .center
        v.textColor = .c0C1C33
        
        return v
    }()
    
    // 开始日期
    lazy var beginDateLabel: UILabel = {
        let v = UILabel()
        v.font = .f14
        v.textColor = .c8E9AB0
        v.textAlignment = .center
        
        return v
    }()
    
    // 时长
    lazy var durationLabel: UILabel = {
        let v = UILabel()
        v.font = .f14
        v.textColor = .c8E9AB0
        v.textAlignment = .center
        
        return v
    }()
    
    // 结束时间
    lazy var endDateLabel: UILabel = {
        let v = UILabel()
        v.font = .f14
        v.textColor = .c8E9AB0
        v.textAlignment = .center
        
        return v
    }()
    
    // 会议号
    lazy var IDLabel: UILabel = {
        let v = UILabel()
        v.font = .f17
        v.textColor = .c0C1C33
        
        return v
    }()
    
    lazy var copyButton: UIButton = {
        let v = UIButton(type: .system)
        v.setImage(UIImage(nameInBundle: "live_room_copy_icon"), for: .normal)
        v.rx.tap.subscribe(onNext: { [weak self] _ in
            UIPasteboard.general.string = self?.meetingInfo.roomID
        }).disposed(by: disposeBag)
        return v
    }()
    
    // 发起人
    lazy var hosterLabel: UILabel = {
        let v = UILabel()
        v.font = .f17
        v.textColor = .c0C1C33
        
        return v
    }()
    
    lazy var joinButton: UIButton = {
        let v = UIButton(type: .system)
        v.setTitle("进入会议".innerLocalized(), for: .normal)
        v.backgroundColor = .systemBlue
        v.setTitleColor(.white, for: .normal)
        v.layer.cornerRadius = 6
        
        v.rx.tap.subscribe(onNext: { [weak self] _ in
            self?.view.endEditing(true)
            if CallingManager.isBusy || LiveRoomViewController.isBusy {
                self?.presentAlert(title: "callingBusy".innerLocalized())
                
                return
            }
            ProgressHUD.animate()
            self?.viewModel.joinMeeting({ [weak self] invitaion in
                ProgressHUD.dismiss()
                guard let self else { return }
                LiveRoomViewController.showIn(viewController: self, invitationInfo: invitaion)
                
            }, onFailure: { errCode, errMsg in
                if errMsg?.contains("roomIsNotExist") == true {
                    ProgressHUD.error("会议已经结束！".innerLocalized())
                } else {
                    ProgressHUD.error("网络异常请稍后再试！".innerLocalized())
                }
            })
        }).disposed(by: disposeBag)
        return v
    }()
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .viewBackgroundColor
        
        let shareButton = UIBarButtonItem(image: UIImage(nameInBundle: "live_room_share_icon"), style: .done, target: self, action: #selector(share))
        let moreButton = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), style: .done, target: self, action: #selector(more))
        navigationItem.setRightBarButtonItems([moreButton, shareButton], animated: false)
        
        let container = UIView()
        container.backgroundColor = .cellBackgroundColor
        
        view.addSubview(container)
        container.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
        }
        
        let statusView = UIView()
        statusView.addSubview(statusLabel)
        statusLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        let timeRow = UIStackView(arrangedSubviews: [beginTimeLabel, statusView, endTimeLabel])
        timeRow.alignment = .center
        timeRow.distribution = .fillEqually
        
        let dateRow = UIStackView(arrangedSubviews: [beginDateLabel, durationLabel, endDateLabel])
        dateRow.alignment = .center
        dateRow.distribution = .fillEqually
    
        let section1 = UIStackView(arrangedSubviews: [nameLabel, timeRow, dateRow])
        section1.spacing = 16
        section1.axis = .vertical
        
        container.addSubview(section1)
        section1.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview().inset(16)
        }
        
        let space = UIView()
        space.backgroundColor = .viewBackgroundColor
        
        container.addSubview(space)
        space.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(section1.snp.bottom).offset(16)
            make.height.equalTo(20)
        }
        
        let section2 = UIStackView(arrangedSubviews: [IDLabel, hosterLabel])
        section2.spacing = 20
        section2.axis = .vertical
        
        container.addSubview(section2)
        section2.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview().inset(16)
            make.top.equalTo(space.snp.bottom).offset(16)
        }
        
        view.addSubview(joinButton)
        joinButton.snp.makeConstraints { make in
            make.top.equalTo(container.snp.bottom).offset(48)
            make.centerX.equalToSuperview()
            make.width.equalTo(230)
            make.height.equalTo(44)
        }

        refreshData()
        
        viewModel.getHosterInfo { [weak self] name in
            self?.hosterLabel.text = "发起人".innerLocalized() + ":" + name
        }
    }
    
    func refreshData()  {
        nameLabel.text = meetingInfo.meetingName
        
        let beginItems = Date.timeString(timeInterval: meetingInfo.startTime * 1000).split(separator: " ")
        beginTimeLabel.text = String(beginItems.last!)
        beginDateLabel.text = String(beginItems.first!)
        
        let endItems = Date.timeString(timeInterval: meetingInfo.endTime * 1000).split(separator: " ")
        endTimeLabel.text = String(endItems.last!)
        endDateLabel.text = String(endItems.first!)
        
        let now = Date().timeIntervalSince1970
        if now > meetingInfo.endTime {
            statusLabel.text =  " " + "已结束".innerLocalized() + " "
        } else if now < meetingInfo.startTime {
            statusLabel.text =  " " + "未开始".innerLocalized() + " "
        } else {
            statusLabel.text =  " " + "已开始".innerLocalized() + " "
        }
        
        durationLabel.text = "—" + String((meetingInfo.endTime - meetingInfo.startTime) / 60 / 60) + "小时".innerLocalized() + "—"
        IDLabel.text = "会议号".innerLocalized() + ":" + meetingInfo.roomID
    }
    
    @objc func share() {
        let vc = GroupFriendsListViewController()
        vc.selectFriendCallBack = { [weak self] (user) in
            guard let self else { return }
            
            presentAlert(title: "确认发送邀请吗？".innerLocalized()) {
                IMController.shared.getConversation(sessionType: .c2c, sourceId: user.userID) { [weak self] (conversation: ConversationInfo?) in
                    guard let self, let conversation else { return }
                    
                    viewModel.sendMeetingMessage(desID: user.userID, conversationType: .c2c)
                    navigationController?.popViewController(animated: true)
                }
            }
        }
        
        vc.selectGroupCallBack = { [weak self] (groupInfo) in
            guard let self else { return }

            presentAlert(title: "确认发送邀请吗？".innerLocalized()) {
                IMController.shared.getConversation(sessionType: .superGroup, sourceId: groupInfo.groupID) { [weak self] (conversation: ConversationInfo?) in
                    guard let self, let conversation else { return }
                    
                    viewModel.sendMeetingMessage(desID: groupInfo.groupID, conversationType: .superGroup)
                    navigationController?.popViewController(animated: true)
                }
            }
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func more() {
        presentActionSheet(action1Title: "修改会议信息".innerLocalized(), action1Handler: { [self] in
            let vc = NewLiveViewController(operateType: .modify, meetingInfo: meetingInfo) { r in
                self.meetingInfo = meetingInfo
                self.refreshData()
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }, action2Title: "取消会议".innerLocalized()) { [self] in
            self.viewModel.closeRoom { r in
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}


