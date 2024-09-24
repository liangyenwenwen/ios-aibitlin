
import OUICore
import LiveKitClient
import RxSwift
import RxRelay

class LiveRoomViewModel {
    
    var invitationSingling: InvitationResultInfo
    var meetingInfo: SettingInfo?
    let disposeBag = DisposeBag()
    let meetingStreamChangeRelay: BehaviorRelay<MeetingStreamEvent?> = .init(value: nil)
    let kickedOffline: PublishSubject<Bool> = .init()

    init(invitationSingling: InvitationResultInfo) {
        self.invitationSingling = invitationSingling
        
        IMController.shared.meetingStreamChange.subscribe(onNext: { [weak self] event in
            if event.roomID == self?.meetingInfo?.roomID {
                self?.meetingStreamChangeRelay.accept(event)
            }
        }).disposed(by: disposeBag)
        
        IMController.shared.connectionRelay.subscribe(onNext: { [self] status in
            if status == .kickedOffline {
                kickedOffline.onNext(true)
            }
        }).disposed(by: disposeBag)
    }
    
    func closeRoom(_ completion: @escaping CallBack.StringOptionalReturnVoid) {
        IMController.shared.signalingCloseMeeting(meetingID: invitationSingling.roomID!, onSuccess: completion, onFailure: { (code, msg) in
            
        })
    }
    
    func getHosterInfo() {
        guard let hostUserID = meetingInfo?.hostUserID else { return }
        IMController.shared.getUserInfo(uids: [hostUserID]) { [weak self] r in
            self?.meetingInfo?.hosterName = r.first?.showName
        }
    }
    
    func updateMeetingInfo(info: MeetingInfo? = nil) async -> Bool {
        if info != nil {
            info?.roomID = meetingInfo!.roomID
        }
        let j = JsonTool.toMap(fromObject: info ?? meetingInfo)
        print("updateMeetingInfo: \(j)")
        return await withCheckedContinuation { continuation in
            IMController.shared.signalingUpdateMeetingInfo(meetingID: meetingInfo!.roomID, param: j) { [self] r in
                print("result: \(r)")
                if let r {
                    var meetingInfoMap = JsonTool.toMap(fromObject: meetingInfo)
                
                    for (key, value) in j {
                        meetingInfoMap[key] = value
                    }
                    self.meetingInfo = JsonTool.fromMap(meetingInfoMap, toClass: SettingInfo.self)
                    continuation.resume(returning: true)
                } else {
                    continuation.resume(returning: false)
                }
            }
        }
    }
        
    func updateUserInfo(userID: String, streamType: String? = nil, mute: Bool = true, muteAll: Bool = false, onCompletion:((Bool) -> Void)? = nil) {
        IMController.shared.signalingOperateStream(meetingID: meetingInfo!.roomID, userID: userID, streamType: streamType, mute: mute, muteAll: muteAll) { r in
            onCompletion?(r != nil)
        }
    }
    
    func sendMeetingMessage(desID: String, conversationType: ConversationType) {
        guard let meetingInfo = meetingInfo else { return }
        let message = IMController.shared.createCustomMessage(customType: CustomMessageType.meeting,
                                                              data: ["inviterUserID": IMController.shared.uid,
                                                                     "inviterNickname": IMController.shared.currentUserRelay.value?.nickname,
                                                                     "inviterFaceURL": IMController.shared.currentUserRelay.value?.faceURL,
                                                                     "subject": meetingInfo.meetingName,
                                                                     "id": meetingInfo.roomID,
                                                                     "start": meetingInfo.startTime,
                                                                     "duration": meetingInfo.endTime - meetingInfo.startTime])
        IMController.shared.sendMessage(message: message, to: desID, conversationType: conversationType) { r in
            print("result: \(r)")
        }
    }
    
    func endMeeting(onSuccess: @escaping CallBack.StringOptionalReturnVoid, onFailure: @escaping CallBack.ErrorOptionalReturnVoid)  {
        IMController.shared.signalingCloseMeeting(meetingID: self.meetingInfo!.roomID, onSuccess: onSuccess, onFailure: onFailure)
    }
}

class SettingInfo: MeetingInfo {
    
    var hosterName: String?

    var videoCanEnable: Bool {
        return hosterIsSelf || (participantCanEnableVideo == true) && (isMuteAllVideo != true)
    }
    
    var screenShareCanEnable: Bool {
        return hosterIsSelf || onlyHostShareScreen != true
    }
    
    var audioCanEnable: Bool {
        return hosterIsSelf || (participantCanUnmuteSelf == true) && (isMuteAllMicrophone != true)
    }
    
    var enableVideoWhileJoining: Bool {
        return hosterIsSelf || joinDisableVideo != true
    }
    
    var enableAudioWhileJoining: Bool {
        return hosterIsSelf || joinDisableMicrophone != true
    }
    
    var hosterIsSelf: Bool {
        return hostUserID == IMController.shared.uid
    }
    
    var canInvite: Bool {
        var canInvite = true
        if !self.hosterIsSelf {
            canInvite = !(self.onlyHostInviteUser ?? false)
        }
        
        return canInvite
    }
}

extension Participant {
    var metadataMap: [String: Any]? {
        if let metadata = metadata {
            let data = try! JSONSerialization.jsonObject(with: metadata.data(using: .utf8)!, options: .allowFragments) as! [String: Any]
            return data
        }
        return nil
    }
    
    var showName: String? {
        if let data = metadataMap {
            let userInfo = data["userInfo"] as? [String: Any]
            let name = userInfo?["nickname"] as? String
            
            return name
        }
        
        return nil
    }
    
    var faceURL: String? {
        if let data = metadataMap {
            let userInfo = data["userInfo"] as? [String: Any]
            let faceURL = userInfo?["faceURL"] as? String
            
            return faceURL
        }
        
        return nil
    }
    
    var roomMetadataMap: [String: Any]? {
        if let roomMetadata = room.metadata {
            let data = try? (JSONSerialization.jsonObject(with: (roomMetadata.data(using: .utf8))!, options: .mutableContainers) as! [String: Any])
            return data
        }
        
        return nil
    }
    
    var isHoster: Bool {
        if roomMetadataMap != nil {
            if let hostID = roomMetadataMap!["hostUserID"] as? String, hostID == identity {
                return true
            }
        }
        
        return false
    }
    
    var isSelf: Bool {
        return identity == IMController.shared.uid
    }
}
