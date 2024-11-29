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
    
    private static let TransferAccountsHome = "/wallet/transferMoneyOut/transferMoneyManualOperationHome1"//转账主页数据
    
    
    private static let SendExternalTransfer = "/wallet/transferMoneyOut/sendExternalTransfer"//转账
    
    private static let AddSecurityCode = "/wallet/securityCode/addSecurityCode" //设置安全密码
    private static let EditSecurityCode = "/wallet/securityCode/updateSecurityCode" //修改安全密码
    
    private static let QueryMyBillList = "/wallet/check/queryMyCheck" //账单列表

    


    private static var httpHeaders : HTTPHeaders = [
        "token":UserDefaults.standard.string(forKey: "bussinessTokenKey")!,
        "X-Forwarded-For":IMController.shared.publicIP,
        "Authorization":"eyJ1c2VySW5mbyI6InVzZXJCbG9nWWFuWmhlbmdUb2tlbiJ9",
        "Content-Type":"application/json",
        "operationID":String(Int(Date().timeIntervalSince1970)),
    ]
    //支付方式列表
    static func QueryUserPaymentList(userId: String?,
                                  valueHandler: @escaping (PaymentMethodData) -> Void,
                                  completionHandler: @escaping CompletionHandler) {
        
        
        if !NetworkStatus.isReacheable {
//            SuperToast.show(title: "")
            return
        }
        ProgressHUD.animate()
        let param = ["userId": userId ?? ""]
        let url = SuperStringUtil.netUrl(API_BOB_URL + UserPaymentMedothList, param)
        
        Alamofire.request(url, method: .post, parameters: param,encoding: JSONEncoding.default, headers: httpHeaders).responseJSON { dataRequest in
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
    static func DeletePayMentRequest(userId: String?,
                                     id:Int,
                                     completionHandler: @escaping CompletionHandler) {
           
           
           if !NetworkStatus.isReacheable {
   //            SuperToast.show(title: "")
               return
           }
           ProgressHUD.animate()
        let param = ["userId": userId ?? "","id":id] as [String : Any]
           let url = SuperStringUtil.netUrl(API_BOB_URL + DeletePayment, param)
           
           Alamofire.request(url, method: .post, parameters: param,encoding: JSONEncoding.default, headers: httpHeaders).responseJSON { dataRequest in
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
        
        Alamofire.request(API_BOB_URL + addPaymentAPI, method: .post, parameters: param,encoding: JSONEncoding.default, headers: httpHeaders).responseJSON { dataRequest in
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
    static func GetBankList(userId: String?,
                                  valueHandler: @escaping ([paymentBankData]) -> Void,
                                  completionHandler: @escaping CompletionHandler) {
        
        
        if !NetworkStatus.isReacheable {
//            SuperToast.show(title: "")
            return
        }
        ProgressHUD.animate()
        let param = ["userId": userId ?? "","language":String.getCurrentLanguageFirst()]
        let url = SuperStringUtil.netUrl(API_BOB_URL + BankList, param)
        
        Alamofire.request(url, method: .post, parameters: param,encoding: JSONEncoding.default, headers: httpHeaders).responseJSON { dataRequest in
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
    
    static func ReceivePaymentRequest(userId: String?,
                            currency:String?,
                                  valueHandler: @escaping (ReceivePaymentData) -> Void,
                                  completionHandler: @escaping CompletionHandler) {
        
        
        if !NetworkStatus.isReacheable {
//            SuperToast.show(title: "")
            return
        }
        ProgressHUD.animate()
        let param = ["userId": userId ?? "","currency":currency ?? ""]
        let url = SuperStringUtil.netUrl(API_BOB_URL + ReceivePayment, param)
        
        Alamofire.request(url, method: .post, parameters: param,encoding: JSONEncoding.default, headers: httpHeaders).responseJSON { dataRequest in
            ProgressHUD.dismiss()
            
            if let data = dataRequest.data {
                let strData = String.init(data: data, encoding: String.Encoding.utf8)
                print(strData!)
                if let res = JsonTool.fromJson(strData!, toClass: PaymentResponse<ReceivePaymentData>.self) {

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
    static func TransferAccountsHomeRequest(userId: String?,
                                  valueHandler: @escaping (TransferAccountsHomeData) -> Void,
                                  completionHandler: @escaping CompletionHandler) {
        
        
        if !NetworkStatus.isReacheable {
            return
        }
        ProgressHUD.animate()
        let param = ["userId": userId ?? ""]
        let url = SuperStringUtil.netUrl(API_BOB_URL + TransferAccountsHome, param)
        
        Alamofire.request(url, method: .post, parameters: param,encoding: JSONEncoding.default, headers: httpHeaders).responseJSON { dataRequest in
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
    
    static func SendExternalTransferRequest(userId: String?,
                                            addr:String?,
                                            currency:String?,
                                            issuingPartyWallet:String?,
                                            transferAmount:String?,
                                            passWord:String?,
                                  completionHandler: @escaping CompletionHandler) {
        
        
        if !NetworkStatus.isReacheable {
            return
        }
        ProgressHUD.animate()
        let param = ["userId": userId ?? "","addr": addr ?? "","currency": currency ?? "","issuingPartyWallet": issuingPartyWallet ?? "","transferAmount": transferAmount ?? "0.00","passWord": passWord ?? ""]
        
        Alamofire.request(API_BOB_URL + SendExternalTransfer, method: .post, parameters: param,encoding: JSONEncoding.default, headers: httpHeaders).responseJSON { dataRequest in
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
                                       oldSecurityCode:String?,
                                       newSecurityCode:String?,
                                       securityCode:String?,
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
            param = ["userId": userId ?? "","securityCode": securityCode ?? ""]
            url = AddSecurityCode
        }else{
            //修改
            param = ["userId": userId ?? "","oldSecurityCode": oldSecurityCode ?? "","newSecurityCode" : newSecurityCode ?? ""]
            url = EditSecurityCode
        }
        
        Alamofire.request(SuperStringUtil.netUrl(API_BOB_URL + url, param), method: .post, parameters: param,encoding: JSONEncoding.default, headers: httpHeaders).responseJSON { dataRequest in
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
    static func GetMyBillList(userId: String?,
                              tpye:Int?,
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
        let param = ["userId": userId ?? "","tpye": tpye ?? 0, "timeStart": timeStart ?? "","timeEnd": timeEnd ?? "","currency": currency ?? "","pageSize": pageSize ?? 0,"pageNum": pageNum ?? 0] as [String : Any]
        let url = SuperStringUtil.netUrl(API_BOB_URL + QueryMyBillList, param)
        
        Alamofire.request(url, method: .post, parameters: param,encoding: JSONEncoding.default, headers: httpHeaders).responseJSON { dataRequest in
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
    
}
class PaymentResponse<T: Decodable>: Decodable {
    var data: T
    var flag: Bool = false
    var code: Int = 20000
    var message: String? = nil
    var count: Int? = 0
}
struct PaymentMethodData: Codable {
    var name: String
    var i: Int
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

class ReceivePaymentData: Decodable {
    var addr: String?
    var minAmount:Double?
}

class TransferAccountsHomeData: Decodable {
    var cpos: [cpos]
    var anQuan:Bool?
}
class cpos: Decodable {
    var icon: String?
    var biZhong:String?
    var xianE:Double?
    var shouXuFei:Double?
    var zuiXiaoShouXuFei:Double?
    var t0:Double?
    var t1:Double?
}
class CionTypeModel: Decodable {
    var icon: String?
    var biZhong:String?
    var xianE:Double?
    var shouXuFei:Double?
    var zuiXiaoShouXuFei:Double?
    var cionType:String?
    var money:Double?
    var type:Int?
    var isSelect:Bool
    init(icon: String? = nil, biZhong: String? = nil, xianE: Double? = nil, shouXuFei: Double? = nil, zuiXiaoShouXuFei: Double? = nil, cionType: String? = nil, money: Double? = nil, type: Int? = nil, isSelect: Bool? = false) {
        self.icon = icon
        self.biZhong = biZhong
        self.xianE = xianE
        self.shouXuFei = shouXuFei
        self.zuiXiaoShouXuFei = zuiXiaoShouXuFei
        self.cionType = cionType
        self.money = money
        self.type = type
        self.isSelect = isSelect!
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
    var code: String?
    var changeTime:String?
    var changeType:Int?
    var show:String?
    var changeZf:String?
    var amount:Double?
    var currency:String?
}

