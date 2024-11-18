
import OUICore
import RxSwift
import RxRelay

enum EmptyType {
    case beDeleted // has been deleted
    case none // unpublished
}

class MomentsViewModel {
    let momentsChangedRelay: PublishSubject<MomentsInfo> = .init()
    let momentsRelay: BehaviorRelay<[MomentsInfo]> = .init(value: [])
    let splitByYearMomentsRelay: BehaviorRelay<[[MomentsInfo]]> = .init(value: [])
    let userInfoRelay: BehaviorRelay<HeaderInfo?> = .init(value: nil)
    
    var pageCount: Int = 10
    var pageNumber: Int = 1
    let userID: String?
    let momentID: String?
        
    var emptyType: EmptyType?
    
    var forDetail: Bool {
        return momentID != nil
    }
    
    init(userID: String? = nil, momentID: String? = nil, moments: MomentsInfo? = nil) {
        self.userID = userID
        self.momentID = momentID
        
        addObservers()
        
        if let moments {
            momentsRelay.accept([moments])
        }
    }
    
    private let dataProvider = OUIMoments.DefaultDataProvider()
    
    private func addObservers() {
        dataProvider.onRecvNewMomentsChanged = { [weak self] (count, msg) in
            guard let self else { return }
            if var userInfo = userInfoRelay.value {
                userInfo.newMsgCount = count
                userInfoRelay.accept(userInfo)
            }
            
            momentsChangedRelay.onNext(msg)
        }
    }
    
    func loadUserInfo() {
        if forDetail {
            // If you are viewing details, the header is not displayed
            return
        }
        var headerInfo = HeaderInfo(userID: "", userName: "")
        
        if userID == nil {
            // Load your circle of friends
            headerInfo.userID = IMController.shared.currentUserRelay.value?.userID ?? ""
            headerInfo.userName = IMController.shared.currentUserRelay.value?.nickname ?? ""
            headerInfo.faceURL = IMController.shared.currentUserRelay.value?.faceURL
            userInfoRelay.accept(headerInfo)
            loadUnreadCount()
        } else {
            // Load other people's circle of friends
            IMController.shared.getUserInfo(uids: [userID!]) { [weak self] users in
                guard let user = users.first else { return }
                headerInfo.userID = user.userID ?? ""
                headerInfo.userName = user.nickname ?? ""
                headerInfo.faceURL = user.faceURL
                
                self?.userInfoRelay.accept(headerInfo)
            }
        }
    }
    
    func loadUnreadCount() {
        dataProvider.queryUnreadCount { [weak self] count in
            guard let self else {return}
            var value = self.userInfoRelay.value
            value?.newMsgCount = count
            userInfoRelay.accept(value)
        }
    }
    
    func loadMoments(loadMore: Bool = false, split: Bool = false) {
        if let momentID = momentID {
            // If it is to obtain a single detail
            loadMomentsDetail(momentID: momentID) { [weak self] info in
                if let info = info, !info.workMomentID.isEmpty {
                    self?.momentsRelay.accept([info])
                } else {
                    // If the circle of friends is deleted
                    self?.emptyType = .beDeleted
                    self?.momentsRelay.accept([])
                }
            }
        } else {
            pageNumber = loadMore ? pageNumber + 1 : 1
            
            dataProvider.loadMoments(userID: userID, pageNumber: pageNumber, pageCount: pageCount) { [weak self] code, m in
                guard let self else { return }
                
                if let m, !m.isEmpty {
                    if split {
                        self.splitByYearMomentsRelay.accept(self.splitByYear(moments: m))
                    } else {
                        self.momentsRelay.accept(m)
                    }
                    self.pageNumber += 1
                } else {
                    if pageNumber == 1 {
                        emptyType == .none
                    }
                    if split {
                        let temp = splitByYearMomentsRelay.value
                        self.splitByYearMomentsRelay.accept(temp)
                    } else {
                        let temp = momentsRelay.value
                        self.momentsRelay.accept(temp)
                    }
                }
            }
        }
    }
    
    private func splitByYear(moments: [MomentsInfo]) -> [[MomentsInfo]] {
        moments.reduce(into: [[MomentsInfo]]()) { result, moment in
            guard var section = result.last,
                  let prevMoment = section.last else {
                let section = [moment]
                result.append(section)
                return
            }
            let prevDate = Date(timeIntervalSince1970: TimeInterval(prevMoment.createTime / 1000))
            let date = Date(timeIntervalSince1970: TimeInterval(moment.createTime / 1000))
            
            if Calendar.current.isDate(prevDate, equalTo: date, toGranularity: .year) {
                section.append(moment)
                result[result.count - 1] = section
            } else {
                let section = [moment]
                result.append(section)
            }
        }
    }
    
    func loadMomentsDetail(momentID: String, completion: @escaping ( MomentsInfo?) -> Void) {
        dataProvider.loadMomentsDetail(momentID: momentID) { code, info in
            completion(info)
        }
    }
    
    func favor(momentID: String, like: Bool, completion: @escaping (MomentsInfo?) -> Void) {
        dataProvider.favor(momentID: momentID, like: like) { [weak self] success in
            if success {
                self?.dataProvider.loadMomentsDetail(momentID: momentID) { code, info in
                    completion(info)
                }
            }
        }
    }
    
    func comment(momentID: String, replyUserID: String?, text: String, completion: @escaping (MomentsInfo?) -> Void) {
        dataProvider.comment(momentID: momentID, replyUserID: replyUserID, text: text) { [weak self] success in
            self?.dataProvider.loadMomentsDetail(momentID: momentID) { code, info in
                completion(info)
            }
        }
    }
    
    func delete(momentID: String, completion: @escaping (_ success: Bool) -> Void) {
        dataProvider.delete(momentID: momentID, commentID: nil, completion: completion)
    }
    
    func deleteComment(momentID: String, commentID: String, completion: @escaping (MomentsInfo?) -> Void) {
        dataProvider.delete(momentID: momentID, commentID: commentID) { [weak self] success in
            if success {
                self?.dataProvider.loadMomentsDetail(momentID: momentID) { code, info in
                    completion(info)
                }
            }
        }
    }
}
