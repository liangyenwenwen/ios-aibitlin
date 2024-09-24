//
//  YFSystemMessageSettingVC.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/9/4.
//  Copyright © 2024 rentsoft. All rights reserved.
//


import UIKit
import TangramKit
import RxSwift
import RxCocoa
import OUIIM
import OUICore
import ProgressHUD

class YFSystemMessageSettingVC: BaseTitleController {

    var userID: String?
    var conversationInfo: ConversationInfo?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getConversationInfo()
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    func getConversationInfo() {
        
        print(userID)
        IMController.shared.getConversation(sessionType: .notification, sourceId: userID!) { [weak self] (conversation: ConversationInfo?) in
            guard let conversation else { return }

            self?.conversationInfo = conversation

            
        }
    }
    
    override func initViews() {
        super.initViews()
        setBackGroundColor(.colorBackgroundAPP)
        initLinearLayoutSafeArea()
    
        title = "系统通知设置".localized()
        
        container.tg_padding = UIEdgeInsets(top: PADDING_OUTER, left: PADDING_MEDDLE, bottom: PADDING_MEDDLE, right: PADDING_MEDDLE)
        container.tg_space = PADDING_OUTER
        
        container.addSubview(ViewFactoryUtil.sectionTilteLbael(R.string.localizable.basicInformation()))
        container.addSubview(settingView)
        
    }
    
    
    func updateUI() {
        

    }
    
    lazy var settingView: TGLinearLayout = {
        let r = TGLinearLayout(.vert)
        r.tg_width.equal(.fill)
        r.tg_height.equal(.wrap)
        r.tg_space = 1
        r.corner(MEDDLE_RADIUS)
        r.backgroundColor = .white
        
        r.addSubview(reveiveMessageSwitch)
        r.addSubview(ViewFactoryUtil.smallDivider())
        r.addSubview(doNotDisturbSwitch)
        r.addSubview(ViewFactoryUtil.smallDivider())
        r.addSubview(upChatSwitch)
        
        return r
    }()
    
    lazy var reveiveMessageSwitch: SuperSettingView = {
        
        let r = SuperSettingView.create(title: "接收系统通知".localized()) { _ in
            
        } switchChanged: { [weak self] data in
            
            if data.isOn {
                print("接收系统通知")
            } else {
                print("取消接收系统通知")
            }
            

        }
        
        return r
    }()
    
    lazy var doNotDisturbSwitch: SuperSettingView = {
        
        let r = SuperSettingView.create(title: "免打扰".localized()) { _ in
            
        } switchChanged: { [weak self] data in
            
            if data.isOn {
                print("免打扰")
            } else {
                print("取消免打扰")
            }
            

        }
        
        return r
    }()
    
    lazy var upChatSwitch: SuperSettingView = {
        
        let r = SuperSettingView.create(title: "消息置顶".localized()) { _ in
            
        } switchChanged: { [weak self] data in
            
            if data.isOn {
                print("置顶聊天")
            } else {
                print("取消置顶聊天")
            }
            
            guard let weakself = self else { return }
            IMController.shared.pinConversation(id: self!.userID ?? "", isPinned: data.isOn, completion: { [weak self] _ in
                guard let sself = self else { return }
                sself.changeChatTop(isPinned: data.isOn)
            })

        }
        
        return r
    }()
    
    func changeChatTop(isPinned: Bool) {
        print(isPinned ? "------置顶" : "--------取消置顶")
        upChatSwitch.superSwitch.isOn = isPinned
    }
    
}

//            guard let weakself = self else { return }
//            IMController.shared.pinConversation(id: weakself.conversationInfo?.conversationID ?? "", isPinned: data.isOn, completion: { [weak self] _ in
//                guard let sself = self else { return }
//                sself.changeChatTop(isPinned: data.isOn)
//            })
