
import OUICore

class NewLiveDetailViewModel {
    
    private var meetingInfo: MeetingInfo!
    
    init(meetingInfo: MeetingInfo) {
        self.meetingInfo = meetingInfo
    }
    
    
    func getHosterInfo(completion: @escaping ((_ name: String) -> Void)) {
        guard let hostUserID = meetingInfo?.hostUserID else { return }
        IMController.shared.getUserInfo(uids: [hostUserID]) { [weak self] r in
            completion(r.first?.showName ?? "")
        }
    }
    
    func joinMeeting(_ completion: @escaping (InvitationResultInfo) -> Void, onFailure: @escaping CallBack.ErrorOptionalReturnVoid) {
        IMController.shared.signalingJoinMeeting(meetingID: meetingInfo.roomID, participantNickname: IMController.shared.currentUserRelay.value?.nickname){ invitation in
            print("\(invitation)")
            completion(invitation)
        } onFailure: {(errCode, errMsg) in
            onFailure(errCode, errMsg)
        }
    }
    
    func sendMeetingMessage(desID: String, conversationType: ConversationType) {

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
    
    func closeRoom(_ completion: @escaping CallBack.StringOptionalReturnVoid) {
        IMController.shared.signalingCloseMeeting(meetingID: meetingInfo.roomID, onSuccess: completion, onFailure: { (code, msg) in
            
        })
    }
}
