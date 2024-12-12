//
//  SuperUIFontExtension.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/9/9.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Foundation

extension UIFont {
    
    static func regularFont(_ size : CGFloat) -> UIFont {
        return UIFont(name: "PingFangSC-Regular", size: size)!
    }
    
    static func mediumFont(_ size : CGFloat) -> UIFont {
        return UIFont(name: "PingFangSC-Medium", size: size)!
    }
    
    
    static func semiboldFont(_ size : CGFloat) -> UIFont {
        return UIFont(name: "PingFangSC-Semibold", size: size)!
    }
    static func lightFont(_ size : CGFloat) -> UIFont {
        return UIFont(name: "PingFangSC-Light", size: size)!
    }
    
}
