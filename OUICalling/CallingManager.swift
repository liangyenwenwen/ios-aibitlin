
import Foundation
import OpenIMSDK
import RxSwift
import RxCocoa
import Reachability
import OUICore

enum CallingState: String {
    case normal = "normal"
    case call = "call" // 主动邀请
    case beCalled = "beCalled" // 被邀请
    case reject = "reject" // 拒绝
    case beRejected = "beRejected" // 被拒绝
    case calling = "calling" // 通话中
    case beAccepted = "beAccepted" // 已接受
    case hangup = "hangup" // 主动挂断
    case beHangup = "beHangup"// 被对方挂断
    case connecting = "connecting"
    case disConnect = "disConnect"
    case connectFailure = "connectFailure"
    case noReply = "noReply"// 无响应
    case cancel = "cancel" // 主动取消
    case beCanceled = "beCanceled" // 被取消
    case timeout = "timeout" //超时
    case join = "join" //主动加入（群通话）
    case accessByOther = "accessByOther"
    case rejectedByOther = "rejectedByOther"
}

public typealias ValueChangedHandler<T> = (_ value: T) -> Void

public class CallingManager: NSObject {
    private let disposeBag = DisposeBag()
    private var signalingInfo: OIMSignalingInfo?
    
    private var senderViewController: CallingSenderController? // 发起人
    private var reciverViewController: CallingReceiverController? // 接收人
    private var inviter: CallingUserInfo? // 邀请者
    private var others: [CallingUserInfo]?// 被邀请者
    // Invited list
    private var inviteeUsersID: [String] = []
    // in the livekit room
    private var participantsID: [String] = []
    private var currentIsGroup = false
    private var currentGroupID: String?
    
    private var isPresented: Bool = false // 是否弹出界面
    private var liveURL: String?
    private var token: String?
    private var reachability: Reachability?

    public static let manager: CallingManager = CallingManager()
    public var roomParticipantChangedHandler: ValueChangedHandler<OIMParticipantConnectedInfo>?
    public var endCallingHandler: ValueChangedHandler<OIMMessageInfo>?
    
    // 调用后初始化监听等
    public func start() {
        OIMManager.callbacker.addSignalingListener(listener: self)
        reachability = Reachability.forInternetConnection()
        reachability?.startNotifier()
        
        NotificationCenter.default.addObserver(self, selector: #selector(willTerminate), name: UIApplication.willTerminateNotification, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(checkRTCWhileStarting), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    public func end() {
        OIMManager.callbacker.removeSignalingListener(listener: self)
    }
    
    public func forceDismiss() {
        guard Self.isBusy else { return }
        
        if let signalingInfo {
            if inviteeUsersID.contains(OIMManager.manager.getLoginUserID()) {
                OIMManager.manager.signalingHungUp(signalingInfo, onSuccess: nil)
            }
        }
        
        if let senderViewController {
            senderViewController.dismiss()
        }
        
        if let reciverViewController {
            reciverViewController.dismiss()
        }
        
        CallingManager.manager.isPresented = false
    }
    
    static public var isBusy: Bool {
        CallingManager.manager.isPresented
    }
    
    // 杀死app后，调用下hungup
    @objc private func willTerminate() {
        update(state: .hangup)
    }
    
    private func setupSenderViewController() {
        senderViewController = CallingSenderController()
        // 发起者状态
        senderViewController!.onDisconnect = { [weak self] in
            self?.update(state: .disConnect)
        }
        
        senderViewController!.onConnectFailure = { [weak self] in
            self?.update(state: .connectFailure)
        }
        
        senderViewController!.onCancel = { [weak self] in
            self?.update(state: .cancel)
        }
        
        senderViewController!.onHungup = { [weak self] duration in
            self?.update(state: .hangup, duration: duration)
        }
        
        senderViewController!.onAction = { [weak self] action in
            guard let self else { return }
            
            switch action {
            case .participantDidConnect(let userID):
                if !participantsID.contains(userID) {
                    participantsID.append(userID)
                }
            case .participantDidDisconnect(let userID, let duration):
                if currentIsGroup {
                    inviteeUsersID.removeAll(where: { $0 == userID })
                    participantsID.removeAll(where: { $0 == userID })
                } else {
                    update(state: .beHangup, duration: duration ?? 0)
                }
            }
        }
    }
    
    private func setupReciverViewController() {
        reciverViewController = CallingReceiverController()
        // 接收者状态
        reciverViewController!.onDisconnect = { [weak self] in
            self?.update(state: .disConnect)
        }
        
        reciverViewController!.onConnectFailure = { [weak self] in
            self?.update(state: .connectFailure)
        }
        
        reciverViewController!.onAccepted = { [weak self] in
            if let signalingInfo = self?.signalingInfo {
                OIMManager.manager.signalingAccept(signalingInfo) { info in
                    self?.reciverViewController?.connectRoom(liveURL: info!.liveURL, token: info!.token)
                }
            }
        }
        
        reciverViewController!.onRejected = { [weak self] in
            self?.update(state: .reject)
        }
        
        reciverViewController!.onHungup = { [weak self] duration in
            self?.update(state: .hangup, duration: duration)
        }
        
        reciverViewController!.onAction = { [weak self] action in
            guard let self else { return }
            
            switch action {
            case .participantDidConnect(let userID):
                if !participantsID.contains(userID) {
                    participantsID.append(userID)
                }
            case .participantDidDisconnect(let userID, let duration):
                if currentIsGroup {
                    inviteeUsersID.removeAll(where: { $0 == userID })
                    participantsID.removeAll(where: { $0 == userID })
                } else {
                    update(state: .beHangup, duration: duration ?? 0)
                }
            }
        }
    }
    
    deinit {
        OIMManager.callbacker.removeSignalingListener(listener: self)
    }
    
    // SDK登录成功以后调用下
    @objc public func checkRTCWhileStarting() {
        OIMManager.manager.getSignalingInvitationInfoStartAppWith { [self] signalingInfo in
            guard let signalingInfo else { return }
            
            if Int(NSDate().timeIntervalSince1970 - signalingInfo.invitation.initiateTime) <= signalingInfo.invitation.timeout {
                self.signalingInfo = signalingInfo
                self.startLiveChat(inviterID: signalingInfo.invitation.inviterUserID,
                                   othersID: signalingInfo.invitation.inviteeUserIDList,
                                   isVideo: signalingInfo.isVideo,
                                   groupID: signalingInfo.invitation.groupID,
                                   incoming: true)
            } else {
                if isPresented,
                    reciverViewController?.isConnected() == false,
                    senderViewController?.isConnected() == false {
                    reciverViewController?.dismiss()
                    reciverViewController = nil
                    isPresented = false
                }
            }
        } onFailure: { code, msg in
            print("code:\(code), msg:\(msg)")
        }
    }
    
    public func signalingGetInvitation(by roomID: String, onSuccess: @escaping (_ url: String, _ token: String) -> Void) {
        OIMManager.manager.signalingGetToken(byRoomID: roomID) { signalingInfo in
            guard let signalingInfo else { return }
            
            onSuccess(signalingInfo.liveURL, signalingInfo.token)
        }
    }
    
    // 发起音视频聊天
    public func startLiveChat(inviterID: String = OIMManager.manager.getLoginUserID(),
                              othersID: [String],
                              isVideo: Bool = true,
                              groupID: String? = nil,
                              incoming: Bool = false) {
        
        guard reachability?.isReachable() == true else {
            showAlert(message: "网络不好或对方正忙".localized() + "...") { [self] in
                self.isPresented = false
                self.senderViewController?.dismiss()
            }
            return
        }
        
        inviteeUsersID = othersID
        currentIsGroup = groupID?.isEmpty == false
        currentGroupID = groupID
        
        if isPresented {
            return
        }
        isPresented = true
        
        if !incoming {
            // 发起者
            setupSenderViewController()
            
            invite(othersID: othersID, isVideo: isVideo, groupID: groupID) { [weak self] canStart in
                guard let self, canStart else { return }
                
                getUsersInfo([inviterID] + othersID, groupID: groupID) { [weak self] r in
                    guard let `self` else { return }
                    
                    self.inviter = r.first
                    self.others = Array(r.dropFirst())
                    self.senderViewController!.startLiveChat(inviter: { [weak self] in
                        
                        guard let `self` else { return [] }
                        return [self.inviter!]
                    }, others: { [weak self] in
                        
                        guard let `self` else { return [] }
                        return self.others!
                    }, isVideo: isVideo, groupID: groupID)
                }
            }
        } else {
            // 收到音视频邀请
            setupReciverViewController()
            getUsersInfo([inviterID] + othersID, groupID: groupID) { [weak self] r in
                guard let `self` else { return }
                self.inviter = r.first
                self.others = Array(r.dropFirst())
                self.reciverViewController?.startLiveChat(inviter: { [weak self] in
                    
                    guard let `self` else { return [] }
                    return [self.inviter!]
                }, others: { [weak self] in
                    
                    guard let `self` else { return [] }
                    return self.others!
                }, isVideo: isVideo, groupID: groupID)
            }
            
        }
    }
    
    // 发起音视频聊天
    public func startLiveChat(inviter: CallingUserInfo = CallingUserInfo(userID: OIMManager.manager.getLoginUserID()),
                              others: [CallingUserInfo],
                              isVideo: Bool = true,
                              groupID: String? = nil,
                              incoming: Bool = false) {
        
        guard reachability?.isReachable() == true else {
            showAlert(message: "网络不好或对方正忙".localized() + "...") { [self] in
                self.isPresented = false
                self.senderViewController?.dismiss()
            }
            return
        }
        
        inviteeUsersID = others.map({ $0.userID })
        currentIsGroup = groupID?.isEmpty == false
        currentGroupID = groupID
        
        if isPresented {
            return
        }
        isPresented = true

        self.inviter = inviter
        self.others = others
        
        if !incoming {
            // 发起者
            setupSenderViewController()
            
            invite(othersID: others.map({$0.userID}), isVideo: isVideo, groupID: groupID) { [weak self] canStart in
                guard let self, canStart else {
                    self?.isPresented = false
                    return
                }
                
                senderViewController!.startLiveChat(inviter: {
                    return [inviter]
                }, others: { [weak self] in
                    guard let self else { return [] }
                    return self.others!
                }, isVideo: isVideo, groupID: groupID)
            }
        } else {
            // 收到音视频邀请
            setupReciverViewController()
            self.reciverViewController!.startLiveChat(inviter: {
                return [inviter]
            }, others: {
                return others
            }, isVideo: isVideo, groupID: groupID)
        }
    }
    
    private func invite(othersID: [String], isVideo: Bool, groupID: String? = nil, completion: @escaping ((Bool) -> Void)) {
        let info = OIMInvitationInfo()
        info.inviteeUserIDList = othersID
        info.groupID = groupID ?? ""
        info.mediaType = isVideo ? "video" : "audio"
        info.timeout = 20
        
        var offlinePushInfo = OIMOfflinePushInfo()
        
        if let groupID, !groupID.isEmpty {
            offlinePushInfo.title = "Someone invited you to a group chat."
        }
        
        signalingInfo = OIMManager.manager.signalingInvite(info, offlinePushInfo: offlinePushInfo) { [weak self] r in
            if (r?.busyLineUserIDList.isEmpty == true || groupID != nil), let url = r?.liveURL, let token = r?.token {
                completion(true)
                self?.liveURL = url
                self?.token = token
                if groupID != nil {
                    self?.senderViewController!.connectRoom(liveURL: url, token: token)
                }
            } else {
                completion(false)
                
                self?.showAlert(message: "网络不好或对方正忙".localized() + "...") { [self] in
                    self?.isPresented = false
                    self?.senderViewController?.dismiss()
                }
            }
        } onFailure: { [self] code, msg in
            completion(false)
            
            if code == 1302 {
                showAlert(message: "callFail".localized() + "...") { [self] in
                    self.isPresented = false
                    self.senderViewController?.dismiss()
                }
            } else if code == 35001 {
                showAlert(message: "callingBusy".localized()) { [self] in
                    self.isPresented = false
                    self.senderViewController?.dismiss()
                }
            } else {
                showAlert(message: msg ?? "SignalingInvite throw error:" + "\(code)") { [self] in
                    self.isPresented = false
                    self.senderViewController?.dismiss()
                }
            }
            print("邀请音视频,code:\(code), msg: \(msg)")
        }
    }
    
    // 中途进入房间
    public func joinRoom(isVideo: Bool = true, roomID: String, liveURL: String, token: String) {
        
        currentIsGroup = false
        currentGroupID = roomID
        
        if isPresented {
            return
        }
        isPresented = true
        
        if reciverViewController == nil {
            setupReciverViewController()
        }

        self.reciverViewController!.joinRoomWith(isVideo: isVideo, roomID: roomID, liveURL: liveURL, token: token)
    }
    
    // 从sdk获取用户基础信息
    private func getUsersInfo(_ usersID: [String], groupID: String?, callback: @escaping ([CallingUserInfo]) -> Void) {
        
        if groupID?.isEmpty == false {
            OIMManager.manager.getSpecifiedGroupMembersInfo(groupID!, usersID: usersID) { members in
                let us = members!.compactMap({ CallingUserInfo(userID: $0.userID, nickname: $0.nickname, faceURL: $0.faceURL )})
                
                callback(us)
            }
        } else {
            var tempUserIDs: [String] = []
            OIMManager.manager.getSpecifiedFriendsInfo(usersID) { friends in
                
                var us = friends?.compactMap({ CallingUserInfo(userID: $0.userID, nickname: $0.nickname, faceURL: $0.faceURL )}) ?? []
                tempUserIDs.removeAll(where: { id in
                    us.contains(where: { $0.userID == id }) == true
                })
                
                guard !tempUserIDs.isEmpty else {
                    callback(us)
                    
                    return
                }
                
                OIMManager.manager.getUsersInfo(tempUserIDs) { infos in
                    guard let infos else {
                        callback(us)
                        
                        return
                    }
                    
                    us += infos.compactMap({ CallingUserInfo(userID: $0.userID, nickname: $0.nickname, faceURL: $0.faceURL )})
                    
                    callback(us)
                }
                
                
            }
        }
    }
    
    private func showAlert(message: String, handler: (() -> Void)?) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "取消".localized(), style: .cancel, handler: { [weak self] action in
            handler?()
        }))
        UIViewController.currentViewController().present(alertController, animated: true)
    }
}

// MARK: 状态变更，消息记录保存
extension CallingManager {
    // 关闭界面操作
    private func update(state: CallingState, duration: Int = 0) {
        print("\(#function): state:\(state)")
        if state == .beAccepted || state == .disConnect {
            if state == .beAccepted {
                if let liveURL, let token, signalingInfo?.isSignal == true {
                    senderViewController?.connectRoom(liveURL: liveURL, token: token)
                }
            } else {
                isPresented = false
            }
            return
        }
        
        isPresented = false
        
        var timeline = "00:00"
        
        if duration > 0 {
            let m = duration / 60
            let s = duration % 60
            
            if m > 99 {
                timeline = String(format: "%d:%02d", m, s)
            } else {
                timeline = String(format: "%02d:%02d", m, s)
            }
        }
        let loginUserID = OIMManager.manager.getLoginUserID()
        var tips = ""
        var record = CallRecord()
        
        switch state {
        case .normal:
            break
        case .call:
            break
        case .beCalled:
            break
        case .reject:
            signalingInfo?.userID = loginUserID
            if let signalingInfo {
                OIMManager.manager.signalingReject(signalingInfo, onSuccess: nil)
            }
            tips = "已拒绝".localized()
        case .beRejected:
            tips = "对方已拒绝".localized()
        case .calling:
            break
        case .beAccepted:
            break
        case .hangup:
            signalingInfo?.userID = loginUserID
            if let signalingInfo {
                OIMManager.manager.signalingHungUp(signalingInfo, onSuccess: nil)
            }
            tips = "通话结束".localized() + ":\(timeline)"
            record.success = true
        case .connecting:
            break
        case .noReply:
            signalingInfo?.userID = loginUserID
            if let signalingInfo, signalingInfo.isSignal {
                OIMManager.manager.signalingCancel(signalingInfo, onSuccess: nil)
            }
            tips = "无响应".localized()
        case .cancel:
            signalingInfo?.userID = loginUserID
            if let signalingInfo {
                OIMManager.manager.signalingCancel(signalingInfo, onSuccess: nil)
            }
            tips = "已取消".localized()
        case .beCanceled:
            tips = duration > 0 ? "通话结束".localized() + ":\(timeline)" : "对方取消".localized()
            record.success = duration > 0
        case .timeout:
            tips = "超时无人接听".localized()
        case .join:
            break
        case .beHangup:
            if duration > 0 {
                tips = "通话结束".localized() + ":\(timeline)"
                record.success = true
            }
        case .disConnect:
            break
        case .connectFailure:
            tips = "connectionFailed".localized()
        case .accessByOther:
            tips = "通话邀请被其它客户端接受".localized()
        case .rejectedByOther:
            tips = "通话邀请被其它客户端拒绝".localized()
        }
        
        if #available(iOS 15, *) {
            record.date = Int(round(Date.now.timeIntervalSince1970 * 1000))
        } else {
            record.date = Int(round(Date.init().timeIntervalSince1970 * 1000))
        }
        // 创建记录
        if let signalingInfo {
            record.nickname = others?.first?.nickname
            record.type = signalingInfo.isVideo ? "video": "audio"
            record.faceURL = others?.first?.faceURL
            record.duration = duration
            record.isSingnal = signalingInfo.isSignal
            record.incoming = signalingInfo.invitation.inviterUserID != OIMManager.manager.getLoginUserID()
            record.otherSideID = record.incoming ? signalingInfo.invitation.inviterUserID : signalingInfo.invitation.inviteeUserIDList.first
            
            if signalingInfo.isSignal, !tips.isEmpty {
                // 目前仅支持单聊
                Self.saveRrecord(record: record)
     
                do {
                    if !tips.isEmpty {
                        let param = ["customType": 901,
                                     "data": ["duration": duration,
                                              "state": state.rawValue,
                                              "type": signalingInfo.invitation.mediaType,
                                              "msg": tips
                                             ]
                        ] as [String : Any]
                        
                        let dataStr = String.init(data: try JSONSerialization.data(withJSONObject: param),
                                                  encoding: .utf8)!
                        
                        let msg = OIMMessageInfo.createCustomMessage(dataStr, extension: nil, description: nil)
                        insertCallingMessage(msg, signaling: signalingInfo, state: state)
                    }
                } catch (let e) {
                    print("catch \(e)")
                }
            }
        }

        // 关闭界面，销毁room等
        reciverViewController?.dismiss()
        reciverViewController = nil
        senderViewController?.dismiss()
        senderViewController = nil
    }
}

// MARK: 插入消息
extension CallingManager {
    
    private func insertCallingMessage(_ msg: OIMMessageInfo, signaling: OIMSignalingInfo, state: CallingState) {
        let loginUserID = OIMManager.manager.getLoginUserID()
        
        if state == .cancel || state == .beRejected || state == .reject || state == .noReply || state == .accessByOther || state == .rejectedByOther {
            // 发起 - 未接听
            OIMManager.manager.insertSingleMessage(toLocalStorage: msg,
                                                   recvID: others!.first!.userID,
                                                   sendID: signaling.invitation.inviterUserID,
                                                   onSuccess: { [weak self] message in
                guard let self, let message else { return }
                endCallingHandler?(message)
            }) { code, msg in
                print("单聊插入本地失败:\(code), \(msg)")
            }
        } else {
            // 接受 - 接听以后
            var recvID = signaling.invitation.inviteeUserIDList.first!
            var sendID = signaling.invitation.inviterUserID
            
            // 如果操作者是自己
            if signaling.userID == loginUserID {
                // 如果发起邀请的是自己
                if signaling.invitation.inviterUserID == loginUserID {
                    recvID = signaling.invitation.inviteeUserIDList.first!
                } else {
                    recvID = signaling.invitation.inviterUserID
                }
            } else {
                recvID = loginUserID
            }
            
            OIMManager.manager.insertSingleMessage(toLocalStorage: msg,
                                                   recvID: recvID,
                                                   sendID: sendID,
                                                   onSuccess: { [weak self] message in
                guard let self, let message else { return }
                endCallingHandler?(message)
            }) { code, msg in
                print("单聊插入本地失败:\(code), \(msg)")
            }
        }
        
    }
    
    // 通话结束保存本地的音视频记录
    static public func saveRrecord(record: CallRecord) {
        let recordsKey = "\(Open_im_sdkGetLoginUserID())-com.calling.records.key"
        var records: [CallRecord] = []
        
        if let jsonStr = UserDefaults.standard.string(forKey: recordsKey) {
            records = CallRecord.fromJson(jsonStr)
        }
        
        records.insert(record, at: 0)
        
        let result = Array<CallRecord>.toJson(fromObject: records)
        UserDefaults.standard.set(result, forKey: recordsKey)
        UserDefaults.standard.synchronize()
    }
    
    // 获取本地的音视频记录
    static public func getRecords() -> [CallRecord] {
        let recordsKey = "\(Open_im_sdkGetLoginUserID())-com.calling.records.key"
        
        if let jsonStr = UserDefaults.standard.string(forKey: recordsKey) {
            var records = CallRecord.fromJson(jsonStr)
            
            return records
        }
        
        return []
    }
}

// MARK: 监听函数

extension CallingManager: OIMSignalingListener {
    
    func removeInvite(userID: String, isTimeout: Bool = false, isInviterHungup: Bool = false) {
        
        inviteeUsersID.removeAll(where: { $0 == userID })
        
        let leftParticipantCount = participantsID.count;
        var canClose = false

        if isInviterHungup, leftParticipantCount < 2 {
            canClose = true
        } else if leftParticipantCount < 2 {
            let p = participantsID.first
            let isLeftInviter = p == signalingInfo?.invitation.inviterUserID
            
            if isLeftInviter {
                if inviteeUsersID.isEmpty {
                    canClose = true
                }
            } else {
                canClose = true
            }
        }
        
        if canClose {
            if isTimeout {
                if let signalingInfo {
                    OIMManager.manager.signalingCancel(signalingInfo, onSuccess: nil)
                }
            }
            
            if let senderViewController {
                senderViewController.dismiss()
            }
            
            if let reciverViewController {
                reciverViewController.dismiss()
            }
            
            signalingInfo = nil
            isPresented = false
        }
        
        iLogger.print("\(#function) left participant: \(inviteeUsersID.map({ $0 }))", keyAndValues: [userID, isTimeout, isInviterHungup, canClose])
    }
    public func onReceiveNewInvitation(_ signalingInfo: OIMSignalingInfo) {
        self.signalingInfo = signalingInfo
        
        startLiveChat(inviterID: signalingInfo.invitation.inviterUserID,
                      othersID: signalingInfo.invitation.inviteeUserIDList,
                      isVideo: signalingInfo.isVideo,
                      groupID: signalingInfo.invitation.groupID,
                      incoming: true)
        
        inviteeUsersID = signalingInfo.invitation.inviteeUserIDList
        iLogger.print("\(#function) participant: \(inviteeUsersID.map({ $0 }))")
    }
    
    public func onRoomParticipantConnected(_ connectedInfo: OIMParticipantConnectedInfo) {
        if !currentIsGroup || connectedInfo.groupID != currentGroupID {
            return
        }
        
        iLogger.print("\(#function) participant: \(connectedInfo.participant.map({ $0.userInfo.userID }))")
        
        roomParticipantChangedHandler?(connectedInfo)
        
        participantsID = connectedInfo.participant.compactMap({ $0.userInfo.userID })
    }
    
    public func onRoomParticipantDisconnected(_ disconnectedInfo: OIMParticipantConnectedInfo) {
        if !currentIsGroup || disconnectedInfo.groupID != currentGroupID {
            return
        }
        
        iLogger.print("\(#function) participant: \(disconnectedInfo.participant.map({ $0.userInfo.userID }))")
        
        roomParticipantChangedHandler?(disconnectedInfo)
        // 最后一个人就关闭群聊
        if !disconnectedInfo.invitation.groupID.isEmpty, (disconnectedInfo.participant == nil || disconnectedInfo.participant.count == 1), inviteeUsersID.count == 1 {
            update(state: .beHangup)
            reciverViewController?.dismiss()
        }
        
        participantsID = disconnectedInfo.participant.compactMap({ $0.userInfo.userID })
    }
    
    public func onInviteeAccepted(_ signalingInfo: OIMSignalingInfo) {
        iLogger.print("\(#function)", keyAndValues: [signalingInfo.userID, signalingInfo.invitation.inviteeUserIDList])
        
        self.signalingInfo = signalingInfo
        update(state: .beAccepted)
    }
    
    public func onInviteeRejected(_ signalingInfo: OIMSignalingInfo) {
        iLogger.print("\(#function)", keyAndValues: [signalingInfo.userID, signalingInfo.invitation.inviteeUserIDList])

        self.signalingInfo = signalingInfo
        if signalingInfo.isSignal {
            update(state: .beRejected)
        } else {
            others?.removeAll(where: { $0.userID == signalingInfo.userID })
            senderViewController?.reloadUsers()
        }
        
        if currentIsGroup, signalingInfo.invitation.groupID == currentGroupID {
            removeInvite(userID: signalingInfo.userID)
        }
    }
    
    public func onInvitationCancelled(_ signalingInfo: OIMSignalingInfo) {
        iLogger.print("\(#function)", keyAndValues: [signalingInfo.userID, signalingInfo.invitation.inviteeUserIDList])

        self.signalingInfo = signalingInfo
        update(state: .beCanceled)
        
        if currentIsGroup, signalingInfo.invitation.groupID == currentGroupID {
            removeInvite(userID: signalingInfo.userID)
        }
    }
    
    public func onInvitationTimeout(_ signalingInfo: OIMSignalingInfo) {
        iLogger.print("\(#function)", keyAndValues: [signalingInfo.userID, signalingInfo.invitation.inviteeUserIDList])

        self.signalingInfo = signalingInfo
        if signalingInfo.isSignal {
            update(state: .noReply)
        } else {
            others?.removeAll(where: { $0.userID == signalingInfo.userID })
            senderViewController?.reloadUsers()
        }
        
        if currentIsGroup, signalingInfo.invitation.groupID == currentGroupID {
            removeInvite(userID: signalingInfo.userID, isTimeout: true)
        }
    }
    
    public func onHunguUp(_ signalingInfo: OIMSignalingInfo) {
        iLogger.print("\(#function)", keyAndValues: [signalingInfo.userID, signalingInfo.invitation.inviteeUserIDList])

        self.signalingInfo = signalingInfo
        // livekit disconnect after the hungup singnaling
//        if signalingInfo.isSignal {
//            var duration = (senderViewController?.duration ?? reciverViewController?.duration) ?? 0
//            update(state: .beHangup, duration: duration)
//        }
        
        if !signalingInfo.isSignal, currentIsGroup, signalingInfo.invitation.groupID == currentGroupID {
            removeInvite(userID: signalingInfo.userID, isInviterHungup: signalingInfo.userID == signalingInfo.invitation.inviterUserID)
        }
    }
    
    public func onInviteeAccepted(byOtherDevice signalingInfo: OIMSignalingInfo) {
        iLogger.print("\(#function)", keyAndValues: [signalingInfo.userID, signalingInfo.invitation.inviteeUserIDList])

        self.signalingInfo = signalingInfo
        update(state: .accessByOther)
    }
    
    public func onInviteeRejected(byOtherDevice signalingInfo: OIMSignalingInfo) {
        iLogger.print("\(#function)", keyAndValues: [signalingInfo.userID, signalingInfo.invitation.inviteeUserIDList])

        self.signalingInfo = signalingInfo
        if signalingInfo.isSignal {
            update(state: .rejectedByOther)
        } else {
            others?.removeAll(where: { $0.userID == signalingInfo.userID })
            senderViewController?.reloadUsers()
        }
        
        if currentIsGroup, signalingInfo.invitation.groupID == currentGroupID {
            removeInvite(userID: signalingInfo.userID)
        }
    }
}

extension OIMSignalingInfo {
    var isSignal: Bool {
        return invitation.groupID == nil || invitation.groupID.isEmpty
    }
    
    var isVideo: Bool {
        return invitation.isVideo()
    }
}

public class CallRecord: Codable {
    public var otherSideID: String?
    public var nickname: String?
    public var faceURL: String?
    public var type: String?
    public var success: Bool = false
    public var incoming: Bool = false
    public var date: Int = 0
    public var duration: Int = 0
    public var isSingnal: Bool = true
    
    public func typeStr() -> String {
        return type == "audio" ? "语音通话".innerLocalized() : "视频通话".innerLocalized()
    }
    
    public func isVideo() -> Bool {
        return type == "video"
    }
    
    public func inOrOutStr() -> String {
        return incoming ? "呼入".innerLocalized() : "呼出".innerLocalized()
    }
    
    public func durationStr() -> String {
        
        var timeline = "";
        
        if duration > 0 {
            let m = duration / 60
            let s = duration % 60
            
            if m > 99 {
                timeline = String(format: "%d:%02d", m, s)
            } else {
                timeline = String(format: "%02d:%02d", m, s)
            }
        }
        
        return timeline
    }
    
    public func formatDateStr() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let date = Date.init(timeIntervalSince1970: TimeInterval(date / 1000))
        return formatter.string(from: date)
    }
    
    static func fromJson(_ json: String) -> [CallRecord] {
        let decoder = JSONDecoder()
        do {
            let result = try decoder.decode([CallRecord].self, from: json.data(using: .utf8)!)
            return result
        } catch let DecodingError.dataCorrupted(context) {
            return []
        } catch let DecodingError.keyNotFound(_, context) {
            return []
        } catch let DecodingError.typeMismatch(_, context) {
            return []
        } catch let DecodingError.valueNotFound(_, context) {
            return []
        } catch {
            return []
        }
    }
    
    func toJson() -> String {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(self)
            guard let json = String(data: data, encoding: .utf8) else {
                fatalError("check your data is encodable from utf8!")
            }
            return json
        } catch let err {
            return ""
        }
    }
}

extension Array {
    static func toJson<T: Encodable>(fromObject: T) -> String {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(fromObject)
            guard let json = String(data: data, encoding: .utf8) else {
                fatalError("check your data is encodable from utf8!")
            }
            return json
        } catch let err {
            return ""
        }
    }
}
