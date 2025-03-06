//
//  YFDeviceID.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2025/3/5.
//  Copyright © 2025 rentsoft. All rights reserved.
//

import Foundation
import KeychainAccess
struct YFDeviceID {

    static let KEYCHAIN_SERVICE:String = "uniim.com"  // 需要项目唯一性，建议使用项目的 bundleId
    static let UUID_KEY:String = "UUID_KEY"
    
    static func getUUID() -> String{
        let keychain = Keychain(service: KEYCHAIN_SERVICE)
        var uuid:String = ""
        do {
            uuid = try keychain.get(UUID_KEY) ?? ""
        }
        catch let error {
            print(error)
        }
        print("拉取的设备： \(uuid)")
        if uuid.isEmpty {
            uuid = UUID().uuidString
            do {
                try keychain.set(uuid, key: UUID_KEY)
            }
            catch let error {
                print(error)
                uuid = ""
            }
        }
        return uuid
    }
}
