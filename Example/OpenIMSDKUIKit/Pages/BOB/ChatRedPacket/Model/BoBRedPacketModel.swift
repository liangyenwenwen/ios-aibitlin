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
    
    private static let SendRedPacketsSL = "/wallet/redPacket/sendRedPacketsSL" //私聊发红包
    private static let SendRedPacketsPSQ = "/wallet/redPacket/sendRedPacketsPSQ" //群拼手气红包
    private static let SendRedPacketsPT = "/wallet/redPacket/sendRedPacketsPT" //群普通红包
    private static let SendRedPacketsZS = "/wallet/redPacket/sendRedPacketsZS" //群专属红包

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
   
    static func TransferMoneyInnerSHomeRequest(
                                  valueHandler: @escaping (BoBTransferAccountsHomeData) -> Void,
                                  completionHandler: @escaping CompletionHandler) {
        if !NetworkStatus.isReacheable {
            return
        }
        ProgressHUD.animate()
//        let param = ["userId": userId ?? ""]
//        let url = SuperStringUtil.netUrl(API_BOB_URL + TransferMoneyInnerSHome, param)
        
        Alamofire.request(API_BOB_URL + TransferMoneyInnerSHome, method: .post, parameters: nil,encoding: JSONEncoding.default, headers: getHttpHeader()).responseJSON { dataRequest in
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
    //发送红包
    static func SendRedPacketRequest(type: Int?,
                                     param:[String: Any],
                                     valueHandler: @escaping (BoBSendRedPacketData) -> Void,
                                  completionHandler: @escaping CompletionHandler) {
        //type：0私聊红包，1群拼手气红包，2群普通红包，3群专属红包
        if !NetworkStatus.isReacheable {
            return
        }
        ProgressHUD.animate()
        var url = ""
        if type == 0{
            //私聊普通红包
            url = API_BOB_URL + SendRedPacketsSL
        }else if type == 1{
            //群拼手气红包
            url = API_BOB_URL + SendRedPacketsPSQ
        }else if type == 2{
            //群普通红包
            url = API_BOB_URL + SendRedPacketsPT
        }else if type == 3{
            //群专属红包
            url = API_BOB_URL + SendRedPacketsZS
        }
        
        Alamofire.request(url, method: .post, parameters: param,encoding: JSONEncoding.default, headers: getHttpHeader()).responseJSON { dataRequest in
            ProgressHUD.dismiss()
            if let data = dataRequest.data {
                let strData = String.init(data: data, encoding: String.Encoding.utf8)
                print(strData!)
                if let res = JsonTool.fromJson(strData!, toClass: BoBSendRedPacketResponse.self) {

                    if res.code == 20000  {
                        res.data.redPacketType = type
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
    var expenditureHomePagePOS: [expenditureHomePagePOS]
    var secure:Bool?
    var certificationLevel:Int?
}
class expenditureHomePagePOS: Decodable {
    var icon: String?
    var currency:String?//币种
    var quota:Double? //限额
    var exchangeRate:Double? //汇率
    var t0:Double?
    var t1:Double?
}
class BoBSendRedPacketResponse: Decodable {
    var data: BoBSendRedPacketData
    var flag: Bool = false
    var code: Int = 20000
    var message: String? = nil
    var count: Int? = 0
}
class BoBSendRedPacketData: Decodable {
    var redPacketType:Int?//0是私聊红包，1是群拼手气红包，2是群普通红包，3是群专属红包

    var amount:Double? //数量
    var funderWallet:String? //发出钱包(C0,C1)
    var officialExchangeRate:Double? //汇率
    var instructions:String?//说明
    var redEnvelopeCover:Int? //红包封面
    var funderId:String? //发送者id
    var receiverId:String? //接收者id
    var receiverName:String? //昵称--接收者
    var sing:Int? //状态 1:已过期 2:以领取 3:未领取
    var img:String? //头像--发送者者
    var nickName:String? //昵称--发送者者
    var code:String? //code
    
    
    var number:Int? //红包个数
    var residualNumber:Int? //剩余个数
    var individualQuantity:Double? //单个数量
    var currency:String? //币种
    var packetCode:String? //红包账单号
    var funderAvatar:String? //发送者头像
    var funderNickName:String? //发送者昵称
    var userSendOrdinaryRedPacketsPOS:[userSendOrdinaryRedPacketsPOS]? //已领取用户
}
class userSendOrdinaryRedPacketsPOS: Decodable {
    var userId:String? //领取者id
    var avatar:String? //领取者头像
    var nickName:String? //领取者昵称
    var amount:String? //领取数量
    var date:String? //领取时间
}

//红包消息
class RedPacketMessageStatus: Decodable {
   
    var customType:Int?
    var data: RedPacketMessageStatusInfo?
    var localEx: String?
}
struct RedPacketMessageStatusInfo: Decodable {
    let sendUserId: String?
    let sendUserFaceURL: String?
    let sendUserName: String?
    let receiverId: String?
    let receiverName:String?
    let code:String?
    let redPacketType:Int? //0是私聊红包，1是群拼手气红包，2是群普通红包，3是群专属红包
    let instructions:String?
    
    var localEx:Int?
}

