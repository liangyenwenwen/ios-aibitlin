//
//  ResurceUntil.swift
//  资源类
//
//  Created by mac on 2024/4/26.
//

import Foundation

class ResourceUtil {
    
    ///拼接图片地址
    static func resourceUri(_ data: String) -> String {
        "\(Config.RESOURCE_ENDPOINT)/\(data)"
    }
    
    
}
