//
//  MineBokeNotificationSettingVC.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/9/6.
//  Copyright © 2024 rentsoft. All rights reserved.
//


import UIKit
import TangramKit
import RxSwift
import RxCocoa
import OUIIM
import OUICore
import ProgressHUD
import MMBAlertsPickers

class MineBokeNotificationSettingVC: BaseTitleController {

    var chooseCount: String = "1"
    var staytime: String = "5"
    var boke : myBlogShowBlogPOModel!

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func initViews() {
        super.initViews()
        setBackGroundColor(.colorBackgroundAPP)
        initLinearLayoutSafeArea()
    
        title = "UserNotifiySetting".localizedFormat(boke.base?.info?.name ?? "")
        
        container.tg_padding = UIEdgeInsets(top: PADDING_MEDDLE, left: PADDING_MEDDLE, bottom: PADDING_MEDDLE, right: PADDING_MEDDLE)
        container.tg_space = PADDING_OUTER
        
        container.addSubview(ViewFactoryUtil.sectionTilteLbael("UserNotifiySetting".localizedFormat("")))
        container.addSubview(accountMessageView)
        
    }
    

  
    
    lazy var accountMessageView: TGLinearLayout = {
        let r = TGLinearLayout(.vert)
        r.tg_width.equal(.fill)
        r.tg_height.equal(.wrap)
        r.tg_space = 1
        r.corner(MEDDLE_RADIUS)
        r.backgroundColor = .white

        r.addSubview(manyTimesView)
        r.addSubview(ViewFactoryUtil.smallDivider())
        r.addSubview(lengthOfStayView)

        
        return r
    }()

    
    lazy var manyTimesView: SuperSettingView = {
        let r = SuperSettingView.createSetTitleAddContentView("访问我的次数达到多少次通知我".localized(), chooseCount) { [weak self] data in
            self!.chooseCountAction()
        }
        r.isMediumFont()
        return r
    }()
    
    lazy var lengthOfStayView: SuperSettingView = {
        let r = SuperSettingView.createSetTitleAddContentView("停留时长超过多少秒通知我".localized(), "SecondsCount".localizedFormat(staytime)) { [weak self] data in
            self!.chooselengthOfStayAction()
        }
        r.isMediumFont()
        return r
    }()
    
    
    
    func chooseCountAction() {
        
        let alert = UIAlertController(title: "访问次数".localized(), message: nil, preferredStyle: .actionSheet)
        let frameSizes = (1...10).map{String($0)}
        let pickerViewValues: [[String]] = [frameSizes]
        let pickerViewSelectedValue: PickerViewViewController.Index = (column: 0, row: frameSizes.firstIndex(of: self.chooseCount) ?? 0)
        
        alert.addPickerView(values: pickerViewValues, initialSelection: pickerViewSelectedValue, withSerchBar: false) { [weak self] vc, picker, index, values  in
            self?.chooseCount = values[0][index.row]
            self?.manyTimesView.contentLbl.text = self?.chooseCount
            
        }
        
        //cacel 取消也改变值  defalut 必须选择 alert才会消失
        alert.addAction(title: "Done".localized(), style: .cancel)
        alert.show()
        
    }
    
    func chooselengthOfStayAction() {
        
        let alert = UIAlertController(title: "停留秒数".localized(), message: nil, preferredStyle: .actionSheet)
        let frameSizes = (1...12).map{String($0 * 5)}
        let pickerViewValues: [[String]] = [frameSizes]
        let pickerViewSelectedValue: PickerViewViewController.Index = (column: 0, row: frameSizes.firstIndex(of: self.chooseCount) ?? 0)
        
        alert.addPickerView(values: pickerViewValues, initialSelection: pickerViewSelectedValue, withSerchBar: false) { [weak self] vc, picker, index, values  in
            self?.staytime = values[0][index.row]
            self?.lengthOfStayView.contentLbl.text = self?.staytime
            
        }
        
        //cacel 取消也改变值  defalut 必须选择 alert才会消失
        alert.addAction(title: "Done".localized(), style: .cancel)
        alert.show()
        
    }
    
}

