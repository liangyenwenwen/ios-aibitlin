
import OUICore
import RxRelay

class NewFriendListViewModel {
    let applications: BehaviorRelay<[FriendApplication]> = .init(value: [])
    let loading = BehaviorRelay<Bool>(value: false)

    func getNewFriendApplications() {
        loading.accept(true)

        var recipients: [FriendApplication] = []
        var applicants: [FriendApplication] = []

        let group = DispatchGroup()
        
        group.enter()
        IMController.shared.getFriendApplicationListAsApplicant { a in
            recipients.append(contentsOf: a)
            group.leave()
        }
        
        group.enter()
        IMController.shared.getFriendApplicationListAsRecipient { a in
            applicants.append(contentsOf: a)
            group.leave()
        }
        
        group.notify(queue: .main) { [self] in
            var t = recipients + applicants
            var new: [FriendApplication] = []
            
            t.forEach { info in
                if info.handleResult == .normal, !isSendOut(userID: info.fromUserID) {
                    new.insert(info, at: 0)
                } else {
                    new.append(info)
                }
            }
            
            applications.accept(new)
            loading.accept(false)
        }
    }

    func acceptFriendWith(uid: String) {
        IMController.shared.acceptFriendApplication(uid: uid, completion: { [weak self] (_: String?) in
            self?.getNewFriendApplications()
            // 发送通知，告诉列表入群申请或者好友申请数量发生改变
            NotificationCenter.default.post(name: ContactsViewModel.NotificationApplicationCountChanged, object: nil)
        })
    }
    
    func isSendOut(userID: String) -> Bool {
        userID == IMController.shared.uid
    }
}
