//
//  WebViewPwdViewController.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2025/4/7.
//  Copyright © 2025 rentsoft. All rights reserved.
//

import MMBAlertsPickers
import OUICore
import ProgressHUD
import RxCocoa
import RxSwift
import RxGesture
import TangramKit
import UIKit
class WebViewPwdViewController: TGLinearLayout {
    var sureBtnClickBlock: ((_ passWord: String)->Void)!
    var cancleBtnClickBlock:(()->Void)!
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
        addSubview(sureBtn)
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
        sureBtn.snp_makeConstraints { make in
            make.right.equalTo(-16)
            make.top.height.width.equalTo(cancleBtn)
        }
        pwdTf.becomeFirstResponder()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
                // 监听键盘将要隐藏的通知
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    @objc func keyboardWillShow(notification: NSNotification) {
            if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardRectangle = keyboardFrame.cgRectValue
                let keyboardHeight = keyboardRectangle.height
                print("Keyboard height: \(keyboardHeight)")
                // 根据键盘高度进行相应的处理
                let width = self.frame.size.width
                let height = self.frame.size.height
                self.frame = CGRectMake((kScreenWidth-width)/2, kScreenHeight-keyboardHeight-height, width, height)
            }
        }
     
        @objc func keyboardWillHide(notification: NSNotification) {
            // 键盘即将隐藏，可以在这里处理隐藏键盘后的操作
            let width = self.frame.size.width
            let height = self.frame.size.height
            self.frame = CGRectMake((kScreenWidth-width)/2, (kScreenHeight-height)/2, width, height)
        }
     
        deinit {
            // 移除所有通知监听
            NotificationCenter.default.removeObserver(self)
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
        let r = ViewFactoryUtil.customTilteLabelFill("隐私访问密码".localized(), font: 18, textColor: .black333)
        r.font = .mediumFont(18)
        r.textColor = .black333
        return r
    }()
    lazy var closeBtn: QMUIButton = {
        let r = ViewFactoryUtil.imageBtn(R.image.close_cirle_icon()!, 28)
        r.rx.tap.subscribe(onNext: {[weak self] in
            if self?.cancleBtnClickBlock != nil{
                self?.cancleBtnClickBlock()
            }
            self?.endEditing(true)
            GKCover.hide()
        })
        .disposed(by: rx.disposeBag)
        return r
    }()
    lazy var pwdTf:QMUITextField = {
        let r = QMUITextField()
        r.textInsets = UIEdgeInsets(top: 0, left: PADDING_OUTER, bottom: 0, right: PADDING_OUTER)
        r.font = .mediumFont(16)
        r.placeholder = "请输入隐私访问密码".localized()
        r.textColor = .black333
        r.keyboardType = .asciiCapableNumberPad
        r.border(.primaryColor,borderWidth: 1,cornerRadius: 8)
        r.maximumTextLength = 6
        r.rx.controlEvent(.editingChanged).subscribe(onNext: { [unowned self] in
            self.sureBtn.isEnabled = r.text?.length == 6
        }).disposed(by: rx.disposeBag)
        r.isSecureTextEntry = true
        return r
    }()
    lazy var cancleBtn: QMUIButton = {
        let r = ViewFactoryUtil.linkButton("取消".localized())
        r.setTitleColor(.black333, for: .normal)
        r.titleLabel?.font = .regularFont(16)
        r.isUserInteractionEnabled = true
        r.border(.black666,borderWidth: 1,cornerRadius: 22)
        r.rx.tap.subscribe(onNext: { [weak self] in
            if self?.cancleBtnClickBlock != nil{
                self?.cancleBtnClickBlock()
            }
            self?.endEditing(true)
            GKCover.hide()
        }).disposed(by: rx.disposeBag)
        return r
    }()
    lazy var sureBtn: QMUIButton = {
        let r = ViewFactoryUtil.linkButton("确定".localized())
        r.setTitleColor(.white, for: .normal)
        r.titleLabel?.font = .regularFont(16)
        r.backgroundColor = .primaryColor
        r.isUserInteractionEnabled = true
        r.isEnabled = false
        r.corner(22)
        r.rx.tap.subscribe(onNext: { [weak self] in
            if self?.sureBtnClickBlock != nil{
                self?.sureBtnClickBlock(self?.pwdTf.text ?? "")
            }
            self?.endEditing(true)
        }).disposed(by: rx.disposeBag)
        return r
    }()
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        false
    }
}

