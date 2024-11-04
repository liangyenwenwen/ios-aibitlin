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
import ProgressHUD
import OpenIMSDK

class YFMineNetViewModel: AccountViewModel {
    
//    static let API_BLOG_URL = "http://192.168.7.107:18898"
//    public static let API_BLOG_URL = "http://blog.aibitlin.com:18898"
    public static let API_BLOG_URL = "https://imblog.aibitlin.com"

    
    
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
    
    private static let vipPurchaseInitializeAPI = "/vip/purchase/initialize"
    private static let vipPurchaseSucceedsAPI = "/vip/purchase/succeeds"
    
    
    // MARK: - 张亚飞打的标记 IM AIP
    private static let pictureFindAPI = "/picture/find"
    
    
    // MARK: - 张亚飞打的标记 举报 AIP
    private static let reportBlogAddAPI = "/report/reportBlogAdd"
    private static let reportUserAddAPI = "/report/reportUserAdd"
    private static let reportChatHistoryAddAPI = "/report/reportChatHistoryAdd"
    private static let feedBackAddAPI = "/report/problemFeedback/problemFeedbackAdd"
    private static let reportComentsAddAPI = "/report/reportCircleOfFriendsAdd"
    
    //"183.156.234.224"
    private static var httpHeaders : HTTPHeaders = [
        "token":UserDefaults.standard.string(forKey: bussinessTokenKey)!,
        "X-Forwarded-For":IMController.shared.publicIP,
        "Authorization":"eyJ1c2VySW5mbyI6InVzZXJCbG9nWWFuWmhlbmdUb2tlbiJ9",
        "Content-Type":"application/json",
//        "operationID":UUID().uuidString,
        "operationID":String(Int(Date().timeIntervalSince1970)),
    ]
    
   // MARK: - 张亚飞打的标记   博客接口
   /// 新增博客信息到自动审核
    static func blogAudit(userId: String?,
                          userBlogUrl: String?,
                          userBlogIcon:String?,
                          userBlogName:String?,
                          userBlogIntro: String?,
                          completionHandler: @escaping CompletionHandler) {
        
        
        if !NetworkStatus.isReacheable {
//            SuperToast.show(title: "")
            return
        }
        
        
//        ProgressHUD.animate()
        
        
        let body = JsonTool.toJson(fromObject: BlogAuditRequest(userId: userId, userBlogUrl: userBlogUrl, userBlogIcon: userBlogIcon, userBlogName: userBlogName, userBlogIntro: userBlogIntro)).data(using: .utf8)
        
        
        var req = try! URLRequest(url: API_BLOG_URL + BlogAuditAddWaitAuditAutoAPI, method: .post, headers: httpHeaders)
        req.httpBody = body
        
//        Alamofire.request(API_BLOG_URL + BlogAuditAddWaitAuditAutoAPI, method: .post, parameters: ["userId": userId!])
        
        
        Alamofire.request(req).responseString { (response: DataResponse<String>) in
            
//            ProgressHUD.dismiss()
            
            switch response.result {
            case .success(let result):
                if let res = JsonTool.fromJson(result, toClass: BlogResponse.self) {

                    if res.code == 20000  {
                        print("请求成功")
                        UserDefaults.standard.set("0", forKey: "blogVersion\(Open_im_sdkGetLoginUserID())")
                    } else {
                        print("请求失败")
                    }
                    
                    completionHandler(res.code, res.message)
                    
                } else {
                    completionHandler(-1, "Fail")
                }
            case .failure(let err):
                ProgressHUD.dismiss()
                completionHandler(-1, err.localizedDescription)
               
            }
        }
        
    }
     
    /// 我的博客
    static func mineBlog(userId: String?,
                         valueHandler: @escaping ([blogDetailItem]) -> Void,
                         completionHandler: @escaping CompletionHandler) {
        
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: <#T##DispatchWorkItem#>)
        
        
        
        if let IMUser = IMController.shared.currentUserRelay.value {
            let blogVersion = UserDefaults.standard.string(forKey: "blogVersion\(Open_im_sdkGetLoginUserID())") ?? "0"
            
            
            let body = JsonTool.toJson(fromObject: MineBlogRequest(userId: userId, userBlogVersion: "\(blogVersion)")).data(using: .utf8)
            var req = try! URLRequest(url: API_BLOG_URL + ShowMyMyBlogsAPI + "?userId=\(userId!)" + "&userBlogVersion=\(blogVersion)", method: .post, headers: httpHeaders)
            req.httpBody = body

            Alamofire.request(req).responseJSON { dataRequest in
                

                
                if let data = dataRequest.data {
                    let strData = String.init(data: data, encoding: String.Encoding.utf8)
                    print(strData!)
                    
                    if let res = JsonTool.fromJson(strData!, toClass: BlogListResponse<myBlogListValue>.self) {

                        if res.code == 20000  {
                            
//                            if res.data.showBlogs?.count ?? 0 > 0 {
//                                valueHandler(res.data.showBlogs!)
//                                YFFileDataUtil.saveDataToFile(.cache, blogsArr: res.data.showBlogs!)
//                            } else {
//                                valueHandler(YFFileDataUtil.readDataToFile(.cache))
//                            }
                            UserDefaults.standard.set(res.data.version, forKey: "blogVersion\(Open_im_sdkGetLoginUserID())")
                            if Int(blogVersion) ==  0 {
                                valueHandler(res.data.showBlogs!)
                                YFFileDataUtil.saveDataToFile(.cache, blogsArr: res.data.showBlogs!)
                            } else {
                                valueHandler(YFFileDataUtil.readDataToFile(.cache))
                            }
                            
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
 
    /// 其他人看我的博客
    static func otherSeeMyBlog(userId: String?,
                         valueHandler: @escaping ([blogDetailItem]) -> Void,
                         completionHandler: @escaping CompletionHandler) {
        
//        ProgressHUD.animate()
        
        let body = JsonTool.toJson(fromObject: othersBlogRequest(userId: userId)).data(using: .utf8)
        var req = try! URLRequest(url: API_BLOG_URL + otherSeeMyBlogAPI + "?userId=\(userId!)", method: .post, headers: httpHeaders)
        req.httpBody = body

        Alamofire.request(req).responseJSON { dataRequest in
            
//            ProgressHUD.dismiss()
            
            if let data = dataRequest.data {
                let strData = String.init(data: data, encoding: String.Encoding.utf8)
                print(strData!)
                if let res = JsonTool.fromJson(strData!, toClass: BlogListResponse<[blogDetailItem]>.self) {

                    if res.code == 20000  {
                        valueHandler(res.data)
                    } else {
                        completionHandler(-1, "failure")
                    }
                } else {
                    completionHandler(-1, "failure")
                }
            } else {
                completionHandler(-1, "-1")
            }
            
        }
    }
    
    static func blogTop(paramters:Parameters, completionHandler: @escaping CompletionHandler) {
        ProgressHUD.animate()
        
        let url = SuperStringUtil.netUrl(API_BLOG_URL + blogTopAPI, paramters)
        print(url)
        Alamofire.request(url, method: .post, headers: httpHeaders).responseJSON { dataRequest in
            
            ProgressHUD.dismiss()
            
            if let data = dataRequest.data {
                let strData = String.init(data: data, encoding: String.Encoding.utf8)
                print(strData!)
                if let res = JsonTool.fromJson(strData!, toClass: BlogResponse.self) {

                    if res.code == 20000  {
                        completionHandler(res.code, res.message)
                    } else {
                        completionHandler(-1, "failure")
                    }
                } else {
                    completionHandler(-1, "failure")
                }
            }else {
                completionHandler(-1, "-1")
            }
        
        }
    }
    // MARK: - 张亚飞打的标记
    static func scanBlog(blog: blogDetailItem, duration: Int) {
        
        if let IMUser = IMController.shared.currentUserRelay.value  {
            
            if IMUser.userID == blog.userId {
                return
            }
  
            IMController.shared.checkFriend(userID: blog.userId!) { [self] r in
                
                let userStruct = SuperStringUtil.getUserState(showname: IMUser.nickname!)
                
                let paramters: [String: Any] = ["userId":blog.userId!,
                                                "userBlogId":blog.id!,
                                                "relation":r ? 1 : 2,
                                                "lookUserId":IMUser.userID!,
                                                "lookUserTouXiang":IMUser.faceURL ?? "",
                                                "lookUserName":userStruct.n,
                                                "lookUserVip":"\(userStruct.v)",
                                                "lookTime":YFDateUtil.getCurrentTime(timeFormat: .YYYYMMDDHHMMSS),
//                                                "longitudeAndLatitude":SuperStringUtil.getCurrentLocation(),
                                                "longitudeAndLatitude":"",
                                                "lookUserIP":IMController.shared.publicIP,
                                                "isNotBlog":userStruct.b,
                                                "isNotQiYe":userStruct.e,
                                                "tingLiuShiJian":duration]

                
                let url = API_BLOG_URL + addShowBlogsSurveyAPI
                ProgressHUD.animate()
                Alamofire.request(url, method: .post, parameters: paramters, encoding: JSONEncoding.default, headers: httpHeaders).responseJSON(completionHandler: { dataRequest in
                    ProgressHUD.dismiss()
                    if let data = dataRequest.data {
                        let strData = String.init(data: data, encoding: String.Encoding.utf8)
                        print(strData!)
                        
                    }
                })
                
                
                
            }
        }
        
        
    }
    
    static func editBlog(paramters:Parameters, completionHandler: @escaping CompletionHandler) {
        
        ProgressHUD.animate()
        
        let url = API_BLOG_URL + updateWaitAuditAutoAPI
        Alamofire.request(url, method: .post, parameters: paramters, encoding: JSONEncoding.default, headers: httpHeaders).responseJSON { dataRequest in
            
            ProgressHUD.dismiss()
            
            if let data = dataRequest.data {
                let strData = String.init(data: data, encoding: String.Encoding.utf8)
                print(strData!)
                if let res = JsonTool.fromJson(strData!, toClass: BlogResponse.self) {

                    if res.code == 20000  {
                        UserDefaults.standard.set("0", forKey: "blogVersion\(Open_im_sdkGetLoginUserID())")
                        completionHandler(res.code, res.message)
                    } else {
                        completionHandler(-1, "failure")
                    }
                } else {
                    completionHandler(-1, "failure")
                }
            }else{
                completionHandler(-1, "-1")
            }
        }
    }
    
    static func deleteBlog(paramters:Parameters, completionHandler: @escaping CompletionHandler) {
        
        ProgressHUD.animate()
        
        let url = SuperStringUtil.netUrl(API_BLOG_URL + deleteBlogAPI, paramters)
        Alamofire.request(url, method: .post, parameters: paramters, encoding: JSONEncoding.default, headers: httpHeaders).responseJSON { dataRequest in
            
            ProgressHUD.dismiss()
            
            if let data = dataRequest.data {
                let strData = String.init(data: data, encoding: String.Encoding.utf8)
                if let res = JsonTool.fromJson(strData!, toClass: BlogResponse.self) {

                    if res.code == 20000  {
                        UserDefaults.standard.set("0", forKey: "blogVersion\(Open_im_sdkGetLoginUserID())")
                        completionHandler(res.code, res.message)
                    } else {
                        completionHandler(-1, "failure")
                    }
                } else {
                    completionHandler(-1, "failure")
                }
            }else{
                completionHandler(-1, "-1")
            }
        }
    }
    
    static func queryShowBlogsSurvey(paramters:Parameters,
                                     valueHandler: @escaping (BlogSurveyData?) -> Void,
                                     completionHandler: @escaping CompletionHandler) {
        
//        ProgressHUD.animate()
        
        let url = SuperStringUtil.netUrl(API_BLOG_URL + queryShowBlogsSurveyAPI, paramters)
        Alamofire.request(url, method: .post, parameters: paramters, encoding: JSONEncoding.default, headers: httpHeaders).responseJSON { dataRequest in
            
//            ProgressHUD.dismiss()
            
            if let data = dataRequest.data {
                let strData = String.init(data: data, encoding: String.Encoding.utf8)
                print(strData!)
                if let res = JsonTool.fromJson(strData!, toClass: BlogSurveyResponse.self) {
                    
                    print(res.data?.visitorPerDay as Any)
                    if res.code == 20000  {
                        valueHandler(res.data)
                    } else {
                        completionHandler(-1, "failure")
                    }
                } else {
                    completionHandler(-1, "failure")
                }
            }else{
                completionHandler(-1, "-1")
            }
        }
    }
    
    static func queryShowBlogsSurveyOneDay(paramters:Parameters,
                                           valueHandler: @escaping (blogOneDayNumber?) -> Void,
                                           completionHandler: @escaping CompletionHandler) {
        
//        ProgressHUD.animate()
        
        let url = SuperStringUtil.netUrl(API_BLOG_URL + queryShowBlogsSurveyOneDayAPI, paramters)
        Alamofire.request(url, method: .post, parameters: paramters, encoding: JSONEncoding.default, headers: httpHeaders).responseJSON { dataRequest in
            
//            ProgressHUD.dismiss()
            
            if let data = dataRequest.data {
                let strData = String.init(data: data, encoding: String.Encoding.utf8)
                print(strData!)
                if let res = JsonTool.fromJson(strData!, toClass: BlogListResponse<blogOneDayNumber>.self) {
                    
                    if res.code == 20000  {
                        valueHandler(res.data)
                    } else {
                        completionHandler(-1, "failure")
                    }
                    
                } else {
                    completionHandler(-1, "failure")
                }
            }else{
                completionHandler(-1, "-1")
            }
        }
    }
    
    static func queryShowBlogsSurveyFriends(paramters:Parameters,
                                           valueHandler: @escaping ([BlogVisitorListModel]) -> Void,
                                           completionHandler: @escaping CompletionHandler) {
        
//        ProgressHUD.animate()
        let url = SuperStringUtil.netUrl(API_BLOG_URL + queryShowBlogsSurveyFriendsAPI, paramters)
        
        Alamofire.request(url, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: httpHeaders).responseJSON { dataRequest in
            
//            ProgressHUD.dismiss()
            if let data = dataRequest.data {
                
                let strData = String.init(data: data, encoding: String.Encoding.utf8)
                print(strData!)
                if let res = JsonTool.fromJson(strData!, toClass: BlogListResponse<[BlogVisitorListModel]>.self) {
                    
                    if res.code == 20000  {
                        valueHandler(res.data)
                    } else {
                        completionHandler(-1, "failure")
                    }
                    
                } else {
                    completionHandler(-1, "failure")
                }
            }else{
                completionHandler(-1, "-1")
            }
        }
    }
    
    static func queryShowBlogsSurveyStranger(paramters:Parameters,
                                           valueHandler: @escaping ([BlogVisitorListModel]) -> Void,
                                           completionHandler: @escaping CompletionHandler) {
//        ProgressHUD.animate()
        
        let url = SuperStringUtil.netUrl(API_BLOG_URL + queryShowBlogsSurveyStrangerAPI, paramters)
        
        Alamofire.request(url, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: httpHeaders).responseJSON { dataRequest in
            
//            ProgressHUD.dismiss()
            
            if let data = dataRequest.data {
                let strData = String.init(data: data, encoding: String.Encoding.utf8)
                print(strData!)
                if let res = JsonTool.fromJson(strData!, toClass: BlogListResponse<[BlogVisitorListModel]>.self) {
                    
                    if res.code == 20000  {
                        valueHandler(res.data)
                    } else {
                        completionHandler(-1, "failure")
                    }
                    
                } else {
                    completionHandler(-1, "failure")
                }
            }else{
                completionHandler(-1, "-1")
            }
        }
    }
    
    
    static func vipPurchaseInitialize(paramters:Parameters,
                                      valueHandler: @escaping (String) -> Void,
                                      completionHandler: @escaping CompletionHandler) {
        
//        ProgressHUD.animate()
        
        let url = SuperStringUtil.netUrl(API_BLOG_URL + vipPurchaseInitializeAPI, paramters)
    
        Alamofire.request(url, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: httpHeaders).responseJSON { dataRequest in
            
//            ProgressHUD.dismiss()
            
            if let data = dataRequest.data {
                let strData = String.init(data: data, encoding: String.Encoding.utf8)
                print(strData!)
                if let res = JsonTool.fromJson(strData!, toClass: BlogResponse.self) {
                    
                    if res.code == 20000  {
                        if res.data != nil {
                            valueHandler(res.data!)
                        }
                    } else {
                        completionHandler(res.code, res.message)
                    }
                    
                } else {
                    completionHandler(-1, "failure")
                }
                
                
            }
        }
    }
    
    static func vipPurchaseSucceeds(paramters:Parameters,
                                      valueHandler: @escaping (String) -> Void,
                                      completionHandler: @escaping CompletionHandler) {
        
        ProgressHUD.animate()
        
        let url = SuperStringUtil.netUrl(API_BLOG_URL + vipPurchaseSucceedsAPI, paramters)
        
        Alamofire.request(url, method: .post, parameters: paramters, encoding: JSONEncoding.default, headers: httpHeaders).responseJSON { dataRequest in
            if let data = dataRequest.data {
                let strData = String.init(data: data, encoding: String.Encoding.utf8)
                print(strData!)
                
                ProgressHUD.dismiss()
                if let data = dataRequest.data {
                    let strData = String.init(data: data, encoding: String.Encoding.utf8)
                    if let res = JsonTool.fromJson(strData!, toClass: BlogResponse.self) {
                        
                        if res.code == 20000  {
                           valueHandler("scuccess")
                        } else {
                            completionHandler(res.code, res.message)
                        }
                        
                    } else {
                        completionHandler(-1, "-1".localized())
                    }
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
                            defaults.set(String.getCurrentLanguageFirst(), forKey: "blogLanguage\(uid)")
                        }
//                        UserDefaults.standard.set("0", forKey: "blogVersion\(Open_im_sdkGetLoginUserID())")
                    } else {
                       
                    }
                }
            }

        
    }
    
    static func updateLanguage(uid: String) {
  
        let url = SuperStringUtil.netUrl(API_BLOG_URL + updateUserLanguageAPI, ["language":String.getCurrentLanguageFirst(), "userId": uid, "imToken":UserDefaults.standard.string(forKey: bussinessTokenKey)!])
        
        Alamofire.request(url, method: .post, encoding: JSONEncoding.default, headers: httpHeaders).responseJSON { dataRequest in
            if let data = dataRequest.data {
                let strData = String.init(data: data, encoding: String.Encoding.utf8)
                if let res = JsonTool.fromJson(strData!, toClass: BlogResponse.self) {
                    
                    if res.code == 20000  {
                        let defaults = UserDefaults.standard
                        defaults.set(String.getCurrentLanguageFirst(), forKey: "blogLanguage\(uid)")
                    }
                    
//                    UserDefaults.standard.set("0", forKey: "blogVersion\(Open_im_sdkGetLoginUserID())")
                } else {
                   
                }
            }
        }
    
        
    }
    
  
    
    
}

// MARK: - 张亚飞打的标记   IM新增API
extension YFMineNetViewModel {
    
     static func pictureFind(valueHandler: @escaping ([String]) -> Void,
                             completionHandler: @escaping CompletionHandler) {
        let url = API_BASE_URL + pictureFindAPI
         ProgressHUD.animate()
         Alamofire.request(url, method: .post, parameters: [:],encoding: JSONEncoding.default, headers: httpHeaders).responseJSON { dataRequest in
             ProgressHUD.dismiss()
             if let data  = dataRequest.data {
                 let strData = String.init(data: data, encoding: String.Encoding.utf8)
                 print(strData)
                 if let res = JsonTool.fromJson(strData!, toClass: Response<PictureFindResponse>.self) {
                     
                     if res.errCode == 0  {
                         valueHandler(res.data?.urls ?? [])
                     } else {
//                         ProgressHUD.error(res.errMsg)
                         SuperToast.show(title: res.errMsg!)
                     }
                     
                 } else {
                     SuperToast.show(title: "failure".localized())
                 }
             }else{
                 SuperToast.show(title: "-1".localized())
             }
         }
    }
    
}

// MARK: - 张亚飞打的标记   举报
enum ReportType {
    case  user
    case  chatHistory
    case  blog
    case  feedback
    case  moments
}
extension YFMineNetViewModel {
    
    static func reportUserNet(paramters:Parameters, reportType:ReportType,valueHandler: @escaping (String) -> Void) {
        
        var url = ""
        switch reportType {
            case .user:
                url = API_BLOG_URL + reportUserAddAPI
            case.chatHistory:
                url = API_BLOG_URL + reportChatHistoryAddAPI
            case .blog:
                url = API_BLOG_URL + reportBlogAddAPI
            case .feedback:
                url = API_BLOG_URL + feedBackAddAPI
        case .moments:
            url = API_BLOG_URL + reportComentsAddAPI
        }
        
        
        Alamofire.request(url, method: .post, parameters: paramters, encoding: JSONEncoding.default, headers: httpHeaders).responseJSON { dataRequest in
            
            if let data  = dataRequest.data {
                let strData = String.init(data: data, encoding: String.Encoding.utf8)
                if let res = JsonTool.fromJson(strData!, toClass: BlogResponse.self) {
                    
                    if res.code == 20000  {
                        SuperToast.show(title: "提交成功".localized())
                        valueHandler("提交成功")
                    }else{
                        SuperToast.show(title: "failure".localized())
                    }
                    
                } else {
                    SuperToast.show(title: "failure".localized())
                }
   
            }else{
                SuperToast.show(title: "-1".localized())
            }
        }
    }
    
    
    
}

struct PictureFindResponse: Codable {
    var urls : [String]?
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

struct myBlogListValue: Codable {
    var showBlogs : [blogDetailItem]?
    var version: String?
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
    let userBlogVersion: String?
    
    init(userId: String?, userBlogVersion: String?) {
        self.userId = userId
        self.userBlogVersion = userBlogVersion
    }
    
}

class othersBlogRequest: Encodable {
    
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
    
    func toBokeElem() -> BokeElem {
        let source = self
        let blog =  BokeElem(id: source.id, sign: source.sign, userBlogUrl: source.userBlogUrl, userBlogIntro: source.userBlogIntro, userBlogName: source.userBlogName, userBlogCreatIp: source.userBlogCreatIp, userBlogCreatAffiliatingArea: source.userBlogCreatAffiliatingArea, userBlogOrder: source.userBlogOrder, userId: source.userId, isDelete: source.isDelete, creationTime: source.creationTime, userBlogIcon: source.userBlogIcon, changeTime: source.changeTime)
        
        return blog
    }
}
