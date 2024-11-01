
import OUICore
import OUICoreView
import SnapKit
import LiveKitClient
import AVFAudio
import OUICalling
import RxSwift
import ProgressHUD
import SwiftProtobuf

public class LiveRoomViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    
    internal let sdk = DispatchQueue(label: "LiveRoom", qos: .userInitiated)
    private var audioPlayer: AVAudioPlayer?
    
    private var isPresented: Bool = false {
        didSet {
            LiveRoomStateManager.manager.isBusy = isPresented
        }
    }

    var room: Room!
    var invitationInfo: LiveKit!
    var liveTimer: Timer?
    var liveDuration: Int = 0
    
    var allParticipants: [Participant] = []
    var leadingIndex = 0 // Big Screen for participant
    var viewModel: LiveRoomViewModel!
    
    @objc public var onInvitedHandler:(() -> Void)?
    
    var onClose: (() -> Void)?
    
    init(invitationInfo: LiveKit) {
        super.init(nibName: nil, bundle: nil)
        self.invitationInfo = invitationInfo
        viewModel = LiveRoomViewModel(invitationSingling: invitationInfo)
        LiveRoomStateManager.manager.currentRoom = self
    }
    
    init(url: String, token: String) {
        super.init(nibName: nil, bundle: nil)
        var livekit = LiveKit()
        livekit.url = url
        livekit.token = token
        
        self.invitationInfo = livekit
        viewModel = LiveRoomViewModel(invitationSingling: invitationInfo)
        LiveRoomStateManager.manager.currentRoom = self
    }
    
    static func showIn(viewController: UIViewController, invitationInfo: LiveKit, onClose: (() -> Void)? = nil) {
        let vc = LiveRoomViewController(invitationInfo: invitationInfo)
        vc.isPresented = true
        vc.onClose = onClose
        LiveRoomStateManager.manager.currentRoom = vc
        
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .overCurrentContext

        UIViewController.currentViewController().present(nav, animated: true)
    }
    
    public static func showIn(viewController: UIViewController, url: String, token: String, onClose: (() -> Void)? = nil) {
        
        var livekit = LiveKit()
        livekit.url = url
        livekit.token = token
        
        let vc = LiveRoomViewController(invitationInfo: livekit)
        vc.isPresented = true
        vc.onClose = onClose
        LiveRoomStateManager.manager.currentRoom = vc
        
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .overCurrentContext

        UIViewController.currentViewController().present(nav, animated: true)
    }
    
    public static var isBusy: Bool {
        LiveRoomStateManager.manager.isBusy
    }
    
    public static func forceDismiss() {
        if LiveRoomStateManager.manager.currentRoom?.viewModel.meetingInfo?.hosterIsSelf == true {
            LiveRoomStateManager.manager.currentRoom?.viewModel.endMeeting(onSuccess: { _ in
                
            }, onFailure: { errCode, errMsg in
                
            })
        } else {
            LiveRoomStateManager.manager.currentRoom?.viewModel.leaveMeeting(onSuccess: { _ in
                
            }, onFailure: { errCode, errMsg in
                
            })
        }
        LiveRoomStateManager.manager.currentRoom?.dismiss()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        isPresented = false
        
        if let room {
            Task {
                await room.disconnect()
            }
        }
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
                    if room.localParticipant.firstScreenShareVideoTrack != nil {
                        unpublish(source: .screenShareVideo) { [self] in
                            DispatchQueue.main.async { [self] in
                                self.toggleCameraEnabled(v.videoTurnOn)
                            }
                        }
                    } else {
                        DispatchQueue.main.async { [self] in
                            self.toggleScreenShareEnable()
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
        
        let v = LiveSettingView()
        v.onCompletion = { [weak self] setting in
            // 设置结果
            ProgressHUD.animate()
            Task {
                let result = await self?.viewModel.updateMeetingInfo(info: setting)
                if result == true {
                    self?.showSettingView()
                    await MainActor.run {
                        ProgressHUD.dismiss()
                    }
                } else {
                    await MainActor.run {
                        ProgressHUD.error("setupFailed".innerLocalized())
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
            UIPasteboard.general.string = self?.viewModel.meetingInfo?.meetingID
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
            guard let self else { return nil}
            let p = allParticipants[index]
            
            return (p, p.isSelf, p.identityString == viewModel.meetingInfo?.hostUserID)
        }
        
        contentView.leadingParticipantHandler = { [weak self] in
            guard let self, allParticipants.count > leadingIndex else { return nil }
            let p = allParticipants[leadingIndex]
            
            return (p, p.isSelf, p.identityString == viewModel.meetingInfo?.hostUserID)
        }
        
        contentView.onTap = { [weak self] (action) in
            guard let self else { return }
            
            switch action {
            case .camera:
                Task {
                    await self.switchCameraPosition()
                }
            case .doubleTap(let index):
                let obj = allParticipants[index]
                
                if let identiry = obj.identityString {
                    scrollToBeWatchParticipant(beWatchID: identiry)
                }
            case .cell(let index):
                navBar.isHidden = !navBar.isHidden
                bottomBar.isHidden = !bottomBar.isHidden
            case .content:
                navBar.isHidden = !navBar.isHidden
                bottomBar.isHidden = !bottomBar.isHidden
            }
        }
        
        contentView.hosterName = { [weak self] in
            return self?.viewModel.meetingInfo?.creatorNickname
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
        ProgressHUD.dismiss()
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
        
//        viewModel.meetingStreamChangeRelay.subscribe(onNext: { [weak self] event in
//            guard let `self` = self, let event = event else { return }
//
//            if (event.streamType == "audio") {
//                self.toggleMicrophoneEnabled(!event.mute)
//            } else {
//                self.toggleCameraEnabled(!event.mute)
//            }
//        }).disposed(by: disposeBag)
    }
    
    // 刷新人
    func setParticipants() {
        var allParticipants = ([room.localParticipant] + room.remoteParticipants.map { $0.value } as [Participant?])
            .compactMap {$0}
            .filter {$0.identityString != viewModel.meetingInfo?.meetingID}
        // 大于两人才有这个逻辑，小于两人的时候类似音视频聊天
//        if allParticipants.count > 2 {
            let i = allParticipants.firstIndex(where: { $0.identityString == viewModel.meetingInfo?.hostUserID })
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
        if let index = allParticipants.firstIndex(where: { $0.identityString == beWatchID}) {
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
            settingView.settingInfo = viewModel.meetingInfo?.setting
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
                guard let self else { return }
                
                switch action {
                case .invite:
                    toInvite()
                case .muteAll(let isMuted):
                    Task {
                        let result = await self.viewModel.operateAllStream(microphoneOnEntry: !isMuted)
                        
                        if !result {
                            ProgressHUD.error("setupFailed".innerLocalized())
                        }
                    }
                }
            }
                        
            memberListViewController!.numberOfitems = { [weak self] in
                guard let `self` = self, !self.allParticipants.isEmpty else { return 0 }
      
                return allParticipants.count
            }
            
            memberListViewController!.participantForRowAt = { [weak self] index in
                guard let `self` = self, let meetingInfo = self.viewModel.meetingInfo else { fatalError() }
                let p = allParticipants[index]
                let isPined = false
                let allSeeHim = false
                let showOperate = meetingInfo.hosterIsSelf
                
                return (p, isPined, showOperate, allSeeHim)
            }
            
            memberListViewController!.participantDidOperated = { [weak self] (index, operate) in
                guard let `self` = self else { return }
                let p = allParticipants[index]
                switch operate {
                case .audio(let isMuted):
                    if p.isSelf {
                        toggleMicrophoneEnabled(!isMuted)
                    } else {
                        guard let identiry = p.identityString else { return }
                        
                        self.viewModel.updateUserInfo(userID: identiry, streamType: "audio", mute: isMuted)
                    }
                case .video(let isMuted):
                    if p.isSelf {
                        Task {
                            await self.toggleCameraEnabled(!isMuted)
                        }
                    } else {
                        guard let identiry = p.identityString else { return }
                        
                        self.viewModel.updateUserInfo(userID: identiry, streamType: "video", mute: isMuted)
                    }
                case .more:
                    break
                case .pined(_):
                    break
                case .allSeeHim(_):
                    break
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
            roomInfoView.nameLabel.text = "meetingInitiatorIs".innerLocalizedFormat(arguments: meetingInfo.creatorNickname)
            roomInfoView.IDLabel.text = "meetingNoIs".innerLocalizedFormat(arguments: meetingInfo.meetingID)
            roomInfoView.hostLabel.text = "meetingHostIs".innerLocalizedFormat(arguments: meetingInfo.creatorNickname)
            roomInfoView.beginLabel.text = "meetingStartTimeIs".innerLocalizedFormat(arguments: Date.timeString(timeInterval: TimeInterval(meetingInfo.scheduledTime)))
            roomInfoView.durationLabel.text = "meetingDurationIs".innerLocalizedFormat(arguments: Date.formatTime(seconds: Int(meetingInfo.duration)))
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
        guard let r = try? MeetingMetadata(jsonString: metadata).detail else { return }
        
        DispatchQueue.main.async { [self] in
            // 导航栏
            self.navBar.nameLabel.text = r.meetingName
            // 设置界面
            self.settingView.settingInfo = r.setting
            // 成员列表
            var canInvite = true
//            if !r.hosterIsSelf {
//                canInvite = !(r.onlyHostInviteUser ?? false)
//            }
            
            memberListViewController?.updateButtonStatus(canInvite: canInvite, canMuteAll: r.hosterIsSelf)
            memberListViewController?.reloadData()
            
            // 有被置顶观看的，需要设置下
//            if let beWatchedUserIDList = r.beWatchedUserIDList, !beWatchedUserIDList.isEmpty {
//                scrollToBeWatchParticipant(beWatchID: beWatchedUserIDList.first!)
//            }
            // 设置摄像头等
            self.operateHardware(r, whileJoing: joing)
            
//            r.roomID = r.roomID
            viewModel.meetingInfo = r
            viewModel.getHosterInfo()
        }
    }
    
    // 操作硬件部分
    func operateHardware(_ r: MeetingInfoSetting, whileJoing: Bool = false) {
        DispatchQueue.main.async { [self] in
            
            var enableAudio = true
            var enableVideo = true
            var enableScreenShare = true
            
            // 房主是否允许开启视频/音频
            let canEnableAudio = false //!(r.isMuteAllMicrophone ?? false)
            let canEnableVideo = false //!(r.isMuteAllVideo ?? false)
            let canEnableScreenShare = r.screenShareCanEnable
            
            // 房主亦受控制 + 成员操作
            if canEnableAudio {
                // 成员
                if whileJoing {
                    enableAudio = r.enableAudioWhileJoining
                } else {
                    enableAudio = bottomBar.audioTurnOn
                }
            } else {
                enableAudio = false
            }
            
            if canEnableVideo {
                // 成员
                if whileJoing {
                    enableVideo = r.enableVideoWhileJoining
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
            vc.selectedContact() { [weak self, weak vc] result in
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
                    vc?.dismiss(animated: true)
                }
            }
            
            let nav = UINavigationController(rootViewController: vc)
            UIViewController.currentViewController().present(nav, animated: false)
        }
    }
    
    func end() {
        // 如果是会议的host，需要选择时离开会议还是结束会议
        if viewModel.meetingInfo?.hosterIsSelf == true {
            presentActionSheet(useRoot: false, action1Title: "leaveMeeting".innerLocalized(), action1Handler: { [weak self] in
                self?.viewModel.leaveMeeting(onSuccess: { [self] r in
                    self?.dismiss()
                }, onFailure: { errCode, errMsg in
                    
                })
            }, action2Title: "endMeeting".innerLocalized()) { [weak self] in
                self?.viewModel.endMeeting(onSuccess: { [self] r in
                    self?.dismiss()
                }, onFailure: { errCode, errMsg in
                    
                })
            }
        } else {
            presentAlert(useRoot: false, title: "leaveMeetingConfirmHint".innerLocalized()) { [weak self] in
                self?.dismiss()
            }
        }
    }
    
    private func dismiss() {
        isPresented = false
        rotateScreen(rotation: .portrait)
        removeMiniWindow()
        onClose?()
        
        dismiss(animated: true)
        LiveRoomStateManager.manager.currentRoom = nil
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

    public func room(_ room: Room, didDisconnectWithError error: Error?) {
        print("\(#function) - \(error)")
        DispatchQueue.main.async { [self] in
            self.presentAlert(useRoot: false, title: "meetingClosedHint".innerLocalized(), cancelTitle: nil) { [weak self] in
                self?.dismiss()
            }
        }
    }
    
    public func room(_ room: Room, didUpdateConnectionState connectionState: ConnectionState, from oldValue: ConnectionState) {
        print("connection state did update: \(connectionState)")
        DispatchQueue.main.async { [self] in
            if connectionState == .connecting || connectionState == .reconnecting {
                navBar.endButton.isEnabled = false
            } else {
                navBar.endButton.isEnabled = true
            }
            
            // 房主挂断不展示提示
            if case .disconnected = connectionState, viewModel.meetingInfo?.hosterIsSelf != true {
                presentAlert(useRoot: false, title: "meetingClosedHint".innerLocalized()) { [weak self] in
                    self?.dismiss()
                }
            }
        }
    }

    public func room(_ room: Room, participant localParticipant: LocalParticipant, didPublishTrack publication: LocalTrackPublication) {
        setParticipants()
        beginCount()
    }
    
    public func room(_ room: Room, didUpdateMetadata metadata: String?) {
        print("\(#function) \(metadata)")
        updateGroupMetadata(metadata: metadata)
    }

    public func room(_ room: Room, participantDidDisconnect participant: RemoteParticipant) {
        print("participant did leave")
        // 如果大屏是离开的这个人，需要重置下leadingIndex
        if let first = allParticipants.firstIndex(where: { $0.identity == participant.identity }), first == leadingIndex {
            leadingIndex = 0
        }
        setParticipants()
    }

    public func room(_ room: Room, participantDidConnect participant: RemoteParticipant) {
        print("\(#function)")
        setParticipants()
    }

    public func room(_ room: Room, participant: RemoteParticipant, didSubscribeTrack publication: RemoteTrackPublication) {
        print("\(#function):\(participant.identity)")
        setParticipants()
    }

    public func room(_ room: Room, participant: RemoteParticipant, didUnpublishTrack publication: RemoteTrackPublication) {
        print("\(#function):\(participant.identity)")
    }

    public func room(_ room: Room, participant: RemoteParticipant, didUnsubscribeTrack publication: RemoteTrackPublication) {
        print("\(#function):\(participant.identity)")
    }
    
    public func room(_ room: Room, didUpdateSpeakingParticipants speakers: [Participant]) {
        if let p = speakers.max(by: { $0.audioLevel > $1.audioLevel }), /*viewModel.meetingInfo?.beWatchedUserIDList?.isEmpty == true,*/ leadingIndex == 0, let identity = p.identityString {
            scrollToBeWatchParticipant(beWatchID: identity)
        }
    }
    
    public func room(_ room: Room, participant: Participant, trackPublication publication: TrackPublication, didUpdateIsMuted muted: Bool) {
        print("\(#function) \(String(describing: participant.showName)) - \(publication.kind) status:\(!muted)")
//        setParticipants()
        if participant.isSelf {
            if publication.kind == .audio {
                toggleMicrophoneEnabled(!muted)
            } else {
                Task {
                  await toggleCameraEnabled(!muted)
                }
            }
        }
    }
    
    public func room(_ room: Room, participant: RemoteParticipant?, didReceiveData data: Data, forTopic topic: String) {
        do {
            let result = try NotifyMeetingData(serializedBytes: data)
            
            let localIdentity = room.localParticipant.identityString
            
            guard result.kickOffMeetingData.userID != localIdentity else {
                dismiss()
                
                return
            }
            
            let streamOperateData = result.streamOperateData
            
            if streamOperateData.operation.isEmpty || result.operatorUserID == localIdentity {
                return
            }
            
            guard let operateUser = streamOperateData.operation.first(where: ({ $0.userID == localIdentity })) else { return }
            
            if operateUser.hasCameraOnEntry {
                let cameraOnEntry = operateUser.cameraOnEntry
                
                if (cameraOnEntry) {
                    DispatchQueue.main.async { [self] in
                        presentAlert(useRoot: false, title: "requestXDoHint".innerLocalizedFormat(arguments: "meetingOpenVideo".innerLocalized()),
                                     cancelTitle: "keepClose".innerLocalized()) {
                            Task {
                                try await room.localParticipant.setCamera(enabled: cameraOnEntry)
                            }
                        }
                    }
                } else {
                    Task {
                        try await room.localParticipant.setCamera(enabled: cameraOnEntry)
                    }
                }
            }
            
            if operateUser.hasMicrophoneOnEntry {
                  let microphoneOnEntry = operateUser.microphoneOnEntry

                  if (microphoneOnEntry) {
                      DispatchQueue.main.async { [self] in
                          presentAlert(useRoot: false, title: "requestXDoHint".innerLocalizedFormat(arguments: "meetingUnmute".innerLocalized()),
                                       cancelTitle: "keepClose".innerLocalized()) {
                              Task {
                                  try await room.localParticipant.setMicrophone(enabled: microphoneOnEntry)
                              }
                          }
                      }
                  } else {
                      Task {
                          try await room.localParticipant.setMicrophone(enabled: microphoneOnEntry)
                      }
                  }
                }
                    
        } catch {
            print("\(#function): throw an error: \(error.localizedDescription)")
        }
    }
}

extension LiveRoomViewController {
    // 链接服务器
    func connectSever() {
        let url = invitationInfo.url
        let token = invitationInfo.token
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
        do {
            Task {
                try await room.connect(url: url, token: token, roomOptions: roomOptions)
                updateGroupMetadata(metadata: room.metadata, joing: true)
                ProgressHUD.dismiss()
            }
        } catch (let error) {
            ProgressHUD.dismiss()
            print("\(#function): \(error)")
            navigationController?.popViewController(animated: true)
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
        Task {
            do {
                let e = enable ?? !room.localParticipant.isMicrophoneEnabled()
                
                if let publication = try await room.localParticipant.setMicrophone(enabled: e) {
                    bottomBar.updateButtonStatus(audio: e)
                } else {
                    
                }
            } catch (let error) {
                print("\(#function) throw an error: \(error)")
            }
        }
    }
    
    func fixPublisherWhenDisableVideoAndAudio() {
        Task {
            do {
                guard let publication = try await room.localParticipant.setMicrophone(enabled: true) else { return }
                
                if let publication = try await room.localParticipant.setMicrophone(enabled: false) {
                   bottomBar.updateButtonStatus(audio: false)
                }
            } catch (let error) {
                print("\(#function) throw an error: \(error)")
            }
        }
    }
    
    // 旋转摄像头
    @discardableResult
    func switchCameraPosition() async -> Bool {
        
        guard let track = room.localParticipant.firstCameraPublication?.track as? LocalVideoTrack,
              let cameraCapturer = track.capturer as? CameraCapturer,
              (try? await CameraCapturer.canSwitchPosition()) == true
        else {
            print("Track or a CameraCapturer doesn't exist")
            return false
        }
        
        do {
            return try await cameraCapturer.switchCameraPosition()
        } catch (let error) {
            print("\(#function) throw an error: \(error)")
            return false
        }
    }
    
    // 摄像头是否可用
    func toggleCameraEnabled(_ enable: Bool? = nil) {
        Task {
            do {
                let e = enable ?? !room.localParticipant.isCameraEnabled()
                
                if let publication = try await room.localParticipant.setCamera(enabled: e) {
                    bottomBar.updateButtonStatus(video: e, screenShare: !e)
                }
            } catch (let error) {
                
            }
        }
    }
    
    func unpublish(source: Track.Source, completion: (() -> Void)? = nil) {
            guard let publication = room.localParticipant.trackPublications.first(where: { $0.value.source == source })?.value as? LocalTrackPublication else { return }
            
            do {
                Task {
                    try await room.localParticipant.unpublish(publication: publication)
                    
                    if source == .camera {
                        try await room.localParticipant.setCamera(enabled: false)
                        
                        completion?()
                    } else {
                        try await room.localParticipant.setScreenShare(enabled: false)
                        
                        completion?()
                    }
                }
            } catch (let error) {
                print("\(#function) throw an error:\(error)")
                completion?()
            }
    }
    
    // 屏幕分享是否可用
    func toggleScreenShareEnable(_ enable: Bool? = nil)  {
        do {
            Task {
                let e = enable ?? !room.localParticipant.isScreenShareEnabled()
                if e {
                    await try room.localParticipant.setCamera(enabled: false)
                }
                if let publication = try await room.localParticipant.setScreenShare(enabled: e) {
                    bottomBar.updateButtonStatus(video: !e, screenShare: e)
                }
            }
        } catch (let error) {
            print("\(#function) throw an error:\(error)")
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
                try session.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
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
    public var currentRoom: LiveRoomViewController?
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
