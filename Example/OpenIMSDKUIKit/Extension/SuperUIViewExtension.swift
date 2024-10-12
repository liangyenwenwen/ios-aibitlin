//
//  SuperUIViewExtension.swift
//  MyCloudMusic
//
//  Created by mac on 2024/4/27.
//

import Foundation
import UIKit
import TangramKit

extension UIView {
    
    
    /// 设置大圆角
    func largeCorner() {
        corner(SuperConfig.SIZE_LARGE_RADIUS)
    }

    /// 设置圆角
    func corner(_ radius:CGFloat) {
        //裁剪多余的内容
        //例如：给ImageView设置了圆角
        //如果不裁剪多余的内容，就不会生效
        self.clipsToBounds=true
        
        self.layer.cornerRadius=CGFloat(radius)
        
    }
    
    /// 设置圆角
    func corner() {
        corner(MEDDLE_RADIUS)
    }

    /// 显示小的圆角
    /// 这样实现会产生离屏渲染，也就是有性能影响，后面在优化
    func smallCorner() {
        corner(SuperConfig.SIZE_SMALL_RADIUS)
    }
    
    /// 显示边框
    func border(_ color:UIColor, borderWidth: CGFloat = 1, cornerRadius: CGFloat = MEDDLE_RADIUS) {
        
        self.clipsToBounds = true
        
        //边框为1
        self.layer.borderWidth = borderWidth
        
        //边框颜色
        self.layer.borderColor=color.cgColor
        
        self.layer.cornerRadius = cornerRadius
    }
    
    func viewController()->UIViewController? {
        
        var nextResponder: UIResponder? = self
        
        repeat {
            nextResponder = nextResponder?.next
            
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
            
        } while nextResponder != nil
        
        return nil
        
    }
    
    func findController() -> UIViewController! {
            return self.findControllerWithClass(UIViewController.self)
        }
        
        func findNavigator() -> UINavigationController! {
            return self.findControllerWithClass(UINavigationController.self)
        }
        
        func findControllerWithClass<T>(_ clzz: AnyClass) -> T? {
            var responder = self.next
            while(responder != nil) {
                if (responder!.isKind(of: clzz)) {
                    return responder as? T
                }
                responder = responder?.next
            }
            return nil
        }
    
}

// MARK: -  隐藏相关
extension UIView  {
    
    /// 视图隐藏，等价于hidden = true, 但是不会在父视图中占位空白区域
    func hide()  {
        tg_visibility = .gone
    }
    
    /// 视图可见，等价于hidden = false
    func show(_ data:Bool = true) {
        tg_visibility = .visible
    }
    
    ///视图隐藏，等价于hidden = true, 但是会在父布局视图中占位空白区域
    func invisible(){
        tg_visibility = .invisible
    }
    
    ///是否隐藏
    func isShow() -> Bool {
        tg_visibility == .visible
    }
    
    ///切换隐藏显示
    func toggle() {
        if isShow() {
            hide()
        } else {
            show()
        }
    }
}




class SuperConfig {
    static let SIZE_LARGE_RADIUS:CGFloat = 10
    static let SIZE_SMALL_RADIUS:CGFloat = 5
}
