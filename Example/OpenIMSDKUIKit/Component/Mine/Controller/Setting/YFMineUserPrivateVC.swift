//
//  YFMineUserPrivateVC.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/5/13.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import UIKit
import TangramKit
import MMBAlertsPickers

class YFMineUserPrivateVC: BaseTitleController {

    var receiveCount = 0
    var tempCount = 0
    
    override func initViews() {
        super.initViews()
        setBackGroundColor(.colorBackgroundAPP)
        initLinearLayoutSafeArea()
    
        title = "PersonalPrivacy".localized()
        
        container.tg_padding = UIEdgeInsets(top: PADDING_MEDDLE, left: PADDING_MEDDLE, bottom: PADDING_MEDDLE, right: PADDING_MEDDLE)
        container.tg_space = PADDING_OUTER
        
        container.addSubview(titleView(type: 0))
        container.addSubview(findMeView)
  
//        container.addSubview(titleView(type: 1))
//        container.addSubview(messageSetView)
        
        changeCount(receiveCount)
    }
    
    
    lazy var findMeView: TGLinearLayout = {
        let r = TGLinearLayout(.vert)
        r.tg_width.equal(.fill)
        r.tg_height.equal(.wrap)
        r.tg_space = 1
        r.corner(MEDDLE_RADIUS)
        r.backgroundColor = .white
        
        r.addSubview(findByIDView)
        r.addSubview(ViewFactoryUtil.smallDivider())
        r.addSubview(findByNicknameView)
        
        return r
    }()
    
    
    lazy var findByIDView: SuperSettingView = {
        let r = SuperSettingView.create(title: "OTC+IM ID") { data in
            
        } switchChanged: { data in
            
        }
        r.isMediumFont()
        return r
    }()
    
    lazy var findByNicknameView: SuperSettingView = {
        let r = SuperSettingView.create(title: "用户名".localized()) { data in
            
        } switchChanged: { data in
            
        }
        r.isMediumFont()
        return r
    }()

    
    
    
    
    lazy var messageSetView: TGLinearLayout = {
        let r = TGLinearLayout(.vert)
        r.tg_width.equal(.fill)
        r.tg_height.equal(.wrap)
        r.tg_space = 1
        r.corner(MEDDLE_RADIUS)
        r.backgroundColor = .white
        
        r.addSubview(messageCountView)
        r.addSubview(messageDivder)
        r.addSubview(messageCountTiplbl)
        return r
    }()
    
    lazy var messageCountView: SuperSettingView = {
        let r = SuperSettingView.createNoromalView("接收消息总数量:\(receiveCount)") { [weak self] data in
//            self?.changeCount(Int.random(in: 5...2000))
            self?.chooseCount()
        }
        r.corner()
        r.isMediumFont()
        return r
    }()
    
    lazy var messageDivder: UIView = {
        let r = ViewFactoryUtil.smallDivider()
        return r
    }()
    
    lazy var messageCountTiplbl: UILabel = {
        let r = ViewFactoryUtil.customBoldTilteLable("如果你没有回复对方，对方最多能给你发 \(receiveCount) 条消息", font: TEXT_SMALL, textColor: .black666)
        r.tg_left.equal(PADDING_OUTER)
        r.tg_top.equal(PADDING_MEDDLE)
        r.tg_right.equal(PADDING_OUTER)
        r.tg_bottom.equal(PADDING_LARGE2)
        return r
    }()

    
    func titleView(type: Int) -> UILabel {
        let r = ViewFactoryUtil.normalLbael()
        switch type {
        case 0:
            r.text = "WhatWaysCanYouFindMe".localized()
        case 1:
            r.text = "是否接收来自陌生人的消息"
        default:
            r.text = ""
        }
        r.textColor = .lightGray
        r.font = .systemFont(ofSize: TEXT_SMALL)
        return r
    }
    
    deinit {
        print(#function)
    }

    func chooseCount() {
        

        
        let alert = UIAlertController(title: "接收消息数量", message: "最多可以接受陌生人消息数量", preferredStyle: .actionSheet)
        
        let frameSizes: [CGFloat] = (0...5).map { CGFloat($0) }
        let pickerViewValues: [[String]] = [frameSizes.map { Int($0).description }]
        let pickerViewSelectedValue: PickerViewViewController.Index = (column: 0, row: frameSizes.index(of: CGFloat(self.receiveCount)) ?? 0)
        
        alert.addPickerView(values: pickerViewValues, initialSelection: pickerViewSelectedValue, withSerchBar: false) { [weak self] vc, picker, index, values  in
            self?.tempCount = Int(values[0][index.row])!
        }
        
        //cacel 取消也改变值  defalut 必须选择 alert才会消失
        alert.addAction(title: "Done".localized(), style: .cancel) { [weak self] _ in
            self?.changeCount(self?.tempCount)
        }
        alert.show()
    }
    
    
    
    func  changeCount(_ count: Int?) {
        let number = count!
        messageCountView.titleView.text = "接收消息总数量:\(number)"
        messageCountTiplbl.text = "如果你没有回复对方，对方最多能给你发 \(number) 条消息"
        messageCountTiplbl.changeColor(changeColorStr: "\(number)", changeColor: .primaryColor)
        
        if(count == 0) {
            messageDivder.hide()
            messageCountTiplbl.hide()
        } else {
            messageDivder.show()
            messageCountTiplbl.show()
        }
        
        receiveCount = number
    }
}
