//
//  AccountViewModelEx.swift
//  SDK交互自己的界面
//
//  Created by mac on 2024/9/24.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Foundation
import OUICore
import ProgressHUD


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
        //点击公共模版
        OIMApi.clickPublicCustomerMessageHandle = { (vc,messageId,source, type, completion: @escaping (String) -> Void) in
            let dic = try! JSONSerialization.jsonObject(with: source.data(using: .utf8)!) as! [String: Any]
            let hash = dic["hash"] as! String
            var request_data = ""
            var url = ""
            if type == "base"{
                url = dic["url"] as! String
                request_data = dic["request_data"] as! String
            }else if type == "item"{
                if let item = dic["item"] as? [String : Any]{
                    url = item["url"] as! String
                    request_data = item["request_data"] as! String
                }
                
            }else{
                if let bt = dic["bt"] as? [String : Any]{
                    if type == "longBtn",
                       let long = bt["long"] as? [String : Any]{
                        url = long["url"] as! String
                        request_data = long["request_data"] as! String
                    }
                    if type == "leftBtn",
                       let left = bt["left"] as? [String : Any]{
                        url = left["url"] as! String
                        request_data = left["request_data"] as! String
                    }
                    if type == "rightBtn",
                       let right = bt["right"] as? [String : Any]{
                        url = right["url"] as! String
                        request_data = right["request_data"] as! String
                    }
                }
            }
            let param = ["hash":hash,"url":url]
            YFMineNetViewModel.checkPublicCustomerMessageApi(paramters: param) { info in
                if info.action == "get"{
                    ProgressHUD.dismiss()
                    let webVC = YFCustomWebViewController()
                    webVC.appid = info.hash
                    webVC.loadUrl = info.url
                    webVC.messageId = messageId
                    vc.navigationController?.pushViewController(webVC, animated: true)
                }else{
                    let dic1 = try! JSONSerialization.jsonObject(with: request_data.data(using: .utf8)!) as! [String: Any]
                    YFMineNetViewModel.updatePublicCustomerMessageAction(url: info.url ?? "",token:info.token ?? "", paramters: dic1) { _ in
                        
                    } completionHandler: { errCode, errMsg in
                        ProgressHUD.dismiss()
                        SuperToast.show(title: errMsg?.localized())
                    }

                }
            }completionHandler: { errCode, errMsg in
                SuperToast.show(title: errMsg?.localized())
            }
        }
        //获取官方应用聊天快捷工具
        OIMApi.getOfficialBokeHandle = { (completion: @escaping ([[String: String]]) -> Void) in
            var array: [[String: String]] = []
            for item in YFFileDataUtil.readDataToFile(.star) {
                if item.type == 0 || item.type == 1{
                    //官方应用,企业应用
                    for item1 in item.base?.shortcut?.sub ?? [] {
                        array.append(["name":item1.name ?? "","icon":"","iconUrl":item1.logo ?? "","h5Url":(item.base?.info?.url ?? "") + (item1.url ?? ""),"hash":item.hash ?? ""])
                    }
                }
            }
            completion(array)
        }
        //点击聊天底部工具栏自定义工具
        OIMApi.clickChatQuickToolHandle = { (vc,chatInfo,url, hash, completion: @escaping (String) -> Void) in
            let webVC = YFCustomWebViewController()
            webVC.appid = hash
            webVC.loadUrl = url
            webVC.chatInfo = chatInfo
            vc.navigationController?.pushViewController(webVC, animated: true)
        }
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
                let blogDic = ["type":String(item.type!),"uid":item.uid,"hash":item.hash,"pwd":item.base?.info?.pwd,"url":item.base?.info?.url,"logo":item.base?.info?.logo,"mark":item.base?.info?.mark,"name":item.base?.info?.name]
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
        
        OIMApi.showBokeLinkHandle = { (vc, link,hash, _: @escaping (String) -> Void) in
            print("link ----- \(link)")
            let webVC = YFCustomWebViewController()
            webVC.appid = hash
            vc.navigationController?.pushViewController(webVC, animated: true)
        }
        
        // MARK: - 张亚飞打的标记   收藏网站
        OIMApi.starBokeLinkHandle = { (jsonString, completion: @escaping (String) -> Void)  in
            
            
            guard let jsonData = jsonString.data(using: .utf8) else {
                        return
            }
                    
            do {
                
                let boke = try JSONDecoder().decode(BokeElem.self, from: jsonData)
                YFMineNetViewModel.flagBlog(paramters: ["hash":boke.hash ?? "","val":"1"]) { errCode, errMsg in
                    if errCode == 200{
                        SuperToast.show(title: "收藏成功".localized())
                    }else{
                        SuperToast.show(title: errMsg?.localized())
                    }
                }
//                YFFileDataUtil.saveOneDataToFile(blogItem: myBlogShowBlogPOModel.init(myBlogShowBlogPO: boke))
                
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
