//
//  UpdateView.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/11/18.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Foundation
import TangramKit


class UpdateView: TGRelativeLayout {

    var versionData = [String: Any]()
    init(versionData: [String: Any]) {
        super.init(frame: CGRect.zero)
        self.versionData = versionData
        initViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initViews()  {
        
        corner(MEDDLE_RADIUS)
        tg_left.equal(67)
        tg_right.equal(67)
        tg_height.equal(.wrap)
        tg_space = PADDING_MEDDLE
        tg_gravity = .horz.center
        tg_padding = UIEdgeInsets(top: PADDING_OUTER, left: PADDING_OUTER, bottom: PADDING_MEDDLE, right: PADDING_OUTER)
        backgroundColor = .colorBackgroundAPP
        addSubview(titleLabel)
        addSubview(contentTextView)
        addSubview(bottomView)
        contentTextView.text = versionData["versionDescribe"] as? String
        if versionData["forceUpdate"] as! Int == 1{
            //强制升级
            UserDefaults.standard.removeObject(forKey: "AppVersion")
            bottomView.addSubview(trueBtn)
        }else{
            //普通升级
            UserDefaults.standard.set(versionData["iosVersion"] as? String, forKey: "AppVersion")
            bottomView.addSubview(cancleBtn)
            bottomView.addSubview(trueBtn)
        }


    }
    lazy var titleLabel: UILabel = {
        let r = UILabel()
        r.textColor = .black333
        r.font = .mediumFont(20)
        r.tg_width.equal(.fill)
        r.tg_height.equal(20)
        r.tg_top.equal(8)
        r.text = "更新提示"
        r.textAlignment = .center
        return r
    }()
    
    lazy var contentTextView: QMUITextView = {
        let r = ViewFactoryUtil.normalTextView()
        r.isUserInteractionEnabled = false
        r.font = .regularFont(14)
        r.tg_top.equal(35)
        r.tg_bottom.equal(bottomView.tg_top, offset: 20)
        r.backgroundColor = .clear
        return r
    }()
    lazy var bottomView: TGLinearLayout = {
        let r = TGLinearLayout(.horz)
        r.tg_width.equal(.fill)
//        r.tg_height.equal(.wrap)
        r.tg_height.equal(35)
        r.tg_bottom.equal(0)
        r.tg_gravity = .horz.center
        r.tg_hspace = 30
        
        return r
    }()
    lazy var cancleBtn: QMUIButton = {
        let r = ViewFactoryUtil.linkButton("稍后更新".localized())
        r.setTitleColor(.placeholder, for: .normal)
        r.tg_width.equal(115)
        r.tg_height.equal(35)
        r.border(.placeholder,borderWidth: 1,cornerRadius: 17.5)
        r.titleLabel?.font = .mediumFont(16)
        r.rx.tap.subscribe(onNext: { [self] in
            GKCover.hide()
        }).disposed(by: rx.disposeBag)
        return r
    }()
    lazy var trueBtn: QMUIButton = {
        let r = ViewFactoryUtil.linkButton("立即更新".localized())
        r.setTitleColor(.primaryColor, for: .normal)
        r.tg_width.equal(115)
        r.tg_height.equal(35)
        r.border(.primaryColor,borderWidth: 1,cornerRadius: 17.5)
        
        r.titleLabel?.font = .mediumFont(16)
        r.rx.tap.subscribe(onNext: { [self] in
            if versionData["forceUpdate"] as! Int == 0{
                //普通升级
                GKCover.hide()
            }
            if let url = URL(string: versionData["apkUrl"] as! String) {
                UIApplication.shared.open(url)
            }
        }).disposed(by: rx.disposeBag)
        return r
    }()
}
