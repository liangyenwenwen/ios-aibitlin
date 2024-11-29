//
//  BoBPrimaryRealNameViewController.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/11/20.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Foundation
import OUICore
import ProgressHUD



class BoBPrimaryRealNameViewController:UIViewController{
    var scrollView: UIScrollView!
    var chooseType:Int = 0 //0是正面，1是反面
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = IMController.shared.certificationLevel == 0 ? "初级实名认证" : "高级实名认证"
        scrollView = UIScrollView()
        view.addSubview(scrollView)
        scrollView.addSubview(idTitleLabel)
        scrollView.addSubview(frontIdCardView)
        scrollView.addSubview(backIdCardView)
        scrollView.addSubview(idContentTitleLabel)
        scrollView.addSubview(idContentView)
        idTitleLabel.frame = CGRect(x: 16, y: 16, width: self.view.frame.width-32, height: 20)
        frontIdCardView.frame = CGRect(x: 16, y: 54, width: self.view.frame.width-32, height: 168)
        backIdCardView.frame = CGRect(x: 16, y: 238, width: self.view.frame.width-32, height: 168)
        idContentTitleLabel.frame = CGRect(x: 16, y: 426, width: self.view.frame.width-32, height: 20)
        idContentView.frame = CGRect(x: 16, y: 474, width: self.view.frame.width-32, height: 116)
        view.addSubview(sumbitBtn)
        scrollView.snp_makeConstraints { make in
            make.left.equalTo(0)
            make.width.equalTo(kScreenWidth)
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(sumbitBtn.snp_top).offset(-20)
        }
        sumbitBtn.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.height.equalTo(48)
            make.bottom.equalTo(view.snp_bottomMargin)
        }
        
        scrollView.contentSize = CGSize(width: kScreenWidth, height: 600)
    }
    @objc func chooseIdCardImage() {
        _photoHelper.setConfigToMultipleSelected(forVideo: false, maxSelectCount: 1)
        _photoHelper.showSelectMetaSheet(byController: self)
    }
    private lazy var _photoHelper: PhotoHelper = {
            let v = PhotoHelper()
            v.setConfigToMultipleSelected()
            v.didPhotoSelected = { [weak self] (images: [UIImage], assets: [PHAsset]) in
                guard var photo = images.first else { return }
                self?.upLoadIdCardImage(idCardImage: photo)
            }
            
            v.didCameraFinished = { [weak self] (photo: UIImage?, videoPath: URL?) in
                guard let sself = self else { return }
                if var photo {
                    self?.upLoadIdCardImage(idCardImage: photo)
                }
            }
        return v
        }()
    func upLoadIdCardImage(idCardImage:UIImage){
        if chooseType == 0{
            let result = FileHelper.shared.saveImage(image: idCardImage)
            ProgressHUD.animate()
            IMController.shared.uploadFile(fullPath: result.fullPath) { [weak self] progress in
                
            } onSuccess: { [weak self] url in
                ProgressHUD.dismiss()
                if let url = url {
                    self?.frontIdCardView.idCardImageView.image = idCardImage
                    self?.getIdCardInfo(url: url)
                }else{
                    SuperToast.show(title: "上传失败")
                }
            }
            
        }else{
            backIdCardView.idCardImageView.image = idCardImage
        }
    }
    func getIdCardInfo(url:String){
        BoBRealNameModel.getIdCardInfo(userId:IMController.shared.uid, image: url){ [weak self] data in
            self?.idTitleLabel.show()
            self?.idContentView.show()
            self?.addressLabel.text = data.nation
            self?.nameLabel.text = data.name
            self?.idCardLabel.text = data.cardId
        }completionHandler: {errCode, errMsg in
            SuperToast.show(title: errMsg)
        }
    }
    lazy var idTitleLabel:UILabel = {
        let r = UILabel()
        r.font = UIFont(name: "PingFangSC-Semibold", size: 18)
        r.textColor = .black333
        r.text = "上传身份证"
        return r
    }()
    lazy var frontIdCardView:cardItemView = {
        let r = cardItemView()
        r.bindData(title: "头像面", subTitle: "上传您身份证头像面", idCardImage: UIImage(named: "real_name_front_IdCard"))
        let tap = UITapGestureRecognizer()
        tap.rx.event.subscribe {  _ in
            self.chooseType = 0
            self.chooseIdCardImage()
        }
        r.addGestureRecognizer(tap)
        return r
    }()
    lazy var backIdCardView:cardItemView = {
        let r = cardItemView()
        r.bindData(title: "国徽面", subTitle: "上传您身份证国徽面", idCardImage: UIImage(named: "real_name_back_IdCard"))
        let tap = UITapGestureRecognizer()
        tap.rx.event.subscribe {  _ in
            self.chooseType = 1
            self.chooseIdCardImage()
        }
        r.addGestureRecognizer(tap)
        return r
    }()
    lazy var idContentTitleLabel:UILabel = {
        let r = UILabel()
        r.font = UIFont(name: "PingFangSC-Semibold", size: 18)
        r.textColor = .black333
        r.text = "请确认身份信息"
        r.hide()
        return r
    }()
    lazy var idContentView:UIView = {
        let r = UIView()
        r.backgroundColor = .init(hexString: "#FBFBFD")
        r.hide()
        r.border(.init(hexString: "#F5F5F5"),borderWidth: 1,cornerRadius: 8)
        r.addSubview(addressTitleLabel)
        r.addSubview(addressLabel)
        r.addSubview(nameTitleLabel)
        r.addSubview(nameLabel)
        r.addSubview(idCardTitleLabel)
        r.addSubview(idCardLabel)
        addressTitleLabel.snp_makeConstraints { make in
            make.left.equalTo(20)
            make.top.equalTo(16)
            make.width.equalTo(74)
        }
        addressLabel.snp_makeConstraints { make in
            make.left.equalTo(addressTitleLabel.snp_right).offset(10)
            make.right.equalTo(-20)
            make.centerY.equalTo(addressTitleLabel.snp_centerY)
        }
        nameTitleLabel.snp_makeConstraints { make in
            make.left.width.equalTo(addressTitleLabel)
            make.centerY.equalTo(r.snp_centerY)
        }
        nameLabel.snp_makeConstraints { make in
            make.left.right.equalTo(addressLabel)
            make.centerY.equalTo(nameTitleLabel.snp_centerY)
        }
        idCardTitleLabel.snp_makeConstraints { make in
            make.left.width.equalTo(addressTitleLabel)
            make.bottom.equalTo(r.snp_bottom).offset(-16)
        }
        idCardLabel.snp_makeConstraints { make in
            make.left.right.equalTo(addressLabel)
            make.centerY.equalTo(idCardTitleLabel.snp_centerY)
        }
        
        return r
    }()
    lazy var addressTitleLabel:UILabel = {
        let r = UILabel()
        r.font = UIFont(name: "PingFangSC-Regular", size: 16)
        r.textColor = .black666
        r.text = "地区"
        return r
    }()
    lazy var nameTitleLabel:UILabel = {
        let r = UILabel()
        r.font = UIFont(name: "PingFangSC-Regular", size: 16)
        r.textColor = .black666
        r.text = "姓名"
        return r
    }()
    lazy var idCardTitleLabel:UILabel = {
        let r = UILabel()
        r.font = UIFont(name: "PingFangSC-Regular", size: 16)
        r.textColor = .black666
        r.text = "身份证号"
        return r
    }()
    lazy var addressLabel:UILabel = {
        let r = UILabel()
        r.font = UIFont(name: "PingFangSC-Regular", size: 16)
        r.textColor = .black333
        return r
    }()
    lazy var nameLabel:UILabel = {
        let r = UILabel()
        r.font = UIFont(name: "PingFangSC-Regular", size: 16)
        r.textColor = .black333
        return r
    }()
    lazy var idCardLabel:UILabel = {
        let r = UILabel()
        r.font = UIFont(name: "PingFangSC-Regular", size: 16)
        r.textColor = .black333
        return r
    }()
    lazy var sumbitBtn: QMUIButton = {
        let r = ViewFactoryUtil.linkButton(IMController.shared.certificationLevel == 0 ? "提交" : "下一步")
        r.setTitleColor(.white, for: .normal)
        r.corner(24)
        r.titleLabel?.font = UIFont(name: "PingFangSC-Medium", size: 16)
        r.backgroundColor = .primaryColor
        r.rx.tap.subscribe(onNext: { [self] in
           
            if self.addressLabel.text?.isEmpty == true || self.nameLabel.text?.isEmpty == true || self.idCardLabel.text?.isEmpty == true{
                SuperToast.show(title: "请上传身份证头像面")
                return
            }
            if self.backIdCardView.idCardImageView.image == UIImage(named: "real_name_back_IdCard"){
                SuperToast.show(title: "请上传身份证国徽面")
                return
            }
            if IMController.shared.certificationLevel == 0 {
                //提交
                BoBRealNameModel.primaryRealNameAuthenticationRequest(userId: IMController.shared.uid, name: self.nameLabel.text!, cardId: self.idCardLabel.text!){errCode, errMsg in
                    if errCode == 20000{
                        SuperToast.show(title: "认证成功")
                        IMController.shared.certificationLevel = 1
                        if (self.navigationController?.viewControllers.count)! > 2{
                            let vc = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)!-3]
                            self.navigationController?.popToViewController(vc!, animated: true)
                        }else{
                            self.navigationController?.popToRootViewController(animated: true)
                        }                        
                    }else{
                        SuperToast.show(title: errMsg)
                    }
                    
                }
//                BoBRealNameModel.getIdCardInfo11(userId:IMController.shared.uid, image: ""){ [weak self] data in
//                    self?.idTitleLabel.show()
//                    self?.idContentView.show()
//                    self?.addressLabel.text = data.nation
//                    self?.nameLabel.text = data.name
//                    self?.idCardLabel.text = data.cardId
//                }completionHandler: {errCode, errMsg in
//                    SuperToast.show(title: String(errCode).localized())
//                }
                
            }else{
                //人脸认证
            }
        }).disposed(by: rx.disposeBag)
        return r
    }()
}
class cardItemView:UIView{
    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func initViews()  {
        self.backgroundColor = .init(hexString: "#FBFBFD")
        self.border(.init(hexString: "#F5F5F5"),borderWidth: 1,cornerRadius: 8)
        addSubview(titleLabel)
        addSubview(subLabel)
        addSubview(idCardImageView)
        titleLabel.snp_makeConstraints { make in
            make.left.equalTo(20)
            make.top.equalTo(56)
            make.right.equalTo(idCardImageView.snp_left).offset(-10)
        }
        subLabel.snp_makeConstraints { make in
            make.left.right.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp_bottom).offset(20)
        }
        idCardImageView.snp_makeConstraints { make in
            make.centerY.equalTo(self.snp_centerY)
            make.right.equalTo(-20)
            make.width.equalTo(178)
            make.height.equalTo(120)
        }
        
    }
    func bindData(title:String,subTitle:String,idCardImage:UIImage?){
        titleLabel.text = title
        subLabel.text = subTitle
        idCardImageView.image = idCardImage
    }
    lazy var titleLabel: UILabel = {
        let r = UILabel()
        r.font = UIFont(name: "PingFangSC-Semibold", size: 18)
        r.textColor = .black333
        r.numberOfLines = 0
        return r
    }()
    lazy var subLabel: UILabel = {
        let r = UILabel()
        r.font = UIFont(name: "PingFangSC-Regular", size: 14)
        r.textColor = .black666
        r.numberOfLines = 0
        return r
    }()
    lazy var idCardImageView: UIImageView = {
        let r = UIImageView()
        r.corner(8)
        return r
    }()
}
