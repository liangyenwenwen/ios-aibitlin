//
//  BoBReceivePaymentViewController.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/11/27.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Foundation
import OUICore
class BoBReceivePaymentViewController:UIViewController{
    var receivePaymentData:ReceivePaymentData?
    var cionType = "C"
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .colorBackgroundAPP
        title = "收款"
        view.addSubview(titleLabel)
        view.addSubview(cionTypeView)
        view.addSubview(contentView)
        view.addSubview(label1)
        view.addSubview(countLabel)
        view.addSubview(cionLabel)
        view.addSubview(label2)
        view.addSubview(label3)
        titleLabel.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(36)
        }
        cionTypeView.snp_makeConstraints { make in
            make.left.right.equalTo(view)
            make.top.equalTo(titleLabel.snp_bottom)
            make.height.equalTo(50)
        }
        contentView.snp_makeConstraints { make in
            make.left.right.equalTo(0)
            make.top.equalTo(cionTypeView.snp_bottom).offset(12)
            make.height.equalTo(170)
        }
        label1.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.top.equalTo(contentView.snp_bottom).offset(26)
        }
        countLabel.snp_makeConstraints { make in
            make.left.equalTo(label1.snp_right).offset(2)
            make.top.equalTo(label1)
        }
        cionLabel.snp_makeConstraints { make in
            make.left.equalTo(countLabel.snp_right).offset(2)
            make.top.equalTo(label1)
        }
        label2.snp_makeConstraints { make in
            make.left.equalTo(label1)
            make.top.equalTo(label1.snp_bottom).offset(15)
            make.right.equalTo(-16)
        }
        label3.snp_makeConstraints { make in
            make.left.equalTo(label1)
            make.top.equalTo(label2.snp_bottom).offset(8)
            make.right.equalTo(label2)
        }
        loadData()
    }
    func loadData(){
        BoBPaymentModel.ReceivePaymentRequest(userId: IMController.shared.uid, currency:cionType ){data in
            self.receivePaymentData = data
            self.addressNumberLabel.text = data.addr
            self.countLabel.text = String(format: "%.2f",data.minAmount ?? 0)
            self.copyIcon.show()
            let idString = IMController.addFriendPrefix.append(string: data.addr)
            DispatchQueue.global().async {
                let image = CodeImageGenerator.createQRCodeImage(content: idString, size: CGSize(width: 124, height: 124), foregroundColor: UIColor.black, backgroundColor: UIColor.clear)
                DispatchQueue.main.async {
                    self.qrCodeImageView.image = image
                }
            }
        }  completionHandler:{errCode,errMsg in
            SuperToast.show(title: errMsg)
        }
    }
    func saveViewToPhotoAlbum(view:UIView) {
       
        
        guard let image = getShareCardImg(view: view) else {return}
            // 保存图片到相册
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(image:didFinishSavingWithError:contextInfo:)), nil)
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
    @objc func image(image: UIImage, didFinishSavingWithError: NSError?,contextInfo: AnyObject)

    {

        if didFinishSavingWithError != nil {
            
            print("error!")
            
            return
        }
        print("图片保存成功".localized())
        SuperToast.show(title: "图片保存成功".localized())
    }
 
    lazy var titleLabel: UILabel = {
        let r = UILabel()
        r.textColor = .black333
        r.font = .semiboldFont(16)
        r.text = "币种"
        return r
    }()
    lazy var cionTypeView: SuperSettingView = {
        let r = SuperSettingView.create(icon: UIImage(named: "mine_home_cion_c_icon")!, title: cionType,isChangeIconColor:false,ishaveMore:false, click: { [weak self] data in
        })
        r.iconView.tg_width.equal(26)
        r.iconView.tg_height.equal(26)
        r.isMediumFont()
        return r
    }()
    lazy var contentView: UIView = {
        let r = UIView()
        r.backgroundColor = .white
        r.addSubview(qrCodeImageView)
        r.addSubview(addressNumberLabel)
        r.addSubview(lineView)
        r.addSubview(shareBtn)
        r.addSubview(saveBtn)
        qrCodeImageView.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.width.height.equalTo(124)
            make.centerY.equalTo(r)
        }
        addressNumberLabel.snp_makeConstraints { make in
            make.left.equalTo(qrCodeImageView.snp_right).offset(14)
            make.top.equalTo(qrCodeImageView)
            make.right.equalTo(-16)
        }
        lineView.snp_makeConstraints { make in
            make.left.right.equalTo(addressNumberLabel)
            make.centerY.equalTo(r)
            make.height.equalTo(1)
        }
        shareBtn.snp_makeConstraints { make in
            make.left.equalTo(addressNumberLabel)
            make.bottom.equalTo(qrCodeImageView)
            make.width.equalTo(100)
            make.height.equalTo(48)
        }
        saveBtn.snp_makeConstraints { make in
            make.right.equalTo(addressNumberLabel)
            make.bottom.equalTo(qrCodeImageView)
            make.width.equalTo(100)
            make.height.equalTo(48)
        }
        return r
    }()
    lazy var qrCodeImageView: UIImageView = {
        let r = UIImageView()
        return r
    }()
    lazy var addressNumberLabel: UILabel = {
        let r = UILabel()
        r.textColor = .black333
        r.font = .semiboldFont(14)
        r.numberOfLines = 2
        r.isUserInteractionEnabled = true
        r.addSubview(copyIcon)
        copyIcon.snp_makeConstraints { make in
            make.bottom.right.equalTo(r)
            make.width.height.equalTo(16)
        }
        let tap = UITapGestureRecognizer()
        tap.rx.event.subscribe {  _ in
            UIPasteboard.general.string = self.addressNumberLabel.text
            SuperToast.show(title: "复制成功".localized())
        }
        r.addGestureRecognizer(tap)
        return r
    }()
    lazy var copyIcon: UIImageView = {
        let r = UIImageView(image: UIImage(named: "receive_payment_copy_icon"))
        r.hide()
        return r
    }()
    lazy var lineView: UIView = {
        let v = UIView()
        v.backgroundColor = .colorDivider
        return v
    }()
    lazy var shareBtn: QMUIButton = {
        let r = ViewFactoryUtil.linkButton("分享地址".localized())
        r.setTitleColor(.primaryColor, for: .normal)
        r.titleLabel?.font = .mediumFont(16)
        r.border(.primaryColor,borderWidth: 1,cornerRadius: 24)
        r.rx.tap.subscribe(onNext: { [self] in
           let vc = BoBShareReceivePaymentQrCodeViewController()
            vc.receivePaymentData = receivePaymentData
            vc.cionType = cionType
            self.navigationController?.pushViewController(vc, animated: true)
        }).disposed(by: rx.disposeBag)
        return r
    }()
    lazy var saveBtn: QMUIButton = {
        let r = ViewFactoryUtil.linkButton("保存二维码".localized())
        r.setTitleColor(.white, for: .normal)
        r.titleLabel?.font = .mediumFont(16)
        r.backgroundColor = .primaryColor
        r.corner(24)
        r.rx.tap.subscribe(onNext: { [self] in
            saveViewToPhotoAlbum(view: qrCodeImageView)
        }).disposed(by: rx.disposeBag)
        return r
    }()
    lazy var label1: UILabel = {
        let r = UILabel()
        r.textColor = .black333
        r.font = .regularFont(16)
        r.text = "最小充值数"
        return r
    }()
    lazy var countLabel: UILabel = {
        let r = UILabel()
        r.textColor = .primaryColor
        r.font = .regularFont(16)
        return r
    }()
    lazy var cionLabel: UILabel = {
        let r = UILabel()
        r.textColor = .black333
        r.font = .regularFont(16)
        r.text = cionType
        return r
    }()
    lazy var label2: UILabel = {
        let r = UILabel()
        r.textColor = .black333
        r.font = .regularFont(16)
        r.text = "该地址仅支持 " + cionType + "收款。"
        return r
    }()
    lazy var label3: UILabel = {
        let r = UILabel()
        r.textColor = .black333
        r.font = .regularFont(16)
        r.numberOfLines = 0
        r.text = "请勿用于其他币种，否则资产将不可找回"
        return r
    }()
}
