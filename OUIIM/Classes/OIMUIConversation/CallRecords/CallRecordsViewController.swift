
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
    
#if ENABLE_CALL
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        self.currentRow = -1
        _viewModel.getRecords()
        updateLanguage()
    }

    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        _viewModel.clearUnRecord()
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
//        navigationItem.title = "音视频".innerLocalized()
        let titleLbl = UILabel()
        titleLbl.font = UIFont(name: "PingFangSC-Medium", size: 18)
        titleLbl.textColor = .init(hexString: "#333333")
        titleLbl.text =  "音视频".innerLocalized()
        self.navigationItem.titleView = titleLbl

        initView()
        bindData()
        _viewModel.getRecords()
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
        view.backgroundColor  = .white
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
        
        _viewModel.getRecords()
    }
    
    // 音视频通话
    private func startCalling(record: CallRecord, isVideo: Bool = true) {
        CallingManager.manager.startLiveChat(othersID: [record.otherSideID!], isVideo: isVideo)
    }
    
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
        _viewModel.getRecords()
    }
#endif
//    #if ENABLE_LIVE_ROOM
//
//    private func startMeeting(meeting: MeetingInfoSetting) {
//        ProgressHUD.animate()
//        _viewModel.joinMeeting(meetingID: meeting.roomID) { [weak self] invitaion in
//            ProgressHUD.dismiss()
//            guard let self else { return }
//            LiveRoomViewController.showIn(viewController: self, invitationInfo: invitaion)
//
//        } onFailure: { errCode, errMsg in
//            if errMsg?.contains("roomIsNotExist") == true {
//                ProgressHUD.error( "会议已经结束！".innerLocalized())
//            } else {
//                ProgressHUD.error( "网络异常请稍后再试！".innerLocalized())
//            }
//        }
//    }
//    #endif
}

#if ENABLE_CALL
extension CallRecordsViewController: UITableViewDelegate, UITableViewDataSource {
    
    public    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _viewModel.items.value.count
    }
    
    public    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: YFCallRecordsListCell.className, for: indexPath) as! YFCallRecordsListCell
        cell.selectionStyle = .none
        
        let model = _viewModel.items.value[indexPath.row]
        
        if model is CallRecord, let model = model as? CallRecord {
            
            cell.update(model: model, indexRow: indexPath.row, currentRow: currentRow)
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
        
        cell.historyView.didClickBlock = {
            let temp = model as! CallRecord
            
//            let records = CallRecord.fromJson(jsonStr)
            let records = CallRecord.fromJson(temp.historyLogs)
            print(records)
            
            
        }

        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)  {
        
        let record = _viewModel.items.value[indexPath.row] as! CallRecord
        print(record.historyLogs)
        if record is CallRecord {
            
            if currentRow == indexPath.row {
                currentRow = -1
            } else {
                currentRow = indexPath.row
            }
            
            self.tableView.reloadData()
        }
        
    }
    
    
    public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .default, title: "删除".localized()) { res, index in
            print(res, index)
            
            self._viewModel.deleteRecord(record: self._viewModel.items.value[indexPath.row] as! CallRecord)
        }
        return [deleteAction]
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
}
#endif


class callRecordSameHistoryView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initViews() {
        addSubview(centerView)
        backgroundColor = .black.withAlphaComponent(0.5)
        
        centerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(306)
            make.centerY.equalToSuperview()
        }
        
        centerView.addSubview(userIcon)
        centerView.addSubview(userName)
        centerView.addSubview(cancelImg)
        centerView.addSubview(lineView)
        
        userIcon.snp.makeConstraints { make in
            make.top.leading.equalTo(16)
            make.width.height.equalTo(36)
        }
        
        userName.snp.makeConstraints { make in
            make.centerY.equalTo(userIcon)
            make.left.equalTo(userIcon.snp_right).offset(10)
            make.right.equalTo(-52)
        }
        
        cancelImg.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(-16)
            make.width.height.equalTo(28)
            make.centerY.equalTo(userIcon)
        }
        
        lineView.snp.makeConstraints { make in
            make.left.right.equalTo(0)
            make.top.equalTo(65)
            make.height.equalTo(1)
        }
        
        
        
        
    }
    
    lazy var centerView: UIView = {
        let r = UIView()
        r.backgroundColor = .white
        r.clipsToBounds = true
        r.layer.cornerRadius = 14
        return r
    }()
    
    lazy var userIcon: UIImageView = {
        let r = UIImageView()
        r.corner(radius: 18)
        return r
    }()
    
    lazy var userName: UILabel = {
        let r = UILabel()
        r.font = UIFont(name: "PingFangSC-Semibold", size: 16)
        return r
    }()
    
    lazy var cancelImg: UIImageView = {
        let r = UIImageView()
        return r
    }()
    
    lazy var lineView: UIView = {
        let r = UIView()
        r.backgroundColor = .init(hexString: "#EAEAEA")
        return r
    }()
    
    lazy var tableView: UITableView = {
        let r = UITableView()
        r.register(callRecordSameHistoryListCell.self, forCellReuseIdentifier: callRecordSameHistoryListCell.className)

        r.rowHeight = UITableView.automaticDimension
        r.backgroundColor = .clear
        return r
    }()
    
}

//, UITableViewDelegate, UITableViewDataSource
extension callRecordSameHistoryView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: callRecordSameHistoryListCell.className, for: indexPath) as! callRecordSameHistoryListCell
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 24
    }
}


class callRecordSameHistoryListCell: UITableViewCell {
    
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
        r.contentMode = .scaleAspectFill
        r.backgroundColor = .red
        return r
    }()
    
    lazy var titleLbl: UILabel = {
        let r = UILabel()
        r.text = "username"
        r.textColor = .init(hexString: "#666666")
        r.font = UIFont(name: "PingFangSC-Regular", size: 14)
        r.textAlignment = .left
        r.text = "9:11 呼入"
        return r
    }()
    
    
    func initUI() {
        
        contentView.addSubview(leftIconImg)
        contentView.addSubview(titleLbl)
        
        
        leftIconImg.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.width.height.equalTo(56)
            make.centerY.equalToSuperview()
        }
        
        titleLbl.snp.makeConstraints { make in
            make.left.equalTo(leftIconImg.snp_right).offset(13)
            make.top.equalTo(leftIconImg.snp_top).offset(4)
            make.height.equalTo(22)
        }
        
        
        
    }
    
    
    
    
    func bindData(model: CallRecord) {
        
        
    }
    

    
    
    
    
}
