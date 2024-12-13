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
//    var currencyAndIconPO:[currencyAndIconPO] //币种
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

