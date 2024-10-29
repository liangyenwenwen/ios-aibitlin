
import OUICore
import RxRelay
import RxSwift
import OUICalling
import Alamofire

class LiveRecordsViewModel {
    let items: BehaviorRelay<[MeetingInfoSetting]> = .init(value: [])
    private let _disposeBag = DisposeBag()
    private let repository = MeetingRepository()

    func getRecords() {
        Task {
            let result = await repository.getMeetings(userID: IMController.shared.uid)
            
            await MainActor.run {
                items.accept(result.sorted(by: { $0.scheduledTime > $1.scheduledTime }))
            }
        }
    }
    
    func createMeeting(completion: @escaping LiveKitOptionalReturnVoid) {
        Task {
            var name = IMController.shared.currentUserRelay.value!.nickname! + "发起的视频会议"
            
            var creatInfo = CreatorDefinedMeetingInfo()
            creatInfo.title = name
            creatInfo.scheduledTime = Int64(Date().timeIntervalSince1970)
            creatInfo.meetingDuration = 3600
            creatInfo.password = ""
            
            let result = await repository.createMeeting(type: .quick, creatorUserID: IMController.shared.uid, creatorDefinedMeetingInfo: creatInfo)
            
            await MainActor.run {
                completion(result.cert)
            }
        }
    }
    
    func joinMeeting(meetingID: String, onSuccess: @escaping LiveKitOptionalReturnVoid, onFailure: @escaping CallBack.ErrorOptionalReturnVoid) {
        
        Task {
            let result = await repository.joinMeeting(meetingID: meetingID, userID: IMController.shared.uid)
            
            await MainActor.run {
                if result != nil {
                    onSuccess(result!)
                } else {
                    onFailure(-1, nil)
                }
            }
        }
    }
}
