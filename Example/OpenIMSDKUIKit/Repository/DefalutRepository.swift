//
//  DefalutRepository.swift
//  MyCloudMusic
//
//  Created by 张亚飞 on 2024/4/25.
//
//
//import Foundation
//import RxSwift
//import HandyJSON
//import Moya
//
//class DefalutRepository {
//    
//    static let shared = DefalutRepository()
//    
//    private var provider: MoyaProvider<DefaultService>!
//    
////    func like(_ data:[String:Any]) -> Observable<DetailResponse<BaseModel>> {
////        return provider
////                    .rx
////                    .request(.like(data: data))
////                    .filterSuccessfulStatusCodes()
////                    .mapString()
////                    .asObservable()
////                    .mapObject(DetailResponse<BaseModel>.self)
////    }
//    
////    func login() -> Observable<DetailResponse<BaseModel>> {
////        return provider.rx
////    }
//    
//    
//    private  init() {
//        //插件列表
//        var plugins:[PluginType] = []
////        if Config.DEBUG {
////            plugins.append(NetworkLoggerPlugin(configuration: NetworkLoggerPlugin.Configuration(logOptions: .verbose)))
////        }
////        
////        //网络请求加载对话框
////        let networkActivityPlugin = NetworkActivityPlugin { change, target in
////            if change == .began {
////                let targetType = target as! DefaultService
////                switch targetType {
////                case .sheetDetail, .register:
////                    DispatchQueue.main.async {
////                        SuperToast.showLoading()
////                    }
////                default:
////                    break
////                }
////            } else {
////                DispatchQueue.main.async {
////                    SuperToast.hideLoading()
////                }
////            }
////        }
//        
////        plugins.append(networkActivityPlugin)
//        
//        provider = MoyaProvider<DefaultService>(plugins: plugins)
//    }
//    
//}
