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
    
    
    // MARK: - 张亚飞打的标记 blogAPI
    private static let upLoadBlogIconAPI = "/blog/upload"
    private static let BlogAuditAddWaitAuditAutoAPI = "/blog/add" //添加网站
    private static let ShowMyMyBlogsAPI = "/blog/myList" //我的网站列表
    private static let updateWaitAuditAutoAPI = "/blog/edit"//修改网站
    private static let deleteBlogAPI = "/blog/ownerDel" //删除网站
    private static let blogTopAPI = "/blog/setTop"//网站置顶
    private static let otherSeeMyBlogAPI = "/blog/othersList" //他人网站列表
    private static let flagBlogAPI = "/blog/flag" //收藏网站
    
    private static let checkH5API = "/blog/signIn" //校验jwt给H5、博客、官方小程序使用
    private static let getPublicCustomerMessageNextAPI = "/blog/signhost" //微交互地址签名



    
    private static let queryShowBlogsSurveyAPI = "/blog/myBlogBeBrowsed/queryMyBlogBeBrowsedOverview"//
    private static let queryShowBlogsSurveyOneDayAPI = "/blog/myBlogBeBrowsed/queryMyBlogBeBrowsedOverviewOne"
    private static let queryShowBlogsSurveyFriendsAPI = "/blog/myBlogBeBrowsed/queryMyBlogBeBrowsedOverviewFriend"
    private static let queryShowBlogsSurveyStrangerAPI = "/blog/myBlogBeBrowsed/queryMyBlogBeBrowsedOverviewStranger"
    private static let addShowBlogsSurveyAPI = "/blog/myBlogBeBrowsed/addMyBlogBeBrowsed" //
    
    
    private static let checkAppVersionAPI = "/version/query"
    
    private static let updateUserLanguageAPI = "/audit/userLanguageToken/adduserLanguageToken"
    private static let addUserLanguageAPI = "/audit/userLanguageToken/adduserLanguageToken"
    
    private static let vipPurchaseInitializeAPI = "/vip/purchase/initialize"
    private static let vipPurchaseSucceedsAPI = "/vip/purchase/succeeds"
    
    
    // MARK: - 张亚飞打的标记 IM AIP
    private static let pictureFindAPI = "/picture/find"
    
    
    // MARK: - 张亚飞打的标记 举报 AIP
    private static let reportBlogAddAPI = "/report/reportBlog/reportBlogAdd"
    private static let reportUserAddAPI = "/report/reportUser/reportUserAdd"
    private static let reportChatHistoryAddAPI = "/report/reportChatHistory/reportChatHistoryAdd"
    private static let feedBackAddAPI = "/report/problemFeedback/problemFeedbackAdd"
    private static let reportComentsAddAPI = "/report/reportCircleOfFriendsAdd"
    
    //"183.156.234.224"
    static func getHttpHeader() -> HTTPHeaders{
        let httpHeaders : HTTPHeaders = [
            "token":IMController.shared.tokenABC,
            "X-Forwarded-Add":IMController.shared.publicAddress,
            "X-Forwarded-IP":IMController.shared.publicIP,
            "Authorization":"eyJ1c2VySW5mbyI6InVzZXJCbG9nWWFuWmhlbmdUb2tlbiJ9",
            "Content-Type":"application/json",
            "operationID":String(Int(Date().timeIntervalSince1970)),
        ]
       return httpHeaders
    }
    
   // MARK: - 张亚飞打的标记   网站接口
   /// 新增网站信息到自动审核
    static func blogAudit(logo: String?,
                          name: String?,
                          url:String?,
                          mark:String?,
                          pwd: String?,
                          completionHandler: @escaping CompletionHandler) {
        
        
        if !NetworkStatus.isReacheable {
//            SuperToast.show(title: "")
            return
        }
        
        
//        ProgressHUD.animate()
        
        
        let body = JsonTool.toJson(fromObject: BlogAuditRequest(logo: logo, name: name, url: url, mark: mark, pwd: pwd)).data(using: .utf8)
        
        
        var req = try! URLRequest(url: IMController.shared.defaultBlogAddress + BlogAuditAddWaitAuditAutoAPI, method: .post, headers: getHttpHeader())
        req.httpBody = body
        Alamofire.request(req).responseString { (response: DataResponse<String>) in
            
//            ProgressHUD.dismiss()
            
            switch response.result {
            case .success(let result):
                if let res = JsonTool.fromJson(result, toClass: BlogResponseNOData.self) {
                    UserDefaults.standard.set(0, forKey: "blogVersion\(Open_im_sdkGetLoginUserID())")
                    completionHandler(res.code, res.msg)
                    
                } else {
                    completionHandler(-1, "Fail")
                }
            case .failure(let err):
                ProgressHUD.dismiss()
                completionHandler(-1, err.localizedDescription)
               
            }
        }
        
    }
     
    /// 我的网站
    static func mineBlog(time: Int?,
                         hash:String?,
                         valueHandler: @escaping ([myBlogShowBlogPOModel]?) -> Void,
                         completionHandler: @escaping CompletionHandler) {
        if let IMUser = IMController.shared.currentUserRelay.value {
            let body = JsonTool.toJson(fromObject: MineBlogRequest(time: time, hash: hash)).data(using: .utf8)
            var req = try! URLRequest(url: IMController.shared.defaultBlogAddress + ShowMyMyBlogsAPI, method: .post, headers: getHttpHeader())
            req.httpBody = body

            Alamofire.request(req).responseJSON { dataRequest in
                if let data = dataRequest.data {
                    let strData = String.init(data: data, encoding: String.Encoding.utf8)
                    print(strData!)
                    
                    if let res = JsonTool.fromJson(strData!, toClass: BlogListResponse<myBlogListValue>.self) {

                        if res.code == 200  {
                            if time != res.result.time{
                                UserDefaults.standard.set(res.result.time, forKey: "blogVersion\(Open_im_sdkGetLoginUserID())")
                                YFFileDataUtil.saveAllDataToFile(blogsArr: res.result.data ?? [])
                            }
                            valueHandler(res.result.data)
                        } else {
                            completionHandler(res.code, res.msg)
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
 
    /// 其他人看我的网站
    static func otherSeeMyBlog(uid: String?,
                               hash:String?,
                               pwd:String?,
                         valueHandler: @escaping ([myBlogShowBlogPOModel]?) -> Void,
                         completionHandler: @escaping CompletionHandler) {
        
//        ProgressHUD.animate()
        
        let body = JsonTool.toJson(fromObject: othersBlogRequest(uid:uid,hash:hash,pwd:pwd)).data(using: .utf8)
        var req = try! URLRequest(url: IMController.shared.defaultBlogAddress + otherSeeMyBlogAPI, method: .post, headers: getHttpHeader())
        req.httpBody = body

        Alamofire.request(req).responseJSON { dataRequest in
            
//            ProgressHUD.dismiss()
            
            if let data = dataRequest.data {
                let strData = String.init(data: data, encoding: String.Encoding.utf8)
                print(strData!)
                if let res = JsonTool.fromJson(strData!, toClass: BlogListResponse<myBlogListValue>.self) {

                    if res.code == 200  {
                        valueHandler(res.result.data)
                    } else {
                        completionHandler(res.code, res.msg)
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
        
        let url = SuperStringUtil.netUrl(IMController.shared.defaultBlogAddress + blogTopAPI, paramters)
        print(url)
        Alamofire.request(url, method: .post, headers: getHttpHeader()).responseJSON { dataRequest in
            
            ProgressHUD.dismiss()
            
            if let data = dataRequest.data {
                let strData = String.init(data: data, encoding: String.Encoding.utf8)
                print(strData!)
                if let res = JsonTool.fromJson(strData!, toClass: BlogResponseNOData.self) {
                    UserDefaults.standard.set(0, forKey: "blogVersion\(Open_im_sdkGetLoginUserID())")
                    completionHandler(res.code, res.msg)
                } else {
                    completionHandler(-1, "failure")
                }
            }else {
                completionHandler(-1, "-1")
            }
        
        }
    }
    static func flagBlog(paramters:Parameters, completionHandler: @escaping CompletionHandler) {
        ProgressHUD.animate()
        
        let url = SuperStringUtil.netUrl(IMController.shared.defaultBlogAddress + flagBlogAPI, paramters)
        print(url)
        Alamofire.request(url, method: .post, headers: getHttpHeader()).responseJSON { dataRequest in
            
            ProgressHUD.dismiss()
            
            if let data = dataRequest.data {
                let strData = String.init(data: data, encoding: String.Encoding.utf8)
                print(strData!)
                if let res = JsonTool.fromJson(strData!, toClass: BlogResponseNOData.self) {
                    UserDefaults.standard.set(0, forKey: "blogVersion\(Open_im_sdkGetLoginUserID())")
                    completionHandler(res.code, res.msg)
                } else {
                    completionHandler(-1, "failure")
                }
            }else {
                completionHandler(-1, "-1")
            }
        
        }
    }
    // MARK: - 张亚飞打的标记
    static func scanBlog(blog: myBlogShowBlogPOModel, duration: Int) {
        
//        if let IMUser = IMController.shared.currentUserRelay.value  {
//            
//            if IMUser.userID == blog.myBlogShowBlogPO.userId {
//                return
//            }
//  
//            IMController.shared.checkFriend(userID: blog.myBlogShowBlogPO.userId!) { [self] r in
//                
//                let userStruct = SuperStringUtil.getUserState(showname: IMUser.nickname!)
//                
//                let paramters: [String: Any] = ["userId":blog.myBlogShowBlogPO.userId!,
//                                                "userBlogId":blog.myBlogShowBlogPO.id!,
//                                                "relation":r ? 1 : 2,
//                                                "lookUserId":IMUser.userID!,
//                                                "lookUserTouXiang":IMUser.faceURL ?? "",
//                                                "lookUserName":userStruct.n,
//                                                "lookUserVip":"\(userStruct.v)",
//                                                "lookTime":YFDateUtil.getCurrentTime(timeFormat: .YYYYMMDD),
////                                                "longitudeAndLatitude":SuperStringUtil.getCurrentLocation(),
//                                                "longitudeAndLatitude":"",
//                                                "lookUserIP":IMController.shared.publicIP,
//                                                "isNotBlog":userStruct.b,
//                                                "isNotQiYe":userStruct.e,
//                                                "lengthOfStay":duration,
//                                                "isVip":"2",
//                                                "blogUrl":blog.myBlogShowBlogPO.userBlogUrl ?? "",
//                                                "blogIcon":blog.myBlogShowBlogPO.userBlogIcon ?? "",
//                                                "blogName":blog.myBlogShowBlogPO.userBlogName ?? "",
//                                                "blogIntor":blog.myBlogShowBlogPO.userBlogIntro ?? ""]
//
//                
//                let url = IMController.shared.defaultBlogAddress + addShowBlogsSurveyAPI
//                ProgressHUD.animate()
//                Alamofire.request(url, method: .post, parameters: paramters, encoding: JSONEncoding.default, headers: httpHeaders).responseJSON(completionHandler: { dataRequest in
//                    ProgressHUD.dismiss()
//                    if let data = dataRequest.data {
//                        let strData = String.init(data: data, encoding: String.Encoding.utf8)
//                        print(strData!)
//                        
//                    }
//                })
//                
//                
//                
//            }
//        }
        
        
    }
    
    static func editBlog(paramters:Parameters, completionHandler: @escaping CompletionHandler) {
        
        ProgressHUD.animate()
        
        let url = IMController.shared.defaultBlogAddress + updateWaitAuditAutoAPI
        Alamofire.request(url, method: .post, parameters: paramters, encoding: JSONEncoding.default, headers: getHttpHeader()).responseJSON { dataRequest in
            
            ProgressHUD.dismiss()
            
            if let data = dataRequest.data {
                let strData = String.init(data: data, encoding: String.Encoding.utf8)
                print(strData!)
                if let res = JsonTool.fromJson(strData!, toClass: BlogResponseNOData.self) {
                    UserDefaults.standard.set(0, forKey: "blogVersion\(Open_im_sdkGetLoginUserID())")
                    completionHandler(res.code, res.msg)
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
        
        let url = SuperStringUtil.netUrl(IMController.shared.defaultBlogAddress + deleteBlogAPI, paramters)
        Alamofire.request(url, method: .post, parameters: paramters, encoding: JSONEncoding.default, headers: getHttpHeader()).responseJSON { dataRequest in
            
            ProgressHUD.dismiss()
            
            if let data = dataRequest.data {
                let strData = String.init(data: data, encoding: String.Encoding.utf8)
                if let res = JsonTool.fromJson(strData!, toClass: BlogResponseNOData.self) {
                    UserDefaults.standard.set(0, forKey: "blogVersion\(Open_im_sdkGetLoginUserID())")
                    completionHandler(res.code, res.msg)
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
        
        let url = SuperStringUtil.netUrl(IMController.shared.defaultBlogAddress + queryShowBlogsSurveyAPI, paramters)
        Alamofire.request(url, method: .post, parameters: paramters, encoding: JSONEncoding.default, headers: getHttpHeader()).responseJSON { dataRequest in
            
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
        
        
//        let url = SuperStringUtil.netUrl(IMController.shared.defaultBlogAddress + queryShowBlogsSurveyOneDayAPI, paramters)
//        Alamofire.request(url, method: .post, parameters: paramters, encoding: JSONEncoding.default, headers: httpHeaders).responseJSON { dataRequest in
//            
////            ProgressHUD.dismiss()
//            
//            if let data = dataRequest.data {
//                let strData = String.init(data: data, encoding: String.Encoding.utf8)
//                print(strData!)
//                if let res = JsonTool.fromJson(strData!, toClass: BlogListResponse<blogOneDayNumber>.self) {
//                    
//                    if res.code == 20000  {
//                        valueHandler(res.data)
//                    } else {
//                        completionHandler(-1, "failure")
//                    }
//                    
//                } else {
//                    completionHandler(-1, "failure")
//                }
//            }else{
//                completionHandler(-1, "-1")
//            }
//        }
    }
    
    static func queryShowBlogsSurveyFriends(paramters:Parameters,
                                           valueHandler: @escaping ([BlogVisitorListModel]) -> Void,
                                           completionHandler: @escaping CompletionHandler) {
        
//        let url = SuperStringUtil.netUrl(IMController.shared.defaultBlogAddress + queryShowBlogsSurveyFriendsAPI, paramters)
//
//        Alamofire.request(url, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: httpHeaders).responseJSON { dataRequest in
//            
////            ProgressHUD.dismiss()
//            if let data = dataRequest.data {
//                
//                let strData = String.init(data: data, encoding: String.Encoding.utf8)
//                print(strData!)
//                if let res = JsonTool.fromJson(strData!, toClass: BlogListResponse<[BlogVisitorListModel]>.self) {
//                    
//                    if res.code == 20000  {
//                        valueHandler(res.data)
//                    } else {
//                        completionHandler(-1, "failure")
//                    }
//                    
//                } else {
//                    completionHandler(-1, "failure")
//                }
//            }else{
//                completionHandler(-1, "-1")
//            }
//        }
    }
    
    static func queryShowBlogsSurveyStranger(paramters:Parameters,
                                           valueHandler: @escaping ([BlogVisitorListModel]) -> Void,
                                           completionHandler: @escaping CompletionHandler) {
        
//        let url = SuperStringUtil.netUrl(IMController.shared.defaultBlogAddress + queryShowBlogsSurveyStrangerAPI, paramters)
//
//        Alamofire.request(url, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: httpHeaders).responseJSON { dataRequest in
//            
////            ProgressHUD.dismiss()
//            
//            if let data = dataRequest.data {
//                let strData = String.init(data: data, encoding: String.Encoding.utf8)
//                print(strData!)
//                if let res = JsonTool.fromJson(strData!, toClass: BlogListResponse<[BlogVisitorListModel]>.self) {
//                    
//                    if res.code == 20000  {
//                        valueHandler(res.data)
//                    } else {
//                        completionHandler(-1, "failure")
//                    }
//                    
//                } else {
//                    completionHandler(-1, "failure")
//                }
//            }else{
//                completionHandler(-1, "-1")
//            }
//        }
    }
    
    
    static func vipPurchaseInitialize(paramters:Parameters,
                                      valueHandler: @escaping (String) -> Void,
                                      completionHandler: @escaping CompletionHandler) {
        
//        ProgressHUD.animate()
        
        let url = SuperStringUtil.netUrl(IMController.shared.defaultBlogAddress + vipPurchaseInitializeAPI, paramters)
    
        Alamofire.request(url, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: getHttpHeader()).responseJSON { dataRequest in
            
//            ProgressHUD.dismiss()
            
            if let data = dataRequest.data {
                let strData = String.init(data: data, encoding: String.Encoding.utf8)
                print(strData!)
                if let res = JsonTool.fromJson(strData!, toClass: BlogResponse.self) {
                    
                    if res.code == 200  {
                        if res.result != nil {
                            valueHandler(res.result!)
                        }
                    } else {
                        completionHandler(res.code, res.msg)
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
        
        let url = SuperStringUtil.netUrl(IMController.shared.defaultBlogAddress + vipPurchaseSucceedsAPI, paramters)
        
        Alamofire.request(url, method: .post, parameters: paramters, encoding: JSONEncoding.default, headers: getHttpHeader()).responseJSON { dataRequest in
            if let data = dataRequest.data {
                let strData = String.init(data: data, encoding: String.Encoding.utf8)
                print(strData!)
                
                ProgressHUD.dismiss()
                if let data = dataRequest.data {
                    let strData = String.init(data: data, encoding: String.Encoding.utf8)
                    if let res = JsonTool.fromJson(strData!, toClass: BlogResponseNOData.self) {
                        
                        if res.code == 200  {
                           valueHandler("scuccess")
                        } else {
                            completionHandler(res.code, res.msg)
                        }
                        
                    } else {
                        completionHandler(-1, "-1".localized())
                    }
                }
             
            }
        }
    }
    
    
    static func addUserLanguage(uid: String) {
        
        let param = ["userLanguage":String.getCurrentLanguageFirst(), "userId": uid, "userToken":UserDefaults.standard.string(forKey: bussinessTokenKey)!]
        let url = SuperStringUtil.netUrl(IMController.shared.defaultBlogAddress + addUserLanguageAPI,param)
        
        print(["language":String.getCurrentLanguageFirst(), "userId": uid, "imToken":UserDefaults.standard.string(forKey: bussinessTokenKey)!])
            Alamofire.request(url, method: .post,parameters: param, encoding: JSONEncoding.default, headers: getHttpHeader() ).responseJSON { dataRequest in
                
                if let data = dataRequest.data {
                    let strData = String.init(data: data, encoding: String.Encoding.utf8)
                    if let res = JsonTool.fromJson(strData!, toClass: BlogResponseNOData.self) {
                        
                        if res.code == 200  {
                            let defaults = UserDefaults.standard
                            defaults.set(String.getCurrentLanguageFirst(), forKey: "blogLanguage\(uid)")
                        }
//                        UserDefaults.standard.set("0", forKey: "blogVersion\(Open_im_sdkGetLoginUserID())")
                    } else {
                       
                    }
                }
            }

        
    }
    
    static func checkAppVersion(uid:String,valueHandler: @escaping ([String:Any]) -> Void){
        let paramters = ["deviceType":"ios", "userID": uid, "ip":IMController.shared.publicIP,"systemVersion":UIDevice.current.systemVersion]
        let url = SuperStringUtil.netUrl(IMController.shared.appAddress + checkAppVersionAPI, paramters)
        Alamofire.request(url, method: .post,parameters: paramters, encoding: JSONEncoding.default, headers: getHttpHeader()).responseData { dataRequest in
            if let data = dataRequest.data {
                guard let result = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String: Any] else {
                    return
                }
                let data = result["data"] as? [String: Any]
                let errCode = result["errCode"] as! Int
                if errCode == 0  {
                    valueHandler(data!)
                }
            }
        }
    }
    
    static func updateLanguage(uid: String) {
        let param = ["userLanguage":String.getCurrentLanguageFirst(), "userId": uid, "userToken":UserDefaults.standard.string(forKey: bussinessTokenKey)!]
        let url = SuperStringUtil.netUrl(IMController.shared.defaultBlogAddress + updateUserLanguageAPI, param)
        
        Alamofire.request(url, method: .post, parameters: param,encoding: JSONEncoding.default, headers: getHttpHeader()).responseJSON { dataRequest in
            if let data = dataRequest.data {
                let strData = String.init(data: data, encoding: String.Encoding.utf8)
                if let res = JsonTool.fromJson(strData!, toClass: BlogResponseNOData.self) {
                    
                    if res.code == 200  {
                        let defaults = UserDefaults.standard
                        defaults.set(String.getCurrentLanguageFirst(), forKey: "blogLanguage\(uid)")
                    }
                    
//                    UserDefaults.standard.set("0", forKey: "blogVersion\(Open_im_sdkGetLoginUserID())")
                } else {
                   
                }
            }
        }
    
        
    }
    static func uploadImageFromPath(apiUrl:String = IMController.shared.defaultBlogAddress + upLoadBlogIconAPI,fileURL: URL,
                                    valueHandler: @escaping (upLoadImageModel) -> Void,
                                    completionHandler: @escaping CompletionHandler) {
        // 发送 Multipart 请求
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            // 添加文件数据
            multipartFormData.append(fileURL, withName: "file")
        }, to: apiUrl, method: .post,headers: getHttpHeader()) { (result) in
            switch result {
            case .success(let upload, _, _):
                // 请求成功
                upload.responseJSON { response in
                    // 处理服务器返回的数据
                    if let data = response.data {
                        let strData = String.init(data: data, encoding: String.Encoding.utf8)
                        print(strData!)
                        if let res = JsonTool.fromJson(strData!, toClass: BlogListResponse<upLoadImageModel>.self) {
                            if res.code == 200  {
                                valueHandler(res.result)
                            }else{
                                completionHandler(-1, "failure")
                            }
        
                        } else {
                            completionHandler(-1, "failure")
                        }
                    }else{
                        completionHandler(-1, "failure")
                    }
                }
            case .failure(_):
                // 请求失败
                completionHandler(-1, "failure")
            }
        }
    }
    static func uploadH5ImageFromPath(apiUrl:String,fileURL: URL,
                                      valueHandler: @escaping ([String:Any]) -> Void,
                                    completionHandler: @escaping CompletionHandler) {
        // 发送 Multipart 请求
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            // 添加文件数据
            multipartFormData.append(fileURL, withName: "file")
        }, to: apiUrl, method: .post,headers: getHttpHeader()) { (result) in
            switch result {
            case .success(let upload, _, _):
                // 请求成功
                upload.responseJSON { response in
                    // 处理服务器返回的数据
                    if let data = response.data {
                        
                        guard let result = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String: Any] else {
                            completionHandler(-1, "failure")
                            return
                        }
                        valueHandler(result)
                    }else{
                        completionHandler(-1, "failure")
                    }
                }
            case .failure(_):
                // 请求失败
                completionHandler(-1, "failure")
            }
        }
    }
    static func checkH5(paramters:Parameters,valueHandler: @escaping (h5Model) -> Void, completionHandler: @escaping CompletionHandler) {
        ProgressHUD.animate()
        
        Alamofire.request(IMController.shared.defaultBlogAddress + checkH5API, method: .post, parameters: paramters, encoding: JSONEncoding.default, headers: getHttpHeader()).responseJSON { dataRequest in
            ProgressHUD.dismiss()
            
            if let data = dataRequest.data {
                let strData = String.init(data: data, encoding: String.Encoding.utf8)
                print(strData!)
                if let res = JsonTool.fromJson(strData!, toClass: BlogListResponse<h5Model>.self) {
                    if res.code == 200{
                        valueHandler(res.result)
                    }else{
                        completionHandler(res.code, res.msg)
                    }
                } else {
                    completionHandler(-1, "failure")
                }
            }else {
                completionHandler(-1, "-1")
            }
        
        }
    }
    static func checkPublicCustomerMessageApi(paramters:Parameters,valueHandler: @escaping (checkPublicCustomerUrlInfo) -> Void, completionHandler: @escaping CompletionHandler) {
        ProgressHUD.animate()
        Alamofire.request(IMController.shared.defaultBlogAddress + getPublicCustomerMessageNextAPI, method: .post, parameters: paramters, encoding: JSONEncoding.default, headers: getHttpHeader()).responseJSON { dataRequest in
            
            if let data = dataRequest.data {
                let strData = String.init(data: data, encoding: String.Encoding.utf8)
                print(strData!)
                if let res = JsonTool.fromJson(strData!, toClass: BlogListResponse<checkPublicCustomerUrlInfo>.self) {
                    if res.code == 200{
                        valueHandler(res.result)
                    }else{
                        completionHandler(res.code, res.msg)
                    }
                } else {
                    completionHandler(-1, "failure")
                }
            }else {
                completionHandler(-1, "-1")
            }
        
        }
    }
    static func updatePublicCustomerMessageAction(url:String,token:String,appId:String,paramters:Parameters,valueHandler: @escaping (Parameters) -> Void, completionHandler: @escaping CompletionHandler) {
        ProgressHUD.animate()
        let header : HTTPHeaders = [
            "token":token,
            "appid":appId,
            "X-Forwarded-Add":IMController.shared.publicAddress,
            "X-Forwarded-IP":IMController.shared.publicIP,
            "Authorization":"eyJ1c2VySW5mbyI6InVzZXJCbG9nWWFuWmhlbmdUb2tlbiJ9",
            "Content-Type":"application/json",
            "operationID":String(Int(Date().timeIntervalSince1970)),
        ]
        Alamofire.request(url, method: .post, parameters: paramters, encoding: JSONEncoding.default, headers: header).responseJSON { dataRequest in
            ProgressHUD.dismiss()
            if let data = dataRequest.data {
                let strData = String.init(data: data, encoding: String.Encoding.utf8)
                print(strData!)
                if let data = dataRequest.data {
                    guard let result = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String: Any] else {
                        completionHandler(-1, "failure")
                        return
                    }
                    valueHandler(result)
                }else{
                    completionHandler(-1, "failure")
                }
            }else {
                completionHandler(-1, "-1")
            }
        
        }
    }
    
}

// MARK: - 张亚飞打的标记   IM新增API
extension YFMineNetViewModel {
    
     static func pictureFind(valueHandler: @escaping ([String]) -> Void,
                             completionHandler: @escaping CompletionHandler) {
        let url = IMController.shared.appAddress + pictureFindAPI
         ProgressHUD.animate()
         Alamofire.request(url, method: .post, parameters: [:],encoding: JSONEncoding.default, headers: getHttpHeader()).responseJSON { dataRequest in
             ProgressHUD.dismiss()
             if let data  = dataRequest.data {
                 let strData = String.init(data: data, encoding: String.Encoding.utf8)
                 print(strData!)
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
                url = IMController.shared.defaultBlogAddress + reportUserAddAPI
            case.chatHistory:
                url = IMController.shared.defaultBlogAddress + reportChatHistoryAddAPI
            case .blog:
                url = IMController.shared.defaultBlogAddress + reportBlogAddAPI
            case .feedback:
                url = IMController.shared.defaultBlogAddress + feedBackAddAPI
        case .moments:
            url = IMController.shared.defaultBlogAddress + reportComentsAddAPI
        }
        
        
        Alamofire.request(url, method: .post, parameters: paramters, encoding: JSONEncoding.default, headers: getHttpHeader()).responseJSON { dataRequest in
            
            if let data  = dataRequest.data {
                let strData = String.init(data: data, encoding: String.Encoding.utf8)
                if let res = JsonTool.fromJson(strData!, toClass: BlogResponseNOData.self) {
                    
                    if res.code == 200  {
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
    var result: String? = nil
    var code: Int = 200
    var msg: String? = nil
    var time: Int? = nil
    var date: String? = nil
}
class BlogResponseNOData: Decodable {
    var code: Int = 200
    var msg: String? = nil
    var time: Int? = nil
    var date: String? = nil
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
    var result: T
    var code: Int = 200
    var msg: String? = nil
    var time: Int? = nil
    var date: String? = nil
}

struct myBlogListValue: Codable {
    var data : [myBlogShowBlogPOModel]?
    var time:Int? = nil
    var date: String? = nil
    var total: String? = nil
}
struct myBlogShowBlogPOModel: Codable {
    var id:Int?
    var uid:String?
    var hash:String?
    var auth:String?
    var type:Int?
    var top_time:Int?
    var show_time:Int?
    var createtime:Int?
    var updatetime:Int?
    var base:BaseBlogModel?
}
struct BaseBlogModel: Codable {
    var hash:String?
    var info:blogDetailItem?
    var extend:extendModel?
    var shortcut:shortcut?
}
struct extendModel: Codable {
    var app:permissionModel?
    var js:jsModel?
    var sum:sumModel?
    var ex:exModel?
}
struct permissionModel: Codable {
    var permission:[String]?
}
struct jsModel: Codable {
    var after:[String]?
    var before:[String]?
}
struct sumModel: Codable {
    var flag:String?
}
struct exModel: Codable {
    var autoflag:String?
}
struct shortcut: Codable {
    var home:homeModel?
    var sub:[homeModel]?
}
struct homeModel: Codable {
    var name:String?
    var logo:String?
    var url:String?
}
struct blogDetailItem: Codable {
    let pwd: String?
    let url: String?
    let logo: String?
    let mark: String?
    let name: String?
    let auto: Int? //0是需要授权，1是不需要授权
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
    
    let logo: String?
    let name: String?
    let url: String?
    let mark: String?
    let pwd: String?
    
    init(logo: String?, name: String?, url: String?, mark: String?, pwd: String?) {
        self.logo = logo
        self.name = name
        self.url = url
        self.mark = mark
        self.pwd = pwd
    }
    
}

class MineBlogRequest: Encodable {
    
    let time: Int?
    let hash: String?
    
    init(time: Int?, hash: String?) {
        self.time = time
        self.hash = hash
    }
    
}

class othersBlogRequest: Encodable {
    
    let uid: String?
    let hash: String?
    let pwd:String?
    
    init(uid: String?, hash: String?,pwd:String?) {
        self.uid = uid
        self.hash = hash
        self.pwd = pwd
    }
    
}
struct upLoadImageModel: Codable {
    let url: String?
}
struct h5Model: Codable {
    let token:String?
    let data:h5Info?
}
struct h5Info: Codable {
    let avatar:String?
    let nickname:String?
    let hash:String?
    let info:blogDetailItem?
    let extend:extendModel?
    let shortcut:shortcut?
    let type:Int?
}
struct checkPublicCustomerUrlInfo:Codable {
    let token:String?
    let url:String?
    let hash:String?
    let action:String?
    let queryJson:String?
}

