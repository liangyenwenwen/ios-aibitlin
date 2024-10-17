//
//  YFFileDataUtil.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/9/24.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Foundation
import OpenIMSDK

enum localBlogType {
    case star
    case recommend
    case cache
}


class YFFileDataUtil {
    
    // 数据存储本地的路径
    static var filePath:URL = {
        let manager = FileManager.default
        var filePath = manager.urls(for: .documentDirectory, in: .userDomainMask).first
        filePath!.appendPathComponent("\(Open_im_sdkGetLoginUserID())blog.archive")
        return filePath!
    }()
    
    static var recommendfilePath:URL = {
        let manager = FileManager.default
        var filePath = manager.urls(for: .documentDirectory, in: .userDomainMask).first
        filePath!.appendPathComponent("\(Open_im_sdkGetLoginUserID())recommendblog.archive")
        return filePath!
    }()
    
    static var cachefilePath:URL = {
        let manager = FileManager.default
        var filePath = manager.urls(for: .documentDirectory, in: .userDomainMask).first
        filePath!.appendPathComponent("\(Open_im_sdkGetLoginUserID())blogCache.archive")
        return filePath!
    }()
        
    static func getBlogPath(_ locaType: localBlogType = .star) -> URL {
        var path: URL? = nil
        switch locaType {
            case .star:
                path = filePath
            case .recommend:
                path = recommendfilePath
            case .cache:
                path = cachefilePath
        }
        return path!
    }
        
    /// 读取全部本地数据
    static  func readDataToFile(_ locaType: localBlogType = .star) -> [blogDetailItem] {
        
        let path = getBlogPath(locaType)
        
        var datas:[blogDetailItem] = []
        if let dataRead = try?  Data(contentsOf:path) {
            
               do{
                   datas = try JSONDecoder().decode([blogDetailItem].self, from: dataRead)
               } catch {
                   print(error)
               }
        } else {
            print("解析出错")
        }
        
        return datas
    }

    // 保存全部数据到本地
    static func saveDataToFile(_ locaType: localBlogType = .star, blogsArr: [blogDetailItem]) -> () {
        let dataWrite = try? JSONEncoder().encode(blogsArr)
        do{
            
            let path = getBlogPath(locaType)
            try dataWrite?.write(to: path)
            print("保存成功")
            
            
        } catch {
            print("保存到本地文件失败")
            
        }
    }
        
    static func saveOneDataToFile(_ locaType: localBlogType = .star, blogItem:blogDetailItem) ->() {
        var datas = readDataToFile(locaType)
        datas.removeFirst(where: {$0.userBlogName == blogItem.userBlogName && $0.userBlogUrl == blogItem.userBlogUrl})
        datas.insert(blogItem, at: 0)
        saveDataToFile(locaType, blogsArr: datas)
    }

    @discardableResult
    static func deleteOneDataFromFile(_ locaType: localBlogType = .star, blogItem: blogDetailItem) -> [blogDetailItem] {
        var datas = readDataToFile(locaType)
        datas.removeFirst(where: {$0.id == blogItem.id})
        saveDataToFile(locaType, blogsArr: datas)
        return datas
    }
    
    static func deleteAllDataFromFile(_ locaType: localBlogType = .star) ->() {
        let datas:[blogDetailItem] = []
        saveDataToFile(locaType, blogsArr: datas)
    }
    
}
