
import OUICore
import RxRelay
import RxSwift

class UnreadListViewModel {
    let isHasReadTableSelected: BehaviorRelay<Bool> = .init(value: false)
    let items: BehaviorRelay<[GroupMemberInfo]> = .init(value: [])
    let lettersRelay: BehaviorRelay<[String]> = .init(value: [])
    
    let hasReadCountRelay: BehaviorRelay<Int> = .init(value: 0)
    let unReadCountRelay: BehaviorRelay<Int> = .init(value: 0)
    
    private let _disposeBag = DisposeBag()
    private var iHasReadMembers: [GroupMemberInfo] = []
    private var iUnReadMembers: [GroupMemberInfo] = []
    var members: [GroupMemberInfo] = []
    var contactSections: [[GroupMemberInfo]] = []
    
    private let conversationID: String
    private let clientMsgID: String
    
    init(conversationID: String, clientMsgID: String) {
        self.conversationID = conversationID
        self.clientMsgID = clientMsgID
        
        isHasReadTableSelected.subscribe(onNext: { [weak self] (isICreated: Bool) in
            guard let sself = self else { return }
            if isICreated {
                self?.items.accept(sself.iHasReadMembers)
            } else {
                self?.items.accept(sself.iUnReadMembers)
            }
        }).disposed(by: _disposeBag)
        
        IMController.shared.groupReadReceiptReceived.subscribe(onNext: { [weak self] receipt in
            self?.getReadStatusMembers()
        }).disposed(by: _disposeBag)
    }

    func getReadStatusMembers() {
        
        IMController.shared.getGroupMessageReaderList(conversationID: conversationID, clientMsgID: clientMsgID, filter: 1, count: 10000) { [weak self] ms in
            guard let self else { return }
            iUnReadMembers = ms
            unReadCountRelay.accept(ms.count)
            isHasReadTableSelected.accept(false)
        }
        
        IMController.shared.getGroupMessageReaderList(conversationID: conversationID, clientMsgID: clientMsgID, filter: 0, count: 10000) { [weak self] ms in
            guard let self else { return }
            iHasReadMembers = ms
            hasReadCountRelay.accept(ms.count)
        }
    }
    
    func getUsersAt(indexPaths: [IndexPath]) -> [UserInfo] {
        var users: [UserInfo] = []
        for indexPath in indexPaths {
            let member = contactSections[indexPath.section][indexPath.row]
            let user = UserInfo(userID: member.userID!)
            user.faceURL = member.faceURL
            user.nickname = member.nickname
            
            users.append(user)
        }
        return users
    }
    
    private func divideUsersInSection(users: [GroupMemberInfo]) {
        DispatchQueue.global().async { [weak self] in
            var letterSet: Set<String> = []
            for user in users {
                if let firstLetter = user.nickname?.getFirstPinyinUppercaseCharactor() {
                    letterSet.insert(firstLetter)
                }
            }

            let letterArr: [String] = Array(letterSet)
            let ret = letterArr.sorted { $0 < $1 }

            for letter in ret {
                var sectionArr: [GroupMemberInfo] = []
                for user in users {
                    if let first = user.nickname?.getFirstPinyinUppercaseCharactor(), first == letter {
                        sectionArr.append(user)
                    }
                }
                self?.contactSections.append(sectionArr)
            }
            DispatchQueue.main.async {
                self?.lettersRelay.accept(ret)
            }
        }
    }
}
