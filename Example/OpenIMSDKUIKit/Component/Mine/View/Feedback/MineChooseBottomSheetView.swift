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
    var conversationInfo: ConversationInfo?
    var currentController: UIViewController?
    
    /// 置顶聊天设置
    var chatTopView: SuperSettingView?
    
    // 翻译
    var translateView: SuperSettingView?
    var currentLanguage: String = "汉语".localized()
    var chooseLanguage: String = "英文".localized()
//    var isCurrentLanguage: Bool = true
    
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
        r.backgroundColor = .red
        return r
    }()
    
    lazy var titleLbl: UILabel = {
        let r = ViewFactoryUtil.customTilteLabelFill("选择举报该账号的原因".localized(), font: 16, textColor: .colorOnBackground)
        r.font = UIFont(name: "PingFangSC-Medium", size: 16)
        return r
    }()
    
//    lazy var tipslbl: UILabel = {
//        let r = ViewFactoryUtil.sectionTilteLbael("ID:")
//        r.tg_top.equal(-5)
//        r.hide()
//        return r
//    }()
    
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
        let titleArr2 = ["删除好友".localized(), "Block".localized(), "Report".localized()]
        for i in titleArr2.indices {
            // MARK: - 张亚飞打的标记  黑名单处理
            if i == 1 {
                let settingView = SuperSettingView.create(title: titleArr2[i]) { _ in
                    
                } switchChanged: { [weak self] data in
                    guard let self = self else {return}
                    if data.isOn {
//                        self?.chooseTitle("加入黑名单")
                        IMController.shared.imManager.add(toBlackList: self.userID!) { r in
                            self.chooseTitle("取消黑名单")
                        }
                        
                    } else {
                        
                        IMController.shared.imManager.remove(fromBlackList: self.userID!, onSuccess: { r in
                            self.chooseTitle("取消黑名单")
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
                    if i == 0 {
                        self?.currentController?.presentAlert(title: "deletFriendTip".localized()) { [weak self] in
                            self?.deleteFriend()
                            GKCover.hide()
                        }
                        
                    }
                    
                    if i == 2 {
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
                    self.chooseTitle("删除好友".localized())
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
            self?.titleLbl.text = userShowname
            self?.userIcon.show(conversation.faceURL)
            self?.chatTopView?.superSwitch.isOn = conversation.isPinned
            print(conversation.conversationID)
            if conversation.ex?.count ?? 0 > 2 {
                self?.chooselanguageView.show()
                self?.translateView?.superSwitch.isOn = true
            }
        }
        
        topContainer.show()
        titleLbl.text = "用户名".localized()
//        tipslbl.show()
        let titleArr = ["置顶聊天".localized(), "聊天自动翻译".localized(), "清空聊天记录".localized()]
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
                
            } else if i == 2 {
                
                
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
                
            } else {
                let settingView = SuperSettingView.create(title: titleArr[i]) { _ in
                    
                } switchChanged: { [weak self] data in
                    if data.isOn {
                        print("翻译")
                    } else {
                        print("取消翻译")
                    }
                    self?.changeTranslate(isTranslate: data.isOn)
                    self?.chooseTitle("reload")
                    UserDefaults.standard.setValue(data.isOn, forKey: (self?.userID!)!)
                    
//                    UserDefaults.standard.value(forKey: <#T##String#>)
                    let ex  = data.isOn ? self?.getConersationEx() : "no"
                    IMController.shared.imManager.setConversationEx(self?.conversationInfo?.conversationID ?? "", ex: ex!, onSuccess: { res in
                        print(res as Any)
                        
                        // MARK: - 张亚飞打的标记  更新chatvc里面的ConversationEx 
                        if let handler = OIMApi.updateConversationEx {
                            handler(ex!, {res in
                                
                            })
                        }
                        
                    }, onFailure: { code, msg in
                        
                    })
                }
                
                translateView = settingView
                
                settingView.isMediumFont(15)
                topContainer.addSubview(settingView)
                topContainer.addSubview(chooselanguageView)
                
//                let isHave = UserDefaults.standard.value(forKey: self.userID!) as? Bool
//                
//                if isHave ?? false {
//                    chooselanguageView.show()
//                    settingView.superSwitch.isOn = true
//                }
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
    
    func changeTranslate(isTranslate: Bool) {
        if isTranslate {
            chooselanguageView.show()
        } else {
            chooselanguageView.hide()
        }
    }
    
    func getConersationEx() -> String {
        var from: String
        var to: String
        if autoLan.title.text == "英文".localized() {
            from = "en"
        } else if autoLan.title.text == "汉语".localized() {
            from = "zh"
        } else  if autoLan.title.text == "泰语".localized() {
            from = "th"
        } else {
            from = "auto"
        }
        
        if chooseLan.title.text == "英文".localized() {
            to = "en"
        } else if chooseLan.title.text == "汉语".localized() {
            to = "zh"
        } else  if chooseLan.title.text == "泰语".localized() {
            to = "th"
        } else {
            to = "en"
        }
        
        return "translate##\(from)##\(to)"
    }
    
    func changeChatTop(isPinned: Bool) {
        print(isPinned ? "------置顶" : "--------取消置顶")
        chatTopView?.superSwitch.isOn = isPinned
    }
    
    deinit {
        print(#file)
    }
    
    // MARK: - 翻译UI
    
    lazy var chooselanguageView: TGLinearLayout = {
        let r = TGLinearLayout(.horz)
        r.tg_gravity = .vert.center
        r.tg_space = PADDING_MEDDLE
        r.addSubview(autoLan)
        r.addSubview(changeLanguageBtn)
        r.tg_padding = UIEdgeInsets(top: 0, left: PADDING_OUTER, bottom: PADDING_OUTER, right: PADDING_OUTER)
        r.addSubview(chooseLan)
        r.tg_height.equal(52)
        r.tg_width.equal(.fill)
        r.hide()
        return r
    }()
        
    lazy var changeLanguageBtn: QMUIButton = {
        let r = ViewFactoryUtil.imageBtn(R.image.change_icon()!, 22)
        r.addTarget(self, action: #selector(changeLangage), for: .touchUpInside)
        return r
    }()
    @objc func changeLangage() {
        let temp = self.currentLanguage
//        print(self.currentLanguage, self.chooseLanguage)
//        print(self.autoLan.title.text, self.chooseLan.title.text)
        
        self.currentLanguage  = self.chooseLanguage
        self.autoLan.title.text = self.chooseLanguage
        
//        print(self.currentLanguage, self.chooseLanguage, temp)
        
        self.chooseLanguage = temp
        self.chooseLan.title.text = temp
        
        let ex = self.getConersationEx()
        IMController.shared.imManager.setConversationEx(self.conversationInfo?.conversationID ?? "", ex: ex, onSuccess: { res in
            print(res as Any)
            
            // MARK: - 张亚飞打的标记  更新chatvc里面的ConversationEx
            if let handler = OIMApi.updateConversationEx {
                handler(ex, {res in
                    
                })
            }
            
        }, onFailure: { code, msg in
            
        })
        
    }
    
    lazy var autoLan: ItemView = {
        let r = ItemView()
        r.title.text = "汉语".localized()
        r.backgroundColor = UIColor(red: 0.919, green: 0.919, blue: 0.919, alpha: 1)
        r.tg_width.equal(.fill)
        r.tg_height.equal(44)
        r.arrowImg.show()
        r.arrowImg.show()
        r.corner(MEDDLE_RADIUS)
        r.tag = 4500
        let tap = UITapGestureRecognizer(target: self, action: #selector(changelanguage(sender:)))
        r.addGestureRecognizer(tap)
        return r
    }()
        
    lazy var chooseLan: ItemView = {
        let r = ItemView()
        r.title.text = "英文".localized()
        r.backgroundColor = UIColor(red: 0.919, green: 0.919, blue: 0.919, alpha: 1)
        r.tg_width.equal(.fill)
        r.tg_height.equal(44)
        r.corner(MEDDLE_RADIUS)
        r.arrowImg.show()
        r.tag = 4501
        let tap = UITapGestureRecognizer(target: self, action: #selector(changelanguage(sender:)))
        r.addGestureRecognizer(tap)
        return r
    }()
        
    @objc func changelanguage(sender: UITapGestureRecognizer) {
       let isCurrentLanguage = sender.view?.tag == 4500
            
        let alert = UIAlertController(title: "选择语言".localized(), message: "选择目标语言".localized(), preferredStyle: .actionSheet)
            
        var frameSizes: [String] = ["英文".localized(), "汉语".localized(), "泰语".localized()]
        frameSizes.remove(at: frameSizes.firstIndex(of: isCurrentLanguage ? chooseLanguage : currentLanguage) ?? 0)
        let pickerViewValues: [[String]] = [frameSizes]
        let pickerViewSelectedValue: PickerViewViewController.Index = (column: 0, row: frameSizes.firstIndex(of: isCurrentLanguage ? currentLanguage : chooseLanguage) ?? 0)
            
        alert.addPickerView(values: pickerViewValues, initialSelection: pickerViewSelectedValue, withSerchBar: false) { [weak self] _, _, index, values in
//            self?.chooseLanguage = values[0][index.row]
            if  isCurrentLanguage {
                self?.autoLan.title.text = values[0][index.row]
                self?.currentLanguage = values[0][index.row]
            } else {
                self?.chooseLan.title.text = values[0][index.row]
                self?.chooseLanguage = values[0][index.row]
            }
//            print(self?.currentLanguage, self?.chooseLanguage)
//            print(self?.autoLan.title.text, self?.chooseLan.title.text)
            
            let ex = self?.getConersationEx()
            IMController.shared.imManager.setConversationEx(self?.conversationInfo?.conversationID ?? "", ex: ex!, onSuccess: { res in
                print(res as Any)
                
                // MARK: - 张亚飞打的标记  更新chatvc里面的ConversationEx
                if let handler = OIMApi.updateConversationEx {
                    handler(ex!, {res in
                        
                    })
                }
                
            }, onFailure: { code, msg in
                
            })
            
        }
            
        // cacel 取消也改变值  defalut 必须选择 alert才会消失
        alert.addAction(title: "Done".localized(), style: .cancel)
        alert.show()
    }
        
    class ItemView: TGLinearLayout {
        init() {
            super.init(frame: .zero, orientation: .horz)
            
            tg_padding = UIEdgeInsets(top: 0, left: PADDING_OUTER, bottom: 0, right: PADDING_OUTER)
            tg_gravity = .vert.center
            addSubview(title)
            addSubview(arrowImg)
        }
        
        @available(*, unavailable)
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        lazy var title: UILabel = {
            let r = ViewFactoryUtil.customTilteLabelFill("自动", font: 16, textColor: .colorOnBackground)
            return r
        }()
        
        lazy var arrowImg: UIImageView = {
            let r = ViewFactoryUtil.defalutImgView(R.image.smallGrayBottomArrow()!, 16)
            r.hide()
            return r
        }()
    }
}

struct bootomChooseItem {
    let title: String
    let isHaveSwitch: Bool
    let ishaveMore: Bool
}
