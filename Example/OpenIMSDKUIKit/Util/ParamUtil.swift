//
//  ParamUtil.swift
//  MyCloudMusic
//
//  Created by mac on 2024/4/25.
//

import Foundation

//导入JSON解析框架
import HandyJSON

//导入网络框架
import Moya

class ParamUtil {
    /// 返回JSON编码的参数
    static func jsonRequestParamters(_ parameters:[String:Any]) -> Task {
        return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
    }
    
    /// 返回URL编码的参数
    static func urlRequestParamters(_ parameters:[String:Any]) -> Task {
        return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
    }
}
