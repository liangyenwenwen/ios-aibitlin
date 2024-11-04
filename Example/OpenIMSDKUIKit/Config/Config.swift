//
//  Config.swift
//  MyCloudMusic
//
//  Created by mac on 2024/4/25.
//

import Foundation

class Config {
    
    /**
     * 是否是调试模式
     * 之所以不直接使用BuildConfig.DEBUG
     * 是因为单独定了一个变量更方便，不用真正更改项目的编译模式
     */
    static let DEBUG = true
    
    /// 本地端点
//    static let ENDPOINT = "http://192.168.50.51:8080/"
    
    /// 我们爱学啊部署好的
    static let ENDPOINT = "http://my-cloud-music-api-sp3-dev.ixuea.com/"
    
    /**
     * 资源端点
     */
    static let RESOURCE_ENDPOINT = "http://course-music-dev.ixuea.com/"
    
    // 阿里云OSS AK
    static let ALIYUN_AK = "LTAI4Fr1njmWpE4E5uGrMtqk"
    
    //阿里云OSS SK
    static let ALIYUN_SK = "XLCBiAGLN1ad1DWUE3ExAux9lxmRue"
    
    //阿里云OSS Bucket
    static let ALIYUN_OSS_BUCKET_NAME = "dev-courses-misuc"
    
    //阿里云OSS Bucket 地址
    //https://help.aliyun.com/document_detail/31837.html
    static let BUCKET_ENDPOINT = "oss-cn-beijing.aliyuncs.com"
    
    //高德地图key
    //获取方法：https://lbs.amap.com/api/ios-sdk/guide/create-project/get-key
    static let AMAP_KEY = "b118833fa0ed59f545a571a1d7c620af"
    
    //pragma mark - 微信
    /**
     * 微信id
     */
    static let WECHAT_AK = "wx672a5ce2ea3a3f4f"

    /**
     * 微信 sk
     */
    static let WECHAT_SK = "04fcd35c088f1bef28af2f1c0bc26654"

    static let MY_UNIVERSAL_LINK = "https://dev-courses-misuc.oss-cn-beijing.aliyuncs.com/mycloudmusic/"
    
    // 用户二维码地址
    //真实项目中一般设置为应用的下载宣传界面，因为目前没有这样的界面，所以就设置为官网地址
    static let USER_QRCODE_URL = "http://www.ixuea.com/?u="
    
    //pragma mark - 聊天
    // 聊天key
    static let IM_KEY = "cpj2xarlct12n"
    
    //ragma mark - 极光
    static let JIGUANG_AK = "ba3f08e44440a942db10b46e"

    static let MY_CHANNEL = "default"
    
    // MARK: - 加解密相关

    /// AES128算法key
    static let AES128_KEY="wqfrwOSH*gN%I2v6"

    /// AES128算法IV
    static let AES128_IV="VO*1sxQO5nDkcMyj"


}
