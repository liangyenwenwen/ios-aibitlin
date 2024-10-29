
import AVFoundation
import Foundation
import LiveKitClient
import RxSwift
import SnapKit
import ProgressHUD
import OUICore

public class CallingSenderController: CallingBaseController {
    
    private var signal: SignalViewController?
    private var room: RoomViewController?
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
            signal?.connectRoom(liveURL: liveURL, token: token)
        } else {
            ProgressHUD.animate(interaction: true)
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
    
    public func reloadUsers() {
        room?.reloadUsers()
    }
    
    /**
     @param isVideo 是否是音视频
     @param inviter 邀请者
     @param others 其它人
     */
    public override func startLiveChat(inviter: @escaping UserInfoHandler,
                                       others: @escaping UserInfoHandler,
                                       isVideo: Bool = true,
                                       groupID: String?)
    {
        if isPresented {
            return
        }
        isPresented = true
        
        if groupID == nil || groupID!.isEmpty {
            signal = SignalViewController()
            signal!.inviter = inviter
            signal!.users = others
            signal!.isVideo = isVideo
            signal!.groupID = groupID
            signal!.onCancel = onCancel
            signal!.onHungup = onHungup
            signal!.onDisconnect = onDisconnect
            signal!.onConnectFailure = onConnectFailure
            signal!.onInvitedOthers = onInvitedOthers
            signal!.onAction = onAction
            
            signal!.modalPresentationStyle = .overCurrentContext
            UIViewController.currentViewController().present(signal!, animated: true)
        } else {
            room = RoomViewController()
            room!.inviter = inviter
            room!.users = others
            room!.isVideo = isVideo
            room!.groupID = groupID
            room!.onCancel = onCancel
            room!.onHungup = onHungup
            room!.onDisconnect = onDisconnect
            room!.onConnectFailure = onConnectFailure
            room!.onInvitedOthers = onInvitedOthers
            room!.onAction = onAction
            
            room!.modalPresentationStyle = .overCurrentContext
            UIViewController.currentViewController().present(room!, animated: true)
        }
    }
}

// 单聊
class SignalViewController: CallingBaseViewController {
    private var verStackView: UIStackView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playSounds()
        setupView()
        room.add(delegate: self)
    }
    
    func setupView() {
        tipsLabel.text = "waitingVoiceCallHint".innerLocalized()
        let inviter = users().first
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
            
            verStackView = UIStackView(arrangedSubviews: [infoStackView, UIView()])
        } else {
            let infoStackView = UIStackView(arrangedSubviews: [nameLabel, tipsLabel])
            infoStackView.axis = .vertical
            infoStackView.distribution = .equalSpacing
            infoStackView.alignment = .leading
            
            let rowStackView = UIStackView(arrangedSubviews: [SizeBox(width: 24), avatarView, infoStackView, SizeBox(width: 24)])
            rowStackView.axis = .horizontal
            rowStackView.spacing = 8
            
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
        senderPreviewFuncButtons()
    }
}

extension SignalViewController: RoomDelegate {
    func room(_ room: Room, didFailToConnectWithError error: LiveKitError?) {
        onConnectFailure?()
        dismiss()
    }
    
    func room(_ room: Room, didUpdateConnectionState connectionState: ConnectionState, from oldValue: ConnectionState) {
        print("connection state did update")
        DispatchQueue.main.async { [self] in
            if case .disconnected = connectionState {
 
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
        guard let track = localParticipant.firstCameraVideoTrack else {
            print("sender did publish track return")
            return
        }
        
        DispatchQueue.main.async { [self, track] in
//            self.smallVideoView.track = track
            smallTrack = track
        }
    }
    
    func room(_ room: Room, participant: RemoteParticipant, didSubscribeTrack publication: RemoteTrackPublication) {
        print("\(#function)")
        DispatchQueue.main.async { [self, participant] in
            if isVideo {
                if let track = participant.firstCameraVideoTrack {
//                    bigVideoView.track = track
                    bigTrack = track
                }
                verStackView?.isHidden = true
                onlineFuncButtons()
            }
            linkingTimer()
            showLinkingView(show: false)
        }
    }
    
    func room(_ room: Room, participant: RemoteParticipant, didUnsubscribeTrack publication: RemoteTrackPublication) {
        print("\(#function)")
        if linkedTimer != nil, participant.identity?.stringValue == users().last?.userID {
            linkedTimer = nil
            DispatchQueue.main.async { [self] in
//                if !room.allParticipants.isEmpty {
//                     onBeHungup?(linkingDuration)
//                }
            }
        }
    }
    
    func room(_ room: Room, participant: Participant, trackPublication publication: TrackPublication, didUpdateIsMuted muted: Bool) {
        print("\(#function) \(String(describing: participant.showName)) 操作了 \(publication.kind == .video ? "视频" : "音频") 目前状态:\(muted ? "关闭麦克风" : "开启了麦克风")  --- \(publication.source)")
        
        if publication.kind == .video, publication.source != .microphone {

            DispatchQueue.main.async { [self] in
                let participantUser = CallingUserInfo(userID: participant.identity?.stringValue, nickname: participant.showName, faceURL: participant.faceURL)
                
                if let user = users().first, participant.identity?.stringValue == user.userID {
                    remoteMuted = muted
                    
                    if smallViewIsMe {
                        bigDisableVideoImageView.isHidden = !muted
                        setupBigPlaceholerView(user: participantUser)
                    } else {
                        smallDisableVideoImageView.isHidden = !muted
                        setupSmallPlaceholerView(user: participantUser)
                    }
                } else if let user = inviter().first, participant.identity?.stringValue == user.userID {
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

// ===========群聊房间=============
// ===============================

private class CustomFlowLayout: UICollectionViewFlowLayout {

    // 保存所有item的attributes
    private var attributesArr: [UICollectionViewLayoutAttributes] = []

    private var numberOfSectoins = 0
    private var numberOfItemsInSection = 0

    init(numberOfSectoins: Int = 0, numberOfItemsInSection: Int = 0) {
        super.init()
        self.numberOfSectoins = numberOfSectoins
        self.numberOfItemsInSection = numberOfItemsInSection
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let screenWidth = UIScreen.main.bounds.width
    // 保存所有item
    
    // MARK:- 重新布局
    override func prepare() {
        super.prepare()
        
        guard let collectionView else { return }
        attributesArr.removeAll()
        
        let itemWidth: CGFloat = screenWidth / CGFloat(numberOfItemsInSection)
        
        itemSize = CGSize(width: itemWidth, height: itemWidth)
        minimumLineSpacing = 0
        minimumInteritemSpacing = 0
        scrollDirection = .horizontal
        
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = true
        let insertMargin = (collectionView.bounds.height - 3 * itemWidth) * 0.5
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        let itemsCount = collectionView.numberOfItems(inSection: 0) ?? 0
        for itemIndex in 0..<itemsCount {
            let indexPath = IndexPath(item: itemIndex, section: 0)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            
            let page = itemIndex / (numberOfItemsInSection * numberOfSectoins)
            let x = itemSize.width * CGFloat(itemIndex % Int(numberOfItemsInSection)) + (CGFloat(page) * screenWidth)
            let y = itemSize.height * CGFloat((itemIndex - page * numberOfSectoins * numberOfItemsInSection) / numberOfItemsInSection)
            attributes.frame = CGRect(x: x, y: y, width: itemSize.width, height: itemSize.height)

            attributesArr.append(attributes)
        }
        
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var rectAttributes: [UICollectionViewLayoutAttributes] = []
        _ = attributesArr.map({
            if rect.contains($0.frame) {
                rectAttributes.append($0)
            }
        })
        return attributesArr
    }
}

class RoomViewController: CallingBaseViewController {
    // 刷新未链接超时的用户
    func reloadUsers() {
        let noConnectedUsers = users()
        remoteParticipants.removeAll { obj in
            if let user = obj as? CallingUserInfo, !noConnectedUsers.contains(where: { $0.userID == user.userID }) {
                return true
            }
            
            return false
        }
        DispatchQueue.main.async { [self] in
            collectionView.reloadData()
        }
    }
    
    private lazy var collectionView: UICollectionView = {
        print("creating UICollectionView...")
        let totalItems = remoteParticipants.count + 1
        let totalSectoin = totalItems < 5 ? 2 : 4
        let itemOfSectoin = totalItems < 5 ? 2 : 3
        
        let layout = CustomFlowLayout(numberOfSectoins: totalSectoin, numberOfItemsInSection: itemOfSectoin)

        let r = UICollectionView(frame: .zero, collectionViewLayout: layout)
        r.backgroundColor = .clear
        r.register(ParticipantCell.self, forCellWithReuseIdentifier: ParticipantCell.reuseIdentifier)
        r.delegate = self
        r.dataSource = self
        r.contentInsetAdjustmentBehavior = .never
        r.isPagingEnabled = true
        
        return r
    }()
    
    lazy var pageControl: UIPageControl = {
        let v = UIPageControl()
        v.currentPageIndicatorTintColor = .white
        v.pageIndicatorTintColor = .lightGray
        v.isHidden = true
        
        return v
    }()
    
    private var remoteParticipants: [Any] = [] // RemoteParticipant || CallingUserInfo
    
    private var cellReference = NSHashTable<ParticipantCell>.weakObjects()
    private var timer: Timer?
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true, block: { [weak self] _ in
            guard let self else { return }
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
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // When starting a group video, first display the profile picture.
        remoteParticipants = users()
        playSounds()
        room.add(delegate: self)
        setupView()
        onlineFuncButtons()
    }
    
    private func setupView() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(minimizeButton.snp_bottom).offset(24)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        view.addSubview(pageControl)
        pageControl.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.bottom.trailing.equalToSuperview().inset(16)
            make.height.equalTo(50)
        }
    }
    
    private func setParticipants() {
        let p = self.room.remoteParticipants.values.filter { $0.identity?.stringValue != self.groupID } // 有一个groupid 的监听者
        // 进场，替换掉链接中的obj
        for (i, item) in remoteParticipants.enumerated() {
            if let temp = item as? CallingUserInfo {
                if let obj = p.first(where: { $0.identityString == temp.userID }) {
                    remoteParticipants[i] = obj
                }
            } else if let temp = item as? RemoteParticipant {
                // 离场
                if p.firstIndex(where: { $0.identity == temp.identity }) == nil {
                    remoteParticipants.remove(at: i)
                }
            }
        }
        
        // 中途进场
        for (_, item) in p.enumerated() {
            if !remoteParticipants.contains(where: { obj in
                if let p = obj as? RemoteParticipant {
                    return p.identity == item.identity
                }
                
                return false
            }) {
                remoteParticipants.append(item)
            }
        }
        DispatchQueue.main.async { [self] in
            self.collectionView.reloadData()
        }
    }
}

extension RoomViewController: UICollectionViewDelegateFlowLayout {
    
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

extension RoomViewController: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // total number of participants to show (including local participant)
        let totalItems = remoteParticipants.count + 1

        return totalItems
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ParticipantCell.reuseIdentifier,
                                                      for: indexPath)
        if let cell = cell as? ParticipantCell {
            // keep weak reference to cell
            cellReference.add(cell)
            
            cell.disableCameraImageView.isHidden = isVideo
            
            if indexPath.item == 0 {
                cell.participant = room.localParticipant
            } else {
                let participant = remoteParticipants[indexPath.row - 1]
                if let participant = participant as? RemoteParticipant {
                    cell.participant = participant
                    cell.loadingView.isHidden = true
                } else {
                    let user = participant as! CallingUserInfo
                    cell.loadingView.isHidden = false
                    cell.loadingView.avatarView.setAvatar(url: user.faceURL, text: user.nickname)
                }
                if isVideo { // 中途加入有个bug，强开下视频
                    cell.videoForceEnable = true
                }
            }
        }
        
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = collectionView.frame.width
        let currentPage = Int((collectionView.contentOffset.x + pageWidth / 2) / pageWidth)

        pageControl.currentPage = currentPage
    }
}

extension RoomViewController: RoomDelegate {
    
    func room(_ room: Room, didFailToConnectWithError error: LiveKitError?) {
        print("\(#function)")
        onConnectFailure?()
        self.dismiss()
    }
    
    func room(_ room: Room, didUpdateConnectionState connectionState: ConnectionState, from oldValue: ConnectionState) {
        print("\(#function)")
        DispatchQueue.main.async { [self] in
            if case .disconnected = connectionState {
                self.remoteParticipants = []
                self.collectionView.reloadData()
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
        iLogger.print("\(#function): \(participant.identityString) \(participant.metadata)")
        setParticipants()
        
        let identityString = participant.identityString
        if identityString?.isEmpty == false{
            DispatchQueue.main.async { [self] in
                onAction?(.participantDidDisconnect(identityString!, linkingDuration))
            }
        }
//        DispatchQueue.main.async { [self] in
//            onAction?(.participantDidDisconnect(identityString!, linkingDuration))
//        }
    }
    
    public func room(_ room: Room, participantDidConnect participant: RemoteParticipant) {
        iLogger.print("\(#function): \(participant.metadata)")
        
        stopSounds()
        setParticipants()
        
        let identityString = participant.identityString
        
        DispatchQueue.main.async { [self] in
            onAction?(.participantDidConnect(identityString!))
        }
    }
}



class SuperStringUtil {
    
  
    /// 获取用户的信息  博客 公司 vip 名字
    static func getUserState(showname: String) -> UserState {
        guard let jsonData = showname.data(using: .utf8) else { return UserState(b: 0, e: 0, v: 0, n: showname)}
        do {
            let user = try JSONDecoder().decode(UserState.self, from: jsonData)
            return user
        } catch {
            return  UserState(b: 0, e: 0, v: 0, n: showname)
        }
    }
    
    static func getUserShowname(showname: String) -> String  {
        let user = getUserState(showname: showname)
        return user.n
    }
    /// 获取用户的tag
    static func getUserTag(showname: String) -> String? {
        guard let jsonData = showname.data(using: .utf8) else { return nil}
        do {
            let user = try JSONDecoder().decode(UserState.self, from: jsonData)
            var reslut = ""
            if user.v > 0 {
                reslut.append("V\(user.v)")
            }
            
            if user.b > 0 {
                reslut.append(reslut.count == 0 ? "\("博客".localized())" : "、\("博客".localized())")
            }
            
            if user.e > 0 {
                reslut.append(reslut.count == 0 ? "\("企业".localized())" : "、\("企业".localized())")
            }
            
            return reslut.count == 0 ? nil : "[\(reslut)]"
        } catch {
            return  nil
        }
    }
    
}


struct UserState: Codable {
    let b: Int
    let e: Int
    let v: Int
    let n: String
}
