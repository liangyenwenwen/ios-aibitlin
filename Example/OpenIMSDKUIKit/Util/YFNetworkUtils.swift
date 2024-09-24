//
//  YFNetworkUtils.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/9/11.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Foundation


class YFNetworkUtils {
    
    class func getIPAddress() -> String? {
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>? = nil
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while ptr != nil {
                defer { ptr = ptr?.pointee.ifa_next }

                let interface = ptr?.pointee
                let addrFamily = interface?.ifa_addr.pointee.sa_family
                if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {

                    // Check interface name
                    let name = String(cString: interface!.ifa_name)
                    if name == "en0" || name == "en1" || name == "en2" {
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        getnameinfo(interface?.ifa_addr, socklen_t((interface?.ifa_addr.pointee.sa_len)!),
                                    &hostname, socklen_t(hostname.count),
                                    nil, socklen_t(0), NI_NUMERICHOST)
                        address = String(cString: hostname)
                    }
                }
            }
            freeifaddrs(ifaddr)
        }
//        return address
        return "1.1.1.1"
    }
    
    
    
}
