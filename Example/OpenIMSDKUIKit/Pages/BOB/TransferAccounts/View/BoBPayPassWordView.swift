//
//  BoBPayPassWordView.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/11/29.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import MMBAlertsPickers
import OUICore
import ProgressHUD
import RxCocoa
import RxSwift
import RxGesture
import TangramKit
import UIKit
class BoBPayPassWordView: TGLinearLayout {
    var payBtnClickBlock: ((_ passWord: String)->Void)!
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
        backgroundColor = .white
        
        addSubview(topView)
        addSubview(pwdTf)
        addSubview(cancleBtn)
        addSubview(payBtn)
        pwdTf.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.top.equalTo(topView.snp_bottom).offset(14)
            make.height.equalTo(56)
        }
        cancleBtn.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.top.equalTo(pwdTf.snp_bottom).offset(21)
            make.height.equalTo(44)
            make.width.equalTo((kScreenWidth-50)/2.0)
        }
        payBtn.snp_makeConstraints { make in
            make.right.equalTo(-16)
            make.top.height.width.equalTo(cancleBtn)
        }
        pwdTf.becomeFirstResponder()
    }
    lazy var topView: TGLinearLayout = {
        let r = TGLinearLayout(.horz)
        r.tg_width.equal(.fill)
        r.tg_height.equal(.wrap)
        r.tg_gravity = .vert.center
        r.tg_space = 7
        r.addSubview(titleLbl)
        r.addSubview(closeBtn)
        return r
    }()
    
    lazy var titleLbl: UILabel = {
        let r = ViewFactoryUtil.customTilteLabelFill("安全密码".localized(), font: 18, textColor: .black333)
        r.font = .mediumFont(18)
        r.textColor = .black333
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
    lazy var pwdTf:QMUITextField = {
        let r = QMUITextField()
        r.textInsets = UIEdgeInsets(top: 0, left: PADDING_OUTER, bottom: 0, right: PADDING_OUTER)
        r.font = .mediumFont(16)
        r.placeholder = "输入安全密码"
        r.textColor = .black333
        r.keyboardType = .asciiCapableNumberPad
        r.border(.primaryColor,borderWidth: 1,cornerRadius: 8)
        r.maximumTextLength = 6
        r.rx.controlEvent(.editingChanged).subscribe(onNext: { [unowned self] in
            self.payBtn.isEnabled = r.text?.length == 6
        }).disposed(by: rx.disposeBag)
        r.isSecureTextEntry = true
        return r
    }()
    lazy var cancleBtn: QMUIButton = {
        let r = ViewFactoryUtil.linkButton("取消")
        r.setTitleColor(.black333, for: .normal)
        r.titleLabel?.font = .regularFont(16)
        r.isUserInteractionEnabled = true
        r.border(.black666,borderWidth: 1,cornerRadius: 22)
        r.rx.tap.subscribe(onNext: { [self] in
            GKCover.hide()
        }).disposed(by: rx.disposeBag)
        return r
    }()
    lazy var payBtn: QMUIButton = {
        let r = ViewFactoryUtil.linkButton("确定")
        r.setTitleColor(.white, for: .normal)
        r.titleLabel?.font = .regularFont(16)
        r.backgroundColor = .primaryColor
        r.isUserInteractionEnabled = true
        r.isEnabled = false
        r.corner(22)
        r.rx.tap.subscribe(onNext: { [weak self] in
            if self?.payBtnClickBlock != nil{
                self?.payBtnClickBlock(self?.pwdTf.text ?? "")
            }
            self?.endEditing(true)
            GKCover.hide()
        }).disposed(by: rx.disposeBag)
        return r
    }()
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        false
    }
}
