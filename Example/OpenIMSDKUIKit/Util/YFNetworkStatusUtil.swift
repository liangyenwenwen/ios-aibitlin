//
//  YFNetworkStatus.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/10/18.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Foundation
import Alamofire
import Network


class NetworkStatus {
    //ji
    static var isReacheable: Bool {
        var res: Bool = false
        let netManager = NetworkReachabilityManager()
        if netManager?.networkReachabilityStatus == .reachable(.ethernetOrWiFi) || netManager?.networkReachabilityStatus == .reachable(.wwan) {
            res = true
        }
        return res
    }
}

extension NetworkStatus {
    /// 基于NWPathMonitor，实时监测网络状态
    static var isNetwork: Bool {
        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "Monitor")
        let semaphore = DispatchSemaphore(value: 0)

        var res: Bool = false

        monitor.pathUpdateHandler = { path in
            res = (path.status == .satisfied)
            semaphore.signal()
        }

        monitor.start(queue: queue)
        semaphore.wait()

        return res
    }
}
