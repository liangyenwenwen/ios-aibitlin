//
//  YFNetworkUtils.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/9/11.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Foundation
import Network

class YFNetworkUtils {
    
    ///获取国内ip
    static func getPublicIP(completion: @escaping (String?,String?) -> Void) {
        let url = URL(string: "https://webapi.sporttery.cn/gateway/position/region/v1.0/multi-level/locateByIp")!
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                getOutPublicIP(completion: completion)
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let value = json["value"] as? [String: Any],
                   let ip = value["ip"] as? String,
                   let address = String(data: data, encoding: .utf8)
                {
                    completion(ip,address.base64Encoded)
                } else {
                    getOutPublicIP(completion: completion)
                }
            } catch {
                getOutPublicIP(completion: completion)
            }
        }
        task.resume()
    }
    ///获取国外ip
    static func getOutPublicIP(completion: @escaping (String?,String?) -> Void) {
        let url = URL(string: "https://hk.ipcelou.com/api/ip")!
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion("","")
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let value = json["data"] as? [String: Any],
                   let ip = value["Remote_addr"] as? String {
                    completion(ip,"")
                } else {
                    completion("","")
                }
            } catch {
                completion("","")
            }
        }
        task.resume()
    }
    
}
