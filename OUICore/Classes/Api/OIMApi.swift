import Foundation
import Alamofire


public typealias CompletionHandler<T: Any> = (Int, T) -> Void
public typealias QueryInfoHandler = ((_ keywords: [String], _ completion: @escaping (([UserInfo]) -> Void)) -> Void)
public typealias QueryDataHandler<T: Any> = ((_ completion: @escaping CompletionHandler<T>) -> Void)

// MARK: - 张亚飞打的标记  网站相关
public typealias showBoke = ((_ keywords: String , _ completion: @escaping ((String) -> Void)) -> Void)
public typealias currentVCShowBokeHandle = ((_ currentVC: UIViewController , _ completion: @escaping ((String) -> Void)) -> Void)
public typealias showBokeLinkHandle = ((_ currentVC: UIViewController, _  bokeLink: String ,_ hash: String,_ completion: @escaping ((String) -> Void)) -> Void)
//public typealias starBokeLinkHandle = ((_ blogTitle: String, _  blogIcon: String, _ _blogUrl: String, _ blogIntro: String, _ completion: @escaping ((String) -> Void)) -> Void)
public typealias starBokeLinkHandle = ((_ blogJson: String,  _ completion: @escaping ((String) -> Void)) -> Void)

public typealias getOfficialBokeHandle = (( _ completion: @escaping (([[String: String]]) -> Void)) -> Void)

public typealias clickChatQuickToolHandle = ((_ currentVC: UIViewController,_ chatInfo: [String:Any],_  linkUrl: String ,_ hash: String,  _ completion: @escaping ((String) -> Void)) -> Void)

public typealias clickPublicCustomerMessageHandle = ((_ currentVC: UIViewController,_ messageId: String, _  source: String ,_ type: String,  _ completion: @escaping ((String) -> Void)) -> Void)


// MARK: - 张亚飞打的标记  其他跳转  比如 个人资料
public typealias gotoUserMessageHandle = ((_ currentVC: UIViewController, _  userID: String, _ nickname: String, _ faceURL: String ,_ completion: @escaping ((String) -> Void)) -> Void)
public typealias gotoGroupSettingHandle = ((_ currentVC: UIViewController, _  groupID: String, _ nickname: String, _ completion: @escaping ((String) -> Void)) -> Void)
public typealias gotoNewFriendHandle = ((_ currentVC: UIViewController, _ completion: @escaping ((String) -> Void)) -> Void)

public typealias showChatVCShoeethandle = ((_ currentVC: UIViewController, _  userID: String, _ completion: @escaping ((String) -> Void)) -> Void)
public typealias gotoSystemSettingHandle = ((_ currentVC: UIViewController, _  userID: String, _ completion: @escaping ((String) -> Void)) -> Void)
public typealias addFriendhandle = ((_ currentVC: UIViewController, _  userID: String, _ completion: @escaping ((String) -> Void)) -> Void)


public typealias getUserMessageHandle = ((_  userID: String, _ completion: @escaping ((String) -> Void)) -> Void)

public typealias reportMomentsHandle = ((_ currentVC: UIViewController,_  reportUserID: String,_ commentID:String, _ completion: @escaping ((String) -> Void)) -> Void)

// MARK: - 张亚飞打的标记  更新会话的ex
public typealias updateConversationEx = ((_ conversationEx : String, _ completion: @escaping ((String) -> Void)) -> Void)

public typealias updateConversationCell = ((_ messageID : String, _ completion: @escaping ((String) -> Void)) -> Void)
public typealias reloadCollectionView = ((_ completion: @escaping ((String) -> Void)) -> Void)


// MARK: - 张亚飞打的标记  tip
public typealias showTipHandle = ((_ tips : String, _ completion: @escaping ((String) -> Void)) -> Void)

public typealias showTipWithViewHandle = ((_ view: UIView,_ tips : String, _ completion: @escaping ((String) -> Void)) -> Void)

public class OIMApi {
    
    private static let userOnlineStatus = "/user/get_users_online_status"
    
    // 查询在线状态
    public static func queryOnlineStatus(userID: String, completionHandler: @escaping ((_ status: [String: String]) -> Void)) {
        let body = JsonTool.toJson(fromObject: OnlineStatusRequest.init(userIDs: [userID])).data(using: .utf8)
        
        var req = try! URLRequest.init(url: IMController.shared.sdkAPIAdrr + userOnlineStatus, method: .post)
        req.httpBody = body
        req.addValue(IMController.shared.token, forHTTPHeaderField: "token")
        req.addValue(UUID().uuidString, forHTTPHeaderField: "operationID")
        req.addValue(String.getCurrentLanguageHeader(), forHTTPHeaderField: "language")
        
        Alamofire.request(req).responseString { (response: DataResponse<String>) in
            switch response.result {
            case .success(let result):
                if let res = JsonTool.fromJson(result, toClass: Response<[OnlineStatus]>.self) {
                    if res.errCode == 0 {
                        completionHandler(paraseOnlineStatus(res.data))
                    } else {
                    }
                }
            case .failure(_):
                break
            }
        }
    }
    
    private static func paraseOnlineStatus(_ status: [OnlineStatus]) -> [String: String] {
        
        var statusDesc: [String: String] = [:]
        
        status.forEach({ onlineStatus in
            if (onlineStatus.status == "online") {
                // IOSPlatformStr     = "IOS"
                // AndroidPlatformStr = "Android"
                // WindowsPlatformStr = "Windows"
                // OSXPlatformStr     = "OSX"
                // WebPlatformStr     = "Web"
                // MiniWebPlatformStr = "MiniWeb"
                // LinuxPlatformStr   = "Linux"
                if let detail = onlineStatus.detailPlatformStatus {
                    var pList: [String] = [];
                    for (index, platform) in detail.enumerated() {
                        if (platform.platform == "Android" || platform.platform == "IOS") {
                            pList.append("手机".innerLocalized())
                        } else if (platform.platform == "Windows") {
                            pList.append("PC".innerLocalized())
                        } else if (platform.platform == "Web") {
                            pList.append("Web".innerLocalized())
                        } else if (platform.platform == "MiniWeb") {
                            pList.append("Mini".innerLocalized())
                        } else {
                            statusDesc[onlineStatus.userID] = "在线".innerLocalized()
                        }
                    }
                    statusDesc[onlineStatus.userID] = "\(pList.joined(separator: "/"))在线"
                }
            } else {
                statusDesc[onlineStatus.userID] = "离线"
            }
        })
        
        return statusDesc
    }
    
    public static func post<T: Decodable>(url: String, body: Data?, token: String? = nil, completionHandler: @escaping CompletionHandler<T?>) {
        var req = try! URLRequest.init(url: url, method: .post)
        req.addValue(token ?? IMController.shared.token, forHTTPHeaderField: "token")
        req.addValue(UUID().uuidString, forHTTPHeaderField: "operationID")
        req.addValue(String.getCurrentLanguageHeader(), forHTTPHeaderField: "language")
        
        if body != nil {
            req.httpBody = body!
        }
        DispatchQueue.global().async {
            Alamofire.request(req).responseString(encoding: .utf8) { (response: DataResponse<String>) in
                switch response.result {
                case .success(let result):
                    let res = JsonTool.fromJson(result, toClass: Response<T>.self)
                    DispatchQueue.main.async {
                        if let res = res, res.errCode == 0 {
                            completionHandler(res.errCode, res.data)
                        } else {
                            completionHandler(res?.errCode ?? -1, nil)
                        }
                    }
                case .failure(_):
                    break
                }
            }
        }
    }
    
    public static func postNoDataKey(url: String, body: Data?, token: String? = nil, completionHandler: @escaping CompletionHandler<String?>) {
        var req = try! URLRequest.init(url: url, method: .post)
        req.addValue(token ?? IMController.shared.token, forHTTPHeaderField: "token")
        req.addValue(UUID().uuidString, forHTTPHeaderField: "operationID")
        req.addValue(String.getCurrentLanguageHeader(), forHTTPHeaderField: "language")
        
        if body != nil {
            req.httpBody = body!
        }
        DispatchQueue.global().async {
            Alamofire.request(req).responseString(encoding: .utf8) { (response: DataResponse<String>) in
                switch response.result {
                case .success(let result):
                    let res = JsonTool.fromJson(result, toClass: NoDataKeyResponse.self)
                    DispatchQueue.main.async {
                        if let res = res, res.errCode == 0 {
                            completionHandler(res.errCode, nil)
                        } else {
                            completionHandler(res?.errCode ?? -1, res?.errMsg)
                        }
                    }
                case .failure(_):
                    break
                }
            }
        }
    }
    
    // 查询好友、查询好友信息 - 业务层提供数据
    public static var queryFriendsWithCompletionHandler: QueryInfoHandler?
    public static var queryUsersInfoWithCompletionHandler: QueryInfoHandler?
    public static var queryConfigHandler: QueryDataHandler<[String: Any]>?
    public static var rotationHandler: ((UIInterfaceOrientationMask) -> Void)?
    
    public static var showBokeHandle: showBoke?
    public static var showBokeSheetHandle: currentVCShowBokeHandle?
    public static var showBokeLinkHandle: showBokeLinkHandle?
    public static var starBokeLinkHandle: starBokeLinkHandle?
    
    public static var getOfficialBokeHandle: getOfficialBokeHandle?
    public static var clickChatQuickToolHandle:clickChatQuickToolHandle?
    public static var clickPublicCustomerMessageHandle:clickPublicCustomerMessageHandle?
    
    
    public static var gotoUserMessageHandle: gotoUserMessageHandle?
    public static var gotoGroupSettingHandle: gotoGroupSettingHandle?
    public static var gotoNewFriendHandle: gotoNewFriendHandle?
    public static var showChatVCShoeethandle: showChatVCShoeethandle?
    public static var gotoSystemSettingHandle: gotoSystemSettingHandle?
    public static var addFriendhandle: addFriendhandle?
    public static var updateConversationEx: updateConversationEx?
    public static var reportMomentsHandle: reportMomentsHandle?
    
    public static var getUserMessageHandle: getUserMessageHandle?
    
    public static var updateConversationCell: updateConversationCell?
    public static var reloadCollectionView: reloadCollectionView?
    
    public static var showTipHandle: showTipHandle?
    public static var showTipWithViewHandle: showTipWithViewHandle?
}

extension OIMApi {
    class OnlineStatusRequest: Encodable {
        private let userIDList: [String]
        private let platform: Int = 1
        private let operationID = UUID.init().uuidString
        init(userIDs: [String]) {
            self.userIDList = userIDs
        }
    }
    
    struct OnlineStatus: Decodable {
        let userID: String
        let status: String
        let detailPlatformStatus: [DetailPlatformStatus]?
    }
    
    struct DetailPlatformStatus: Decodable {
        let platform: String
        let status: String
    }
    
    public class Response<T: Decodable>: Decodable {
        public var data: T
        public var errCode: Int = 0
        public var errMsg: String?
        public var errDlt: String?
    }
    
    public class NoDataKeyResponse: Decodable {
        public var errCode: Int = 0
        public var errMsg: String?
        public var errDlt: String?
    }
}

extension String {
    
    /// 获取系统当前语言
    static func getCurrentLanguage() -> String {
        // 返回设备曾使用过的语言列表
        let languages: [String] = UserDefaults.standard.object(forKey: "AppleLanguages") as! [String]
        // 当前使用的语言排在第一
        let currentLanguage = languages.first
        return currentLanguage ?? "en-CN"
    }
    
    ///获取当前语言的
    static func getCurrentLanguageHeader() -> String {
        // 返回设备曾使用过的语言列表
        let language = getCurrentLanguage()
        let indexStart = language.startIndex
        let indexZero = language.index(indexStart, offsetBy:0)
        let indexOne = language.index(indexStart, offsetBy:1)
        let subString = language[indexZero...indexOne]
        return String(subString)
    }
}
