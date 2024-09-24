//
//  SuperUIStringExtension.swift
//  MyCloudMusic
//
//  Created by mac on 2024/4/27.
//

import Foundation

extension String {
    
    func absoluteUri() -> String {
        return "\(Config.RESOURCE_ENDPOINT)\(self)"
    }
    
    /// range  转nsrange
    func nsRange(from range: Range<String.Index>) -> NSRange {
            return NSRange(range, in: self)
    }
    
    ///首字母大写
    var upperFirstLetter:String{
            return String(self.prefix(1).capitalized + self.dropFirst())
        }
    
    /// 获取系统当前语言
    static func getCurrentLanguage() -> String {
        // 返回设备曾使用过的语言列表
        let languages: [String] = UserDefaults.standard.object(forKey: "AppleLanguages") as! [String]
        // 当前使用的语言排在第一
        let currentLanguage = languages.first
        return currentLanguage ?? "en-CN"
    }
    
    /// 获取系统当前语言
    static func getCurrentLanguageFirst() -> String {
        // 返回设备曾使用过的语言列表
        let languages: [String] = UserDefaults.standard.object(forKey: "AppleLanguages") as! [String]
        // 当前使用的语言排在第一
        let currentLanguage = languages.first
        var reslut = currentLanguage ?? "en"
        if reslut.starts(with: "zh")  {
            reslut = "zh"
        } else if reslut.starts(with: "th"){
            reslut = "th"
        } else {
            reslut = "en"
        }
        
        return reslut
    }
    
    ///获取当前语言的
    static func getCurrentLanguageHeader() -> String {
        // 返回设备曾使用过的语言列表
        let language = getCurrentLanguage()
        let indexStart = language.startIndex
        let indexZero = language.index(indexStart, offsetBy:0)
        let indexOne = language.index(indexStart, offsetBy:1)
        let subString = language[indexZero...indexOne]
        return String(subString)
    }
    
    static func getWeekdayAbout(timestamp: String) -> String {
        let timestamp: TimeInterval = timestamp.toDouble ?? 0
        let date = Date(timeIntervalSince1970: timestamp)
        let calendar = Calendar.current
        let components = calendar.dateComponents([.weekday], from: date)
         
        let weekDays = [NSNull.init(),"周日","周一","周二","周三","周四","周五","周六"]as [Any]
        if let weekday = components.weekday {
            return weekDays[weekday] as! String
        }
        
        return "未知"
    }
}
