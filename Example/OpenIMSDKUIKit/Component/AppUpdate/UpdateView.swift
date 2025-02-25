//
//  UpdateView.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2025/2/18.
//  Copyright © 2025 rentsoft. All rights reserved.
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
        addSubview(trueBtn)
        contentTextView.text = versionData["versionDescribe"] as? String
    }
    lazy var titleLabel: UILabel = {
        let r = UILabel()
        r.textColor = .black333
        r.font = .semiboldFont(18)
        r.tg_width.equal(.fill)
        r.tg_height.equal(20)
        r.tg_top.equal(10)
        r.text = "更新提示".localized()
        r.textAlignment = .center
        return r
    }()
    
    lazy var contentTextView: QMUITextView = {
        let r = ViewFactoryUtil.normalTextView()
        r.isUserInteractionEnabled = false
        r.font = .regularFont(14)
        r.textColor = .black666
        r.tg_top.equal(30)
        r.tg_height.equal(100)
        r.backgroundColor = .clear
        r.textAlignment = .center
        return r
    }()
    lazy var trueBtn: QMUIButton = {
        let r = ViewFactoryUtil.linkButton("立即更新".localized())
        r.setTitleColor(.white, for: .normal)
        r.backgroundColor = .primaryColor
        r.tg_left.equal(32)
        r.tg_right.equal(32)
        r.tg_height.equal(36)
        r.tg_bottom.equal(24)
        r.corner(18)
        r.titleLabel?.font = .mediumFont(14)
        r.rx.tap.subscribe(onNext: { [self] in
            if let url = URL(string: versionData["apkUrl"] as! String) {
                UIApplication.shared.open(url)
            }
        }).disposed(by: rx.disposeBag)
        return r
    }()
}

