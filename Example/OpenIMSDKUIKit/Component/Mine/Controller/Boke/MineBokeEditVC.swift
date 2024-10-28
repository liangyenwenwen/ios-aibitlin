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

class MineBokeEditVC: BaseTitleController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    private let _viewModel = MineViewModel()
    var url: String = ""
    var isEdit: Bool = false
    var blogItem: blogDetailItem?
    
    override func initViews() {
        super.initViews()
        setBackGroundColor(.colorBackgroundAPP)
        initLinearLayoutSafeArea()

        title = "MeBlog".localized()
        
        container.tg_padding = UIEdgeInsets(top: PADDING_MEDDLE, left: PADDING_MEDDLE, bottom: PADDING_MEDDLE, right: PADDING_MEDDLE)
        container.addSubview(topContentView)
        
        topContentView.addSubview(iconView)
        topContentView.addSubview(ViewFactoryUtil.smallDivider())
        topContentView.addSubview(nameView)
        topContentView.addSubview(ViewFactoryUtil.smallDivider())
        topContentView.addSubview(addressView)
        topContentView.addSubview(ViewFactoryUtil.smallDivider())
        topContentView.addSubview(introView)
        
        
//        let view = UIView()
//        view.tg_height.equal(.fill)
//        view.tg_width.equal(.fill)
//        container.addSubview(view)
        
//        container.addSubview(trueBtn)
        
        superFooterContainerContainer.tg_padding = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        superFooterContainerContainer.addSubview(trueBtn)
        
        
        bindData()
        
        if isEdit {
            addressView.textFieldView.text = blogItem?.userBlogUrl
            iconView.changeIcon.show(blogItem?.userBlogIcon)
            url = blogItem?.userBlogIcon ?? ""
            nameView.textFieldView.text = blogItem?.userBlogName
            introView.textView.text = blogItem?.userBlogIntro
        }
    }

    lazy var topContentView: TGLinearLayout = {
        let r = TGLinearLayout(.vert)
        r.tg_width.equal(.fill)
        r.tg_height.equal(.wrap)
        r.tg_space = 1
        r.corner(MEDDLE_RADIUS)
        r.backgroundColor = .white
        
        return r
    }()
    
    lazy var addressView: SuperSettingView = {
        let r = SuperSettingView.createInput("地址".localized(), placeholder: " 请输入以https://开头的地址".localized())
        r.needLimitLength(length: 255)
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
    
    
    
//    private lazy var _photoHelper: PhotoHelper = {
//        let v = PhotoHelper()
//        v.setConfigToPickAvatar()
//        v.didPhotoSelected = { [weak self] (images: [UIImage], _: [PHAsset]) in
//            guard var first = images.first else { return }
//            ProgressHUD.animate()
//            first = first.compress(expectSize: 20 * 1024)
//            let result = FileHelper.shared.saveImage(image: first)
//            
//            if result.isSuccess {
//                IMController.shared.uploadFile(fullPath: result.fullPath) { [weak self] progress in
//                    
//                } onSuccess: { [weak self] url in
//                    if let url = url {
//                        print(url)
//                        self?.url = url
//                        self?.iconView.changeIcon.image = first
//                        
//                    }
//                    
//                    ProgressHUD.dismiss()
//                }
//
//            } else {
//                
//                ProgressHUD.dismiss()
//            }
//        }
//        
//        v.didCameraFinished = { [weak self] (photo: UIImage?, _: URL?) in
//            guard let sself = self else { return }
//            if var photo {
//                ProgressHUD.animate()
//                
//                photo = photo.compress(expectSize: 20 * 1024)
//                let result = FileHelper.shared.saveImage(image: photo)
//                if result.isSuccess {
//                    IMController.shared.uploadFile(fullPath: result.fullPath) { [weak self] progress in
//                        
//                    } onSuccess: { [weak self] url in
//                        if let url = url {
//                            print(url)
//                            self?.url = url
//                            self?.iconView.changeIcon.image = photo
//                            
//                        }
//                        ProgressHUD.dismiss()
//                    }
//                }
//                
//            }
//        }
//        return v
//    }()
    private lazy var _photoHelper: PhotoHelper = {
            let v = PhotoHelper()
            v.setConfigToMultipleSelected()
            v.didPhotoSelected = { [weak self] (images: [UIImage], assets: [PHAsset]) in
                guard var first = images.first else { return }
                ProgressHUD.animate()
                first = first.compress(expectSize: 20 * 1024)
                let result = FileHelper.shared.saveImage(image: first)
                
                if result.isSuccess {
                    IMController.shared.uploadFile(fullPath: result.fullPath) { [weak self] progress in
                        
                    } onSuccess: { [weak self] url in
                        if let url = url {
                            print(url)
                            self?.url = url
                            self?.iconView.changeIcon.image = first
                            
                        }
                        
                        ProgressHUD.dismiss()
                    }

                } else {
                    
                    ProgressHUD.dismiss()
                }
            }
            
            v.didCameraFinished = { [weak self] (photo: UIImage?, videoPath: URL?) in
                guard let sself = self else { return }
                if var photo {
                    ProgressHUD.animate()
                    
                    photo = photo.compress(expectSize: 20 * 1024)
                    let result = FileHelper.shared.saveImage(image: photo)
                    if result.isSuccess {
                        IMController.shared.uploadFile(fullPath: result.fullPath) { [weak self] progress in
                            
                        } onSuccess: { [weak self] url in
                            if let url = url {
                                print(url)
                                self?.url = url
                                self?.iconView.changeIcon.image = photo
                                
                            }
                            ProgressHUD.dismiss()
                        }
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
            SuperToast.show(title: "博客图标未设置".localized())
            return
        }
        
        if !SuperStringUtil.isUrl(addressView.inputText, showTip: true) {
            SuperToast.show(title: "请输入正确网址".localized())
            return
        }
        
        
        
        if let IMUser = IMController.shared.currentUserRelay.value {
            ProgressHUD.animate()
            YFMineNetViewModel.blogAudit(userId: IMUser.userID, userBlogUrl: addressView.inputText, userBlogIcon: url, userBlogName: nameView.inputText, userBlogIntro: introView.textView.text) { errCode, errMsg in
                if errCode == 20000 {
                    ProgressHUD.dismiss()
                    self.navigationController?.popViewController(animated: true)
                    SuperToast.show(title: "success".localized())
                } else {
                    SuperToast.show(title: "failure".localized())
                    ProgressHUD.dismiss()
                }
            }
        }
    }
    
    func editBlog() {
        let paramters : [String: Any] = ["userId": blogItem!.userId!,
                         "userBlogUrl": addressView.inputText!,
                         "userBlogIcon": url,
                         "userBlogName": nameView.inputText!,
                         "userBlogIntro": introView.textView.text!,
                         "sign": blogItem!.sign!,
                         "userBlogId": blogItem!.id!]
        
        YFMineNetViewModel.editBlog(paramters: paramters) { errCode, errMsg in
            if errCode == 20000 {
                ProgressHUD.dismiss()
                self.navigationController?.popViewController(animated: true)
                SuperToast.show(title: "success".localized())
            } else {
                SuperToast.show(title: "failure".localized())
                ProgressHUD.dismiss()
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
        
        
        _photoHelper.setConfigToMultipleSelected(forVideo: false, maxSelectCount: 1)
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
                  
                  image = image.compress(expectSize: 20 * 1024)
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
