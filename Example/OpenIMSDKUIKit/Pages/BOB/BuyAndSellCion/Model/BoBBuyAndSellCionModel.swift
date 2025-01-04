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
    
    
    private static let BuyingAndSellingCoinsHome = "/wallet/advertisement/buyingAndSellingCoinsHome" //买卖币首页数据
    private static let RefreshTheExchangeRate = "/wallet/advertisement/refreshTheExchangeRate"//获取当前利率
    private static let FreeAreaList = "/wallet/advertisement/selfSelectedArea"//自选区
    private static let QueryBalanceByCurrency = "/wallet/advertisement/queryBalanceByCurrency"//根据币种显示余额
    private static let QueryDailyLimit = "/wallet/advertisement/dailyLimit"//获取剩余限额
    private static let CreatingAdvertisementPurchase = "/wallet/advertisement/creatingAdvertisementPurchase"//创建、编辑购买广告
    private static let CreatingAdvertisementSell = "/wallet/advertisement/creatingAdvertisementSell"//创建、编辑出售广告
    private static let UpdateNameOfAdvertiser = "/wallet/advertisement/updateNameOfAdvertiser"//修改广告商名称
    private static let MyAdvertisementList = "/wallet/advertisement/myAdvertisement"//我的广告列表
    private static let ListingAdvertising = "/wallet/advertisement/listingAdvertising"//上架广告
    private static let TakeDownAdvertising = "/wallet/advertisement/takeDownAdvertising"//下架广告
    private static let DelAdvertising = "/wallet/advertisement/delAdvertising"//删除广告
    private static let RefreshUnitPrice = "/wallet/userOrderDetails/refreshUnitPrice"//刷新意向单单价
    private static let IntendedOrderHomePage = "/wallet/userOrderDetails/intendedOrderHomePage"//意向单首页
    private static let IntendedBuy = "/wallet/userOrderDetails/intendedBuy"//意向购买
    private static let IntendedSell = "/wallet/userOrderDetails/intendedSell"//意向出售
    private static let MyOrderList = "/wallet/userOrderDetails/myOrder"//我的订单列表
    private static let OrderDetails = "/wallet/userOrderDetails/orderDetails"//订单详情
    private static let BuyTakesOrders = "/wallet/userOrderDetails/buyTakesOrders"//买家接单
    private static let SellTakesOrders = "/wallet/userOrderDetails/sellTakesOrders"//卖家接单
    private static let UploadCredentials = "/wallet/userOrderDetails/uploadCredentials"//上传支付凭证
    private static let SellerDepositCoin = "/wallet/userOrderDetails/sellerDepositCoin"//通知平台放币
    private static let CancelOrder = "/wallet/userOrderDetails/cancelOrder"//订单取消
    private static let UpLoadAppeal = "/wallet/userOrderStatement/petitionInitiate"//上传申诉
    private static let QueryStatementDetails = "/wallet/userOrderStatement/queryStatementDetails"//查看申诉详情
    private static let QuickBuyCoin = "/wallet/fast/fastBuy"//快捷买币
    private static let QuickSellCoin = "/wallet/fast/fastSell"//快捷卖币

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
        let param = ["type": type, "currency": currency,"amount": amount,"payment": payment,"pageNum": pageNum,"pageSize": pageSize] as [String : Any]
        let url = SuperStringUtil.netUrl(API_BOB_URL + FreeAreaList, param)
        Alamofire.request(url, method: .post, parameters: param,encoding: JSONEncoding.default, headers: getHttpHeader()).responseJSON { dataRequest in
            
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
    static func QueryDailyLimitRequest(currency:String,
                                       valueHandler: @escaping (DailyLimitModel) -> Void,
                                       completionHandler: @escaping CompletionHandler) {
        if !NetworkStatus.isReacheable {
            return
        }
        let param = ["currency": currency] as [String : Any]
        let url = SuperStringUtil.netUrl(API_BOB_URL + QueryDailyLimit, param)
        Alamofire.request(url, method: .post, parameters: param,encoding: JSONEncoding.default, headers: getHttpHeader()).responseJSON { dataRequest in
            
            if let data = dataRequest.data {
                let strData = String.init(data: data, encoding: String.Encoding.utf8)
                print(strData!)
                if let res = JsonTool.fromJson(strData!, toClass: BoBBuyAndSellResponse<DailyLimitModel>.self) {
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

    static func MyAdvertisementListRequest(currency:String,
                                           type:Int,
                                           state:Int,
                                           pageNum:Int,
                                           pageSize:Int,
                                           valueHandler: @escaping ([BoBMineAdList]) -> Void,
                                           completionHandler: @escaping CompletionHandler) {
        if !NetworkStatus.isReacheable {
            return
        }
        ProgressHUD.animate()
        let param = ["currency": currency, "type": type,"state": state,"pageNum": pageNum,"pageSize": pageSize] as [String : Any]
        let url = SuperStringUtil.netUrl(API_BOB_URL + MyAdvertisementList, param)
        Alamofire.request(url, method: .post, parameters: param,encoding: JSONEncoding.default, headers: getHttpHeader()).responseJSON { dataRequest in
            ProgressHUD.dismiss()
            
            if let data = dataRequest.data {
                let strData = String.init(data: data, encoding: String.Encoding.utf8)
                print(strData!)
                if let res = JsonTool.fromJson(strData!, toClass: BoBMineAdData.self) {

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
    static func MyAdvertisementChangeRequest(type:Int,
                                             code:String,
                                             completionHandler: @escaping CompletionHandler) {
        if !NetworkStatus.isReacheable {
            return
        }
        ProgressHUD.animate()
        let param = ["code": code] as [String : Any]
        var url = ""
        if type == 0{
            //去下架
            url = SuperStringUtil.netUrl(API_BOB_URL + TakeDownAdvertising, param)
        }else if type == 1{
            //去上架
            url = SuperStringUtil.netUrl(API_BOB_URL + ListingAdvertising, param)
        }else{
            //去删除
            url = SuperStringUtil.netUrl(API_BOB_URL + DelAdvertising, param)
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
    static func RefreshUnitPriceRequest(code:String,
                                        valueHandler: @escaping (Double) -> Void,
                                        completionHandler: @escaping CompletionHandler) {
        if !NetworkStatus.isReacheable {
            return
        }
        ProgressHUD.animate()
        let param = ["code": code] as [String : Any]
        let url = SuperStringUtil.netUrl(API_BOB_URL + RefreshUnitPrice, param)
        Alamofire.request(url, method: .post, parameters: param,encoding: JSONEncoding.default, headers: getHttpHeader()).responseJSON { dataRequest in
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
    static func IntendedOrderHomePageRequest(code:String,
                                        valueHandler: @escaping (IntendedOrderHome) -> Void,
                                        completionHandler: @escaping CompletionHandler) {
        if !NetworkStatus.isReacheable {
            return
        }
        ProgressHUD.animate()
        let param = ["code": code] as [String : Any]
        let url = SuperStringUtil.netUrl(API_BOB_URL + IntendedOrderHomePage, param)
        Alamofire.request(url, method: .post, parameters: param,encoding: JSONEncoding.default, headers: getHttpHeader()).responseJSON { dataRequest in
            ProgressHUD.dismiss()
            
            if let data = dataRequest.data {
                let strData = String.init(data: data, encoding: String.Encoding.utf8)
                print(strData!)
                if let res = JsonTool.fromJson(strData!, toClass: BoBBuyAndSellResponse<IntendedOrderHome>.self) {

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
    static func IntendedBuyRequest(code:String,
                                   amount:String,
                                   payment:String,
                                   quantity:String,
                                   exchangeRate:String,
                                   type:Int,
                                   valueHandler: @escaping (String) -> Void,
                                   completionHandler: @escaping CompletionHandler) {
        if !NetworkStatus.isReacheable {
            return
        }
        ProgressHUD.animate()
        let param = ["code": code,"amount":amount,"payment":payment,"quantity":quantity,"exchangeRate":exchangeRate,"type":type] as [String : Any]
        let url = SuperStringUtil.netUrl(API_BOB_URL + IntendedBuy, param)
        Alamofire.request(url, method: .post, parameters: param,encoding: JSONEncoding.default, headers: getHttpHeader()).responseJSON { dataRequest in
            ProgressHUD.dismiss()
            if let data = dataRequest.data {
                let strData = String.init(data: data, encoding: String.Encoding.utf8)
                print(strData!)
                if let res = JsonTool.fromJson(strData!, toClass: BoBBuyAndSellResponse<String>.self) {
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
    static func IntendedSellRequest(code:String,
                                   amount:String,
                                   currencyWallet:String,
                                   payment:String,
                                   quantity:String,
                                   exchangeRate:String,
                                   paymentId:String,
                                   type:Int,
                                   pwd:String,
                                   valueHandler: @escaping (String) -> Void,
                                   completionHandler: @escaping CompletionHandler) {
        if !NetworkStatus.isReacheable {
            return
        }
        ProgressHUD.animate()
        let timestamp = String(Int(Date().timeIntervalSince1970 * 1000))
        let passWord = (IMController.shared.payPassWordSonKey + pwd).md5
        let sign = (code + amount + currencyWallet + payment + quantity + exchangeRate + paymentId + timestamp + String(type) + passWord).md5

        let param = ["code": code,"amount":amount,"currencyWallet":currencyWallet,"payment":payment,"quantity":quantity,"exchangeRate":exchangeRate,"paymentId":paymentId,"timestamp":timestamp,"type":type,"sign":sign] as [String : Any]
        let url = SuperStringUtil.netUrl(API_BOB_URL + IntendedSell, param)
        Alamofire.request(url, method: .post, parameters: param,encoding: JSONEncoding.default, headers: getHttpHeader()).responseJSON { dataRequest in
            ProgressHUD.dismiss()
            if let data = dataRequest.data {
                let strData = String.init(data: data, encoding: String.Encoding.utf8)
                print(strData!)
                if let res = JsonTool.fromJson(strData!, toClass: BoBBuyAndSellResponse<String>.self) {
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
    static func MyOrderListRequest(type:Int,
                                   sign:Int,
                                   pageNum:Int,
                                   pageSize:Int,
                                   valueHandler: @escaping ([BoBMineOrderList]) -> Void,
                                   completionHandler: @escaping CompletionHandler) {
        if !NetworkStatus.isReacheable {
            return
        }
        ProgressHUD.animate()
        let param = ["type": type, "sign": sign,"pageNum": pageNum,"pageSize": pageSize] as [String : Any]
        let url = SuperStringUtil.netUrl(API_BOB_URL + MyOrderList, param)
        Alamofire.request(url, method: .post, parameters: param,encoding: JSONEncoding.default, headers: getHttpHeader()).responseJSON { dataRequest in
            ProgressHUD.dismiss()
            
            if let data = dataRequest.data {
                let strData = String.init(data: data, encoding: String.Encoding.utf8)
                print(strData!)
                if let res = JsonTool.fromJson(strData!, toClass: BoBMineOrderListData.self) {

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
    static func OrderDetailsRequest(code:String,
                                   valueHandler: @escaping (BoBMineOrderList) -> Void,
                                   completionHandler: @escaping CompletionHandler) {
        if !NetworkStatus.isReacheable {
            return
        }
        let param = ["code": code] as [String : Any]
        let url = SuperStringUtil.netUrl(API_BOB_URL + OrderDetails, param)
        Alamofire.request(url, method: .post, parameters: param,encoding: JSONEncoding.default, headers: getHttpHeader()).responseJSON { dataRequest in
            
            if let data = dataRequest.data {
                let strData = String.init(data: data, encoding: String.Encoding.utf8)
                print(strData!)
                if let res = JsonTool.fromJson(strData!, toClass: BoBBuyAndSellResponse<BoBMineOrderList>.self) {

                    if res.code == 20000  {
                        if let res1 = JsonTool.fromJson(res.data.payDetails ?? "", toClass: paymentDdetailData.self) {
                            res.data.paymentMethodDetails = res1
                        }
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
    static func BuyerReceiveOrdersRequest(code:String,
                                      completionHandler: @escaping CompletionHandler) {
        if !NetworkStatus.isReacheable {
            return
        }
        ProgressHUD.animate()
        let param = ["code": code] as [String : Any]
        let url = SuperStringUtil.netUrl(API_BOB_URL + BuyTakesOrders, param)
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
    static func SellerReceiveOrdersRequest(code:String,
                                           paymentId:String,
                                           completionHandler: @escaping CompletionHandler) {
        if !NetworkStatus.isReacheable {
            return
        }
        ProgressHUD.animate()
        let param = ["code": code,"paymentId":paymentId] as [String : Any]
        let url = SuperStringUtil.netUrl(API_BOB_URL + SellTakesOrders, param)
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
    static func UploadCredentialsRequest(code:String,
                                         credentials:String,
                                         completionHandler: @escaping CompletionHandler) {
        if !NetworkStatus.isReacheable {
            return
        }
        ProgressHUD.animate()
        let param = ["code": code,"credentials":credentials] as [String : Any]
        let url = SuperStringUtil.netUrl(API_BOB_URL + UploadCredentials, param)
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
    static func SellerDepositCoinRequest(code:String,
                                         completionHandler: @escaping CompletionHandler) {
        if !NetworkStatus.isReacheable {
            return
        }
        ProgressHUD.animate()
        let param = ["code": code] as [String : Any]
        let url = SuperStringUtil.netUrl(API_BOB_URL + SellerDepositCoin, param)
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
    static func CancelOrderRequest(code:String,
                                         completionHandler: @escaping CompletionHandler) {
        if !NetworkStatus.isReacheable {
            return
        }
        ProgressHUD.animate()
        let param = ["code": code] as [String : Any]
        let url = SuperStringUtil.netUrl(API_BOB_URL + CancelOrder, param)
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
    static func UpLoadAppealRequest(code:String,
                                    representationDetails:String,
                                    screenshot:String,
                                    completionHandler: @escaping CompletionHandler) {
        if !NetworkStatus.isReacheable {
            return
        }
        ProgressHUD.animate()
        let param = ["code": code,"representationDetails":representationDetails,"screenshot":screenshot] as [String : Any]
        Alamofire.request(API_BOB_URL + UpLoadAppeal, method: .post, parameters: param,encoding: JSONEncoding.default, headers: getHttpHeader()).responseJSON { dataRequest in
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
    static func QueryStatementDetailsRequest(code:String,
                                             valueHandler: @escaping (BoBMineOrderAppealData) -> Void,
                                             completionHandler: @escaping CompletionHandler) {
        if !NetworkStatus.isReacheable {
            return
        }
        ProgressHUD.animate()
        let param = ["code": code] as [String : Any]
        let url = SuperStringUtil.netUrl(API_BOB_URL + QueryStatementDetails, param)
        Alamofire.request(url, method: .post, parameters: param,encoding: JSONEncoding.default, headers: getHttpHeader()).responseJSON { dataRequest in
            ProgressHUD.dismiss()
            if let data = dataRequest.data {
                let strData = String.init(data: data, encoding: String.Encoding.utf8)
                print(strData!)
                if let res = JsonTool.fromJson(strData!, toClass: BoBBuyAndSellResponse<BoBMineOrderAppealData>.self) {
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
    static func QuickBuyCoinRequest(paymentId:String,
                                    payment:String,
                                    amountOrNumber:String,
                                    input:String,
                                    currency:String,
                                    valueHandler: @escaping (String) -> Void,
                                    completionHandler: @escaping CompletionHandler) {
        if !NetworkStatus.isReacheable {
            return
        }
        ProgressHUD.animate()
        let param = ["paymentId": paymentId,"payment":payment,"amountOrNumber":amountOrNumber,"input":input,"currency":currency] as [String : Any]
        let url = SuperStringUtil.netUrl(API_BOB_URL + QuickBuyCoin, param)
        Alamofire.request(url, method: .post, parameters: param,encoding: JSONEncoding.default, headers: getHttpHeader()).responseJSON { dataRequest in
            ProgressHUD.dismiss()
            if let data = dataRequest.data {
                let strData = String.init(data: data, encoding: String.Encoding.utf8)
                print(strData!)
                if let res = JsonTool.fromJson(strData!, toClass: BoBBuyAndSellResponse<String>.self) {
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
    static func QuickSellCoinRequest(paymentId:String,
                                     payment:String,
                                     amountOrNumber:String,
                                     input:String,
                                     currency:String,
                                     currencyWallet:String,
                                     passWord:String,
                                     valueHandler: @escaping (String) -> Void,
                                     completionHandler: @escaping CompletionHandler) {
        if !NetworkStatus.isReacheable {
            return
        }
        ProgressHUD.animate()
        let timestamp = String(Int(Date().timeIntervalSince1970 * 1000))
        let pwd = (IMController.shared.payPassWordSonKey + passWord).md5
        let sign = (paymentId + payment + amountOrNumber + input + currency + currencyWallet + timestamp + pwd).md5
        let param = ["paymentId": paymentId,"payment":payment,"amountOrNumber":amountOrNumber,"input":input,"currency":currency,"currencyWallet":currencyWallet,"timestamp":timestamp,"sign":sign] as [String : Any]
        let url = SuperStringUtil.netUrl(API_BOB_URL + QuickSellCoin, param)
        Alamofire.request(url, method: .post, parameters: param,encoding: JSONEncoding.default, headers: getHttpHeader()).responseJSON { dataRequest in
            ProgressHUD.dismiss()
            if let data = dataRequest.data {
                let strData = String.init(data: data, encoding: String.Encoding.utf8)
                print(strData!)
                if let res = JsonTool.fromJson(strData!, toClass: BoBBuyAndSellResponse<String>.self) {
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
class DailyLimitModel:Decodable {
    var dailyLimitBuy:Double?
    var dailyLimitSell:Double?
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
class BoBMineAdData: Decodable {
    var data: [BoBMineAdList]
    var flag: Bool = false
    var code: Int = 20000
    var message: String? = nil
    var count: Int? = 0
}
class BoBMineAdList: Decodable {
    var advertisingCurrency:String? //币种
    var currencyWallet:Int? //钱包（t0,t1）
    var advertisingType:Int? //广告类型1:出售 2:购买 3:兑换
    var transactionMode:String? //交易方式1:银行卡 2:支付宝 3:微信
    var exchangeRateType:Int? //汇率类型，1:浮动 2:固定
    var setExchangeRate:Double?//设置汇率
    var floatingIndex:Double?//浮动指数
    var surplusQuantity:Double?//数量
    var quotaMin:Double?//最小限额
    var quotaMax:Double?//最大限额
    var termsOfTradeZc:Int? // 注册天数限制
    var advertisingName:String?//广告商名称
    var userId:String?
    var code:String?//广告编号
    var icon:String? //货币图标
    var advertisingState:Int?//1:上架中 2:已下架
}
class IntendedOrderHome: Decodable {
    var icon:String? //货币图标
    var price:Double? //单价
    var quotaMin:Double?//最小限额
    var quotaMax:Double?//最大限
    var surplusQuantity:Double? //广告剩余数量
    var advertisingCurrency:String? //币种
    var advertisingType:Int? //广告类型1:出售 2:购买 3:兑换
    var transactionMode:String? //交易方式1:银行卡 2:支付宝 3:微信
    var timeOfPayment:Int?//付款时限(单位分钟)
    var completed:Int? //已完成次数
    var order30:Int? //30天的成单数
    var transactionRates30:Double? //30天的成单率
    var creationDays:Int? //账户已创建
    var firstTradingTime:Int? //首次交易至今
    var counterparty:Int? //交易对手
    var assemblyNumber:Int? //总成单数
    var buy:Int? // 买入
    var sell:Int? // 卖出
}
class BoBMineOrderListData: Decodable {
    var data: [BoBMineOrderList]
    var flag: Bool = false
    var code: Int = 20000
    var message: String? = nil
    var count: Int? = 0
}
class BoBMineOrderList: Decodable {
    var orderStatus:Int? //1:等待用户付款 2:等待商家确认 3:已完成 4:用户取消 5:商家取消 6:等待商家付款 7:等待用户确认 8:等待卖家接单 9:等待买家接单 10:已超时
    var beginTime:String? //开始时间时间戳
    var orderTakingTimeLimit:Int?//接单时间限制 单位:分
    var advertisingNameBuy:String?//广告商名称买家
    var advertisingNameSell:String?//广告商名称卖家
    var transactionType:Int? //交易类型 1:出售 2:购买 3:兑换
    var currency:String? //币种
    var orderNumber:String? //订单号
    var amount:Double? //付款金额
    var price:Double?//单价
    var quantity:Double? //数量
    var payment:Int? //支付方式 1:银行卡 2:支付宝 3:微信
    var payer:String? //付款人姓名
    var payDetails:String? //支付方式详情
    //    var payDetails:paymentDdetailData? //支付方式详情
    var paymentMethodDetails:paymentDdetailData?
    var creationTime:String? //创建时间
    var paymentTime:String? //付款时间
    var completionTime:String? //完成时间
    var cancellationTime:String? //取消时间
    var paymentCredentials:String? // 支付凭证
    var buyOrSell:Int? // 用户是买家还是卖家 1买家 2卖家
    var icon:String? //币种图标
    var representationType:Int?//申述状态 0:没有申诉  1:申述中 2:申述完成
    var countdownTime:Int?//d倒计时时间
    var representationTypeOther:Int?//对方申述状态 1:申述中 2:申述完成
    
    var creatTime:String{
        getTransformTime(time: creationTime ?? "")
    }
    var payTime:String{
        getTransformTime(time: paymentTime ?? "")
    }
    var completeTime:String{
        getTransformTime(time: completionTime ?? "")
    }
    var canceTime:String{
        getTransformTime(time: cancellationTime ?? "")
    }
}
class BoBMineOrderAppealData: Decodable {
    var code: String?//订单号
    var statementDetailsBuyPO: BoBMineOrderAppealDetail?//买家详情
    var statementDetailsSellPO: BoBMineOrderAppealDetail?//卖家详情
}
class BoBMineOrderAppealDetail: Decodable {
    var representationDetails: String?
    var screenshot: String?
    var resultPresentation: String?
}

