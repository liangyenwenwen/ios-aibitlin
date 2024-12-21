//
//  BoBCreatAdNameAlertView.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/12/18.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import MMBAlertsPickers
import OUICore
import RxCocoa
import RxSwift
import RxGesture
import TangramKit
import UIKit
class BoBCreatAdNameAlertView: TGLinearLayout {
    var updateAdvertisingName:((_ adName:String)->())!
    var advertisingName:String = ""
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
//        tg_space = PADDING_MEDDLE
        tg_gravity = .horz.center
        tg_padding = UIEdgeInsets(top: 0, left: 0, bottom: 25, right: 0)
        backgroundColor = .white
        addSubview(titleLabel)
        addSubview(tipLabel)
        addSubview(bgView)
        addSubview(nameTipLabel)
        addSubview(bottomView)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
                // 监听键盘将要隐藏的通知
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    func bindData(adName:String?){
        advertisingName = adName ?? ""
        titleLabel.text = advertisingName.isEmpty ? "创建广告商名称" : "修改广告商名称"
        nameTF.text = advertisingName
        countLabel.text = String(format: "%d", advertisingName.length) + "/20"
        sureBtn.isEnabled = false
        nameTF.becomeFirstResponder()
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
    lazy var titleLabel: UILabel = {
        let r = UILabel()
        r.tg_left.equal(16)
        r.tg_right.equal(16)
        r.tg_height.equal(.wrap)
        r.tg_top.equal(20)
        r.textColor = .black333
        r.font = .semiboldFont(18)
        r.numberOfLines = 0
        r.text = "创建广告商名称"
        r.textAlignment = .center
        return r
    }()
    lazy var tipLabel: UILabel = {
        let r = UILabel()
        r.tg_left.equal(16)
        r.tg_right.equal(16)
        r.tg_top.equal(12)
        r.tg_height.equal(.wrap)
        r.numberOfLines = 0
        r.textColor = .black999
        r.font = .regularFont(14)
        r.text = "建议不要使用真实姓名，广告商名称每180天只能修改1次"
        r.textAlignment = .center
        return r
    }()
    lazy var bgView: UIView = {
        let r = UIView()
        r.tg_left.equal(16)
        r.tg_right.equal(16)
        r.tg_top.equal(14)
        r.tg_height.equal(52)
        r.backgroundColor = .init(hexString: "#F5F5F5")
        r.corner(8)
        r.addSubview(nameTF)
        r.addSubview(countLabel)
        nameTF.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.top.bottom.equalTo(r)
            make.right.equalTo(-60)
        }
        countLabel.snp_makeConstraints { make in
            make.right.equalTo(-10)
            make.top.bottom.equalTo(r)
        }
        return r
    }()
    lazy var nameTF: QMUITextField = {
        let r = QMUITextField()
        r.font = .mediumFont(16)
        r.tintColor = .black333
        r.maximumTextLength = 20
        r.setPlaceHolderTextColor(.black999)
        r.placeholder = "请输入广告商名称"
        r.rx.controlEvent(.editingChanged).subscribe(onNext: {  [weak self] in
            self?.countLabel.text = String(format: "%d", r.text?.length ?? "0") + "/20"
            if self?.advertisingName == r.text{
                self?.sureBtn.isEnabled = false
            }else{
                self?.sureBtn.isEnabled = true
            }
        }).disposed(by: rx.disposeBag)
        return r
    }()
    lazy var countLabel: UILabel = {
        let r = UILabel()
        r.textColor = .black999
        r.font = .regularFont(14)
        r.text = "0/20"
        r.textAlignment = .right
        return r
    }()
    lazy var nameTipLabel: UILabel = {
        let r = UILabel()
        r.tg_left.equal(16)
        r.tg_right.equal(16)
        r.tg_top.equal(6)
        r.tg_height.equal(.wrap)
        r.numberOfLines = 0
        r.textColor = .black999
        r.font = .regularFont(14)
        r.text = "支持汉字、英文、数字和特殊符号"
        return r
    }()
    lazy var bottomView: UIView = {
        let r = UIView()
        r.tg_left.equal(16)
        r.tg_right.equal(16)
        r.tg_top.equal(20)
        r.tg_height.equal(46)
        r.addSubview(cancleBtn)
        r.addSubview(sureBtn)
        cancleBtn.snp_makeConstraints { make in
            make.left.top.bottom.equalTo(0)
            make.right.equalTo(r.snp_centerX).offset(-6)
        }
        sureBtn.snp_makeConstraints { make in
            make.right.top.bottom.equalTo(0)
            make.left.equalTo(r.snp_centerX).offset(6)
        }
        return r
    }()
    lazy var cancleBtn: QMUIButton = {
        let r = ViewFactoryUtil.linkButton("取消")
        r.setTitleColor(.black666, for: .normal)
        r.titleLabel?.font = .mediumFont(16)
        r.border(.init(hexString: "#EAEAEA"),borderWidth: 1,cornerRadius: 23)
        r.rx.tap.subscribe(onNext: { [weak self] in
            GKCover.hideWithoutAnimation()
        }).disposed(by: rx.disposeBag)
        return r
    }()
    lazy var sureBtn: QMUIButton = {
        let r = ViewFactoryUtil.linkButton("确认")
        r.setTitleColor(.white, for: .normal)
        r.titleLabel?.font = .mediumFont(16)
        r.backgroundColor = .primaryColor
        r.corner(23)
        r.rx.tap.subscribe(onNext: { [weak self] in
            BoBBuyAndSellCionModel.UpdateNameOfAdvertiserRequest(advertiserName:self?.nameTF.text){[weak self] errCode, errMsg in
                if errCode == 20000{
                    if self?.advertisingName.isEmpty == true{
                        SuperToast.show(title:"创建成功")
                    }else{
                        SuperToast.show(title:"修改成功")
                    }
                    if self?.updateAdvertisingName != nil{
                        self?.updateAdvertisingName(self?.nameTF.text ?? "")
                    }
                    GKCover.hideWithoutAnimation()
                }else{
                    SuperToast.show(title: errMsg)
                }
            }
        }).disposed(by: rx.disposeBag)
        return r
    }()
}




