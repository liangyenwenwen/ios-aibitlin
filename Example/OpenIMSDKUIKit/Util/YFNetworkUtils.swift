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
    
    ///获取ip
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
        return address
//        return "1.1.1.1"
    }
    
//    static func getIPAddress() -> String? {
//        var ipAddress: String?
//        
//        let monitor = NWPathMonitor()
//        let queue = DispatchQueue(label: "NetworkMonitor")
//        
//        monitor.pathUpdateHandler = { path in
//            if let ipv4Interface = path.availableInterfaces.filter({ $0.type == .wifi || $0.type == .wiredEthernet }).first,
//               let ipv4Address = ipv4Interface.ipv4Addresses.first
//            {
//                ipAddress = ipv4Address
//            }
//        }
//        
//        monitor.start(queue: queue)
//        
//        return ipAddress
//    }
    
    
//    static func getIPAddress() -> String?  {
//        let task = Process()
//        task.launchPath = "/usr/sbin/ifconfig"
//        task.arguments = ["en0"]
//         
//        let pipe = Pipe()
//        task.standardOutput = pipe
//        task.launch()
//         
//        let data = pipe.fileHandleForReading.readDataToEndOfFile()
//        let output = String(data: data, encoding: .utf8)
//        let lines = output?.components(separatedBy: .newlines)
//         
//        var ipAddress: String?
//        if let lines = lines {
//            for line in lines {
//                if line.contains("inet "),
//                   let range = line.range(of: "inet ") {
//                    let start = line.index(range.upperBound, offsetBy: 1)
//                    let end = line.index(range.upperBound, offsetBy: 14)
//                    ipAddress = String(line[start..<end])
//                    break
//                }
//            }
//        }
//         
//        return ipAddress
//    }
    
    
    /// 获取公共ip
//    static func getPublicIPAddress(completion: @escaping (String?) -> Void) {
//
//            let url = URL(string: "https://httpbin.org/ip")!
//
//            let task = URLSession.shared.dataTask(with: url) { data, response, error in
//
//                if let error = error {
//
//                    print("Error fetching public IP: \(error.localizedDescription)")
//
//                    completion(nil)
//
//                    return
//
//                }
//
//                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
//
//                    print("Invalid response")
//
//                    completion(nil)
//
//                    return
//
//                }
//
//                guard let data = data else {
//
//                    print("No data in response")
//
//                    completion(nil)
//
//                    return
//
//                }
//
//                guard let ipString = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) else {
//
//                    print("Failed to decode IP address")
//
//                    completion(nil)
//
//                    return
//
//                }
//
//                guard let jsonData = ipString.data(using: .utf8) else { return  }
//
//                do {
//
//                        if let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
//
//                           let origin = jsonObject["origin"] as? String {
//
//                            completion(origin)
//
//                        }
//
//                    } catch {
//
//                        print(error)
//
//                    }
//
//            }
//
//            task.resume()
//
//        }
    static func getPublicIP(completion: @escaping (String?) -> Void) {
        let url = URL(string: "https://httpbin.org/ip")!
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let ip = json["origin"] as? String {
                    completion(ip)
                } else {
                    completion(nil)
                }
            } catch {
                completion(nil)
            }
        }
        task.resume()
    }

    
}
