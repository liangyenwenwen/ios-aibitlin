
import OUICore
import RxRelay
import RxSwift

#if ENABLE_LIVE_ROOM
import OUILive
#endif

class ForwardListViewModel {
    let isHasReadTableSelected: BehaviorRelay<Bool> = .init(value: true)
    let items: BehaviorRelay<[GroupMemberInfo]> = .init(value: [])
    let hasReadRelay: BehaviorRelay<[GroupMemberInfo]> = .init(value: [])
    let lettersRelay: BehaviorRelay<[String]> = .init(value: [])
    let hasUnReadCountRelay: BehaviorRelay<Int> = .init(value: 0)
    
    private let _disposeBag = DisposeBag()
    private var iHasReadMembers: [GroupMemberInfo] = []
    private var iUnReadMembers: [GroupMemberInfo] = []
    var members: [GroupMemberInfo] = []
    var contactSections: [[GroupMemberInfo]] = []
    
    init() {
        isHasReadTableSelected.subscribe(onNext: { [weak self] (isICreated: Bool) in
            guard let sself = self else { return }
            if isICreated {
                self?.items.accept(sself.iHasReadMembers)
            } else {
                self?.items.accept(sself.iUnReadMembers)
            }
        }).disposed(by: _disposeBag)
    }
    
    func getReadStatusMembers(groupID: String, hasReadIDs: [String]) {
        guard !groupID.isEmpty else {
            return
        }
        
        if !hasReadIDs.isEmpty {
            IMController.shared.getGroupMembersInfo(groupId: groupID, uids: hasReadIDs) { [weak self] membersInfo in
                guard let sself = self else { return }
                sself.hasReadRelay.accept(membersInfo)
                sself.iHasReadMembers = membersInfo
                sself.isHasReadTableSelected.accept(true)
            }
        }
        
        IMController.shared.getGroupInfo(groupIds: [groupID]) { [weak self] infos in
            guard let sself = self, let count = infos.first?.memberCount else { return }
            // 将已读 和 发送者 排除
            sself.hasUnReadCountRelay.accept(count - hasReadIDs.count - 1)
        }
        
        IMController.shared.getGroupMemberList(groupId: groupID, offset: 0, count: 10000) { [weak self] groupMembers in
            
            guard let sself = self else { return }
            let ms: [GroupMemberInfo] = groupMembers ?? []
            var unReadMembers: [GroupMemberInfo] = []
            // 将已读 和 发送者 排除
            for item in ms {
                if !hasReadIDs.contains(item.userID!), item.userID != IMController.shared.uid {
                    unReadMembers.append(item)
                }
            }
            sself.iUnReadMembers = unReadMembers
        }
    }
    
    func getUsersAt(indexPaths: [IndexPath]) -> [UserInfo] {
        var users: [UserInfo] = []
        for indexPath in indexPaths {
            let member = contactSections[indexPath.section][indexPath.row]
            let user = UserInfo(userID: member.userID!, nickname: member.nickname, faceURL: member.faceURL)
            
            users.append(user)
        }
        return users
    }
    
    private func divideUsersInSection(users: [GroupMemberInfo]) {
        DispatchQueue.global().async { [weak self] in
            var letterSet: Set<String> = []
            for user in users {
                if let firstLetter = user.nickname?.getFirstPinyinUppercaseCharactor() {
                    letterSet.insert(firstLetter)
                }
            }
            
            let letterArr: [String] = Array(letterSet)
            let ret = letterArr.sorted { $0 < $1 }
            
            for letter in ret {
                var sectionArr: [GroupMemberInfo] = []
                for user in users {
                    if let first = user.nickname?.getFirstPinyinUppercaseCharactor(), first == letter {
                        sectionArr.append(user)
                    }
                }
                self?.contactSections.append(sectionArr)
            }
            DispatchQueue.main.async {
                self?.lettersRelay.accept(ret)
            }
        }
    }
    
#if ENABLE_LIVE_ROOM
    func joinMeeting(meetingID: String, onSuccess: @escaping SignalingInfoOptionalReturnVoid, onFailure: @escaping CallBack.ErrorOptionalReturnVoid) {
        IMController.shared.signalingJoinMeeting(meetingID: meetingID, participantNickname: IMController.shared.currentUserRelay.value?.nickname, onSuccess: onSuccess, onFailure: onFailure)
    }
#endif
}
