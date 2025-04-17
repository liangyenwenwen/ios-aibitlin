
import OUICore
import RxRelay
import RxSwift

class MemberListViewModel {
    let lettersRelay: BehaviorRelay<[String]> = .init(value: [])
    var membersRelay: BehaviorRelay<[GroupMemberInfo]> = .init(value: [])
    var contactSections: [[GroupMemberInfo]] = []
    var targetUserId: String?
    let targetIndexRelay: BehaviorRelay<IndexPath?> = .init(value: nil)
    let ownerAndAdminRelay: BehaviorRelay<[GroupMemberInfo]> = .init(value: [])
    
    let groupInfo: GroupInfo
    private var offset = 0
    private let limit = 100
    private let _disposeBag = DisposeBag()
    
    init(groupInfo: GroupInfo) {
        self.groupInfo = groupInfo
        
        IMController.shared.groupMemberInfoChange.subscribe(onNext: { [weak self] info in
            guard let self else { return }
            resetMembersArray()
            getOwnerAndAdmin()
            getMoreMembers()
        }).disposed(by: _disposeBag)
        
        IMController.shared.groupMemberAdded.subscribe(onNext: { [weak self] info in
            // groupInfo.groupID 即为邀请你的群
            guard let self, groupInfo.groupID == info?.groupID else { return }
            resetMembersArray()
            getOwnerAndAdmin()
            getMoreMembers()
        }).disposed(by: _disposeBag)
        
        IMController.shared.groupMemberDeleted.subscribe(onNext: { [weak self] info in
            // groupInfo.groupID 即为踢出你的群 多人会进多次
            guard let self, groupInfo.groupID == info?.groupID else { return }
            resetMembersArray()
            getOwnerAndAdmin()
            getMoreMembers()
        }).disposed(by: _disposeBag)
    }
    
    func resetMembersArray() {
        self.offset = 0
        self.membersRelay.accept([])
    }
    
    func getOwnerAndAdmin() {
        IMController.shared.getGroupMemberList(groupId: groupInfo.groupID, filter: .superAndAdmin, offset: 0, count: limit) { [weak self] infos in
            self?.ownerAndAdminRelay.accept(infos)
        }onFailure: { errCode, errMsg in
            
        }
    }

    func getMoreMembers(completion: ((Bool) -> Void)? = nil) {
        IMController.shared.getGroupMemberList(groupId: groupInfo.groupID, filter: .member, offset: offset, count: limit) { [weak self] (ms: [GroupMemberInfo]) in
            guard let self else { return }

            if !ms.isEmpty {
                offset += min(limit, ms.count)
            }
            
            var temp = membersRelay.value
            temp.append(contentsOf: ms)

            // groupMemberDeleted 多人会进多次
            temp.reduce([], { (partialResult: [GroupMemberInfo], m) in
                partialResult.contains(where: { $0.userID == m.userID }) ? partialResult : partialResult + [m]
            })
            
            if ms.isEmpty, completion != nil {
                completion?(true)
                return
            }
            membersRelay.accept(temp)
            completion?(ms.count < limit ? true : false)
//            self?.divideUsersInSection(users: sself.members, completion: completion)
        }onFailure: { errCode, errMsg in
            
        }
    }

    func getUsersAt(indexPaths: [IndexPath]) -> [GroupMemberInfo] {
        var users: [GroupMemberInfo] = []
        for indexPath in indexPaths {
            let user = contactSections[indexPath.section][indexPath.row]
            users.append(user)
        }
        return users
    }

    private func divideUsersInSection(users: [GroupMemberInfo], completion: ((Bool)-> Void)?) {
        DispatchQueue.global().async { [weak self] in
            var letterSet: Set<String> = []
            for user in users {
                if let firstLetter = user.nickname?.getFirstPinyinUppercaseCharactor() {
                    letterSet.insert(firstLetter)
                }
            }

            var letterArr: [String] = Array(letterSet)
            var isContainsSharp = false
            if letterArr.contains("#") {
                isContainsSharp = true
                letterArr.removeAll { (value: String) in
                    return value == "#"
                }
            }
            var ret = letterArr.sorted()
            if isContainsSharp {
                ret.append("#")
            }
            var sections: [[GroupMemberInfo]] = []
            for letter in ret {
                var sectionArr: [GroupMemberInfo] = []
                for user in users {
                    if let first = user.nickname?.getFirstPinyinUppercaseCharactor(), first == letter {
                        sectionArr.append(user)
                    }
                }
                sections.append(sectionArr)
            }
            self?.contactSections = sections
            DispatchQueue.main.async {
                completion?(false)
                self?.lettersRelay.accept(ret)
                var indexPath: IndexPath?
                for (section, contacts) in sections.enumerated() {
                    for (row, contact) in contacts.enumerated() {
                        if contact.userID == self?.targetUserId {
                            indexPath = IndexPath.init(row: row, section: section)
                        }
                    }
                }
                self?.targetIndexRelay.accept(indexPath)
            }
        }
    }
}
