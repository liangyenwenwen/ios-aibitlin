//
//  BoBSendAppealViewController.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/12/26.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Foundation
import TangramKit
import OUICore
import ProgressHUD
import MMBAlertsPickers
import RxSwift
import RxCocoa
class BoBSendAppealViewController: BaseTitleController {
    var uploadAppealSuccessBlock:(()->())!
    var code:String = ""
    var appealImgs: String = ""
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    override func initViews() {
        super.initViews()
        setBackGroundColor(.colorBackgroundAPP)
        initScrollSafeArea()
        title = "发起申诉"
        scrollViewContainer.tg_padding = UIEdgeInsets(top: 0, left: PADDING_OUTER, bottom: 0, right: PADDING_OUTER)
        superFooterContainerContainer.addSubview(bottomView)
        scrollViewContainer.addSubview(orderTitleView)
        scrollViewContainer.addSubview(appealDetailTitleLabel)
        scrollViewContainer.addSubview(bgView)
        scrollViewContainer.addSubview(imageTitleLabel)
        scrollViewContainer.addSubview(picView)
        scrollViewContainer.addSubview(tipLabel)
        refreshUI()
        let tap = UITapGestureRecognizer()
        tap.rx.event.subscribe {  _ in
            self.view.endEditing(true)
        }.disposed(by: rx.disposeBag)
        self.view.addGestureRecognizer(tap)
    }
    func uploadImageNetWork(index: Int) {
       
        if index < datum.count {
           
            ProgressHUD.animate()
            let result = FileHelper.shared.saveImage(image: datum[index] as! UIImage)
            IMController.shared.uploadFile(fullPath: result.fullPath) { [weak self] progress in
                
            } onSuccess: { [weak self] url in
                if let url = url {
                   
                    if index > 0 {
                        self?.appealImgs = self!.appealImgs + "," + url
                    } else {
                        self?.appealImgs = url
                    }
                    self?.uploadImageNetWork(index: index + 1)
                    print(self!.appealImgs)
                    
                }
                ProgressHUD.dismiss()
            }

        } else {
            print("\n\n\n所有图片上传完成")
            toAppealNet()
        }
    }
    func toAppealNet(){
        BoBBuyAndSellCionModel.UpLoadAppealRequest(code: code, representationDetails: textView.text ?? "", screenshot: appealImgs) {[weak self] errCode,errMsg in
            if errCode == 620000{
                SuperToast.show(title: "提交成功")
                if self?.uploadAppealSuccessBlock != nil{
                    self?.uploadAppealSuccessBlock()
                }
                self?.navigationController?.popViewController(animated: true)
            }else{
                SuperToast.show(title: String(errCode) + "：" + String(errCode).localized())
            }
        }
    }
    @objc func addPic(gesture: UITapGestureRecognizer) {
        self.view.endEditing(true)
        print(gesture.view?.tag ?? "11111")
        if gesture.view!.tag - 6000 == datum.count {
            _photoHelper.setConfigToMultipleSelected(forVideo: false, maxSelectCount: 9 - datum.count)
            _photoHelper.showSelectMetaSheet(byController: self)
        }
    }
    
    private lazy var _photoHelper: PhotoHelper = {
        let v = PhotoHelper()
//        v.setConfigToPickAvatar(9)
        v.setConfigToMultipleSelected()

        
        v.didPhotoSelected = { [weak self] (images: [UIImage], _: [PHAsset]) in
            guard var first = images.first else { return }
            self?.datum = self!.datum + images
            self?.refreshUI()
        }
        
        v.didCameraFinished = { [weak self] (photo: UIImage?, _: URL?) in
            guard let sself = self else { return }
            if var photo {
                self?.datum.append(photo)
                self?.refreshUI()
            }
        }
        return v
    }()
    func refreshUI() {
        for i in 0...8 {
            let imageView = view.viewWithTag(i + 6000) as! addUploadImageView
            let btn = imageView.viewWithTag(i + 7000) as! QMUIButton
            if datum.count == 0 && i == 0 {
                imageView.show()
                imageView.upLoadImageView.image = nil
                btn.hide()
            } else if i <= datum.count && datum.count < 9 {
                imageView.show()
                if i == datum.count {
                    imageView.upLoadImageView.image = nil
                    btn.hide()
                } else {
                    imageView.upLoadImageView.image = datum[i] as? UIImage
                    btn.show()
                }
            } else if datum.count == 9{
                imageView.show()
                imageView.upLoadImageView.image = datum[i] as? UIImage
                btn.show()
            } else {
                imageView.hide()
                btn.hide()
            }
        }
    }
    @objc func deleteBtnClick(_ sender: UIButton) {
        let tag = sender.tag - 7000
        datum.remove(at: tag)
        refreshUI()
        self.view.endEditing(true)
    }
    func getAttribute(str:String) -> NSMutableAttributedString{
        let attachment = NSTextAttachment()
        attachment.image = UIImage(named: "receive_payment_copy_icon")
        attachment.bounds = CGRect(x: 0, y: -3.0, width: 16, height: 16)
        let str1 = str + " "
        let attributedString = NSMutableAttributedString(string: str1)
        let attachmentString = NSAttributedString(attachment: attachment)
        attributedString.insert(attachmentString, at: str1.length)
        return attributedString
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
    lazy var orderTitleView: buyAndSellTitleView = {
        let r = buyAndSellTitleView()
        r.tg_top.equal(10)
        r.tg_left.equal(0)
        r.tg_right.equal(0)
        r.tg_height.equal(28)
        r.buyCountTitleLabel.text = "订单号"
        r.buyCounLabel.attributedText = getAttribute(str: code)
        r.buyCounLabel.font = .mediumFont(14)
        r.buyCounLabel.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer()
        tap.rx.event.subscribe { [weak self] _ in
            UIPasteboard.general.string = self?.code ?? ""
            SuperToast.show(title: "复制成功".localized())
            self?.view.endEditing(true)
        }.disposed(by: rx.disposeBag)
        r.addGestureRecognizer(tap)
        return r
    }()
    lazy var appealDetailTitleLabel: UILabel = {
        let r = UILabel()
        r.tg_top.equal(12)
        r.tg_left.equal(0)
        r.tg_right.equal(0)
        r.tg_height.equal(18)
        r.textColor = .black333
        r.font = .mediumFont(16)
        r.attributedText = setupAttributedText(text: "申诉详情 *", targetWords: ["*"], color: .init(hexString: "#F32525"))
        return r
    }()
    lazy var bgView: UIView = {
        let r = UIView()
        r.tg_top.equal(10)
        r.tg_left.equal(0)
        r.tg_right.equal(0)
        r.tg_height.equal(190)
        r.backgroundColor = .white
        r.corner(8)
        r.addSubview(textView)
        textView.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.top.equalTo(13)
            make.bottom.equalTo(-13)
        }
        return r
    }()
    lazy var textView: QMUITextView = {
        let r = QMUITextView()
        r.maximumTextLength = 500
        r.placeholder = "请通过5到500个字描述您要申诉的问题"
        r.placeholderColor = .placeholderText
        r.font = .mediumFont(16)
        r.tintColor = .black333
        return r
    }()
    lazy var imageTitleLabel: UILabel = {
        let r = UILabel()
        r.tg_top.equal(16)
        r.tg_left.equal(0)
        r.tg_right.equal(0)
        r.tg_height.equal(18)
        r.textColor = .black333
        r.font = .mediumFont(16)
        r.attributedText = setupAttributedText(text: "相关截图 *", targetWords: ["*"], color: .init(hexString: "#F32525"))
        return r
    }()
    lazy var picView: TGRelativeLayout = {
        let r = TGRelativeLayout()
        r.tg_top.equal(10)
        r.tg_width.equal(.fill)
        r.tg_height.equal(.wrap)
        let imageWidth = (UIScreen.main.bounds.width - 12 - 32) / 3
        for i in 0...8 {
            let imageView = addUploadImageView()
            let left = Int(i % 3) * Int(imageWidth + 8)
            let top = Int(i / 3) * Int(imageWidth + 8)
      
            imageView.tg_left.equal(left)
            imageView.tg_top.equal(top)
            imageView.tg_width.equal(imageWidth)
            imageView.tg_height.equal(imageWidth)
            imageView.tag = 6000 + i
            
            let gesTap = UITapGestureRecognizer(target: self, action: #selector(addPic(gesture:)))
            imageView.isUserInteractionEnabled = true
            imageView.addGestureRecognizer(gesTap)
            r.addSubview(imageView)
            let deleteBtn = ViewFactoryUtil.imageBtn(R.image.report_icon_delete()!, 20)
            deleteBtn.frame = CGRect(x: imageWidth-20, y: 0, width: 20, height: 20)
            deleteBtn.tag = 7000+i
            deleteBtn.addTarget(self, action: #selector(deleteBtnClick(_:)), for: .touchUpInside)
            imageView.addSubview(deleteBtn)
        }
        return r
    }()
    lazy var tipLabel: UILabel = {
        let r = UILabel()
        r.tg_top.equal(19)
        r.tg_left.equal(0)
        r.tg_right.equal(0)
        r.tg_height.equal(18)
        r.textColor = .init(hexString: "#F32525")
        r.font = .regularFont(16)
        r.text = "提示：一笔订单只能申诉一次"
        return r
    }()
    lazy var bottomView: TGLinearLayout = {
        let r = TGLinearLayout(.horz)
        r.tg_width.equal(.fill)
        r.tg_height.equal(66)
        r.tg_hspace = 18
        r.tg_padding = UIEdgeInsets(top: 10, left: PADDING_OUTER, bottom: 10, right: PADDING_OUTER)
        r.addSubview(cancleBtn)
        r.addSubview(sureBtn)
        return r
    }()
    lazy var cancleBtn: QMUIButton = {
        let r = ViewFactoryUtil.linkButton("取消")
        r.tg_height.equal(48)
        r.tg_width.equal((kScreenWidth-32-18)/2)
        r.setTitleColor(.primaryColor, for: .normal)
        r.titleLabel?.font = .mediumFont(16)
        r.border(.primaryColor,borderWidth: 1,cornerRadius: 24)
        r.rx.tap.subscribe(onNext: { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }).disposed(by: rx.disposeBag)
        return r
    }()
    lazy var sureBtn: QMUIButton = {
        let r = ViewFactoryUtil.linkButton("确定")
        r.tg_height.equal(48)
        r.tg_width.equal((kScreenWidth-32-18)/2)
        r.setTitleColor(.white, for: .normal)
        r.titleLabel?.font = .mediumFont(16)
        r.backgroundColor = .primaryColor
        r.corner(24)
        r.rx.tap.subscribe(onNext: { [weak self] in
            if self?.textView.text.length == 0{
                SuperToast.show(title: "请填写申诉内容")
                return
            }else if self?.textView.text.length ?? 0 < 5{
                SuperToast.show(title: "申诉内容不能少于5个字")
                return
            }
            if self?.datum.count == 0{
                SuperToast.show(title: "请上传申诉截图")
                return
            }
            self?.uploadImageNetWork(index: 0)
        }).disposed(by: rx.disposeBag)
        return r
    }()
}
class addUploadImageView:UIView{
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(upLoadBgView)
        upLoadBgView.snp_makeConstraints { make in
            make.edges.equalTo(self)
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var upLoadBgView: UIImageView = {
        let r = UIImageView(image: UIImage(named: "order_detail_upload_appeal_icon"))
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
            make.centerY.equalTo(r.snp_centerY).offset(-10)
            make.width.height.equalTo(26)
        }
        label.snp_makeConstraints { make in
            make.top.equalTo(icon.snp_bottom).offset(7)
            make.left.equalTo(6)
            make.right.equalTo(-6)
            make.height.equalTo(13)
        }
        r.addSubview(upLoadImageView)
        upLoadImageView.snp_makeConstraints { make in
            make.left.right.top.bottom.equalTo(r)
        }
        return r
    }()
    lazy var upLoadImageView: UIImageView = {
        let r = UIImageView()
        r.contentMode = .scaleAspectFill
        return r
    }()
    
}


