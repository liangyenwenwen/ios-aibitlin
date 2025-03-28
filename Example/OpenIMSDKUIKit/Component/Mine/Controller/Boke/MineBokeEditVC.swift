//
//  MineBokeEditVC.swift
//  MyCloudMusic
//
//  Created by mac on 2024/5/6.
//

import UIKit
import TangramKit
import OUICore
import ProgressHUD
import RxSwift
import RxCocoa
import IQKeyboardManagerSwift

class MineBokeEditVC: BaseTitleController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    private let _viewModel = MineViewModel()
    var url: String = ""
    var isEdit: Bool = false
    var blogItem: myBlogShowBlogPOModel?
    var isSetPwd:Bool = false
    var refreshMineBokeList : (()->Void)!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enable = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enable = false
    }
    override func initViews() {
        super.initViews()
        setBackGroundColor(.colorBackgroundAPP)
        initLinearLayoutSafeArea()

        title = "MeWebsite".localized()
        
        container.tg_padding = UIEdgeInsets(top: PADDING_MEDDLE, left: PADDING_MEDDLE, bottom: PADDING_MEDDLE, right: PADDING_MEDDLE)
        container.tg_space = PADDING_OUTER
        container.addSubview(ViewFactoryUtil.sectionTilteLbael("基础信息".localized()))
        
        container.addSubview(topContentView)
        
        container.addSubview(ViewFactoryUtil.sectionTilteLbael("隐私访问".localized(),top: 14))
        container.addSubview(privacyAccessContentView)
        
        superFooterContainerContainer.tg_padding = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        superFooterContainerContainer.addSubview(trueBtn)
        
        
        bindData()
        
        if isEdit {
            if blogItem?.base?.info?.pwd?.length ?? 0 > 0 {
                isSetPwd = true
                privacyAccessSwitchView.superSwitch.isOn = true
                lineView.isHidden = false
                pwdView.isHidden = false
                pwdView.textFieldView.text = blogItem?.base?.info?.pwd
                let key = (blogItem?.base?.info?.pwd ?? "") + "0000000000"
                let ivs = "0000000000000000"
                if let de = try? AESEncyptUtil.decrypt_AES_CBC(decryptText: blogItem?.base?.info?.url ?? "", key: key, ivs: ivs){
                    addressView.textFieldView.text = de
                }
                
                
            }else{
                addressView.textFieldView.text = blogItem?.base?.info?.url
            }
            iconView.changeIcon.show(blogItem?.base?.info?.logo)
            url = blogItem?.base?.info?.logo ?? ""
            nameView.textFieldView.text = blogItem?.base?.info?.name
            introView.textView.text = blogItem?.base?.info?.mark
        }
    }

    lazy var topContentView: TGLinearLayout = {
        let r = TGLinearLayout(.vert)
        r.tg_width.equal(.fill)
        r.tg_height.equal(.wrap)
        r.tg_space = 1
        r.corner(MEDDLE_RADIUS)
        r.backgroundColor = .white
        r.addSubview(iconView)
        r.addSubview(ViewFactoryUtil.smallDivider())
        r.addSubview(nameView)
        r.addSubview(ViewFactoryUtil.smallDivider())
        r.addSubview(addressView)
        r.addSubview(ViewFactoryUtil.smallDivider())
        r.addSubview(introView)
        return r
    }()
    
    lazy var addressView: SuperSettingView = {
        let r = SuperSettingView.createInput("地址".localized(), placeholder: " 请输入以https://开头的地址".localized())
        r.needLimitLength(length: 255)
        r.textFieldView.keyboardType = .URL
        r.textFieldView.rx.controlEvent(.editingDidEnd).subscribe(onNext: { [unowned self] in
            let str = r.textFieldView.text?.replacingOccurrences(of: " ", with: "").lowercased()
            r.textFieldView.text = str
        }).disposed(by: rx.disposeBag)

        return r
    }()
    
    lazy var iconView: SuperSettingView = {
        let r = SuperSettingView.createSetIcon("图标".localized()) { [weak self] data in
            self?.changeAvatar()
        }
        r.avatarImageView.hide()
        r.changeIcon.show()
        r.changeIcon.image = R.image.empty_blog_icon()!
        r.changeIcon.corner(4)
//        r.changeIcon.backgroundColor = .init(hexString: "#f0f2f5")
        return r
    }()
    
    lazy var nameView: SuperSettingView = {
        let r = SuperSettingView.createInput("名称".localized())
//        r.textFieldView.backgroundColor = .red
        r.needLimitLength(length: 50)
        return r
    }()
    
    lazy var introView: SuperSettingView = {
//        let r = SuperSettingView.createInputTextView("简介".localized())
//        r.tg_height.equal(92)
//        r.titleView.tg_top.equal(8)
//        r.tg_gravity = .vert.top
//        r.tg_height.equal(80)
//        
////        r.textView.backgroundColor = .red
//        
//        r.textView.textContainerInset = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 13)
//        
//        return r
        
        let r = SuperSettingView.createInputTextView("简介".localized(), min: 75)
        r.isMediumFont()
//        r.titleView.changeColor(changeColorStr: "*")
        r.tg_height.equal(110)
        r.tg_gravity = .vert.top
        r.titleView.tg_top.equal(21)
        r.textView.tg_top.equal(14)
        r.textView.tg_height.equal(80)
        r.textView.tg_width.equal(.fill)
        r.needLimitLengthAboutTextView(length: 500)
        return r
    }()
    lazy var privacyAccessContentView: TGLinearLayout = {
        let r = TGLinearLayout(.vert)
        r.tg_width.equal(.fill)
        r.tg_height.equal(.wrap)
        r.tg_space = 1
        r.corner(MEDDLE_RADIUS)
        r.backgroundColor = .white
        r.addSubview(privacyAccessSwitchView)
        r.addSubview(lineView)
        r.addSubview(pwdView)
        lineView.isHidden = !isSetPwd
        pwdView.isHidden = !isSetPwd
        return r
    }()
    lazy var privacyAccessSwitchView: SuperSettingView = {
        let r = SuperSettingView.create(title: "开启隐私访问".localized()) { data in
            
        } switchChanged: { data in
            self.isSetPwd = data.isOn
            self.lineView.isHidden = !self.isSetPwd
            self.pwdView.isHidden = !self.isSetPwd
        }
        r.isMediumFont()
        return r
    }()
    lazy var lineView: UIView = {
        let r = ViewFactoryUtil.smallDivider()
        return r
    }()
    lazy var pwdView: SuperSettingView = {
        let r = SuperSettingView.createInput("隐私密码".localized(),placeholder: "请输入隐私访问密码".localized())
//        r.textFieldView.backgroundColor = .red
        r.needLimitLength(length: 6)
        r.textFieldView.keyboardType = .numberPad
        return r
    }()
    
    lazy var bottomBtn: QMUIButton = {
        let r = ViewFactoryUtil.primaryHalfFilletButton()
        r.setTitle("确定", for: .normal)
        return r
    }()
    
    lazy var trueBtn: QMUIButton = {
        let  r = ViewFactoryUtil.primaryHalfFilletButton()
        r.tg_top.equal(20)
        r.setTitle("Confirm".localized(), for: .normal)
        r.addTarget(self, action: #selector(saveBlog), for: .touchUpInside)
        r.tg_bottom.equal(50)
        return r
    }()
    private lazy var _photoHelper: PhotoHelper = {
            let v = PhotoHelper()
//            v.setConfigToMultipleSelected()
            v.setConfigToPickAvatar()
            v.didPhotoSelected = { [weak self] (images: [UIImage], assets: [PHAsset]) in
                guard var first = images.first else { return }
                ProgressHUD.animate()
                first = first.compress(expectSize: 1500 * 1024)
                let result = FileHelper.shared.saveImage(image: first)
                
                if result.isSuccess {
                    YFMineNetViewModel.uploadImageFromPath(fileURL:NSURL(fileURLWithPath: result.fullPath) as URL) { [weak self] data in
                        ProgressHUD.dismiss()
                        self?.url = data.url ?? ""
                        self?.iconView.changeIcon.image = first
                    } completionHandler: { errCode, errMsg in
                        ProgressHUD.dismiss()
                        SuperToast.show(title: errMsg?.localized())
                    }
//                    IMController.shared.uploadFile(fullPath: result.fullPath) { [weak self] progress in
//                        
//                    } onSuccess: { [weak self] url in
//                        if let url = url {
//                            print(url)
//                            self?.url = url
//                            self?.iconView.changeIcon.image = first
//                            
//                        }
//                        
//                        ProgressHUD.dismiss()
//                    }

                } else {
                    
                    ProgressHUD.dismiss()
                }
            }
            
            v.didCameraFinished = { [weak self] (photo: UIImage?, videoPath: URL?) in
                guard let sself = self else { return }
                if var photo {
                    ProgressHUD.animate()
                    
                    photo = photo.compress(expectSize: 1500 * 1024)
                    let result = FileHelper.shared.saveImage(image: photo)
                    if result.isSuccess {
                        YFMineNetViewModel.uploadImageFromPath(fileURL:NSURL(fileURLWithPath: result.fullPath) as URL) { [weak self] data in
                            ProgressHUD.dismiss()
                            self?.url = data.url ?? ""
                            self?.iconView.changeIcon.image = photo
                        } completionHandler: { errCode, errMsg in
                            ProgressHUD.dismiss()
                            SuperToast.show(title: errMsg?.localized())
                        }
                        
                        
//                        IMController.shared.uploadFile(fullPath: result.fullPath) { [weak self] progress in
//                            
//                        } onSuccess: { [weak self] url in
//                            if let url = url {
//                                print(url)
//                                self?.url = url
//                                self?.iconView.changeIcon.image = photo
//                                
//                            }
//                            ProgressHUD.dismiss()
//                        }
                    }else{
                        ProgressHUD.dismiss()
                    }
                    
                }
            }
            return v
        }()
    
    
    override func bindData() {
        
        Observable.combineLatest(addressView.textFieldView.rx.text.orEmpty, nameView.textFieldView.rx.text.orEmpty, introView.textView.rx.text.orEmpty) {
            $0.count > 0  && $1.count > 0  && $2.count > 0
        }
        .bind(to: trueBtn.rx.isEnabled)
        .disposed(by: rx.disposeBag)
    }
    
}

extension MineBokeEditVC {
    
    
    
    
    @objc func saveBlog() {
        
        if isEdit {
            editBlog()
        } else {
            addNewBlog()
        }
       
    }
    
    
    func addNewBlog() {
        
        if url.count < 2 {
            SuperToast.show(title: "网站图标未设置".localized())
            return
        }
        
        if !SuperStringUtil.isUrl(addressView.inputText, showTip: true) {
            SuperToast.show(title: "请输入正确网址".localized())
            return
        }
        var webSiteUrl = addressView.inputText
        if isSetPwd{
            if pwdView.inputText?.isEmpty ?? true {
                SuperToast.show(title: "请输入隐私访问密码".localized())
                return
            }
            if pwdView.inputText?.length != 6 {
                SuperToast.show(title: "密码长度必须为6位数字".localized())
                return
            }
            /// 加密
            let key = pwdView.inputText! + "0000000000"
            let ivs = "0000000000000000"
            let en = try? AESEncyptUtil.encrypt_AES_CBC(encryptText: addressView.inputText!, key: key, ivs: ivs)
            if let str = en {
                webSiteUrl = str
            }else{
                SuperToast.show(title: "加密失败".localized())
                return
            }
        }
        
        
//        let pwd = "123456"
//        /// 加密
//        let key = pwd + "0000000000"
//        let ivs = "0000000000000000"
//        let en = try? AESEncyptUtil.encrypt_AES_CBC(encryptText: addressView.inputText!, key: key, ivs: ivs)
//        if let str = en {
//           print(str)
//        /// 加密
//            let de = try? AESEncyptUtil.decrypt_AES_CBC(decryptText: str, key: key, ivs: ivs)
//            print(de)
//        }
//        let de1 = try? AESEncyptUtil.decrypt_AES_CBC(decryptText: "N26AWY6mNu1crEHORakCwKPfquQnzJpEGHN386ydCRM=", key: key, ivs: ivs)

        
        
        if let IMUser = IMController.shared.currentUserRelay.value {
            ProgressHUD.animate()
            YFMineNetViewModel.blogAudit(logo: url,name:nameView.inputText, url: webSiteUrl, mark: introView.textView.text, pwd: pwdView.inputText) { errCode, errMsg in
                ProgressHUD.dismiss()
                if errCode == 200 {
                    if self.refreshMineBokeList != nil {
                        self.refreshMineBokeList!()
                    }
                    self.navigationController?.popViewController(animated: true)
                    SuperToast.show(title: "success".localized())
                } else if errCode == -1{
                    SuperToast.show(title: String(errCode).localized())
                }else{
                    SuperToast.show(title: "failure".localized())
                }
            }
        }
    }
    
    func editBlog() {
        if url.count < 2 {
            SuperToast.show(title: "网站图标未设置".localized())
            return
        }
        
        if !SuperStringUtil.isUrl(addressView.inputText, showTip: true) {
            SuperToast.show(title: "请输入正确网址".localized())
            return
        }
        var webSiteUrl = addressView.inputText
        if isSetPwd{
            if pwdView.inputText?.isEmpty ?? true {
                SuperToast.show(title: "请输入隐私访问密码".localized())
                return
            }
            if pwdView.inputText?.length != 6 {
                SuperToast.show(title: "密码长度必须为6位数字".localized())
                return
            }
            /// 加密
            let key = pwdView.inputText! + "0000000000"
            let ivs = "0000000000000000"
            let en = try? AESEncyptUtil.encrypt_AES_CBC(encryptText: addressView.inputText!, key: key, ivs: ivs)
            if let str = en {
                webSiteUrl = str
            }else{
                SuperToast.show(title: "加密失败".localized())
                return
            }
        }
        
        let paramters : [String: Any] = ["hash": blogItem!.base?.hash ?? "",
                                         "logo": url,
                                         "name": nameView.inputText ?? "",
                                         "url": webSiteUrl ?? "",
                                         "mark": introView.textView.text ?? "",
                                         "pwd": pwdView.inputText ?? ""]
        
        YFMineNetViewModel.editBlog(paramters: paramters) { errCode, errMsg in
            if errCode == 200 {
                if self.refreshMineBokeList != nil {
                    self.refreshMineBokeList!()
                }
                self.navigationController?.popViewController(animated: true)
                SuperToast.show(title: "success".localized())
            } else {
                SuperToast.show(title: errMsg?.localized())
            }
        }
    }
    
    
    func changeAvatar() {
        
//        presentSelectedPictureActionSheet { [weak self] in
//            guard let self else { return }
//            _photoHelper.presentPhotoLibrary(byController: self)
//        } cameraHandler: {[weak self] in
//            guard let self else { return }
////            _photoHelper.presentCamera(byController: self)
//            presentCamera()
//        }
        
        
//        _photoHelper.setConfigToMultipleSelected(forVideo: false, maxSelectCount: 1)
        _photoHelper.showSelectMetaSheet(byController: self)
        
        
    }
    
    
    
    //    , UIImagePickerControllerDelegate, UINavigationControllerDelegate  private let _viewModel = MineViewModel()
        
//        func presentCamera() {
//             
//
//                let imagePicker = UIImagePickerController()
//                imagePicker.delegate = self
//                imagePicker.sourceType = .camera
//                imagePicker.allowsEditing = true
//         
//                // 检查相机权限
//                if UIImagePickerController.isSourceTypeAvailable(.camera) {
//                    // 检查相机权限
//                    switch AVCaptureDevice.authorizationStatus(for: .video) {
//                    case .authorized:
//                        // 已授权，可以直接调用相机
//                        present(imagePicker, animated: true, completion: nil)
//                    case .notDetermined:
//                        // 未询问过用户授权，请求授权
//                        AVCaptureDevice.requestAccess(for: .video) { granted in
//                            if granted {
//                                DispatchQueue.main.async {
//                                    self.present(imagePicker, animated: true, completion: nil)
//                                }
//                            }
//                        }
//                    default:
//                        // 无权限，可以提示用户或者跳转到设置页面
//                        print("无权限访问相机")
//                    }
//                } else {
//                    // 设备无相机，提示用户或者进行错误处理
//                    print("设备无相机")
//                }
//            
//        }
        
        // MARK: - UIImagePickerControllerDelegate
          func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
              picker.dismiss(animated: true, completion: nil)
          }
       
          func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
              // 处理图片
              if var image = info[.editedImage] as? UIImage {
                  // 使用image
                  
                  ProgressHUD.animate()
                  
                  image = image.compress(expectSize: 1500 * 1024)
                  let result = FileHelper.shared.saveImage(image: image)
                  if result.isSuccess {
                      IMController.shared.uploadFile(fullPath: result.fullPath) { [weak self] progress in
                          
                      } onSuccess: { [weak self] url in
                          if let url = url {
                              print(url)
                              self?.url = url
                              self?.iconView.changeIcon.image = image
                              
                          }
                          ProgressHUD.dismiss()
                      }
                  }
              }
       
              picker.dismiss(animated: true, completion: nil)
          }
    
    
}
