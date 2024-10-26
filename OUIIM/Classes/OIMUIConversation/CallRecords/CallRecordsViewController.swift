
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

open class CallRecordsViewController: UIViewController {
    var isShow: Bool = false
    
#if ENABLE_CALL
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        self.currentRow = -1
        _viewModel.getRecords(true)
        isShow = true
//        NotificationCenter.default.post(name: Notification.Name("refrehCallLogsbadgeValue"), object: nil, userInfo: ["value": "\(0)"])
        
        updateLanguage()
    }

    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isShow = false
        
        _viewModel.clearUnRecord()
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
//        navigationItem.title = "音视频".innerLocalized()
        
        let titleLbl = UILabel()
        titleLbl.font = UIFont(name: "PingFangSC-Medium", size: 18)
        titleLbl.textColor = .init(hexString: "#333333")
        titleLbl.text =  "音视频".innerLocalized()
        self.navigationItem.titleView = titleLbl
        
        
        initView()
        bindData()
        _viewModel.getRecords(true)
        tableViewAddEmptyView()
    }
    
    func tableViewAddEmptyView() {
        tableView.ly_emptyView = emptyView
    }
    
    func updateLanguage() {
        
        emptyView._titleStr = "空空如也".localized() as NSString
        allLogsBtn.setTitle("通话记录".localized(), for: .normal)
        unreadLogsBtn.setTitle("未接来电".localized(), for: .normal)
    }
    
    
    lazy var emptyView:HDEmptyView  = {
        let emptyV:HDEmptyView = HDEmptyView.emptyActionViewWithImageStr(imageStr: "custom_blank_icon", titleStr: "空空如也".localized() as NSString, detailStr: "", btnTitleStr: "", target: self, action: #selector(reloadBtnAction)) as! HDEmptyView
        
        emptyV.titleLabTextColor = UIColor.red
        emptyV.actionBtnFont = UIFont.systemFont(ofSize: 19)
        emptyV.contentViewY = -90
        emptyV.actionBtnIsHidden = true
        emptyV.titleLabFont = UIFont(name: "PingFangSC-Medium", size: 16)!
        emptyV.titleLabTextColor =  UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
        return emptyV
    }()
    
    
    @objc func reloadBtnAction() {
        
    }
    
    deinit {
        hidesBottomBarWhenPushed = false
        NotificationCenter.default.removeObserver(self)
    }

    private lazy var tableView: UITableView = {
        let v = UITableView()
        v.register(FriendListUserTableViewCell.self, forCellReuseIdentifier: FriendListUserTableViewCell.className)
        
        v.register(YFCallRecordsListCell.self, forCellReuseIdentifier: YFCallRecordsListCell.className)
        
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

    var currentRow: Int = -1
    
    private func initView() {
        
//        let btnStackView: UIStackView = {
//            let v = UIStackView(arrangedSubviews: [allRecordsBtn, missedRecordsBtn])
//            v.frame = CGRect(origin: .zero, size: CGSize(width: kScreenWidth, height: 44))
//            v.distribution = .fillEqually
//            return v
//        }()
        
        view.backgroundColor  = .white

//        tableView.tableHeaderView = btnStackView
      
//        btnStackView.backgroundColor = .white
//        view.addSubview(btnStackView)
//        btnStackView.snp.makeConstraints { make in
//            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
//            make.left.equalToSuperview()
//            make.right.equalToSuperview()
//            make.height.equalTo(44)
//        }
        
        
        view.addSubview(chooseLogsView)
        chooseLogsView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(6)
            make.width.equalTo(172)
            make.height.equalTo(32)
            make.centerX.equalToSuperview()
        }
        
        allLogsBtn.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(2)
            make.top.bottom.equalToSuperview().inset(2)
            make.width.equalTo(83)
        }
        
        unreadLogsBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(2)
            make.top.bottom.equalToSuperview().inset(2)
            make.width.equalTo(83)
        }
        
        
        tableView.tableFooterView = UIView()
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
//            make.top.equalTo(btnStackView.snp_bottom)
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(54)
        }
    }

    private let _viewModel = CallRecordsViewModel()
    private let _disposeBag = DisposeBag()
    private func bindData() {
        
        // 注册对名为"refrehCallLogs"的通知的观察  刷新界面
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification), name: Notification.Name("refrehCallLogs"), object: nil)
        // 注册对名为"refrehCallLogsbadgeValue"的通知的观察  刷新badgeValue
//        NotificationCenter.default.addObserver(self, selector: #selector(refreshBadges(_:)), name: Notification.Name("refrehCallLogsbadgeValue"), object: nil)

      
        
        
        
//        allRecordsBtn.rx.tap.subscribe(onNext: { [weak self] in
//            self?._viewModel.tabSelected.accept(0)
//        }).disposed(by: _disposeBag)
//        
//        missedRecordsBtn.rx.tap.subscribe(onNext: { [weak self] in
//            self?._viewModel.tabSelected.accept(1)
//        }).disposed(by: _disposeBag)
//        
//        missedMeetingBtn.rx.tap.subscribe(onNext: { [weak self] in
//            self?._viewModel.tabSelected.accept(2)
//        }).disposed(by: _disposeBag)
//        
//        _viewModel.tabSelected.subscribe(onNext: { [weak self] index in
//            self?.allRecordsBtn.isSelected = index == 0
//            self?.missedRecordsBtn.isSelected = index == 1
//            self?.missedMeetingBtn.isSelected = index == 2
//            self?.tableView.reloadData()
//        }).disposed(by: _disposeBag)
        
        allLogsBtn.rx.tap.subscribe(onNext: { [weak self] in
            self?._viewModel.tabSelected.accept(0)
        }).disposed(by: _disposeBag)
        
        unreadLogsBtn.rx.tap.subscribe(onNext: { [weak self] in
            self?._viewModel.tabSelected.accept(1)
        }).disposed(by: _disposeBag)

        
        _viewModel.tabSelected.subscribe(onNext: { [weak self] index in
            self?.allLogsBtn.backgroundColor = index == 0 ? .white : .clear
            self?.unreadLogsBtn.backgroundColor = index == 1 ? .white : .clear
            self?.currentRow = -1
            self?.tableView.reloadData()
        }).disposed(by: _disposeBag)
        
        
        
        _viewModel.getRecords(true)
    }
    
    // 音视频通话
    private func startCalling(record: CallRecord, isVideo: Bool = true) {
        CallingManager.manager.startLiveChat(othersID: [record.otherSideID!], isVideo: isVideo)
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
            ProgressHUD.dismiss()
            if errMsg?.contains("roomIsNotExist") == true {
//                ProgressHUD.error( "会议已经结束！".innerLocalized())
                if let handler = OIMApi.showTipHandle {
                                
                    handler("会议已经结束！".innerLocalized(), { res in
                       
                    })
                }
            } else {
//                ProgressHUD.error( "网络异常请稍后再试！".innerLocalized())
                if let handler = OIMApi.showTipHandle {
                                
                    handler("网络异常请稍后再试！".innerLocalized(), { res in
                       
                    })
                }
            }
        }
    }
    #endif
    
    lazy var chooseLogsView: UIView = {
        let r = UIView()
        r.backgroundColor = .init(hexString: "#E8E8E8")
        r.clipsToBounds = true
        r.layer.cornerRadius = 9
        
        r.addSubview(allLogsBtn)
        r.addSubview(unreadLogsBtn)
        return r
    }()
    
    lazy var allLogsBtn: UIButton = {
        let r = UIButton()
        r.setTitle("通话记录".localized(), for: .normal)
        r.setTitleColor(.init(hexString: "#333333"), for: .normal)
        r.backgroundColor = .clear
        r.titleLabel?.font =  UIFont(name: "PingFangSC-Medium", size: 13)
        r.clipsToBounds = true
        r.layer.cornerRadius = 7
        r.backgroundColor = .white
        return r
    }()
    
    lazy var unreadLogsBtn: UIButton = {
        let r = UIButton()
        r.setTitle("未接来电".localized(), for: .normal)
        r.setTitleColor(.init(hexString: "#333333"), for: .normal)
        r.backgroundColor = .clear
        r.titleLabel?.font =  UIFont(name: "PingFangSC-Medium", size: 13)
        r.clipsToBounds = true
        r.layer.cornerRadius = 7
        return r
    }()
    
    
    
    // 处理接收到的通知  刷新通知
    @objc func handleNotification() {
        self.currentRow = -1
        _viewModel.getRecords(isShow)
    }
    
//    @objc func refreshBadges(_ notidication: Notification) {
//        
//        print(notidication.userInfo)
//        
//        if  let userinfo = notidication.userInfo, let receivedValue = userinfo["value"] as? String {
//            print(receivedValue)
//            
//        }
//    }
    
    
   
}

#if ENABLE_CALL
extension CallRecordsViewController: UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _viewModel.items.value.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: YFCallRecordsListCell.className, for: indexPath) as! YFCallRecordsListCell
        cell.selectionStyle = .none
        
        let model = _viewModel.items.value[indexPath.row]
        
        if model is CallRecord, let model = model as? CallRecord {
            
            cell.update(model: model, indexRow: indexPath.row, currentRow: currentRow)
        } else if model is MeetingInfo, let model = model as? MeetingInfo {
            
            cell.update(model: model)
        }
        
        cell.videoView.didClickBlock = {
            let temp = model as! CallRecord
            temp.type = "video"
            print("video")
            self.startCalling(record: temp, isVideo: true)
        }
        cell.audioView.didClickBlock = {
            let temp = model as! CallRecord
            temp.type = "audio"
            print("audio")
            self.startCalling(record: temp, isVideo: false)
        }
        
        
        return cell
        
        
//        let cell = tableView.dequeueReusableCell(withIdentifier: FriendListUserTableViewCell.className, for: indexPath) as! FriendListUserTableViewCell
//        cell.selectionStyle = .none
//        
//        let model = _viewModel.items.value[indexPath.row]
//        
//        if model is CallRecord, let model = model as? CallRecord {
//            cell.titleLabel.text = model.nickname
//            cell.subtitleLabel.text = "[\(model.typeStr())] \(model.formatDateStr())"
//            cell.avatarImageView.setAvatar(url: model.faceURL, text: model.nickname, onTap: nil)
//            cell.trainingLabel.text = model.durationStr()
//            
//            if !model.success {
//                cell.titleLabel.textColor = .red
//                cell.subtitleLabel.textColor = .red
//                cell.trainingLabel.textColor = .red
//                cell.trainingLabel.text = model.inOrOutStr()
//            }
//        } else if model is MeetingInfo, let model = model as? MeetingInfo {
//            cell.titleLabel.text = model.meetingName
//            cell.subtitleLabel.text = "\(Date.timeString(timeInterval: model.startTime * 1000)) - \(Date.timeString(timeInterval: model.endTime * 1000))"
//            cell.avatarImageView.setAvatar(url: nil, text: nil, placeHolder: "live_room_record_icon")
//            let now = Date().timeIntervalSince1970
//            if now > model.endTime {
//                cell.trainingLabel.text =  "[已结束]"
//            } else if now < model.startTime {
//                cell.trainingLabel.text =  "[未开始]"
//            } else {
//                cell.trainingLabel.text =  "[已开始]"
//            }
//            
//            cell.titleLabel.textColor = .red
//            cell.subtitleLabel.textColor = .red
//            cell.trainingLabel.textColor = .red
//        }
//        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)  {
        
        let record = _viewModel.items.value[indexPath.row]
        
        if record is CallRecord {
            
            if currentRow == indexPath.row {
                currentRow = -1
            } else {
                currentRow = indexPath.row
            }
            
            self.tableView.reloadData()
        }
        
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .default, title: "删除") { res, index in
            print(res, index)
            
            self._viewModel.deleteRecord(record: self._viewModel.items.value[indexPath.row] as! CallRecord)
//            self.tableView.reloadData()
        }
        return [deleteAction]
    }
    
   
    
//    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        
////        tableView.deselectRow(at: indexPath, animated: true)
////                // 创建UIAlertController
////                let alertController = UIAlertController(title: "Title", message: "Your message here", preferredStyle: .alert)
////                
////                // 创建UIAlertAction，用于处理点击气泡按钮的事件
////                let okAction = UIAlertAction(title: "OK", style: .default, handler: { _ in
////                    // 点击OK后的处理
////                })
////                
////                alertController.addAction(okAction)
////                
////                // 显示UIAlertController
////                present(alertController, animated: true, completion: nil)
//        
////        tableView.reloadRows(at: [indexPath], with: .automatic)
//        
//        let record = _viewModel.items.value[indexPath.row]
//        
//#if ENABLE_LIVE_ROOM
//        if CallingManager.isBusy || LiveRoomViewController.isBusy {
//            presentAlert(title: "callingBusy".innerLocalized())
//            
//            return
//        }
//#else
//        if CallingManager.isBusy {
//            presentAlert(title: "callingBusy".innerLocalized())
//            
//            return
//        }
//#endif
//        
//        if record is CallRecord {
//            // 吊起拨打电话界面
//            startCalling(record: record as! CallRecord)
////            let temp = record as! CallRecord
////            temp.type = "video" "audio"
//        } else {
//            
//        }
//    }
    
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
}
#endif
