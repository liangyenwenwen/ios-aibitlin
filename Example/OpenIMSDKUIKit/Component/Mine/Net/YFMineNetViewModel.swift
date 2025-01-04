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
    public static let API_BLOG_URL = "https://imblogs.aibitlin.com"
    
    private static let checkAppVersionAPI = "/version/query"
    
    private static let updateUserLanguageAPI = "/audit/userLanguageToken/adduserLanguageToken"
    private static let addUserLanguageAPI = "/audit/userLanguageToken/adduserLanguageToken"
        
    
    // MARK: -   IM AIP
    private static let pictureFindAPI = "/picture/find"
    
    
    // MARK: -   举报 AIP
    private static let reportUserAddAPI = "/report/reportUser/reportUserAdd"
    private static let reportChatHistoryAddAPI = "/report/reportChatHistory/reportChatHistoryAdd"
    private static let feedBackAddAPI = "/report/problemFeedback/problemFeedbackAdd"
    private static let reportComentsAddAPI = "/report/reportCircleOfFriendsAdd"
   func getHttpHeader() -> HTTPHeaders{
        let httpHeaders : HTTPHeaders = [
            "token":IMController.shared.chatToken,
            "X-Forwarded-For":IMController.shared.publicIP,
            "Authorization":"eyJ1c2VySW5mbyI6InVzZXJCbG9nWWFuWmhlbmdUb2tlbiJ9",
            "Content-Type":"application/json",
            "operationID":String(Int(Date().timeIntervalSince1970)),
        ]
       return httpHeaders
    }
        
    static func addUserLanguage(uid: String) {
        
        let param = ["userLanguage":String.getCurrentLanguageFirst(), "userId": uid, "userToken":IMController.shared.chatToken]
        let url = SuperStringUtil.netUrl(API_BLOG_URL + addUserLanguageAPI,param)
        
            Alamofire.request(url, method: .post,parameters: param, encoding: JSONEncoding.default, headers: getHttpHeader() ).responseJSON { dataRequest in
                
                if let data = dataRequest.data {
                    let strData = String.init(data: data, encoding: String.Encoding.utf8)
                    if let res = JsonTool.fromJson(strData!, toClass:  YFMineResponse.self) {
                        
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
    
    static func checkAppVersion(uid:String,valueHandler: @escaping ([String:Any]) -> Void){
        let paramters = ["deviceType":"ios", "userID": uid, "ip":IMController.shared.publicIP,"systemVersion":UIDevice.current.systemVersion]
        let url = SuperStringUtil.netUrl(API_BASE_URL + checkAppVersionAPI, paramters)
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
        let param = ["userLanguage":String.getCurrentLanguageFirst(), "userId": uid, "userToken":IMController.shared.chatToken]
        let url = SuperStringUtil.netUrl(API_BLOG_URL + updateUserLanguageAPI, param)
        
        Alamofire.request(url, method: .post, parameters: param,encoding: JSONEncoding.default, headers: getHttpHeader()).responseJSON { dataRequest in
            if let data = dataRequest.data {
                let strData = String.init(data: data, encoding: String.Encoding.utf8)
                if let res = JsonTool.fromJson(strData!, toClass:  YFMineResponse.self) {
                    
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

// MARK: -     IM新增API
extension YFMineNetViewModel {
    
     static func pictureFind(valueHandler: @escaping ([String]) -> Void,
                             completionHandler: @escaping CompletionHandler) {
        let url = API_BASE_URL + pictureFindAPI
         ProgressHUD.animate()
         Alamofire.request(url, method: .post, parameters: [:],encoding: JSONEncoding.default, headers: getHttpHeader()).responseJSON { dataRequest in
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

// MARK: -     举报
enum ReportType {
    case  user
    case  chatHistory
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
            case .feedback:
                url = API_BLOG_URL + feedBackAddAPI
        case .moments:
            url = API_BLOG_URL + reportComentsAddAPI
        }
        
        
        Alamofire.request(url, method: .post, parameters: paramters, encoding: JSONEncoding.default, headers: getHttpHeader()).responseJSON { dataRequest in
            
            if let data  = dataRequest.data {
                let strData = String.init(data: data, encoding: String.Encoding.utf8)
                if let res = JsonTool.fromJson(strData!, toClass:  YFMineResponse.self) {
                    
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




// MARK: -     Response
class  YFMineResponse: Decodable {
    var data: String? = nil
    var flag: Bool = false
    var code: Int = 20000
    var message: String? = nil
    var count: Int? = 0
}

struct myBlogShowBlogPOModel: Codable {
    var myBlogShowBlogPO : blogDetailItem
}


struct blogDetailItem: Codable {
    let id: Int?
    let userBlogSign: Int?
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
        switch userBlogSign {
        case 1:
            return .wait
        case 2:
            return .normal
        case 3:
            return .refuse
        case 4:
            return .limit
            
        default:
            return.normal
        }
    }
}
