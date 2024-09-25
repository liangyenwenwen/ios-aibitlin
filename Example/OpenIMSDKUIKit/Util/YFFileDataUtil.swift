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
        
        
    /// 读取全部本地数据
    static  func readDataToFile() -> [blogDetailItem] {
        let path:URL? = filePath
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
    static func saveDataToFile(blogsArr: [blogDetailItem]) -> () {
        let dataWrite = try? JSONEncoder().encode(blogsArr)
        do{
            try dataWrite?.write(to:filePath)
            print("保存成功")
        } catch {
            print("保存到本地文件失败")
        }
    }
        
    static func saveOneDataToFile(blogItem:blogDetailItem) ->() {
        var datas = readDataToFile()
        datas.removeFirst(where: {$0.userBlogName == blogItem.userBlogName && $0.userBlogUrl == blogItem.userBlogUrl})
        datas.insert(blogItem, at: 0)
        saveDataToFile(blogsArr: datas)
    }

    
    static func deleteOneDataFromFile(blogItem: blogDetailItem) -> [blogDetailItem] {
        var datas = readDataToFile()
        datas.removeFirst(where: {$0.id == blogItem.id})
        saveDataToFile(blogsArr: datas)
        return datas
    }
    
    static func deleteAllDataFromFile() ->() {
        var datas:[blogDetailItem] = []
        saveDataToFile(blogsArr: datas)
    }
    
}
