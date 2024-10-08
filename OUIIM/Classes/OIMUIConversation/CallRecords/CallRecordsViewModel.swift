
import OUICore
import RxRelay
import RxSwift

#if ENABLE_CALL
import OUICalling
#endif

#if ENABLE_LIVE_ROOM
import OUILive
#endif

class CallRecordsViewModel {
    
    #if ENABLE_CALL
    // 0 所有通话 1 未接通话 2 未结束会议
    let tabSelected: BehaviorRelay<Int> = .init(value: 0)
    let items: BehaviorRelay<[Any]> = .init(value: [])
    let allRecordsRelay: BehaviorRelay<[CallRecord]> = .init(value: [])

    private let _disposeBag = DisposeBag()
    private var allRecords: [CallRecord] = []
    private var missedRecords: [CallRecord] = []
    private var missedMeetingRecords: [MeetingInfo] = []
    init() {
        tabSelected.subscribe(onNext: { [weak self] (index: Int) in
            guard let sself = self else { return }
            if index == 0 {
                self?.items.accept(sself.allRecords)
            } else if index == 1 {
                self?.items.accept(sself.missedRecords)
            } else {
                self?.items.accept(sself.missedMeetingRecords)
            }
        }).disposed(by: _disposeBag)
    }

    func getRecords() {
        allRecords = CallingManager.getRecords()
        getMeetings()
        missedRecords = allRecords.filter { $0.success == false}
        allRecordsRelay.accept(allRecords)
        tabSelected.accept(0)
        
    
    }
    
    func getMeetings() {
        IMController.shared.signalingGetMeetings { [weak self] r in
            guard let `self` = self else { return }
            self.missedMeetingRecords = r
        }
    }
    
    func joinMeeting(meetingID: String, onSuccess: @escaping SignalingInfoOptionalReturnVoid, onFailure: @escaping CallBack.ErrorOptionalReturnVoid) {
        IMController.shared.signalingJoinMeeting(meetingID: meetingID, onSuccess: onSuccess, onFailure: onFailure)
    }
    #endif
}
