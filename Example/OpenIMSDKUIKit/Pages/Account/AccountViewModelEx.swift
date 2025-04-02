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
    
    static func initInteraction() {
        IMGotoAppVC()
        showBoke()
        showTip()
        showViewTip()
    }
    
    
    
    // MARK: - 张亚飞打的标记  业务交互 跳转
    static func IMGotoAppVC() {
       
        OIMApi.gotoUserMessageHandle = {(vc, userid, nickName, faceUrl, completion: @escaping (String) -> Void) in
            
//            if  userid != IMController.shared.uid {
                let messageVC = UserMessageVC()
                messageVC.hidesBottomBarWhenPushed = true
                messageVC.userID = userid
                messageVC.userInfo?.nickname = nickName
                messageVC.userInfo?.faceURL = faceUrl
                messageVC.userInfo?.userID = userid
                vc.gotoController(messageVC)
//            }
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
            GKCover.cover(from: vc.view, contentView: contentView, style: .translucent, showStyle: .bottom, showAnimStyle: .bottom, hideAnimStyle: .bottom, notClick: false)
            
        }
        
        OIMApi.gotoSystemSettingHandle = { (vc, userid, completion: @escaping (String) -> Void) in
          
            let settingVC = YFSystemMessageSettingVC()
            settingVC.userID = userid
            vc.gotoController(settingVC)
            
        }
        
        OIMApi.gotoNewFriendHandle = { (vc, completion: @escaping (String) -> Void) in
            vc.gotoControllerFromRoot(YFChatNewFriendListVC.self)
        }
        
        OIMApi.getUserMessageHandle = { (userID, completion: @escaping (String) -> Void) in
            AccountViewModel.queryUserInfo(userIDList: [userID]) { users in
                guard let user: QueryUserInfo = users.first else { return }
                completion(user.nickname ?? "")
            } completionHandler: { errCode, errMsg in
                
            }

        }
        OIMApi.reportMomentsHandle = {(vc, reportUserId, commentID, completion: @escaping (String) -> Void) in
            let feedbackVC = YFFeedbackVC()
            feedbackVC.hidesBottomBarWhenPushed = true
//            feedbackVC.navigationController?.navigationBar.isHidden = true
            feedbackVC.reportType = .moments
            feedbackVC.reportCommentUserId = reportUserId
            feedbackVC.commentID = commentID
            vc.gotoController(feedbackVC)
        }
        
    }
    
    
    
    // MARK: - 张亚飞打的标记  网站相关
    static func showBoke() {
        
        // MARK: - 张亚飞打的标记 展示网站
        OIMApi.showBokeHandle = { (keywords, completion: @escaping (String) -> Void) in
            print(keywords)
            completion("测试完成")
        }
        
        OIMApi.showBokeSheetHandle = { (vc, completion: @escaping (String) -> Void) in
            
            
            let contentView = YFChatBokeBottomSheetView()
            contentView.tg_width.equal(.fill)
            contentView.tg_height.equal(350)
            contentView.refreshTableView()
            contentView.hideSheetView = {
                GKCover.hide()
            }
            contentView.chooseBoke = { item in
//                let result = "\(item.userBlogName)####\(item.userBlogIcon)####\(item.userBlogUrl)####\(item.userBlogIntro)"
                let blogDic = ["uid":item.uid,"hash":item.hash,"pwd":item.base?.info?.pwd,"url":item.base?.info?.url,"logo":item.base?.info?.logo,"mark":item.base?.info?.mark,"name":item.base?.info?.name]
                do  {
                    let jsondata = try JSONSerialization.data(withJSONObject: blogDic, options: .prettyPrinted)
                    if let jsonString = String(data: jsondata, encoding: .utf8) {
                        print(jsonString)
                        completion(jsonString)
                    }
                } catch {
                    print(error.localizedDescription)
                }
//                let encoder = JSONEncoder()
//                do  {
//                    let jsondata = try encoder.encode(item.base)
//                    if let jsonString = String(data: jsondata, encoding: .utf8) {
//                        print(jsonString)
//                        completion(jsonString)
//                    }
//                } catch {
//                    print(error.localizedDescription)
//                }
                GKCover.hide()
            }
            GKCover.cover(from: vc.view.window, contentView: contentView, style: .translucent, showStyle: .bottom, showAnimStyle: .bottom, hideAnimStyle: .bottom, notClick: false)
        }
        
        // MARK: - 张亚飞打的标记   网站跳转
        OIMApi.showBokeLinkHandle = { (vc, link, _: @escaping (String) -> Void) in
            print("link ----- \(link)")
            let target = SuperWebController()
            target.uri = link
            vc.navigationController?.pushViewController(target, animated: true)
        }
        
        // MARK: - 张亚飞打的标记   收藏网站
        OIMApi.starBokeLinkHandle = { (jsonString, completion: @escaping (String) -> Void)  in
            
            
            guard let jsonData = jsonString.data(using: .utf8) else {
                        return
            }
                    
            do {
                
                let boke = try JSONDecoder().decode(blogDetailItem.self, from: jsonData)
//                YFFileDataUtil.saveOneDataToFile(blogItem: myBlogShowBlogPOModel.init(myBlogShowBlogPO: boke))
                SuperToast.show(title: "收藏成功".localized())
            } catch {
                
                return
            }
            
            
//           print(title, icon, url, intro)
//            
//            let id: Int
//            let sign: Int
//            let userBlogUrl: String
//            let userBlogIntro: String
//            let userBlogName: String
//            let userBlogCreatIp: String
//            let userBlogCreatAffiliatingArea: String
//            let userBlogOrder: Int
//            let userId: String
//            let isDelete: Int
//            let creationTime: String
//            let userBlogIcon: String
//            let changeTime: String
//            
//            let item = blogDetailItem(id: -1, sign: 0, userBlogUrl: url, userBlogIntro: intro, userBlogName: title, userBlogCreatIp: "", userBlogCreatAffiliatingArea: "", userBlogOrder: 0, userId: "", isDelete: 0, creationTime: "", userBlogIcon: icon, changeTime: "")
//            
//            YFFileDataUtil.saveOneDataToFile(blogItem: item)
            
        }
        
    }
    
    // MARK: - 张亚飞打的标记  提示
    static func  showTip() {
        OIMApi.showTipHandle = { (tips, _: @escaping (String) -> Void) in
            SuperToast.show(title: tips)
        }
    }
    static func  showViewTip() {
        OIMApi.showTipWithViewHandle = { (view,tips, _: @escaping (String) -> Void) in
            SuperToast.showWithView(view: view, title: tips)
        }
    }
}
