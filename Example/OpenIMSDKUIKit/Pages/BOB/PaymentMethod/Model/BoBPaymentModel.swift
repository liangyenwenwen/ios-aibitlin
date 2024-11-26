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
    private static let AddPaymentBank = "/wallet/userPayment/addPaymentBank" //添加银行卡支付
    private static let AddPaymentALi = "/wallet/userPayment/addPaymentALi" //添加支付宝支付
    private static let AddPaymentWX = "/wallet/userPayment/addPaymentWX" //添加微信支付


    private static var httpHeaders : HTTPHeaders = [
        "token":UserDefaults.standard.string(forKey: "bussinessTokenKey")!,
        "X-Forwarded-For":IMController.shared.publicIP,
        "Authorization":"eyJ1c2VySW5mbyI6InVzZXJCbG9nWWFuWmhlbmdUb2tlbiJ9",
        "Content-Type":"application/json",
        "operationID":String(Int(Date().timeIntervalSince1970)),
    ]
    //支付方式列表
    static func QueryUserPaymentList(userId: String?,
                                  valueHandler: @escaping (RealNameInfoDataModel) -> Void,
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
                
                if let res = JsonTool.fromJson(strData!, toClass: RealNameInfoResponse<RealNameInfoDataModel>.self) {

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
    //
    static func AddPaymentMethod(
                                 paymentType:Int = 0,
                                 param:[String: Any],
                                  completionHandler: @escaping CompletionHandler) {
        
        
        if !NetworkStatus.isReacheable {
//            SuperToast.show(title: "")
            return
        }
        ProgressHUD.animate()
        var addPaymentAPI = ""
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
        let url = SuperStringUtil.netUrl(API_BOB_URL + addPaymentAPI, param)
        
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
}
