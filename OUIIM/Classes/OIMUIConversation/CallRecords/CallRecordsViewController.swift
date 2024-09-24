
import OUICore
import OUICoreView
import RxSwift
import ProgressHUD
#if ENABLE_CALL
import OUICalling
#endif

#if ENABLE_LIVE_ROOM
import OUILive
#endif

class CallRecordsViewController: UIViewController {
#if ENABLE_CALL
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }

    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "音视频".innerLocalized()

        initView()
        bindData()
        _viewModel.getRecords()
    }
    
    deinit {
        hidesBottomBarWhenPushed = false
    }

    private lazy var tableView: UITableView = {
        let v = UITableView()
        v.register(FriendListUserTableViewCell.self, forCellReuseIdentifier: FriendListUserTableViewCell.className)
        v.separatorInset = UIEdgeInsets(top: 0, left: 82, bottom: 0, right: StandardUI.margin_22)
        v.separatorColor = .sepratorColor
        v.rowHeight = UITableView.automaticDimension
        v.delegate = self
        v.dataSource = self
        if #available(iOS 15.0, *) {
            v.sectionHeaderTopPadding = 0
        }
        return v
    }()

    private let allRecordsBtn: UnderlineButton = {
        let v = UnderlineButton(frame: .zero)
        v.setTitle("所有通话".innerLocalized(), for: .normal)
        v.setTitleColor(.c0C1C33, for: .normal)
        v.titleLabel?.font = .f14
        v.isSelected = true
        v.underLineWidth = 30
        return v
    }()

    private let missedRecordsBtn: UnderlineButton = {
        let v = UnderlineButton(frame: .zero)
        v.setTitle("未接通话".innerLocalized(), for: .normal)
        v.setTitleColor(.c0C1C33, for: .normal)
        v.titleLabel?.font = .f14
        v.underLineWidth = 30
        return v
    }()
    
    private let missedMeetingBtn: UnderlineButton = {
        let v = UnderlineButton(frame: .zero)
        v.setTitle("未结束会议".innerLocalized(), for: .normal)
        v.setTitleColor(.c0C1C33, for: .normal)
        v.titleLabel?.font = .f14
        v.underLineWidth = 30
        return v
    }()

    private lazy var resultC = GroupListResultViewController()

    private func initView() {
        
        let btnStackView: UIStackView = {
            let v = UIStackView(arrangedSubviews: [allRecordsBtn, missedRecordsBtn])
            v.frame = CGRect(origin: .zero, size: CGSize(width: kScreenWidth, height: 44))
            v.distribution = .fillEqually
            return v
        }()

        tableView.tableHeaderView = btnStackView
        tableView.tableFooterView = UIView()
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private let _viewModel = CallRecordsViewModel()
    private let _disposeBag = DisposeBag()
    private func bindData() {
        allRecordsBtn.rx.tap.subscribe(onNext: { [weak self] in
            self?._viewModel.tabSelected.accept(0)
        }).disposed(by: _disposeBag)
        
        missedRecordsBtn.rx.tap.subscribe(onNext: { [weak self] in
            self?._viewModel.tabSelected.accept(1)
        }).disposed(by: _disposeBag)
        
        missedMeetingBtn.rx.tap.subscribe(onNext: { [weak self] in
            self?._viewModel.tabSelected.accept(2)
        }).disposed(by: _disposeBag)
        
        _viewModel.tabSelected.subscribe(onNext: { [weak self] index in
            self?.allRecordsBtn.isSelected = index == 0
            self?.missedRecordsBtn.isSelected = index == 1
            self?.missedMeetingBtn.isSelected = index == 2
            self?.tableView.reloadData()
        }).disposed(by: _disposeBag)
        
        _viewModel.getRecords()
    }
    
    // 音视频通话
    private func startCalling(record: CallRecord) {
        CallingManager.manager.startLiveChat(othersID: [record.otherSideID!])
    }
#endif
    #if ENABLE_LIVE_ROOM
    
    private func startMeeting(meeting: MeetingInfo) {
        ProgressHUD.animate()
        _viewModel.joinMeeting(meetingID: meeting.roomID) { [weak self] invitaion in
            ProgressHUD.dismiss()
            guard let self else { return }
            LiveRoomViewController.showIn(viewController: self, invitationInfo: invitaion)

        } onFailure: { errCode, errMsg in
            if errMsg?.contains("roomIsNotExist") == true {
                ProgressHUD.error( "会议已经结束！".innerLocalized())
            } else {
                ProgressHUD.error( "网络异常请稍后再试！".innerLocalized())
            }
        }
    }
    #endif
}

#if ENABLE_CALL
extension CallRecordsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _viewModel.items.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FriendListUserTableViewCell.className, for: indexPath) as! FriendListUserTableViewCell
        cell.selectionStyle = .none
        
        let model = _viewModel.items.value[indexPath.row]
        
        if model is CallRecord, let model = model as? CallRecord {
            cell.titleLabel.text = model.nickname
            cell.subtitleLabel.text = "[\(model.typeStr())] \(model.formatDateStr())"
            cell.avatarImageView.setAvatar(url: model.faceURL, text: model.nickname, onTap: nil)
            cell.trainingLabel.text = model.durationStr()
            
            if !model.success {
                cell.titleLabel.textColor = .red
                cell.subtitleLabel.textColor = .red
                cell.trainingLabel.textColor = .red
                cell.trainingLabel.text = model.inOrOutStr()
            }
        } else if model is MeetingInfo, let model = model as? MeetingInfo {
            cell.titleLabel.text = model.meetingName
            cell.subtitleLabel.text = "\(Date.timeString(timeInterval: model.startTime * 1000)) - \(Date.timeString(timeInterval: model.endTime * 1000))"
            cell.avatarImageView.setAvatar(url: nil, text: nil, placeHolder: "live_room_record_icon")
            let now = Date().timeIntervalSince1970
            if now > model.endTime {
                cell.trainingLabel.text =  "[已结束]"
            } else if now < model.startTime {
                cell.trainingLabel.text =  "[未开始]"
            } else {
                cell.trainingLabel.text =  "[已开始]"
            }
            
            cell.titleLabel.textColor = .red
            cell.subtitleLabel.textColor = .red
            cell.trainingLabel.textColor = .red
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let record = _viewModel.items.value[indexPath.row]
        
#if ENABLE_LIVE_ROOM
        if CallingManager.isBusy || LiveRoomViewController.isBusy {
            presentAlert(title: "callingBusy".innerLocalized())
            
            return
        }
#else
        if CallingManager.isBusy {
            presentAlert(title: "callingBusy".innerLocalized())
            
            return
        }
#endif
        
        if record is CallRecord {
            // 吊起拨打电话界面
            startCalling(record: record as! CallRecord)
        } else {
            
        }
    }
}
#endif
