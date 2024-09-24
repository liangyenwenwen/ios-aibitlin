//
//  DefaultService.swift
//  网络API
//
//  Created by mac on 2024/4/25.
//

import Foundation
import Moya

enum DefaultService {
    //广告列表 首页轮播图 0
    case ads(position: Int)
    
    case login(phone: String? = nil, account: String? = nil, email: String? = nil, psw: String? = nil, verificationCode: String? = nil, areaCode: String)
}

extension DefaultService: TargetType {
    
    //返回网址
    var baseURL: URL {
        return URL(string: Config.ENDPOINT)!
    }
    
    //返回每个请求的路径 
    var path: String {
        switch self {
        case .ads(_):
            return "v1/ads"
        case .login:
            return "/account/login"
        default:
            fatalError()
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .login:
              return  .post
        default:
              return  .get
        }
    }
    
    //请求参数
    var task: Moya.Task {
        switch self {
        case .ads(let position):
            return ParamUtil.urlRequestParamters(["position":position])
        case .login(let phone, let account, let email, let psw, let verificationCode, let areaCode):
            return ParamUtil.urlRequestParamters(["phone":phone, "account":account, "email":email, "psw":psw, "verificationCode":verificationCode, "areaCode":areaCode])
        default:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        var headers: Dictionary<String, String> = [:]
        
        //内容的类型
        headers["Content-Type"] = "application/json"
        
        headers["operationID"] = UUID().uuidString
        
        return headers
    }
    
    
}
