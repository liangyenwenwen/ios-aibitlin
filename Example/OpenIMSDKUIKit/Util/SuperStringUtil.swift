//
//  SuperStringUtil.swift
//  MyCloudMusic
//
//  Created by mac on 2024/4/27.
//

import Foundation
import SwifterSwift
import CoreLocation

class SuperStringUtil {
    
    // 验证邮箱
    static func isEmail(_ email: String) -> Bool {
        if email.count == 0 {
            return false
        }
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest:NSPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: email)
    }
    
    // 验证手机号
    static func isPhoneNumber(_ phoneNumber: String) -> Bool {
        if phoneNumber.count == 0 {
            return false
        }
        let mobile = "^1([358][0-9]|4[579]|66|7[0135678]|9[89])[0-9]{8}$"
        let regexMobile = NSPredicate(format: "SELF MATCHES %@",mobile)
        if regexMobile.evaluate(with: phoneNumber) == true {
            return true
        } else {
            return false
        }
    }
    
    static func getCurrentLocation() -> String {
        let locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            if let currentLocation = locationManager.location {
//                print("当前经度：\(currentLocation.coordinate.longitude)")
//                print("当前纬度：\(currentLocation.coordinate.latitude)")
                return "\(currentLocation.coordinate.longitude),\(currentLocation.coordinate.latitude)"
            }
        }
        
        return "120.2052342,30.2489634"
    }
    
    ///是否为空
    static func isBlank(_ data: String?) -> Bool {
        var data  = data
        data = data?.trimmed
        return data == nil || data!.isEmpty
    }
    
    ///是否不为空
    static func isNotBlank(_ data: String?) -> Bool {
        !isBlank(data)
    }
    
    
    ///检测网址 并且网址长度低于256
    static func isUrl(_ data: String?, limitLength: Int = 256, showTip: Bool = false) -> Bool {
        let  urlString = data ?? ""
        if urlString.count > limitLength {
            
            return false
        }
        
        guard let url = URL(string: urlString) else {
                return false
        }
            
        let dataDetector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let range = NSRange(location: 0, length: urlString.utf16.count)
        
        let result = dataDetector.firstMatch(in: urlString, options: [], range: range) != nil
        
        if showTip && result == false {
            SuperToast.show(title: "请输入有效网址")
        }
        return result
    }
    
    static func netUrl(_ data: String ,_ paramters:[String: Any]) -> String {
        var string = data + "?"
        for (key, value) in paramters {
            string += "&\(key)=\(value)"
        }
        return string
    }
    
    
    static func getWeekDay (dateTime : String, isFriend: Bool = false, isStranger: Bool = false) -> String {
        let dateFmt =  DateFormatter ()
        dateFmt.dateFormat = "yyyy-MM-dd"
        let date = dateFmt.date(from: dateTime )!
        let calendar = Calendar.current
        let components = calendar.dateComponents([.weekday], from: date)
        var weekDays :[Any] = []
        weekDays = [NSNull.init(),"周日","周一","周二","周三","周四","周五","周六"]
        if isFriend {
            weekDays = [NSNull.init(),"周日好友访客","周一好友访客","周二好友访客","周三好友访客","周四好友访客","周五好友访客","周六好友访客"]
        }
        
        if isStranger {
            weekDays = [NSNull.init(),"周日陌生人访客","周一陌生人访客","周二陌生人访客","周三陌生人访客","周四陌生人访客","周五陌生人访客","周六陌生人访客"]
        }
        
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
