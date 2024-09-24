//
//  Meta.swift
//  分页模型
//
//  Created by mac on 2024/4/25.
//

import UIKit
import HandyJSON

class Meta<T:HandyJSON>: BaseModel {
    /// 真实数据
    var data:[T]?
    
    var total:Int!
    
    var pages:Int!
    
    var size:Int!
    
    var page:Int!
    
    var next:Int?
}
