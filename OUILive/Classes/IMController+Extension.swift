
import OUICore
import OpenIMSDK
import RxSwift

public typealias SignalingInfoOptionalReturnVoid = (_ cert: (url: String, token: String, meetingID: String?)?) -> Void

typealias LiveKitOptionalReturnVoid = (LiveKit?) -> Void

extension IMController {
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
    
    public func signalingJoinMeeting(meetingID: String, meetingName: String? = nil, participantNickname: String? = nil, onSuccess: @escaping SignalingInfoOptionalReturnVoid, onFailure: @escaping CallBack.ErrorOptionalReturnVoid) {
        Task {
            guard let result = await MeetingRepository().joinMeeting(meetingID: meetingID, userID: IMController.shared.uid) else {
                await MainActor.run {
                    onFailure(-1, "join meeting error")
                }
                return
            }
            
            await MainActor.run {
                onSuccess((url: result.url, token: result.token, meetingID: meetingID))
            }
        }
    }
}


