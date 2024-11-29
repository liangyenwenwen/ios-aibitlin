//
//  BoBShareReceivePaymentQrCodeViewController.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/11/27.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Foundation
import TangramKit
import OUICore

class BoBShareReceivePaymentQrCodeViewController:BaseTitleController{
    var receivePaymentData:ReceivePaymentData?
    var cionType = "C"
    override func initViews() {
        
        super.initViews()
        setBackGroundColor(.init(hexString: "#388CEF"))
        initScrollSafeArea()
        title = "分享地址"
        navView.titleView.textColor = .white
        scrollViewContainer.tg_padding = UIEdgeInsets(top: PADDING_OUTER, left: PADDING_OUTER, bottom: PADDING_OUTER, right: PADDING_OUTER)
        scrollViewContainer.tg_space = 10
        superFooterContainerContainer.tg_bottom.equal(0)
        scrollViewContainer.addSubview(carView)
        scrollViewContainer.addSubview(bottomView)
        let idString = IMController.walletTransferPrefix.append(string: receivePaymentData?.addr)
        DispatchQueue.global().async {
            let image = CodeImageGenerator.createQRCodeImage(content: idString, size: CGSize(width: 190, height: 190), foregroundColor: UIColor.black, backgroundColor: UIColor.clear)
            DispatchQueue.main.async {
                self.qrImageView.image = image
            }
        }
    }
    func  getShareCardImg(view:UIView ) -> UIImage? {
        
        // 开始图形上下文
        UIGraphicsBeginImageContextWithOptions(view.bounds.size,  false, 0.0)
        defer { UIGraphicsEndImageContext() } // 确保上下文能被释放
        
        // 将view渲染到图形上下文中
        if let context = UIGraphicsGetCurrentContext() {
            view.layer.render(in: context)
//                view.isHidden = true
        } else {
//                view.isHidden = true
        }
        
        // 从图形上下文获取图片
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        
        return image
    }
    lazy var carView: TGLinearLayout = {
        let r = TGLinearLayout(.vert)
        r.tg_width.equal(.fill)
        r.tg_height.equal(.wrap)
        r.tg_top.equal(4)
        r.tg_gravity = .horz.center
        r.backgroundColor = .white
        r.corner(14)
        r.addSubview(cardTitleView)
        r.addSubview(tipLabel)
        r.addSubview(qrView)
        r.addSubview(walletTitleLabel)
        r.addSubview(walletView)
        r.addSubview(tipLabel1)
        r.addSubview(tipLabel2)
        r.addSubview(tipLabel3)
        return r
    }()
    lazy var cardTitleView: TGLinearLayout = {
        let r = TGLinearLayout(.horz)
        r.tg_width.equal(.wrap)
        r.tg_height.equal(22)
        r.tg_space = 0
        r.tg_gravity = .vert.center
        r.tg_top.equal(30)
        r.addSubview(cardTitleLabel)
        r.addSubview(cionImageView)
        r.addSubview(cionLabel)
        return r
    }()
    lazy var cardTitleLabel: UILabel = {
        let r = UILabel()
        r.tg_width.equal(.wrap)
        r.tg_height.equal(.wrap)
       
        r.textColor = .black333
        r.font = .mediumFont(20)
        r.text = "资产类型："
        return r
    }()
    lazy var cionImageView: UIImageView = {
        let r = UIImageView(image: UIImage(named: "mine_home_cion_c_icon"))
//        r.tg_left.equal(cardTitleLabel.tg_right)
        r.tg_width.equal(20)
        r.tg_height.equal(20)
        return r
    }()
    lazy var cionLabel: UILabel = {
        let r = UILabel()
        r.tg_width.equal(.wrap)
        r.tg_height.equal(.wrap)
        r.textColor = .black333
        r.font = .mediumFont(20)
        r.text = cionType
        return r
    }()
    lazy var tipLabel: UILabel = {
        let r = UILabel()
//        r.tg_width.equal(.wrap)
        r.tg_top.equal(cardTitleLabel.tg_bottom, offset: 34)
        r.tg_left.equal(24)
        r.tg_right.equal(24)
        r.tg_height.equal(.wrap)
        r.textColor = .black999
        r.font = .regularFont(12)
        r.textAlignment = .center
        r.text = "该地址仅支持 " + cionType + "收款。\n请勿用于其他币种，否则资产将不可找回"
        return r
    }()
    lazy var qrView: UIView = {
        let r = UIView()
        r.tg_top.equal(tipLabel.tg_bottom, offset: 34)
        r.tg_width.equal(210)
        r.tg_height.equal(210)
        r.tg_centerY.equal(0)
        r.border(.init(hexString: "#EAEAEA"),borderWidth: 1,cornerRadius: 8)
        r.addSubview(qrImageView)
        qrImageView.snp_makeConstraints { make in
            make.left.top.equalTo(10)
            make.right.bottom.equalTo(-10)
        }
        return r
    }()
    lazy var qrImageView: UIImageView = {
        let r = UIImageView()
        return r
    }()
    lazy var walletTitleLabel: UILabel = {
        let r = UILabel()
        r.tg_top.equal(qrView.tg_bottom, offset: 20)
        r.tg_left.equal(24)
        r.tg_right.equal(24)
        r.tg_height.equal(.wrap)
        r.textColor = .black999
        r.font = .mediumFont(14)
        r.textAlignment = .center
        r.text = "钱包地址"
        return r
    }()
    lazy var walletView: TGLinearLayout = {
        let r = TGLinearLayout(.horz)
        r.tg_top.equal(walletTitleLabel.tg_bottom,offset: 8)
        r.tg_left.equal(24)
        r.tg_right.equal(24)
        r.tg_height.equal(36)
        r.tg_space = 5
        r.tg_gravity = .vert.between
        r.isUserInteractionEnabled = true
        r.backgroundColor = .init(hexString: "#F5F5F5")
        r.corner(8)
        r.addSubview(walletAddressLabel)
        r.addSubview(copyImageView)
        let tap = UITapGestureRecognizer()
        tap.rx.event.subscribe {  _ in
            UIPasteboard.general.string = self.walletAddressLabel.text
            SuperToast.show(title: "复制成功".localized())
        }
        r.addGestureRecognizer(tap)
        return r
    }()
    lazy var walletAddressLabel: UILabel = {
        let r = UILabel()
        r.tg_left.equal(13)
        r.tg_width.equal(kScreenWidth-127)
        r.tg_height.equal(20)
        r.tg_top.equal(8)
        r.textColor = .black333
        r.font = .mediumFont(12)
        r.sizeToFit()
//        r.numberOfLines = 0
        r.text = receivePaymentData?.addr
        return r
    }()
    lazy var copyImageView: UIImageView = {
        let r = UIImageView(image: UIImage(named: "copy_icon"))
        r.tg_width.equal(16)
        r.tg_height.equal(16)
        r.tg_top.equal(10)
        r.tg_right.equal(13)
        return r
    }()
    lazy var tipLabel1: UILabel = {
        let r = UILabel()
        r.tg_top.equal(walletView.tg_bottom,offset: 10)
        r.tg_left.equal(24)
        r.tg_right.equal(24)
        r.tg_height.equal(.wrap)
        r.textColor = .black999
        r.font = .mediumFont(12)
        r.numberOfLines = 0
        r.text = "· 最小收款金额：" + String(format: "%.2f ",receivePaymentData?.minAmount ?? 0) + cionType
        return r
    }()
    lazy var tipLabel2: UILabel = {
        let r = UILabel()
        r.tg_top.equal(tipLabel1.tg_bottom,offset: 5)
        r.tg_left.equal(24)
        r.tg_right.equal(24)
        r.tg_height.equal(.wrap)
        r.textColor = .black999
        r.font = .mediumFont(12)
        r.numberOfLines = 0
        r.text = "· 小于最小金额的收款将不会上账且无法退回"
        return r
    }()
    lazy var tipLabel3: UILabel = {
        let r = UILabel()
        r.tg_top.equal(tipLabel2.tg_bottom,offset: 5)
        r.tg_left.equal(24)
        r.tg_right.equal(24)
        r.tg_height.equal(.wrap)
        r.tg_bottom.equal(12)
        r.textColor = .black999
        r.font = .mediumFont(12)
        r.numberOfLines = 0
        r.text = "· 您的充值地址不会经常改变，可截图保存并重复充值"
        return r
    }()
    lazy var bottomView:TGLinearLayout = {
        let r = TGLinearLayout(.horz)
        r.tg_top.equal(carView.tg_bottom,offset: 30)
        r.tg_width.equal(kScreenWidth-32)
        r.tg_height.equal(46)
        r.tg_gravity = .horz.between
        r.tg_hspace = 18
        r.backgroundColor = .clear
        r.addSubview(cancleBtn)
        r.addSubview(shareBtn)
        return r
    }()
    lazy var cancleBtn: QMUIButton = {
        let r = ViewFactoryUtil.linkButton("取消".localized())
        r.tg_width.equal(182)
        r.tg_height.equal(46)
        r.setTitleColor(.white, for: .normal)
        r.titleLabel?.font = .regularFont(16)
        r.backgroundColor = .clear
        r.isUserInteractionEnabled = true
        r.border(.white,borderWidth: 1,cornerRadius: 23)
        r.rx.tap.subscribe(onNext: { [self] in
            self.navigationController?.popViewController(animated: true)
        }).disposed(by: rx.disposeBag)
        return r
    }()
    lazy var shareBtn: QMUIButton = {
        let r = ViewFactoryUtil.linkButton("分享".localized())
        r.tg_width.equal((kScreenWidth - 50)/2.0)
        r.tg_height.equal(46)
        r.setTitleColor(.primaryColor, for: .normal)
        r.titleLabel?.font = .regularFont(16)
        r.backgroundColor = .white
        r.isUserInteractionEnabled = true
        r.corner(23)
        r.rx.tap.subscribe(onNext: { [self] in
            guard let image = getShareCardImg(view: carView) else {return}
            
            let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            self.present(activityViewController, animated: true)
        }).disposed(by: rx.disposeBag)
        return r
    }()
    
    
}
