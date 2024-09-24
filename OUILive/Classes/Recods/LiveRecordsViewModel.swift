
import OUICore
import RxRelay
import RxSwift
import OUICalling

class LiveRecordsViewModel {
    let items: BehaviorRelay<[MeetingInfo]> = .init(value: [])
    private let _disposeBag = DisposeBag()

    func getRecords() {
        IMController.shared.signalingGetMeetings { [weak self] r in
            guard let `self` = self else { return }
            let uids = r.map{ $0.hostUserID! }
            IMController.shared.getUserInfo(uids: uids) { users in
                for (index, item) in r.enumerated() {
                    item.hostUserName = users.first(where: {$0.userID == item.hostUserID})?.showName
                }
                self.items.accept(r.sorted(by: { $0.startTime > $1.startTime }))
            }
        }
    }
    
    func createMeeting(completion: @escaping SignalingInfoOptionalReturnVoid) {
        var name = IMController.shared.currentUserRelay.value!.nickname! + "发起的视频会议"
        IMController.shared.signalingCreateMeeting(name: name, startTime: Date().timeIntervalSince1970, duration: 3600) { r in
            completion(r)
        } onFailure: { errCode, errMsg in
        }
    }
    
    func joinMeeting(meetingID: String, onSuccess: @escaping SignalingInfoOptionalReturnVoid, onFailure: @escaping CallBack.ErrorOptionalReturnVoid) {
        IMController.shared.signalingJoinMeeting(meetingID: meetingID, onSuccess: onSuccess, onFailure: onFailure)
    }
}
