//
//  YFFileDataUtil.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/9/24.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Foundation

class YFFileDataUtil {
    
    // 数据存储本地的路径
    static var filePath:URL = {
        let manager = FileManager.default
        var filePath = manager.urls(for: .documentDirectory, in: .userDomainMask).first
        filePath!.appendPathComponent("blog.archive")
        return filePath!
    }()
    
    static var recommendfilePath:URL = {
        let manager = FileManager.default
        var filePath = manager.urls(for: .documentDirectory, in: .userDomainMask).first
        filePath!.appendPathComponent("recommendblog.archive")
        return filePath!
    }()
        
        
    /// 读取全部本地数据
    static  func readDataToFile(_ isStar: Bool = true) -> [blogDetailItem] {
        let path:URL? = isStar ? filePath : recommendfilePath
        var datas:[blogDetailItem] = []
        if let dataRead = try?  Data(contentsOf:path!) {
               do{
                   datas = try JSONDecoder().decode([blogDetailItem].self, from: dataRead)
               } catch {
                   print(error)
               }
        } else { }
        return datas
    }

    // 保存全部数据到本地
    static func saveDataToFile(_ isStar: Bool = true, blogsArr: [blogDetailItem]) -> () {
        let dataWrite = try? JSONEncoder().encode(blogsArr)
        do{
            try dataWrite?.write(to: isStar ? filePath : recommendfilePath)
            print("保存成功")
        } catch {
            print("保存到本地文件失败")
        }
    }
        
    static func saveOneDataToFile(_ isStar: Bool = true, blogItem:blogDetailItem) ->() {
        var datas = readDataToFile(isStar)
        datas.removeFirst(where: {$0.userBlogName == blogItem.userBlogName && $0.userBlogUrl == blogItem.userBlogUrl})
        datas.insert(blogItem, at: 0)
        saveDataToFile(isStar, blogsArr: datas)
    }

    
    static func deleteOneDataFromFile(_ isStar: Bool = true, blogItem: blogDetailItem) -> [blogDetailItem] {
        var datas = readDataToFile(isStar)
        datas.removeFirst(where: {$0.id == blogItem.id})
        saveDataToFile(isStar, blogsArr: datas)
        return datas
    }
    
    static func deleteAllDataFromFile(_ isStar: Bool = true) ->() {
        var datas:[blogDetailItem] = []
        saveDataToFile(isStar,blogsArr: datas)
    }
    
}
