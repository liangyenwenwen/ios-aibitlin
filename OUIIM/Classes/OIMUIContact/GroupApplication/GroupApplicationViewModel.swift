
import OUICore
import RxRelay

class GroupApplicationViewModel {
    let applicationItems: BehaviorRelay<[GroupApplicationInfo]> = .init(value: [])
    let loading = BehaviorRelay<Bool>(value: false)

    func getGroupApplications() {
        
        var recipients: [GroupApplicationInfo] = []
        var applicants: [GroupApplicationInfo] = []

        loading.accept(true)
        let group = DispatchGroup()
        
        group.enter()
        IMController.shared.getGroupApplicationListAsRecipient { [weak self] a in
            
            recipients.append(contentsOf: a)
            group.leave()
        }
        
        group.enter()
        IMController.shared.getGroupApplicationListAsApplicant { a in
            
            applicants.append(contentsOf: a)
            group.leave()
        }
        
        group.notify(queue: .main) { [self] in
            var t = recipients + applicants
            var new: [GroupApplicationInfo] = []
            t.forEach { info in
                if info.handleResult == .normal, !isSendOut(userID: info.userID!) {
                    new.insert(info, at: 0)
                } else {
                    new.append(info)
                }
            }
            
            applicationItems.accept(new)
            loading.accept(false)
        }
    }

    func acceptApplicationWith(groupId: String, fromUserId: String) {
        IMController.shared.acceptGroupApplication(groupID: groupId, fromUserId: fromUserId) { [weak self] _ in
            self?.getGroupApplications()
            // 发送通知，告诉列表入群申请或者好友申请数量发生改变
            NotificationCenter.default.post(name: ContactsViewModel.NotificationApplicationCountChanged, object: nil)
        }
    }
    
    func apply(grouID: String? = nil, userID: String? = nil, reqMsg: String?, onSuccess: @escaping CallBack.StringOptionalReturnVoid) {
        if grouID != nil {
            IMController.shared.joinGroup(id: grouID!, reqMsg: reqMsg, onSuccess: onSuccess)
        } else {
            IMController.shared.addFriend(uid: userID!, reqMsg: reqMsg, onSuccess: onSuccess)
        }
    }
    
    func isSendOut(userID: String) -> Bool {
        userID == IMController.shared.uid
    }
}
