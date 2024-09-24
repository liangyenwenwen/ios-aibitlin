
import OUICore

class NewLiveViewModel {
    var meetingID: String?
    var name: String = ""
    var beginTime: Double = 0
    var duration: Double = 0
    
    func createMeeting(_ completion: @escaping (InvitationResultInfo) -> Void, onFailure: @escaping CallBack.ErrorOptionalReturnVoid) {
        IMController.shared.signalingCreateMeeting(name: name.trimmingCharacters(in: .whitespacesAndNewlines), startTime: beginTime, duration: duration) { r in
            print("\(r)")
            completion(r)
        } onFailure: { (errCode, errMsg) in
            onFailure(errCode, errMsg)
        }
    }
    
    func joinMeeting(_ completion: @escaping (InvitationResultInfo) -> Void, onFailure: @escaping CallBack.ErrorOptionalReturnVoid) {
        IMController.shared.signalingJoinMeeting(meetingID: meetingID!, participantNickname: name.trimmingCharacters(in: .whitespacesAndNewlines)){ invitation in
            print("\(invitation)")
            completion(invitation)
        } onFailure: {(errCode, errMsg) in
            onFailure(errCode, errMsg)
        }
    }
    
    func updateMeetingInfo(meetingInfo: MeetingInfo, completion: @escaping (MeetingInfo?) -> Void) {
        meetingInfo.meetingName = name
        meetingInfo.startTime = beginTime
        meetingInfo.endTime = beginTime + duration
        let j = JsonTool.toMap(fromObject: meetingInfo)
        print("updateMeetingInfo: \(j)")
        IMController.shared.signalingUpdateMeetingInfo(meetingID: meetingInfo.roomID, param: j) { r in
            print("result: \(r)")
            completion(meetingInfo)
        }
    }
}
