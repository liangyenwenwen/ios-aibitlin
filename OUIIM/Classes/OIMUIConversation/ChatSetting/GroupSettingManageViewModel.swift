
import OUICore
import RxCocoa
import RxSwift

class GroupSettingManageViewModel {
    private(set) var groupInfo: GroupInfo
    
    private var groupID: String!
    
    var groupInfoRelay: BehaviorRelay<GroupInfo?> = .init(value: nil)
    let mutedAllRelay: BehaviorRelay<Bool> = .init(value: false)
    let canViewProfileRelay: BehaviorRelay<Bool> = .init(value: false)
    let canAddFriendRelay: BehaviorRelay<Bool> = .init(value: false)
    
    private(set) var allMembers: [String] = []

    init(groupInfo: GroupInfo) {
        self.groupInfo = groupInfo
        self.groupID = groupInfo.groupID
    }
    
    func initialStatus() {
        mutedAllRelay.accept(groupInfo.status == .muted)
        canViewProfileRelay.accept(groupInfo.lookMemberInfo == 1)
        canAddFriendRelay.accept(groupInfo.applyMemberFriend == 1)
        groupInfoRelay.accept(groupInfo)
    }
    
    func toggleCanViewProfile() {
        IMController.shared.setGroupLookMemberInfo(id: groupID, rule: canViewProfileRelay.value ? 0 : 1, completion: { [weak self] _ in
            guard let sself = self else { return }
            sself.canViewProfileRelay.accept(!sself.canViewProfileRelay.value)
        })
    }
    
    func toggleCanAddFriend() {
        IMController.shared.setGroupApplyMemberFriend(id: groupID, rule: canAddFriendRelay.value ? 0 : 1, completion: { [weak self] _ in
            guard let sself = self else { return }
            sself.canAddFriendRelay.accept(!sself.canAddFriendRelay.value)
        })
    }
    
    func toggleMuteAll() {
        IMController.shared.changeGroupMute(groupID: groupID, isMute: !mutedAllRelay.value, completion: { [weak self] _ in
            guard let sself = self else { return }
            sself.mutedAllRelay.accept(!sself.mutedAllRelay.value)
        })
    }

    
    func transferOwner(to uid: String, onSuccess: @escaping CallBack.VoidReturnVoid) {
        IMController.shared.transferOwner(groupId: groupID, to: uid) { r in
            onSuccess()
        }
    }
    
    func updateVerificationOption(type: GroupVerificationType) {
        IMController.shared.setGroupVerification(groupId: groupID, type: type) {[weak self] r in
            
            if var info = self?.groupInfoRelay.value {
                info.needVerification = type
                self?.groupInfoRelay.accept(info)
            }
        }
    }
}
