
import OUICore
import RxSwift
import RxRelay
#if ENABLE_ORGANIZATION
import OUIOrganization
#endif

class UserDetailViewModel {
    let userId: String
    let groupId: String?
    let groupInfo: GroupInfo?
    
    let userInfoRelay: BehaviorSubject<FriendInfo?> = .init(value: nil)
    var memberInfoRelay: BehaviorRelay<GroupMemberInfo?> = .init(value: nil)
    var allowAddFriend: BehaviorSubject<Bool> = .init(value: false)
    var showSetAdmin: Bool = false
    var showJoinSource: Bool = false
    var showMute: Bool = false
    var allowSendMsg: PublishRelay<Bool> = .init()
    var userDetailFor = UserDetailFor.groupMemberInfo
#if ENABLE_ORGANIZATION
    var companyName: String?
    var organizationInfo: BehaviorRelay<[UserInDepartmentInfo]> = .init(value: [])
#endif
    
    var isMine: Bool {
        userId == IMController.shared.uid || groupInfo?.ownerUserID == IMController.shared.uid
    }
    
    private let _disposeBag = DisposeBag()
    init(userId: String, groupId: String? = nil, groupInfo: GroupInfo? = nil, groupMemberInfo: GroupMemberInfo? = nil, userInfo: PublicUserInfo? = nil, userDetailFor: UserDetailFor) {
        self.userId = userId
        self.groupId = groupId
        self.groupInfo = groupInfo
        self.userDetailFor = userDetailFor
        if let userInfo {
            self.userInfoRelay.onNext(FriendInfo(userID: userInfo.userID, nickname: userInfo.nickname, faceURL: userInfo.faceURL))
        }
        if let groupMemberInfo {
            self.memberInfoRelay.accept(groupMemberInfo)
        }
        
        IMController.shared.friendInfoChangedSubject.subscribe { [weak self] (friendInfo: FriendInfo?) in
            guard let self else { return }
            guard friendInfo?.userID == userId else { return }
            
            userInfoRelay.onNext(friendInfo)
        }.disposed(by: _disposeBag)
    }
    
    func getUserOrMemberInfo() {
        let group = DispatchGroup()
        var memberInfo: GroupMemberInfo?
#if ENABLE_ORGANIZATION
        var orgInfo: [UserInDepartmentInfo] = []
#endif
        
        if let groupId = groupId, !groupId.isEmpty, userDetailFor == .groupMemberInfo {
            group.enter()
            // 如果群聊点击的是自己
            var isSelf = IMController.shared.uid == userId
            IMController.shared.getGroupMembersInfo(groupId: groupId,
                                                    uids: isSelf ? [userId] : [IMController.shared.uid, userId]) { [weak self] (members: [GroupMemberInfo]) in
                guard let mine = members.first(where: { $0.userID == IMController.shared.uid}), let sself = self else {
                    group.leave()
                    return
                }
                memberInfo = members.first(where: { $0.userID == sself.userId})
                
                if !isSelf {
                    if mine.roleLevel == .owner {
                        sself.showMute = true
                        sself.showSetAdmin = true
                        sself.showJoinSource = true
                    } else if mine.roleLevel == .admin {
                        sself.showMute = true
                        sself.showJoinSource = true
                    }
                    //                    IMController.shared.getUserInfo(uids: [memberInfo!.inviterUserID!], groupID: groupId) { users in
                    //                        memberInfo!.inviterUserName = users.first?.showName
                    group.leave()
                    //                    }
                } else {
                    group.leave()
                }
            }
        }
        
#if ENABLE_ORGANIZATION
        group.enter()
        OUIOrganization.Repository.queryDepartment() { [weak self] (r: DepartmentInfo?) in
            if let r = r {
                self?.companyName = r.name
            }
            group.leave()
        }
        
        group.enter()
        OUIOrganization.Repository.queryUserInDepartment(userID: userId) { [weak self] r in
            if let r = r {
                orgInfo.append(contentsOf: r)
            }
            group.leave()
        }
#endif
        group.notify(queue: .main) { [weak self] in
            self?.memberInfoRelay.accept(memberInfo)
#if ENABLE_ORGANIZATION
            self?.organizationInfo.accept(orgInfo)
#endif
        }
        
        getOtherSetting()
    }
    
    func getOtherSetting() {
        IMController.shared.getUserInfo(uids: [userId], groupID: groupId) { [self] users in
            guard let sdkUser = users.first else { return }
//            userInfoRelay.onNext(sdkUser as! FriendInfo)
            UserCacheManager.shared.addOrUpdateUserInfo(userID: userId, userInfo: UserInfo(userID: sdkUser.userID!, nickname: sdkUser.nickname, faceURL: sdkUser.faceURL))
            
            IMController.shared.getFriendsInfo(userIDs: [userId]) { friendInfo in
                
                let isFriend = friendInfo != nil
                
                if let handler = OIMApi.queryUsersInfoWithCompletionHandler, userId != IMController.shared.uid {
                    handler([userId], { [weak self] users in
                        guard let self else { return }
                        
                        if let chatUser = users.first {
                            UserCacheManager.shared.addOrUpdateUserInfo(userID: userId, userInfo: chatUser)
                            
                            var chatAllowAddFriend = chatUser.allowAddFriend == 1 && !isFriend
                            var groupAllowAddFriend = true
                            
                            // Personal setting level is higher
                            if let groupInfo = groupInfo {
                                groupAllowAddFriend = groupInfo.applyMemberFriend == 0
                            }
                            
                            let allow = chatAllowAddFriend && groupAllowAddFriend
                            
                            allowAddFriend.onNext(allow)
                        }
                    })
                }
                
                guard !isFriend else {
                    allowSendMsg.accept(true)
                    
                    return
                }
                
                if let configHandler = OIMApi.queryConfigHandler {
                    
                    configHandler { [weak self] code, result in
                        guard let self else { return }
                        
                        if !result.isEmpty {
                            if let allowSendMsgNotFriend = result["allowSendMsgNotFriend"] as? String {
                                let allowedStranger = Int(allowSendMsgNotFriend) == 1 && userId != IMController.shared.uid
                                
                                allowSendMsg.accept(isFriend || allowedStranger)
                            }
                        } else {
                            allowSendMsg.accept(true)
                        }
                    }
                }
            }
        }
    }
    
    func createSingleChat(onComplete: @escaping (ConversationInfo) -> Void) {
        IMController.shared.getConversation(sessionType: .c2c, sourceId: userId) { [weak self] (conversation: ConversationInfo?) in
            guard let conversation else { return }
            
            onComplete(conversation)
        }
    }
    
    func addFriend(onSuccess: @escaping CallBack.StringOptionalReturnVoid, onFailure: @escaping CallBack.ErrorOptionalReturnVoid) {
        let reqMsg = "\(IMController.shared.currentUserRelay.value!.nickname!)请求添加你为好友"
        IMController.shared.addFriend(uid: userId, reqMsg: reqMsg, onSuccess: onSuccess, onFailure: onFailure)
    }
    
    func toggleSetAdmin(toAdmin: Bool, onSuccess: @escaping CallBack.StringOptionalReturnVoid) {
        IMController.shared.setGroupMemberRoleLevel(groupId: groupId!, userID: userId, roleLevel: toAdmin ? .admin : .member, onSuccess: onSuccess)
    }
    
    func setMutedSeconds(seconds: Int, acceptValue: Bool = true, onSuccess: @escaping CallBack.StringOptionalReturnVoid) {
        guard let groupId = groupId else {
            return
        }
        
        IMController.shared.changeGroupMemberMute(groupID: groupId, userID: userId, seconds: seconds) { [weak self] r in
            
            guard let sself = self else { return }
            if acceptValue {
                var info = sself.memberInfoRelay.value!
                info.muteEndTime = (NSDate().timeIntervalSince1970 + Double(seconds)) * 1000
                sself.memberInfoRelay.accept(info)
            }
            onSuccess(r)
        }
    }
    deinit {
#if DEBUG
        print("dealloc \(type(of: self))")
#endif
    }
}

struct UserCacheManager {
    static var shared = UserCacheManager()
    var _userInfoMap: [String: UserInfo] = [:]
    
    mutating func addOrUpdateUserInfo(userID: String, userInfo: UserInfo) {
      _userInfoMap[userID] = userInfo
    }

    func getUserInfo(userID: String) -> UserInfo? {
      return _userInfoMap[userID]
    }

    mutating func removeUserInfo(userID: String) {
      _userInfoMap.removeValue(forKey: userID)
    }
}
