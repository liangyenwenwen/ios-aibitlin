
import OUICore
import RxRelay
import RxSwift


class NewGroupViewModel {
    
    var groupAvatar: String?
    var groupType: GroupType
    
    var membersRelay: BehaviorRelay<[UserInfo]> = .init(value: [])
    
    var contacts: [ContactInfo] = []
    private var friends: [ContactInfo] = []
    let loadingSubject: BehaviorSubject<Bool> = .init(value: false)
    let lettersRelay: BehaviorRelay<[String]> = .init(value: [])
    var contactsSections: [[ContactInfo]] = []
    init() {
        self.groupType = .normal
    }
    
    func getMyFriendList() {
        loadingSubject.onNext(true)
        IMController.shared.getFriendList { [weak self] users in
            guard let self else { return }

            contacts = users.map{ContactInfo(ID: $0.userID, name: $0.remark?.isEmpty == false ? $0.remark : $0.nickname, faceURL: $0.faceURL, type: .user)}
            friends.append(contentsOf: contacts)
            divideContactsInSection(contacts)
            loadingSubject.onNext(false)
        }
    }
    private func divideContactsInSection(_ contacts: [ContactInfo]) {
        DispatchQueue.global().async { [self] in
            self.contactsSections.removeAll()
            
            var letterSet: Set<String> = []
            for contact in contacts {
                if let firstLetter = contact.name?.getFirstPinyinUppercaseCharactor() {
                    letterSet.insert(firstLetter)
                }
            }

            let letterArr: [String] = Array(letterSet)
            let ret = letterArr.sorted { $0 < $1 }

            for letter in ret {
                var sectionArr: [ContactInfo] = []
                for contact in contacts {
                    if let first = contact.name?.getFirstPinyinUppercaseCharactor(), first == letter {
                        sectionArr.append(contact)
                    }
                }
                self.contactsSections.append(sectionArr)
            }
            
            DispatchQueue.main.async {
                self.lettersRelay.accept(ret)
            }
        }
    }
    func uploadFile(fullPath: String, onComplete: @escaping CallBack.StringOptionalReturnVoid) {
        IMController.shared.uploadFile(fullPath: fullPath, onProgress: { _ in
        }) { [weak self] url in
            onComplete(url)
        }
    }
    
    func createGroup(users:[ContactInfo],groupName:String,onSuccess: @escaping CallBack.ConversationInfoOptionalReturnVoid) {
    
        let userArray = users.map{UserInfo(userID: $0.ID!, nickname: $0.name, faceURL: $0.faceURL)}

        IMController.shared.createGroupConversation(users: userArray,
                                                    groupType: groupType,
                                                    groupName: groupName,
                                                    avatar: groupAvatar) { [weak self] groupInfo in
            
            guard let groupInfo = groupInfo, let sself = self else {
                onSuccess(nil)
                return
            }
            
            IMController.shared.getConversation(sessionType: .superGroup,
                                                sourceId: groupInfo.groupID) { [weak self] (conversation: ConversationInfo?) in
                onSuccess(conversation)
            }
        } onFailure: { code, msg in
            onSuccess(nil)
        }
    }
}
