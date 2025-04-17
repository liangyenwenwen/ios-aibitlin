
import Foundation
import UIKit
import OUICore
import RxSwift

#if ENABLE_CALL
import OUICalling
#endif

protocol DataProvider {
    
    func loadInitialMessages(completion: @escaping ([MessageInfo]) -> Void)
    
    func loadPreviousMessages(completion: @escaping ([MessageInfo]) -> Void)
    
    func loadMoreMessages(completion: @escaping ([MessageInfo]) -> Void)
    
    func getGroupInfo(groupInfoHandler: @escaping (GroupInfo) -> Void, muteInfoHandler: ((MutedInfo) -> Void)?)
    
    func getGroupMembers(userIDs: [String]?, handler: @escaping ([GroupMemberInfo]) -> Void, isAdminHandler: ((Bool) -> Void)?)
    
    func getUserInfo(otherInfo: ((PublicUserInfo) -> Void)?, mine: ((UserInfo) -> Void)?)

    func isJoinedGroup(groupID: String, handler: @escaping (Bool) -> Void)
}

final class DefaultDataProvider: DataProvider {
    
    private let _disposeBag = DisposeBag()
    
    weak var delegate: DataProviderDelegate?
    
    private var startClientMsgID: String?
    
    private var lastMinSeq: Int = 0
    
    private var reverseStartClientMsgID: String?
    
    private var reverseLastMinSeq: Int = 0
    
    private var conversation: ConversationInfo!
    
    private var startingTimestamp = Date().timeIntervalSince1970
    
    private var typingState: TypingState = .idle
    
    private let users: [String] = []
    
    private let receiverId: String!
    
    private var lastMessageIndex: Int = 0
    
    private var lastReadString: String?
    
    private var lastReceivedString: String?
    
    private let enableNewMessages = true
    
    private var anchorMessage: MessageInfo?
    
    init(conversation: ConversationInfo, anchorMessage: MessageInfo? = nil) {
        self.conversation = conversation
        self.receiverId = conversation.conversationType == .c2c ? conversation.userID! : conversation.groupID!
        self.anchorMessage = anchorMessage
        
        checkBlackList()
        getInputStatus()
        addObservers()
    }
    
    deinit {
        print("\(type(of: self)) - \(#function)")
    }
    
    func loadInitialMessages(completion: @escaping ([MessageInfo]) -> Void) {
        if anchorMessage != nil {
            startClientMsgID = anchorMessage?.clientMsgID
            reverseStartClientMsgID = anchorMessage?.clientMsgID
            anchorMessage?.isAnchor = true
            
            var r = [anchorMessage!]
            
//            getHistoryMessageList(reverse: false) { ms in
            getHistoryMessageList(reverse: true) { ms in
                r = ms + r
                completion(r)
            }
        } else {
            lastMinSeq = 0
            startClientMsgID = nil
            getHistoryMessageList(completion: completion)
        }
    }
    
    func loadPreviousMessages(completion: @escaping ([MessageInfo]) -> Void) {
        getHistoryMessageList(completion: completion)
    }
    
    func loadMoreMessages(completion: @escaping ([MessageInfo]) -> Void) {
        guard let anchorMessage else {
            completion([])
            return
        }
        getHistoryMessageList(reverse: true, completion: completion)
//        getHistoryMessageList(reverse: false, completion: completion)
    }
    
    func getGroupInfo(groupInfoHandler: @escaping (GroupInfo) -> Void, muteInfoHandler: ((MutedInfo) -> Void)?) {
        IMController.shared.getGroupInfo(groupIds: [receiverId]) { [weak self] (infos: [GroupInfo]) in
            guard let self, let groupInfo = infos.first else {
                return
            }
            groupInfoHandler(groupInfo)
            
            if !groupInfo.isMine, let muteInfoHandler {
                var mutedInfo: MutedInfo!
                // 普通成员才能接收禁言等状态
                if groupInfo.status == .muted { // 群禁言级别更高
                    mutedInfo = MutedInfo(mutedEndTime: -1,
                                          mutedText: "全体禁言",
                                          muted: true)
                    muteInfoHandler(mutedInfo)
                } else {
                    IMController.shared.getGroupMembersInfo(groupId: receiverId,
                                                            uids: [IMController.shared.uid]) { ms in
                        
                        if let m = ms.first {
                            let timeStamp = NSDate().timeIntervalSince1970
                            mutedInfo = MutedInfo(mutedEndTime: m.muteEndTime,
                                                  mutedText: "youMuted".innerLocalized(),
                                                  muted: m.muteEndTime > timeStamp * 1000,
                                                  mutedMe: true)
                            muteInfoHandler(mutedInfo)
                            self.delegate?.mute(info: mutedInfo)
                        }
                    }
                }
            }
        }
    }
    
    func getGroupMembers(userIDs: [String]?, handler: @escaping ([GroupMemberInfo]) -> Void, isAdminHandler: ((Bool) -> Void)?) {
        
        if let userIDs, !userIDs.isEmpty {
            IMController.shared.getGroupMembersInfo(groupId: receiverId, uids: userIDs) { infos in
                handler(infos)
            }
        } else {
            IMController.shared.getGroupMemberList(groupId: receiverId,
                                                   filter: .all,
                                                   offset: 0,
                                                   count: 10000) { ms in
                handler(ms)
                
                if let isAdminHandler, let r = ms.first(where: { $0.userID == IMController.shared.uid }) {
                    isAdminHandler(r.isOwnerOrAdmin)
                }
            }onFailure: { errCode, errMsg in
                
            }
        }
    }
    
    func isJoinedGroup(groupID: String, handler: @escaping (Bool) -> Void) {
        IMController.shared.isJoinedGroup(groupID: groupID) { r in
            handler(r)
        }
    }
    
    func getUserInfo(otherInfo: ((PublicUserInfo) -> Void)?, mine: ((UserInfo) -> Void)?) {
        if let me = IMController.shared.currentUserRelay.value {
            mine?(me)
        }
        if otherInfo != nil {
            IMController.shared.getUserInfo(uids: [receiverId]) { others in
                if let other = others.first {
                    otherInfo?(other)
                }
            }
        }
    }
    
    private func getHistoryMessageList(reverse: Bool = false, count: Int = 20, completion: @escaping ([MessageInfo]) -> Void) {
        if reverse {
            IMController.shared.getHistoryMessageListReverse(conversationID: conversation.conversationID,
                                                             startCliendMsgId: reverseStartClientMsgID,
                                                             lastMinSeq: reverseLastMinSeq,
                                                             count: count) { [weak self] seq, ms in
                guard let self, !ms.isEmpty else {
                    completion([])
                    return
                }
                
                self.reverseLastMinSeq = seq
                self.reverseStartClientMsgID = ms.last?.clientMsgID
                completion(ms)
            }
        } else {
            IMController.shared.getHistoryMessageList(conversationID: conversation.conversationID,
                                                      conversationType: conversation.conversationType,
                                                      startCliendMsgId: startClientMsgID,
                                                      lastMinSeq: lastMinSeq,
                                                      count: count) { [weak self] seq, ms in
                guard let self, !ms.isEmpty else {
                    completion([])
                    return
                }
                
                self.lastMinSeq = seq
                self.startClientMsgID = ms.first?.clientMsgID
                
//                if ms.count < count {
//                    IMController.shared.getHistoryMessageList(conversationID: conversation.conversationID,
//                                                              conversationType: conversation.conversationType,
//                                                              startCliendMsgId: startClientMsgID,
//                                                              lastMinSeq: lastMinSeq,
//                                                              count: count) { [weak self] seq, ms2 in
//                        guard let self, !ms2.isEmpty else {
//                            completion(ms)
//                            return
//                        }
//                        
//                        self.lastMinSeq = seq
//                        self.startClientMsgID = ms2.first?.clientMsgID
//                        completion(ms + ms2)
//                    }
//                } else {
                    completion(ms)
//                }
            }
        }
    }
    
    private func checkBlackList() {
        IMController.shared.getBlackList { [self] infos in
            if infos.contains(where: { $0.userID == receiverId }) {
                let mutedInfo = MutedInfo(
                    mutedText: "对方已被拉入黑名单",
                    muted: true)
                delegate?.mute(info: mutedInfo)
            }
        }
    }
    
    private func getInputStatus() {
        guard conversation.conversationType == .c2c else { return }
        
        IMController.shared.getInputStatus(conversationID: conversation.conversationID, userID: receiverId) { [self] result in
            switch result {
            case .success(let platformIDs):
                
                self.typingState = !platformIDs.isEmpty ? .typing : .idle

                self.delegate?.typingStateChanged(to: self.typingState)
            case .failure(let err):
                self.typingState = .idle

                self.delegate?.typingStateChanged(to: self.typingState)
            }
        }
    }
    
    // 接收消息
    private func addObservers() {
        IMController.shared.inputStatusChangedSubject.subscribe(onNext: { [weak self] status in
            guard let self,
                    status?.conversationID == conversation.conversationID,
                    status?.userID == receiverId else { return }
            
            self.typingState = status?.platformIDs?.isEmpty == false ? .typing : .idle

            self.delegate?.typingStateChanged(to: self.typingState)
        }).disposed(by: _disposeBag)
        
        IMController.shared.newMsgReceivedSubject.subscribe(onNext: { [weak self] (message: MessageInfo) in
            guard let self else { return }
            // 输入状态
            if case .typing = message.contentType {
//                if (self.conversation.userID == message.sendID ||
//                    self.conversation.groupID == message.groupID) {
//                    self.typingState = message.isTyping() ? .typing : .idle
//                    self.delegate?.typingStateChanged(to: self.typingState)
//                }
            } else {
                self.receivedNewMessages(message: message)
            }
        }).disposed(by: _disposeBag)
        
        IMController.shared.c2cReadReceiptReceived.subscribe(onNext: { [weak self] (receiptInfos: [ReceiptInfo]) in
            let receipts = receiptInfos.filter({ $0.userID == self?.conversation.userID })
            self?.delegate?.lastReadIdsChanged(signal: receipts.flatMap({ $0.msgIDList ?? [] }), group: nil)
        }).disposed(by: _disposeBag)
        
        IMController.shared.groupReadReceiptReceived.subscribe(onNext: { [weak self] receiptInfo in
            if receiptInfo.conversationID == self?.conversation.conversationID {
                self?.delegate?.lastReadIdsChanged(signal: nil, group: receiptInfo.groupMessageReadInfo)
            }
        }).disposed(by: _disposeBag)
        
        IMController.shared.groupMemberInfoChange.subscribe(onNext: { [weak self] info in
            guard let info else { return }
            self?.delegate?.groupMemberInfoChanged(info: info)
        }).disposed(by: _disposeBag)
        
        IMController.shared.joinedGroupAdded.subscribe(onNext: { [weak self] info in
            // groupInfo.groupID 即为邀请你的群
            guard let self, self.receiverId == info?.groupID else { return }
            
            self.delegate?.isInGroup(with: true)
            
        }).disposed(by: _disposeBag)
        
        IMController.shared.joinedGroupDeleted.subscribe(onNext: { [weak self] info in
            // groupInfo.groupID 即为踢出你的群
            guard let self, self.receiverId == info?.groupID else { return }
            
            self.delegate?.isInGroup(with: false)
            
        }).disposed(by: _disposeBag)
#if ENABLE_CALL
        CallingManager.manager.roomParticipantChangedHandler = { [weak self] info in
            if info.groupID == self?.receiverId {
                let members = info.participant.map { $0.groupMemberInfo.toGroupMemberInfo() }
                self?.delegate?.roomParticipantChanged(isVideo: info.invitation.isVideo(), members: members)
            }
        }
#endif
        
        IMController.shared.msgRevokeReceived.subscribe(onNext: { [weak self] revokedInfo in
            self?.delegate?.receivedRevokedInfo(info: revokedInfo)
        }).disposed(by: _disposeBag)
        
        IMController.shared.friendInfoChangedSubject.subscribe(onNext:  { [weak self] (friendInfo: FriendInfo?) in
            guard let self, let friendInfo else { return }
            
            delegate?.friendInfoChanged(info: friendInfo)
        }).disposed(by: _disposeBag)
        
        IMController.shared.onBlackAddedSubject.subscribe(onNext:  { [weak self] (blcakInfo: BlackInfo?) in
            guard let blcakInfo else { return }
            
            let mutedInfo = MutedInfo(
                mutedText: "对方已被拉入黑名单",
                muted: true)
            self?.delegate?.mute(info: mutedInfo)
        }).disposed(by: _disposeBag)
        
        IMController.shared.onBlackDeletedSubject.subscribe(onNext:  { [weak self] (blcakInfo: BlackInfo?) in
            guard let blcakInfo else { return }
            let mutedInfo = MutedInfo(
                mutedText: "",
                muted: false)
            self?.delegate?.mute(info: mutedInfo)
        }).disposed(by: _disposeBag)
        
        IMController.shared.groupInfoChangedSubject.subscribe(onNext:  { [weak self] (groupInfo: GroupInfo?) in
            guard let groupInfo else { return }
            self?.delegate?.groupInfoChanged(info: groupInfo)
        }).disposed(by: _disposeBag)
        
        IMController.shared.userStatusSubject.subscribe(onNext: { [weak self] info in
            guard let info, self?.conversation.conversationType == .c2c, info.userID == self?.receiverId else { return }
            self?.delegate?.onlineStatus(status: info)
        }).disposed(by: _disposeBag)
        
        IMController.shared.groupMemberAdded.subscribe(onNext:  { [weak self] member in
            guard let member else { return }
            
            self?.delegate?.groupMembersChanged(added: true, info: member)
        }).disposed(by: _disposeBag)
        
        IMController.shared.groupMemberDeleted.subscribe(onNext:  { [weak self] member in
            guard let member else { return }
            
            self?.delegate?.groupMembersChanged(added: false, info: member)
        }).disposed(by: _disposeBag)
        
        IMController.shared.totalUnreadSubject.subscribe(onNext: { [weak self] count in
            self?.delegate?.unreadCountChanged(count: count)
        }).disposed(by: _disposeBag)
    }
    
    private func receivedNewMessages(message: MessageInfo) {
        guard enableNewMessages else {
            return
        }
        
        delegate?.received(message: message)
        delegate?.lastReceivedIdChanged(to: message.clientMsgID)
    }
}
