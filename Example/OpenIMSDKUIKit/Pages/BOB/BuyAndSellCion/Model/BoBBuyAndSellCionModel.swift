//
//  BoBBuyAndSellCionModel.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/12/13.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Alamofire
import Foundation
import OUICore
import ProgressHUD
import RxSwift
import Network
class BoBBuyAndSellCionModel {
    // 业务服务器地址
    private static let API_BOB_URL = "http://192.168.7.128:18729"
//    public static let API_BOB_URL = "http://143.92.40.164:18729"
    
    
    private static let BuyingAndSellingCoinsHome = "/wallet/advertisement/buyingAndSellingCoinsHome" //买卖币首页数据
    private static let RefreshTheExchangeRate = "/wallet/advertisement/refreshTheExchangeRate"//获取当前利率
    private static let FreeAreaList = "/wallet/advertisement/selfSelectedArea"//自选区
    private static let QueryBalanceByCurrency = "/wallet/advertisement/queryBalanceByCurrency"//根据币种显示余额
    private static let CreatingAdvertisementPurchase = "/wallet/advertisement/creatingAdvertisementPurchase"//创建、编辑购买广告
    private static let CreatingAdvertisementSell = "/wallet/advertisement/creatingAdvertisementSell"//创建、编辑出售广告
    private static let UpdateNameOfAdvertiser = "/wallet/advertisement/updateNameOfAdvertiser"//修改广告商名称
    
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
   
    static func BuyingAndSellingCoinsHomeRequest(
                                  valueHandler: @escaping (BoBBuyAndSellHomeData) -> Void,
                                  completionHandler: @escaping CompletionHandler) {
        if !NetworkStatus.isReacheable {
            return
        }
        ProgressHUD.animate()

        
        Alamofire.request(API_BOB_URL + BuyingAndSellingCoinsHome, method: .post, parameters: nil,encoding: JSONEncoding.default, headers: getHttpHeader()).responseJSON { dataRequest in
            ProgressHUD.dismiss()
            
            if let data = dataRequest.data {
                let strData = String.init(data: data, encoding: String.Encoding.utf8)
                print(strData!)
                if let res = JsonTool.fromJson(strData!, toClass: BoBBuyAndSellResponse<BoBBuyAndSellHomeData>.self) {

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
    static func RefreshTheExchangeRateRequest(
                                  valueHandler: @escaping (Double) -> Void,
                                  completionHandler: @escaping CompletionHandler) {
        if !NetworkStatus.isReacheable {
            return
        }
        ProgressHUD.animate()

        
        Alamofire.request(API_BOB_URL + RefreshTheExchangeRate, method: .post, parameters: nil,encoding: JSONEncoding.default, headers: getHttpHeader()).responseJSON { dataRequest in
            ProgressHUD.dismiss()
            
            if let data = dataRequest.data {
                let strData = String.init(data: data, encoding: String.Encoding.utf8)
                print(strData!)
                if let res = JsonTool.fromJson(strData!, toClass: BoBBuyAndSellResponse<Double>.self) {

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
    
    static func FreeAreaListRequest(type:Int,
                                    currency:String,
                                    amount:String,
                                    payment:String,
                                    pageNum:Int,
                                    pageSize:Int,
                                    valueHandler: @escaping ([BoBBuyAndSellFreeAreaList]) -> Void,
                                    completionHandler: @escaping CompletionHandler) {
        if !NetworkStatus.isReacheable {
            return
        }
        ProgressHUD.animate()
        let param = ["type": type, "currency": currency,"amount": amount,"payment": payment,"pageNum": pageNum,"pageSize": pageSize] as [String : Any]
        let url = SuperStringUtil.netUrl(API_BOB_URL + FreeAreaList, param)
        Alamofire.request(url, method: .post, parameters: param,encoding: JSONEncoding.default, headers: getHttpHeader()).responseJSON { dataRequest in
            ProgressHUD.dismiss()
            
            if let data = dataRequest.data {
                let strData = String.init(data: data, encoding: String.Encoding.utf8)
                print(strData!)
                if let res = JsonTool.fromJson(strData!, toClass: BoBBuyAndSellFreeAreaData.self) {

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
    static func QueryBalanceByCurrencyRequest(currency:String,
                                              valueHandler: @escaping (CionDetailTypeModel) -> Void,
                                              completionHandler: @escaping CompletionHandler) {
        if !NetworkStatus.isReacheable {
            return
        }
        ProgressHUD.animate()
        let param = ["currency": currency] as [String : Any]
        let url = SuperStringUtil.netUrl(API_BOB_URL + QueryBalanceByCurrency, param)
        Alamofire.request(url, method: .post, parameters: param,encoding: JSONEncoding.default, headers: getHttpHeader()).responseJSON { dataRequest in
            ProgressHUD.dismiss()
            
            if let data = dataRequest.data {
                let strData = String.init(data: data, encoding: String.Encoding.utf8)
                print(strData!)
                if let res = JsonTool.fromJson(strData!, toClass: BoBBuyAndSellResponse<CionDetailTypeModel>.self) {

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
    static func CreatAdvertisementRequest(type:Int?,
                                          param:[String:Any],
                                          completionHandler: @escaping CompletionHandler) {
        if !NetworkStatus.isReacheable {
            return
        }
        ProgressHUD.animate()
        var url = ""
        if type == 1{
            //出售
            url = API_BOB_URL + CreatingAdvertisementSell
        }else{
            //购买
            url = API_BOB_URL + CreatingAdvertisementPurchase
        }
        Alamofire.request(url, method: .post, parameters: param,encoding: JSONEncoding.default, headers: getHttpHeader()).responseJSON { dataRequest in
            ProgressHUD.dismiss()
            if let data = dataRequest.data {
                let strData = String.init(data: data, encoding: String.Encoding.utf8)
                print(strData!)
                if let res = JsonTool.fromJson(strData!, toClass: BoBBuyAndSellNODataResponse.self) {
                    completionHandler(res.code, res.message)
                } else {
                    completionHandler(-1, "failure")
                }
            } else {
                completionHandler(-1, "failure")
            }
        }
        
    }
    static func UpdateNameOfAdvertiserRequest(advertiserName:String?,
                                          completionHandler: @escaping CompletionHandler) {
        if !NetworkStatus.isReacheable {
            return
        }
        ProgressHUD.animate()
        let param = ["advertiserName":advertiserName ?? ""] as [String:Any]
//        let url =  SuperStringUtil.netUrl(API_BOB_URL + UpdateNameOfAdvertiser, param)
        Alamofire.request(API_BOB_URL + UpdateNameOfAdvertiser, method: .post, parameters: param,encoding: JSONEncoding.default, headers: getHttpHeader()).responseJSON { dataRequest in
            ProgressHUD.dismiss()
            if let data = dataRequest.data {
                let strData = String.init(data: data, encoding: String.Encoding.utf8)
                print(strData!)
                if let res = JsonTool.fromJson(strData!, toClass: BoBBuyAndSellNODataResponse.self) {
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
class BoBBuyAndSellResponse<T: Decodable>: Decodable {
    var data: T
    var flag: Bool = false
    var code: Int = 20000
    var message: String? = nil
    var count: Int? = 0
}
class BoBBuyAndSellNODataResponse: Decodable {
//    var data: T
    var flag: Bool = false
    var code: Int = 20000
    var message: String? = nil
    var count: Int? = 0
}
class BoBBuyAndSellHomeData: Decodable {
    var certificationLevel: Int?
    var payment: Bool = false //是否有支付方式
    var secure:Bool = false //是否有安全密码
    var exchangeRate:Double? //汇率
    var userBankAndWeiXinAndZFBPO:PaymentMethodData? //支付方式
    var needRegistrationDay:Int? //需要注册天数
    var needAuthenticationDay:Int?//需要身份认证天数
    var currencyAndIconPO:[currencyAndIconPO] //币种
    var advertisingName:String?//广告商名称
    var minimumAdvertisedRate:Double?//最低广告汇率
    var maximumAdvertisedRate:Double?//最高广告汇率
    var mregistrationDay:Int?//我的注册天数
    var mauthenticationDay:Int?//我的身份认证天数
}
class currencyAndIconPO: Decodable {
    var currency:String? //币种
    var icon:String? //图标
}
class BoBBuyAndSellFreeAreaData: Decodable {
    var data: [BoBBuyAndSellFreeAreaList]
    var flag: Bool = false
    var code: Int = 20000
    var message: String? = nil
    var count: Int? = 0
}
class BoBBuyAndSellFreeAreaList: Decodable {
    var advertisingCurrency:String? //币种
    var advertisingType:Int? //广告类型1:出售 2:购买 3:兑换
    var transactionMode:String? //交易方式1:银行卡 2:支付宝 3:微信
    var surplusQuantity:Double?//数量
    var quotaMin:Double?//最小限额
    var quotaMax:Double?//最大限额
    var advertisingName:String?//广告商名称
    var orderAndTransactionRatesPO:orderAndTransactionRatesPO? //订单数和成单率
    var code:String?
    var setExchangeRate:Double?//设置汇率
}
class orderAndTransactionRatesPO:Decodable {
    var order:Int?//订单数
    var transactionRates:Double?//成单率(0-1)
}
class CionDetailTypeModel:Decodable {
    var t0:Double?
    var t1:Double?
    var icon:String?
}

