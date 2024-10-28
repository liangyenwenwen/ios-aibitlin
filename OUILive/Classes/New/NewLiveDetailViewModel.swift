
import OUICore

class NewLiveDetailViewModel {
    
    var meetingInfo: MeetingInfoSetting!
    private let repository = MeetingRepository()
    
    init(meetingInfo: MeetingInfoSetting) {
        self.meetingInfo = meetingInfo
    }
    
    var isMine: Bool {
        meetingInfo.hostUserID == IMController.shared.uid
    }
    
    func getHosterInfo() -> String {
        meetingInfo.creatorNickname
    }
    
    func getDetail(completion: @escaping (() -> Void)) {
        Task {
            let m = await repository.getMeetingInfo(meetingID: meetingInfo.meetingID, userID: IMController.shared.uid)
            
            await MainActor.run {
                meetingInfo = m
                completion()
            }
        }
    }
    
    func joinMeeting(_ completion: @escaping (LiveKit) -> Void, onFailure: @escaping CallBack.ErrorOptionalReturnVoid) {
        Task {
            let result = await repository.joinMeeting(meetingID: meetingInfo.meetingID, userID: IMController.shared.uid)
            
            await MainActor.run {
                if result != nil {
                    completion(result!)
                } else {
                    onFailure(-1, nil)
                }
            }
        }
    }
    
    func sendMeetingMessage(desID: String, conversationType: ConversationType) {

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
    
    func closeRoom(_ completion: @escaping CallBack.StringOptionalReturnVoid) {
        Task {
            let result = await repository.endMeeting(meetingID: meetingInfo!.meetingID, userID: IMController.shared.uid, endType: .cancelType)
            
            await MainActor.run {
                if result {
                    completion("")
                } else {
                }
            }
        }
    }
}
