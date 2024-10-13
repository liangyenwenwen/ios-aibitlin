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
    
    /// 获取用户的信息  博客 公司 vip 名字
    static func getUserState(showname: String) -> UserState {
        guard let jsonData = showname.data(using: .utf8) else { return UserState(b: 0, e: 0, v: 0, n: showname)}
        do {
            let user = try JSONDecoder().decode(UserState.self, from: jsonData)
            return user
        } catch {
            return  UserState(b: 0, e: 0, v: 0, n: showname)
        }
    }
    
    static func getUserShowname(showname: String) -> String  {
        let user = getUserState(showname: showname)
        return user.n
    }
    /// 获取用户的tag
    static func getUserTag(showname: String) -> String? {
        guard let jsonData = showname.data(using: .utf8) else { return nil}
        do {
            let user = try JSONDecoder().decode(UserState.self, from: jsonData)
            var reslut = ""
            if user.v > 0 {
                reslut.append("V\(user.v)")
            }
            
            if user.b > 0 {
                reslut.append(reslut.count == 0 ? "\("博客".localized())" : "、\("博客".localized())")
            }
            
            if user.e > 0 {
                reslut.append(reslut.count == 0 ? "\("企业".localized())" : "、\("企业".localized())")
            }
            
            return reslut.count == 0 ? nil : "[\(reslut)]"
        } catch {
            return  nil
        }
    }
    
}


struct UserState: Codable {
    let b: Int
    let e: Int
    let v: Int
    let n: String
}
