//
//  BoBPaymentModel.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/11/25.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Alamofire
import Foundation
import OUICore
import ProgressHUD
import RxSwift
import Network
class BoBPaymentModel {
    // 业务服务器地址
    public static let API_BOB_URL = "http://192.168.7.128:18729"
//    public static let API_BOB_URL = "http://143.92.40.164:18729"
    
    
    private static let UserPaymentMedothList = "/wallet/userPayment/queryUserPayment" //支付方式列表
    private static let DeletePayment = "/wallet/userPayment/delUserPayment" //删除支付方式
    private static let AddPaymentBank = "/wallet/userPayment/addPaymentBank" //添加银行卡支付
    private static let AddPaymentALi = "/wallet/userPayment/addPaymentALi" //添加支付宝支付
    private static let AddPaymentWX = "/wallet/userPayment/addPaymentWX" //添加微信支付
    private static let EditPaymentBank = "/wallet/userPayment/updateUserPaymentBank" //编辑银行卡支付
    private static let EditPaymentALi = "/wallet/userPayment/updateUserPaymentALi" //编辑支付宝支付
    private static let EditPaymentWX = "/wallet/userPayment/updateUserPaymentWX" //编辑微信支付
    private static let BankList = "/wallet/bankInfo/queryBankInfoAll" //银行列表
    
    private static let ReceivePayment = "/wallet/collection/mYCollectionHome" //收款主页数据
    
    private static let TransferAccountsHome = "/wallet/transferMoneyOut/transferMoneyManualOperationHome"//转账主页数据
    
    
    private static let SendExternalTransfer = "/wallet/transferMoneyOut/sendExternalTransfer"//转账
    
    private static let AddSecurityCode = "/wallet/securityCode/addSecurityCode" //设置安全密码
    private static let EditSecurityCode = "/wallet/securityCode/updateSecurityCode" //修改安全密码
    
    private static let QueryMyBillList = "/wallet/check/queryMyCheck" //账单列表
    private static let QueryBillDeatil = "/wallet/check/queryMyCheckByCode" //账单详情

    


//    private static var httpHeaders : HTTPHeaders = [
//        "token":UserDefaults.standard.string(forKey: "bussinessTokenKey")!,
//        "X-Forwarded-For":IMController.shared.publicIP,
//        "Authorization":"eyJ1c2VySW5mbyI6InVzZXJCbG9nWWFuWmhlbmdUb2tlbiJ9",
//        "Content-Type":"application/json",
//        "operationID":String(Int(Date().timeIntervalSince1970)),
//    ]
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
    //支付方式列表
    static func QueryUserPaymentList(valueHandler: @escaping (PaymentMethodData) -> Void,
                                  completionHandler: @escaping CompletionHandler) {
        
        
        if !NetworkStatus.isReacheable {
//            SuperToast.show(title: "")
            return
        }
        ProgressHUD.animate()
//        let param = ["userId": userId ?? ""]
//        let url = SuperStringUtil.netUrl(API_BOB_URL + UserPaymentMedothList, param)
        
        Alamofire.request(API_BOB_URL + UserPaymentMedothList, method: .post, parameters: nil,encoding: JSONEncoding.default, headers: getHttpHeader()).responseJSON { dataRequest in
            ProgressHUD.dismiss()
            
            if let data = dataRequest.data {
                let strData = String.init(data: data, encoding: String.Encoding.utf8)
                print(strData!)
                if let res = JsonTool.fromJson(strData!, toClass: PaymentResponse<PaymentMethodData>.self) {

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
    //删除支付
    static func DeletePayMentRequest(id:Int,
                                     completionHandler: @escaping CompletionHandler) {
           
           
           if !NetworkStatus.isReacheable {
   //            SuperToast.show(title: "")
               return
           }
           ProgressHUD.animate()
        let param = ["id":id] as [String : Any]
           let url = SuperStringUtil.netUrl(API_BOB_URL + DeletePayment, param)
           
           Alamofire.request(url, method: .post, parameters: param,encoding: JSONEncoding.default, headers: getHttpHeader()).responseJSON { dataRequest in
               ProgressHUD.dismiss()
               
               if let data = dataRequest.data {
                   let strData = String.init(data: data, encoding: String.Encoding.utf8)
                   print(strData!)
                   if let res = JsonTool.fromJson(strData!, toClass: BoBResponse.self) {
                       completionHandler(res.code, res.message)
                   } else {
                       completionHandler(-1, "failure")
                   }
               } else {
                   completionHandler(-1, "failure")
               }
           }
           
       }
    //添加、修改支付方式
    static func AddPaymentMethod(type:Int = 1,
                                 paymentType:Int = 0,
                                 param:[String: Any],
                                  completionHandler: @escaping CompletionHandler) {
        
        
        if !NetworkStatus.isReacheable {
//            SuperToast.show(title: "")
            return
        }
        ProgressHUD.animate()
        var addPaymentAPI = ""
        if type == 1{
            if paymentType == 0{
                //银行卡
                addPaymentAPI = AddPaymentBank
            }else if paymentType == 1{
                //支付宝
                addPaymentAPI = AddPaymentALi
            }else{
                //微信
                addPaymentAPI = AddPaymentWX
            }
        }else{
            if paymentType == 0{
                //银行卡
                addPaymentAPI = EditPaymentBank
            }else if paymentType == 1{
                //支付宝
                addPaymentAPI = EditPaymentALi
            }else{
                //微信
                addPaymentAPI = EditPaymentWX
            }
        }
        
//        let url = SuperStringUtil.netUrl(API_BOB_URL + addPaymentAPI, param)
        
        Alamofire.request(API_BOB_URL + addPaymentAPI, method: .post, parameters: param,encoding: JSONEncoding.default, headers: getHttpHeader()).responseJSON { dataRequest in
            ProgressHUD.dismiss()
            
            if let data = dataRequest.data {
                let strData = String.init(data: data, encoding: String.Encoding.utf8)
                print(strData!)
                if let res = JsonTool.fromJson(strData!, toClass: BoBResponse.self) {
                    completionHandler(res.code, res.message)
                } else {
                    completionHandler(-1, "failure")
                }
            } else {
                completionHandler(-1, "failure")
            }
        }
        
    }
    static func GetBankList(valueHandler: @escaping ([paymentBankData]) -> Void,
                                  completionHandler: @escaping CompletionHandler) {
        
        
        if !NetworkStatus.isReacheable {
//            SuperToast.show(title: "")
            return
        }
        ProgressHUD.animate()
        let param = ["language":String.getCurrentLanguageFirst()]
        let url = SuperStringUtil.netUrl(API_BOB_URL + BankList, param)
        
        Alamofire.request(url, method: .post, parameters: param,encoding: JSONEncoding.default, headers: getHttpHeader()).responseJSON { dataRequest in
            ProgressHUD.dismiss()
            
            if let data = dataRequest.data {
                let strData = String.init(data: data, encoding: String.Encoding.utf8)
                print(strData!)
                if let res = JsonTool.fromJson(strData!, toClass: BoBBankResponse.self) {

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
    
    static func ReceivePaymentRequest(
                                  valueHandler: @escaping ([ReceivePaymentData]) -> Void,
                                  completionHandler: @escaping CompletionHandler) {
        
        
        if !NetworkStatus.isReacheable {
//            SuperToast.show(title: "")
            return
        }
        ProgressHUD.animate()
//        let param = ["currency":currency ?? ""]
//        let url = SuperStringUtil.netUrl(API_BOB_URL + ReceivePayment, param)
        
        Alamofire.request(API_BOB_URL + ReceivePayment, method: .post, parameters: nil,encoding: JSONEncoding.default, headers: getHttpHeader()).responseJSON { dataRequest in
            ProgressHUD.dismiss()
            
            if let data = dataRequest.data {
                let strData = String.init(data: data, encoding: String.Encoding.utf8)
                print(strData!)
                if let res = JsonTool.fromJson(strData!, toClass: ReceivePayResponse.self) {

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
    static func TransferAccountsHomeRequest(
                                  valueHandler: @escaping (TransferAccountsHomeData) -> Void,
                                  completionHandler: @escaping CompletionHandler) {
        
        
        if !NetworkStatus.isReacheable {
            return
        }
        ProgressHUD.animate()
//        let param = ["userId": userId ?? ""]
//        let url = SuperStringUtil.netUrl(API_BOB_URL + TransferAccountsHome, param)
        
        Alamofire.request(API_BOB_URL + TransferAccountsHome, method: .post, parameters: nil,encoding: JSONEncoding.default, headers: getHttpHeader()).responseJSON { dataRequest in
            ProgressHUD.dismiss()
            
            if let data = dataRequest.data {
                let strData = String.init(data: data, encoding: String.Encoding.utf8)
                print(strData!)
                if let res = JsonTool.fromJson(strData!, toClass: PaymentResponse<TransferAccountsHomeData>.self) {

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
    
    static func SendExternalTransferRequest(addr:String?,
                                            currency:String?,
                                            issuingPartyWallet:String?,
                                            transferAmount:String?,
                                            sign:String?,
                                  completionHandler: @escaping CompletionHandler) {
        
        
        if !NetworkStatus.isReacheable {
            return
        }
        ProgressHUD.animate()
        let timestamp = String(Int(Date().timeIntervalSince1970 * 1000))
        let signStr = (addr! + currency! + issuingPartyWallet! + transferAmount! + timestamp + (IMController.shared.payPassWordSonKey + (sign ?? "")).md5).md5
        let param = ["addr": addr ?? "","currency": currency ?? "","issuingPartyWallet": issuingPartyWallet ?? "","transferAmount": transferAmount ?? "0.00","timestamp":timestamp,"sign": signStr]
        
        Alamofire.request(API_BOB_URL + SendExternalTransfer, method: .post, parameters: param,encoding: JSONEncoding.default, headers: getHttpHeader()).responseJSON { dataRequest in
            ProgressHUD.dismiss()
            
            if let data = dataRequest.data {
                let strData = String.init(data: data, encoding: String.Encoding.utf8)
                print(strData!)
                
                if let res = JsonTool.fromJson(strData!, toClass: BoBResponse.self) {
                    completionHandler(res.code, res.message)
                } else {
                    completionHandler(-1, "failure")
                }
            } else {
                completionHandler(-1, "failure")
            }
        }
        
    }
    
    static func SetSecurityCodeRequest(userId: String?,
                                       oldSign:String?,
                                       newSign:String?,
                                       sign:String?,
                                       type:Int?,
                                  completionHandler: @escaping CompletionHandler) {
        
        
        if !NetworkStatus.isReacheable {
            return
        }
        ProgressHUD.animate()
        
        var param:[String: Any]
        var url = ""
        if type == 0{
            //设置
            param = ["userId": userId ?? "","sign": (IMController.shared.payPassWordSonKey + (sign ?? "")).md5]
            url = AddSecurityCode
        }else{
            //修改
            param = ["userId": userId ?? "","oldSign": (IMController.shared.payPassWordSonKey + (oldSign ?? "")).md5,"newSign" :  (IMController.shared.payPassWordSonKey + (newSign ?? "")).md5]
            url = EditSecurityCode
        }
        
        Alamofire.request(SuperStringUtil.netUrl(API_BOB_URL + url, param), method: .post, parameters: param,encoding: JSONEncoding.default, headers: getHttpHeader()).responseJSON { dataRequest in
            ProgressHUD.dismiss()
            
            if let data = dataRequest.data {
                let strData = String.init(data: data, encoding: String.Encoding.utf8)
                print(strData!)
                
                if let res = JsonTool.fromJson(strData!, toClass: BoBResponse.self) {
                    completionHandler(res.code, res.message)
                } else {
                    completionHandler(-1, "failure")
                }
            } else {
                completionHandler(-1, "failure")
            }
        }
        
    }
    //账单
    static func GetMyBillList(tpye:Int?,
                              timeStart:String?,
                              timeEnd:String?,
                              currency:String?,
                              pageSize:Int?,
                              pageNum:Int?,
                                  valueHandler: @escaping ([BillListData]) -> Void,
                                  completionHandler: @escaping CompletionHandler) {
        
        
        if !NetworkStatus.isReacheable {
//            SuperToast.show(title: "")
            return
        }
        ProgressHUD.animate()
        let param = ["tpye": tpye ?? 0, "timeStart": timeStart ?? "","timeEnd": timeEnd ?? "","currency": currency ?? "","pageSize": pageSize ?? 0,"pageNum": pageNum ?? 0] as [String : Any]
        let url = SuperStringUtil.netUrl(API_BOB_URL + QueryMyBillList, param)
        
        Alamofire.request(url, method: .post, parameters: param,encoding: JSONEncoding.default, headers: getHttpHeader()).responseJSON { dataRequest in
            ProgressHUD.dismiss()
            
            if let data = dataRequest.data {
                let strData = String.init(data: data, encoding: String.Encoding.utf8)
                print(strData!)
                if let res = JsonTool.fromJson(strData!, toClass: BoBBillResponse.self) {

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
    //账单详情
    static func QueryBillDeatilRequest(code:Int?,
                               valueHandler: @escaping (BoBBillDetail) -> Void,
                               completionHandler: @escaping CompletionHandler) {
     
     
     if !NetworkStatus.isReacheable {
//            SuperToast.show(title: "")
         return
     }
     ProgressHUD.animate()
     let param = ["code": code ?? 0] as [String : Any]
     let url = SuperStringUtil.netUrl(API_BOB_URL + QueryBillDeatil, param)
     
     Alamofire.request(url, method: .post, parameters: param,encoding: JSONEncoding.default, headers: getHttpHeader()).responseJSON { dataRequest in
         ProgressHUD.dismiss()
         
         if let data = dataRequest.data {
             let strData = String.init(data: data, encoding: String.Encoding.utf8)
             print(strData!)
             if let res = JsonTool.fromJson(strData!, toClass: BoBBillDetailResponse.self) {

                 if res.code == 20000  {
                     valueHandler(res.data.externalTransferMessageVO)
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
class PaymentResponse<T: Decodable>: Decodable {
    var data: T
    var flag: Bool = false
    var code: Int = 20000
    var message: String? = nil
    var count: Int? = 0
}
struct PaymentMethodData: Codable {
    var name: String?
    var i: Int?
    var stringAndDatePOS: [stringAndDatePOS]?
}

struct stringAndDatePOS: Codable {
    var id: Int
    var dateValue: String
    var icon:String?
    var stringValue:String?
    var type: String
}
class paymentDdetailData: Decodable {
    var userId: String?
    var name: String?
    var zfbCode:String?
    var nickName: String?
    var img:String?
    var bankId:String?
    var bankDeposit:String?
    var bankBranch:String?
}
class BoBBankResponse: Decodable {
    var data: [paymentBankData]
    var flag: Bool = false
    var code: Int = 20000
    var message: String? = nil
    var count: Int? = 0
}
class paymentBankData: Decodable {
    var name: String?
    var icon:String?
}
class ReceivePayResponse: Decodable {
    var data: [ReceivePaymentData]
    var flag: Bool = false
    var code: Int = 20000
    var message: String? = nil
    var count: Int? = 0
}
class ReceivePaymentData: Decodable {
    var addr: String?
    var minAmount:Double?
    var icon:String?
    var currency:String?
}

class TransferAccountsHomeData: Decodable {
    var externalTransferOutPOS: [externalTransferOutPOS]
    var secure:Bool?
    var certificationLevel:Int?
}
class externalTransferOutPOS: Decodable {
    var icon: String? //币种图标
    var currency:String? //币种
    var quota:Double? //剩余限额
    var aggregateLimit:Double? //限额
    var handlingCharge:Double? //手续费
    var minimumCommission:Double? //最小手续费
    var t0:Double?
    var t1:Double?
}
class CionTypeModel: Decodable {
    var icon: String?
    var currency:String?
    var quota:Double?
    var aggregateLimit:Double?
    var handlingCharge:Double?
    var minimumCommission:Double?
    var cionType:String?
    var money:Double?
    var type:Int?
    var isSelect:Bool
    var exchangeRate:Double?
    init(icon: String? = nil, currency: String? = nil, quota: Double? = nil, aggregateLimit: Double? = nil, handlingCharge: Double? = nil, minimumCommission: Double? = nil, cionType: String? = nil, money: Double? = nil, type: Int? = nil, isSelect: Bool? = false, exchangeRate: Double? = 1) {
        self.icon = icon
        self.currency = currency
        self.quota = quota
        self.aggregateLimit = aggregateLimit
        self.handlingCharge = handlingCharge
        self.minimumCommission = minimumCommission
        self.cionType = cionType
        self.money = money
        self.type = type
        self.isSelect = isSelect!
        self.exchangeRate = exchangeRate
    }
}
class BoBBillResponse: Decodable {
    var data: [BillListData]
    var flag: Bool = false
    var code: Int = 20000
    var message: String? = nil
    var count: Int? = 0
}
class BillListData: Decodable {
    var code: Int?
    var changeTime:String?
    var changeType:Int?
    var show:String?
    var changeZf:String?
    var amount:Double?
    var currency:String?
    var time: String {
        getTransformTime(time: changeTime ?? "")
    }
}
class BoBBillDetailResponse: Decodable {
    var data: BoBBillDetailData
    var flag: Bool = false
    var code: Int = 20000
    var message: String? = nil
    var count: Int? = 0
}
class BoBBillDetailData: Decodable {
    var type: Int?
    var externalTransferMessageVO: BoBBillDetail
}
struct BoBBillDetail:Decodable {
    var amount:Double? //数量
    var direction:String? //符号（+，-）
    var type:Int?
    var counterpartyAddress:String? //对方收款地址
    var orderNumber:String? //原订单编号
    var orderNumberBack:String? //退款单号
    var backTime:String?//退款时间
    var tradingHours:String? //交易时间
    var handlingCharge:Double? //手续费
    var currency:String? //货币
    var tradingTime:String{
        getTransformTime(time: tradingHours ?? "")
    }
    var returnBackTime:String{
        getTransformTime(time: backTime ?? "")
    }
}
func getTransformTime(time:String) -> (String){
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

