//
//  SuperUIViewControllerExtension.swift
//  MyCloudMusic
//
//  Created by   on 2024/5/7.
//

import Foundation

extension UIViewController {
    
    /// 获取导航控制器
    func getNavigationController() -> UINavigationController {
        var nav = self.navigationController
        if let result = nav {
            return result
        }
        
        let rvc = UIApplication.shared.keyWindow!.rootViewController
        if rvc is UINavigationController {
            nav = (rvc as! UINavigationController)
        }else{
            nav = rvc!.navigationController
        }
        
        return nav!
    }

    /// 启动界面
    func gotoController(_ data:UIViewController.Type) {
        let target = data.init()
        getNavigationController().pushViewController(target, animated: true)
    }
    
    /// 启动界面
    func gotoController(_ data:UIViewController) {
        getNavigationController().pushViewController(data, animated: false)
    }
    
    /// 启动界面首页跳转
    func gotoControllerFromRoot(_ data:UIViewController.Type) {
        let target = data.init()
        target.hidesBottomBarWhenPushed = true
        getNavigationController().pushViewController(target, animated: true)
    }
    
    /// 启动界面首页跳转
    func gotoControllerFromRoot(_ data:UIViewController) {
        data.hidesBottomBarWhenPushed = true
        getNavigationController().pushViewController(data, animated: true)
    }
    
    
    
    
}
