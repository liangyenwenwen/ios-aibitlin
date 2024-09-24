//
//  SuperStringUtil.swift
//  MyCloudMusic
//
//  Created by mac on 2024/4/27.
//

import Foundation
import SwifterSwift

class SuperStringUtil {
    
    ///是否为空
    static func isBlank(_ data: String?) -> Bool {
        var data  = data
        data = data?.trimmed
        return data == nil || data!.isEmpty
    }
    
    //是否不为空
    static func isNotBlank(_ data: String?) -> Bool {
        !isBlank(data)
    }
    
    static func netUrl(_ data: String ,_ paramters:[String: Any]) -> String {
        var string = data + "?"
        for (key, value) in paramters {
            string += "&\(key)=\(value)"
        }
        return string
    }
    
    
    static func getWeekDay (dateTime : String ) -> String {
        let dateFmt =  DateFormatter ()
        dateFmt.dateFormat = "yyyy-MM-dd"
        let date = dateFmt.date(from: dateTime )!
        let calendar = Calendar.current
        let components = calendar.dateComponents([.weekday], from: date)
        let weekDays = [NSNull.init(),"周日","周一","周二","周三","周四","周五","周六"]as [Any]
        if let weekday = components.weekday {
            return weekDays[weekday] as! String
        }
        return "error"
    }
    
}
