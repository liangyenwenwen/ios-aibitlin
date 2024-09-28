//
//  YFMineNetViewModel.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/9/13.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Alamofire
import Foundation
import OUICore
import ProgressHUD
import RxSwift
import Network

class YFMineNetViewModel: AccountViewModel {
    
    static let API_BLOG_URL = "http://192.168.7.107:18898"
    
    // MARK: - 张亚飞打的标记 blogAPI
    private static let BlogAuditAddWaitAuditAutoAPI = "/blog/audit/addWaitAuditAuto"
    private static let ShowMyMyBlogsAPI = "/Show/My/myBlogs"
    private static let otherSeeMyBlogAPI = "/Show/My/otherSeeMyBlog"
    private static let blogTopAPI = "/Show/My/blogTop"
    private static let updateWaitAuditAutoAPI = "/blog/audit/updateWaitAuditAuto"
    private static let deleteBlogAPI = "/blog/audit/deleteBlog"
    private static let queryShowBlogsSurveyAPI = "/show/blogsSurvey/queryShowBlogsSurvey"
    private static let queryShowBlogsSurveyOneDayAPI = "/show/blogsSurvey/queryShowBlogsSurveyOneDay"
    private static let queryShowBlogsSurveyFriendsAPI = "/show/blogsSurvey/queryShowBlogsSurveyFriends"
    private static let queryShowBlogsSurveyStrangerAPI = "/show/blogsSurvey/queryShowBlogsSurveyStranger"
    private static let addShowBlogsSurveyAPI = "/show/blogsSurvey/addShowBlogsSurvey"
    
    private static let updateUserLanguageAPI = "/user/language/updateUserLanguage"
    private static let addUserLanguageAPI = "/user/language/addUserLanguage"
    
    
    private static var httpHeaders : HTTPHeaders = [
        "token":UserDefaults.standard.string(forKey: bussinessTokenKey)!,
        "X-Forwarded-For":"183.156.234.224",
        "Authorization":"eyJ1c2VySW5mbyI6InVzZXJCbG9nWWFuWmhlbmdUb2tlbiJ9",
        "Content-Type":"application/json",
    ]
    
   // MARK: - 张亚飞打的标记   博客接口
   /// 新增博客信息到自动审核
    static func blogAudit(userId: String?,
                          userBlogUrl: String?,
                          userBlogIcon:String?,
                          userBlogName:String?,
                          userBlogIntro: String?,
                          completionHandler: @escaping CompletionHandler) {
        
        let body = JsonTool.toJson(fromObject: BlogAuditRequest(userId: userId, userBlogUrl: userBlogUrl, userBlogIcon: userBlogIcon, userBlogName: userBlogName, userBlogIntro: userBlogIntro)).data(using: .utf8)
        
        
        var req = try! URLRequest(url: API_BLOG_URL + BlogAuditAddWaitAuditAutoAPI, method: .post, headers: httpHeaders)
        req.httpBody = body
        
//        Alamofire.request(API_BLOG_URL + BlogAuditAddWaitAuditAutoAPI, method: .post, parameters: ["userId": userId!])
        
        
        Alamofire.request(req).responseString { (response: DataResponse<String>) in
            switch response.result {
            case .success(let result):
                if let res = JsonTool.fromJson(result, toClass: BlogResponse.self) {

                    if res.code == 20000  {
                        print("请求成功")
                    } else {
                        print("请求失败")
                    }
                    
                    completionHandler(res.code, res.message)
                    
                } else {
                    completionHandler(-1, "Fail")
                }
            case .failure(let err):
                completionHandler(-1, err.localizedDescription)
            }
        }
        
    }
     
    /// 我的博客
    static func mineBlog(userId: String?,
                         valueHandler: @escaping ([blogDetailItem]) -> Void,
                         completionHandler: @escaping CompletionHandler) {
        
        let body = JsonTool.toJson(fromObject: MineBlogRequest(userId: userId)).data(using: .utf8)
        var req = try! URLRequest(url: API_BLOG_URL + ShowMyMyBlogsAPI + "?userId=\(userId!)", method: .post, headers: httpHeaders)
        req.httpBody = body

        Alamofire.request(req).responseJSON { dataRequest in
            if let data = dataRequest.data {
                let strData = String.init(data: data, encoding: String.Encoding.utf8)
                print(strData!)
                if let res = JsonTool.fromJson(strData!, toClass: BlogListResponse<[blogDetailItem]>.self) {

                    if res.code == 20000  {
                        valueHandler(res.data)
                    } else {
                        completionHandler(res.code, res.message)
                    }
                } else {
                    completionHandler(-1, "Failure")
                }
            }
        }
    }
 
    /// 其他人看我的博客
    static func otherSeeMyBlog(userId: String?,
                         valueHandler: @escaping ([blogDetailItem]) -> Void,
                         completionHandler: @escaping CompletionHandler) {
        
        let body = JsonTool.toJson(fromObject: MineBlogRequest(userId: userId)).data(using: .utf8)
        var req = try! URLRequest(url: API_BLOG_URL + otherSeeMyBlogAPI + "?userId=\(userId!)", method: .post, headers: httpHeaders)
        req.httpBody = body

        Alamofire.request(req).responseJSON { dataRequest in
            if let data = dataRequest.data {
                let strData = String.init(data: data, encoding: String.Encoding.utf8)
                print(strData!)
                if let res = JsonTool.fromJson(strData!, toClass: BlogListResponse<[blogDetailItem]>.self) {

                    if res.code == 20000  {
                        valueHandler(res.data)
                    } else {
                        completionHandler(res.code, res.message)
                    }
                } else {
                    completionHandler(-1, "Failure")
                }
            }
        }
    }
    
    static func blogTop(paramters:Parameters, completionHandler: @escaping CompletionHandler) {
        
        let url = SuperStringUtil.netUrl(API_BLOG_URL + blogTopAPI, paramters)
        print(url)
        Alamofire.request(url, method: .post, headers: httpHeaders).responseJSON { dataRequest in
            
            if let data = dataRequest.data {
                let strData = String.init(data: data, encoding: String.Encoding.utf8)
                print(strData!)
                if let res = JsonTool.fromJson(strData!, toClass: BlogResponse.self) {

                    if res.code == 20000  {
                        completionHandler(res.code, res.message)
                    } else {
                        completionHandler(res.code, res.message)
                    }
                } else {
                    completionHandler(-1, "Failure")
                }
            }
        
        }
    }
    
    static func scanBlog(blog: blogDetailItem) {
        
        if let IMUser = IMController.shared.currentUserRelay.value  {
            
            IMController.shared.checkFriend(userID: blog.userId!) { [self] r in
                
                let paramters: [String: Any] = ["userId":blog.userId!,
                                                "userBlogId":blog.id!,
                                                "relation":r ? 1 : 2,
                                                "lookUserId":IMUser.userID!,
                                                "lookUserTouXiang":IMUser.faceURL ?? "",
                                                "lookUserName":IMUser.nickname!,
                                                "lookUserVip":"1",
                                                "lookTime":YFDateUtil.getCurrentTime(timeFormat: .YYYYMMDDHHMMSS),
                                                "longitudeAndLatitude":"120.2052342,30.2489634",
                                                "lookUserIP":YFNetworkUtils.getIPAddress()!,
                                                "isNotBlog":0,
                                                "isNotQiYe":0,
                                                "tingLiuShiJian":51]
                
//                let paramters: [String: Any] = ["userId":"3433973805",
//                                                "userBlogId":551,
//                                                "relation":2,
//                                                "lookUserId":"8124940774",
//                                                "lookUserTouXiang":"",
//                                                "lookUserName":"{\"b\":0,\"e\":0,\"n\":\"\",\"v\":3}",
//                                                "lookUserVip":"1",
//                                                "lookTime":"2024-09-27 18:06:58",
//                                                "longitudeAndLatitude":"120.373036,30.308040",
//                                                "lookUserIP":"183.156.234.224",
//                                                "isNotBlog":1,
//                                                "isNotQiYe":1,
//                                                "tingLiuShiJian":5]
                
                let url = API_BLOG_URL + addShowBlogsSurveyAPI
                Alamofire.request(url, method: .post, parameters: paramters, encoding: JSONEncoding.default, headers: httpHeaders).responseJSON(completionHandler: { dataRequest in
                    
                    if let data = dataRequest.data {
                        let strData = String.init(data: data, encoding: String.Encoding.utf8)
                        print(strData!)
                        
                    }
                })
                
                
                
            }
        }
        
        
    }
    
    static func editBlog(paramters:Parameters, completionHandler: @escaping CompletionHandler) {
        let url = API_BLOG_URL + updateWaitAuditAutoAPI
        print(paramters)
        Alamofire.request(url, method: .post, parameters: paramters, encoding: JSONEncoding.default, headers: httpHeaders).responseJSON { dataRequest in
            if let data = dataRequest.data {
                let strData = String.init(data: data, encoding: String.Encoding.utf8)
                print(strData!)
                if let res = JsonTool.fromJson(strData!, toClass: BlogResponse.self) {

                    if res.code == 20000  {
                        completionHandler(res.code, res.message)
                    } else {
                        completionHandler(res.code, res.message)
                    }
                } else {
                    completionHandler(-1, "Failure")
                }
            }
        }
    }
    
    static func deleteBlog(paramters:Parameters, completionHandler: @escaping CompletionHandler) {
        let url = SuperStringUtil.netUrl(API_BLOG_URL + deleteBlogAPI, paramters)
        print(paramters)
        Alamofire.request(url, method: .post, parameters: paramters, encoding: JSONEncoding.default, headers: httpHeaders).responseJSON { dataRequest in
            if let data = dataRequest.data {
                let strData = String.init(data: data, encoding: String.Encoding.utf8)
                print(strData!)
                if let res = JsonTool.fromJson(strData!, toClass: BlogResponse.self) {

                    if res.code == 20000  {
                        completionHandler(res.code, res.message)
                    } else {
                        completionHandler(res.code, res.message)
                    }
                } else {
                    completionHandler(-1, "Failure")
                }
            }
        }
    }
    
    static func queryShowBlogsSurvey(paramters:Parameters,
                                     valueHandler: @escaping (BlogSurveyData?) -> Void,
                                     completionHandler: @escaping CompletionHandler) {
        let url = SuperStringUtil.netUrl(API_BLOG_URL + queryShowBlogsSurveyAPI, paramters)
        print(paramters)
        Alamofire.request(url, method: .post, parameters: paramters, encoding: JSONEncoding.default, headers: httpHeaders).responseJSON { dataRequest in
            if let data = dataRequest.data {
                let strData = String.init(data: data, encoding: String.Encoding.utf8)
                print(strData!)
                if let res = JsonTool.fromJson(strData!, toClass: BlogSurveyResponse.self) {
                    
                    print(res.data?.visitorPerDay as Any)
                    if res.code == 20000  {
                        valueHandler(res.data)
                    } else {
                        completionHandler(res.code, res.message)
                    }
                } else {
                    completionHandler(-1, "Failure")
                }
            }
        }
    }
    
    static func queryShowBlogsSurveyOneDay(paramters:Parameters,
                                           valueHandler: @escaping (blogOneDayNumber?) -> Void,
                                           completionHandler: @escaping CompletionHandler) {
        print(paramters)
        let url = SuperStringUtil.netUrl(API_BLOG_URL + queryShowBlogsSurveyOneDayAPI, paramters)
        Alamofire.request(url, method: .post, parameters: paramters, encoding: JSONEncoding.default, headers: httpHeaders).responseJSON { dataRequest in
            if let data = dataRequest.data {
                let strData = String.init(data: data, encoding: String.Encoding.utf8)
                print(strData!)
                if let res = JsonTool.fromJson(strData!, toClass: BlogListResponse<blogOneDayNumber>.self) {
                    
                    if res.code == 20000  {
                        valueHandler(res.data)
                    } else {
                        completionHandler(res.code, res.message)
                    }
                    
                } else {
                    completionHandler(-1, "Failure")
                }
            }
        }
    }
    
    static func queryShowBlogsSurveyFriends(paramters:Parameters,
                                           valueHandler: @escaping ([BlogVisitorListModel]) -> Void,
                                           completionHandler: @escaping CompletionHandler) {
        print(paramters)
        let url = SuperStringUtil.netUrl(API_BLOG_URL + queryShowBlogsSurveyFriendsAPI, paramters)
        
        Alamofire.request(url, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: httpHeaders).responseJSON { dataRequest in
            if let data = dataRequest.data {
                let strData = String.init(data: data, encoding: String.Encoding.utf8)
                print(strData!)
                if let res = JsonTool.fromJson(strData!, toClass: BlogListResponse<[BlogVisitorListModel]>.self) {
                    
                    if res.code == 20000  {
                        valueHandler(res.data)
                    } else {
                        completionHandler(res.code, res.message)
                    }
                    
                } else {
                    completionHandler(-1, "Failure")
                }
            }
        }
    }
    
    static func queryShowBlogsSurveyStranger(paramters:Parameters,
                                           valueHandler: @escaping ([BlogVisitorListModel]) -> Void,
                                           completionHandler: @escaping CompletionHandler) {
        print(paramters)
        let url = SuperStringUtil.netUrl(API_BLOG_URL + queryShowBlogsSurveyStrangerAPI, paramters)
        
        Alamofire.request(url, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: httpHeaders).responseJSON { dataRequest in
            if let data = dataRequest.data {
                let strData = String.init(data: data, encoding: String.Encoding.utf8)
                print(strData!)
                if let res = JsonTool.fromJson(strData!, toClass: BlogListResponse<[BlogVisitorListModel]>.self) {
                    
                    if res.code == 20000  {
                        valueHandler(res.data)
                    } else {
                        completionHandler(res.code, res.message)
                    }
                    
                } else {
                    completionHandler(-1, "Failure")
                }
            }
        }
    }
    
    
    static func addUserLanguage(uid: String) {
        
 
        let url = SuperStringUtil.netUrl(API_BLOG_URL + addUserLanguageAPI, ["language":String.getCurrentLanguageFirst(), "userId": uid, "imToken":UserDefaults.standard.string(forKey: bussinessTokenKey)!])
        
        print(["language":String.getCurrentLanguageFirst(), "userId": uid, "imToken":UserDefaults.standard.string(forKey: bussinessTokenKey)!])
            Alamofire.request(url, method: .post, encoding: JSONEncoding.default, headers: httpHeaders ).responseJSON { dataRequest in
                
                if let data = dataRequest.data {
                    let strData = String.init(data: data, encoding: String.Encoding.utf8)
                    if let res = JsonTool.fromJson(strData!, toClass: BlogResponse.self) {
                        
                        if res.code == 20000  {
                            let defaults = UserDefaults.standard
                            defaults.set(String.getCurrentLanguageFirst(), forKey: "blogLanguage")
                        }
                        
                    } else {
                       
                    }
                }
            }

        
    }
    
    static func updateLanguage(uid: String) {
        

            
            let url = SuperStringUtil.netUrl(API_BLOG_URL + updateUserLanguageAPI, ["language":String.getCurrentLanguageFirst(), "userId": uid,"imToken":UserDefaults.standard.string(forKey: bussinessTokenKey)!])
            
            Alamofire.request(url, method: .post, encoding: JSONEncoding.default, headers: httpHeaders).responseJSON { dataRequest in
                if let data = dataRequest.data {
                    let strData = String.init(data: data, encoding: String.Encoding.utf8)
                    if let res = JsonTool.fromJson(strData!, toClass: BlogResponse.self) {
                        
                        if res.code == 20000  {
                            let defaults = UserDefaults.standard
                            defaults.set(String.getCurrentLanguageFirst(), forKey: "blogLanguage")
                        }
                        
                    } else {
                       
                    }
                }
            }
    
        
    }
    
}


// MARK: - 张亚飞打的标记   Response
class BlogResponse: Decodable {
    var data: String? = nil
    var flag: Bool = false
    var code: Int = 20000
    var message: String? = nil
    var count: Int? = 0
}

class BlogSurveyResponse: Decodable {
    var data: BlogSurveyData? = nil
    var flag: Bool = false
    var code: Int = 20000
    var message: String? = nil
    var count: Int? = 0
}

struct BlogSurveyData: Decodable {
    var friend: Int
    var visitor7Day: Int
    var stranger: Int
    var visitorPerDay: [BlogVisitorPerDay]? = nil
}

struct BlogVisitorPerDay: Decodable {
    var i: Int
    var time: String
}


class BlogListResponse<T: Decodable>: Decodable {
    var data: T
    var flag: Bool = false
    var code: Int = 20000
    var message: String? = nil
    var count: Int? = 0
}

struct BlogVisitorListModel: Decodable {
    var lookUserTouXiang: String
    var lookUserVip: Int
    var isNotBlog: Int
    var lookUserIP: String
    var userId: String
    var userBlogId: String
    var relation: Int
    var lookUserId: String
    var lookUserName: String
    var isNotQiYe: Int
    var lookTime: String
    var longitudeAndLatitude: String
    var tingLiuShiJian: Int
    var ciShu: Int
}

struct blogOneDayNumber: Decodable {
    var stranger: Int
    var friend: Int
}

class BlogAuditRequest: Encodable {
    
    let userId: String?
    let userBlogUrl: String?
    let userBlogIcon: String?
    let userBlogName: String?
    let userBlogIntro: String?
    
    init(userId: String?, userBlogUrl: String?, userBlogIcon: String?, userBlogName: String?, userBlogIntro: String?) {
        self.userId = userId
        self.userBlogUrl = userBlogUrl
        self.userBlogIcon = userBlogIcon
        self.userBlogName = userBlogName
        self.userBlogIntro = userBlogIntro
    }
    
}

class MineBlogRequest: Encodable {
    
    let userId: String?
    
    init(userId: String?) {
        self.userId = userId
    }
    
}

struct blogDetailItem: Codable {
    let id: Int?
    let sign: Int?
    let userBlogUrl: String?
    let userBlogIntro: String?
    let userBlogName: String?
    let userBlogCreatIp: String?
    let userBlogCreatAffiliatingArea: String?
    let userBlogOrder: Int?
    let userId: String?
    let isDelete: Int?
    let creationTime: String?
    let userBlogIcon: String?
    let changeTime: String?
    
    var state: BokeType {
        switch sign {
        case 0:
            return .normal
        case 1, 4:
            return .wait
        case 2:
            return .refuse
        case 3:
            return .limit
            
        default:
            return.normal
        }
    }
    
}
