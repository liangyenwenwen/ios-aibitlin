//
//  BoBOrderDetailPaymentView.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/12/25.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Foundation
import OUICore
import TangramKit
class BoBOrderDetailPaymentView: TGLinearLayout {
    var chooseRedPacketTypeBlock:((_ typeTitle:String,_ typeIndex:Int)->())!
    var paymentDetail:paymentDdetailData?
    var currentVC:UIViewController?
    var type:Int = 1
    init() {
        super.init(frame: .zero, orientation: .vert)
        innerInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        innerInit()
    }
    
    func innerInit() {
        tg_width.equal(.fill)
        tg_height.equal(.wrap)
    }
    func getAttribute(str:String) -> NSMutableAttributedString{
        let attachment = NSTextAttachment()
        attachment.image = UIImage(named: "receive_payment_copy_icon")
        attachment.bounds = CGRect(x: 0, y: -3.0, width: 16, height: 16)
        let str1 = str + " "
        let attributedString = NSMutableAttributedString(string: str1)
        let attachmentString = NSAttributedString(attachment: attachment)
        
//        attributedString.append(attachmentString)
        attributedString.insert(attachmentString, at: str1.length)
        return attributedString
    }
    func bindData(type:Int,data:paymentDdetailData){
        paymentDetail = data
        self.type = type
        if type == 1{
            addSubview(bankView)
            bankIcon.sd_setImage(with: URL(string: data.icon ?? ""))
            bankName.text = data.bankDeposit ?? ""
            bankNumber.attributedText = getAttribute(str: data.bankId ?? "")
            bankUserName.attributedText = getAttribute(str: data.name ?? "")
        }else if type == 2{
            addSubview(aliPayView)
            aliPayView.payIcon.sd_setImage(with: URL(string: data.img ?? ""))
            aliPayView.userNameView.buyCounLabel.attributedText = getAttribute(str: data.name ?? "")
            aliPayView.userNickNameView.buyCounLabel.text = data.nickName
            aliPayView.numberView.buyCounLabel.attributedText = getAttribute(str: data.zfbCode ?? "")
        }else if type == 3{
            addSubview(weixinPayView)
            weixinPayView.payIcon.sd_setImage(with: URL(string: data.img ?? ""))
            weixinPayView.userNameView.buyCounLabel.attributedText = getAttribute(str: data.name ?? "")
            weixinPayView.userNickNameView.buyCounLabel.text = data.nickName
        }
    }
    func showQrCode(){
        let voucherView = BoBShowVoucherView()
        voucherView.tg_width.equal(300)
        voucherView.tg_height.equal(.wrap)
        voucherView.tg_centerY.equal(0)
        voucherView.bindData(image:nil, url: paymentDetail?.img)
//        voucherView.voucherImageView.sd_setImage(with: URL(string: paymentDetail?.img))
        GKCover.cover(from: self.currentVC?.view?.window, contentView: voucherView, style: .translucent, showStyle: .center, showAnimStyle: .bottom, hideAnimStyle: .bottom, notClick: true)
    }
    lazy var bankView: UIView = {
        let r = UIView()
        r.tg_top.equal(0)
        r.tg_left.equal(0)
        r.tg_right.equal(0)
        r.tg_height.equal(90)
        r.backgroundColor = .init(hexString: "#EAF5FF")
        r.border(.init(hexString: "#BEDFFF"),borderWidth: 1,cornerRadius: 8)
        r.addSubview(bankIcon)
        r.addSubview(bankName)
        r.addSubview(bankNumber)
        r.addSubview(bankUserName)
        bankIcon.snp_makeConstraints { make in
            make.top.equalTo(19)
            make.left.equalTo(22)
            make.width.height.equalTo(30)
        }
        bankName.snp_makeConstraints { make in
            make.top.equalTo(14)
            make.left.equalTo(bankIcon.snp_right).offset(14)
            make.height.equalTo(18)
            make.right.equalTo(-22)
        }
        bankNumber.snp_makeConstraints { make in
            make.top.equalTo(bankName.snp_bottom).offset(4)
            make.left.right.equalTo(bankName)
            make.height.equalTo(18)
        }
        bankUserName.snp_makeConstraints { make in
            make.top.equalTo(bankNumber.snp_bottom).offset(4)
            make.left.right.equalTo(bankName)
            make.height.equalTo(18)
        }
        return r
    }()
    private lazy var bankIcon: UIImageView = {
        let r = UIImageView()
        
        return r
    }()
    private lazy var bankName: UILabel = {
        let r = UILabel()
        r.textColor = .black333
        r.font = .mediumFont(16)
        return r
    }()
    private lazy var bankNumber: UILabel = {
        let r = UILabel()
        r.textColor = .black333
        r.font = .regularFont(14)
        r.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer()
        tap.rx.event.subscribe {[weak self]  _ in
            UIPasteboard.general.string = self?.paymentDetail?.bankId ?? ""
            SuperToast.show(title: "复制成功".localized())
        }.disposed(by: rx.disposeBag)
        r.addGestureRecognizer(tap)
        return r
    }()
    private lazy var bankUserName: UILabel = {
        let r = UILabel()
        r.textColor = .black333
        r.font = .regularFont(16)
        r.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer()
        tap.rx.event.subscribe {[weak self]  _ in
            UIPasteboard.general.string = self?.paymentDetail?.name ?? ""
            SuperToast.show(title: "复制成功".localized())
        }.disposed(by: rx.disposeBag)
        r.addGestureRecognizer(tap)
        return r
    }()
    lazy var aliPayView: orderDetailPayView = {
        let r = orderDetailPayView()
        r.tg_top.equal(0)
        r.tg_left.equal(0)
        r.tg_right.equal(0)
        r.tg_height.equal(162)
        r.backgroundColor = .init(hexString: "#EAF5FF")
        r.border(.init(hexString: "#BEDFFF"),borderWidth: 1,cornerRadius: 8)
        r.userNameView.buyCountTitleLabel.text = "收款人"
        r.userNickNameView.buyCountTitleLabel.text = "支付宝昵称"
        r.numberView.buyCountTitleLabel.text = "支付宝账号"
        r.userNameView.buyCounLabel.isUserInteractionEnabled = true
        r.numberView.buyCounLabel.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer()
        tap.rx.event.subscribe { [weak self] _ in
            self?.showQrCode()
        }.disposed(by: rx.disposeBag)
        r.leftView.addGestureRecognizer(tap)
        let tap1 = UITapGestureRecognizer()
        tap1.rx.event.subscribe {[weak self]  _ in
            UIPasteboard.general.string = self?.paymentDetail?.name ?? ""
            SuperToast.show(title: "复制成功".localized())
        }.disposed(by: rx.disposeBag)
        r.userNameView.buyCounLabel.addGestureRecognizer(tap1)
        let tap2 = UITapGestureRecognizer()
        tap2.rx.event.subscribe {[weak self]  _ in
            UIPasteboard.general.string = self?.paymentDetail?.zfbCode ?? ""
            SuperToast.show(title: "复制成功".localized())
        }.disposed(by: rx.disposeBag)
        r.numberView.buyCounLabel.addGestureRecognizer(tap2)
        return r
    }()
    lazy var weixinPayView: orderDetailPayView = {
        let r = orderDetailPayView()
        r.tg_top.equal(0)
        r.tg_left.equal(0)
        r.tg_right.equal(0)
        r.tg_height.equal(162)
        r.backgroundColor = .init(hexString: "#EAF5FF")
        r.border(.init(hexString: "#BEDFFF"),borderWidth: 1,cornerRadius: 8)
        r.userNameView.buyCountTitleLabel.text = "收款人"
        r.userNickNameView.buyCountTitleLabel.text = "微信昵称"
        r.userNameView.buyCounLabel.isUserInteractionEnabled = true
        r.numberView.hide()
        let tap = UITapGestureRecognizer()
        tap.rx.event.subscribe { [weak self] _ in
            self?.showQrCode()
        }.disposed(by: rx.disposeBag)
        r.leftView.addGestureRecognizer(tap)
        let tap1 = UITapGestureRecognizer()
        tap1.rx.event.subscribe {[weak self]  _ in
            UIPasteboard.general.string = self?.paymentDetail?.name ?? ""
            SuperToast.show(title: "复制成功".localized())
        }.disposed(by: rx.disposeBag)
        r.userNameView.buyCounLabel.addGestureRecognizer(tap1)
        return r
    }()
}
class orderDetailPayView: TGLinearLayout {
    init() {
        super.init(frame: .zero, orientation: .horz)
        innerInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        innerInit()
    }
    
    func innerInit() {
        tg_width.equal(.fill)
        tg_height.equal(.wrap)
        tg_space = PADDING_MEDDLE
        tg_gravity = .horz.between
        tg_padding = UIEdgeInsets(top: PADDING_OUTER, left: PADDING_OUTER, bottom: PADDING_OUTER, right: PADDING_OUTER)
        addSubview(leftView)
        addSubview(rightView)
    }
    lazy var leftView: UIView = {
        let r = UIView()
        r.tg_width.equal(130)
        r.tg_height.equal(130)
        r.addSubview(payIcon)
        r.addSubview(icon)
        payIcon.snp_makeConstraints { make in
            make.left.right.top.bottom.equalTo(r)
        }
        icon.snp_makeConstraints { make in
            make.right.bottom.equalTo(-6)
            make.width.height.equalTo(24)
        }
        return r
    }()
    lazy var payIcon: UIImageView = {
        let r = UIImageView()
        r.corner(8)
        return r
    }()
    lazy var icon: UIImageView = {
        let r = UIImageView(image: UIImage(named: "order_detail_qrcode_big_icon"))
        return r
    }()
    lazy var rightView: TGLinearLayout = {
        let r = TGLinearLayout(.vert)
        r.tg_top.equal(0)
//        r.tg_left.equal(12)
        r.tg_right.equal(0)
        r.tg_width.equal(kScreenWidth-32-32-10-130)
        r.tg_height.equal(130)
        r.addSubview(userNameView)
        r.addSubview(userNickNameView)
        r.addSubview(numberView)
        r.addSubview(saveBtn)
        saveBtn.snp_makeConstraints { make in
            make.left.bottom.equalTo(0)
            make.width.equalTo(104)
            make.height.equalTo(32)
        }
        return r
    }()
    lazy var userNameView: buyAndSellTitleView = {
        let r = buyAndSellTitleView()
        r.tg_top.equal(0)
        r.tg_left.equal(0)
        r.tg_right.equal(0)
        r.tg_height.equal(16)
        return r
    }()
    lazy var userNickNameView: buyAndSellTitleView = {
        let r = buyAndSellTitleView()
        r.tg_top.equal(15)
        r.tg_left.equal(0)
        r.tg_right.equal(0)
        r.tg_height.equal(16)
        return r
    }()
    lazy var numberView: buyAndSellTitleView = {
        let r = buyAndSellTitleView()
        r.tg_top.equal(15)
        r.tg_left.equal(0)
        r.tg_right.equal(0)
        r.tg_height.equal(16)
        return r
    }()
    lazy var saveBtn: QMUIButton = {
        let r = ViewFactoryUtil.linkButton("保存到相册")
        r.setTitleColor(.white, for: .normal)
        r.titleLabel?.font = .mediumFont(14)
        r.backgroundColor = .primaryColor
        r.corner(16)
        r.rx.tap.subscribe(onNext: { [weak self] in
            if self?.payIcon.image != nil{
                UIImageWriteToSavedPhotosAlbum((self?.payIcon.image)!, self, #selector(self?.image(image:didFinishSavingWithError:contextInfo:)), nil)
//                PhotoHelper().saveImageToAlbum(image: (self?.payIcon.image)!)
            }
        }).disposed(by: rx.disposeBag)
        return r
    }()
    @objc func image(image: UIImage, didFinishSavingWithError: NSError?,contextInfo: AnyObject)

    {
        if didFinishSavingWithError != nil {
            print("error!")
            return
        }
        print("图片保存成功".localized())
        SuperToast.show(title: "图片保存成功".localized())
    }
    
}
