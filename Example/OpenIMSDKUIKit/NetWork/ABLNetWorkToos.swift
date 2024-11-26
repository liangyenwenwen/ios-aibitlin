//
//  ABLNetWorkToos.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/10/30.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Foundation
import Alamofire
import ProgressHUD
import OUICore

enum MethodType {
    case get
    case post
}
//一次封装
class ABLNetWorkToos {
    
    /// 请求方法 返回值JSON
    ///
    /// - Parameters:
    ///   - type: 请求类型
    ///   - URLString: 链接
    ///   - params: 参数
    ///   - success: 成功的回调
    ///   - failture: 失败的回调
    class func request(_ type : MethodType = .post, url : String, params : [String : Any]?,isLoading: Bool = false, isAletError: Bool = true,headers: HTTPHeaders? = nil,success : @escaping (_ data : String)->(), failure : ((Int?, String) ->Void)?) {
        // 1.获取类型
        let method = type == .get ? HTTPMethod.get : HTTPMethod.post
        // 2.发送网络请求
        if isLoading == true{
            ProgressHUD.animate()
        }
        var httpHeaders = headers ?? HTTPHeaders()
        httpHeaders["language"] = String.getCurrentLanguageHeader()
        httpHeaders["operationID"] = String(Int(NSDate().timeIntervalSince1970))
        
        Alamofire.request(url, method: method, parameters: params, encoding: JSONEncoding.default, headers: httpHeaders).validate().responseString { (response: DataResponse<String>) in
//            if isLoading == true{
                ProgressHUD.dismiss()
//            }
            switch response.result {
            case .success(let result):
                if let res = JsonTool.fromJson(result, toClass: BaseModel.self) {
                    var resultCode:Int
                    if res.errCode != nil{
                        resultCode = res.errCode!
                    }else{
                        resultCode = res.code!
                    }
                    switch (resultCode) {
                    case 0,20000:
                        //数据返回正确
                        success(result)
                        
                    default:
                        //其他错误
                        if(isAletError){
                            SuperToast.show(title: String(resultCode).localized())
                        }
                        failure?(resultCode,String(resultCode).localized())
                    }
                } else {
                    let err = JsonTool.fromJson(result, toClass: DemoError.self)
                    SuperToast.show(title: err?.errMsg)
                    failure?(err?.errCode,err?.errMsg ?? "")
                }
            case .failure(let err):
                SuperToast.show(title: err.localizedDescription)
                failure?(-1,String("-1").localized())
            }
        }
    }
            
}
//二次封装
extension ABLNetWorkToos{
    
    /// GET 请求 返回JSON
    ///
    /// - Parameters:
    ///   - URLString: 请求链接
    ///   - params: 参数
    ///   - success: 成功的回调
    ///   - failture: 失败的回调
    class func BussinessGET(url : String, params : [String : Any]?,isLoading: Bool = false, isAletError: Bool = true,headers: HTTPHeaders? = nil,success : @escaping (_ data : String)->(), failure : ((Int?, String) ->Void)?) {
        let newUrl = UserDefaults.standard.string(forKey: bussinessSeverAddrKey)! + url
        ABLNetWorkToos.request(.get, url: newUrl, params: params,isLoading:isLoading,isAletError:isAletError,headers: headers,success: success, failure: failure)

    }
    
    
    /// POST 求情
    ///
    /// - Parameters:
    ///   - URLString: 请求链接
    ///   - params: 参数
    ///   - success: 成功的回调
    ///   - failture: 失败的回调
    class func BussinessPOST(url : String, params : [String : Any]? ,isLoading: Bool = false, isAletError: Bool = true,headers: HTTPHeaders? = nil,success : @escaping (_ data : String) ->(), failure : ((Int?, String) ->Void)?) {
//        let newUrl = UserDefaults.standard.string(forKey: bussinessSeverAddrKey)! + url
        ABLNetWorkToos.request(.post, url: url, params: params,isLoading:isLoading,isAletError:isAletError,headers: headers,success: success, failure: failure)
    }
    
    
}
struct BaseModel: Decodable {
    let errCode: Int?
    let code: Int?
}


