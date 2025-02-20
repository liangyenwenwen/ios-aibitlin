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
    
    private static let checkAppVersionAPI = "/version/query"
    
    // MARK: -   IM AIP
    private static let pictureFindAPI = "/picture/find"
    
    
    // MARK: -   举报 AIP
    private static let reportUserAddAPI = "/report/reportUser/reportUserAdd"
    private static let reportChatHistoryAddAPI = "/wallet/wallet/complaintAdd"
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
                         SuperToast.show(title: String(res.errCode) + "：" + String(res.errCode).localized())
                     }
                     
                 } else {
                     if let res1 = JsonTool.fromJson(strData!, toClass: YFIMNODataResponse.self) {
                         SuperToast.show(title: String(res1.errCode) + "：" + String(res1.errCode).localized())
                     }else{
                         SuperToast.show(title: strData)
                     }
                 }
             }else{
//                 SuperToast.show(title: "-1".localized())
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
                url = API_BOB_URL + reportUserAddAPI
            case.chatHistory:
                url = API_BOB_URL + reportChatHistoryAddAPI
            case .feedback:
                url = API_BOB_URL + feedBackAddAPI
        case .moments:
            url = API_BOB_URL + reportComentsAddAPI
        }
        
        
        Alamofire.request(url, method: .post, parameters: paramters, encoding: JSONEncoding.default, headers: getHttpHeader()).responseJSON { dataRequest in
            
            if let data  = dataRequest.data {
                let strData = String.init(data: data, encoding: String.Encoding.utf8)
                if let res = JsonTool.fromJson(strData!, toClass:  YFMineResponse.self) {
                    
                    if res.code == 620000 || res.code == 20000  {
                        SuperToast.show(title: "提交成功".localized())
                        valueHandler("提交成功")
                    }else{
                        SuperToast.show(title: String(res.code) + "：" + String(res.code).localized())
                    }
                    
                } else {
                    if let res1 = JsonTool.fromJson(strData!, toClass: YFNODataResponse.self) {
                        SuperToast.show(title: String(res1.code) + "：" + String(res1.code).localized())
                    }else{
                        SuperToast.show(title: strData)
                    }
                }
   
            }else{
//                SuperToast.show(title: "-1".localized())
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
    var code: Int = 620000
    var message: String? = nil
    var count: Int? = 0
}
class  YFIMNODataResponse: Decodable {
    var flag: Bool = false
    var errCode: Int = 0
    var message: String? = nil
    var count: Int? = 0
}
class  YFNODataResponse: Decodable {
    var flag: Bool = false
    var code: Int = 620000
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
