
import OUICore
import RxRelay
import RxSwift
import Differentiator

enum GlobalSearchRowType {
    case all
    case friends
    case groups
    case text
    case file

    var title: String {
        switch self {
        case .all:
            return "综合".innerLocalized()
        case .friends:
            return "联系人".innerLocalized()
        case .groups:
            return "群组".innerLocalized()
        case .text:
            return "聊天记录".innerLocalized()
        case .file:
            return "文件".innerLocalized()
        }
    }
}

class GlobalSearchViewModel {
    
    let allRelay: BehaviorRelay<[SectionModel<GlobalSearchRowType, Any>]> = .init(value: [])
    let friendsRelay: BehaviorRelay<[SearchUserInfo]> = .init(value: [])
    let groupsRelay: BehaviorRelay<[GroupInfo]> = .init(value: [])
    let textRelay: BehaviorRelay<[SearchResultItemInfo]> = .init(value: [])
    let filesRelay: BehaviorRelay<[SearchResultItemInfo]> = .init(value: [])
    
    var searchedText: String?
    
    private let disposeBag = DisposeBag()
    
    func searchAll(query: String, completion: (() -> Void)? = nil) {
        Observable.zip(friendsRelay, groupsRelay, textRelay, filesRelay)
            .subscribe(onNext:{ [weak self] (friends: [SearchUserInfo], groups: [GroupInfo], text: [SearchResultItemInfo], files: [SearchResultItemInfo]) in

                var all: [SectionModel<GlobalSearchRowType, Any>] = []

                if !friends.isEmpty {
                    var result = friends.suffix(2) as Array
                    
                    if friends.count > 2 {
                        let fakeMore = SearchUserInfo()
                        fakeMore.userID = "-1"
                        fakeMore.nickname = "seeMoreRelatedContacts".innerLocalized()
                        
                        result.append(fakeMore)
                    }
                    
                    all.append(SectionModel(model: GlobalSearchRowType.friends, items: result))
                }

                if !groups.isEmpty {
                    var result = groups.suffix(2) as Array
                    
                    if groups.count > 2 {
                        let fakeMore = GroupInfo(groupID: "-1", groupName: "seeMoreRelatedGroup".innerLocalized())
                        
                        result.append(fakeMore)
                    }
                    
                    all.append(SectionModel(model: GlobalSearchRowType.groups, items: result))
                }

                if !text.isEmpty {
                    var result = text.suffix(2) as Array
                    
                    if text.count > 2 {
                        let fakeMore = SearchResultItemInfo()
                        fakeMore.conversationID = "-1"
                        fakeMore.showName = "seeMoreRelatedChatHistory".innerLocalized()
                        
                        result.append(fakeMore)
                    }
                    
                    all.append(SectionModel(model: GlobalSearchRowType.text, items: result))
                }

                if !files.isEmpty {
                    var result = files.suffix(2) as Array
                    
                    if files.count > 2 {
                        let fakeMore = SearchResultItemInfo()
                        fakeMore.conversationID = "-1"
                        fakeMore.showName = "seeMoreRelatedFile".innerLocalized()
                        
                        result.append(fakeMore)
                    }
                    
                    all.append(SectionModel(model: GlobalSearchRowType.file, items: result))
                }
            
                self?.allRelay.accept(all)
                self?.searchedText = query
                completion?()
            })
            .disposed(by: disposeBag)

        searchFile(query: query)
        searchText(query: query)
        searchFriends(query: query)
        searchGroups(query: query)
    }
    
    func searchFile(query: String) {

        let param = SearchParam()
        param.keywordList = [query]
        param.messageTypeList = [.file]

        IMController.shared.searchRecord(param: param) {[weak self] result in
            self?.filesRelay.accept(result?.searchResultItems ?? [])
        }
    }

    func searchText(query: String, conversationID: String? = nil) {

        guard !query.isEmpty else {
            textRelay.accept([])
            
            return
        }
        let param = SearchParam()
        param.keywordList = [query]
        param.messageTypeList = [.text, .at]
        
        if let conversationID {
            param.conversationID = conversationID
        }

        IMController.shared.searchRecord(param: param) {[weak self] result in
            self?.textRelay.accept(result?.searchResultItems ?? [])
        }
    }

    func searchGroups(query: String) {

        let param = SearchGroupParam()
        param.keywordList = [query]

        IMController.shared.searchGroups(param: param) {[weak self] result in
            self?.groupsRelay.accept(result ?? [])
        }
    }
    
    func searchFriends(query: String) {
        
        let param = SearchUserParam()
        param.keywordList = [query]
        
        IMController.shared.searchFriends(param: param) {[weak self] result in
            self?.friendsRelay.accept(result ?? [])
        }
    }
}
