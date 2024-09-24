
import OUICore
import OpenIMSDK
import RxSwift

public typealias MeetingReturnVoid = ([MeetingInfo]) -> Void
public typealias SignalingInfoOptionalReturnVoid = (InvitationResultInfo) -> Void

public class InvitationResultInfo: Codable {
    public var token: String?
    public var liveURL: String?
    public var roomID: String?
    
    public init() {
        
    }
}

extension IMController {
    
    private struct AssociatedKeys {
        static var meetingStreamChangeKey = "meetingStreamChangeKey"
    }
    
    public var meetingStreamChange: PublishSubject<MeetingStreamEvent> {
        get {
            return (objc_getAssociatedObject(self, &AssociatedKeys.meetingStreamChangeKey) as? PublishSubject<MeetingStreamEvent>) ?? .init()
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.meetingStreamChangeKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public func addRoomSignalingListener() {
        OIMManager.callbacker.addSignalingListener(listener: self)
    }
    
    public func getRoomSignalingInfoByGroupID(groupID: String, onSuccess: @escaping CallBack.GroupSignalingInfoReturnVoid) {
        Self.shared.imManager.signalingGetRoom(byGroupID: groupID) { info in
            
            if let participants = info?.participant, let participant = participants.first {
                let members = participants.map {$0.groupMemberInfo.toGroupMemberInfo()}
                onSuccess(info!.invitation.isVideo(), members)
            } else {
                onSuccess(false, [])
            }
        } onFailure: { code, msg in
            print("\(#function):\(code), \(msg)")
        }
    }
    
    public func signalingGetInvitation(by roomID : String, onSuccess: @escaping SignalingInfoOptionalReturnVoid) {
        Self.shared.imManager.signalingGetToken(byRoomID: roomID, onSuccess: { info in
            guard let info else { return }
            
            info.roomID = roomID
            onSuccess(info.toInvitationResultInfo())
        }) { code, msg in
            print("\(#function):\(code), \(msg)")
        }
   }
    
    public func signalingCreateMeeting(name: String, startTime: Double, duration: Double, onSuccess: @escaping SignalingInfoOptionalReturnVoid, onFailure: CallBack.ErrorOptionalReturnVoid?) {
        Self.shared.imManager.signalingCreateMeeting(name,
                                                     meetingHostUserID: IMController.shared.uid,
                                                     startTime: Int(startTime) as NSNumber,
                                                     meetingDuration: Int(duration) as NSNumber,
                                                     inviteeUserIDList: []) { r in
            onSuccess(r!.toInvitationResultInfo())
        } onFailure: { (code, msg) in
            print("创建会议错误:\(code), 消息：\(msg)")
            onFailure?(code, msg)
        }
    }
    
    public func signalingJoinMeeting(meetingID: String, meetingName: String? = nil, participantNickname: String? = nil, onSuccess: @escaping SignalingInfoOptionalReturnVoid, onFailure: @escaping CallBack.ErrorOptionalReturnVoid) {
        Self.shared.imManager.signalingJoinMeeting(meetingID, name: meetingName, participantNickname: participantNickname) { r in
            onSuccess(r!.toInvitationResultInfo())
        } onFailure: { (code, msg) in
            print("加入会议错误:\(code), 消息：\(msg)")
            onFailure(code, msg)
        }
    }
    
    public func signalingCloseMeeting(meetingID: String, onSuccess: @escaping CallBack.StringOptionalReturnVoid, onFailure: @escaping CallBack.ErrorOptionalReturnVoid) {
        Self.shared.imManager.signalingCloseRoom(meetingID) { r in
            onSuccess(r)
        } onFailure: { (code, msg) in
            print("结束会议错误:\(code), 消息：\(msg)")
            onFailure(code, msg)
        }
    }
    
    public func signalingUpdateMeetingInfo(meetingID: String, param: [String: Any], onSuccess: @escaping CallBack.StringOptionalReturnVoid) {
        Self.shared.imManager.signalingUpdateMeetingInfo(meetingID, setting: param) { r in
            onSuccess(r)
        } onFailure: { (code, msg) in
            print("\(#function) throw errs:\(code), \(msg)")
            onSuccess(nil)
        }
    }
    
    /**
     会议室 管理员对指定的某一个入会人员设置禁言
     @param roomID 会议ID
     @param userID 目标的用户ID
     @param streamType video/audio
     @param mute YES：禁言
     @param muteAll video/audio 一起设置
     */
    public func signalingOperateStream(meetingID: String, userID: String, streamType: String? = nil, mute: Bool = true, muteAll: Bool = false, onSuccess: @escaping CallBack.StringOptionalReturnVoid) {
        Self.shared.imManager.signalingOperateStream(meetingID, userID: userID, streamType: streamType ?? "video", mute: mute, muteAll: muteAll) { r in
            onSuccess(r)
        } onFailure: { (code, msg) in
            onSuccess(nil)
            print("加入会议错误:\(code), 消息：\(msg)")
        }
    }
    
    public func signalingGetMeetings(onSuccess: @escaping MeetingReturnVoid) {
        Self.shared.imManager.signalingGetMeetings { r in
            let result = r?.meetingInfoList.map {$0.toMeetingInfo()} ?? []
            onSuccess(result)
        } onFailure: { (code, msg) in
            print("获取会议错误:\(code), 消息：\(msg)")
        }
    }
}


extension IMController: OIMSignalingListener {
    public func onStreamChange(_ meettingInfo: OIMMeetingStreamEvent) {
        meetingStreamChange.onNext(meettingInfo.toMeetingStreamEvent())
    }
}

extension OIMInvitationResultInfo {
    public func toInvitationResultInfo() -> InvitationResultInfo {
        let item = InvitationResultInfo()
        item.roomID = roomID
        item.liveURL = liveURL
        item.token = token
        
        return item
    }
}

extension OIMMeetingInfoList {
    func toMeetingInfoList() -> MeetingInfoList {
        let item = MeetingInfoList()
        
        return item
    }
}

class MeetingInfoList: Codable {
    public var meetingInfoList: [MeetingInfo] = []
}

open class MeetingInfo: Codable {
    public var roomID: String = ""
    public var meetingName: String?
    public var hostUserID: String?
    public var createTime: Double = 0
    public var startTime: Double = 0
    public var endTime: Double = 0
    public var participantCanUnmuteSelf: Bool? // 成员是否能开启音频
    public var participantCanEnableVideo: Bool? // 成员是否能开启视频
    public var onlyHostInviteUser: Bool? //仅主持人可邀请用户
    public var joinDisableVideo: Bool? //加入是否默认关视频
    public var isMuteAllMicrophone: Bool? // 是否全员禁用麦克风
    public var inviteeUserIDList: [String]? //邀请列表
    public var onlyHostShareScreen: Bool?  //仅主持人可共享屏幕
    public var joinDisableMicrophone: Bool?  //加入是否默认关麦克风
    public var isMuteAllVideo: Bool? // 是否全员禁用视频
    public var canScreenUserIDList: [String]? // 可共享屏幕的ID列表
    public var disableMicrophoneUserIDList: [String]? // 当前被禁言麦克风的id列表
    public var disableVideoUserIDList: [String]? // 当前禁用视频流的ID列表
    public var pinedUserIDList: [String]? // 置顶ID列表
    public var beWatchedUserIDList: [String]? // 正在被观看用户列表
    
    // 增加/删除相关ID
    public var addCanScreenUserIDList: [String]?
    public var reduceCanScreenUserIDList: [String]?
    public var addDisableMicrophoneUserIDList: [String]?
    public var reduceDisableMicrophoneUserIDList: [String]?
    public var addDisableVideoUserIDList: [String]?
    public var reduceDisableVideoUserIDList: [String]?
    public var addPinedUserIDList: [String]?
    public var reducePinedUserIDList: [String]?
    public var addBeWatchedUserIDList: [String]?
    public var reduceBeWatchedUserIDList: [String]?
    
    public var ex: String?
    
    public var hostUserName: String?
    
    public init() {
        
    }
}

public class MeetingStreamEvent: Codable {
    public var roomID: String = ""
    public var streamType: String?
    public var mute: Bool = false
    
    public init() {
        
    }
}

extension OIMMeetingInfo {
    public func toMeetingInfo() -> MeetingInfo {
        let item = MeetingInfo()
        item.roomID = roomID
        item.meetingName = meetingName
        item.startTime = startTime
        item.endTime = endTime
        item.createTime = createTime
        item.hostUserID = hostUserID
        item.inviteeUserIDList = inviteeUserIDList
        item.isMuteAllMicrophone = isMuteAllMicrophone
        item.joinDisableVideo = joinDisableVideo
        item.onlyHostInviteUser = onlyHostInviteUser
        item.participantCanEnableVideo = participantCanEnableVideo
        item.participantCanUnmuteSelf = participantCanUnmuteSelf
        return item
    }
}

extension OIMMeetingStreamEvent {
    public func toMeetingStreamEvent() -> MeetingStreamEvent {
        let item = MeetingStreamEvent()
        item.roomID = roomID
        item.mute = mute
        item.streamType = streamType
        
        return item
    }
}

extension InvitationResultInfo {
    public func toOIMInvitationResultInfo() -> OIMInvitationResultInfo {
        let json: String = JsonTool.toJson(fromObject: self)
        if let item = OIMInvitationResultInfo.mj_object(withKeyValues: json) {
            return item
        }
        return OIMInvitationResultInfo()
    }
}

