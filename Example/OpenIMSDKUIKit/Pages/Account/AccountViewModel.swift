
import Alamofire
import Foundation
import OUICore
import ProgressHUD
import RxSwift
import Network

// 注册/忘记密码
public enum UsedFor: Int {
    case register = 1
    case forgotPassword = 2
    case login = 3
    case changeAccount = 4
    case deleteAccount = 5
}

typealias CompletionHandler = (_ errCode: Int, _ errMsg: String?) -> Void

open class AccountViewModel {
    // 业务服务器地址
//    static let API_BASE_URL = UserDefaults.standard.string(forKey: bussinessSeverAddrKey)!
//    static let ADMIN_BASE_URL = UserDefaults.standard.string(forKey: adminSeverAddrKey)!
    static let API_BASE_URL = defaultAppAddress
    static let ADMIN_BASE_URL = defaultAdminAddress
   
    // 实际开发，抽离网络部分
    static let IMPreLoginAccountKey = "IMPreLoginAccountKey"
    static let IMUidKey = "DemoIMUidKey"
    static let IMTokenKey = "DemoIMTokenKey"
    static let bussinessTokenKey = "bussinessTokenKey"
    
    private static let LoginAPI = "/account/login"
    private static let RegisterAPI = "/account/register"
    private static let CodeAPI = "/account/code/send"
    private static let ChangeAccountAPI = "/user/phone_mail/change"
    private static let VerifyCodeAPI = "/account/code/verify"
    private static let ResetPasswordAPI = "/account/password/reset"
    private static let ChangePasswordAPI = "/account/password/change"
    private static let UpdateUserInfoAPI = "/user/update"
    private static let QueryUserInfoAPI = "/user/find/full"
    private static let SearchUserFullInfoAPI = "/user/search/full"
    private static let GetClientConfigAPI = "/client_config/get"
    
    private static let LoginWithPhonePasswordAPI = "/account/phone_password_login"
    private static let LoginWithPhoneVerifyCodeAPI = "/account/phone_verify_login"
    private static let LoginWithEmailPasswordAPI = "/account/mail_password_login"
    private static let LoginWithEmailVerifyCodeAPI = "/account/mail_verify_login"
    private static let RegisterWithPhoneAPI = "/account/phone_register"
    private static let RegisterWithEmailAPI = "/account/mail_register"
    private static let ResetPasswordWithPhoneAPI = "/account/password/phone_reset"
    private static let ResetPasswordWithEmailAPI = "/account/password/mail_reset"
    private static let ChangePasswordWithPhoneAPI = "/account/password/phone_change"
    private static let ChangePasswordWithEmailAPI = "/account/password/mail_change"
    
    private static let DeleteAccountAPI = "/user/cancel"
    private static let DeleteAccountWithPhoneAPI = "/user/phone_cancel"
    private static let DeleteAccountWithEmailAPI = "/user/mail_cancel"

    private static let getMineHomeWalletAPI = "/wallet/myHomePage/queryMyAssets"
    private static let getMineProgressOrderAPI = "/wallet/myHomePage/areYouOK"
    
    private let _disposeBag = DisposeBag()
    static func getHttpHeader() -> HTTPHeaders{
        let httpHeaders : HTTPHeaders = [
            "token":IMController.shared.chatToken,
            "X-Forwarded-For":IMController.shared.publicIP,
            "Authorization":"eyJ1c2VySW5mbyI6InVzZXJCbG9nWWFuWmhlbmdUb2tlbiJ9",
            "Content-Type":"application/json",
            "operationID":String(Int(Date().timeIntervalSince1970)),
        ]
       return httpHeaders
    }
    
    // 业务层提供给OIMUIKit数据
    // 业务查询好友逻辑
    static func ifQueryFriends() {
        OIMApi.queryFriendsWithCompletionHandler = { (keywords, completion: @escaping ([UserInfo]) -> Void) in
            AccountViewModel.queryFriends(content: keywords.first!, valueHandler: { users in
                let result = users.compactMap {
                    UserInfo(userID: $0.userID!, nickname: $0.nickname, phoneNumber: $0.phoneNumber, email: $0.email, faceURL: $0.faceURL)
                }
                completion(result)
            }, completionHandler: { errCode, _ in
                if errCode == 1501 || errCode == 1506 {
                    NotificationCenter.default.post(name: .init("logout"), object: nil)
                }
                completion([])
            })
        }
    }
    
    
    
    // 业务查询用户信息
    static func ifQueryUserInfo() {
        OIMApi.queryUsersInfoWithCompletionHandler = { (keywords, completion: @escaping ([UserInfo]) -> Void) in
            AccountViewModel.queryUserInfo(userIDList: keywords,
                                           valueHandler: { users in
                                               let result = users.compactMap {
                                                   UserInfo(userID: $0.userID!,
                                                            nickname: $0.nickname,
                                                            phoneNumber: $0.phoneNumber,
                                                            email: $0.email,
                                                            faceURL: $0.faceURL,
                                                            birth: $0.birth,
                                                            gender: Gender(rawValue: $0.gender!),
                                                            landline: $0.telephone,
                                                            forbidden: $0.forbidden,
                                                            allowAddFriend: $0.allowAddFriend)
                                               }
                                               completion(result)
                                           }, completionHandler: { errCode, _ in
                                               if errCode == 1501 || errCode == 1506 {
                                                   NotificationCenter.default.post(name: .init("logout"), object: nil)
                                               }
                                               completion([])
                                           })
        }
    }
    
    // 全局配置信息
    static func ifQeuryConfig() {
        OIMApi.queryConfigHandler = { (completion: (Int, [String: Any]) -> Void) in
            completion(0, AccountViewModel.clientConfig?.config?.toMap() ?? [:])
        }
    }
    
    static func loginDemo(phone: String? = nil, account: String? = nil, email: String? = nil, psw: String? = nil, verificationCode: String? = nil, areaCode: String, LoginType: Int, completionHandler: @escaping CompletionHandler) {
        //LoginType,1:手机号+验证码，2:手机号+密码，3:邮箱+验证码，4:手机号+密码
        
        let body = JsonTool.toJson(fromObject: Request(phoneNumber: phone,
                                                       account: account,
                                                       email: email,
                                                       psw: psw,
                                                       verificationCode: verificationCode,
                                                       areaCode: areaCode)).data(using: .utf8)
        var loginApi = ""
        switch LoginType{
        case 1:
            loginApi = LoginWithPhoneVerifyCodeAPI
        case 2:
            loginApi = LoginWithPhonePasswordAPI
        case 3:
            loginApi = LoginWithEmailVerifyCodeAPI
        case 4:
            loginApi = LoginWithEmailPasswordAPI
        default:
            loginApi = LoginAPI
        }
        
        var req = try! URLRequest(url: API_BASE_URL + loginApi, method: .post)
        req.httpBody = body
//        req.addValue(UUID().uuidString, forHTTPHeaderField: "operationID")
        req.addValue(String(Int(Date().timeIntervalSince1970)), forHTTPHeaderField: "operationID")
        req.addValue(String.getCurrentLanguageHeader(), forHTTPHeaderField: "language")

        Alamofire.request(req).responseString { (response: DataResponse<String>) in
            
            switch response.result {
            case .success(let result):
                if let res = JsonTool.fromJson(result, toClass: Response<UserEntity>.self) {
                    if res.errCode == 0 {
                        // 登录IM
                        savePreLoginAccount(phone)
                        loginIM(uid: res.data!.userID, imToken: res.data!.imToken, chatToken: res.data!.chatToken, completionHandler: completionHandler)
                        
                    } else {
                        completionHandler(res.errCode, res.errMsg)
                    }
                } else {
                    let err = JsonTool.fromJson(result, toClass: DemoError.self)
                    completionHandler(err?.errCode ?? -1, err?.errMsg)
                }
            case .failure(let err):
                completionHandler(-1, err.localizedDescription)
            }
        }
    }
    
    private static func queryUserInfoFromChatServer(userID: String) {
        AccountViewModel.queryUserInfo(userIDList: [userID],
                                       valueHandler: { infos in
                                           guard let info = infos.first else { return }

                                           IMController.shared.enableRing = info.allowBeep == 2
                                           IMController.shared.enableVibration = info.allowVibration == 2
                                       }, completionHandler: { _, _ in
            
                                       })
    }
    static func deleteAccount(userID: String,cancelSign: Int,reason: String, areaCode: String? = nil,phoneNumber: String? = nil, email: String? = nil, verifyCode: String,completionHandler: @escaping CompletionHandler) {
        //cancelSign 注销方式 1:邮箱2:短信
        let body = JsonTool.toJson(fromObject:
                                    DeleteAccountRequest(
                userID:userID,
                cancelSign: cancelSign,
                reason: reason,
                areaCode: areaCode,
                phoneNumber: phoneNumber,
                email:email,
                verifyCode: verifyCode)).data(using: .utf8)
        var deleteAccountApi = ""
        switch cancelSign{
        case 1:
            deleteAccountApi = DeleteAccountWithEmailAPI
        case 2:
            deleteAccountApi = DeleteAccountWithPhoneAPI
        default:
            deleteAccountApi = DeleteAccountAPI
        }
        var req = try! URLRequest(url: API_BASE_URL + deleteAccountApi, method: .post)
        req.httpBody = body
        
        //        req.addValue(UUID().uuidString, forHTTPHeaderField: "operationID")
        req.addValue(String(Int(Date().timeIntervalSince1970)), forHTTPHeaderField: "operationID")
//        let language = String.getCurrentLanguage()[0...1].lowercased()
        req.addValue(String.getCurrentLanguageHeader(), forHTTPHeaderField: "language")
        
        Alamofire.request(req).responseString { (response: DataResponse<String>) in
            switch response.result {
            case .success(let result):
                if let res = JsonTool.fromJson(result, toClass: Response<UserEntity>.self) {
                    if res.errCode == 0 {
                        completionHandler(res.errCode, nil)
                    } else {
                        completionHandler(res.errCode, res.errMsg)
                    }
                } else {
                    print("JSON解析错误")
                }
            case .failure(let err):
                completionHandler(-1, err.localizedDescription)
            }
        }
    }
    
    static func registerAccount(phone: String?,
                                areaCode: String?,
                                verificationCode: String,
                                password: String,
                                faceURL: String,
                                nickName: String,
                                birth: Int = Int(NSDate().timeIntervalSince1970),
                                gender: Int = 1,
                                email: String?,
                                invitationCode: String? = nil,
                                registerType:Int,
                                completionHandler: @escaping CompletionHandler)
    {
        //registerType,1:手机号注册，2:邮箱注册
        let body = JsonTool.toJson(fromObject:
            RegisterRequest(
                phone: phone,
                areaCode: areaCode,
                verificationCode: verificationCode,
                password: password,
                faceURL: faceURL,
                nickName: nickName,
                birth: birth,
                gender: gender,
                email: email,
                invitationCode: invitationCode)).data(using: .utf8)
        var registerTypeApi = ""
        switch registerType {
        case 1:
            registerTypeApi = RegisterWithPhoneAPI
        case 2:
            registerTypeApi = RegisterWithEmailAPI
        default:
            registerTypeApi = RegisterAPI
        }
        
        var req = try! URLRequest(url: API_BASE_URL + registerTypeApi, method: .post)
        req.httpBody = body
        //        req.addValue(UUID().uuidString, forHTTPHeaderField: "operationID")
        req.addValue(String(Int(Date().timeIntervalSince1970)), forHTTPHeaderField: "operationID")
        req.addValue(String.getCurrentLanguageHeader(), forHTTPHeaderField: "language")
        
        
        
        Alamofire.request(req).responseString { (response: DataResponse<String>) in
            switch response.result {
            case .success(let result):
                if let res = JsonTool.fromJson(result, toClass: Response<UserEntity>.self) {
                    if res.errCode == 0 {
                        saveUser(uid: res.data?.userID, imToken: res.data?.imToken, chatToken: res.data?.chatToken)
                        completionHandler(res.errCode, nil)
                    } else {
                        completionHandler(res.errCode, res.errMsg)
                    }
                } else {}
            case .failure(let err):
                completionHandler(-1, err.localizedDescription)
            }
        }
    }
    
    // [usedFor] 1：注册，2：重置密码， 3: 登录，4: 变更邮箱/手机号，5: 删除账号
    static func requestCode(phone: String? = nil, areaCode: String? = nil, email: String? = nil, invaitationCode: String? = nil, useFor: UsedFor, completionHandler: @escaping CompletionHandler) {
        let body = JsonTool.toJson(fromObject:
            CodeRequest(
                phone: phone,
                areaCode: areaCode,
                email: email,
                usedFor: useFor.rawValue,
                invaitationCode: invaitationCode)).data(using: .utf8)
        
        var req = try! URLRequest(url: API_BASE_URL + CodeAPI, method: .post)
        req.httpBody = body
        
        //        req.addValue(UUID().uuidString, forHTTPHeaderField: "operationID")
        req.addValue(String(Int(Date().timeIntervalSince1970)), forHTTPHeaderField: "operationID")
//        let language = String.getCurrentLanguage()[0...1].lowercased()
        req.addValue(String.getCurrentLanguageHeader(), forHTTPHeaderField: "language")
        
        Alamofire.request(req).responseString { (response: DataResponse<String>) in
            switch response.result {
            case .success(let result):
                if let res = JsonTool.fromJson(result, toClass: Response<UserEntity>.self) {
                    if res.errCode == 0 {
                        completionHandler(res.errCode, nil)
                    } else {
                        completionHandler(res.errCode, res.errMsg)
                    }
                } else {
                    print("JSON解析错误")
                }
            case .failure(let err):
                completionHandler(-1, err.localizedDescription)
            }
        }
    }
    
    // [usedFor] 1：注册，2：重置密码
    static func verifyCode(phone: String?, areaCode: String?, email: String? = nil, useFor: UsedFor, verificationCode: String, completionHandler: @escaping CompletionHandler) {
        let body = JsonTool.toJson(fromObject:
            CodeRequest(
                phone: phone,
                areaCode: areaCode,
                email: email,
                usedFor: useFor.rawValue,
                verificationCode: verificationCode)).data(using: .utf8)
        
        var req = try! URLRequest(url: API_BASE_URL + VerifyCodeAPI, method: .post)
        req.httpBody = body
        //        req.addValue(UUID().uuidString, forHTTPHeaderField: "operationID")
        req.addValue(String(Int(Date().timeIntervalSince1970)), forHTTPHeaderField: "operationID")
        req.addValue(String.getCurrentLanguageHeader(), forHTTPHeaderField: "language")
        
        Alamofire.request(req).responseString { (response: DataResponse<String>) in
            switch response.result {
            case .success(let result):
                if let res = JsonTool.fromJson(result, toClass: Response<UserEntity>.self) {
                    if res.errCode == 0 {
                        completionHandler(res.errCode, nil)
                    } else {
                        completionHandler(res.errCode, res.errMsg)
                    }
                } else {}
            case .failure(let err):
                completionHandler(-1, err.localizedDescription)
            }
        }
    }
    
    static func resetPassword(phone: String?,
                              areaCode: String?,
                              email: String?,
                              verificationCode: String,
                              password: String,
                              resetType:Int,
                              completionHandler: @escaping CompletionHandler)
    {
        //resetType,1:手机号，2:邮箱
        let body = JsonTool.toJson(fromObject:
            Request(
                phoneNumber: phone,
                email: email,
                psw: password,
                verificationCode: verificationCode,
                areaCode: areaCode)).data(using: .utf8)
        var resetTypeApi = ""
        switch resetType {
        case 1:
            resetTypeApi = ResetPasswordWithPhoneAPI
        case 2:
            resetTypeApi = ResetPasswordWithEmailAPI
        default:
            resetTypeApi = ResetPasswordAPI
        }
        var req = try! URLRequest(url: API_BASE_URL + resetTypeApi, method: .post)
        req.httpBody = body
        //        req.addValue(UUID().uuidString, forHTTPHeaderField: "operationID")
        req.addValue(String(Int(Date().timeIntervalSince1970)), forHTTPHeaderField: "operationID")
        req.addValue(String.getCurrentLanguageHeader(), forHTTPHeaderField: "language")
        
        Alamofire.request(req).responseString { (response: DataResponse<String>) in
            switch response.result {
            case .success(let result):
                if let res = JsonTool.fromJson(result, toClass: Response<UserEntity>.self) {
                    if res.errCode == 0 {
                        completionHandler(res.errCode, nil)
                    } else {
                        completionHandler(res.errCode, res.errMsg)
                    }
                } else {}
            case .failure(let err):
                completionHandler(-1, err.localizedDescription)
            }
        }
    }
    
    static func changePassword(userID: String, current password1: String, to password2: String,changePasswordType:Int, completionHandler: @escaping CompletionHandler) {
        //changePasswordType,1:手机号登录的修改密码，2:邮箱登录的修改密码
        let body = JsonTool.toJson(fromObject:
            ChangePasswordRequest(
                userID: userID,
                currentPassword: password1,
                newPassword: password2)).data(using: .utf8)
        var changePasswordTypeAPI = ""
        switch changePasswordType {
        case 1:
            changePasswordTypeAPI = ChangePasswordWithPhoneAPI
        case 2:
            changePasswordTypeAPI = ChangePasswordWithEmailAPI
        default:
            changePasswordTypeAPI = ChangePasswordAPI
        }
        var req = try! URLRequest(url: API_BASE_URL + changePasswordTypeAPI, method: .post)
        req.httpBody = body
        req.addValue(IMController.shared.chatToken, forHTTPHeaderField: "token")
        //        req.addValue(UUID().uuidString, forHTTPHeaderField: "operationID")
        req.addValue(String(Int(Date().timeIntervalSince1970)), forHTTPHeaderField: "operationID")
        req.addValue(String.getCurrentLanguageHeader(), forHTTPHeaderField: "language")
        
        Alamofire.request(req).responseString { (response: DataResponse<String>) in
            switch response.result {
            case .success(let result):
                if let res = JsonTool.fromJson(result, toClass: Response<UserEntity>.self) {
                    if res.errCode == 0 {
                        completionHandler(res.errCode, nil)
                    } else {
                        completionHandler(res.errCode, res.errMsg)
                    }
                } else {}
            case .failure(let err):
                completionHandler(-1, err.localizedDescription)
            }
        }
    }
    //更改账号
    static func changeAccountRequest(userID: String? = nil,phoneNumber: String? = nil, areaCode: String? = nil, email: String? = nil, verifyCode: String? = nil, completionHandler: @escaping CompletionHandler) {
        let body = JsonTool.toJson(fromObject:
                                    ChangePhoneOrEmailRequest(
                                        userID: userID,
                                        phoneNumber: phoneNumber,
                                        areaCode: areaCode,
                                        email: email,
                                        verifyCode: verifyCode)).data(using: .utf8)
        
        var req = try! URLRequest(url: API_BASE_URL + ChangeAccountAPI, method: .post)
        req.httpBody = body
        req.addValue(IMController.shared.chatToken, forHTTPHeaderField: "token")
        req.addValue(String(Int(Date().timeIntervalSince1970)), forHTTPHeaderField: "operationID")
        Alamofire.request(req).responseString { (response: DataResponse<String>) in
            switch response.result {
            case .success(let result):
                if let res = JsonTool.fromJson(result, toClass: Response<UserEntity>.self) {
                    if res.errCode == 0 {
                        completionHandler(res.errCode, nil)
                    } else {
                        completionHandler(res.errCode, res.errMsg)
                    }
                } else {
                    print("JSON解析错误")
                }
            case .failure(let err):
                completionHandler(-1, err.localizedDescription)
            }
        }
    }
    
    // 更新个人信息
    static func updateUserInfo(userID: String,
                               account: String? = nil,
                               areaCode: String? = nil,
                               phone: String? = nil,
                               email: String? = nil,
                               nickname: String? = nil,
                               faceURL: String? = nil,
                               gender: Gender? = nil,
                               birth: Int? = nil,
                               level: Int? = nil,
                               allowAddFriend: Int? = nil,
                               allowBeep: Int? = nil,
                               allowVibration: Int? = nil,
                               chatID: String? = nil,
                               personalProfile: String? = nil,
                               completionHandler: @escaping CompletionHandler)
    {
        let body = JsonTool.toJson(fromObject:
            UpdateUserInfoRequest(userID: userID,
                                  chatID: chatID,
                                  phone: phone,
                                  faceURL: faceURL,
                                  nickname: nickname,
                                  birth: birth,
                                  gender: gender,
                                  account: account,
                                  level: level,
                                  email: email,
                                  allowAddFriend: allowAddFriend,
                                  allowBeep: allowBeep,
                                  allowVibration: allowVibration,
                                  personalProfile: personalProfile
                                  )).data(using: .utf8)
        
        var req = try! URLRequest(url: API_BASE_URL + UpdateUserInfoAPI, method: .post)
        req.httpBody = body
        req.addValue(IMController.shared.chatToken, forHTTPHeaderField: "token")
        //        req.addValue(UUID().uuidString, forHTTPHeaderField: "operationID")
        req.addValue(String(Int(Date().timeIntervalSince1970)), forHTTPHeaderField: "operationID")
        req.addValue(String.getCurrentLanguageHeader(), forHTTPHeaderField: "language")
        
        
        
        Alamofire.request(req).responseString { (response: DataResponse<String>) in
            
            switch response.result {
            case .success(let result):
                if let res = JsonTool.fromJson(result, toClass: Response<UpdateUserInfoRequest>.self) {
                    if res.errCode == 0 {
                        completionHandler(res.errCode, nil)
                    } else {
                        completionHandler(res.errCode, res.errMsg)
                    }
                } else {
                    
                }
            case .failure(let err):
                completionHandler(-1, err.localizedDescription)
            }
        }
    }
    
    // 获取个人信息
    static func queryUserInfo(pageNumber: Int = 1,
                              showNumber: Int = 10,
                              userIDList: [String],
                              valueHandler: @escaping ([QueryUserInfo]) -> Void,
                              completionHandler: @escaping CompletionHandler)
    {
        let body = JsonTool.toJson(fromObject:
            QueryUserInfoRequest(userIDList: userIDList)).data(using: .utf8)
        
        var req = try! URLRequest(url: API_BASE_URL + QueryUserInfoAPI, method: .post)
        req.httpBody = body
        req.addValue(IMController.shared.chatToken, forHTTPHeaderField: "token")
        //        req.addValue(UUID().uuidString, forHTTPHeaderField: "operationID")
        req.addValue(String(Int(Date().timeIntervalSince1970)), forHTTPHeaderField: "operationID")
        
        Alamofire.request(req).responseString(encoding: .utf8) { (response: DataResponse<String>) in
            switch response.result {
            case .success(let result):
                if let res = JsonTool.fromJson(result, toClass: Response<QueryUserInfoData>.self) {
                    if res.errCode == 0 {
                        valueHandler(res.data!.users)
                    } else {
                        completionHandler(res.errCode, res.errMsg)
                    }
                } else {
                    completionHandler(-1, result)
                }
            case .failure(let err):
                completionHandler(-1, err.localizedDescription)
            }
        }
    }
    
    // 查询好友
    static func queryFriends(pageNumber: Int = 1,
                             showNumber: Int = 100,
                             content: String,
                             valueHandler: @escaping ([QueryUserInfo]) -> Void,
                             completionHandler: @escaping CompletionHandler)
    {
        let body = JsonTool.toJson(fromObject:
            QueryFriendsRequest(keyword: content,
                                pageNumber: pageNumber,
                                showNumber: showNumber)).data(using: .utf8)
        
        var req = try! URLRequest(url: API_BASE_URL + SearchUserFullInfoAPI, method: .post)
        req.httpBody = body
        req.addValue(IMController.shared.chatToken, forHTTPHeaderField: "token")
        //        req.addValue(UUID().uuidString, forHTTPHeaderField: "operationID")
        req.addValue(String(Int(Date().timeIntervalSince1970)), forHTTPHeaderField: "operationID")
        req.addValue(String.getCurrentLanguageHeader(), forHTTPHeaderField: "language")
        
        Alamofire.request(req).responseString(encoding: .utf8) { (response: DataResponse<String>) in
            switch response.result {
            case .success(let result):
                if let res = JsonTool.fromJson(result, toClass: Response<QueryUserInfoData>.self) {
                    if res.errCode == 0 {
                        valueHandler(res.data!.users)
                    } else {
                        completionHandler(res.errCode, res.errMsg)
                    }
                } else {
                    completionHandler(-1, nil)
                }
            case .failure(let err):
                completionHandler(-1, err.localizedDescription)
            }
        }
    }
    
    static func loginIM(uid: String, imToken: String, chatToken: String, completionHandler: @escaping CompletionHandler) {
        IMController.shared.login(uid: uid, token: imToken) { resp in
            print("login onSuccess \(String(describing: resp))")
            completionHandler(0, nil)
            
            ifQueryFriends()
            ifQueryUserInfo()
            ifQeuryConfig()
//            showBoke()
//            IMGotoAppVC()
            saveUser(uid: uid, imToken: imToken, chatToken: chatToken)
            queryUserInfoFromChatServer(userID: uid)
        } onFail: { (code: Int, msg: String?) in
            let reason = "login onFail: code \(code), reason \(String(describing: msg))"
            completionHandler(code, reason)
            saveUser(uid: nil, imToken: nil, chatToken: nil)
        }
    }
    
    static func saveUser(uid: String?, imToken: String?, chatToken: String?) {
        IMController.shared.chatToken = chatToken ?? ""
        UserDefaults.standard.set(uid, forKey: IMUidKey)
        UserDefaults.standard.set(imToken, forKey: IMTokenKey)
        UserDefaults.standard.set(chatToken, forKey: bussinessTokenKey)
        UserDefaults.standard.synchronize()
//        IMController.shared.setup(businessServer: UserDefaults.standard.string(forKey: bussinessSeverAddrKey)!, businessToken: chatToken)
    }
    
    static func savePreLoginAccount(_ account: String?) {
        UserDefaults.standard.set(account, forKey: IMPreLoginAccountKey)
        UserDefaults.standard.synchronize()
    }
    
    static var perLoginAccount: String? {
        return UserDefaults.standard.string(forKey: IMPreLoginAccountKey)
    }
    
    static var userID: String? {
        return UserDefaults.standard.string(forKey: IMUidKey)
    }
    
    static var baseUser: UserEntity {
        return UserEntity(userID: UserDefaults.standard.string(forKey: IMUidKey) ?? "",
                          imToken: UserDefaults.standard.string(forKey: IMTokenKey) ?? "",
                          chatToken: UserDefaults.standard.string(forKey: bussinessTokenKey) ?? "",
                          expiredTime: nil)
    }
    
    // 获取配置
    static func getClientConfig(completion: ((ClientConfigData?) -> Void)? = nil) {
//        let body = try! JSONSerialization.data(withJSONObject: ["operationID": UUID().uuidString], options: .prettyPrinted)
        let body = try! JSONSerialization.data(withJSONObject: ["operationID":String(Int(Date().timeIntervalSince1970))], options: .prettyPrinted)
        
        var req = try! URLRequest(url: ADMIN_BASE_URL + GetClientConfigAPI, method: .post)
        req.httpBody = body
//        req.addValue(UUID().uuidString, forHTTPHeaderField: "operationID")
        req.addValue(String(Int(Date().timeIntervalSince1970)), forHTTPHeaderField: "operationID")
        req.addValue(String.getCurrentLanguageHeader(), forHTTPHeaderField: "language")
        
        Alamofire.request(req).responseString(encoding: .utf8) { (response: DataResponse<String>) in
            switch response.result {
            case .success(let result):
                if let res = JsonTool.fromJson(result, toClass: Response<ClientConfigData>.self) {
                    if res.errCode == 0 {
                        clientConfig = res.data
                        completion?(clientConfig)
                    } else {
                        completion?(nil)
                    }
                } else {
                    completion?(nil)
                }
            case .failure:
                completion?(nil)
            }
        }
    }

    // 配置
    static var clientConfig: ClientConfigData?
    //获取用户钱包信息
    static func queryUserWalletInfo(
                              valueHandler: @escaping (MineWalletMoneyData) -> Void,
                              completionHandler: @escaping CompletionHandler)
    {
        if !NetworkStatus.isReacheable {
            //            SuperToast.show(title: "")
            return
        }
        Alamofire.request(API_BOB_URL + getMineHomeWalletAPI, method: .post, parameters: nil,encoding: JSONEncoding.default, headers: getHttpHeader()).responseJSON { dataRequest in
            if let data = dataRequest.data {
                let strData = String.init(data: data, encoding: String.Encoding.utf8)
                print(strData!)
                if let res = JsonTool.fromJson(strData!, toClass: RealNameInfoResponse<MineWalletMoneyData>.self) {
                    if res.code == 20000  {
                        valueHandler(res.data)
                    } else {
                        completionHandler(res.code, res.message)
                    }
                } else {
                    completionHandler(-1, "failure")
                }
            } else {
                completionHandler(-1, "failure")
            }
        }
    }
    //获取用户进行中的订单
    static func getMineProgressOrderRequest(
                              valueHandler: @escaping (MineWalletMoneyData) -> Void,
                              completionHandler: @escaping CompletionHandler)
    {
        if !NetworkStatus.isReacheable {
            //            SuperToast.show(title: "")
            return
        }
        Alamofire.request(API_BOB_URL + getMineProgressOrderAPI, method: .post, parameters: nil,encoding: JSONEncoding.default, headers: getHttpHeader()).responseJSON { dataRequest in
            if let data = dataRequest.data {
                let strData = String.init(data: data, encoding: String.Encoding.utf8)
                print(strData!)
                if let res = JsonTool.fromJson(strData!, toClass: RealNameInfoResponse<MineWalletMoneyData>.self) {
                    if res.code == 20000  {
                        valueHandler(res.data)
                    } else {
                        completionHandler(res.code, res.message)
                    }
                } else {
                    completionHandler(-1, "failure")
                }
            } else {
                completionHandler(-1, "failure")
            }
        }
    }
}

class Request: Encodable {
    private let areaCode: String?
    private let phoneNumber: String?
    private let password: String
    private let verifyCode: String?
    private let platform: Int = 1
    private let account: String?
    private let email: String?

    init(phoneNumber: String? = nil, account: String? = nil, email: String? = nil, psw: String? = nil, verificationCode: String? = nil, areaCode: String? = nil) {
        self.phoneNumber = phoneNumber
        self.email = email
        self.account = account
        self.password = psw?.md5() ?? ""
        self.areaCode = areaCode
        self.verifyCode = verificationCode
    }
}




class Response<T: Decodable>: Decodable {
    var data: T? = nil
    var errCode: Int = 0
    var errMsg: String? = nil
    var errDlt: String?
    

}

struct UserEntity: Decodable {
    let userID: String
    let imToken: String
    let chatToken: String
    let expiredTime: Int?
}

class RegisterRequest: Encodable {
    private var verifyCode: String?
    private let platform: Int = 1
    private let user: UpdateUserInfoRequest
    private let invitationCode: String?
    private let deviceID = UUID().uuidString
    private let autoLogin = true
    
    init(phone: String?, areaCode: String?, verificationCode: String?, password: String?, faceURL: String?, nickName: String?, birth: Int?, gender: Int?, email: String? = nil, invitationCode: String?) {
        self.user = UpdateUserInfoRequest(phone: phone, password: password, areaCode: areaCode, nickname: nickName, email: email)
        self.verifyCode = verificationCode
        self.invitationCode = invitationCode
    }
}
class DeleteAccountRequest: Encodable {
    private let userID: String
    private let cancelSign: Int
    private let reason: String
    private let areaCode: String?
    private let phoneNumber: String?
    private let email: String?
    private let verifyCode: String
    
    init(userID: String,cancelSign: Int,reason: String, areaCode: String? = nil,phoneNumber: String? = nil, email: String? = nil, verifyCode: String) {
        assert(phoneNumber != nil || email != nil, "phone or email is nil")
        self.userID = userID
        self.cancelSign = cancelSign
        self.reason = reason
        self.areaCode = areaCode
        self.phoneNumber = phoneNumber
        self.email = email
        self.verifyCode = verifyCode
    }
}

class CodeRequest: Encodable {
    private let areaCode: String?
    private let phoneNumber: String?
    private let email: String?
    private let usedFor: Int
    private let verifyCode: String?
    private let invaitationCode: String?
    private let platform: Int = 1
    
    init(phone: String? = nil, areaCode: String? = nil, email: String? = nil, usedFor: Int, invaitationCode: String? = nil, verificationCode: String? = nil) {
        assert(phone != nil || email != nil, "phone or email is nil")
        self.phoneNumber = phone
        self.email = email
        self.areaCode = areaCode
        self.usedFor = usedFor
        self.verifyCode = verificationCode
        self.invaitationCode = invaitationCode
    }
}

class QueryUserInfoRequest: Encodable {
    private let userIDs: [String]
    
    init(pageNumber: Int = 1, showNumber: Int = 10, userIDList: [String]) {
        self.userIDs = userIDList
    }
}

class QueryUserInfoData: Decodable {
    let users: [QueryUserInfo]
    let totalNumber: Int?
}

class QueryUserInfo: UpdateUserInfoRequest {}

class UpdateUserInfoRequest: Codable {
    var userID: String?
    let chatID: String?
    let account: String?
    let password: String?
    let level: Int?
    var faceURL: String?
    var nickname: String?
    var areaCode: String?
    var phoneNumber: String?
    let telephone: String?
    let hireDate: String?
    private var platform: Int? = 1
    var birth: Int?
    var gender: Int?
    var email: String?
    let englishName: String?
    let forbidden: Int?
    let allowAddFriend: Int?
    let allowBeep: Int?
    let allowVibration: Int?
    let personalProfile: String?
    
    init(userID: String? = nil,
         chatID: String? = nil,
         phone: String? = nil,
         password: String? = nil,
         telephone: String? = nil,
         areaCode: String? = nil,
         faceURL: String? = nil,
         nickname: String? = nil,
         englishName: String? = nil,
         birth: Int? = nil,
         gender: Gender? = nil,
         account: String? = nil,
         level: Int? = nil,
         email: String? = nil,
         hireDate: String? = nil,
         allowAddFriend: Int? = nil,
         allowBeep: Int? = nil,
         allowVibration: Int? = nil,
         forbidden: Int? = nil,
         personalProfile: String? = nil)
    {
        self.areaCode = areaCode
        self.chatID = chatID
        self.telephone = telephone
        self.password = password?.md5()
        self.phoneNumber = phone
        self.faceURL = faceURL
        self.nickname = nickname
        self.englishName = englishName
        self.birth = birth
        self.gender = gender?.rawValue
        self.email = email
        self.account = account
        self.level = level
        self.userID = userID
        self.hireDate = hireDate
        self.allowAddFriend = allowAddFriend
        self.allowBeep = allowBeep
        self.allowVibration = allowVibration
        self.forbidden = forbidden
        self.personalProfile = personalProfile
    }
}


class ChangePasswordRequest: Encodable {
    private let userID: String
    private let currentPassword: String
    private let newPassword: String
    
    init(userID: String, currentPassword: String, newPassword: String) {
        self.userID = userID
        self.currentPassword = currentPassword.md5
        self.newPassword = newPassword.md5
    }
}
class ChangePhoneOrEmailRequest: Encodable {
    private let userID: String?
    private let phoneNumber: String?
    private let areaCode: String?
    private let email: String?
    private let verifyCode: String?

    init(userID: String? = nil, phoneNumber: String? = nil, areaCode: String? = nil, email: String? = nil, verifyCode: String? = nil) {
        self.userID = userID
        self.phoneNumber = phoneNumber
        self.areaCode = areaCode
        self.email = email
        self.verifyCode = verifyCode
    }
}

class QueryFriendsRequest: Encodable {
    private let pagination: Pagination
    private let keyword: String
    private let platform: Int = 1
    
    init(keyword: String, pageNumber: Int = 1, showNumber: Int = 100) {
        self.keyword = keyword
        self.pagination = Pagination(pageNumber: pageNumber, showNumber: showNumber)
    }
}

class Pagination: Encodable {
    private let pageNumber: Int
    private let showNumber: Int
    
    init(pageNumber: Int, showNumber: Int) {
        self.pageNumber = pageNumber
        self.showNumber = showNumber
    }
}

class ClientConfigData: Codable {
    class Config: Codable {
        var discoverPageURL: String?
        var ordinaryUserAddFriend: String?
        var bossUserID: String?
        var adminURL: String?
        var allowSendMsgNotFriend: String?
        var needInvitationCodeRegister: String?
        var robots: [String]?
        
        func toMap() -> [String: Any] {
            return JsonTool.toMap(fromObject: self)
        }
    }
    
    var config: Config?
}

struct DemoError: Error, Decodable {
    let errCode: Int
    let errMsg: String?
    
    var localizedDescription: String {
        let msg: String = errMsg ?? "no message"
        return "code: \(errCode), msg: \(msg)"
    }
}
class MineWalletMoneyData: Codable {
    let totalAssets: Double? //我的总资产
    let certificationLevel: Int? //用户实名认证等级 0:未认证 1:初级认证 2:高级认证
    let secure:Bool? //是否已设置安全密码
    let sonKey:String?//支付密码私钥
    let quantityOfMoneyPOS:[QuantityOfMoneyPOS]? //钱包资产
}
class QuantityOfMoneyPOS: Codable {
    var logoAddr: String? //币种icon
    var currency: String? //币种
    var officialExchangeRate: Double? //汇率
    var quantityOfMoney: Double? //货币数量,保留两位小数
    var equivalentToRMB: Double? //折合人民币,约等于
    var frozen: Double? //冻结
    var usable: Double? //可用
    var t0:Double? //t+0
    var t1:Double? //t+1
//    func toMap() -> [String: Any] {
//        return JsonTool.toMap(fromObject: self)
//    }
}
