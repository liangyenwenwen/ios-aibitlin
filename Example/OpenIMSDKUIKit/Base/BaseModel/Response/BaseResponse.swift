//
//  BaseResponse.swift
//  MyCloudMusic
//
//  Created by mac on 2024/4/25.
//

import UIKit

class BaseResponse: BaseModel {
    ///状态码
    var status: Int = 0
    
    /// 错误信息
    var message: String?
    
    
}
