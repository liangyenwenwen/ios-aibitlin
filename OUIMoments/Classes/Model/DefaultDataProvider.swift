
import OUICore
import Alamofire
import RxSwift

private let baseURL: String = IMController.shared.businessServer
private let token: String = IMController.shared.businessToken!

public class DefaultDataProvider {
    
    private let disposeBag = DisposeBag()
    
    var onRecvNewMomentsChanged:((Int, MomentsInfo) -> Void)?
    
    init() {
        setupObserver()
    }
    
    func setupObserver() {
        IMController.shared.customBusinessSubject.subscribe(onNext: { [weak self] message in
            self?.queryUnreadCount { [weak self] count in
                if let message, let msg = JsonTool.fromMap(message, toClass: MomentsInfo.self) {
                    self?.onRecvNewMomentsChanged?(count, msg)
                }
            }
        }).disposed(by: disposeBag)
    }
    
    func publishMoments(type: Int,
                        text: String?,
                        metas: [[String: String]],
                        permisson: Int,
                        permissonFriends: [String],
                        permissonGroups: [String],
                        metionContacts: [String], completion:((_ msg: String?) -> Void)?) {
        
        if !metas.isEmpty {
            var m: [[String: String]] = []
            let group = DispatchGroup()
            let groupQueue = DispatchQueue.global()
            
            groupQueue.async(group: group) {
                m.append(contentsOf: metas)
                
                for (i, item) in metas.enumerated() {
                    let original = item["original"]
                    let thumb = item["thumb"]
                    
                    if let thumb {
                        group.enter()
                        IMController.shared.uploadFile(fullPath: thumb) { progress in
                        } onSuccess: { r in
                            m[i]["thumb"] = r
                            group.leave()
                        }
                    }
                    if let original {
                        group.enter()
                        IMController.shared.uploadFile(fullPath: original) { progress in
                        } onSuccess: { r in
                            m[i]["original"] = r
                            group.leave()
                        }
                    }
                }
            
            
                group.notify(queue: .main) { [self] in
                    publishHelper(type: type,
                                  text: text,
                                  metas: m,
                                  permisson: permisson,
                                  permissonFriends: permissonFriends,
                                  permissonGroups: permissonGroups,
                                  metionContacts: metionContacts, completion: completion)
                }
            }
        } else {
            publishHelper(type: type,
                          text: text,
                          metas: metas,
                          permisson: permisson,
                          permissonFriends: permissonFriends,
                          permissonGroups: permissonGroups,
                          metionContacts: metionContacts, completion: completion)
        }
    }
    
    func publishHelper(type: Int,
                       text: String?,
                       metas: [[String: String]],
                       permisson: Int,
                       permissonFriends: [String],
                       permissonGroups: [String],
                              metionContacts: [String], completion:((_ msg: String?) -> Void)?) {
        
        
        let data = ["type": type, "metas": metas, "text": text ?? ""] as [String : Any]

        let param = ["content": data,
                     "permissionUserIDs": permissonFriends,
                     "permissionGroupIDs": permissonGroups,
                     "atUserIDs": metionContacts,
                     "permission": permisson
        ] as [String : Any]
        
        OIMApi.publishMoments(param: param) { code, r in
            print("\(r)")
            completion?(code != 0 ? "发布失败": nil)
        }
    }
    
    func loadMoments(userID: String?, pageNumber: Int = 1, pageCount: Int = 30, completion: @escaping (Int, [MomentsInfo]?) -> Void) {
        var param: [String: Any] = ["pagination" : ["pageNumber": pageNumber, "showNumber": pageCount]]
        
        if userID != nil {
            param["userID"] = userID!
        }
        OIMApi.loadMoments(param: param) { code, moments in
            completion(code, moments?.workMoments)
        }
    }
    
    func loadMomentsDetail(momentID: String, completion: @escaping (Int, MomentsInfo?) -> Void) {
        let param = ["workMomentID": momentID]
        OIMApi.loadMomentDetail(param: param) { code, res in
            completion(code, res?.workMoment)
        }
    }
    
    func favor(momentID: String, like: Bool, completion: @escaping (_ success: Bool) -> Void) {
        let param = ["workMomentID": momentID, "like": like] as [String : Any]
        OIMApi.favorMoments(param: param) { code, r in
            completion(code == 0)
        }
    }
    
    func comment(momentID: String, replyUserID: String?, text: String, completion: @escaping (_ success: Bool) -> Void) {
        let param = ["workMomentID": momentID, "replyUserID": replyUserID, "content": text]
        OIMApi.commentMoments(param: param) { code, r in
            completion(code == 0)
        }
    }
    
    func delete(momentID: String, commentID: String?, completion: @escaping (_ success: Bool) -> Void) {
        let param = ["workMomentID": momentID, "commentID": commentID]
        if commentID == nil {
            OIMApi.deleteMoments(param: param) { code, r in
                completion(code == 0)
            }
        } else {
            OIMApi.deleteComment(param: param) { code, r in
                completion(code == 0)
            }
        }
    }
    // 1:未读数 2:消息列表 3:全部
    func clearNewMessage(type: Int, completion: @escaping (_ success: Bool) -> Void) {
        OIMApi.clearUnreadCount(param: ["type": type]) { code, r in
            completion(code == 0)
        }
    }
    
    func queryUnreadCount(completionHandler: @escaping (Int) -> Void) {
        OIMApi.queryUnreadCount { code, r in
            if code == 0, let total = r?["total"] {
                completionHandler(total)
            } else {
                completionHandler(0)
            }
        }
    }
    
    func queryNewMsg(completionHandler: @escaping ([NewMessageInfo]) -> Void) {
        var param = ["pagination" : ["pageNumber": 1, "showNumber": 10000]]
        OIMApi.queryNewMsg(param: param) { code, r in
            completionHandler(r?.workMoments ?? [])
        }
    }
    
    public class RecvNewMessages: Decodable {
        public var body: NewMessageInfo
    }
}

// 朋友圈
extension OIMApi {
    // 获取好友的
    private static let getUserFriendMoments = "/office/work_moment/find/recv"
    // 获取某人的
    private static let getUserMoments = "/office/work_moment/find/send"
    // 发布朋友圈
    private static let publishMoment = "/office/work_moment/add"
    // 点赞
    private static let favorMoment = "/office/work_moment/like"
    // 评论
    private static let commentMoment = "/office/work_moment/comment/add"
    // 删除
    private static let deleteMoment = "/office/work_moment/del"
    // 详情
    private static let getMomentDetail = "/office/work_moment/get"
    // 删除评论
    private static let deleteComment = "/office/work_moment/comment/del"
    // 未读数
    private static let queryUnreadCount = "/office/work_moment/unread/count"
    // 清空未读数
    private static let clearUnreadCount = "/office/work_moment/unread/clear"
    // 消息列表
    private static let queryNewMsgs = "/office/work_moment/logs"
    
    public static func loadMoments(param: [String: Any], completionHandler: @escaping CompletionHandler<Moments?>) {
        let body = try? JSONSerialization.data(withJSONObject: param, options: .fragmentsAllowed)
        let url = baseURL + (param["userID"] != nil ? getUserMoments : getUserFriendMoments)
        
        post(url: url, body: body, token: token, completionHandler: completionHandler)
    }
    
    public static func loadMomentDetail(param: [String: Any], completionHandler: @escaping CompletionHandler<MomentsDetail?>) {

        let body = try? JSONSerialization.data(withJSONObject: param, options: .fragmentsAllowed)
        let url = baseURL + getMomentDetail
        
        post(url: url, body: body, token: token, completionHandler: completionHandler)
    }
    
    public static func publishMoments(param: [String: Any], completionHandler: @escaping CompletionHandler<String?>) {
        let body = try? JSONSerialization.data(withJSONObject: param, options: .fragmentsAllowed)
        let url = baseURL + publishMoment
        
        postNoDataKey(url: url, body: body, token: token, completionHandler: completionHandler)
    }
    
    public static func favorMoments(param: [String: Any], completionHandler: @escaping CompletionHandler<String?>) {
       
        let body = try? JSONSerialization.data(withJSONObject: param, options: .fragmentsAllowed)
        let url = baseURL + favorMoment
        
        postNoDataKey(url: url, body: body, token: token, completionHandler: completionHandler)
    }
    
    public static func commentMoments(param: [String: Any], completionHandler: @escaping CompletionHandler<String?>) {
        
        let body = try? JSONSerialization.data(withJSONObject: param, options: .fragmentsAllowed)
        let url = baseURL + commentMoment
        
        postNoDataKey(url: url, body: body, token: token, completionHandler: completionHandler)
    }
    
    public static func deleteMoments(param: [String: Any], completionHandler: @escaping CompletionHandler<String?>) {
        
        let body = try? JSONSerialization.data(withJSONObject: param, options: .fragmentsAllowed)
        let url = baseURL + deleteMoment
        
        postNoDataKey(url: url, body: body, token: token, completionHandler: completionHandler)
    }
    
    public static func deleteComment(param: [String: Any], completionHandler: @escaping CompletionHandler<String?>) {
        
        let body = try? JSONSerialization.data(withJSONObject: param, options: .fragmentsAllowed)
        let url = baseURL + deleteComment
        
        postNoDataKey(url: url, body: body, token: token, completionHandler: completionHandler)
    }
    
    public static func queryUnreadCount(completionHandler: @escaping CompletionHandler<[String: Int]?>) {
        
        let body = try? JSONSerialization.data(withJSONObject: [:], options: .fragmentsAllowed)
        let url = baseURL + queryUnreadCount
        
        post(url: url, body: body, token: token, completionHandler: completionHandler)
    }
    
    public static func clearUnreadCount(param: [String: Any], completionHandler: @escaping CompletionHandler<[String: String]?>) {
        let body = try? JSONSerialization.data(withJSONObject: param, options: .fragmentsAllowed)
        let url = baseURL + clearUnreadCount
        
        post(url: url, body: body, token: token, completionHandler: completionHandler)
    }
    
    public static func queryNewMsg(param: [String: Any], completionHandler: @escaping CompletionHandler<NewMessages?>) {
        let body = try? JSONSerialization.data(withJSONObject: param, options: .fragmentsAllowed)
        let url = baseURL + queryNewMsgs
        
        post(url: url, body: body, token: token, completionHandler: completionHandler)
    }
    
    public class MomentsRequest: Encodable {
        private let userID: String? // 如果userID为假，则获取登录账号的列表，否则获取userID的列表
        private let pageNumber: Int
        private let showNumber: Int
        private let operationID = UUID.init().uuidString
        
        init(userID: String?, pageNumber: Int = 1, showNumber: Int = 100) {
            self.userID = userID
            self.pageNumber = pageNumber
            self.showNumber = showNumber
        }
    }
    
    public class Moments: Decodable {
        public var workMoments: [MomentsInfo] = []
    }
    
    public class MomentsDetail: Decodable {
        public var workMoment: MomentsInfo
    }
    
    public class NewMessages: Decodable {
        public var workMoments: [NewMessageInfo] = []
    }
}
