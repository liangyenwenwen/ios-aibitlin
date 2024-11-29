//
//  BoBAddAliPaymentView.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/11/25.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Foundation
import TangramKit
import OUICore
import ProgressHUD



class BoBAddAliPaymentView:TGLinearLayout {
    var paymentType:Int = 1 //1支付宝，2微信
    var currentVC: UIViewController?
    var qrUrl:String?
    init(type:Int) {
        super.init(frame: .zero, orientation: .vert)
        paymentType = type
        initViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initViews()
    }

    
    func initViews()  {
        self.backgroundColor = .colorBackgroundAPP
        self.tg_width.equal(kScreenWidth-32)
        if paymentType == 1{
            self.tg_height.equal(292)
        }else{
            self.tg_height.equal(242)
        }
        addSubview(topView)
        addSubview(bottomView)
    }
    lazy var topView: UIImageView = {
        let r = UIImageView(image: UIImage(named: "mine_payment_method_qr_upload_bg_icon"))
        r.tg_width.equal(.fill)
        r.tg_height.equal(130)
        r.corner(8)
        r.backgroundColor = .white
        r.isUserInteractionEnabled = true
        r.addSubview(titleLabel)
        r.addSubview(qrCodeView)
        r.addSubview(subLabel)
        titleLabel.snp_makeConstraints { make in
            make.left.equalTo(14)
            make.top.equalTo(30)
            make.right.equalTo(qrCodeView.snp_left).offset(-12)
        }
        subLabel.snp_makeConstraints { make in
            make.left.right.equalTo(titleLabel)
            make.bottom.equalTo(-30)
        }
        qrCodeView.snp_makeConstraints { make in
            make.centerY.equalTo(r)
            make.right.equalTo(-14)
            make.width.height.equalTo(112)
        }
        
        return r
    }()
    lazy var titleLabel: UILabel = {
        let r = UILabel()
        r.font =  UIFont(name: "PingFangSC-Semibold", size: 16)
        r.textColor = .black333
        r.numberOfLines = 1
        r.text = paymentType == 1 ? "请上传您的支付宝收款码" :"请上传您的微信收款码"
        return r
    }()
    lazy var subLabel: UILabel = {
        let r = UILabel()
        r.font =  UIFont(name: "PingFangSC-Regular", size: 12)
        r.textColor = .black666
        r.numberOfLines = 3
        r.text = "请勿上传截图的收款码，请在二维码收款界面，点击保存收款码，上传图片"
        return r
    }()
    lazy var qrCodeView: UIView = {
        let r = UIView()
        r.backgroundColor = .init(hexString: "#F3F5F7")
        r.corner(8)
        let iconView = UIImageView(image: UIImage(named: "mine_payment_method_qr_upload_icon"))
        let label = UILabel()
        label.text = "点击上传"
        label.textAlignment = .center
        label.textColor = .init(hexString: "#999999")
        label.font = UIFont(name: "PingFangSC-Regular", size: 12)
        label.numberOfLines = 2
        r.addSubview(iconView)
        r.addSubview(label)
        iconView.snp_makeConstraints { make in
            make.centerX.equalTo(r)
            make.top.equalTo(32)
            make.width.height.equalTo(26)
        }
        label.snp_makeConstraints { make in
            make.left.equalTo(6)
            make.right.equalTo(-6)
            make.top.equalTo(iconView.snp_bottom).offset(14)
        }
        r.addSubview(qrCodeImageView)
        qrCodeImageView.snp_makeConstraints { make in
            make.edges.equalTo(r)
        }
        let tap = UITapGestureRecognizer()
        tap.rx.event.subscribe {  _ in
            self.chooseQrCodeImage()
        }
        r.addGestureRecognizer(tap)
        return r
    }()
    lazy var qrCodeImageView: UIImageView = {
        let r = UIImageView()
        return r
    }()
    
    lazy var bottomView: TGLinearLayout = {
        let r = TGLinearLayout(.vert)
        r.backgroundColor = .white
        r.tg_top.equal(12)
        r.tg_width.equal(.fill)
        r.tg_height.equal(.wrap)
        r.corner(8)
        r.addSubview(nameView)
        r.addSubview(ViewFactoryUtil.smallDivider())
        if paymentType == 1 {
            r.addSubview(aliNumberView)
            r.addSubview(ViewFactoryUtil.smallDivider())
        }
        r.addSubview(nickNameView)
        return r
    }()
    lazy var nameView: SuperSettingView = {
        let r = SuperSettingView.createInput(paymentType == 1 ? "支付宝实名*":"微信实名*", placeholder: "请输入姓名")
        r.isMediumFont()
        r.titleView.changeColor(changeColorStr: "*")
        r.textFieldView.textAlignment = .right
        r.textFieldView.isUserInteractionEnabled = false
        r.needLimitLength(length: 64)
        r.textFieldView.tg_right.equal(-10)
        r.textFieldView.textColor = .black666
        r.textFieldView.font = UIFont(name: "PingFangSC-Regular", size: 16)
        return r
    }()
    lazy var aliNumberView: SuperSettingView = {
        let r = SuperSettingView.createInput("支付宝账号*", placeholder: "请输入支付宝账号")
        r.textFieldView.textAlignment = .right
        r.isMediumFont()
        r.needLimitLength(length: 64)
        r.textFieldView.tg_right.equal(-10)
        r.textFieldView.textColor = .black666
        r.textFieldView.font = UIFont(name: "PingFangSC-Regular", size: 16)
        return r
    }()
    lazy var nickNameView: SuperSettingView = {
        let r = SuperSettingView.createInput(paymentType == 1 ? "支付宝昵称*":"微信昵称*", placeholder: paymentType == 1 ? "请输入支付宝昵称":"请输入微信昵称")
        r.isMediumFont()
        r.titleView.changeColor(changeColorStr: "*")
        r.textFieldView.font = UIFont(name: "PingFangSC-Regular", size: 16)
        r.needLimitLength(length: 64)
//        r.textFieldView.keyboardType = .asciiCapableNumberPad
        r.textFieldView.tg_right.equal(-10)
        r.textFieldView.textAlignment = .right
        r.textFieldView.textColor = .black666
        return r
    }()
    
    @objc func chooseQrCodeImage() {
        _photoHelper.setConfigToMultipleSelected(forVideo: false, maxSelectCount: 1)
        _photoHelper.showSelectMetaSheet(byController: currentVC!)
    }
    private lazy var _photoHelper: PhotoHelper = {
            let v = PhotoHelper()
            v.setConfigToMultipleSelected()
            v.didPhotoSelected = { [weak self] (images: [UIImage], assets: [PHAsset]) in
                guard var photo = images.first else { return }
                self?.upLoadQrCodeImage(qrCodeImage: photo)
            }
            
            v.didCameraFinished = { [weak self] (photo: UIImage?, videoPath: URL?) in
                guard let sself = self else { return }
                if var photo {
                    self?.upLoadQrCodeImage(qrCodeImage: photo)
                }
            }
        return v
        }()
    func upLoadQrCodeImage(qrCodeImage:UIImage){
//        self.qrCodeImageView.image = qrCodeImage
        let result = FileHelper.shared.saveImage(image: qrCodeImage)
        IMController.shared.uploadFile(fullPath: result.fullPath) { [weak self] progress in
            
        } onSuccess: { [weak self] url in
            DispatchQueue.main.async {
                ProgressHUD.dismiss()
                if let url = url {
                    self?.qrUrl = url
                    self?.qrCodeImageView.image = qrCodeImage
                }else{
                    SuperToast.show(title: "上传失败")
                }
            }
        }
    }
    
}

