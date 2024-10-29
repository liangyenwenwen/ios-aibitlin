
import OUICore
import LiveKitClient
import RxSwift
import RxRelay

class LiveRoomViewModel {
    
    var invitationSingling: LiveKit
    var meetingInfo: MeetingInfoSetting?
    let disposeBag = DisposeBag()
    //    let meetingStreamChangeRelay: BehaviorRelay<MeetingStreamEvent?> = .init(value: nil)
    let kickedOffline: PublishSubject<Bool> = .init()
    
    private let repository = MeetingRepository()
    
    init(invitationSingling: LiveKit) {
        self.invitationSingling = invitationSingling
        
        //        IMController.shared.meetingStreamChange.subscribe(onNext: { [weak self] event in
        //            if event.roomID == self?.meetingInfo?.roomID {
        //                self?.meetingStreamChangeRelay.accept(event)
        //            }
        //        }).disposed(by: disposeBag)
        
        IMController.shared.connectionRelay.subscribe(onNext: { [self] status in
            if status == .kickedOffline {
                kickedOffline.onNext(true)
            }
        }).disposed(by: disposeBag)
    }
    
    func closeRoom(_ completion: @escaping CallBack.StringOptionalReturnVoid) {
        Task {
            await repository.endMeeting(meetingID: meetingInfo!.meetingID, userID: IMController.shared.uid)
            
            await MainActor.run {
                completion("")
            }
        }
    }
    
    func getHosterInfo() {
        meetingInfo?.creatorNickname
    }
    
    func updateUserInfo(userID: String, streamType: String? = nil, mute: Bool = true, muteAll: Bool = false, onCompletion:((Bool) -> Void)? = nil) {
        Task {
            var setting = PersonalMeetingSetting()
            
            if streamType == "audio" {
                setting.microphoneOnEntry = !mute
            } else {
                setting.cameraOnEntry = !mute
            }
            
            let result = await repository.setPersonalSetting(meetingID: meetingInfo!.meetingID, userID: userID, setting: setting)
            
            await MainActor.run {
                onCompletion?(result)
            }
        }
    }
    
    func sendMeetingMessage(desID: String, conversationType: ConversationType) {
        guard let meetingInfo = meetingInfo else { return }
        let message = IMController.shared.createCustomMessage(customType: CustomMessageType.meeting,
                                                              data: ["inviterUserID": IMController.shared.uid,
                                                                     "inviterNickname": IMController.shared.currentUserRelay.value?.nickname,
                                                                     "inviterFaceURL": IMController.shared.currentUserRelay.value?.faceURL,
                                                                     "subject": meetingInfo.meetingName,
                                                                     "id": meetingInfo.meetingID,
                                                                     "start": meetingInfo.scheduledTime,
                                                                     "duration": meetingInfo.duration])
        IMController.shared.sendMessage(message: message, to: desID, conversationType: conversationType) { r in
            print("result: \(r)")
        }
    }
    
    func leaveMeeting(onSuccess: @escaping CallBack.StringOptionalReturnVoid, onFailure: @escaping CallBack.ErrorOptionalReturnVoid)  {
        Task {
            let result = await repository.leaveMeeting(meetingID: meetingInfo!.meetingID, userID: IMController.shared.uid)
            
            await MainActor.run {
                if result {
                    onSuccess("")
                } else {
                    onFailure(-1, "leave error")
                }
            }
        }
    }
    
    func endMeeting(onSuccess: @escaping CallBack.StringOptionalReturnVoid, onFailure: @escaping CallBack.ErrorOptionalReturnVoid)  {
        Task {
            let result = await repository.endMeeting(meetingID: meetingInfo!.meetingID, userID: IMController.shared.uid)
            
            await MainActor.run {
                if result {
                    onSuccess("")
                } else {
                    onFailure(-1, "leave error")
                }
            }
        }
    }
    
    func updateMeetingInfo(info: MeetingSetting) async -> Bool {
        
        var update = UpdateMeetingRequest()
        update.meetingID = meetingInfo!.meetingID
        update.canParticipantsEnableCamera = info.canParticipantsEnableCamera
        update.canParticipantsUnmuteMicrophone = info.canParticipantsUnmuteMicrophone
        update.canParticipantsShareScreen = info.canParticipantsShareScreen
        update.disableMicrophoneOnJoin = info.disableMicrophoneOnJoin
        update.disableCameraOnJoin = info.disableCameraOnJoin
        
        return await repository.updateMeetingSetting(req: update)
    }
    
    func operateAllStream(microphoneOnEntry: Bool) async -> Bool {
        await repository.operateAllStream(meetingID: meetingInfo!.meetingID, operatorUserID: IMController.shared.uid, cameraOnEntry: nil, microphoneOnEntry: microphoneOnEntry)
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
    
    var isSelf: Bool {
        identityString == IMController.shared.uid
    }
}
