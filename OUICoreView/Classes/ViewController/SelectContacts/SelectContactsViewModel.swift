
import OUICore
import RxRelay
import RxSwift
#if ENABLE_ORGANIZATION
import OUIOrganization // 组织架构不对外开放，这里只有特殊处理下
#endif

class SelectContactsViewModel {
    let tabSelected: BehaviorRelay<ContactType> = .init(value: .friends)
    let lettersRelay: BehaviorRelay<[String]> = .init(value: [])
    var contacts: [ContactInfo] = []
    var contactsSections: [[ContactInfo]] = []
    let searchResult: BehaviorRelay<[ContactInfo]> = .init(value: [])
    let loadingSubject: BehaviorSubject<Bool> = .init(value: false)
    
    // 多种组合选择才使用
    private var friends: [ContactInfo] = []
    private var groups: [ContactInfo] = []
    private var members: [ContactInfo] = []
    private var staff: [ContactInfo] = []
    private let _disposeBag = DisposeBag()
    
    init() {
        tabSelected.subscribe(onNext: { [weak self] (type: ContactType) in
            guard let `self` = self else { return }
            
            switch type {
            case .friends:
                self.divideContactsInSection(self.friends)
            case .members:
                self.divideContactsInSection(self.members)
            case .groups:
                self.divideContactsInSection(self.groups)
            case .staff:
                self.divideContactsInSection(self.staff)
            default:
                break
            }
        }).disposed(by: _disposeBag)
    }
    
    func getMyFriendList() {
        loadingSubject.onNext(true)
        IMController.shared.getFriendList { [weak self] users in
            guard let self else { return }

            contacts = users.map{ContactInfo(ID: $0.userID, name: $0.remark?.isEmpty == false ? $0.remark : $0.nickname, faceURL: $0.faceURL, type: .user)}
            friends.append(contentsOf: contacts)
            divideContactsInSection(contacts)
            loadingSubject.onNext(false)
        }onFailure: { errCode, errMsg in
            
        }
    }
    
    func getGroups() {
        IMController.shared.getJoinedGroupList { [weak self] g in
            guard let `self` = self else { return }
            self.contacts = g.map{ContactInfo(ID: $0.groupID, name: $0.groupName, faceURL: $0.faceURL, type: .group)}
            self.groups.append(contentsOf: self.contacts)
            if self.tabSelected.value == .undefine { // 好友+群组+组织架构，不要刷新界面
                self.divideContactsInSection(self.contacts)
            }
        }onFailure: { errCode, errMsg in
            
        }
    }
    
    func getGroupMemberList(groupID: String) {
        IMController.shared.getGroupMemberList(groupId: groupID, filter: .all, offset: 0, count: 1000010) { [weak self] (members: [GroupMemberInfo]) in
            guard let `self` = self else { return }

            self.contacts = members.compactMap({ info in
                if !info.isSelf {
                    return ContactInfo(ID: info.userID, name: info.nickname, faceURL: info.faceURL, sub: info.roleLevelString, type: .user)
                } else {
                    return nil
                }
            })
            self.members.append(contentsOf: self.contacts)
            self.divideContactsInSection(self.contacts)
        }onFailure: { errCode, errMsg in
            
        }
    }
    
    func search(keyword: String, type: [ContactType] = [.friends, .groups, .staff], sourceID: String? = nil) {
        var temp: [ContactInfo] = []
        
        let group = DispatchGroup()
        DispatchQueue.global().async { [self] in
            let param = SearchGroupParam()
            param.keywordList = [keyword]
            
            let param2 = SearchUserParam()
            param2.keywordList = [keyword]
            
            group.enter()
            IMController.shared.searchFriends(param: param2) {[weak self] result in
                temp.append(contentsOf: result.map{ContactInfo(ID: $0.userID, name: $0.nickname, faceURL: $0.faceURL)})
                group.leave()
            }
            
            if type.contains(.groups) {
                group.enter()
                IMController.shared.searchGroups(param: param) {[weak self] result in
                    temp.append(contentsOf: result.map{ContactInfo(ID: $0.groupID, name: $0.groupName, faceURL: $0.faceURL)})
                    group.leave()
                }
            }
            
            if type.contains(.friends) {
                let param2 = SearchUserParam()
                param2.keywordList = [keyword]
                
                group.enter()
                IMController.shared.searchFriends(param: param2) {[weak self] result in
                    temp.append(contentsOf: result.map{ContactInfo(ID: $0.userID, name: $0.nickname, faceURL: $0.faceURL)})
                    group.leave()
                }
            }
            
            if type.contains(.members) {
                group.enter()
                let result = members.filter({ $0.ID?.contains(keyword) == true || $0.name?.contains(keyword) == true })
                temp.append(contentsOf: result)
                group.leave()
            }
            
            if type.contains(.staff) {
#if ENABLE_ORGANIZATION
            OUIOrganization.DefaultDataProvider.searchOrganization(keyword: keyword) { [weak self] r in
                temp.append(contentsOf: r.map{ContactInfo(ID: $0.user?.userID, name: $0.user?.nickname, faceURL: $0.user?.faceURL)})
                    group.leave()
                }
#endif
            }
            
            group.notify(queue: .main) { [self]
                self.searchResult.accept(temp)
            }
        }
    }
    
    func getContactAt(indexPaths: [IndexPath]) -> [ContactInfo] {
        var users: [ContactInfo] = []
        for indexPath in indexPaths {
            let user = contactsSections[indexPath.section][indexPath.row]
            users.append(user)
        }
        return users
    }
    
    func getContact(by ID: String) -> ContactInfo? {
        return contacts.first(where: {$0.ID == ID})
    }
    
    // 从好友/群组获取
    func getContactIndexPath(by ID: String) -> IndexPath? {
        for (row, objectRow) in contactsSections.enumerated() {
            for (col, object) in objectRow.enumerated() {
                if object.ID == ID {
                    return IndexPath(row: col, section: row)
                }
            }
        }
        return nil
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
}
