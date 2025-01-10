//
//  BoBRealNameModel.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/11/20.
//  Copyright © 2024 rentsoft. All rights reserved.
//
import Alamofire
import Foundation
import OUICore
import ProgressHUD
import RxSwift
import Network
open class BoBRealNameModel {
    
    private static let AddUserLanguageToken = "/wallet/userLanguageToken/adduserLanguageToken" //更改语言
    private static let InitWallet = "/wallet/wallet/initializeWallet"
    private static let QueryRealNameAuthentication = "/wallet/realNameAuthentication/queryRealNameAuthentication" //查看实名认证
    private static let ReceiveIdentityCardHeadshots = "/wallet/realNameAuthentication/receiveIdentityCardHeadshots" //接收身份证的头像面
    private static let PrimaryRealNameAuthentication = "/wallet/realNameAuthentication/primaryRealNameAuthentication"//初级实名认证
    private static let AdvancedRealNameAuthentication = "/wallet/realNameAuthentication/advancedRealNameAuthentication"//高级实名认证
    private static let GetOpenScreenPage = "/wallet/wallet/openScreenPage"//开屏广告

//    private static var httpHeaders : HTTPHeaders = [
//        "token":UserDefaults.standard.string(forKey: "bussinessTokenKey")!,
//        "X-Forwarded-For":IMController.shared.publicIP,
//        "Authorization":"eyJ1c2VySW5mbyI6InVzZXJCbG9nWWFuWmhlbmdUb2tlbiJ9",
//        "Content-Type":"application/json",
//        "operationID":String(Int(Date().timeIntervalSince1970)),
//    ]
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
    //更改语言
    static func AddUserLanguageRequest(uid: String) {
        let param = ["userLanguage":String.getCurrentLanguageFirst(), "userToken":IMController.shared.chatToken]
        let url = SuperStringUtil.netUrl(API_BOB_URL + AddUserLanguageToken, param)
        
        Alamofire.request(url, method: .post, parameters: param,encoding: JSONEncoding.default, headers: getHttpHeader()).responseJSON { dataRequest in
            if let data = dataRequest.data {
                let strData = String.init(data: data, encoding: String.Encoding.utf8)
                if let res = JsonTool.fromJson(strData!, toClass: BoBResponse.self) {
                    
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
    //初始化钱包
    static func InitWalletRequest(
                                  nickName:String?,
                          completionHandler: @escaping CompletionHandler) {
        
        
        if !NetworkStatus.isReacheable {
//            SuperToast.show(title: "")
            return
        }
        let param = ["nickName":nickName ?? ""]
//        let url = SuperStringUtil.netUrl(API_BOB_URL + InitWallet, param)
        
        Alamofire.request(API_BOB_URL + InitWallet, method: .post, parameters: param,encoding: JSONEncoding.default, headers: getHttpHeader()).responseString { (response: DataResponse<String>) in
            switch response.result {
            case .success(let result):
                if let res = JsonTool.fromJson(result, toClass: BoBResponse.self) {

                    if res.code == 20000  {
                        print("请求成功")
                    } else {
                        print("请求失败")
                    }
                    
                    completionHandler(res.code, res.message)
                    
                } else {
                    if let res = JsonTool.fromJson(result, toClass: RealNameNODataResponse.self){
                        completionHandler(res.code, res.message)
                    }else{
                        completionHandler(-1, "网络错误")
                    }
                }
            case .failure(let err):
                completionHandler(-1, err.localizedDescription)
               
            }
        }
        
    }
    //查看实名认证
    static func QueryRealNameInfo(userId: String?,
                                  valueHandler: @escaping (RealNameInfoDataModel) -> Void,
                                  completionHandler: @escaping CompletionHandler) {
        
        
        if !NetworkStatus.isReacheable {
//            SuperToast.show(title: "")
            return
        }
        ProgressHUD.animate()
//        let param = ["userId": userId ?? ""]
//        let url = SuperStringUtil.netUrl(API_BOB_URL + QueryRealNameAuthentication, param)
        
        Alamofire.request(API_BOB_URL + QueryRealNameAuthentication, method: .post, parameters: nil,encoding: JSONEncoding.default, headers: getHttpHeader()).responseJSON { dataRequest in
            ProgressHUD.dismiss()
            
            if let data = dataRequest.data {
                let strData = String.init(data: data, encoding: String.Encoding.utf8)
                print(strData!)
                
                if let res = JsonTool.fromJson(strData!, toClass: RealNameInfoResponse<RealNameInfoDataModel>.self) {

                    if res.code == 20000  {
                        valueHandler(res.data)
                    } else {
                        completionHandler(res.code, res.message)
                    }
                } else {
                    if let res = JsonTool.fromJson(strData!, toClass: RealNameNODataResponse.self){
                        completionHandler(res.code, res.message)
                    }else{
                        completionHandler(-1, "网络错误")
                    }
                }
            } else {
                completionHandler(-1, "网络错误")
            }
        }
        
    }
    //识别身份证图片上的信息
    static func getIdCardInfo(image:String?,
                              valueHandler: @escaping (RealNameIdCardInfo) -> Void,
                                  completionHandler: @escaping CompletionHandler) {
        
        
        if !NetworkStatus.isReacheable {
//            SuperToast.show(title: "")
            return
        }
        ProgressHUD.animate()
        let param = ["image":image ?? ""]
//        let url = SuperStringUtil.netUrl(API_BOB_URL + ReceiveIdentityCardHeadshots, param)
        let url = API_BOB_URL + ReceiveIdentityCardHeadshots
        Alamofire.request(url, method: .post, parameters: param,encoding: JSONEncoding.default, headers: getHttpHeader()).responseJSON { dataRequest in
            ProgressHUD.dismiss()
            if let data = dataRequest.data {
                let strData = String.init(data: data, encoding: String.Encoding.utf8)
                print(strData!)
                if let res = JsonTool.fromJson(strData!, toClass: RealNameInfoResponse<RealNameIdCardInfo>.self) {
                    if res.code == 20000  {
                        valueHandler(res.data)
                    } else {
                        completionHandler(res.code, res.message)
                    }
                } else {
                    if let res = JsonTool.fromJson(strData!, toClass: RealNameNODataResponse.self){
                        completionHandler(res.code, res.message)
                    }else{
                        completionHandler(-1, "网络错误")
                    }
                }
            } else {
                completionHandler(-1, "网络错误")
            }
        }
        
    }
    //初级实名认证
    static func primaryRealNameAuthenticationRequest(name:String,
                                                     cardId:String,
                                                     idCardZM:String,
                                                     idCardBM:String,
                                  completionHandler: @escaping CompletionHandler) {
        
        
        if !NetworkStatus.isReacheable {
//            SuperToast.show(title: "")
            return
        }
        ProgressHUD.animate()
        let param = ["name":name,"cardId":cardId,"idCardZM":idCardZM,"idCardBM":idCardBM]
        let url = API_BOB_URL + PrimaryRealNameAuthentication
        Alamofire.request(url, method: .post, parameters: param,encoding: JSONEncoding.default, headers: getHttpHeader()).responseJSON { dataRequest in
            ProgressHUD.dismiss()
            if let data = dataRequest.data {
                let strData = String.init(data: data, encoding: String.Encoding.utf8)
                print(strData!)
                if let res = JsonTool.fromJson(strData!, toClass: BoBResponse.self) {
                    completionHandler(res.code, res.message)
                } else {
                    if let res = JsonTool.fromJson(strData!, toClass: RealNameNODataResponse.self){
                        completionHandler(res.code, res.message)
                    }else{
                        completionHandler(-1, "网络错误")
                    }
                }
            } else {
                completionHandler(-1, "网络错误")
            }
        }
        
    }
    //高级实名认证
    static func AdvancedRealNameAuthenticationRequest(url:String,
                                                      name:String?,
                                                      cardId:String?,
                                                      idCardZM:String?,
                                                      idCardBM:String?,
                                                      completionHandler: @escaping CompletionHandler) {
        ProgressHUD.animate()
        let param = [url:url,"name":name,"cardId":cardId,"idCardZM":idCardZM,"idCardBM":idCardBM]
        let url = API_BOB_URL + AdvancedRealNameAuthentication
        Alamofire.request(url, method: .post, parameters: param,encoding: JSONEncoding.default, headers: getHttpHeader()).responseJSON { dataRequest in
            ProgressHUD.dismiss()
            if let data = dataRequest.data {
                let strData = String.init(data: data, encoding: String.Encoding.utf8)
                print(strData!)
                if let res = JsonTool.fromJson(strData!, toClass: BoBResponse.self) {
                    completionHandler(res.code, res.message)
                } else {
                    if let res = JsonTool.fromJson(strData!, toClass: RealNameNODataResponse.self){
                        completionHandler(res.code, res.message)
                    }else{
                        completionHandler(-1, "网络错误")
                    }
                }
            } else {
                completionHandler(-1, "网络错误")
            }
        }
        
    }
    
    static func GetOpenScreenPageRequest(valueHandler: @escaping (OpenScreenAdInfo) -> Void,
                                         completionHandler: @escaping CompletionHandler) {
        
        
        if !NetworkStatus.isReacheable {
//            SuperToast.show(title: "")
            return
        }
        let url = API_BOB_URL + GetOpenScreenPage
        Alamofire.request(url, method: .post, parameters: nil,encoding: JSONEncoding.default, headers: getHttpHeader()).responseJSON { dataRequest in
            if let data = dataRequest.data {
                let strData = String.init(data: data, encoding: String.Encoding.utf8)
                print(strData!)
                if let res = JsonTool.fromJson(strData!, toClass: RealNameInfoResponse<OpenScreenAdInfo>.self) {
                    if res.code == 20000  {
                        valueHandler(res.data)
//                        var data1 = res.data
//                        data1.img = "https://img2.baidu.com/it/u=3931248722,2037178766&fm=253&fmt=auto&app=138&f=JPEG?w=281&h=500"
//                        data1.showType = 2
//                        valueHandler(data1)
                    } else {
                        completionHandler(res.code, res.message)
                    }
                } else {
                    if let res = JsonTool.fromJson(strData!, toClass: RealNameNODataResponse.self){
                        completionHandler(res.code, res.message)
                    }else{
                        completionHandler(-1, "网络错误")
                    }
                }
            } else {
                completionHandler(-1, "网络错误")
            }
        }
        
    }
}
class UserIDRequest: Encodable {
    
    let userId: String?
    init(userId: String?) {
        self.userId = userId
    }
}
//
class RealNameNODataResponse: Decodable {
//    var data: T
    var flag: Bool = false
    var code: Int = 20000
    var message: String? = nil
    var count: Int? = 0
}
class BoBResponse: Decodable {
    var data: String? = nil
    var flag: Bool = false
    var code: Int = 20000
    var message: String? = nil
    var count: Int? = 0
}
//  Response
class RealNameInfoResponse<T: Decodable>: Decodable {
    var data: T
    var flag: Bool = false
    var code: Int = 20000
    var message: String? = nil
    var count: Int? = 0
}
struct RealNameInfoDataModel: Codable {
    var certificationLevel: Int //0未认证，1初级认证，2高级认证
    var certificationAudit:Int //高级认证:0申请过了等待审核 1没有申请
    var cjmmbRealNameAuthenticationPOS: [cjmmbRealNameAuthenticationPOS]
    var cjtbRealNameAuthenticationPOS: [cjtbRealNameAuthenticationPOS]
    var gjmmbRealNameAuthenticationPOS: [gjmmbRealNameAuthenticationPOS]
    var gjtbRealNameAuthenticationPOS: [gjtbRealNameAuthenticationPOS]
}
struct cjmmbRealNameAuthenticationPOS: Codable {
    var currency: String //币种
    var primaryCertificationBusiness: Int //初级认证买卖币 C限额/日
}
struct cjtbRealNameAuthenticationPOS: Codable {
    var currency: String //币种
    var primaryCertificationWithdraw: Int //初级认证提币币 C限额/日
}
struct gjmmbRealNameAuthenticationPOS: Codable {
    var currency: String //币种
    var advancedCertificationBusiness: Int //高级认证买卖币 C限额/日
}
struct gjtbRealNameAuthenticationPOS: Codable {
    var currency: String //币种
    var advancedCertificationWithdraw: Int //高级认证提币币 C限额/日
}
struct RealNameIdCardInfo: Codable {
    var nation: String //国家
    var name:String //姓名
    var cardId:String //身份证号
}
struct OpenScreenAdInfo: Codable {
    var showType: Int? //开屏页展示,1关闭 2开启
    var img:String? //开屏广告地址
}



