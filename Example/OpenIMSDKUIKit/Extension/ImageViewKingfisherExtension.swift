//
//  ImageViewKingfisherExtension.swift
//  MyCloudMusic
//
//  Created by mac on 2024/4/27.
//

import Foundation
import Kingfisher


extension UIImageView {
    
    ///显示头像
    func showAvator(_ data: String?) {
        show(data, "DefaultAvatar")
    }
    
    ///显示网络图片
    func show(_ data: String?, _ defaultImage: String = "DefaultAvatar") {
//        if SuperStringUtil.isBlank(data) {
//            image = UIImage(named: defaultImage)
//        } else {
//            var newData: String!
//            if data!.starts(with: "http") {
//                newData = data
//            } else {
//                newData = data?.absoluteUri()
//            }
//            
//            showFull(newData)
//        }
        sd_setImage(with: URL(string: data ?? ""), placeholderImage: UIImage(named: defaultImage))
    }
    
    ///绝对路径图片
    func showFull(_ data:String) {
        kf.indicatorType = .activity
        kf.setImage(with: URL(string: data))
    }
}
