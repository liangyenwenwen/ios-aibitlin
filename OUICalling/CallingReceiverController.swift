
import AVFoundation
import Foundation
import LiveKitClient
import Lottie
import RxSwift
import SnapKit
import OUICore
import ProgressHUD

public class CallingReceiverController: CallingBaseController {
    
    private var signal: ReceiverSignalViewController?
    private var room: ReceiverRoomViewController?
    private var isPresented: Bool = false
    // 通话时长
    public var duration: Int {
        if signal != nil {
            return signal!.linkingDuration
        } else {
            return room!.linkingDuration
        }
    }
    /**
     链接房间
     */
    public override func connectRoom(liveURL: String, token: String) {
        if signal != nil {
            signal!.connectRoom(liveURL: liveURL, token: token)
        } else {
            room?.connectRoom(liveURL: liveURL, token: token)
        }
    }
    /**
     挂断、拒绝等关闭界面
     */
    public override func dismiss() {
        isPresented = false
        signal?.dismiss()
        room?.dismiss()
    }
    
    /**
     @param isVideo 是否是音视频
     @param inviter 邀请者
     @param others 其它人
     */
    public override func startLiveChat(inviter: @escaping UserInfoHandler,
                                       others: @escaping UserInfoHandler,
                                       isVideo: Bool = true,
                                       groupID: String?) {
        if isPresented {
            return
        }
        isPresented = true
        
        if groupID == nil || groupID!.isEmpty {
            signal = ReceiverSignalViewController()
            signal!.inviter = inviter
            signal!.users = others
            signal!.isVideo = isVideo
            signal!.groupID = groupID
            signal!.onAccepted = onAccepted
            signal!.onRejected = onRejected
            signal!.onHungup = onHungup
            signal!.onDisconnect = onDisconnect
            signal!.onConnectFailure = onConnectFailure
            signal!.onAction = onAction
            
            signal!.modalPresentationStyle = .overCurrentContext
            UIViewController.currentViewController().present(signal!, animated: true)
        } else {
            room = ReceiverRoomViewController()
            room!.inviter = inviter
            room!.users = others
            room!.isVideo = isVideo
            room!.groupID = groupID
            room!.onAccepted = onAccepted
            room!.onRejected = onRejected
            room!.onHungup = onHungup
            room!.onDisconnect = onDisconnect
            room!.onConnectFailure = onConnectFailure
            room!.onCancel = onCancel
            room!.onAction = onAction
            
            room!.modalPresentationStyle = .overCurrentContext
            UIViewController.currentViewController().present(room!, animated: true)
        }
    }
    
    // 中途加入群聊
    @objc public func joinRoomWith(isVideo: Bool = true, roomID: String, liveURL: String, token: String) {
        room = ReceiverRoomViewController()
        room!.isJoinRoom = true
        room!.isVideo = isVideo
        room!.groupID = roomID
        room!.onAccepted = onAccepted
        room!.onRejected = onRejected
        room!.onHungup = onHungup
        room!.onDisconnect = onDisconnect
        room!.onConnectFailure = onConnectFailure
        
        room!.connectRoom(liveURL: liveURL, token: token)
        
        room!.modalPresentationStyle = .fullScreen
        UIViewController.currentViewController().present(room!, animated: true)
    }
}

//=====================
//=======单聊==========

class ReceiverSignalViewController: CallingBaseViewController {
    private var verStackView: UIStackView?
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        playSounds()
        room.add(delegate: self)
        setupView()
    }
    
    func setupView() {
        let inviter = inviter().first
        // 个人信息
        let avatarView = AvatarView()
        avatarView.setAvatar(url: inviter?.faceURL, text: inviter?.nickname)
        avatarView.snp.makeConstraints { make in
            make.width.height.equalTo(70)
        }
        
        let nameLabel = UILabel()
        nameLabel.layer.cornerRadius = 6
        nameLabel.layer.masksToBounds = true
        nameLabel.text = SuperStringUtil.getUserShowname(showname: inviter?.nickname ?? "")
        nameLabel.font = .systemFont(ofSize: 28)
        nameLabel.textAlignment = .center
        nameLabel.textColor = .white
        
        // 如果是音频，垂直结构
        if !isVideo {
            let infoStackView = UIStackView(arrangedSubviews: [avatarView, nameLabel, tipsLabel])
            infoStackView.axis = .vertical
            infoStackView.spacing = 24
            infoStackView.alignment = .center
            
            tipsLabel.text = "invitedVoiceCallHint".innerLocalized()
            verStackView = UIStackView(arrangedSubviews: [infoStackView, UIView()])
        } else {
            let infoStackView = UIStackView(arrangedSubviews: [nameLabel, tipsLabel])
            infoStackView.axis = .vertical
            infoStackView.distribution = .equalSpacing
            infoStackView.alignment = .leading
            
            let rowStackView = UIStackView(arrangedSubviews: [SizeBox(width: 24), avatarView, SizeBox(width: 8), infoStackView, SizeBox(width: 24)])
            rowStackView.axis = .horizontal
            rowStackView.spacing = 8
            
            tipsLabel.text = "invitedVideoCallHint".innerLocalized()
            verStackView = UIStackView(arrangedSubviews: [rowStackView, UIView()])
        }
        
        verStackView!.axis = .vertical
        verStackView!.distribution = .equalSpacing
        view.addSubview(verStackView!)
        
        verStackView!.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(minimizeButton.snp_bottom).offset(24)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        insertLinkingViewAbove(aboveView: verStackView!)
        
        if !isJoinRoom {
            previewFuncButtons()
        }
    }
}

extension ReceiverSignalViewController: RoomDelegate {
    func room(_ room: Room, didFailToConnectWithError error: LiveKitError?) {
        iLogger.print("\(#function): \(error?.message)")
        onConnectFailure?()
        dismiss()
    }
    
    func room(_ room: Room, didUpdateConnectionState connectionState: ConnectionState, from oldValue: ConnectionState) {
        iLogger.print("\(#function): \(connectionState)")
        DispatchQueue.main.async { [self] in
            if case .disconnected = connectionState {
                onDisconnect?()
            } else if case .connected = connectionState {
                publishMicrophone()
            }
        }
    }
    
    func roomIsReconnecting(_ room: Room) {
        iLogger.print("\(#function)")
        poorNetwork = true
    }
    
    func roomDidReconnect(_ room: Room) {
        iLogger.print("\(#function)")
        poorNetwork = false
    }
    
    func room(_ room: Room, participantDidConnect participant: RemoteParticipant) {
        iLogger.print("\(#function): \(participant.metadata)")
    }
    
    func room(_ room: Room, participantDidDisconnect participant: RemoteParticipant) {
        iLogger.print("\(#function): \(participant.metadata)")
        
        let identityString = participant.identityString
        
        if poorNetwork {
            ProgressHUD.text("callingInterruption".localized()) {
                DispatchQueue.main.async { [self] in
                    onAction?(.participantDidDisconnect(identityString!, linkingDuration))
                }
            }
        } else {
            DispatchQueue.main.async { [self] in
                onAction?(.participantDidDisconnect(identityString!, linkingDuration))
            }
        }
    }
    
    func room(_ room: Room, participant: Participant, didUpdateConnectionQuality quality: ConnectionQuality) {
        iLogger.print("\(#function): participant: \(participant.metadata) quality: \(quality)")
        guard room.connectionState != .disconnected else { return }
        
        if quality == .lost || quality == .poor {
            poorNetwork = true
            
            let isMine = participant.identity == room.localParticipant.identity
            
            ProgressHUD.text(isMine ? "networkNotStable".localized() : "otherNetworkNotStableHint".localized())
        } else {
            poorNetwork = false
        }
    }
    
    func room(_ room: Room, participant localParticipant: LocalParticipant, didPublishTrack publication: LocalTrackPublication) {
        iLogger.print("\(#function)")
        DispatchQueue.main.async { [self] in
            onlineFuncButtons()
            showLinkingView(show: false)
        }
        guard let track = localParticipant.firstCameraVideoTrack else {
            iLogger.print("receiver did publish track return")
            return
        }
        
        DispatchQueue.main.async { [self, track] in
            self.smallTrack = track
//            self.smallVideoView.track = track
        }
    }
    
    func room(_ room: Room, participant: RemoteParticipant, didSubscribeTrack publication: RemoteTrackPublication) {
        iLogger.print("\(#function) participant: \(participant.metadata) subscribe \(publication.name)")
        DispatchQueue.main.async { [self, participant] in
            if isVideo {
                if let track = participant.firstCameraVideoTrack {
//                    bigVideoView.track = track
                    self.bigTrack = track
                }
                verStackView?.isHidden = true
            }
            linkingTimer()
        }
    }
    
    func room(_ room: Room, participant: RemoteParticipant, didUnsubscribeTrack publication: RemoteTrackPublication) {
        iLogger.print("\(#function) participant: \(participant.metadata) subscribe \(publication.name)")
        // 收到邀请的时候， 对方的userID 在inviter上。
        if linkedTimer != nil, participant.identityString == inviter().first?.userID {
            linkedTimer = nil
            DispatchQueue.main.async { [self] in
                if !room.allParticipants.isEmpty {
//                     onBeHungup?(linkingDuration)
                }
            }
        }
    }
    
    func room(_ room: Room, participant: Participant, trackPublication publication: TrackPublication, didUpdateIsMuted muted: Bool) {
        iLogger.print("\(#function) \(String(describing: participant.showName)) 操作了 \(publication.kind == .video ? "视频" : "音频") 目前状态:\(muted ? "关闭麦克风" : "开启了麦克风")  --- \(publication.source)")
        
        if publication.kind == .video, publication.source != .microphone {
            DispatchQueue.main.async { [self] in
                let participantUser = CallingUserInfo(userID: participant.identityString, nickname: participant.showName, faceURL: participant.faceURL)

                if let user = inviter().first, participant.identityString == user.userID {
                    remoteMuted = muted
                    
                    if smallViewIsMe {
                        bigDisableVideoImageView.isHidden = !muted
                        setupBigPlaceholerView(user: participantUser)
                    } else {
                        smallDisableVideoImageView.isHidden = !muted
                        setupSmallPlaceholerView(user: participantUser)
                    }
                } else if let user = users().first, participant.identityString == user.userID {
                    localMuted = muted
                    
                    if smallViewIsMe {
                        smallDisableVideoImageView.isHidden = !muted
                        setupSmallPlaceholerView(user: participantUser)
                    } else {
                        bigDisableVideoImageView.isHidden = !muted
                        setupBigPlaceholerView(user: participantUser)
                    }
                }
            }
        }
    }
}

// =================================
// 群聊接收界面
// =================================

class UsersGridView: UIView {
    var users: UserInfoHandler!
    
    init(isVideo: Bool = true, inviter: UserInfoHandler, users: @escaping UserInfoHandler) {
        super.init(frame: .zero)
        
        self.backgroundColor = .init(red: 38 / 255, green: 38 / 255, blue: 38 / 255, alpha: 1)
        self.users = users
        let inviter = inviter().first
        
        // 邀请者信息
        let avatarView = AvatarView()
        avatarView.setAvatar(url: inviter?.faceURL, text: inviter?.nickname)
        avatarView.snp.updateConstraints { make in
            make.size.equalTo(50)
        }
        
        let tipsLabel = UILabel()
        tipsLabel.textColor = .white
        tipsLabel.text = (SuperStringUtil.getUserShowname(showname: inviter?.nickname ?? "")) + (isVideo ? "invitedVideoCallHint".innerLocalized() : "invitedVoiceCallHint".innerLocalized())
        
        let countLabel = UILabel()
        countLabel.text = "\(users().count)人正在\(isVideo ? "视频" : "语音")通话中"
        countLabel.textColor = .white
        
        let verStackView = UIStackView(arrangedSubviews: [tipsLabel, countLabel])
        verStackView.axis = .vertical
        
        let horStackView = UIStackView(arrangedSubviews: [SizeBox(width: 24), avatarView, SizeBox(width: 8), verStackView, SizeBox(width: 24)])
        horStackView.axis = .horizontal
        
        addSubview(horStackView)
        
        horStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(48)
        }
        // 邀请的人头信息
        addSubview(gridView)
        
        gridView.snp.makeConstraints { make in
            make.top.equalTo(horStackView.snp_bottom).offset(24)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var gridView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 4
        layout.itemSize = .init(width: 70, height: 80)
        
        let v = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        v.register(UICollectionViewCell.self,
                   forCellWithReuseIdentifier: "usersCell")
        
        v.delegate = self
        v.dataSource = self
        
        v.backgroundColor = .clear
        
        return v
    }()
}

extension UsersGridView: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users().count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "usersCell", for: indexPath)
        let info = users()[indexPath.row]
        // 个人信息
        let avatarView = AvatarView()
        avatarView.layer.cornerRadius = 6.0
        avatarView.clipsToBounds = true
        avatarView.setAvatar(url: info.faceURL, text: info.nickname)
        avatarView.snp.updateConstraints { make in
            make.size.equalTo(50)
        }
        
        let nameLabel = UILabel()
        nameLabel.layer.cornerRadius = 6
        nameLabel.layer.masksToBounds = true
        nameLabel.text = SuperStringUtil.getUserShowname(showname: info.nickname ?? "")
        nameLabel.textAlignment = .center
        nameLabel.textColor = .white
        nameLabel.snp.makeConstraints { make in
            make.width.equalTo(70)
        }
        
        let infoStackView = UIStackView(arrangedSubviews: [avatarView, nameLabel])
        infoStackView.axis = .vertical
        infoStackView.spacing = 8
        infoStackView.distribution = .equalSpacing
        infoStackView.alignment = .center
        
        cell.contentView.addSubview(infoStackView)
        
        infoStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        return cell
    }
}

extension UsersGridView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView.numberOfItems(inSection: section) == 1 {
            let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
            
            return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: collectionView.frame.width - flowLayout.itemSize.width - 16)
        }
        
        return UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
    }
}

class ReceiverRoomViewController: CallingBaseViewController {
    private lazy var collectionView: UICollectionView = {
        print("creating UICollectionView...")
        let r = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        r.register(ParticipantCell.self, forCellWithReuseIdentifier: ParticipantCell.reuseIdentifier)
        r.delegate = self
        r.dataSource = self
        r.alwaysBounceVertical = true
        r.contentInsetAdjustmentBehavior = .never
        return r
    }()
    
    lazy var usersGridView: UsersGridView = {
        let v = UsersGridView(isVideo: isVideo, inviter: inviter, users: users)
        return v
    }()
    
    private var remoteParticipants = [RemoteParticipant]()
    
    private var cellReference = NSHashTable<ParticipantCell>.weakObjects()
    private var timer: Timer?
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { [weak self] _ in
            guard let self = self else { return }
            self.reComputeVideoViewEnabled()
        })
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        timer?.invalidate()
        timer = nil
    }
    
    override func loadView() {
        super.loadView()
        view.addSubview(collectionView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !isJoinRoom {
            previewView()
            playSounds()
        }
        
        collectionView.backgroundColor = .clear
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(minimizeButton.snp_bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        room.add(delegate: self)
    }
    
    // 人头像列表
    private func previewView() {
        // 邀请的所有人
        view.addSubview(usersGridView)
        
        usersGridView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(minimizeButton.snp_bottom).offset(8)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        previewFuncButtons()
//        onlineTopFuncButtons()
    }
    
    private func setParticipants() {
        DispatchQueue.main.async { [self] in
            remoteParticipants = self.room.remoteParticipants.values.filter { $0.identityString != self.groupID }
            collectionView.reloadData()
        }
    }
    
    override func onTapAccepted() {
        DispatchQueue.main.async { [self] in
            usersGridView.removeFromSuperview()
        }
    }
}

extension ReceiverRoomViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        print("sizeForItemAt...")
        
        let columns: CGFloat = 2
        let size = (collectionView.bounds.width - 8.0) / columns
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        4.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        4.0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("didSelectItemAt: \(indexPath)")
        collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
    }
    
    func reComputeVideoViewEnabled() {
        let visibleCells = collectionView.visibleCells.compactMap { $0 as? ParticipantCell }
        let offScreenCells = cellReference.allObjects.filter { !visibleCells.contains($0) }
        
        for cell in visibleCells.filter({ !$0.videoView.isEnabled }) {
            print("setting cell#\(cell.cellId) to true")
            cell.videoView.isEnabled = true
        }
        
        for cell in offScreenCells.filter({ $0.videoView.isEnabled }) {
            print("setting cell#\(cell.cellId) to false")
            cell.videoView.isEnabled = false
        }
    }
}

extension ReceiverRoomViewController: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // total number of participants to show (including local participant)
        print("numberOfItemsInSection...")
        return remoteParticipants.count + 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ParticipantCell.reuseIdentifier,
                                                      for: indexPath)
        
        if let cell = cell as? ParticipantCell {
            cellReference.add(cell)
            
            cell.disableCameraImageView.isHidden = isVideo
//            cell.topInfoView.isHidden = true
            
            if indexPath.row == 0 {
                cell.participant = room.localParticipant
            } else {
                let participant = remoteParticipants[indexPath.row - 1]
                cell.participant = participant
            }
        }
        
        return cell
    }
}

extension ReceiverRoomViewController: RoomDelegate {
    func room(_ room: Room, didFailToConnectWithError error: LiveKitError?) {
        onConnectFailure?()
        dismiss()
    }
    
    func room(_ room: Room, didUpdateConnectionState connectionState: ConnectionState, from oldValue: ConnectionState) {
        print("\(#function)")
        DispatchQueue.main.async { [self] in
            if case .disconnected = connectionState {
                remoteParticipants = []
                collectionView.reloadData()
                
                onDisconnect?()
            }
        }
    }
    
    public func room(_ room: Room, participant localParticipant: LocalParticipant, didPublishTrack publication: LocalTrackPublication) {
        print("\(#function)")
        DispatchQueue.main.async { [self] in
            collectionView.reloadData()
            linkingTimer()
        }
    }
    
    public func room(_ room: Room, participantDidDisconnect participant: RemoteParticipant) {
        iLogger.print("\(#function): \(participant.metadata)")
        setParticipants()
        
        let identityString = participant.identityString
        
        DispatchQueue.main.async { [self] in
            onAction?(.participantDidDisconnect(identityString!, linkingDuration))
        }
    }
    
    public func room(_ room: Room, participantDidConnect participant: RemoteParticipant) {
        iLogger.print("\(#function): \(participant.metadata)")
        setParticipants()
        
        let identityString = participant.identityString
        
        DispatchQueue.main.async { [self] in
            onAction?(.participantDidConnect(identityString!))
        }
    }
    
    func room(_ room: Room, participant: RemoteParticipant, didSubscribeTrack publication: RemoteTrackPublication) {
        print("\(#function):\(participant.identity)")
        setParticipants()
    }
    
    func room(_ room: Room, participant: RemoteParticipant, didUnpublishTrack publication: RemoteTrackPublication) {
        print("\(#function):\(participant.identity)")
    }
    
    func room(_ room: Room, participant: RemoteParticipant, didUnsubscribeTrack publication: RemoteTrackPublication) {
        print("\(#function):\(participant.identity)")
    }
}

