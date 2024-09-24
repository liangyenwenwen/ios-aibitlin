//
//  YFControllerUtil.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/5/9.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import UIKit

class YFControllerUtil {

    ///获取当前控制器
    static func currentVc() ->UIViewController{

        var vc = UIApplication.shared.keyWindow?.rootViewController

        if (vc?.isKind(of: UITabBarController.self))! {
            vc = (vc as! UITabBarController).selectedViewController
        }else if (vc?.isKind(of: UINavigationController.self))!{
            vc = (vc as! UINavigationController).visibleViewController
        }else if ((vc?.presentedViewController) != nil){
            vc =  vc?.presentedViewController
        }

        return vc!

    }
    
    static func back() {
        print(currentVc())
        currentVc().navigationController?.popViewController(animated: true)
    }

   
}
