//
//  SuperToast.swift
//  MyCloudMusic
//
//  Created by mac on 2024/4/25.
//

import UIKit
import MBProgressHUD

class SuperToast {
    
    static  var hud:MBProgressHUD?
    
    /// 1.5秒文字提示
    /// - Parameter title: 提示文字
    static func show(title: String?)  {
        let hud = MBProgressHUD.showAdded(to: AppDelegate.shared.window!, animated: true)
        hud.mode = .text
        
        //背景颜色
        hud.bezelView.style = .solidColor
        hud.bezelView.backgroundColor = .black.withAlphaComponent(0.8)
        hud.bezelView.corner(18)
        
        //标题提示文字颜色
        hud.label.textColor = .white
        hud.label.font = .mediumFont(16)
        hud.label.numberOfLines = 0
        hud.label.text = title
        
        hud.label.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(8)
            make.left.right.equalToSuperview().inset(20)
        }
        
        //显示到屏幕顶部
        let offsetY = -hud.frame.height/CGFloat(2) + CGFloat(80)
        hud.offset = CGPoint(x: 0, y: offsetY)
        
        hud.removeFromSuperViewOnHide = true
        hud.hide(animated: true, afterDelay: 1.5)
    }
    
    static func showWithView(view:UIView,title: String?)  {
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.mode = .text
        
        //背景颜色
        hud.bezelView.style = .solidColor
        hud.bezelView.backgroundColor = .black.withAlphaComponent(0.8)
        hud.bezelView.corner(18)
        
        //标题提示文字颜色
        hud.label.textColor = .white
        hud.label.font = .mediumFont(16)
        hud.label.numberOfLines = 0
        hud.label.text = title
        
        hud.label.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(8)
            make.left.right.equalToSuperview().inset(20)
        }
        
        //显示到屏幕顶部
        let offsetY = -hud.frame.height/CGFloat(2) + CGFloat(80)
        hud.offset = CGPoint(x: 0, y: offsetY)
        
        hud.removeFromSuperViewOnHide = true
        hud.hide(animated: true, afterDelay: 1.5)
    }
    
    
    static func showLoading(title:String=R.string.localizable.superLoading()) {
        //菊花颜色
        UIActivityIndicatorView.appearance(whenContainedInInstancesOf: [MBProgressHUD.self]).color = .white
        
//        [UIActivityIndicatorView appearanceWhenContainedInInstancesOfClasses:@[[MBProgressHUD class]]].color = [UIColor whiteColor];

        if (SuperToast.hud == nil) {
            SuperToast.hud = MBProgressHUD.showAdded(to: AppDelegate.shared.window!.rootViewController!.view, animated: true)
            SuperToast.hud!.mode = .indeterminate
            
            //最小尺寸
            SuperToast.hud!.minSize = CGSize(width: 120, height: 120)
            
            //背景半透明
            SuperToast.hud!.backgroundView.style = .solidColor
            SuperToast.hud!.backgroundView.color = UIColor(white: 0, alpha: 0.5)
            
            //背景颜色
            SuperToast.hud!.bezelView.style = .solidColor
            SuperToast.hud!.bezelView.backgroundColor = .black
            
            //标题文字颜色
            SuperToast.hud!.label.textColor = .colorLightWhite
            SuperToast.hud!.label.font = UIFont.boldSystemFont(ofSize: TEXT_LARGE)
            
            //显示对话框
            SuperToast.hud!.show(animated: true)
        }
        
        //设置对话框文字
        SuperToast.hud!.label.text = title
        
        //详细文字
        //progressHUD.detailsLabelText = @"请耐心等待";
    }
    
    static func hideLoading() {
        if let r = SuperToast.hud {
            r.hide(animated: true)
            SuperToast.hud = nil
        }
    }
}
