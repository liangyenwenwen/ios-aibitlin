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
    case mine
    case home
    case history
    case loginAuth
}


class YFFileDataUtil {
    
//     数据存储本地的路径
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
    
    static var homefilePath:URL = {
        let manager = FileManager.default
        var filePath = manager.urls(for: .documentDirectory, in: .userDomainMask).first
        filePath!.appendPathComponent("\(Open_im_sdkGetLoginUserID())blogHome.archive")
        return filePath!
    }()
    static var historyfilePath:URL = {
        let manager = FileManager.default
        var filePath = manager.urls(for: .documentDirectory, in: .userDomainMask).first
        filePath!.appendPathComponent("\(Open_im_sdkGetLoginUserID())blogHistory.archive")
        return filePath!
    }()
    static var loginAuthfilePath:URL = {
        let manager = FileManager.default
        var filePath = manager.urls(for: .documentDirectory, in: .userDomainMask).first
        filePath!.appendPathComponent("\(Open_im_sdkGetLoginUserID())blogLoginAuth.archive")
        return filePath!
    }()

        
    static func getBlogPath(_ locaType: localBlogType = .star) -> URL {
        var path: URL? = nil
        switch locaType {
            case .star:
                path = filePath
            case .recommend:
                path = recommendfilePath
            case .mine:
                path = cachefilePath
            case .home:
                path = homefilePath
        case .history:
                path = historyfilePath
        case .loginAuth:
                path = loginAuthfilePath
        }
        return path!
    }
        
    /// 读取全部本地数据
    static  func readDataToFile(_ locaType: localBlogType = .star) -> [myBlogShowBlogPOModel] {
        
        let path = getBlogPath(locaType)
        
        var datas:[myBlogShowBlogPOModel] = []
        if let dataRead = try?  Data(contentsOf:path) {
            
               do{
                   datas = try JSONDecoder().decode([myBlogShowBlogPOModel].self, from: dataRead)
               } catch {
                   print(error)
               }
        } else {
            print("解析出错")
        }
        
        return datas
    }

    // 保存全部数据到本地
    static func saveAllDataToFile(blogsArr: [myBlogShowBlogPOModel]) -> () {
        var mineBlogs:[myBlogShowBlogPOModel] = []
        var startBlogs:[myBlogShowBlogPOModel] = []
        var recommendBlogs:[myBlogShowBlogPOModel] = readDataToFile(.recommend)
        var homeBlogs:[myBlogShowBlogPOModel] = readDataToFile(.home)
        for item in blogsArr {
            if item.auth == "owner" || item.auth == "admin"{
                mineBlogs.append(item)
            }else if item.auth == "flag"{
                startBlogs.append(item)
            }
            recommendBlogs = recommendBlogs.map { $0.hash == item.hash ? item : $0 }
            homeBlogs = homeBlogs.map { $0.hash == item.hash ? item : $0 }
        }
        for (index,item) in recommendBlogs.enumerated() {
            if !blogsArr.contains(where: {$0.hash == item.hash}){
                recommendBlogs.remove(at: index)
            }
        }
        for (index,item) in homeBlogs.enumerated() {
            if !blogsArr.contains(where: {$0.hash == item.hash}){
                homeBlogs.remove(at: index)
            }
        }
        saveDataToFile(.mine, blogsArr: mineBlogs)
        saveDataToFile(.star, blogsArr: startBlogs)
        saveDataToFile(.recommend, blogsArr: recommendBlogs)
        saveDataToFile(.home, blogsArr: homeBlogs)
    }
    static func saveDataToFile(_ locaType: localBlogType = .star, blogsArr: [myBlogShowBlogPOModel]) -> () {
        let dataWrite = try? JSONEncoder().encode(blogsArr)
        
        do{
            
            let path = getBlogPath(locaType)
            try dataWrite?.write(to: path)
            print("保存成功")
            
            
        } catch {
            print("保存到本地文件失败")
            
        }
    }
        
    static func saveOneDataToFile(_ locaType: localBlogType = .star, blogItem:myBlogShowBlogPOModel) ->() {
        var datas = readDataToFile(locaType)
        datas.removeFirst(where: {$0.hash == blogItem.hash})
        datas.insert(blogItem, at: 0)
        saveDataToFile(locaType, blogsArr: datas)
    }
    
    static func isHaveThisBlog(_ locaType: localBlogType = .star, blogItem:myBlogShowBlogPOModel) -> Bool {
        let datas = readDataToFile(locaType)
        return  datas.contains(where: {$0.hash == blogItem.hash})
    }

    @discardableResult
    static func deleteOneDataFromFile(_ locaType: localBlogType = .star, blogItem: myBlogShowBlogPOModel) -> [myBlogShowBlogPOModel] {
        var datas = readDataToFile(locaType)
        datas.removeFirst(where: {$0.hash == blogItem.hash})
        saveDataToFile(locaType, blogsArr: datas)
        return datas
    }
    
    static func deleteAllDataFromFile(_ locaType: localBlogType = .star) ->() {
        let datas:[myBlogShowBlogPOModel] = []
        saveDataToFile(locaType, blogsArr: datas)
    }
    
    
    
    
    
    
    static  func readH5DataToFile(_ locaType: localBlogType = .history) -> [h5Model] {
        
        let path = getBlogPath(locaType)
        
        var datas:[h5Model] = []
        if let dataRead = try?  Data(contentsOf:path) {
            
               do{
                   datas = try JSONDecoder().decode([h5Model].self, from: dataRead)
               } catch {
                   print(error)
               }
        } else {
            print("解析出错")
        }
        
        return datas
    }
    static func saveOneH5ToFile(_ locaType: localBlogType = .history,item:h5Model) ->() {
        var datas = readH5DataToFile(locaType)
        datas.insert(item, at: 0)
        saveH5DataToFile(locaType, h5Arr: datas)
    }
    static func saveH5DataToFile(_ locaType: localBlogType = .history, h5Arr: [h5Model]) -> () {
        let dataWrite = try? JSONEncoder().encode(h5Arr)
        
        do{
            
            let path = getBlogPath(locaType)
            try dataWrite?.write(to: path)
            print("保存成功")
            
            
        } catch {
            print("保存到本地文件失败")
            
        }
    }
    static func isHaveThisH5Data(_ locaType: localBlogType = .history, item:h5Model) -> Bool {
        let datas = readH5DataToFile(locaType)
        return  datas.contains(where: {$0.data?.hash == item.data?.hash})
    }
}
