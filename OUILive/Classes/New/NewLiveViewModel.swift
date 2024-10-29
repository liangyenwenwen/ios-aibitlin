
import OUICore

class NewLiveViewModel {
    var meetingID: String?
    var name: String = ""
    var beginTime: Double = 0
    var duration: Double = 0
    private let repository = MeetingRepository()
    
    func createMeeting(_ completion: @escaping () -> Void, onFailure: @escaping CallBack.ErrorOptionalReturnVoid) {
        Task {
            let name = !name.isEmpty ? name : "meetingInitiatorIs".innerLocalizedFormat(arguments: IMController.shared.currentUserRelay.value!.nickname!)
            
            var creatInfo = CreatorDefinedMeetingInfo()
            creatInfo.title = name
            creatInfo.scheduledTime = Int64(beginTime)
            creatInfo.meetingDuration = Int64(duration)
            creatInfo.password = ""
            
            let result = await repository.createMeeting(type: .booking, creatorUserID: IMController.shared.uid, creatorDefinedMeetingInfo: creatInfo)
            
            await MainActor.run {
                if result.info != nil {
                    completion()
                } else {
                    onFailure(-1, "create meeting throw an error")
                }
            }
        }
    }
    
    func joinMeeting(_ completion: @escaping (LiveKit) -> Void) {
        Task {
            let result = await repository.joinMeeting(meetingID: meetingID!, userID: IMController.shared.uid)
            
            await MainActor.run {
                if (result != nil) {
                    completion(result!)
                }
            }
        }
    }
    
    func updateMeetingInfo(completion: @escaping () -> Void) {
        Task {
            var update = UpdateMeetingRequest()
            update.title = name
            update.scheduledTime = Int64(beginTime)
            update.meetingDuration = Int64(duration)
            update.meetingID = meetingID!
            update.updatingUserID = IMController.shared.uid
            
            let result = await repository.updateMeetingSetting(req: update)
            
            await MainActor.run {
                completion()
            }
        }
    }
}
