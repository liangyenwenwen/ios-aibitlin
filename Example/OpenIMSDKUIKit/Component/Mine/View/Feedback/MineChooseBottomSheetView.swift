//
//  MineReportBottomSheetView.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/5/15.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import MMBAlertsPickers
import OUICore
import ProgressHUD
import RxCocoa
import RxSwift
import TangramKit
import UIKit

class MineChooseBottomSheetView: TGLinearLayout {
    var chooseTitle: ((String) -> ())!
    var reportBlock: ((String) -> ())?
    var userID: String?
    var isFriend: Bool = false
    var conversationInfo: ConversationInfo?
    var currentController: UIViewController?
    
    /// 置顶聊天设置
    var chatTopView: SuperSettingView?
    init() {
        super.init(frame: .zero, orientation: .vert)
        innerInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        innerInit()
    }
    
    func innerInit() {
        corner(MEDDLE_RADIUS)
        tg_width.equal(.fill)
        tg_height.equal(.wrap)
        tg_space = PADDING_MEDDLE
        tg_gravity = .horz.center
        tg_padding = UIEdgeInsets(top: PADDING_OUTER, left: PADDING_OUTER, bottom: PADDING_MEDDLE, right: PADDING_OUTER)
        backgroundColor = .colorBackgroundAPP
        
        addSubview(topView)
//        addSubview(tipslbl)
        
        addSubview(topContainer)
        addSubview(centerContainer)
    }
    
    lazy var topView: TGLinearLayout = {
        let r = TGLinearLayout(.horz)
        r.tg_width.equal(.fill)
        r.tg_height.equal(.wrap)
        r.tg_gravity = .vert.center
        r.tg_space = 7
        r.addSubview(userIcon)
        r.addSubview(titleLbl)
        r.addSubview(closeBtn)
        return r
    }()
    
    
    lazy var userIcon: UIImageView = {
        let r = UIImageView()
        r.tg_width.equal(24)
        r.tg_height.equal(24)
        r.corner(4)
//        r.backgroundColor = .red
        return r
    }()
    
    lazy var titleLbl: UILabel = {
        let r = ViewFactoryUtil.customTilteLabelFill("选择举报该账号的原因".localized(), font: 16, textColor: .colorOnBackground)
        r.font = UIFont(name: "PingFangSC-Medium", size: 16)
        r.numberOfLines = 1
        return r
    }()
    
    lazy var closeBtn: QMUIButton = {
        let r = ViewFactoryUtil.imageBtn(R.image.close_cirle_icon()!, 28)
        r.rx.tap.subscribe(onNext: {
            GKCover.hide()
        })
        .disposed(by: rx.disposeBag)
        return r
    }()

    lazy var topContainer: TGLinearLayout = {
        let r = TGLinearLayout(.vert)
        r.tg_width.equal(.fill)
        r.tg_height.equal(.wrap)
        r.backgroundColor = .white
        r.corner()
        r.hide()
        return r
    }()
    
    lazy var centerContainer: TGLinearLayout = {
        let r = TGLinearLayout(.vert)
        r.tg_width.equal(.fill)
        r.tg_height.equal(.wrap)
        r.backgroundColor = .white
        r.corner()
        r.hide()
        return r
    }()
    
    /// 举报弹窗
    func addReportUI() {
        topContainer.show()
        let titleArr = ["发布不适当内容对我造成骚扰".localized(), "钱财欺诈".localized(), "怀疑账号被盗用".localized(), "其他".localized()]
        for i in titleArr.indices {
            let settingView = SuperSettingView.onlylTitle(titleArr[i]) { [weak self] _ in
                self?.chooseTitle(titleArr[i])
            }
            settingView.isMediumFont(15)
            topContainer.addSubview(settingView)
            if i != titleArr.count - 1 {
                topContainer.addSubview(ViewFactoryUtil.smallDivider())
            }
        }
    }
    
    /// 用户信息弹窗
    func addUserMessageUI() {
        
        IMController.shared.getConversation(sessionType: .c2c, sourceId: userID!) { [weak self] (conversation: ConversationInfo?) in
            guard let conversation else { return }
            
            let userShowname = SuperStringUtil.getUserShowname(showname: conversation.showName ?? "")
            
            self?.conversationInfo = conversation
            self?.titleLbl.text = userShowname
            self?.userIcon.show(conversation.faceURL)

        }
        
        topContainer.show()

//        tipslbl.show()
        let titleArr = ["ModifyRemarks".localized()]
        for i in titleArr.indices {
            let settingView = SuperSettingView.createNoromalView(titleArr[i]) { [weak self] _ in
                self?.chooseTitle(titleArr[i])
            }
            settingView.isMediumFont(15)
            topContainer.addSubview(settingView)
            if i != titleArr.count - 1 {
                topContainer.addSubview(ViewFactoryUtil.smallDivider())
            }
        }
                
        centerContainer.show()
//        let titleArr2 = ["Block".localized(), "Report".localized(),"解除好友关系".localized()]
        let titleArr2 = isFriend == true ?["Block".localized(), "Report".localized(),"解除好友关系".localized()]:["Block".localized(), "Report".localized()]
        for i in titleArr2.indices {
            // MARK: -    黑名单处理
            if i == 0 {
                let settingView = SuperSettingView.create(title: titleArr2[i]) { _ in
                    
                } switchChanged: { [weak self] data in
                    guard let self = self else {return}
                    if data.isOn {
                        IMController.shared.imManager.add(toBlackList: self.userID!,onSuccess: { message in
                        },onFailure: { errCode, errorMsg in
                            data.isOn = !data.isOn
                        })
                    } else {
                        
                        IMController.shared.imManager.remove(fromBlackList: self.userID! ,onSuccess: { message in
                        },onFailure: { errCode, errorMsg in
                            data.isOn = !data.isOn
                        })
                        
                    }
                }
                settingView.isMediumFont(15)
                centerContainer.addSubview(settingView)
                
                IMController.shared.getBlackList { blackUsers in
                    if blackUsers.contains(where: { info in
                        info.userID == self.userID
                    }) {
                        settingView.superSwitch.isOn = true
                    }
                }
                
                
                
                
                
            } else {
                let settingView = SuperSettingView.onlylTitle(titleArr2[i]) { [weak self] _ in
//                    self?.chooseTitle(titleArr2[i])
                    if i == 2 {
                        self?.currentController?.presentAlert(title: "deletFriendTip".localized()) { [weak self] in
                            self?.deleteFriend()
                            GKCover.hide()
                        }
                        
                    }
                    
                    if i == 1 {
                        self?.reportAction()
                        GKCover.hide()
                    }
                    
                }
                settingView.isMediumFont(15)
                centerContainer.addSubview(settingView)
            }
                    
            if i != titleArr2.count - 1 {
                centerContainer.addSubview(ViewFactoryUtil.smallDivider())
            }
        }
    }
    
    // 删除好友
    func deleteFriend() {
        IMController.shared.deleteFriend(uid: userID ?? "") { [weak self] _ in
            guard let `self` = self else { return }
            IMController.shared.getConversation(sessionType: .c2c, sourceId: userID!) { conv in
                
                guard let conv else { return }
                IMController.shared.deleteConversation(conversationID: conv.conversationID) { _ in
                    
//                    self.currentController?.navigationController?.popToRootViewController(animated: true)
                    self.chooseTitle("解除好友关系".localized())
                }
            }
        }
    }
    
    func reportAction() {
        if reportBlock != nil {
            reportBlock!("")
        }
    }
    
    /// 聊天弹窗
    func addChatVCUI() {
        IMController.shared.getConversation(sessionType: .c2c, sourceId: userID!) { [weak self] (conversation: ConversationInfo?) in
            guard let conversation else { return }
            
            let userShowname = SuperStringUtil.getUserShowname(showname: conversation.showName ?? "")
            
            self?.conversationInfo = conversation
            self?.titleLbl.text = ""
//            self?.titleLbl.text = userShowname
//            self?.userIcon.show(conversation.faceURL)
            self?.chatTopView?.superSwitch.isOn = conversation.isPinned
            print(conversation.conversationID)
        }
        
        topContainer.show()
        titleLbl.text = "用户名".localized()
//        tipslbl.show()
//        let titleArr = ["置顶聊天".localized(), "聊天自动翻译".localized(), "清空聊天记录".localized()]
        let titleArr = ["置顶聊天".localized(), "清空聊天记录".localized()]
        for i in titleArr.indices {
            if i == 0 {
                let settingView = SuperSettingView.create(title: titleArr[i]) { _ in
                    
                } switchChanged: { [weak self] data in
                    if data.isOn {
                        print("置顶聊天")
                    } else {
                        print("取消置顶聊天")
                    }
                    
                    print("adasdasdasd")
                    
                    guard let weakself = self else { return }
                    IMController.shared.pinConversation(id: weakself.conversationInfo?.conversationID ?? "", isPinned: data.isOn, completion: { [weak self] _ in
                        guard let sself = self else { return }
                        sself.changeChatTop(isPinned: data.isOn)
                    })
                }
                
                chatTopView = settingView
                
                settingView.superSwitch.isOn = conversationInfo?.isPinned ?? false
                settingView.isMediumFont(15)
                topContainer.addSubview(settingView)
                
            }else{
                let settingView = SuperSettingView.onlylTitle(titleArr[i]) { [weak self] _ in
//                    self?.chooseTitle(titleArr[i])
                    self?.currentController?.presentAlert(title: "确认清空所有聊天记录吗？".innerLocalized()) {
                        guard let weakself = self else { return }
                        IMController.shared.clearC2CHistoryMessages(conversationID: weakself.conversationInfo?.conversationID ?? "") { [weak self] _ in
                            guard let sself = self else { return }
                            let event = EventRecordClear(conversationId: weakself.conversationInfo?.conversationID ?? "")
                            JNNotificationCenter.shared.post(event)
                            
                            NotificationCenter.default.post(name: Notification.Name("chat.clear.record"), object: nil)
    //                        ProgressHUD.success("清空成功".innerLocalized())
                            SuperToast.show(title: "清空成功".innerLocalized())
                            GKCover.hide()
                        }
                    }
                    
                }
                settingView.isMediumFont(15)
                topContainer.addSubview(settingView)
                
            }
                    
            if i != titleArr.count - 1 {
                topContainer.addSubview(ViewFactoryUtil.smallDivider())
            }
        }
          
        centerContainer.show()
        let titleArr2 = ["Report".localized()]
        for i in titleArr2.indices {
            let settingView = SuperSettingView.onlylTitle(titleArr2[i]) { [weak self] _ in
                self?.chooseTitle(titleArr2[i])
                    
                let vc = YFFeedbackVC()

                vc.reportType = .chatHistory
//                vc.reportID = (self?.userID)!
                vc.conversationItem = self!.conversationInfo
                self?.currentController?.navigationController?.pushViewController(vc)
                GKCover.hideWithoutAnimation()
            }
            settingView.isMediumFont(15)
            centerContainer.addSubview(settingView)
            
        }
    }
    
    func changeChatTop(isPinned: Bool) {
        print(isPinned ? "------置顶" : "--------取消置顶")
        chatTopView?.superSwitch.isOn = isPinned
    }
    
    deinit {
        print(#file)
    }
}

struct bootomChooseItem {
    let title: String
    let isHaveSwitch: Bool
    let ishaveMore: Bool
}
