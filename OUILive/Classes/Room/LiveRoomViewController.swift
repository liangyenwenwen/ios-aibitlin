
import OUICore
import OUICoreView
import SnapKit
import LiveKitClient
import AVFAudio
import Promises
import OUICalling
import RxSwift
import ProgressHUD

public class LiveRoomViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    
    internal var cameraTrackState: TrackPublishState = .notPublished()
    internal var microphoneTrackState: TrackPublishState = .notPublished()
    internal var screenShareTrackState: TrackPublishState = .notPublished()
    internal let sdk = DispatchQueue(label: "LiveRoom", qos: .userInitiated)
    private var audioPlayer: AVAudioPlayer?
    
    private var isPresented: Bool = false {
        didSet {
            LiveRoomStateManager.manager.isBusy = isPresented
        }
    }

    var room: Room!
    var invitationInfo: InvitationResultInfo!
    var liveTimer: Timer?
    var liveDuration: Int = 0
    
    var allParticipants: [Participant] = []
    var leadingIndex = 0 // Big Screen for participant
    var viewModel: LiveRoomViewModel!
    
    @objc public var onInvitedHandler:(() -> Void)?
    
    public init(invitationInfo: InvitationResultInfo) {
        super.init(nibName: nil, bundle: nil)
        self.invitationInfo = invitationInfo
        viewModel = LiveRoomViewModel(invitationSingling: invitationInfo)
    }
    
    public static func showIn(viewController: UIViewController, invitationInfo: InvitationResultInfo) {
        let vc = LiveRoomViewController(invitationInfo: invitationInfo)
        vc.isPresented = true
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .overCurrentContext

        UIViewController.currentViewController().present(nav, animated: true)
    }
    
    public static var isBusy: Bool {
        LiveRoomStateManager.manager.isBusy
    }
    
    public static func dismiss() {
        UIViewController.currentViewController().dismiss(animated: false)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        isPresented = false
        room.disconnect()
        liveTimer?.invalidate()
        liveTimer = nil
        UIApplication.shared.isIdleTimerDisabled = false
        NotificationCenter.default.removeObserver(self)
    }
    
    lazy var navBar: LiveNavBar = {
        let v = LiveNavBar { [weak self] action in
            guard let `self` = self else {return}
            switch action {
            case .scale:
                print("scale")
                self.suspend(coverImageName: "contact_my_friend_icon", tips: "会议中".innerLocalized())
            case .earpiece(let enable):
                print("earpiece")
                self.toggleEarpieceEnabled(enabled: enable)
            case .info:
                print("info")
                self.showRoomInfoView()
            case .end:
                print("end")
                self.end()
            }
        }
        return v
    }()
    
    // 点击某人或显示自己的视频流
    lazy var contentView: LiveContentView = {
        let v = LiveContentView()
        
        return v
    }()
    
    // 横向滚动的成员
//    lazy var participantsView: LiveParticipantsView = {
//        let v = LiveParticipantsView()
//        return v
//    }()
    
    lazy var bottomBar: LiveBottomBar = {
        let v = LiveBottomBar()
        v.onTap = { [weak self] action in
            guard let self, let setting = self.viewModel.meetingInfo else { return false}
            switch action {
            case .mute:
                // 房主允许才能开启音频
                let can = setting.audioCanEnable
                if can {
                    self.toggleMicrophoneEnabled()
                }
                return can
            case .video:
                let can = setting.videoCanEnable
                if can {
                    self.toggleScreenShareEnable(false)
                    self.toggleCameraEnabled()
                }
                return can
            case .screenShare:
                let can = setting.screenShareCanEnable
                if can {
                    if screenShareTrackState.isPublished {
                        unpublish(source: .screenShareVideo) { [self] in
                            DispatchQueue.main.async { [self] in
                                self.toggleCameraEnabled(v.videoTurnOn)
                            }
                        }
                    } else {
                        unpublish(source: .camera) { [self] in
                            DispatchQueue.main.async { [self] in
                                self.toggleScreenShareEnable()
                            }
                        }
                    }
                    contentView.reloadLeadingParticipants()
                    contentView.reloadParticipants()
                } else {
                    let alertController = UIAlertController(title: nil, message: "目前仅主持人能分享屏幕".innerLocalized() + "...", preferredStyle: .alert)
                    UIViewController.currentViewController().present(alertController, animated: true)
                }
                return can
            case .member:
                self.showMemberListView()
                return true
            case .setting:
                self.showSettingView()
                return true
            }
        }
        return v
    }()
    
    // 设置界面
    lazy var settingView: LiveSettingView = {
        
        let v = LiveSettingView() { [weak self] setting in
            // 设置结果
            ProgressHUD.animate()
            Task {
                let result = await self?.viewModel.updateMeetingInfo(info: setting)
                if result == true {
                    self?.showSettingView()
                    ProgressHUD.dismiss()
                } else {
//                    ProgressHUD.error("setupFailed".innerLocalized())
                    ProgressHUD.dismiss()
                    if let handler = OIMApi.showTipHandle {
                                    
                        handler("setupFailed".innerLocalized(), { res in
                           
                        })
                    }
                }
            }
        }
        
        v.onTap = { [weak self] in
            self?.showSettingView()
        }
        v.isHidden = true
        return v
    }()
    
    var memberListViewController: LiveMemberListViewController?
    
    // 房间信息
    lazy var roomInfoView: LiveRoomInfoView = {
        let v = LiveRoomInfoView()
        v.onTap = { [weak self] in
            UIPasteboard.general.string = self?.viewModel.meetingInfo?.roomID
        }
        v.isHidden = true
        
        let tap = UITapGestureRecognizer()
        v.addGestureRecognizer(tap)
        tap.rx.event.subscribe(onNext: { [weak self] _ in
            self?.showRoomInfoView()
        }).disposed(by: disposeBag)
        return v
    }()
    
    // 旋转按钮
    lazy var rotationButton: UIButton = {
        let v = UIButton(type: .custom)
        v.setImage(UIImage(nameInBundle: "live_room_rotation_icon"), for: .normal)
        v.addTarget(self, action: #selector(rotateScreen(_:)), for: .touchUpInside)
        
        return v
    }()
    
    @objc func rotateScreen(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        let rotation: UIInterfaceOrientationMask = sender.isSelected ? .landscapeRight : .portrait
        rotateScreen(rotation: rotation)
        
        bottomBar.isHidden = rotation == .landscapeLeft
        navBar.isHidden = rotation == .landscapeLeft
    }
    
    @objc private func didEnterBackground() {
        SleepPreventer.preventer.start()
    }
    
    @objc private func willEnterForeground() {
        SleepPreventer.preventer.stop()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.backgroundColor = .black
        UIApplication.shared.isIdleTimerDisabled = true
        definesPresentationContext = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
                
        Self.scale = { [weak self] scale in
            self?.rotateScreen(rotation: scale ? .portrait : self?.rotationButton.isSelected == true ? .landscapeRight : .portrait)
        }
        // 默认本地视频流
        let verSV = UIStackView(arrangedSubviews: [navBar, contentView, /*participantsView,*/ bottomBar])
        verSV.axis = .vertical
        view.addSubview(verSV)
        
        verSV.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        // 大屏幕部分
        contentView.numberOfItems = { [weak self] in
            guard let `self` = self, !self.allParticipants.isEmpty else { return 0 }
            return self.allParticipants.count
        }
        
//        contentView.itemSize = { [weak self] in
//            guard let `self` else { return .zero }
//            return CGSizeMake(UIScreen.main.bounds.size.width,
//                              UIScreen.main.bounds.size.height -
//                              CGRectGetHeight(self.navBar.bounds) -
//                              CGRectGetHeight(self.bottomBar.bounds)/* -
//                              CGRectGetHeight(self.participantsView.bounds)*/)
//        }
        
        contentView.participantHandler = { [weak self] index in
            guard let `self` = self else { return nil}
            let p = allParticipants[index]
            
            return (p, p.isSelf)
        }
        
        contentView.leadingParticipantHandler = { [weak self] in
            guard let self, allParticipants.count > leadingIndex else { return nil }
            let p = allParticipants[leadingIndex]
            
            return (p, p.isSelf)
        }
        
        contentView.onTap = { [weak self] (action) in
            guard let self else { return }
            
            switch action {
            case .camera:
                switchCameraPosition()
            case .doubleTap(let index):
                let obj = allParticipants[index]
                scrollToBeWatchParticipant(beWatchID: obj.identity)
            case .cell(let index):
                navBar.isHidden = !navBar.isHidden
                bottomBar.isHidden = !bottomBar.isHidden
            case .content:
                navBar.isHidden = !navBar.isHidden
                bottomBar.isHidden = !bottomBar.isHidden
            }
        }
        
        contentView.hosterName = { [weak self] in
            return self?.viewModel.meetingInfo?.hosterName
        }
        /*
        // 成员列表缩略图
        participantsView.contentView.numberOfItems = { [weak self] in
            guard let `self` = self, !self.allParticipants.isEmpty else { return 0 }
            return self.allParticipants.count
        }

        participantsView.contentView.participantHandler = { [weak self] index in
            guard let `self` = self else { return nil }
            return (self.allParticipants[index],  false)
        }

        participantsView.contentView.onTap = { [weak self] (action, index) in
            if case .cell = action {
                self?.contentView.collectionView.isPagingEnabled = false
                self?.contentView.collectionView.scrollToItem(at: .init(item: index, section: 0), at: .centeredHorizontally, animated: false)
                self?.contentView.collectionView.isPagingEnabled = true
            }
        }
        
        participantsView.contentView.showInfoView = {
            return (false, true)
        }
        */
        
        view.addSubview(rotationButton)
        rotationButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(90.h)
        }
        
        // 详情页
        view.addSubview(roomInfoView)
        roomInfoView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(UIScreen.main.bounds.height)
            make.bottom.equalToSuperview().offset(UIScreen.main.bounds.height)
        }
        // 设置页
        view.addSubview(settingView)
        settingView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(UIScreen.main.bounds.height)
            make.bottom.equalToSuperview().offset(UIScreen.main.bounds.height)
        }
        
        bindData()
        connectSever()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if #available(iOS 16.0, *) {} else {
            UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        }
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if #available(iOS 16.0, *) {} else {
            UIDevice.current.endGeneratingDeviceOrientationNotifications()
        }
    }
    
    func bindData() {
        viewModel.kickedOffline.subscribe(onNext: { [weak self] _ in
            self?.isPresented = false
            self?.dismiss()
        }).disposed(by: disposeBag)
        
        viewModel.meetingStreamChangeRelay.subscribe(onNext: { [weak self] event in
            guard let `self` = self, let event = event else { return }

            if (event.streamType == "audio") {
                self.toggleMicrophoneEnabled(!event.mute)
            } else {
                self.toggleCameraEnabled(!event.mute)
            }
        }).disposed(by: disposeBag)
    }
    
    // 刷新人
    func setParticipants() {
        var allParticipants = ([room.localParticipant] + room.remoteParticipants.map { $0.value } as [Participant?])
            .compactMap {$0}
            .filter {$0.identity != viewModel.meetingInfo?.roomID}
        // 大于两人才有这个逻辑，小于两人的时候类似音视频聊天
//        if allParticipants.count > 2 {
            let i = allParticipants.firstIndex(where: { $0.identity == viewModel.meetingInfo?.hostUserID })
            if let i = i {
                let obj = allParticipants[i]
                allParticipants.remove(at: i)
                allParticipants.insert(obj, at: 0)
            }
//        }
        
        self.allParticipants = allParticipants
        contentView.reloadParticipants()
        contentView.reloadLeadingParticipants()
        bottomBar.memberCount = self.allParticipants.count
        memberListViewController?.reloadData()
    }
    
    // 滚动到指定观看的人
    func scrollToBeWatchParticipant(beWatchID: String) {
        if let index = allParticipants.firstIndex(where: { $0.identity == beWatchID}) {
            leadingIndex = index
            DispatchQueue.main.async { [self] in
                contentView.reloadLeadingParticipants()
                // Scroll to the large screen on the first page
                contentView.collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: false)
            }
        }
    }
    
    // 展示设置页
    func showSettingView() {
        let show = settingView.isHidden
        
        // 刷新下数据
        if show {
            let JSON = JsonTool.toJson(fromObject: viewModel.meetingInfo)
            settingView.settingInfo = JsonTool.fromJson(JSON, toClass: SettingInfo.self)
        }
        settingView.isHidden = false
        settingView.snp.updateConstraints { make in
            if show {
                make.bottom.equalToSuperview()
            } else {
                make.bottom.equalToSuperview().offset(UIScreen.main.bounds.height)
            }
        }
        
        UIView.animate(withDuration: 0.3) {  [weak self] in
            self?.view.layoutIfNeeded()
        } completion: { [weak self] _ in
            if !show {
                self?.settingView.isHidden = true
            }
        }
    }
    
    // 展示成员列表页
    func showMemberListView() {
        if allParticipants.isEmpty {
            return
        }
        
        if memberListViewController == nil {
            memberListViewController = LiveMemberListViewController()
            
            memberListViewController!.onTap = { [weak self] action in
                switch action {
                case .invite:
                    self?.toInvite()
                case .muteAll(let isMuted):
                    self?.viewModel.meetingInfo?.isMuteAllMicrophone = isMuted
                    let m = MeetingInfo()
                    m.isMuteAllMicrophone = isMuted
                    Task {
                        await self?.viewModel.updateMeetingInfo(info: m)
                    }
                }
            }
            
            var tempParticipants: [Participant] = []
            
            memberListViewController!.numberOfitems = { [weak self] in
                guard let `self` = self, !self.allParticipants.isEmpty else { return 0 }
                // 将置顶的放在最上面
                tempParticipants.removeAll()
                let pinedUsers = self.viewModel.meetingInfo?.pinedUserIDList ?? []
                self.allParticipants.forEach { p in
                    if pinedUsers.contains(where: { $0 == p.identity}) {
                        tempParticipants.insert(p, at: 0)
                    } else {
                        tempParticipants.append(p)
                    }
                }
                return tempParticipants.count
            }
            
            memberListViewController!.participantForRowAt = { [weak self] index in
                guard let `self` = self, let meetingInfo = self.viewModel.meetingInfo else { fatalError() }
                let p = tempParticipants[index]
                let isPined = meetingInfo.pinedUserIDList?.contains(where: { $0 == p.identity }) ?? false
                let allSeeHim = meetingInfo.beWatchedUserIDList?.contains(where: { $0 == p.identity }) ?? false
                let showOperate = meetingInfo.hosterIsSelf
                
                return (p, isPined, showOperate, allSeeHim)
            }
            
            memberListViewController!.participantDidOperated = { [weak self] (index, operate) in
                guard let `self` = self else { return }
                let p = tempParticipants[index]
                switch operate {
                case .audio(let isMuted):
                    if p.isSelf {
                        toggleMicrophoneEnabled(!isMuted)
                    } else {
                        self.viewModel.updateUserInfo(userID: p.identity, streamType: "audio", mute: isMuted)
                    }
                case .video(let isMuted):
                    if p.isSelf {
                        toggleCameraEnabled(!isMuted)
                    } else {
                        self.viewModel.updateUserInfo(userID: p.identity, streamType: "video", mute: isMuted)
                    }
                case .more:
                    break
                case .pined(_):
                    let index = viewModel.meetingInfo?.pinedUserIDList?.firstIndex(where: { $0 == p.identity })
                    let update = MeetingInfo()
                    if index == nil {
                        update.reducePinedUserIDList = viewModel.meetingInfo?.pinedUserIDList
                        update.addPinedUserIDList = [p.identity]
                    } else {
                        update.reducePinedUserIDList = [p.identity]
                    }
                    
                    Task {
                        await self.viewModel.updateMeetingInfo(info: update)
                    }
                    self.showMemberListView()
                case .allSeeHim(_):
                    let index = viewModel.meetingInfo?.beWatchedUserIDList?.firstIndex(where: { $0 == p.identity })
                    let update = MeetingInfo()
                    if index == nil {
                        update.reduceBeWatchedUserIDList = viewModel.meetingInfo?.beWatchedUserIDList
                        update.addBeWatchedUserIDList = [p.identity]
                    } else {
                        leadingIndex = 0
                        update.reduceBeWatchedUserIDList = [p.identity]
                    }
                    
                    Task {
                        await self.viewModel.updateMeetingInfo(info: update)
                    }
                    self.showMemberListView()
                }
            }
        }
        
        if let m = viewModel.meetingInfo {
            memberListViewController!.updateButtonStatus(canInvite: m.canInvite, canMuteAll: m.hosterIsSelf)
        }
        
        let nav = UINavigationController(rootViewController: memberListViewController!)
        
        present(nav, animated: true)
    }
    
    // 展示房间信息
    func showRoomInfoView() {
        let show = roomInfoView.isHidden
        
        if show {
            guard let meetingInfo = self.viewModel.meetingInfo else { return }
            roomInfoView.nameLabel.text = meetingInfo.hosterName ?? "" + "发起的视频会议".innerLocalized()
            roomInfoView.IDLabel.text = "会议号".innerLocalized() + ":" + meetingInfo.roomID
            roomInfoView.hostLabel.text = "主持人".innerLocalized() + ":" + (meetingInfo.hosterName ?? "")
            roomInfoView.beginLabel.text = "开始时间".innerLocalized() + ":" + Date.timeString(timeInterval: TimeInterval(meetingInfo.startTime * 1000))
            roomInfoView.durationLabel.text = "会议时长".innerLocalized() + ":" + String((meetingInfo.endTime - meetingInfo.startTime) / 60 / 60) + "小时".innerLocalized()
        }
        
        roomInfoView.isHidden = false
        roomInfoView.snp.updateConstraints { make in
            if show {
                make.bottom.equalToSuperview()
            } else {
                make.bottom.equalToSuperview().offset(UIScreen.main.bounds.height)
            }
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        } completion: { _ in
            if !show {
                self.roomInfoView.isHidden = true
            }
        }
    }
    
    // 更新相关信息
    func updateGroupMetadata(metadata: String?, joing: Bool = false) {
        guard let metadata = metadata, !metadata.isEmpty else { return }
        print("房间情况: \(metadata)")
        let r = JsonTool.fromJson(metadata, toClass: SettingInfo.self)!
        DispatchQueue.main.async { [self] in
            // 导航栏
            self.navBar.nameLabel.text = r.meetingName
            // 设置界面
            self.settingView.settingInfo = r
            // 成员列表
            var canInvite = true
            if !r.hosterIsSelf {
                canInvite = !(r.onlyHostInviteUser ?? false)
            }
            
            memberListViewController?.updateButtonStatus(canInvite: canInvite, canMuteAll: r.hosterIsSelf)
            memberListViewController?.reloadData()
            
            // 有被置顶观看的，需要设置下
            if let beWatchedUserIDList = r.beWatchedUserIDList, !beWatchedUserIDList.isEmpty {
                scrollToBeWatchParticipant(beWatchID: beWatchedUserIDList.first!)
            }
            // 设置摄像头等
            self.operateHardware(r, whileJoing: joing)
            
            r.roomID = r.roomID
            viewModel.meetingInfo = r
            viewModel.getHosterInfo()
        }
    }
    
    // 操作硬件部分
    func operateHardware(_ r: SettingInfo, whileJoing: Bool = false) {
        DispatchQueue.main.async { [self] in
            
            var enableAudio = true
            var enableVideo = true
            var enableScreenShare = true
            
            // 房主是否允许开启视频/音频
            let canEnableAudio = !(r.isMuteAllMicrophone ?? false)
            let canEnableVideo = !(r.isMuteAllVideo ?? false)
            let canEnableScreenShare = !(r.onlyHostShareScreen ?? false)
            
            // 房主亦受控制 + 成员操作
            if canEnableAudio {
                // 成员
                if whileJoing {
                    enableAudio = !(r.joinDisableMicrophone ?? false)
                } else {
                    enableAudio = bottomBar.audioTurnOn
                }
            } else {
                enableAudio = false
            }
            
            if canEnableVideo {
                // 成员
                if whileJoing {
                    enableVideo = !(r.joinDisableVideo ?? false)
                } else {
                    enableVideo = bottomBar.videoTurnOn
                }
            } else {
                enableVideo = false
            }
            
            if canEnableScreenShare {
                // 成员
                if whileJoing {
                    enableScreenShare = canEnableScreenShare
                } else {
                    enableScreenShare = bottomBar.screenShareTurnOn
                }
            } else {
                enableScreenShare = false
            }

            // 如果是第一次链接 && 房主 || 成员
            if (whileJoing && r.hosterIsSelf) || !r.hosterIsSelf {
                self.toggleCameraEnabled(enableVideo)
                
                if whileJoing, !enableAudio, !enableVideo {
                    // There is a bug in 'livekit'. When entering a room, if the camera and microphone are not released, the member list will not be called back.
                    fixPublisherWhenDisableVideoAndAudio()
                } else {
                    self.toggleMicrophoneEnabled(enableAudio && r.audioCanEnable)
                }
                // 底部按钮
                self.bottomBar.updateButtonStatus(audio: enableAudio && r.audioCanEnable,
                                                  audioIsEnable: r.audioCanEnable,
                                                  video: enableVideo, 
                                                  videoIsEnable: r.videoCanEnable,
                                                  screenShare: enableScreenShare, 
                                                  screenShareIsEnable: r.screenShareCanEnable,
                                                  setting: r.hosterIsSelf)
            }
        
            // 如果目前只能看房主屏幕共享，那么要把成员的分享都关了。
            if !r.hosterIsSelf, !r.screenShareCanEnable {
                self.toggleScreenShareEnable(false)
            }
        }
    }
    
    func toInvite() {
        if onInvitedHandler != nil {
            onInvitedHandler?()
        } else {
            let vc = MyContactsViewController(types: [.friends, .groups, .recent], multipleSelected: true)
            vc.selectedContact() { [weak self] result in
                guard let self else { return }
                
                presentAlert(useRoot: false, title: "确认发送邀请吗？".innerLocalized()) {
                    result.forEach { contact in
                        if contact.type == .group {
                            IMController.shared.getConversation(sessionType: .superGroup, sourceId: contact.ID!) { [weak self] (conversation: ConversationInfo?) in
                                guard let self, let conversation else { return }
                                
                                viewModel.sendMeetingMessage(desID: contact.ID!, conversationType: .superGroup)
                            }
                        } else {
                            IMController.shared.getConversation(sessionType: .c2c, sourceId: contact.ID!) { [weak self] (conversation: ConversationInfo?) in
                                guard let self, let conversation else { return }
                                
                                viewModel.sendMeetingMessage(desID: contact.ID!, conversationType: .c2c)
                            }
                        }
                    }                
                    self.navigationController?.popViewController(animated: false)
                }
            }
            
            navigationController?.pushViewController(vc, animated: false)
        }
    }
    
    func end() {
        // 如果是会议的host，需要选择时离开会议还是结束会议
        if viewModel.meetingInfo?.hosterIsSelf == true {
            presentActionSheet(useRoot: false, action1Title: "离开会议".innerLocalized(), action1Handler: { [weak self] in
                self?.dismiss()
            }, action2Title: "结束会议".innerLocalized()) { [weak self] in
                self?.viewModel.endMeeting(onSuccess: { [weak self] r in
                    self?.dismiss()
                }, onFailure: { errCode, errMsg in
                    
                })
            }
        } else {
            presentAlert(useRoot: false, title: "确认离开该会议吗？".innerLocalized()) { [weak self] in
                self?.dismiss()
            }
        }
    }
    
    private func dismiss() {
        isPresented = false
        rotateScreen(rotation: .portrait)
        
        dismiss(animated: true)
    }
    
    private func rotateScreen(rotation: UIInterfaceOrientationMask) {
        OIMApi.rotationHandler?(rotation)
        
        if #available(iOS 16.0, *) {
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            setNeedsUpdateOfSupportedInterfaceOrientations()
            navigationController?.setNeedsUpdateOfSupportedInterfaceOrientations()
            windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: rotation)) { error in
                print(error)
                print(windowScene?.effectiveGeometry ?? "")
            }
        } else {
            let unknown = UIInterfaceOrientation.unknown.rawValue
            UIDevice.current.setValue(unknown, forKey: "orientation")
            
            if rotation == .landscapeRight {
                UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
            } else {
                UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            }
        }
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }
}

extension LiveRoomViewController: RoomDelegate {
    public func room(_ room: Room, didUpdate connectionState: ConnectionState, oldValue: ConnectionState) {
        print("connection state did update: \(connectionState)")
        DispatchQueue.main.async { [self] in
            // 房主挂断不展示提示
            if case .disconnected = connectionState, viewModel.meetingInfo?.hosterIsSelf != true {
                presentAlert(useRoot: false, title: "会议已关闭或已断开链接，确定离开吗？".innerLocalized()) { [weak self] in
                    self?.dismiss()
                }
            }
        }
    }

    public func room(_ room: Room, localParticipant: LocalParticipant, didPublish publication: LocalTrackPublication) {
        setParticipants()
        beginCount()
    }
    
    public func room(_ room: Room, didUpdate metadata: String?) {
        print("\(#function) \(metadata)")
        updateGroupMetadata(metadata: metadata)
    }

    public func room(_ room: Room, participantDidLeave participant: RemoteParticipant) {
        print("participant did leave")
        // 如果大屏是离开的这个人，需要重置下leadingIndex
        if let first = allParticipants.firstIndex(where: { $0.identity == participant.identity }), first == leadingIndex {
            leadingIndex = 0
        }
        setParticipants()
    }

    public func room(_ room: Room, participantDidJoin participant: RemoteParticipant) {
        print("participant did join")
        setParticipants()
    }

    public func room(_ room: Room, participant: RemoteParticipant, didSubscribe publication: RemoteTrackPublication, track: Track) {
        print("didSubscribe:\(participant.identity)")
        setParticipants()
    }

    public func room(_ room: Room, participant: RemoteParticipant, didUnpublish publication: RemoteTrackPublication) {
        print("didUnpublish:\(participant.identity)")
    }

    public func room(_ room: Room, participant: RemoteParticipant, didUnsubscribe publication: RemoteTrackPublication, track: Track) {
        print("didUnsubscribe:\(participant.identity)")
    }
    
    public func room(_ room: Room, didUpdate speakers: [Participant]) {
        if let p = speakers.max(by: { $0.audioLevel > $1.audioLevel }), viewModel.meetingInfo?.beWatchedUserIDList?.isEmpty == true, leadingIndex == 0 {
            scrollToBeWatchParticipant(beWatchID: p.identity)
        }
    }
    
    public func room(_ room: Room, participant: Participant, didUpdate publication: TrackPublication, muted: Bool) {
        print("\(#function) \(String(describing: participant.showName)) - \(publication.kind) status:\(!muted)")
//        setParticipants()
        
        if participant.isSelf {
            if publication.kind == .audio {
                toggleMicrophoneEnabled(!muted)
            } else {
                toggleCameraEnabled(!muted)
            }
        }
    }
}

extension LiveRoomViewController {
    // 链接服务器
    func connectSever() {
        if let url = invitationInfo.liveURL, let token = invitationInfo.token {
            let roomOptions = RoomOptions(
                defaultCameraCaptureOptions: CameraCaptureOptions(
                    dimensions: .h540_169
                ),
                defaultScreenShareCaptureOptions: ScreenShareCaptureOptions(
                    useBroadcastExtension: true),
                adaptiveStream: true,
                dynacast: true,
                suspendLocalVideoTracksInBackground: false
            )
            room = Room(delegate: self, roomOptions: roomOptions)
            ProgressHUD.animate(interaction: true)
            room.connect(url, token, roomOptions: roomOptions).then { [weak self] r in
                ProgressHUD.dismiss()
                self?.updateGroupMetadata(metadata: r.metadata, joing: true)
            }.catch { e in
                // failed to connect
                ProgressHUD.dismiss()
                print("Failed to  connet: \(e)")
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    // 链接时间
    func beginCount(fire: Bool = true) {
        DispatchQueue.main.async { [self] in
            if self.liveTimer != nil { return }
            self.liveTimer = Timer.scheduledTimer(withTimeInterval: 1,
                                             repeats: true) { [weak self] _ in
                
                guard let wself = self else { return }
                wself.liveDuration += 1
                wself.navBar.duration = wself.liveDuration
                // 更新小窗口时间
                let m = wself.liveDuration / 60
                let s = wself.liveDuration % 60
                var timeline = ""
    
                if m > 99 {
                    timeline = String(format: "%d:%02d", m, s)
                } else {
                    timeline = String(format: "%02d:%02d", m, s)
                }
                wself.updateSuspendTips(text: timeline)
            }
        }
    }
    
    // 麦克风可用
    func toggleMicrophoneEnabled(_ enable: Bool? = nil) {
        guard let localParticipant = room.localParticipant, !microphoneTrackState.isBusy else {
            return
        }
        
        self.microphoneTrackState = .busy(isPublishing: !self.microphoneTrackState.isPublished)
        let e = enable ?? !localParticipant.isMicrophoneEnabled()
        print("======麦克风状态:\(e) --- 入参:\(enable)")
        
        localParticipant.setMicrophone(enabled: e).then(on: sdk) { publication in
            DispatchQueue.main.async {
                if let publication = publication {
                    self.microphoneTrackState = .published(publication)
                    self.bottomBar.updateButtonStatus(audio: e)
                } else {
                    self.microphoneTrackState = .notPublished()
                }
            }
            print("Successfully published microphone")
        }.catch(on: sdk) { error in
            self.microphoneTrackState = .notPublished(error: error)
            print("Failed to publish microphone, error: \(error)")
        }
    }
    
    func fixPublisherWhenDisableVideoAndAudio() {
        guard let localParticipant = room.localParticipant else {
            return
        }
        
        localParticipant.setMicrophone(enabled: true).then(on: sdk) { publication in
            DispatchQueue.main.async { [self] in
                if let publication = publication {
                    self.microphoneTrackState = .published(publication)
                    
                    localParticipant.setMicrophone(enabled: false).then(on: sdk) { publication in
                        DispatchQueue.main.async {
                            if let publication = publication {
                                self.microphoneTrackState = .published(publication)
                                self.bottomBar.updateButtonStatus(audio: false)
                            } else {
                                self.microphoneTrackState = .notPublished()
                            }
                        }
                        print("Successfully published microphone")
                    }.catch(on: sdk) { error in
                        self.microphoneTrackState = .notPublished(error: error)
                        print("Failed to publish microphone, error: \(error)")
                    }
                } else {
                    self.microphoneTrackState = .notPublished()
                }
            }
            print("Successfully published microphone")
        }.catch(on: sdk) { error in
            self.microphoneTrackState = .notPublished(error: error)
            print("Failed to publish microphone, error: \(error)")
        }
    }
    
    // 旋转摄像头
    @discardableResult
    func switchCameraPosition() -> Promise<Bool> {
        guard case .published(let publication) = cameraTrackState,
              let track = publication.track as? LocalVideoTrack,
              let cameraCapturer = track.capturer as? CameraCapturer
        else {
            return Promise(TrackError.state(message: "Track or a CameraCapturer doesn't exist"))
        }
        
        return cameraCapturer.switchCameraPosition()
    }
    
    // 摄像头是否可用
    func toggleCameraEnabled(_ enable: Bool? = nil) {
        guard let localParticipant = room.localParticipant, !cameraTrackState.isBusy else {
            return
        }
        
        self.cameraTrackState = .busy(isPublishing: !self.cameraTrackState.isPublished)
        let e = enable ?? !localParticipant.isCameraEnabled()
        print("======摄像头状态:\(e) --- 入参:\(enable)")
        
        localParticipant.setCamera(enabled: e).then(on: sdk) { publication in
            DispatchQueue.main.async {
                if let publication = publication {
                    self.cameraTrackState = .published(publication)
                    self.bottomBar.updateButtonStatus(video: e, screenShare: !e)
                } else {
                    self.cameraTrackState = .notPublished()
                }
            }
        }
    }
    
    func unpublish(source: Track.Source, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async { [self] in 
            if source == .camera, cameraTrackState.isPublished {
                if case .published(let p) = cameraTrackState {
                    room.localParticipant?.unpublish(publication: p)
                    print("======localParticipant.unpublish")
                    cameraTrackState = .notPublished()
                    room.localParticipant?.setCamera(enabled: false).then(on: sdk) { _ in
                        completion?()
                    }
                }
            } else {
                completion?()
            }
            
            if source == .screenShareVideo, screenShareTrackState.isPublished {
                if case .published(let p) = screenShareTrackState {
                    room.localParticipant?.unpublish(publication: p)
                    print("======localParticipant.unpublish")
                    screenShareTrackState = .notPublished()
                    room.localParticipant?.setScreenShare(enabled: false).then(on: sdk) { _ in
                        completion?()
                    }
                }
            } else {
                completion?()
            }
        }
    }
    
    // 屏幕分享是否可用
    func toggleScreenShareEnable(_ enable: Bool? = nil)  {
        guard let localParticipant = room.localParticipant, !screenShareTrackState.isBusy else {
            return
        }
        
        self.screenShareTrackState = .busy(isPublishing: !self.screenShareTrackState.isPublished)
        let e = enable ?? !localParticipant.isScreenShareEnabled()
        print("======屏幕分享状态:\(e) --- 入参:\(enable)")
        
        localParticipant.setScreenShare(enabled: e).then(on: sdk) { publication in
            DispatchQueue.main.async {
                if let publication = publication {
                    self.screenShareTrackState = .published(publication)
                    self.bottomBar.updateButtonStatus(video: !e, screenShare: e)
                } else {
                    self.screenShareTrackState = .notPublished()
                }
            }
            print("Successfully published microphone")
        }.catch(on: sdk) { error in
            self.screenShareTrackState = .notPublished(error: error)
            print("Failed to publish microphone, error: \(error)")
        }
    }
    
    // 是否免提
    func toggleEarpieceEnabled(enabled: Bool = true) {
        print("toggleEarpieceEnabled:\(enabled)")
        do {
            let session = AVAudioSession.sharedInstance()
        
            if !enabled {
                try session.setCategory(.playAndRecord, mode: .default, options: .allowBluetooth)
                try session.overrideOutputAudioPort(.none)
            } else {
                try session.setCategory(.playAndRecord, mode: .default, options: [.allowBluetooth, .defaultToSpeaker])
                try session.overrideOutputAudioPort(.speaker)
            }
            try session.setActive(true)
        } catch let error {
            print(error.localizedDescription)
        }
    }
}

public class LiveNavigationController: UINavigationController {
    public override var shouldAutorotate: Bool {
        true
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        [.portrait, .landscapeRight]
    }
}

public class LiveRoomStateManager {
    static var manager = LiveRoomStateManager()
    
    public var isBusy: Bool = false
    public var error: Error? = nil
}

class CustomTransition: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5 // 设置动画持续时间
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toView = transitionContext.view(forKey: .to) else { return }
        
        let containerView = transitionContext.containerView
        toView.frame = containerView.bounds
        toView.transform = CGAffineTransform(translationX: 0, y: containerView.bounds.height)
        
        containerView.addSubview(toView)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            toView.transform = CGAffineTransform.identity
        }) { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
