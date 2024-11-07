
import Alamofire
import ChatLayout
import Foundation
import Kingfisher
import OUICore

#if ENABLE_CALL
import OUICalling
#endif

#if ENABLE_LIVE_ROOM
import OUILive
#endif

final class DefaultChatController: ChatController {
    weak var delegate: ChatControllerDelegate?
    
    private let dataProvider: DataProvider
    
    private var typingState: TypingState = .idle
    
    private let dispatchQueue = DispatchQueue(label: "DefaultChatController", qos: .userInteractive)
    
    private var lastReadIDs: [String]?
    
    private var groupReadedInfos: [GroupMessageReadInfo]? // 群组中已读人
    
    private var unReadCount: Int = 0 // 左上角的未读数
    
    private var lastReceivedString: String?
    
    private let receiverId: String // 接收人的uid
    
    private let senderID: String // 发送人的uid
    
    private let conversationType: ConversationType // 会话类型
    
    // MARK: - 张亚飞打的标记  会话信息

    private let conversation: ConversationInfo
    
    private var groupInfo: GroupInfo? // 将其缓存
    
    private var groupMembers: [GroupMemberInfo]?
    
    private var otherInfo: FullUserInfo?
    
    private var me: UserInfo?
    
    private var messages: [MessageInfo] = []
    var translateMessages: [MessageInfo] = []
    
    private var selecteMessages: [MessageInfo] = [] // 选中的消息id， 可转发、删除、引用消息

    private var selectedUsers: [String] = [] // 选中的成员, 可做为@成员
    
    private var isAdminOrOwner = false
    
    private var canRevokeMessage = false
    
    private var mediaMessages: [Message] = []
    
    private var mutedTimer: Timer?
    
    private var recvMessageIsCurrentChat = false
        
    init(dataProvider: DataProvider, senderID: String, conversation: ConversationInfo) {
        self.dataProvider = dataProvider
        self.receiverId = conversation.conversationType == .c2c ?
            conversation.userID! : conversation.groupID!
        self.senderID = senderID
        self.conversationType = conversation.conversationType
        self.conversation = conversation
        
#if ENABLE_CALL
        if conversationType == .superGroup {
            getMeetingRoom()
        }
        CallingManager.manager.endCallingHandler = { [weak self] msg in
            self?.appendConvertingToMessages([msg.toMessageInfo()])
            self?.repopulateMessages(requiresIsolatedProcess: true)
        }
#endif
        
        updataeConversationEx()
    }
    
    deinit {
        print("\(type(of: self)) - \(#function)")
        mutedTimer = nil
        clearUnreadCount()
        resetGroupPrefix()
        unSubscribeUsersStatus()
        FileDownloadManager.manager.pauseAllDownloadRequest()
    }
    
    // MARK: 协议相关
    
    func loadInitialMessages(completion: @escaping ([Section]) -> Void) {
        dataProvider.loadInitialMessages { [weak self] messages in
            self?.appendConvertingToMessages(messages, removeAll: true)
            self?.markAllMessagesAsReceived { [weak self] in
                self?.markAllMessagesAsRead { [weak self] in
                    self?.propagateLatestMessages { [weak self] sections in
                        completion(sections)
                        
                        guard let self else { return }
                        
                        if conversationType == .c2c {
                            getOtherInfo { [weak self] info in
                                let otherInfo = FriendInfo()
                                otherInfo.nickname = info.showName
                                otherInfo.userID = info.userID
                                self?.delegate?.friendInfoChanged(info: otherInfo)
                            }
                        } else if conversationType == .superGroup {
                            getGroupInfo(force: true) { [weak self] info in
                                self?.delegate?.groupInfoChanged(info: info)
                            }
                            getGroupMembers(userIDs: nil, memory: false) { _ in }
                        }
                        
                        if conversation.unreadCount != 0 {
                            markMessageAsReaded { [weak self] in
                                self?.getUnReadTotalCount()
                            }
                        }
                        
                        searchLocalMediaMessage { [weak self] ms in
                            self?.mediaMessages = ms
                        }
                        
                        resetGroupPrefix()
                    }
                }
            }
        }
    }
    
    func loadPreviousMessages(completion: @escaping ([Section]) -> Void) {
        dataProvider.loadPreviousMessages(completion: { [weak self] messages in
            self?.appendConvertingToMessages(messages)
            self?.markAllMessagesAsReceived { [weak self] in
                self?.markAllMessagesAsRead { [weak self] in
                    self?.propagateLatestMessages { [weak self] sections in
                        completion(sections)
                    }
                }
            }
        })
    }
    
    func loadMoreMessages(completion: @escaping ([Section]) -> Void) {
        dataProvider.loadMoreMessages(completion: { [weak self] messages in
            self?.insertConvertingToMessages(messages)
            self?.markAllMessagesAsReceived { [weak self] in
                self?.markAllMessagesAsRead { [weak self] in
                    self?.propagateLatestMessages { [weak self] sections in
                        completion(sections)
                    }
                }
            }
        })
    }
    
    func getTitle() {
        switch conversationType {
        case .undefine:
            break
        case .c2c:
            // To quickly display the title.
            let otherInfo = FriendInfo()
            otherInfo.nickname = conversation.showName
            otherInfo.userID = receiverId
            delegate?.friendInfoChanged(info: otherInfo)
            
            subscribeUsersStatus()
        case .superGroup:
            // To quickly display the title.
            let groupInfo = GroupInfo(groupID: receiverId, groupName: conversation.showName)
            delegate?.groupInfoChanged(info: groupInfo)
        case .notification:
            // To quickly display the title.
            let otherInfo = FriendInfo()
            otherInfo.nickname = "SystemNotice".innerLocalized()
            otherInfo.userID = receiverId
            delegate?.friendInfoChanged(info: otherInfo)
        }
    }
    
    func messageIsExsit(with id: String) -> Bool {
        messages.contains(where: { $0.clientMsgID == id })
    }
    
    func defaultSelecteMessage(with id: String?, onlySelect: Bool = false) {
        if let id {
            selecteMessages.removeAll()
            if !onlySelect {
                resetSelectedStatus()
                selecteMessage(with: id)
            } else {
                seleteMessageHelper(with: id)
            }
        } else {
            if !onlySelect {
                resetSelectedStatus()
            }
            selecteMessages.removeAll()
        }
    }
    
    func defaultSelecteUsers(with usersID: [String]) {
        selectedUsers.append(contentsOf: usersID)
    }
    
    // 重置原始消息的选中状态
    private func resetSelectedStatus() {
        messages.forEach { $0.isSelected = false }
    }
    
    func deleteMessage(completion: (() -> Void)?) {
        // 删除成功以后，再对比数据源
        deleteMessages(messages: selecteMessages) { [weak self] result in
            guard let self else { return }
            messages.removeAll { fm in
                result.contains(where: { $0.clientMsgID == fm.clientMsgID })
            }
            completion?()
            repopulateMessages(requiresIsolatedProcess: false)
            selecteMessages.removeAll { ms in
                result.contains(where: { $0.clientMsgID == ms.clientMsgID })
            }
        }
    }
    
    func forwardMessage(merge: Bool, usersID: [String]?, groupsID: [String]?, title: String, attachMessage: String?) {
        let users = usersID ?? []
        let groups = groupsID ?? []
        
        var usersCount = users.count
        var groupsCount = groups.count
        
        func resetSelectedMessagesStatus() {
            if usersCount == 0 && groupsCount == 0 {
                selecteMessages.removeAll()
                resetSelectedStatus()
            }
        }
        
        for userID in users {
            if merge {
                sendMergeMessage(to: userID, or: nil, title: title, attachMessage: attachMessage) { [weak self] _ in
                    usersCount -= 1
                    resetSelectedMessagesStatus()
                }
            } else {
                sendForwardMessage(to: userID, or: nil, attachMessage: attachMessage) { [weak self] _ in
                    usersCount -= 1
                    resetSelectedMessagesStatus()
                }
            }
        }
        
        for groupID in groups {
            if merge {
                sendMergeMessage(to: nil, or: groupID, title: title, attachMessage: attachMessage) { [weak self] _ in
                    groupsCount -= 1
                    resetSelectedMessagesStatus()
                }
            } else {
                sendForwardMessage(to: nil, or: groupID, attachMessage: attachMessage) { [weak self] _ in
                    groupsCount -= 1
                    resetSelectedMessagesStatus()
                }
            }
        }
    }
    
    func getConversation() -> ConversationInfo {
        return conversation
    }
    
    func getGroupMembers(userIDs: [String]?, memory: Bool, completion: @escaping ([GroupMemberInfo]) -> Void) {
        if memory, let userIDs {
            if let ms = groupMembers?.filter({ userIDs.contains($0.userID!) }) {
                completion(ms)
            }
        } else {
            if let userIDs {
                dataProvider.getGroupMembers(userIDs: userIDs, handler: completion, isAdminHandler: nil)
            } else {
                if groupMembers == nil {
                    dataProvider.getGroupMembers(userIDs: userIDs) { [weak self] ms in
                        completion(ms)
                        self?.groupMembers = ms
                    } isAdminHandler: { [weak self] admin in
                        self?.isAdminOrOwner = admin
                    }
                } else {
                    completion(groupMembers!)
                }
            }
        }
    }
    
    func getMentionUsers(completion: @escaping ([GroupMemberInfo]) -> Void) {
        getGroupMembers(userIDs: nil, memory: true) { ms in
            var us = ms.filter { $0.userID != IMController.shared.uid }
            let metionAll = GroupMemberInfo()
            metionAll.userID = IMController.shared.atAllTag()
            metionAll.nickname = "所有人".innerLocalized()
            us.insert(metionAll, at: 0)
            
            completion(us)
        }
    }
    
    func getMentionAllFlag() -> (tag: String, text: String) {
        return (IMController.shared.atAllTag(), "everyone".innerLocalized())
    }
    
    func getMessageInfo(ids: [String]) -> [MessageInfo] {
        return messages.filter { ids.contains($0.clientMsgID) }
    }
    
    private func getBasicInfo(completion: @escaping () -> Void) {
        if conversationType == .c2c {
            getOtherInfo { _ in
                completion()
            }
        } else {
            getGroupInfo(force: false) { _ in
                completion()
            }
        }
    }
    
    func getOtherInfo(completion: @escaping (FullUserInfo) -> Void) {
        if otherInfo == nil {
            // To quickly display the title.
            otherInfo = FullUserInfo(userID: receiverId, showName: conversation.showName)
            
            dataProvider.getUserInfo { [weak self] full in
                completion(full)
                self?.otherInfo = full
            } mine: { [weak self] u in
                self?.me = u
            }
            completion(otherInfo!)
        } else {
            completion(otherInfo!)
        }
    }

    func getGroupInfo(force: Bool, completion: @escaping (GroupInfo) -> Void) {
        if groupInfo == nil {
            // To quickly display the title.
            groupInfo = GroupInfo(groupID: receiverId, groupName: conversation.showName)
            completion(groupInfo!)
        }
        
        if !force, groupInfo != nil {
            completion(groupInfo!)
            return
        }
        
        if me == nil {
            dataProvider.getUserInfo(otherInfo: nil, mine: { [weak self] info in
                self?.me = info
            })
        }
        dataProvider.getGroupInfo { [weak self] group in
            completion(group)
            self?.groupInfo = group
        } muteInfoHandler: { [weak self] muted in
            self?.delegate?.mute(info: muted)
        }
        
        dataProvider.isJoinedGroup(groupID: receiverId) { [weak self] isIn in
            self?.isInGroup(with: isIn)
        }
    }
    
    func getSelectedMessages() -> [MessageInfo] {
        selecteMessages
    }
    
    func getSelfInfo() -> UserInfo? {
        IMController.shared.currentUserRelay.value
    }
    
    func getIsAdminOrOwner() -> Bool {
        isAdminOrOwner
    }
    
    func canRevokeMessage(msg: Message) -> Bool {
        if conversationType == .c2c {
            return msg.type == .outgoing && msg.date.timeIntervalSinceNow > -24 * 60 * 60
        } else {
            if groupInfo?.isMine == true ||
                (isAdminOrOwner && msg.owner.id != groupInfo?.ownerUserID)
            {
                if case .text(let source) = msg.data {
                    return source.type != .notice
                }
                return true
            } else {
                return msg.type == .outgoing && msg.date.timeIntervalSinceNow > -24 * 60 * 60
            }
        }
    }
    
    func addFriend(onSuccess: @escaping CallBack.StringOptionalReturnVoid, onFailure: @escaping CallBack.ErrorOptionalReturnVoid) {
        let reqMsg = "\(IMController.shared.currentUserRelay.value!.nickname)请求添加你为好友"
        IMController.shared.addFriend(uid: receiverId, reqMsg: reqMsg, onSuccess: onSuccess, onFailure: onFailure)
    }
    
    private func getMeetingRoom() {
#if ENABLE_LIVE_ROOM
        IMController.shared.getRoomSignalingInfoByGroupID(groupID: receiverId) { [self] isVideo, members in
            self.delegate?.roomParticipantChanged(isVideo: isVideo, members: members)
        }
#endif
    }
    
#if ENABLE_LIVE_ROOM
    func joinMeeting(meetingID: String, onSuccess: @escaping SignalingInfoOptionalReturnVoid, onFailure: @escaping CallBack.ErrorOptionalReturnVoid) {
        IMController.shared.signalingJoinMeeting(meetingID: meetingID, participantNickname: IMController.shared.currentUserRelay.value?.nickname, onSuccess: onSuccess, onFailure: onFailure)
    }
#endif
    
    func joinMeetingMidway(isVedio: Bool) {
#if ENABLE_LIVE_ROOM
        CallingManager.manager.signalingGetInvitation(by: receiverId) { [self] url, token in
            CallingManager.manager.joinRoom(isVideo: isVedio, roomID: receiverId, liveURL: url, token: token)
        }
#endif
    }
    
    // 主动撤回
    func revokeMessage(with id: String, completion: @escaping () -> Void) {
        if var msg = messages.first(where: { $0.clientMsgID == id }) {
            let contentType = msg.contentType
            
            IMController.shared.revokeMessage(conversationID: conversation.conversationID,
                                              clientMsgID: id)
            { [weak self] _ in
                guard let self else { return }
                
                let info = MessageRevoked()
                info.clientMsgID = msg.clientMsgID
                info.revokerNickname = IMController.shared.currentUserRelay.value?.nickname
                info.revokerID = IMController.shared.currentUserRelay.value?.userID
                info.sourceMessageSendID = msg.sendID
                info.sourceMessageSendTime = msg.sendTime
                info.sourceMessageSenderNickname = msg.senderNickname
                info.revokeTime = NSDate().timeIntervalSince1970
                info.sessionType = msg.sessionType
                msg.content = JsonTool.toJson(fromObject: info)
                msg.contentType = .revoke
                
                if contentType == .text || contentType == .quote || contentType == .at {
                    msg.contentType = contentType
                    RevokedMessageStorage.append(messageID: msg.clientMsgID, value: msg)
                }
                
                completion()
                
                repopulateMessages(requiresIsolatedProcess: false)
                
                if msg.contentType == .image || msg.contentType == .video {
                    removeMediaMessage(msg: convertMessage(msg))
                }
            }
        }
    }
    
    func markMessageAsReaded(messageID: String? = nil, completion: (() -> Void)? = nil) {
        if messageID == nil, conversation.unreadCount == 0 {
            completion?()
    
            return
        }
        
        if let messageID, conversationType == .superGroup {
            IMController.shared.sendGroupMessageReadReceipt(conversationID: conversation.conversationID, clientMsgIDs: [messageID]) { [weak self] _ in
                completion?()
            }
        } else {
            IMController.shared.markMessageAsReaded(byConID: conversation.conversationID, msgIDList: messageID == nil ? [] : [messageID!]) { [weak self] _ in
                if let messageID {
                    let msg = self?.messages.first(where: { $0.clientMsgID == messageID })
                    msg?.hasReadTime = Date().timeIntervalSince1970 * 1000
                    msg?.isRead = true
                    
                    // private chat count down timer
                    self?.repopulateMessages(requiresIsolatedProcess: true)
                }
                
                completion?()
            } onFailure: { _, _ in
                completion?()
            }
        }
    }
    
    func updateMessageLocalEx(messageID: String, ex: MessageEx) {
        let json = JsonTool.toJson(fromObject: ex)
        IMController.shared.setMessageLocalEx(conversationID: conversation.conversationID, clientMsgID: messageID, ex: json)
    }
    
    func clearUnreadCount() {
        guard conversation.unreadCount > 0 else { return }
        
        IMController.shared.markMessageAsReaded(byConID: conversation.conversationID, msgIDList: []) { _ in
        }
    }
    
    func saveDraft(text: String?) {
        if text?.isEmpty == true {
            if conversation.draftText?.isEmpty == false {
                conversation.draftText = text ?? ""
                IMController.shared.saveDraft(conversationID: conversation.conversationID, text: text)
            }
        } else {
            conversation.draftText = text ?? ""
            IMController.shared.saveDraft(conversationID: conversation.conversationID, text: text)
        }
    }
    
    func uploadFile(image: UIImage, progress: @escaping (CGFloat) -> Void, completion: @escaping (String?) -> Void) {
        let r = FileHelper.shared.saveImage(image: image)

        IMController.shared.uploadFile(fullPath: r.fullPath) { p in
            progress(p)
        } onSuccess: { [weak self] r in
            if let r {
                KingfisherManager.shared.cache.store(image, forKey: r)
            }
            completion(r)
        }
    }
    
    func typing(doing: Bool) {
        guard conversation.conversationType == .c2c else { return }

        IMController.shared.typingStatusUpdate(conversationID: conversation.conversationID, focus: doing)
    }
    
    // MARK: preview media messages
    
    func searchLocalMediaMessage(completion: @escaping ([Message]) -> Void) {
        IMController.shared.searchLocalMessages(conversationID: conversation.conversationID, messageTypes: [.image, .video]) { [weak self] ms in
            guard let self else { return }
            let result = ms.reversed().flatMap { self.convertMessage($0) }
            
            completion(result)
        }
    }
    
    func appendMediaMessage(msg: Message) {
        mediaMessages.append(msg)
    }
    
    func removeMediaMessage(msg: Message) {
        mediaMessages.removeAll(where: { $0.id == msg.id })
    }
    
    // MARK: send message

    // MARK: - 张亚飞打的标记  ******** 重中之重  发送消息 ***********

    func sendMessage(_ data: Message.Data, completion: @escaping ([Section]) -> Void) {
        switch data {
        case .text(let source):
            // 如果有选中的消息，说明是引用消息
            let quoteMsg = selecteMessages.first
            
            if selectedUsers.count > 0 {
                sendAtMessage(text: source.text, quoteMessage: quoteMsg, completion: completion)
            } else {
                sendText(text: source.text, quoteMessage: quoteMsg, completion: completion)
            }
            saveDraft(text: nil)
        case .url(let url, isLocallyStored: _):
            break
            
        case .image(let source, isLocallyStored: _):
            sendImage(source: source, completion: completion)
            
        case .video(let source, isLocallyStored: _):
            // 发送的时候，图片选择器选择以后，传入的是路径
            sendVideo(source: source, completion: completion)
            
        case .audio(let source, isLocallyStored: _):
            sendAudio(source: source, completion: completion)
            
        case .merge(let source):
            let userID = conversationType == .c2c ? receiverId : nil
            let groupID = conversationType == .superGroup ? receiverId : nil
            
            sendMergeMessage(to: userID, or: groupID, title: "", completion: completion)
     
        case .file(let source, isLocallyStored: let isLocallyStored):
            sendFile(source: source, completion: completion)
            
        case .card(let source):
            sendCard(user: source.user, completion: completion)
            
        case .location(let source):
            sendLocation(location: source, completion: completion)
            
        case .face(let source, _):
            sendFace(face: source, completion: completion)
                            
        case .attributeText(_), .quote(_), .mention(_), .notice:
            break
        case .custom(let source):
            
            if source.type == .boke {
                print(#file, #line)
                print("发送博客 \(source)")
                print("发送博客 \(source.value)")
                sendBoke(source: source.bokeMessageSource, completion: completion)
            }
        }
    }
    
    private func resend(messageID: String) {
        guard let index = messages.firstIndex(where: { $0.clientMsgID == messageID }) else { return }
        
        IMController.shared.sendMessage(message: messages[index], to: receiverId, conversationType: conversationType) { [weak self] r in
            if r.status != .sendFailure {
                self?.messages[index] = r
                self?.repopulateMessages(requiresIsolatedProcess: false)
            }
        }
    }
    
    private func sendText(text: String, to: String? = nil, conversationType: ConversationType? = nil, quoteMessage: MessageInfo? = nil, completion: (([Section]) -> Void)?) {
        IMController.shared.sendTextMessage(text: text,
                                            quoteMessage: quoteMessage,
                                            to: to ?? receiverId,
                                            conversationType: conversationType ?? self.conversationType)
        { [weak self] msg in
            guard let completion else { return }
            self?.appendMessage(msg, completion: completion)
        } onComplete: { [weak self] msg in
            guard let completion else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [self] in // Animation effect problem.
                self?.appendMessage(msg, completion: completion)
                self?.selecteMessages.removeAll()
                self?.selectedUsers.removeAll()
            }
        }
    }
    
    // MARK: - 张亚飞打的标记  ******** 重中之重  发送博客方法 ***********

    private func sendBoke(source: bokeMessageSource, completion: @escaping ([Section]) -> Void) {
//        let boke = BokeElem(title: source.title, iconUrl: source.iconUrl, linkUrl: source.linkUrl, intro: source.intro)
//        let boke = BokeElem(from: )
        
        let boke = BokeElem(id: source.id,userBlogSign: source.userBlogSign, userBlogUrl: source.userBlogUrl, userBlogIntro: source.userBlogIntro, userBlogName: source.userBlogName, userBlogCreatIp: source.userBlogCreatIp, userBlogCreatAffiliatingArea: source.userBlogCreatAffiliatingArea, userBlogOrder: source.userBlogOrder, userId: source.userId, isDelete: source.isDelete, creationTime: source.creationTime, userBlogIcon: source.userBlogIcon, changeTime: source.changeTime)

        IMController.shared.sendBokeMessage(boke: boke, to: receiverId, conversationType: conversationType) { [weak self] msg in
            self?.appendMessage(msg, completion: completion)
        } onComplete: { [weak self] msg in
            self?.appendMessage(msg, completion: completion)
        }
    }
    
    private func sendImage(source: MediaMessageSource, completion: @escaping ([Section]) -> Void) {
        var path = source.source.url!.path
        path = path.hasPrefix("file://") ? path : "file://" + path
        
        DefaultImageCacher.cacheLocalData(path: path) { [self] data in
            if data?.imageFormat == .gif {
                IMController.shared.sendImageMessage(path: source.source.relativePath!,
                                                     to: receiverId,
                                                     conversationType: conversationType)
                { [weak self] msg in
                    self?.appendMessage(msg, completion: completion)
                } onComplete: { [weak self] msg in
                    // When displaying pictures in a list, they can be read quickly
                    if let data, let thumbUrl = msg.pictureElem?.snapshotPicture?.url?.defaultThumbnailURLString,
                       let url = msg.pictureElem?.sourcePicture?.url
                    {
                        DefaultImageCacher.cacheLoacalGIF(path: thumbUrl, data: data)
                        DefaultImageCacher.cacheLoacalGIF(path: url, data: data)
                    }
                    self?.appendMessage(msg, completion: completion)
                }
            } else {
                IMController.shared.sendImageMessage(path: source.source.relativePath!,
                                                     to: receiverId,
                                                     conversationType: conversationType)
                { [weak self] msg in
                    self?.appendMessage(msg, completion: completion)
                } onComplete: { [weak self] msg in
                    // When displaying pictures in a list, they can be read quickly
                    if let data, let image = UIImage(data: data),
                       let thumbUrl = msg.pictureElem?.snapshotPicture?.url?.defaultThumbnailURLString,
                       let url = msg.pictureElem?.sourcePicture?.url
                    {
                        DefaultImageCacher.cacheLocalImage(path: thumbUrl, image: image)
                        DefaultImageCacher.cacheLocalImage(path: url, image: image)
                    }
                    self?.appendMessage(msg, completion: completion)
                }
            }
        }
    }
    
    private func sendVideo(source: MediaMessageSource, completion: @escaping ([Section]) -> Void) {
        var path = source.thumb!.url.path
        let image = DefaultImageCacher.cacheLocalImage(path: path)
                
        IMController.shared.sendVideoMessage(path: source.source.relativePath!,
                                             duration: source.duration!,
                                             snapshotPath: (source.thumb?.url.relativeString)!,
                                             to: receiverId,
                                             conversationType: conversationType)
        { [weak self] msg in
            self?.appendMessage(msg, completion: completion)
        } onComplete: { [weak self] msg in
            if let image, let snapshotUrl = msg.videoElem?.snapshotUrl {
                DefaultImageCacher.cacheLocalImage(path: snapshotUrl, image: image)
                DefaultImageCacher.cacheLocalImage(path: snapshotUrl.defaultThumbnailURLString, image: image)
            }
            self?.appendMessage(msg, completion: completion)
        }
    }
    
    private func sendAudio(source: MediaMessageSource, completion: @escaping ([Section]) -> Void) {
        IMController.shared.sendAudioMessage(path: source.source.relativePath!,
                                             duration: source.duration!,
                                             to: receiverId,
                                             conversationType: conversationType)
        { [weak self] msg in
            self?.appendMessage(msg, completion: completion)
        } onComplete: { [weak self] msg in
            self?.appendMessage(msg, completion: completion)
        }
    }
    
    private func sendFile(source: FileMessageSource, completion: @escaping ([Section]) -> Void) {
        let filePath = source.url!.path
        
        IMController.shared.sendFileMessage(filePath: filePath,
                                            to: receiverId,
                                            conversationType: conversationType)
        { [weak self] msg in
            self?.appendMessage(msg, completion: completion)
        } onComplete: { [weak self] msg in
            self?.appendMessage(msg, completion: completion)
        }
    }
    
    private func sendMergeMessage(to userID: String?, or groupID: String?, title: String, attachMessage: String? = nil, completion: @escaping ([Section]) -> Void) {
        assert(userID != nil || groupID != nil)
        
        let type: ConversationType = userID != nil ? .c2c : .superGroup
        let sourceID = (type == .c2c ? userID : groupID)!
        let tempSelectedMessages = selecteMessages.sorted(by: { $0.sendTime < $1.sendTime })
        
        IMController.shared.getConversation(sessionType: type, sourceId: sourceID) { [weak self] _ in
            guard let self else { return }
            
            IMController.shared.sendMergeMessage(messages: tempSelectedMessages,
                                                 title: title,
                                                 to: sourceID,
                                                 conversationType: type)
            { [weak self] msg in
                if sourceID == self?.receiverId {
                    self?.appendMessage(msg, completion: completion)
                }
            } onComplete: { [weak self] msg in
                if sourceID == self?.receiverId {
                    if let attachMessage, !attachMessage.isEmpty {
                        self?.sendText(text: attachMessage, to: sourceID, conversationType: type) { _ in
                            self?.appendMessage(msg, completion: completion)
                        }
                    } else {
                        self?.appendMessage(msg, completion: completion)
                    }
                } else {
                    if let attachMessage, !attachMessage.isEmpty {
                        self?.sendText(text: attachMessage, to: sourceID, conversationType: type) { _ in
                        }
                    }
                    completion([])
                }
            }
        }
    }
    
    private func sendForwardMessage(to userID: String?, or groupID: String?, attachMessage: String? = nil, completion: @escaping ([Section]) -> Void) {
        assert(userID != nil || groupID != nil)
        
        let type: ConversationType = userID != nil ? .c2c : .superGroup
        let recvID = (type == .c2c ? userID : groupID)!
        
        // When selecting multiple people, the sending status is reset when sending, resulting in failure to send successfully.
        let tempSelectedMessage = selecteMessages.first!
        tempSelectedMessage.status = .sendSuccess
        
        IMController.shared.sendForwardMessage(message: tempSelectedMessage,
                                               to: recvID,
                                               conversationType: type)
        { [weak self] msg in
            if recvID == self?.receiverId {
                self?.appendMessage(msg, completion: completion)
            }
        } onComplete: { [weak self] msg in
            if recvID == self?.receiverId {
                if let attachMessage, !attachMessage.isEmpty {
                    self?.sendText(text: attachMessage, to: recvID, conversationType: type) { _ in
                        self?.appendMessage(msg, completion: completion)
                    }
                } else {
                    self?.appendMessage(msg, completion: completion)
                }
            } else {
                if let attachMessage, !attachMessage.isEmpty {
                    self?.sendText(text: attachMessage, to: recvID, conversationType: type) { _ in
                    }
                }
                completion([])
            }
        }
    }
    
    private func sendCard(user: User, completion: @escaping ([Section]) -> Void) {
        let card = CardElem(userID: user.id, nickname: user.name, faceURL: user.faceURL)

        IMController.shared.sendCardMessage(card: card,
                                            to: receiverId,
                                            conversationType: conversationType)
        { [weak self] msg in
            self?.appendMessage(msg, completion: completion)
        } onComplete: { [weak self] msg in
            self?.appendMessage(msg, completion: completion)
        }
    }
    
    private func sendLocation(location: LocationMessageSource, completion: @escaping ([Section]) -> Void) {
        IMController.shared.sendLocation(latitude: location.latitude,
                                         longitude: location.longitude,
                                         desc: location.desc,
                                         to: receiverId,
                                         conversationType: conversationType)
        { [weak self] msg in
            self?.appendMessage(msg, completion: completion)
        } onComplete: { [weak self] msg in
            self?.appendMessage(msg, completion: completion)
        }
    }
    
    private func sendFace(face: FaceMessageSource, completion: @escaping ([Section]) -> Void) {
        let param = ["url": face.url.absoluteString, "width": 60, "height": 60] as [String: Any]
        if let json = try? JSONSerialization.data(withJSONObject: param, options: .fragmentsAllowed), let jsonStr = String(data: json, encoding: .utf8) {
            if let localPath = face.localPath {
                DefaultImageCacher.cacheLocalData(path: localPath)
            }
            
            IMController.shared.sendFaceMessage(data: jsonStr,
                                                index: -1,
                                                to: receiverId,
                                                conversationType: conversationType)
            { [weak self] msg in
                self?.appendMessage(msg, completion: completion)
            } onComplete: { [weak self] msg in
                self?.appendMessage(msg, completion: completion)
            }
        }
    }
    
    private func sendAtMessage(text: String, quoteMessage: MessageInfo? = nil, completion: @escaping ([Section]) -> Void) {
        var atUsers: [AtInfo] = []
        var tempText = text
        
        for id in selectedUsers {
            if id == IMController.shared.atAllTag() {
                let atAllText = "所有人".innerLocalized()
                let all = IMController.shared.createAtAllFlag(displayText: atAllText)
                atUsers.append(all)
                tempText = tempText.replacingOccurrences(of: atAllText, with: id)
            }
            if let first = groupMembers?.first(where: { $0.userID == id }) {
                atUsers.append(AtInfo(atUserID: first.userID!, groupNickname: first.nickname!))
                tempText = tempText.replacingOccurrences(of: "@\(first.nickname!)", with: "@\(first.userID!)")
            }
        }
        
        if !selectedUsers.isEmpty {
            tempText += " " // There is a problem on the desktop/flutter side, "@member" must be followed by a space. eg: "@Jhon "
        }
        
        IMController.shared.sendAtTextMessage(text: tempText, atUsers: atUsers, quoteMessage: quoteMessage, to: receiverId, conversationType: conversationType) { [weak self] msg in
            self?.appendMessage(msg, completion: completion)
        } onComplete: { [weak self] msg in
            self?.appendMessage(msg, completion: completion)
            self?.selecteMessages.removeAll()
            self?.selectedUsers.removeAll()
        }
    }
    
    // MARK: 更新数据源

    private func appendMessage(_ message: MessageInfo, completion: @escaping ([Section]) -> Void) {
        // 刷新数据源
        var exist = false
        
        for (i, item) in messages.enumerated() {
            if item.clientMsgID == message.clientMsgID {
                messages[i] = message
                exist = true
                break
            }
        }
        
        if !exist {
            messages.append(message)
            
            if message.contentType == .image || message.contentType == .video {
                appendMediaMessage(msg: convertMessage(message))
            }
        }
        
        propagateLatestMessages(completion: completion)
    }
    
    private func replaceMessage(_ message: MessageInfo) {
        for (i, item) in messages.enumerated() {
            if item.clientMsgID == message.clientMsgID {
                messages[i] = message
                break
            }
        }
    }
    
    // MARK: - 张亚飞打的标记  消息添加到消息列表

    private func appendConvertingToMessages(_ rawMessages: [MessageInfo], removeAll: Bool = false) {
        if removeAll {
            messages.removeAll()
        }
        // If it is a private message, this message needs to be removed.
        let temp: [MessageInfo] = rawMessages.flatMap { msg in
            if msg.attachedInfoElem?.isPrivateChat == true,
               let hasReadTime = msg.attachedInfoElem?.hasReadTime,
               let duration = msg.attachedInfoElem?.burnDuration
            {
                let timestamp = NSDate().timeIntervalSince1970 * 1000
                
                if hasReadTime > 0 {
                    let end = hasReadTime + (duration * 1000)
                    var diff = (end - timestamp) / 1000
                    let countdownTime = Int(ceil(diff < 0 ? 0 : diff))
                    
                    if countdownTime <= 0 {
                        return nil
                    } else {
                        return msg
                    }
                } else if !msg.isRead {
                    return msg
                }
                return nil
            } else {
                return msg
            }
        }
        var messages = messages
        messages.append(contentsOf: temp)
        self.messages = messages.sorted(by: { $0.sendTime < $1.sendTime })
    }
    
    private func insertConvertingToMessages(_ rawMessages: [MessageInfo]) {
        var messages = messages
        messages.insert(contentsOf: rawMessages, at: 0)
        self.messages = messages.sorted(by: { $0.sendTime < $1.sendTime })
    }
    
    private func propagateLatestMessages(completion: @escaping ([Section]) -> Void) {
        var lastMessageStorage: Message?
        dispatchQueue.async { [weak self] in
            guard let self else { return }
            
            let messagesSplitByDay = self.messages
                .map { self.convertMessage($0) }
                .reduce(into: [[Message]]()) { result, message in
                    guard var section = result.last,
//                          let prevMessage = section.last
                          let prevMessage = section.first
                    else {
                        let section = [message]
                        result.append(section)
                        return
                    }                    
                    // 使用Calendar类和Component进行计算
                    let calendar = Calendar.current
                    let components = calendar.dateComponents([.minute], from: prevMessage.date, to: message.date)
                    let minutes = components.minute
                    if minutes ?? 0 < 10 {
                        section.append(message)
                        result[result.count - 1] = section
                    } else {
                        let section = [message]
                        result.append(section)
                    }
                    
//                    if Calendar.current.isDate(prevMessage.date, equalTo: message.date, toGranularity: .hour) {
//                        section.append(message)
//                        result[result.count - 1] = section
//                    } else {
//                        let section = [message]
//                        result.append(section)
//                    }
                }
            
            let cells = messagesSplitByDay.enumerated().map { index, messages -> [Cell] in // 按天划分
                var cells: [Cell] = Array(messages.enumerated().map { _, message -> [Cell] in // 按发送者划分
                    
                    if message.contentType == .system, case .attributeText(let value) = message.data {
                        let systemCell = Cell.systemMessage(SystemGroup(id: message.id, value: value))
                        return [systemCell]
                    }
                    
                    // Plan A
                    /*
                     
                     let bubble: Cell.BubbleType
                     if index < messages.count - 1 {
                         let nextMessage = messages[index + 1]
                         bubble = nextMessage.owner == message.owner ? .normal : .tailed
                     } else {
                         bubble = .tailed
                     }
                    
                     guard message.type != .outgoing else {
                         lastMessageStorage = message
                         return [.message(message, bubbleType: bubble)]
                     }
                    
                     let titleCell = Cell.messageGroup(MessageGroup(id: message.id, title: "\(message.owner.name) \(Date.timeString(date: message.date))", type: message.type))
                    
                     if let lastMessage = lastMessageStorage {
                         if lastMessage.owner != message.owner {
                             lastMessageStorage = message
                             return [titleCell, .message(message, bubbleType: bubble)]
                         } else {
                             lastMessageStorage = message
                             return [titleCell, .message(message, bubbleType: bubble)]
                         }
                     } else {
                         lastMessageStorage = message
                         return [titleCell, .message(message, bubbleType: bubble)]
                     }
                     
                      return [.message(message, bubbleType: bubble)]
                     */
                    // Plan B
                    return [.message(message, bubbleType: .normal)]
                }.joined())
                
                if let firstMessage = messages.first {
                    let conversation = self.getConversation()
                    if conversation.conversationType != .notification{
                        let dateCell = Cell.date(DateGroup(id: firstMessage.id, date: firstMessage.date))
                        cells.insert(dateCell, at: 0)
                    }
                }
                
                if self.typingState == .typing,
                   index == messagesSplitByDay.count - 1
                {
                    cells.append(.typingIndicator)
                }
                
                return cells // Section(id: sectionTitle.hashValue, title: sectionTitle, cells: cells)
            }.joined()
            
            DispatchQueue.main.async { [self] in

                completion([Section(id: 0, title: "", cells: Array(cells))])
            }
        }
    }
    
    private func convertMessage(_ msg: MessageInfo) -> Message {
        func configStatus(_ msg: MessageInfo) -> MessageStatus {
            // Exclude messages that failed to send.
            guard msg.status != .sendFailure else { return .sentFailure }
            guard msg.status != .sending else { return .sending }
            
            var info = AttachInfo()
            guard msg.contentType != .groupAnnouncement else { return .sent(info) }
            
            // Set read information
            if msg.sessionType == .c2c, msg.serverMsgID != nil, msg.isOutgoing {
                let tips = msg.isRead ? "已读".innerLocalized() : "未读".innerLocalized()
                info = AttachInfo(readedStatus: .signalReaded(msg.isRead), text: tips)
            } else if let groupInfo, msg.sessionType == .superGroup {
                // There are merged messages of groups in single chat.
                let readCount = msg.attachedInfoElem?.groupHasReadInfo?.hasReadCount ?? 0
                let unReadCount = msg.attachedInfoElem?.groupHasReadInfo?.unreadCount ?? 0
                let tips = unReadCount <= 0 ? "全部".innerLocalized() + "已读".innerLocalized() : "\(unReadCount)" + "未读".innerLocalized()
                info = AttachInfo(readedStatus: .groupReaded(msg.isRead, unReadCount <= 0), text: tips)
            }
            
            // Burnable content
            if let attchInfo = msg.attachedInfoElem, attchInfo.isPrivateChat {
                info = AttachInfo(readedStatus: .signalReaded(msg.isRead),
                                  text: info.text,
                                  isPriavte: attchInfo.isPrivateChat,
                                  duration: attchInfo.burnDuration,
                                  hasReadTime: msg.hasReadTime)
            }
            
            return .sent(info)
        }
        
        var type = msg.contentType.rawValue > MessageContentType.face.rawValue ? MessageRawType.system : MessageRawType.normal
        
        // For example, messages such as being blocked by friends need to be displayed as system prompts.
        if msg.contentType == .custom && (msg.customElem?.type == .deletedByFriend || msg.customElem?.type == .blockedByFriend) {
            type = .system
        }
        
        return Message(id: msg.clientMsgID,
                       date: Date(timeIntervalSince1970: msg.sendTime / 1000),
                       contentType: type,
                       sessionType: msg.sessionType == .superGroup ? .group : .single,
                       data: convert(msg),
                       owner: User(id: msg.sendID, name: msg.senderNickname ?? "", faceURL: msg.senderFaceUrl),
                       type: msg.isOutgoing ? .outgoing : .incoming,
                       status: configStatus(msg),
                       isSelected: msg.isSelected,
                       isAnchor: msg.isAnchor)
    }
    
    private func convert(_ msg: MessageInfo) -> Message.Data {
        do {
            var isSending = msg.serverMsgID == nil // To send locally, first render the message to the interface; after the sending is successful, replace the original message.
            
            switch msg.contentType {
            case .text:
                let textElem = msg.textElem!

                // MARK: - 张亚飞打的标记  重中之重 消息的扩展给文本消息

                var source = TextMessageSource(text: textElem.content, ex: msg.ex)
                
                if let ex = msg.localEx {
                    let ex = JsonTool.fromJson(ex, toClass: MessageEx.self)
                    source.ex = ex?.translate
                }
                
                return .text(source)
                
            case .image:
                let pictureElem = msg.pictureElem!
                let thumbURL = isSending ? pictureElem.sourcePath!.toFileURL() : URL(string: pictureElem.snapshotPicture!.url!.defaultThumbnailURLString)!
                let url = isSending ? pictureElem.sourcePath!.toFileURL() : pictureElem.sourcePicture!.url!.toURL()
                let isPresentLocally = KingfisherManager.shared.cache.isCached(forKey: thumbURL.absoluteString)
                let size = CGSize(width: pictureElem.sourcePicture!.width, height: pictureElem.sourcePicture!.height)
                
                let source = MediaMessageSource(source: MediaMessageSource.Info(url: url, size: size), thumb: MediaMessageSource.Info(url: thumbURL, size: size))
                
                return .image(source, isLocallyStored: isPresentLocally)
                
            case .video:
                let videoElem = msg.videoElem!
                var localPath = videoElem.videoPath ?? ""
                
                var url = isSending ? localPath.toFileURL() : videoElem.videoUrl?.toURL()
                
                if !isSending {
                    let subPath = localPath.components(separatedBy: "Documents").last
                    let sandboxPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""
                    localPath = sandboxPath + subPath!
                    
                    let localVideoCanLoad = FileManager.default.fileExists(atPath: localPath)
                    url = localVideoCanLoad ? localPath.toFileURL() : url
                }
                
                let thumbURL = isSending ? videoElem.snapshotPath!.toFileURL() : URL(string: videoElem.snapshotUrl?.defaultThumbnailURLString ?? "")
                let isPresentLocally = thumbURL == nil ? false : KingfisherManager.shared.cache.isCached(forKey: thumbURL!.absoluteString)
                let duration = msg.videoElem!.duration
                let size = CGSize(width: videoElem.snapshotWidth, height: videoElem.snapshotHeight)

                let source = MediaMessageSource(source: MediaMessageSource.Info(url: url, size: size),
                                                thumb: MediaMessageSource.Info(url: thumbURL, size: size),
                                                duration: duration)
                
                return .video(source, isLocallyStored: isPresentLocally)
                
            case .audio:
                let soundElem = msg.soundElem!
                let url = isSending ? soundElem.soundPath!.toFileURL() : soundElem.sourceUrl!.toURL()!
                let duration = soundElem.duration
                let isLocallyStored = FileHelper.shared.exsit(path: url.relativeString) != nil
                
                var source = MediaMessageSource(source: MediaMessageSource.Info(url: url), duration: duration)

                if let ex = msg.localEx {
                    let ex = JsonTool.fromJson(ex, toClass: MessageEx.self)
                    source.ex = ex
                } else {
                    source.ex = MessageEx()
                }
                
                return .audio(source, isLocallyStored: isLocallyStored)
                
            case .file:
                let fileElem = msg.fileElem!
                let url = isSending ? fileElem.filePath?.toFileURL() : fileElem.sourceUrl!.toURL()
                
                let size = fileElem.fileSize
                let name = fileElem.fileName!
                // For files sent by yourself, first determine the local address and pay attention to the name of the local path.
                var isLocallyStored = false
                if let filePath = fileElem.filePath {
                    isLocallyStored = FileHelper.shared.exsit(path: filePath, name: name) != nil
                    if !isLocallyStored, let url = fileElem.sourceUrl {
                        isLocallyStored = FileHelper.shared.exsit(path: url, name: name) != nil
                    }
                } else {
                    if let url = fileElem.sourceUrl {
                        isLocallyStored = FileHelper.shared.exsit(path: url, name: name) != nil
                    }
                }
                
                let source = FileMessageSource(url: url, length: size, name: name)
                
                return .file(source, isLocallyStored: isLocallyStored)
                
            case .quote:
                let quoteElem = msg.quoteElem!
                var text = quoteElem.text!
                let quoteMsg = quoteElem.quoteMessage!
                
                var source: QuoteMessageSource!
                var quoteSource: Message.Data!
                
                if quoteMsg.contentType == .revoke {
                    quoteSource = .attributeText(NSAttributedString(string: "quoteContentBeRevoked".innerLocalized()))
                } else {
                    quoteSource = convert(quoteMsg)
                }
                
                // Do not display the text message of the reply. Comment it out first.
                //            if quoteElem.quoteMessage?.contentType == .at {
                //                text = quoteMsg.atTextElem!.atText
                //            }
                source = QuoteMessageSource(sender: quoteElem.quoteMessage?.senderNickname ?? "",
                                            text: text,
                                            quoteMessageID: quoteElem.quoteMessage?.clientMsgID,
                                            quote: quoteSource)
                
                return .quote(source)
                
            case .merge:
                let mergeElem = msg.mergeElem!
                let title = mergeElem.title!
                let abstractList = mergeElem.abstractList
                let multiMessage = mergeElem.multiMessage?.map { convertMessage($0) }
                
                let source = MergeMessageSource(title: title, abstractList: abstractList, multiMessage: multiMessage)
                
                return .merge(source)
                
            case .card:
                let cardElem = msg.cardElem
                
                let source = CardMessageSource(user: User(id: cardElem?.userID ?? "", name: cardElem?.nickname ?? "", faceURL: cardElem?.faceURL ?? ""))
                
                return .card(source)
                
            case .location:
                let location = msg.locationElem!
                let longitude = location.longitude
                let latitude = location.latitude
                let desc = location.desc ?? ""
                
                let param = try? JSONSerialization.jsonObject(with: desc.data(using: .utf8)!) as? [String: Any]
                let name = param?["name"] as? String
                let address = param?["addr"] as? String
//                let url = (param?["url"] as! String).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                let url = LocationViewController.getStaticMapURL(longitude: longitude, latitude: latitude)
                let source = LocationMessageSource(url: url, name: name, address: address, latitude: latitude, longitude: longitude)
                
                return .location(source)
            case .at:
                let atElem = msg.atTextElem!
                var text = atElem.atText
                let atUsersInfo = atElem.atUsersInfo ?? []
                
                // There is no need to overlay and nest, just display one layer.
                atElem.quoteMessage?.quoteElem?.quoteMessage = nil
                atElem.quoteMessage?.atTextElem?.quoteMessage = nil
                
                // 如果@消息中有引用消息，变换成引用消息的样式
                if let quoteMessage = atElem.quoteMessage {
                    let quoteSource = convert(quoteMessage)
                    
                    let source = QuoteMessageSource(sender: quoteMessage.senderNickname ?? "",
                                                    text: text,
                                                    attributedString: atElem.atAttributeString,
                                                    quoteMessageID: quoteMessage.clientMsgID,
                                                    quote: quoteSource)
                    
                    return .quote(source)
                }
                
                let source = MentionMessageSource(attributedString: atElem.atAttributeString)
                
                return .mention(source)
                
            case .groupAnnouncement:
                let noti = msg.notificationElem!
                
                let source = TextMessageSource(text: noti.group?.notification ?? "", type: .notice)
                
                return .text(source)
                
            case .oaNotification:
                let noti = msg.notificationElem!
                
                let source = NoticeMessageSource(type: .oa, detail: noti.detail)
                
                return .notice(source)
                
            case .face:
                let faceElem = msg.faceElem!
                
                let temp = faceElem.url!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                let url = URL(string: temp)!
                let isPresentLocally = KingfisherManager.shared.cache.isCached(forKey: url.customThumbnailURL()!.absoluteString)
                
                let source = FaceMessageSource(url: url, index: 0)
                
                return .face(source, isLocallyStored: isPresentLocally)
                
            case .custom:
                let value = msg.customMessageDetailAttributedString
                
                if msg.customElem?.type == .deletedByFriend || msg.customElem?.type == .blockedByFriend {
                    return .attributeText(value)
                } else {
                    let source = CustomMessageSource(data: msg.customElem?.data, attributedString: value)
                    
                    return .custom(source)
                }
            default:
                let value = msg.systemNotification(showReEdit: RevokedMessageStorage.isExsit(messageID: msg.clientMsgID))
                
                return .attributeText(value!)
            }
        } catch (let e) {
            print("\(#function) throws error: \(e)")
        }
    }
        
    private func repopulateMessages(requiresIsolatedProcess: Bool = false) {
        propagateLatestMessages { [weak self] sections in
            self?.delegate?.update(with: sections, requiresIsolatedProcess: requiresIsolatedProcess)
        }
    }
    
    // MARK: operate message
    
    private func deleteMessages(messages: [MessageInfo], completion: @escaping ([MessageInfo]) -> Void) {
        var result: [MessageInfo] = []
        var count = 0
        
        for (i, msg) in messages.enumerated() {
            IMController.shared.deleteMessage(conversation: conversation.conversationID,
                                              clientMsgID: msg.clientMsgID)
            { [weak self] _ in
                guard let self else { return }
                
                if msg.contentType == .image || msg.contentType == .video {
                    appendMediaMessage(msg: convertMessage(msg))
                }
                
                result.append(msg)
                count += 1
                
                if count == messages.count {
                    completion(result)
                }
            } onFailure: { errCode, _ in
                count += 1
                
                if errCode == 10005 {
                    result.append(msg)
                }
                
                if count == messages.count {
                    completion(result)
                }
            }
        }
    }
    
    // MARK: 其它操作

    private func getUnReadTotalCount() {
        IMController.shared.getTotalUnreadMsgCount { [weak self] count in
            self?.unReadCount = count
            self?.delegate?.updateUnreadCount(count: count)
        }
    }
    
    private func subscribeUsersStatus() {
        guard conversationType == .c2c else { return }
        
        IMController.shared.subscribeUsersStatus(userIDs: [receiverId]) { [weak self] status in
            guard let self, let s = status.first(where: { $0.userID == self.receiverId }) else { return }
            
            delegate?.onlineStatus(status: s)
        }
    }
    
    private func unSubscribeUsersStatus() {
        guard conversationType == .c2c else { return }
        
        IMController.shared.unsubscribeUsersStatus(userIDs: [receiverId]) { _ in
        }
    }
    
    private func resetGroupPrefix() {
        guard conversation.groupAtType != .normal else { return }
        
        IMController.shared.resetConversationGroupAtType(conversationID: conversation.conversationID) { _ in
        }
    }
}

extension DefaultChatController: DataProviderDelegate {
    func unreadCountChanged(count: Int) {
        if !recvMessageIsCurrentChat {
            delegate?.updateUnreadCount(count: count)
        }
    }
    
    func groupMembersChanged(added: Bool, info: GroupMemberInfo) {
        if info.groupID == receiverId {
            if added {
                groupMembers?.append(info)
            } else {
                groupMembers?.removeAll(where: { $0.userID == info.userID })
            }
        }
    }
    
    func friendInfoChanged(info: OUICore.FriendInfo) {
        if info.userID == otherInfo?.userID {
            otherInfo?.friendInfo = info
        }
        delegate?.friendInfoChanged(info: info)
    }
    
    func roomParticipantChanged(isVideo: Bool, members: [GroupMemberInfo]) {
        delegate?.roomParticipantChanged(isVideo: isVideo, members: members)
    }
    
    func groupMemberInfoChanged(info: GroupMemberInfo) {
        if info.isSelf {
            if info.muteEndTime > 0 {
                let timeStamp = NSDate().timeIntervalSince1970
                let mutedInfo = MutedInfo(mutedEndTime: info.muteEndTime,
                                          mutedText: "youMuted".innerLocalized(),
                                          muted: info.muteEndTime > timeStamp * 1000,
                                          mutedMe: true)
                delegate?.mute(info: mutedInfo)
            } else {
                delegate?.mute(info: MutedInfo())
            }
            
            isAdminOrOwner = info.isOwnerOrAdmin
        } else {
            if let index = groupMembers?.firstIndex(where: { $0.userID == info.userID }) {
                groupMembers![index] = info
            }
        }
    }
    
    func mute(info: MutedInfo) {
        if info.muted, info.mutedMe {
            if mutedTimer == nil {
                var tempInfo = info
                mutedTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
                    guard let self else { return }
                    
                    let timeStamp = NSDate().timeIntervalSince1970 * 1000
                    if timeStamp >= tempInfo.mutedEndTime {
                        mutedTimer?.invalidate()
                        mutedTimer = nil
                        
                        tempInfo.muted = false
                        delegate?.mute(info: info)
                    }
                }
            }
        } else {
            mutedTimer?.invalidate()
            mutedTimer = nil
        }
        
        delegate?.mute(info: info)
    }
    
    func groupInfoChanged(info: GroupInfo) {
        groupInfo = info
        
        if !isAdminOrOwner {
            let mutedInfo = MutedInfo(mutedEndTime: -1,
                                      mutedText: "全体禁言".innerLocalized(),
                                      muted: info.status == .muted)
            delegate?.mute(info: mutedInfo)
        }
        
        delegate?.groupInfoChanged(info: info)
    }
    
    func isInGroup(with isIn: Bool) {
        delegate?.isInGroup(with: isIn)
    }
    
    // MARK: - 张亚飞打的标记  接收消息

    func received(message: MessageInfo) {
        let sendID = message.sendID
        let receivID = message.recvID
        let msgGroupID = message.groupID
        let msgSessionType = message.sessionType
        let conversationType = conversation.conversationType
        let userID = conversation.userID
        let groupID = conversation.groupID
        
        let isCurSingleChat = msgSessionType == .c2c && conversationType == .c2c && (sendID == userID || sendID == IMController.shared.uid && receivID == userID)
        let isCurGroupChat = msgSessionType == .superGroup && conversationType == .superGroup && groupID == msgGroupID
        
        /// 接收消息时候对名字过滤
//        message.senderNickname = SuperStringUtil.getUserState(showname: message.senderNickname ?? "").n
        
        
        if isCurGroupChat || isCurSingleChat {
            recvMessageIsCurrentChat = true
            
            // MARK: - 张亚飞打的标记 conversation的扩展给message
            print(conversation.ex)
            message.ex = conversation.ex

            
            
            if conversation.ex != nil && message.textElem != nil {
                if conversation.ex!.length > 2 {
                    let exArr = conversation.ex?.components(separatedBy: "##")
                    translateReceivedMessage(message.textElem!.content, from: exArr![1], to: exArr![2], messageID: message.clientMsgID, message: message)
//                    updateMessageLocalEx(messageID: message.clientMsgID, ex: MessageEx(translate: conversation.ex!))
                } else {
                    message.ex = "translate##"
                    appendConvertingToMessages([message])
                }
            } else {
                appendConvertingToMessages([message])
            }
            
            markAllMessagesAsReceived { [weak self] in
                self?.markAllMessagesAsRead { [weak self] in
                    self?.repopulateMessages()
                }
            }
        } else {
            recvMessageIsCurrentChat = false
            // 左上角未读数加1，过滤多端同步的问题
            if !message.isMine {
                unReadCount += 1
//                delegate?.updateUnreadCount(count: unReadCount)
            }
        }
    }
    
    // MARK: - 张亚飞打的标记  翻译接收到的文字

    func translateReceivedMessage(_ content: String, from: String, to : String, messageID: String, message: MessageInfo) {
        print(content)
        
//        let body = JsonTool.toJson(fromObject: TranslateRequest(q: content, sign: nil)).data(using: .utf8)
        let request = TranslateRequest(q: content, from: from, to: to, sign: nil)
        var req = try! URLRequest(url: "http://api.fanyi.baidu.com/api/trans/vip/translate?q=\(request.q)&from=\(request.from)&to=\(request.to)&appid=\(request.appid)&salt=\(request.salt)&sign=\(request.sign!)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!, method: .get)
//        var req = try! URLRequest(url: "http://api.fanyi.baidu.com/api/trans/vip/translate)", method: .post)
//        req.httpBody = body
//        req.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        Alamofire.request(req).responseString { (response: DataResponse<String>) in
            switch response.result {
            case .success(let result):
                if let res = JsonTool.fromJson(result, toClass: ResponseTranslate<[transReslutItem]>.self) {
                    if res.trans_result?.count ??  0 >= 0 {
                        //如果scr == dst 说明from语言不是 设置的语言 不用翻译
                        print(res.trans_result![0].dst)
                        if res.trans_result![0].src != res.trans_result![0].dst {
                            self.updateMessageLocalEx(messageID: messageID, ex: MessageEx(translate: res.trans_result![0].dst))
                            
                            message.ex = res.trans_result![0].dst
                            self.appendConvertingToMessages([message])
                            self.markAllMessagesAsReceived { [weak self] in
                                self?.markAllMessagesAsRead { [weak self] in
                                    self?.repopulateMessages()
                                }
                            }
                        } else {
                            
                            
                            message.ex = "translate##"
                            self.appendConvertingToMessages([message])
                            self.markAllMessagesAsReceived { [weak self] in
                                self?.markAllMessagesAsRead { [weak self] in
                                    self?.repopulateMessages()
                                }
                            }
                        }
                        
                    } else {
                        
                    }
                }
            case .failure(let err):
                print(err)
                break
            }
        }
    }
    
    // MARK: - 张亚飞打的标记  刷新conversation.ex

    func updataeConversationEx() {
        OIMApi.updateConversationEx = { (conversationEx, _: @escaping (String) -> Void) in
            print(self.conversation.conversationID)
            self.conversation.ex = conversationEx
        }
        
        OIMApi.updateConversationCell = { (messageId, _: @escaping (String) -> Void) in
            print(messageId)
            self.reloadMessage(with: messageId)
            
            if let handler = OIMApi.reloadCollectionView {
                handler( {res in
                    
                })
            }
            
        }
    }
    
    func receivedRevokedInfo(info: MessageRevoked) {
        if var msg = messages.first(where: { $0.clientMsgID == info.clientMsgID }) {
            msg.contentType = .revoke
            msg.content = JsonTool.toJson(fromObject: info)
            repopulateMessages()
        }
    }
    
    func typingStateChanged(to state: TypingState) {
        typingState = state
        repopulateMessages()
    }
    
    func lastReadIdsChanged(signal ids: [String]?, group readInfos: [GroupMessageReadInfo]?) {
        lastReadIDs = ids
        groupReadedInfos = readInfos
        markAllMessagesAsRead { [weak self] in
            self?.repopulateMessages()
        }
    }
    
    func lastReceivedIdChanged(to id: String) {
        lastReceivedString = id
        markAllMessagesAsReceived { [weak self] in
//            self?.repopulateMessages()
        }
    }
    
    func markAllMessagesAsReceived(completion: @escaping () -> Void) {
        completion()
        // 目前没有标记已收到功能
    }
    
    func markAllMessagesAsRead(completion: @escaping () -> Void) {
        guard lastReadIDs?.isEmpty == false || groupReadedInfos?.isEmpty == false else {
            completion()
            return
        }
        dispatchQueue.async { [weak self] in
            guard let self else { return }
            
            if let groupReadedInfos {
                for (_, item) in groupReadedInfos.enumerated() {
                    var msg = messages.first(where: { $0.clientMsgID == item.clientMsgID })
                    msg?.attachedInfoElem?.groupHasReadInfo?.unreadCount = item.unreadCount
                    msg?.attachedInfoElem?.groupHasReadInfo?.hasReadCount = item.hasReadCount
                }
            } else {
                self.messages = self.messages.map { [weak self] message in
                    guard let self, !message.isRead else { return message }
                    
                    if lastReadIDs?.contains(message.clientMsgID) == true {
                        message.isRead = true
                        message.hasReadTime = NSDate().timeIntervalSince1970 * 1000
                    }
                    
                    return message
                }
            }
            groupReadedInfos = nil
            lastReadIDs?.removeAll()
            
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    func onlineStatus(status: UserStatusInfo) {
        if conversationType == .c2c {
            delegate?.onlineStatus(status: status)
        }
    }
}

// MARK: - 张亚飞打的标记  聊天刷新

extension DefaultChatController: ReloadDelegate {
    func reloadMessage(with id: String) {
        repopulateMessages()
    }
    
    func didTapContent(with id: String, data: Message.Data) {
        delegate?.didTapContent(with: id, data: data)
    }
    
    func didTapRead(messageID: String) {
        delegate?.didTapRead(messageID: messageID)
    }
    
    func resendMessage(messageID: String) {
        resend(messageID: messageID)
    }
    
    func removeMessage(messageID: String) {
        defaultSelecteMessage(with: messageID)
        deleteMessage {}
    }
}

extension DefaultChatController: EditingAccessoryControllerDelegate {
    func selecteMessage(with id: String) {
        seleteMessageHelper(with: id)
        repopulateMessages(requiresIsolatedProcess: true)
    }
    
    private func seleteMessageHelper(with id: String) {
        // 将选中的消息计入，用来删除，转发等
        if let index = selecteMessages.firstIndex(where: { $0.clientMsgID == id }) {
            selecteMessages.remove(at: index)
            messages.first(where: { $0.clientMsgID == id })?.isSelected = false
        } else {
            if let item = messages.first(where: { $0.clientMsgID == id }) {
                item.isSelected = true // 多选的时候用来记录选中项，主要是cell重用问题。
                selecteMessages.append(item)
            }
        }
    }
}

class TranslateRequest: Encodable {
     let q: String
     let from: String
     let to: String
     let appid: String = "20240516002053204"
     let key: String = "bM2EltHXo2Qyg3DjnryP"
     let salt: String = "1435661231458"
     let sign: String?
    
    init(q: String, from: String = "auto", to: String = "en", sign: String?) {
        self.q = q
        self.from = from
        self.to = to
        let signStr = "\(appid)\(q)\(salt)\(key)"
        self.sign = signStr.md5Str
        print(signStr, self.sign)
        
    }
}

class ResponseTranslate<T: Decodable> :Decodable {
    var trans_result: T? = nil
    var from: String?
    let to: String?
}

 
struct transReslutItem: Decodable {
    let src: String
    let dst: String
}
