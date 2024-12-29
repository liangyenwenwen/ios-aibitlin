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
        OIMApi.gotoBoBDetailHandle = { (vc, code, completion: @escaping (String) -> Void) in
          
            let orderDetailVC = BoBOrderDetailViewController()
            orderDetailVC.code = code
            vc.gotoController(orderDetailVC)
            
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
        //扫码去外部转账
        OIMApi.gotoBoBTransferAccountsHandle = {(vc, address, completion: @escaping (String) -> Void) in
            let boBTransferAccountsVC = BoBTransferAccountsViewController()
            boBTransferAccountsVC.hidesBottomBarWhenPushed = true
            boBTransferAccountsVC.address = address
            vc.gotoController(boBTransferAccountsVC)
        }
        
        //聊天去转账
        OIMApi.sendBoBTransferAccountsHandle = {(vc, receiveUserId, groupId,completion: @escaping (String) -> Void) in
            let sendChatTransferAccountsVC = BoBSendChatTransferAccountsViewController()
            sendChatTransferAccountsVC.receiveUserId = receiveUserId
            sendChatTransferAccountsVC.groupId = groupId
            sendChatTransferAccountsVC.sendTransferAccountsAction = {transferAccountsJson in
                completion(transferAccountsJson)
                
            }
            sendChatTransferAccountsVC.hidesBottomBarWhenPushed = true
            vc.gotoController(sendChatTransferAccountsVC)
        }
        //聊天去发红包
        OIMApi.sendBoBRedPacketHandle = {(vc, receiveUserId, groupId,groupMemberCount,completion: @escaping (String) -> Void) in
            let sendRedPacketVC = BoBSendRedPacketViewController()
            sendRedPacketVC.receiveUserId = receiveUserId
            sendRedPacketVC.groupId = groupId
            sendRedPacketVC.groupMemberCount = groupMemberCount
            sendRedPacketVC.sendRedPacketAction = {redPacketJson in
                completion(redPacketJson)
                
            }
            sendRedPacketVC.hidesBottomBarWhenPushed = true
            vc.gotoController(sendRedPacketVC)
        }
        //点击领取红包
        OIMApi.gotoReceiveRedPacketHandle = {(vc, scour,completion: @escaping (String) -> Void) in
            if let redPacketStatus = JsonTool.fromJson(scour, toClass: RedPacketMessageStatus.self) {
                let status = Int(redPacketStatus.localEx ?? "0")
                if redPacketStatus.data?.sendUserId == IMController.shared.uid{
                    //自己发的
                    if status == 0 && redPacketStatus.data?.redPacketType != 0 && redPacketStatus.data?.redPacketType != 3{
                        receiveRedpacket(vc: vc, scour: redPacketStatus,completion:completion)
                    }else{
                        //直接进列表
                        let redPacketDetailVC = BoBReceiveRedPacketDetailViewController()
                        redPacketDetailVC.redPacketMessage = redPacketStatus
                        redPacketDetailVC.updateRedPacketStatus = {status1 in
                            if status1 != redPacketStatus.localEx ?? "0"{
                                completion(status1)
                            }
                        }
                        redPacketDetailVC.hidesBottomBarWhenPushed = true
                        vc.gotoController(redPacketDetailVC)
                    }
                }else{
                    if status == 0{
                        //未领取
                        if redPacketStatus.data?.redPacketType == 3{
                            //群专属红包
                            if redPacketStatus.data?.receiverId == IMController.shared.uid{
                                //领取专属红包
                                receiveRedpacket(vc: vc, scour: redPacketStatus,completion:completion)
                            }else{
                                //不是自己的专属红包不能领，弹框提醒
                                let redPacketTipView = BoBRedPacketTipView()
                                redPacketTipView.tg_width.equal(293)
                                redPacketTipView.tg_height.equal(200)
                                redPacketTipView.bindData(redPacketInfo: redPacketStatus)
                                GKCover.cover(from: vc.view, contentView: redPacketTipView, style: .translucent, showStyle: .center, showAnimStyle: .bottom, hideAnimStyle: .bottom, notClick: false)
                                
                            }
                            
                        }else{
                          //直接领取红包
                            receiveRedpacket(vc: vc, scour: redPacketStatus,completion:completion)
                        }
                    }else if status == 1{
                        //已领取，直接进详情列表
                        let redPacketDetailVC = BoBReceiveRedPacketDetailViewController()
                        redPacketDetailVC.redPacketMessage = redPacketStatus
                        redPacketDetailVC.hidesBottomBarWhenPushed = true
                        vc.gotoController(redPacketDetailVC)
                    }else if status == 2{
                        //已过期,弹框提醒
                        
                        receiveRedpacket(vc: vc, scour: redPacketStatus,completion:completion)
                        
                    }else if status == 3{
                        //已领完，弹框提醒
                        receiveRedpacket(vc: vc, scour: redPacketStatus,completion:completion)
                    }
                }
            }
        }
        //点击领取转账
        OIMApi.gotoReceiveTransferAccountsHandle = {(vc, scour,completion: @escaping (String) -> Void) in
            if let transferAccountsStatus = JsonTool.fromJson(scour, toClass: TransferAccountsMessageStatus.self) {
                if transferAccountsStatus.data?.sendUserId == IMController.shared.uid || transferAccountsStatus.data?.receiverId == IMController.shared.uid{
                    //是自己发的或者自己领的
                    let receiveTransferAccountsDetailVC =  BoBReceiveTransferAccountsDetailViewController()
                    receiveTransferAccountsDetailVC.updateTransferAccountsStatus = { status in
                        if status != transferAccountsStatus.localEx ?? "0"{
                            completion(status)
                        }
                        
                    }
                    receiveTransferAccountsDetailVC.hidesBottomBarWhenPushed = true
                    receiveTransferAccountsDetailVC.transferAccountsMessage = transferAccountsStatus
                    vc.gotoController(receiveTransferAccountsDetailVC)
                }else{
                    //不能领的人点击弹框
                    let transferAccountsTipView = BoBRedPacketTipView()
                    transferAccountsTipView.tg_width.equal(293)
                    transferAccountsTipView.tg_height.equal(200)
                    transferAccountsTipView.bindTransferAccountData(transferInfo: transferAccountsStatus)
                    GKCover.cover(from: vc.view, contentView: transferAccountsTipView, style: .translucent, showStyle: .center, showAnimStyle: .bottom, hideAnimStyle: .bottom, notClick: false)
                }
            }
        }
    }
    static func receiveRedpacket(vc:UIViewController,scour:RedPacketMessageStatus,completion: @escaping (String) -> Void){
        let status = Int(scour.localEx ?? "0")
        if status == 0{
            BoBRedPacketModel.GetRedPacketStatusRequest(code: scour.data?.code,groupId: (scour.data?.redPacketType == 0 || scour.data?.redPacketType == 3) ? "000":scour.data?.groupId){data in
                var redPacketStatus = 0
                if data == 1{
                    //已过期
                    redPacketStatus = 2
                }else if data == 2{
                    //已领取
                    redPacketStatus = 1
                }else if data == 3{
                    //未领取
                    redPacketStatus = 0
                }else if data == 4{
                    //已领完
                    redPacketStatus = 3
                }
                if redPacketStatus != 0{
                    completion(String(format: "%d", redPacketStatus))
                    scour.localEx = String(format: "%d", redPacketStatus)
                }
                if redPacketStatus == 2{
                    let redPacketDetailVC = BoBReceiveRedPacketDetailViewController()
                    redPacketDetailVC.redPacketMessage = scour
                    redPacketDetailVC.hidesBottomBarWhenPushed = true
                    vc.gotoController(redPacketDetailVC)
                }else{
                    let receiveRedPacketAlertView = BoBReceiveRedPacketAlertView()
                    receiveRedPacketAlertView.tg_width.equal(kScreenWidth-40)
                    receiveRedPacketAlertView.tg_height.equal(585)
                    receiveRedPacketAlertView.bindData(redPacketInfo: scour)
                    receiveRedPacketAlertView.receiveRedPacketSuccess = { redPacketStaus in
                        GKCover.hide()
                        completion(redPacketStaus)
                        if scour.data?.sendUserId == IMController.shared.uid || redPacketStaus == "1"{
                            let redPacketDetailVC = BoBReceiveRedPacketDetailViewController()
                            redPacketDetailVC.redPacketMessage = scour
                            redPacketDetailVC.hidesBottomBarWhenPushed = true
                            vc.gotoController(redPacketDetailVC)
                        }
                    }
                    GKCover.cover(from: vc.view, contentView: receiveRedPacketAlertView, style: .translucent, showStyle: .center, showAnimStyle: .bottom, hideAnimStyle: .bottom, notClick: false)
                }
                
            } completionHandler:{errCode,errMsg in
                SuperToast.show(title: errMsg)
            }
        }else{
            let receiveRedPacketAlertView = BoBReceiveRedPacketAlertView()
            receiveRedPacketAlertView.tg_width.equal(kScreenWidth-40)
            receiveRedPacketAlertView.tg_height.equal(585)
            receiveRedPacketAlertView.bindData(redPacketInfo: scour)
            receiveRedPacketAlertView.receiveRedPacketSuccess = { redPacketStaus in
                GKCover.hide()
                completion(redPacketStaus)
                if scour.data?.sendUserId == IMController.shared.uid || redPacketStaus == "1"{
                    let redPacketDetailVC = BoBReceiveRedPacketDetailViewController()
                    redPacketDetailVC.redPacketMessage = scour
                    redPacketDetailVC.hidesBottomBarWhenPushed = true
                    vc.gotoController(redPacketDetailVC)
                }
            }
            GKCover.cover(from: vc.view, contentView: receiveRedPacketAlertView, style: .translucent, showStyle: .center, showAnimStyle: .bottom, hideAnimStyle: .bottom, notClick: false)
        }
    }
    
    
    
    // MARK: - 张亚飞打的标记  博客相关
    static func showBoke() {
        
        // MARK: - 张亚飞打的标记 展示博客
        OIMApi.showBokeHandle = { (keywords, completion: @escaping (String) -> Void) in
            print(keywords)
            completion("测试完成")
        }
        
        OIMApi.showBokeSheetHandle = { (vc, completion: @escaping (String) -> Void) in
            
            
            let contentView = YFChatBokeBottomSheetView()
            contentView.tg_width.equal(.fill)
            contentView.tg_height.equal(350)
            contentView.hideSheetView = {
                GKCover.hide()
            }
            contentView.chooseBoke = { item in
//                let result = "\(item.userBlogName)####\(item.userBlogIcon)####\(item.userBlogUrl)####\(item.userBlogIntro)"
                
                let encoder = JSONEncoder()
                do  {
                    let jsondata = try encoder.encode(item.myBlogShowBlogPO)
                    if let jsonString = String(data: jsondata, encoding: .utf8) {
                        print(jsonString)
                        completion(jsonString)
                    }
                } catch {
                    print(error.localizedDescription)
                }

                GKCover.hide()
            }
            GKCover.cover(from: vc.view.window, contentView: contentView, style: .translucent, showStyle: .bottom, showAnimStyle: .bottom, hideAnimStyle: .bottom, notClick: false)
        }
        
        // MARK: - 张亚飞打的标记   博客跳转
        OIMApi.showBokeLinkHandle = { (vc, link, _: @escaping (String) -> Void) in
            print("link ----- \(link)")
            let target = SuperWebController()
            target.uri = link
            vc.navigationController?.pushViewController(target, animated: true)
        }
        
        // MARK: - 张亚飞打的标记   收藏博客
        OIMApi.starBokeLinkHandle = { (jsonString, completion: @escaping (String) -> Void)  in
            
            
            guard let jsonData = jsonString.data(using: .utf8) else {
                        return
            }
                    
            do {
                
                let boke = try JSONDecoder().decode(myBlogShowBlogPOModel.self, from: jsonData)
                YFFileDataUtil.saveOneDataToFile(blogItem: boke)
                
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
