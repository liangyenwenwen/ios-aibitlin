//
//  ExceptionHandleUtil.swift
//  MyCloudMusic
//
//  Created by mac on 2024/4/25.
//

import Foundation

import Moya
import Alamofire

class ExceptionHandleUtil {
    
    /// 网络处理响应
    static func handlerResponse(_ data:BaseResponse? = nil, _ error:Error? = nil)  {
        if error != nil {
            //先处理异常请求
            handlerError(error!)
        } else {
            if let r = data?.message {
                SuperToast.show(title: r)
            } else {
                SuperToast.show(title: R.string.localizable.errorUnknown())
            }
        }
    }
    
    ///处理错误
    static func handlerError(_ error:Error) {
        if let error = error as? MoyaError {
            switch error {
            case .stringMapping(_) :
                SuperToast.show(title: "响应转为字符串错误")
            case .statusCode(let response):
                let code = response.statusCode
                handleHttpError(code)
            case .underlying(let nsError as NSError, _):
                if let almofireError = error.errorUserInfo["NSUnderlyingError"] as? Alamofire.AFError ,
                   let underlyingError = almofireError.underlyingError as? NSError{
                    switch underlyingError.code {
                    case NSURLErrorNotConnectedToInternet:
                        //没有网络
                        SuperToast.show(title: R.string.localizable.networkError())
                    case NSURLErrorTimedOut:
                        //连接超时
                        SuperToast.show(title: R.string.localizable.errorNetworkTimeout())
                    case NSURLErrorCannotFindHost:
                        //域名无法解析
                        SuperToast.show(title: R.string.localizable.errorNetworkUnknownHost())
                    case NSURLErrorCannotConnectToHost:
                        //无法连接到主机
                        SuperToast.show(title: R.string.localizable.errorNetworkUnknownHost())
                    default:
                        SuperToast.show(title: R.string.localizable.errorUnknown())
                    }
                } else {
                    SuperToast.show(title: R.string.localizable.errorUnknown())
                }
            default:
                SuperToast.show(title: R.string.localizable.errorUnknown())
            }
        }
        
        
    }
    
    static func handleHttpError(_ data: Int) {
        switch data {
        case 401:
            SuperToast.show(title: R.string.localizable.errorNetworkNotAuth())
//            AppDelegate.shared.logout()
        case 403:
            SuperToast.show(title: R.string.localizable.errorNetworkNotPermission())
        case 404:
            SuperToast.show(title: R.string.localizable.errorNetworkNotFound())
        case 500...598:
            SuperToast.show(title: R.string.localizable.errorNetworkServer())
        default:
            SuperToast.show(title: R.string.localizable.errorUnknown())
        }
    }

}
