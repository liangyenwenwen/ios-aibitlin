//
//  TestDataUtil.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/5/18.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import UIKit
import Foundation

class TestDataUtil {

    static var BokeData:[BokeItemStruct] = [
        BokeItemStruct(title: "CSDN", icon: "https://q6.itc.cn/q_70/images03/20240405/7270f230b695441b85fa9374752beab6.jpeg", content: "CSDN", link: "https://blog.csdn.net/", state: .limit),
        BokeItemStruct(title: "B站", icon: "https://q4.itc.cn/q_70/images03/20240405/39ec09deda3a41d79e03897b0fdf68a0.jpeg", content: "bilibili", link: "https://www.bilibili.com/"),
        BokeItemStruct(title: "百度", icon: "https://q7.itc.cn/q_70/images03/20240423/6d236fae5c8f44ed9b60d977f32debb7.jpeg", content: "百度网页", link: "https://www.baidu.com/", state: .refuse),
        BokeItemStruct(title: "CSDN", icon: "https://q8.itc.cn/q_70/images03/20240421/e0a5f758921840449f1561e206243211.jpeg", content: "CSDN", link: "https://blog.csdn.net/"),
        BokeItemStruct(title: "B站", icon: "http://img1.baidu.com/it/u=2551674738,2135379517&fm=253&app=138&f=JPEG?w=800&h=800", content: "bilibili", link: "https://www.bilibili.com/"),
        BokeItemStruct(title: "百度", icon: "https://q2.itc.cn/q_70/images03/20240401/f74179c3516c4f0685dd5c817898520b.jpeg", content: "百度网页", link: "https://www.baidu.com/", state: .wait),
        BokeItemStruct(title: "CSDN", icon: "https://q2.itc.cn/q_70/images03/20240511/14a46b1edda24636b7bd90feca5d547c.jpeg", content: "CSDN", link: "https://blog.csdn.net/"),
        BokeItemStruct(title: "B站", icon: "https://q6.itc.cn/q_70/images03/20240514/edff7fc31d05404cb97be496dd7785d2.jpeg", content: "bilibili", link: "https://www.bilibili.com/", state: .wait),
        BokeItemStruct(title: "百度", icon: "https://nimg.ws.126.net/?url=http%3A%2F%2Fdingyue.ws.126.net%2F2024%2F0404%2F1cfb5634j00sbf8i0002fd200u000u0g007w007w.jpg&thumbnail=660x2147483647&quality=80&type=jpg", content: "百度网页", link: "https://www.baidu.com/"),
        BokeItemStruct(title: "CSDN", icon: "https://k.sinaimg.cn/n/sinakd20110/560/w1080h1080/20230930/915d-f3d7b580c33632b191e19afa0a858d31.jpg/w700d1q75cms.jpg", content: "CSDN", link: "https://blog.csdn.net/"),
        BokeItemStruct(title: "B站", icon: "https://q5.itc.cn/q_70/images03/20240402/3a1b55723376460494a5e0011a9328a2.jpeg", content: "bilibili", link: "https://www.bilibili.com/"),
        BokeItemStruct(title: "百度", icon: "https://q0.itc.cn/q_70/images03/20240409/4f4f7c6d25f940a9b9ae9722adbcf18a.jpeg", content: "百度网页", link: "https://www.baidu.com/"),
    ]

    static var moreBokeItemStruct = BokeItemStruct(title: R.string.localizable.more(), icon: "", content: "百度网页", link: "https://www.baidu.com/")
}

struct BokeItemStruct : Comparable{
    
    static func < (lhs: BokeItemStruct, rhs: BokeItemStruct) -> Bool {
        return lhs.title < rhs.title
    }
    
    static func == (lhs: BokeItemStruct, rhs: BokeItemStruct) -> Bool {
        return lhs.title == rhs.title && lhs.icon == rhs.icon && lhs.content == rhs.content && lhs.link == rhs.link
    }
    
    var title: String
    var icon: String
    var content: String
    var link: String
    var state: BokeType
    
    init(title: String, icon: String, content: String, link: String, state: BokeType = .normal) {
        self.title = title
        self.icon = icon.count > 8 ? icon : "\(link)favicon.ico"
        self.content = content
        self.link = link
        self.state = state
    }
}

enum BokeType {
    case normal
    case wait
    case refuse
    case limit
}
