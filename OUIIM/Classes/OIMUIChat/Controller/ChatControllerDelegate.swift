import Foundation
import OUICore

protocol ChatControllerDelegate: AnyObject {
    func isInGroup(with isIn: Bool)
    func update(with sections: [Section], requiresIsolatedProcess: Bool)
    func updateUnreadCount(count: Int)
    func didTapContent(with id: String, data: Message.Data)
    func didTapRead(messageID: String)
    func mute(info: MutedInfo)
    func roomParticipantChanged(isVideo: Bool, members: [GroupMemberInfo])
    func onlineStatus(status: UserStatusInfo)
    func groupInfoChanged(info: GroupInfo)
    func friendInfoChanged(info: FriendInfo)
}

extension ChatControllerDelegate {
    func isInGroup(with _: Bool) {}
    func updateUnreadCount(_: Int) {}
    func didTapContent(with _: String, _:  Message.Data) {}
    func didTapRead(_: String) {}
    func mute(_: MutedInfo) {}
    func roomParticipantChanged(_: Bool, _: [GroupMemberInfo]) {}
    func onlineStatus(_: UserStatusInfo) {}
    func groupInfoChanged(_: GroupInfo) {}
    func friendInfoChanged(_: FriendInfo) {}
}
