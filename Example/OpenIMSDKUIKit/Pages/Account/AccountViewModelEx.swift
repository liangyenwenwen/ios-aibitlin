//
//  AccountViewModelEx.swift
//  SDK交互自己的界面
//
//  Created by mac on 2024/9/24.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Foundation
import OUICore

// MARK: - 张亚飞打的标记  业务交互
extension AccountViewModel {
    
    // MARK: - 张亚飞打的标记  业务交互 跳转
    static func IMGotoAppVC() {
       
        OIMApi.gotoUserMessageHandle = {(vc, userid, nickName, faceUrl, completion: @escaping (String) -> Void) in
            
            if  userid != IMController.shared.uid {
                let messageVC = UserMessageVC()
                messageVC.hidesBottomBarWhenPushed = true
                messageVC.userID = userid
                vc.gotoController(messageVC)
            }
        }
        
        OIMApi.showChatVCShoeethandle = { (vc, userid, completion: @escaping (String) -> Void) in
            
            let contentView = MineChooseBottomSheetView()
            contentView.userID  = userid
            contentView.currentController = vc
            contentView.tg_width.equal(.fill)
            contentView.tg_height.equal(410)
            contentView.addChatVCUI()
            contentView.chooseTitle = { title in
                print(title)
                if title == "reload" {
                    completion("reload")
                }
            }
            GKCover.cover(from: vc.view.window, contentView: contentView, style: .translucent, showStyle: .bottom, showAnimStyle: .bottom, hideAnimStyle: .bottom, notClick: false)
            
        }
        
        OIMApi.gotoSystemSettingHandle = { (vc, userid, completion: @escaping (String) -> Void) in
          
            let settingVC = YFSystemMessageSettingVC()
            settingVC.userID = userid
            vc.gotoController(settingVC)
            
        }
        
        
    }
    
    
    
    // MARK: - 张亚飞打的标记   展示博客
    static func showBoke() {
        OIMApi.showBokeHandle = { (keywords, completion: @escaping (String) -> Void) in
            print(keywords)
            completion("测试完成")
        }
        
        OIMApi.showBokeSheetHandle = { (vc, completion: @escaping (String) -> Void) in
            
            
            let contentView = YFChatBokeBottomSheetView()
            contentView.tg_width.equal(.fill)
            contentView.tg_height.equal(350)
            contentView.chooseBoke = { item in
                let result = "\(item.userBlogName)####\(item.userBlogIcon)####\(item.userBlogUrl)####\(item.userBlogIntro)"
                completion(result)
                GKCover.hide()
            }
            GKCover.cover(from: vc.view.window, contentView: contentView, style: .translucent, showStyle: .bottom, showAnimStyle: .bottom, hideAnimStyle: .bottom, notClick: false)
            
//            let contentView = MineChooseBottomSheetView()
//            contentView.tg_width.equal(.fill)
//            contentView.tg_height.equal(350)
//            contentView.addUserMessageUI()
//            contentView.chooseTitle = { title in
//                print(title)
//                let result = "百度首页####https://img2.baidu.com/it/u=1581581883,3427578739&fm=253&fmt=auto&app=138&f=PNG?w=192&h=192####https://www.baidu.com/"
//                completion(result)
//
//                GKCover.hide()
//            }
//            GKCover.cover(from: vc.view.window, contentView: contentView, style: .translucent, showStyle: .bottom, showAnimStyle: .bottom, hideAnimStyle: .bottom, notClick: false)
        }
        
        // MARK: - 张亚飞打的标记   博客跳转
        OIMApi.showBokeLinkHandle = { (vc, link, _: @escaping (String) -> Void) in
            print("link ----- \(link)")
            let target = SuperWebController()
            target.uri = link
            vc.navigationController?.pushViewController(target, animated: true)
        }
    }
}
