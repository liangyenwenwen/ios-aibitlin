//
//  BoBUploadVoucherAlertView.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/12/25.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import MMBAlertsPickers
import OUICore
import ProgressHUD
import RxCocoa
import RxSwift
import TangramKit
import UIKit
class BoBUploadVoucherAlertView: UIView {
    var uploadVoucherSuccessBlock:(()->())!
    var currentVC:UIViewController?
    var voucherUrl:String?
    var type:Int = 1 //1银行卡2支付宝，3微信
    var code:String? //订单号
    public override init(frame: CGRect) {
        super.init(frame: frame)
        innerInit()

    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func innerInit() {
        backgroundColor = UIColor.black.withAlphaComponent(0.5) // 半透明背景
        addSubview(contentView)
        contentView.addSubview(titleLbl)
        contentView.addSubview(closeBtn)
        contentView.addSubview(tipLabel)
        contentView.addSubview(voucherTipLabel)
        contentView.addSubview(upLoadBgView)
        contentView.addSubview(cancleBtn)
        contentView.addSubview(sureBtn)
        contentView.snp_makeConstraints { make in
            make.left.right.bottom.equalTo(0)
            make.height.equalTo(400)
        }
        titleLbl.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(closeBtn.snp_left).offset(-15)
            make.top.equalTo(18)
        }
        closeBtn.snp_makeConstraints { make in
            make.right.equalTo(-16)
            make.centerY.equalTo(titleLbl)
            make.width.height.equalTo(28)
        }
        tipLabel.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.top.equalTo(titleLbl.snp_bottom).offset(16)
        }
        voucherTipLabel.snp_makeConstraints { make in
            make.left.right.equalTo(tipLabel)
            make.top.equalTo(tipLabel.snp_bottom).offset(12)
            make.height.equalTo(20)
        }
        upLoadBgView.snp_makeConstraints { make in
            make.top.equalTo(tipLabel.snp_bottom).offset(44)
            make.left.equalTo(16)
            make.width.height.equalTo(112)
        }
        cancleBtn.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.top.equalTo(302)
            make.height.equalTo(46)
            make.width.equalTo((kScreenWidth-32-18)/2)
        }
        sureBtn.snp_makeConstraints { make in
            make.right.equalTo(-16)
            make.top.width.height.equalTo(cancleBtn)
        }
    }
    // 自定义弹框视图
    func showMask(view: UIView) {
        self.frame = view.bounds
        view.addSubview(self)
        // 动画显示遮罩
        alpha = 0
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1
        }
    }
    
    // 隐藏遮罩
    func hideMask() {
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0
        }) { _ in
            self.removeFromSuperview()
        }
    }
    func bindData(type:Int,code:String){
        self.type = type
        self.code = code
        if type == 1{
            voucherTipLabel.hide()
            upLoadBgView.snp_updateConstraints { make in
                make.top.equalTo(tipLabel.snp_bottom).offset(12)
            }
        }else{
            let str = type == 2 ? "查看支付宝付款凭证示例":"查看微信付款凭证示例"
            voucherTipLabel.attributedText = setupAttributedText(text: "点击，" + str, targetWords: [str], color: .primaryColor)
        }
    }
    @objc func chooseImage() {
        _photoHelper.setConfigToMultipleSelected(forVideo: false, maxSelectCount: 1)
//        _photoHelper.showSelectMetaSheet(byController: currentVC!)
        _photoHelper.presentPhotoLibrary(byController: currentVC!)
    }
    private lazy var _photoHelper: PhotoHelper = {
            let v = PhotoHelper()
            v.setConfigToMultipleSelected()
            v.didPhotoSelected = { [weak self] (images: [UIImage], assets: [PHAsset]) in
                guard var photo = images.first else { return }
                self?.upLoadVoucherImage(voucherImage: photo)
            }
            
            v.didCameraFinished = { [weak self] (photo: UIImage?, videoPath: URL?) in
                guard let sself = self else { return }
                if var photo {
                    self?.upLoadVoucherImage(voucherImage: photo)
                }
            }
        return v
        }()
    func upLoadVoucherImage(voucherImage:UIImage){
//        self.qrCodeImageView.image = qrCodeImage
        let result = FileHelper.shared.saveImage(image: voucherImage)
        IMController.shared.uploadFile(fullPath: result.fullPath) { [weak self] progress in
            
        } onSuccess: { [weak self] url in
            DispatchQueue.main.async {
                ProgressHUD.dismiss()
                if let url = url {
                    self?.voucherUrl = url
                    self?.voucherImageView.image = voucherImage
                }else{
                    SuperToast.show(title: "上传失败")
                }
            }
        }
    }
    func setupAttributedText(text: String, targetWords: [String], color: UIColor) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: text)
        for word in targetWords {
            if let range = text.range(of: word) {
                let nsRange = NSRange(range, in: text)
                attributedString.addAttribute(.foregroundColor, value: color, range: nsRange)
            }
        }
        return NSAttributedString(attributedString: attributedString)
    }
    lazy var contentView: UIView = {
        let r = UIView()
        r.corner(MEDDLE_RADIUS)
//        r.tg_width.equal(.fill)
//        r.tg_height.equal(.wrap)
//        r.tg_space = PADDING_MEDDLE
//        r.tg_bottom.equal(0)
//        r.tg_padding = UIEdgeInsets(top: 0, left: PADDING_OUTER, bottom: PADDING_MEDDLE+34, right: PADDING_OUTER)
        r.backgroundColor = .white
        return r
    }()
    lazy var titleLbl: UILabel = {
        let r = ViewFactoryUtil.customTilteLabelFill("上传您的付款凭证", font: 18, textColor: .black333)
        r.font = .mediumFont(18)
        r.textColor = .black333
        return r
    }()
    lazy var closeBtn: QMUIButton = {
        let r = ViewFactoryUtil.imageBtn(R.image.close_cirle_icon()!, 28)
        r.rx.tap.subscribe(onNext: {[weak self] in
            self?.hideMask()
        })
        .disposed(by: rx.disposeBag)
        return r
    }()
    lazy var tipLabel: UILabel = {
        let r = UILabel()
        r.font = .regularFont(16)
        r.textColor = .black666
        r.numberOfLines = 0
        r.attributedText = setupAttributedText(text: "请您上传这笔交易完整的回执单，包含完整的图片、金额、姓名", targetWords: ["图片、金额、姓名"], color: .init(hexString: "#F32525"))
//        r.text = "请您上传这笔交易完整的回执单，包含完整的图片、金额、姓名"
        return r
    }()
    lazy var voucherTipLabel: UILabel = {
        let r = UILabel()
        r.font = .regularFont(16)
        r.textColor = .black666
        r.numberOfLines = 0
//        r.text = "点击，查看微信付款凭证示例"
        r.attributedText = setupAttributedText(text: "点击，查看微信付款凭证示例", targetWords: ["查看微信付款凭证示例"], color: .primaryColor)
        r.isUserInteractionEnabled = true
        let btn = QMUIButton()
        btn.rx.tap.subscribe(onNext: { [weak self] in
            let voucherView = BoBShowVoucherView()
            voucherView.tg_width.equal(300)
            voucherView.tg_height.equal(.wrap)
            voucherView.tg_centerY.equal(0)
            voucherView.bindData(image: UIImage(named: self?.type == 2 ? "order_detail_voucher_example_zhifubao_icon" :"order_detail_voucher_example_weixin_icon"), url: nil)
            GKCover.cover(from: self?.currentVC?.view?.window, contentView: voucherView, style: .translucent, showStyle: .center, showAnimStyle: .bottom, hideAnimStyle: .bottom, notClick: true)
        }).disposed(by: rx.disposeBag)
        r.addSubview(btn)
        btn.snp_makeConstraints { make in
            make.left.right.top.bottom.equalTo(r)
        }
        return r
    }()
    lazy var upLoadBgView: UIImageView = {
        let r = UIImageView(image: UIImage(named: "order_detail_upload_voucher_icon"))
        r.isUserInteractionEnabled = true
        r.corner(8)
        let icon = UIImageView(image: UIImage(named: "mine_payment_method_qr_upload_icon"))
        r.addSubview(icon)
        let label = UILabel()
        label.textColor = .black666
        label.font = .regularFont(12)
        label.text = "点击上传"
        label.textAlignment = .center
        r.addSubview(label)
        icon.snp_makeConstraints { make in
            make.centerX.equalTo(r)
            make.top.equalTo(28)
            make.width.height.equalTo(26)
        }
        label.snp_makeConstraints { make in
            make.bottom.equalTo(-28)
            make.left.equalTo(6)
            make.right.equalTo(-6)
        }
        r.addSubview(voucherImageView)
        voucherImageView.snp_makeConstraints { make in
            make.left.right.top.bottom.equalTo(r)
        }
        let tap = UITapGestureRecognizer()
        tap.rx.event.subscribe { [weak self] _ in
            self?.chooseImage()
        }.disposed(by: rx.disposeBag)
        r.addGestureRecognizer(tap)
        return r
    }()
    lazy var voucherImageView: UIImageView = {
        let r = UIImageView()
        return r
    }()
    lazy var cancleBtn: QMUIButton = {
        let r = ViewFactoryUtil.linkButton("取消")
        r.setTitleColor(.black666, for: .normal)
        r.titleLabel?.font = .mediumFont(16)
        r.border(.init(hexString: "#EAEAEA"),borderWidth: 1,cornerRadius: 23)
        r.rx.tap.subscribe(onNext: { [weak self] in
            self?.hideMask()
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
            if (self?.voucherUrl ?? "").length == 0{
                SuperToast.show(title: "请上传付款凭证")
                return
            }
            BoBBuyAndSellCionModel.UploadCredentialsRequest(code: self?.code ?? "", credentials: self?.voucherUrl ?? ""){[weak self] errCode,errMsg in
                if errCode == 20000{
                    SuperToast.show(title: "上传成功")
                    if self?.uploadVoucherSuccessBlock != nil{
                        self?.uploadVoucherSuccessBlock()
                    }
                    self?.hideMask()
                }else{
                    SuperToast.show(title: errMsg)
                }
            }
        }).disposed(by: rx.disposeBag)
        return r
    }()
}




