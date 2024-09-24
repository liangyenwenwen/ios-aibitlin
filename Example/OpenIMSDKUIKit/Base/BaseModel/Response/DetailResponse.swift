//
//  DetailResponse.swift
//  详情网络请求解析
//
//  Created by mac on 2024/4/25.
//

import UIKit
import HandyJSON

class DetailResponse<T:HandyJSON>: BaseResponse {
    ///真实数据
    var data:T?
    
    init(data: T? = nil) {
        self.data = data
    }
    
    required init() {
        super.init()
    }
}
