//
//  BoBRedPacketModel.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/12/3.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Alamofire
import Foundation
import OUICore
import ProgressHUD
import RxSwift
import Network
class BoBRedPacketModel {
    // 业务服务器地址
    public static let API_BOB_URL = "http://192.168.7.128:18729"
//    public static let API_BOB_URL = "http://143.92.40.164:18729"
    
    
    private static let TransferMoneyInnerSHome = "/wallet/transferMoneyInner/transferMoneyInnerSHome" //聊天转账首页
    private static let SendTransferMoneySInner = "/wallet/transferMoneyInner/sendTransferMoneySInner" //私聊转账
    private static let SendTransferMoneyQInner = "/wallet/transferMoneyInner/sendTransferMoneyQInner" //群聊转账


    static func getHttpHeader() -> HTTPHeaders{
        let httpHeaders : HTTPHeaders = [
            "token":UserDefaults.standard.string(forKey: "bussinessTokenKey")!,
            "X-Forwarded-For":IMController.shared.publicIP,
            "Authorization":"eyJ1c2VySW5mbyI6InVzZXJCbG9nWWFuWmhlbmdUb2tlbiJ9",
            "Content-Type":"application/json",
            "operationID":String(Int(Date().timeIntervalSince1970)),
        ]
       return httpHeaders
    }
   
    static func TransferMoneyInnerSHomeRequest(userId: String?,
                                  valueHandler: @escaping (BoBTransferAccountsHomeData) -> Void,
                                  completionHandler: @escaping CompletionHandler) {
        if !NetworkStatus.isReacheable {
            return
        }
        ProgressHUD.animate()
        let param = ["userId": userId ?? ""]
        let url = SuperStringUtil.netUrl(API_BOB_URL + TransferMoneyInnerSHome, param)
        
        Alamofire.request(url, method: .post, parameters: param,encoding: JSONEncoding.default, headers: getHttpHeader()).responseJSON { dataRequest in
            ProgressHUD.dismiss()
            
            if let data = dataRequest.data {
                let strData = String.init(data: data, encoding: String.Encoding.utf8)
                print(strData!)
                if let res = JsonTool.fromJson(strData!, toClass: BoBRedPacketResponse<BoBTransferAccountsHomeData>.self) {

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
    static func SendTransferMoneyRequest(issuingPartyUserId: String?,
                                         receiverUserId:String?,
                                         currency:String?,
                                         issuingPartyWallet:String?,
                                         transferAmount:String?,
                                         instructions:String?,
                                         passWord:String?,
                                         transferAccountsType:Int?,
                                  completionHandler: @escaping CompletionHandler) {
        
        
        if !NetworkStatus.isReacheable {
            return
        }
        ProgressHUD.animate()
        let param = ["issuingPartyUserId": issuingPartyUserId ?? "","receiverUserId": receiverUserId ?? "","currency": currency ?? "","issuingPartyWallet": issuingPartyWallet ?? "","transferAmount": transferAmount ?? "0.00","instructions": instructions ?? "","passWord": passWord ?? ""]
        var url = ""
        if transferAccountsType == 0{
            url = API_BOB_URL + SendTransferMoneySInner
        }else{
            url = API_BOB_URL + SendTransferMoneyQInner
        }
        
        Alamofire.request(url, method: .post, parameters: param,encoding: JSONEncoding.default, headers: getHttpHeader()).responseJSON { dataRequest in
            ProgressHUD.dismiss()
            
            if let data = dataRequest.data {
                let strData = String.init(data: data, encoding: String.Encoding.utf8)
                print(strData!)
                
                if let res = JsonTool.fromJson(strData!, toClass: BoBRedPacketNODataResponse.self) {
                    completionHandler(res.code, res.message)
                } else {
                    completionHandler(-1, "failure")
                }
            } else {
                completionHandler(-1, "failure")
            }
        }
        
    }
}
class BoBRedPacketResponse<T: Decodable>: Decodable {
    var data: T
    var flag: Bool = false
    var code: Int = 20000
    var message: String? = nil
    var count: Int? = 0
}
class BoBRedPacketNODataResponse: Decodable {
//    var data: T
    var flag: Bool = false
    var code: Int = 20000
    var message: String? = nil
    var count: Int? = 0
}
class BoBTransferAccountsHomeData: Decodable {
    var cipos: [cipos]
    var anQuan:Bool?
    var certificationLevel:Int?
}
class cipos: Decodable {
    var icon: String?
    var biZhong:String?
    var xianE:Double?
    var shouXuFei:Double?
    var huiLv:Double?
    var t0:Double?
    var t1:Double?
}

