
import OUICore
import RxCocoa
import RxSwift

class GroupChatSettingViewModel {
    private let _disposeBag = DisposeBag()
    private(set) var conversation: ConversationInfo

    let membersRelay: BehaviorRelay<[GroupMemberInfo]> = .init(value: [])
    let membersCountRelay: BehaviorRelay<Int> = .init(value: 0)
    let noDisturbRelay: BehaviorRelay<Bool> = .init(value: false)
    let setTopContactRelay: BehaviorRelay<Bool> = .init(value: false)
    var groupInfoRelay: BehaviorRelay<GroupInfo?> = .init(value: nil)
    let myInfoInGroup: BehaviorRelay<GroupMemberInfo?> = .init(value: nil)
    let mutedAllRelay: BehaviorRelay<Bool> = .init(value: false)
    let canViewProfileRelay: BehaviorRelay<Bool> = .init(value: false)
    let canAddFriendRelay: BehaviorRelay<Bool> = .init(value: false)
    let regularlyDeleteRelay: BehaviorRelay<Bool> = .init(value: false)
    let regularlyDurationRelay: BehaviorRelay<Double> = .init(value: 1)
    let isInGroupRelay: BehaviorRelay<Bool> = .init(value: true)

    private(set) var allMembers: [String] = []
    private(set) var superAndAdmins: [GroupMemberInfo] = []
    
    init(conversation: ConversationInfo, groupInfo: GroupInfo? = nil) {
        self.conversation = conversation
        if let groupInfo {
            groupInfoRelay.accept(groupInfo)
        }
        let defaultUserInfo = GroupMemberInfo()
        defaultUserInfo.userID = IMController.shared.currentUserRelay.value?.userID
        defaultUserInfo.nickname = IMController.shared.currentUserRelay.value?.nickname
        myInfoInGroup.accept(defaultUserInfo)
        
        if groupInfo != nil {
            groupInfoRelay.accept(groupInfo)
        } else {
            isInGroupRelay.accept(false)
        }
        
        IMController.shared.groupMemberInfoChange.subscribe(onNext: { [weak self] info in
            guard let self else { return }
            getConversationInfo()
        }).disposed(by: _disposeBag)
        
        IMController.shared.groupMemberAdded.subscribe(onNext: { [weak self] info in
            // groupInfo.groupID 即为邀请你的群
            guard let self, conversation.groupID == info?.groupID else { return }
            queryMembers(groupID: conversation.groupID!) {
            }
            queryMyInfoInGroup()
            isInGroupRelay.accept(true)
        }).disposed(by: _disposeBag)
        
        IMController.shared.groupMemberDeleted.subscribe(onNext: { [weak self] info in
            // groupInfo.groupID 即为踢出你的群
            guard let self, conversation.groupID == info?.groupID else { return }
            queryMembers(groupID: conversation.groupID!) {
            }

        }).disposed(by: _disposeBag)
        
        IMController.shared.joinedGroupAdded.subscribe(onNext: { [weak self] info in
            guard let self, conversation.groupID == info?.groupID else { return }
            queryMembers(groupID: conversation.groupID!) {
            }
            queryMyInfoInGroup()
            isInGroupRelay.accept(true)
        }).disposed(by: _disposeBag)
        
        IMController.shared.joinedGroupDeleted.subscribe(onNext: { [weak self] info in
            guard let self, conversation.groupID == info?.groupID else { return }
            
            isInGroupRelay.accept(false)
        }).disposed(by: _disposeBag)
        
        IMController.shared.groupInfoChangedSubject.subscribe { [weak self] groupInfo in
            guard let self else { return }
            getConversationInfo()
            
        }.disposed(by: _disposeBag)
    }

    private func publishConversationInfo() {
        noDisturbRelay.accept(conversation.recvMsgOpt != .receive)
        setTopContactRelay.accept(conversation.isPinned)
        regularlyDurationRelay.accept(conversation.msgDestructTime)
        regularlyDeleteRelay.accept(conversation.isMsgDestruct)
    }
    
    func getConversationInfo() {
        if let groupInfo = groupInfoRelay.value {
            
            getGroupInfoHelper(groupInfo: groupInfo)
        } else {
            guard let gid = conversation.groupID else { return }

            IMController.shared.getGroupInfo(groupIds: [gid]) { [weak self] (groupInfos: [GroupInfo]) in
                guard let self else { return }
                guard let groupInfo = groupInfos.first else { return }
                
                getGroupInfoHelper(groupInfo: groupInfo)
            }
        }
        
        queryMyInfoInGroup()
    }
    
    private func getGroupInfoHelper(groupInfo: GroupInfo) {
        membersCountRelay.accept(groupInfo.memberCount)
        mutedAllRelay.accept(groupInfo.status == .muted)
        canAddFriendRelay.accept((groupInfo.applyMemberFriend != 0))
        canViewProfileRelay.accept((groupInfo.lookMemberInfo != 0))
        
        IMController.shared.isJoinedGroup(groupID: groupInfo.groupID) { [self] isIn in
            
            self.isInGroupRelay.accept(isIn)
            
            if isIn {
                self.queryMembers(groupID: groupInfo.groupID) { [self] in
                    self.groupInfoRelay.accept(groupInfo)
                    self.publishConversationInfo()
                }
            } else {
                self.publishConversationInfo()
            }
        }
    }
    
    private func queryMyInfoInGroup() {
        guard let gid = conversation.groupID else { return }

        IMController.shared.getGroupMembersInfo(groupId: gid, uids: [IMController.shared.uid]) { [weak self] (members: [GroupMemberInfo]) in
            for member in members {
                if member.isSelf {
                    member.nickname = member.nickname ?? IMController.shared.currentUserRelay.value?.nickname
                    self?.myInfoInGroup.accept(member)
                }
            }
        }
    }
    
    // MARK: -   获取群成员
    private func queryMembers(groupID: String, endHandler: @escaping () -> Void) {
        
        let group = DispatchGroup()
        var displayMembers: [GroupMemberInfo] = []
        
        group.enter()
        IMController.shared.getGroupMemberList(groupId: groupID, filter: .superAndAdmin, offset: 0, count: 10) { [self] ms in
            superAndAdmins = ms
            group.leave()
        }
        
        group.enter()
        IMController.shared.getGroupMemberList(groupId: groupID, filter: .member, offset: 0, count: 10) { [self] ms in
            displayMembers = ms
            group.leave()
        }
        
        group.notify(queue: .main) { [self] in
            
            var users: [GroupMemberInfo] = []
            
            let fakeUser = GroupMemberInfo()
            fakeUser.isAddButton = true
            fakeUser.nickname = "增加".innerLocalized()
            users.append(fakeUser)
            
            if let isSuperAndAdmin = superAndAdmins.first(where: { $0.userID == IMController.shared.uid }) {
                let fakeUser2 = GroupMemberInfo()
                fakeUser2.isRemoveButton = true
                fakeUser2.nickname = "remove".innerLocalized()
                users.append(fakeUser2)
            }
            
            let tempUsers = (superAndAdmins + displayMembers).prefix(10 - users.count)
            users.insert(contentsOf: Array(tempUsers), at: 0)
            
            membersRelay.accept(users)
            endHandler()
        }
        
        IMController.shared.getGroupMemberList(groupId: groupID, filter: .all, offset: 0, count: 100000) { [self] ms in
            allMembers = ms.compactMap({ $0.userID })
        }
    }

    func updateGroupName(_ name: String, onSuccess: @escaping CallBack.StringOptionalReturnVoid) {
        guard let group = groupInfoRelay.value else { return }
        group.groupName = name
        IMController.shared.setGroupInfo(group: group) { [weak self] resp in
            self?.groupInfoRelay.accept(group)
            onSuccess(resp)
        }
    }

    func clearRecord(completion: @escaping CallBack.StringOptionalReturnVoid) {
        guard let groupID = conversation.groupID else { return }
        IMController.shared.clearGroupHistoryMessages(conversationID: conversation.conversationID) { [weak self] resp in
            guard let sself = self else { return }
            let event = EventRecordClear(conversationId: sself.conversation.conversationID)
            JNNotificationCenter.shared.post(event)
            completion(resp)
        }
    }
    
    func toggleCanViewProfile() {
        guard let groupID = conversation.groupID else { return }
        IMController.shared.setGroupLookMemberInfo(id: groupID, rule: canViewProfileRelay.value ? 0 : 1, completion: { [weak self] _ in
            guard let sself = self else { return }
            sself.canViewProfileRelay.accept(!sself.canViewProfileRelay.value)
        })
    }
    
    func toggleCanAddFriend() {
        guard let groupID = conversation.groupID else { return }
        IMController.shared.setGroupApplyMemberFriend(id: groupID, rule: canAddFriendRelay.value ? 0 : 1, completion: { [weak self] _ in
            guard let sself = self else { return }
            sself.canAddFriendRelay.accept(!sself.canAddFriendRelay.value)
        })
    }
    
    // MARK: -    置顶聊天
    func toggleTopContacts() {
        IMController.shared.pinConversation(id: conversation.conversationID, isPinned: !setTopContactRelay.value, completion: { [weak self] _ in
            guard let sself = self else { return }
            sself.setTopContactRelay.accept(!sself.setTopContactRelay.value)
        })
    }
    
    func toggleMuteAll() {
        guard let groupID = conversation.groupID else { return }
        IMController.shared.changeGroupMute(groupID: groupID, isMute: !mutedAllRelay.value, completion: { [weak self] _ in
            guard let sself = self else { return }
            sself.mutedAllRelay.accept(!sself.mutedAllRelay.value)
        })
    }

    func setNoDisturbWithNotRecieve() {
        IMController.shared.setConversationRecvMessageOpt(conversationID: conversation.conversationID, status: .notReceive, completion: { [weak self] _ in
            guard let sself = self else { return }
            self?.noDisturbRelay.accept(true)
        })
    }

    func setNoDisturbWithNotNotify() {
        IMController.shared.setConversationRecvMessageOpt(conversationID: conversation.conversationID, status: .notNotify, completion: { [weak self] _ in
            guard let sself = self else { return }
            self?.noDisturbRelay.accept(true)
        })
    }

    func setNoDisturbOff() {
        IMController.shared.setConversationRecvMessageOpt(conversationID: conversation.conversationID, status: .receive, completion: { [weak self] _ in
            guard let sself = self else { return }
            self?.noDisturbRelay.accept(false)
        })
    }

    func dismissGroup(onSuccess: @escaping CallBack.VoidReturnVoid) {
        guard let groupId = conversation.groupID else { return }
        IMController.shared.dismissGroup(id: groupId) { [weak self] _ in
            guard let sself = self else { return }
            let event = EventGroupDismissed(conversationId: sself.conversation.conversationID)
            JNNotificationCenter.shared.post(event)
            IMController.shared.deleteConversation(conversationID: (self?.conversation.conversationID)!) { r in
                onSuccess()
            }
        }
    }

    func quitGroup(onSuccess: @escaping CallBack.VoidReturnVoid) {
        guard let groupId = conversation.groupID else { return }
        IMController.shared.quitGroup(id: groupId) { [weak self] _ in
            guard let sself = self else { return }
            let event = EventGroupDismissed(conversationId: sself.conversation.conversationID)
            JNNotificationCenter.shared.post(event)
            IMController.shared.deleteConversation(conversationID: (self?.conversation.conversationID)!) { r in
                onSuccess()
            }
        }
    }

    func updateMyNicknameInGroup(_ nickname: String, onSuccess: @escaping CallBack.VoidReturnVoid) {
        guard let group = groupInfoRelay.value else { return }
        IMController.shared.setGroupMemberNicknameOf(userid: IMController.shared.uid, inGroupId: group.groupID, with: nickname) { [weak self] _ in
            let member = self?.myInfoInGroup.value
            member?.nickname = nickname
            self?.myInfoInGroup.accept(member)
            onSuccess()
        }
    }
    
    func transferOwner(to uid: String, onSuccess: @escaping CallBack.VoidReturnVoid) {
        guard let group = groupInfoRelay.value else { return }
        IMController.shared.transferOwner(groupId: group.groupID, to: uid) { r in
            onSuccess()
        }
    }
    
    func updateVerificationOption(type: GroupVerificationType) {
        guard let group = groupInfoRelay.value else { return }
        IMController.shared.setGroupVerification(groupId: group.groupID, type: type) {[weak self] r in
            
            if var info = self?.groupInfoRelay.value {
                info.needVerification = type
                self?.groupInfoRelay.accept(info)
            }
        }
    }
    
    func inviteUsersToGroup(uids: [String], onSuccess: @escaping CallBack.VoidReturnVoid) {
        guard let groupID = groupInfoRelay.value?.groupID else { return }
        
        IMController.shared.inviteUsersToGroup(groupId: groupID, uids: uids) { [weak self] in
            self?.queryMembers(groupID: groupID) {
                onSuccess()
            }
        }
    }
    
    func kickGroupMember(uids: [String], onSuccess: @escaping CallBack.VoidReturnVoid) {
        guard let groupID = groupInfoRelay.value?.groupID else { return }

        IMController.shared.kickGroupMember(groupId: groupID, uids: uids) { [weak self] r in
            if r {
                self?.queryMembers(groupID: groupID) {
                    onSuccess()
                }
            } else {
                onSuccess()
            }
        }
    }
    
    func toggleRegularlyDelete(onSuccess: @escaping CallBack.StringOptionalReturnVoid) {
        IMController.shared.setRegularlyDelete(conversationID: conversation.conversationID, isMsgDestruct:!regularlyDeleteRelay.value) { [weak self] r in
            guard let sself = self else {return}
            if let r {
                sself.regularlyDeleteRelay.accept(!sself.regularlyDeleteRelay.value)
            } else {
                sself.regularlyDeleteRelay.accept(sself.regularlyDeleteRelay.value)
            }
            onSuccess(r)
        }
    }
    
    func setRegularlyDuration(_ duration: Int, onSuccess: @escaping CallBack.StringOptionalReturnVoid) {
        IMController.shared.setRegularlyDuration(conversationID: conversation.conversationID, duration: duration) { [weak self] r in
            if let r {
                self?.regularlyDurationRelay.accept(Double(duration))
            }
            onSuccess(r)
        }
    }
    
    func uploadFile(fullPath: String, onProgress: @escaping (CGFloat) -> Void, onComplete: @escaping () -> Void) {
        IMController.shared.uploadFile(fullPath: fullPath, onProgress: onProgress) { [weak self] url in
            if let url, let info = self?.groupInfoRelay.value {
                
                let p = GroupInfo(groupID: info.groupID)
                p.faceURL = url
                
                IMController.shared.setGroupInfo(group: p) { r in
                    info.faceURL = url
                    self?.groupInfoRelay.accept(info)
                    onComplete()
                }
            }
        }
    }
    
    func removeConversation(onComplete: @escaping (Bool) -> Void) {
        IMController.shared.deleteConversation(conversationID: conversation.conversationID) { [weak self] r in
            onComplete(r != nil)
        }
    }
}

fileprivate var GroupMemberInfoAddButtonExtensionKey: String?
fileprivate var GroupMemberInfoRemoveButtonExtensionKey: String?

extension GroupMemberInfo {
    public func toUserInfo() -> UserInfo {
        let user = UserInfo(userID: userID!)
        user.faceURL = faceURL
        user.nickname = nickname
        
        return user
    }
    
    public var isAddButton: Bool {
        set {
            objc_setAssociatedObject(self, &GroupMemberInfoAddButtonExtensionKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
        }

        get {
            let value: Bool = objc_getAssociatedObject(self, &GroupMemberInfoAddButtonExtensionKey) as? Bool ?? false
            return value
        }
    }
    
    public var isRemoveButton: Bool {
        set {
            objc_setAssociatedObject(self, &GroupMemberInfoRemoveButtonExtensionKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
        }

        get {
            let value: Bool = objc_getAssociatedObject(self, &GroupMemberInfoRemoveButtonExtensionKey) as? Bool ?? false
            return value
        }
    }
}
