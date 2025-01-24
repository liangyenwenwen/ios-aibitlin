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
    
    private static let TransferMoneyInnerSHome = "/wallet/transferMoneyInner/transferMoneyInnerSHome" //聊天转账首页
    private static let SendTransferMoneySInner = "/wallet/transferMoneyInner/sendTransferMoneySInner" //私聊转账
    
    private static let SendRedPacketsSL = "/wallet/redPacket/sendRedPacketsSL" //私聊发红包
    private static let SendRedPacketsPSQ = "/wallet/redPacket/sendRedPacketsPSQ" //群拼手气红包
    private static let SendRedPacketsPT = "/wallet/redPacket/sendRedPacketsPT" //群普通红包
    private static let ReceivePrivateChatRedPackets = "/wallet/redPacket/receivePrivateChatRedPackets"//领取私聊、群专属红包
    private static let ReceivePrivateChatRedPacketsPSQ = "/wallet/redPacket/receivePrivateChatRedPacketsPSQ"//领取群拼手气红包
    private static let ReceivePrivateChatRedPacketsPT = "/wallet/redPacket/receivePrivateChatRedPacketsPT"//领取群普通红包
    private static let ReceiveTransferAccount = "/wallet/transferMoneyInner/collectionAndTransferAccount"//领取转账
    
    private static let RedPacketsDetails = "/wallet/redPacket/redEnvelopeDetails"//红包详情
    private static let TransferAccountsDetails = "/wallet/transferMoneyInner/internalTransferdetails"//转账详情
    private static let GetRedPacketStatus = "/wallet/redPacket/redType"//判断红包状态
    
    
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
   
    static func TransferMoneyInnerSHomeRequest(
                                  valueHandler: @escaping (BoBTransferAccountsHomeData) -> Void,
                                  completionHandler: @escaping CompletionHandler) {
//        if !NetworkStatus.isReacheable {
//            return
//        }
        ProgressHUD.animate()
//        let param = ["userId": userId ?? ""]
//        let url = SuperStringUtil.netUrl(API_BOB_URL + TransferMoneyInnerSHome, param)
        
        Alamofire.request(API_BOB_URL + TransferMoneyInnerSHome, method: .post, parameters: nil,encoding: JSONEncoding.default, headers: getHttpHeader()).responseJSON { dataRequest in
            ProgressHUD.dismiss()
            
            if let data = dataRequest.data {
                let strData = String.init(data: data, encoding: String.Encoding.utf8)
                print(strData!)
                if let res = JsonTool.fromJson(strData!, toClass: BoBRedPacketResponse<BoBTransferAccountsHomeData>.self) {

                    if res.code == 620000  {
                        valueHandler(res.data)
                    } else {
                        completionHandler(res.code, res.message)
                    }
                } else {
                    if let res = JsonTool.fromJson(strData!, toClass: BoBRedPacketNODataResponse.self){
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
    static func SendTransferMoneyRequest(receiverUserId:String?,
                                         currency:String?,
                                         issuingPartyWallet:String?,
                                         transferAmount:String?,
                                         instructions:String?,
                                         passWord:String?,
                                         transferAccountsType:Int?,
                                         groupId:String?,
                                         valueHandler: @escaping (BoBSendTransferAccountsData) -> Void,
                                  completionHandler: @escaping CompletionHandler) {
        
        
//        if !NetworkStatus.isReacheable {
//            return
//        }
        ProgressHUD.animate()
        let timestamp = String(Int(Date().timeIntervalSince1970 * 1000))
        let sign = (receiverUserId! + currency! + issuingPartyWallet! + transferAmount! + instructions! + groupId! + timestamp + (IMController.shared.payPassWordSonKey + (passWord ?? "")).md5).md5
        let param = ["receiverUserId": receiverUserId ?? "","currency": currency ?? "","issuingPartyWallet": issuingPartyWallet ?? "","transferAmount": transferAmount ?? "0.00","instructions": instructions ?? "","groupId": groupId ?? "","timestamp":timestamp,"sign": sign]
        Alamofire.request(API_BOB_URL + SendTransferMoneySInner, method: .post, parameters: param,encoding: JSONEncoding.default, headers: getHttpHeader()).responseJSON { dataRequest in
            ProgressHUD.dismiss()
            
            if let data = dataRequest.data {
                let strData = String.init(data: data, encoding: String.Encoding.utf8)
                print(strData!)
                
                if let res = JsonTool.fromJson(strData!, toClass: BoBSendTransferAccountsResponse.self) {
                    if res.code == 620000  {
                        res.data.transferAccountsType = transferAccountsType
                        valueHandler(res.data)
                    } else {
                        completionHandler(res.code, res.message)
                    }
                } else {
                    if let res = JsonTool.fromJson(strData!, toClass: BoBRedPacketNODataResponse.self){
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
    //发送红包
    static func SendRedPacketRequest(type: Int?,
                                     param:[String: Any],
                                     valueHandler: @escaping (BoBSendRedPacketData) -> Void,
                                  completionHandler: @escaping CompletionHandler) {
        //type：0私聊红包，1群拼手气红包，2群普通红包，3群专属红包
//        if !NetworkStatus.isReacheable {
//            return
//        }
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
            url = API_BOB_URL + SendRedPacketsSL
        }
        
        Alamofire.request(url, method: .post, parameters: param,encoding: JSONEncoding.default, headers: getHttpHeader()).responseJSON { dataRequest in
            ProgressHUD.dismiss()
            if let data = dataRequest.data {
                let strData = String.init(data: data, encoding: String.Encoding.utf8)
                print(strData!)
                if let res = JsonTool.fromJson(strData!, toClass: BoBSendRedPacketResponse.self) {

                    if res.code == 620000  {
                        res.data.redPacketType = type
                        valueHandler(res.data)
                    } else {
                        completionHandler(res.code, res.message)
                    }
                } else {
                    if let res = JsonTool.fromJson(strData!, toClass: BoBRedPacketNODataResponse.self){
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
    //领取红包
    static func ReceiveChatRedPacketsRequest(type: Int?,
                                     param:[String: Any],
                                  completionHandler: @escaping CompletionHandler) {
        //type：0私聊红包，1群拼手气红包，2群普通红包，3群专属红包
//        if !NetworkStatus.isReacheable {
//            return
//        }
        var url = ""
        if type == 0 || type == 3{
            //私聊普通红包、群专属红包
            url = SuperStringUtil.netUrl(API_BOB_URL + ReceivePrivateChatRedPackets, param)

        }else if type == 1{
            //群拼手气红包、群普通红包
            url = SuperStringUtil.netUrl(API_BOB_URL + ReceivePrivateChatRedPacketsPSQ, param)

        }else if type == 2{
            //群普通红包
            url = SuperStringUtil.netUrl(API_BOB_URL + ReceivePrivateChatRedPacketsPT, param)
        }
                    
        
        Alamofire.request(url, method: .post, parameters: param,encoding: JSONEncoding.default, headers: getHttpHeader()).responseJSON { dataRequest in
            
            if let data = dataRequest.data {
                let strData = String.init(data: data, encoding: String.Encoding.utf8)
                print(strData!)
                if let res = JsonTool.fromJson(strData!, toClass: BoBRedPacketNODataResponse.self) {
                    completionHandler(res.code, res.message)
                } else {
                    if let res = JsonTool.fromJson(strData!, toClass: BoBRedPacketNODataResponse.self){
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
    //红包详情
    static func RedPacketsDetailsRequest(code: String?,
                                             valueHandler: @escaping (BoBRedPacketDetailData) -> Void,
                                             completionHandler: @escaping CompletionHandler) {
//        if !NetworkStatus.isReacheable {
//            return
//        }
        ProgressHUD.animate()
        let param = ["code":code ?? ""]
        let url = SuperStringUtil.netUrl(API_BOB_URL + RedPacketsDetails, param)
        Alamofire.request(url, method: .post, parameters: param,encoding: JSONEncoding.default, headers: getHttpHeader()).responseJSON { dataRequest in
            ProgressHUD.dismiss()
            
            if let data = dataRequest.data {
                let strData = String.init(data: data, encoding: String.Encoding.utf8)
                print(strData!)
                if let res = JsonTool.fromJson(strData!, toClass: BoBRedPacketDetailResponse.self) {
                    if res.code == 620000  {
                        valueHandler(res.data)
                    } else {
                        completionHandler(res.code, res.message)
                    }
                } else {
                    if let res = JsonTool.fromJson(strData!, toClass: BoBRedPacketNODataResponse.self){
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
    //转账详情
    static func TransferAccountsDetailsRequest(code: String?,
                                             valueHandler: @escaping (BoBSendTransferAccountsData) -> Void,
                                             completionHandler: @escaping CompletionHandler) {
//        if !NetworkStatus.isReacheable {
//            return
//        }
        ProgressHUD.animate()
        let param = ["code":code ?? ""]
        let url = SuperStringUtil.netUrl(API_BOB_URL + TransferAccountsDetails, param)
        Alamofire.request(url, method: .post, parameters: param,encoding: JSONEncoding.default, headers: getHttpHeader()).responseJSON { dataRequest in
            ProgressHUD.dismiss()
            
            if let data = dataRequest.data {
                let strData = String.init(data: data, encoding: String.Encoding.utf8)
                print(strData!)
                if let res = JsonTool.fromJson(strData!, toClass: BoBSendTransferAccountsResponse.self) {
                    if res.code == 620000  {
                        valueHandler(res.data)
                    } else {
                        completionHandler(res.code, res.message)
                    }
                } else {
                    if let res = JsonTool.fromJson(strData!, toClass: BoBRedPacketNODataResponse.self){
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
    //领取转账
    static func ReceiveTransferAccountRequest(code: String?,
                                             valueHandler: @escaping (BoBSendTransferAccountsData) -> Void,
                                             completionHandler: @escaping CompletionHandler) {
//        if !NetworkStatus.isReacheable {
//            return
//        }
        ProgressHUD.animate()
        let param = ["code":code ?? ""]
        let url = SuperStringUtil.netUrl(API_BOB_URL + ReceiveTransferAccount, param)
        Alamofire.request(url, method: .post, parameters: param,encoding: JSONEncoding.default, headers: getHttpHeader()).responseJSON { dataRequest in
            ProgressHUD.dismiss()
            
            if let data = dataRequest.data {
                let strData = String.init(data: data, encoding: String.Encoding.utf8)
                print(strData!)
                if let res = JsonTool.fromJson(strData!, toClass: BoBSendTransferAccountsResponse.self) {
                    if res.code == 620000  {
                        valueHandler(res.data)
                    } else {
                        completionHandler(res.code, res.message)
                    }
                } else {
                    if let res = JsonTool.fromJson(strData!, toClass: BoBRedPacketNODataResponse.self){
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
    
    static func GetRedPacketStatusRequest(code: String?,
                                          groupId:String?,
                                          valueHandler: @escaping (Int) -> Void,
                                          completionHandler: @escaping CompletionHandler) {
//        if !NetworkStatus.isReacheable {
//            return
//        }
        ProgressHUD.animate()
        let param = ["code":code ?? "","groupId":groupId ?? ""]
        let url = SuperStringUtil.netUrl(API_BOB_URL + GetRedPacketStatus, param)
        Alamofire.request(url, method: .post, parameters: param,encoding: JSONEncoding.default, headers: getHttpHeader()).responseJSON { dataRequest in
            ProgressHUD.dismiss()
            
            if let data = dataRequest.data {
                let strData = String.init(data: data, encoding: String.Encoding.utf8)
                print(strData!)
                if let res = JsonTool.fromJson(strData!, toClass: BoBRedPacketResponse<Int>.self) {
                    if res.code == 620000  {
                        valueHandler(res.data)
                    } else {
                        completionHandler(res.code, res.message)
                    }
                } else {
                    if let res = JsonTool.fromJson(strData!, toClass: BoBRedPacketNODataResponse.self){
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
class BoBRedPacketResponse<T: Decodable>: Decodable {
    var data: T
    var flag: Bool = false
    var code: Int = 620000
    var message: String? = nil
    var count: Int? = 0
}
class BoBRedPacketNODataResponse: Decodable {
//    var data: T
    var flag: Bool = false
    var code: Int = 620000
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
    var code: Int = 620000
    var message: String? = nil
    var count: Int? = 0
}
class BoBSendRedPacketData: Decodable {
    var redPacketType:Int?//0是私聊红包，1是群拼手气红包，2是群普通红包，3是群专属红包

    var amount:Double? //数量
    var funderWallet:Int? //发出钱包(0,1)
    var officialExchangeRate:Double? //汇率
    var instructions:String?//说明
    var redEnvelopeCover:Int? //红包封面
    var funderId:String? //发送者id
    var funderImg:String? //发送者头像
    var funderNickName:String? //发送者昵称
    var receiverId:String? //接收者id
    var receiverNickName:String? //昵称--接收者
    var receiverImg:String? //头像--接收者
    var currency:String?//货币
    var sing:Int? //状态 1:已过期 2:以领取 3:未领取
    var code:String? //红包账单号
    
    
    var number:Int? //红包个数
    var residualNumber:Int? //剩余个数
    var individualQuantity:Double? //单个数量
}
class userSendOrdinaryRedPacketsPOS: Decodable {
    var userId:String? //领取者id
    var avatar:String? //领取者头像
    var nickName:String? //领取者昵称
    var amount:String? //领取数量
    var date:String? //领取时间
}

class BoBSendTransferAccountsResponse: Decodable {
    var data: BoBSendTransferAccountsData
    var flag: Bool = false
    var code: Int = 620000
    var message: String? = nil
    var count: Int? = 0
}
class BoBSendTransferAccountsData: Decodable {
    var issuingPartyUserId:String?//发出方id
    var issuingPartyUserNickName:String?//发出方昵称
    var receiverUserId:String?//收款方id
    var nickName:String? //收款方昵称
    var currency:String?//货币
    var issuingPartyWallet:Int? //发出钱包(0,1)
    var transferAmount:Double? //数量
    var instructions:String?//说明
    var transferCode:String? //转账单号
    var fcTime:String? //发出时间
    var lqTime:String? //领取时间
    var thTime:String? //退回时间
    var sendTime:String{
        getTime(time: fcTime ?? "")
    }
    var receiveTime:String{
        getTime(time: lqTime ?? "")
    }
    var returnTime:String{
        getTime(time: thTime ?? "")
    }
    var sign:Int? //1:未领取 2:已领取 3:已过期
    var transferAccountsType:Int? //0:私聊转账，1是群转账
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
    let groupId:String?
    
    var localEx:Int?
}
//转账消息
class TransferAccountsMessageStatus: Decodable {
   
    var customType:Int?
    var data: TransferAccountsMessageStatusInfo?
    var localEx: String?
}
struct TransferAccountsMessageStatusInfo: Decodable {
    let sendUserId: String?
    let sendUserName: String?
    let receiverId: String?
    let receiverName:String?
    let code:String?
    let instructions:String?
    
    var localEx:Int?
}
//红包详情
class BoBRedPacketDetailResponse: Decodable {
    var data: BoBRedPacketDetailData
    var flag: Bool = false
    var code: Int = 620000
    var message: String? = nil
    var count: Int? = 0
}
class BoBRedPacketDetailData: Decodable {
    var number:Int?//红包总个数
    var funderNickName:String?//发出方昵称
    var funderImg:String?//发送者头像
    var instructions:String?//说明
    var code:String? //红包账单号
    var currency:String?//货币
    var residualNumber:Int? //剩余个数
    var amountAll:Double? //数量(总)
    var amountM:Double? //自己领取的数量
    var sign:Int?//1可领取；2已领完；3已过期（红包的总状态，发送者使用的）
    var iconTimeAmountCurrencyNamePOS:[iconTimeAmountCurrencyNamePOS]
}
class iconTimeAmountCurrencyNamePOS: Decodable {
    var amount:Double?//领取数量
    var currency:String?//货币
    var icon:String? //领取者头像
    var name:String? //领取者昵称
    var time:String? //领取时间
    var addr:String? //领取者钱包地址
    var luck:Bool? //手机最佳
    var receiveTime:String{
        getTime(time: time ?? "")
    }
}
func getTime(time:String) -> (String){
    let dateFormatter = DateFormatter()
    // 设置日期格式化器的时区，确保输出正确的时间
//        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    dateFormatter.timeZone =  NSTimeZone.system

     
    // 设置日期格式化器的日期格式
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
     
    // 将ISO 8601字符串转换为Date对象
    guard let date = dateFormatter.date(from: time) else {
        return ""
//        fatalError("Date conversion failed")
    }
     
    // 重新设置日期格式化器的日期格式
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
     
    // 将Date对象转换为需要的格式的字符串
    let formattedDateString = dateFormatter.string(from: date)
    return formattedDateString
}
