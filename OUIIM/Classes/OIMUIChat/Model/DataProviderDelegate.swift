
import OUICore

protocol DataProviderDelegate: AnyObject {

    func received(message: MessageInfo)
    
    func receivedRevokedInfo(info: MessageRevoked)

    func typingStateChanged(to state: TypingState)

    func lastReadIdsChanged(signal ids: [String]?, group readIndos: [GroupMessageReadInfo]?)
    
    func lastReceivedIdChanged(to id: String)
    
    func isInGroup(with isIn: Bool)
    
    func mute(info: MutedInfo)
    
    func groupMemberInfoChanged(info: GroupMemberInfo)
    
    func groupInfoChanged(info: GroupInfo)
    
    func roomParticipantChanged(isVideo: Bool, members: [GroupMemberInfo])
    
    func onlineStatus(status: UserStatusInfo)
    
    func friendInfoChanged(info: FriendInfo)
    
    func groupMembersChanged(added: Bool, info: GroupMemberInfo)
    
    func unreadCountChanged(count: Int)
}
