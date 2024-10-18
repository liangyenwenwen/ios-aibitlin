//
//  YFChooseUserAvatarCard.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/10/8.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Foundation
import OUICore
import ProgressHUD

class YFChooseUserAvatarCardView: UIView, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var currentIndex: Int = -1
    var bottomHeight = 672
    var picData: [String]?
    var isHaveImg: Bool = false
    var userIconImg: UIImage?
    
    private let _viewModel = MineViewModel()
    
    lazy var bottomView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.clipsToBounds =  true
        return v
    }()
    
    lazy var topCameraImg: UIImageView = {
        let r = UIImageView()
        r.image = .init(named: "choose_avater_camera")
        r.corner(60)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(changeAvatar))
        r.isUserInteractionEnabled = true
        r.addGestureRecognizer(tap)
        return r
    }()
    
    lazy var changeIconLbl: UILabel = {
        let r = UILabel()
        r.font = .mediumFont(16)
        r.textColor = .init(hexString: "#388CEF")
        r.text = "更换头像"
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(changeAvatar))
        r.isUserInteractionEnabled = true
        r.addGestureRecognizer(tap)
        
        return r
    }()
    
    lazy var chooseIconTitleLbl: UILabel = {
        let r = UILabel()
        r.textColor = .init(hexString: "#333333")
        r.font = .mediumFont(16)
        r.text = "选择系统头像"
        return r
    }()
    
    
    lazy var refreshView: UIView = {
        let r = UIView()
        r.addSubview(refreshViewImage)
        r.addSubview(refreshViewTitle)
        let tap = UITapGestureRecognizer(target: self, action: #selector(refreshAction))
        r.addGestureRecognizer(tap)
        return r
    }()
    
    lazy var refreshViewImage: UIImageView = {
        let r = UIImageView()
        r.image = .init(named: "refresh_blue")
        return r
    }()
    
    lazy var refreshViewTitle: UILabel = {
        let r = UILabel()
        r.text = "换一批".localized()
        r.textColor = .init(hexString: "#388CEF")
        r.font = .mediumFont(16)
        return r
    }()
    
    
    
    
    
    
    
    
    lazy var trueLbl: UILabel = {
        
        let r = UILabel()
        r.textAlignment = .center
        r.text = "保存".localized()
        r.textColor = .white
        r.font = .mediumFont(14)
//        r.backgroundColor = .init(hexString: "#388CEF")
        r.backgroundColor = .init(hexString: "#eaeaea")
        r.corner(23)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(saveAction))
        r.isUserInteractionEnabled = true
        r.addGestureRecognizer(tap)
        
        return r
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .black.withAlphaComponent(0.3)
        
        
        addSubview(bottomView)
        bottomView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(self.snp.bottom)
            make.height.equalTo(672)
        }
        bottomView.layer.cornerRadius = 14
        bottomView.layer.maskedCorners  = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        bottomView.addSubview(topCameraImg)
        topCameraImg.snp.makeConstraints { make in
            make.top.equalTo(70)
            make.width.height.equalTo(120)
            make.centerX.equalToSuperview()
        }
        
        bottomView.addSubview(changeIconLbl)
        changeIconLbl.snp.makeConstraints { make in
            make.top.equalTo(topCameraImg.snp_bottom).offset(20)
            make.height.equalTo(22)
            make.centerX.equalToSuperview()
        }
        
        bottomView.addSubview(chooseIconTitleLbl)
        chooseIconTitleLbl.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(22)
            make.top.equalTo(topCameraImg.snp_bottom).offset(92)
        }
        
        
        
        let  width = (UIScreen.main.bounds.width - 29 * 2 - 6 * 4) / 5
        for index in 0..<10 {
            let systemIconImg = systemIconView()
            bottomView.addSubview(systemIconImg)
            systemIconImg.corner(width / 2)
            systemIconImg.tag = 15000 + index
            systemIconImg.centerImg.corner((width - 8) / 2)
            systemIconImg.layer.borderColor =  index == currentIndex ? UIColor.init(hexString: "#388CEF").cgColor : UIColor.clear.cgColor
//            systemIconImg.centerImg.image = .init(named: "system_avatar_\(index)")
            
            let top = 334 + (index / 5) * 80
            let left = 29 + Int(index % 5) * Int(width + 6)
            
            systemIconImg.snp.makeConstraints { make in
                make.top.equalTo(top)
                make.left.equalTo(left)
                make.width.equalTo(width)
                make.height.equalTo(width)
            }
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(imageChanged(sender:)))
            systemIconImg.isUserInteractionEnabled = true
            systemIconImg.addGestureRecognizer(tap)
//            systemIconImg.snp.makeConstraints { make in
//                make.top.equalTo(top)
//                make.left.equalTo(left)
//            }
        }
        
        
        bottomView.addSubview(refreshView)
        let refreshTop  = 334 + 2 * 80 + 10
        refreshView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(refreshTop)
            make.height.equalTo(20)
        }
        refreshViewImage.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(4)
            make.centerY.equalToSuperview()
            make.width.equalTo(17)
            make.height.equalTo(18)
        }
        refreshViewTitle.snp.makeConstraints { make in
            make.left.equalTo(refreshViewImage.snp_right).offset(10)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(4)
        }
        
        
        
        
        
        
        bottomView.addSubview(trueLbl)
        trueLbl.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.left.equalTo(24)
            make.right.equalTo(-24)
            make.height.equalTo(46)
            make.bottom.equalToSuperview().offset(-36)
        }
        
        
        getPicNet()
    }
    
    
    
    
    //点击bottom区域外 消失
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let touch = touches.first else {return}
//        let view = bottomView
//        let point = touch.location(in: self)
//        let tPoint = view.convert(point, from: self)
//        if view.point(inside: tPoint, with: event) {return}
//        bottomShow(show: false)
    }
    
    
    func bottomShow(show:Bool, _ duration: CGFloat = 0.3) {
        
        self.layoutIfNeeded()
        UIView.animate(withDuration: duration) {
            
            self.bottomView.snp.updateConstraints { make in
                make.top.equalTo(self.snp.bottom).offset( show ? -self.bottomHeight : 0)
            }
            self.backgroundColor = .black.withAlphaComponent(show ? 0.3 : 0)
            self.layoutIfNeeded()
        } completion: { [self] _ in
            if !show  {
                self.backgroundColor = .black.withAlphaComponent(show ? 0.3 : 0)
                self.removeFromSuperview()
            }
        }

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    class systemIconView: UIView {
        
        lazy var centerImg: UIImageView = {
            let r = UIImageView()
            r.clipsToBounds = true
//            r.image = .init(named: "DefaultAvatar")
            r.contentMode = .scaleAspectFill
            return r
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            addSubview(centerImg)
            clipsToBounds = true
            layer.borderWidth = 2
            centerImg.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(4)
                make.left.equalToSuperview().offset(4)
                make.right.equalToSuperview().offset(-4)
                make.bottom.equalToSuperview().offset(-4)
            }
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        
    }
    
    private lazy var _photoHelper: PhotoHelper = {
        let v = PhotoHelper()
        v.setConfigToPickAvatar()
        v.didPhotoSelected = { [weak self] (images: [UIImage], _: [PHAsset]) in
            guard var first = images.first else { return }
            
            self?.currentIndex = -1
            self?.isHaveImg = true
            self?.refrehUI()
            
            self?.userIconImg = first
            self?.topCameraImg.image = first
            
//            ProgressHUD.animate()
//            first = first.compress(expectSize: 20 * 1024)
//            let result = FileHelper.shared.saveImage(image: first)
//            
//            if result.isSuccess {
//                self?._viewModel.uploadFile(fullPath: result.fullPath, onProgress: { [weak self] progress in
//
//                }, onComplete: { [weak self] code, msg in
//                    if code == 0 {
//                        self?.bottomShow(show: false)
//                        ProgressHUD.dismiss()
//                    } else {
////                        ProgressHUD.error(msg)
//                        SuperToast.show(title: msg)
//                    }
//                })
//            } else {
//                ProgressHUD.dismiss()
//            }
        }
        
        v.didCameraFinished = { [weak self] (photo: UIImage?, _: URL?) in
            guard let sself = self else { return }
            if var photo {
                ProgressHUD.animate()
                
                photo = photo.compress(expectSize: 20 * 1024)
                let result = FileHelper.shared.saveImage(image: photo)
                if result.isSuccess {
                    self?._viewModel.uploadFile(fullPath: result.fullPath, onProgress: { [weak self] progress in

                    }, onComplete: { [weak self] code, msg in
                        if code == 0 {
                            ProgressHUD.dismiss()
                        } else {
//                            ProgressHUD.error(msg)
                            SuperToast.show(title: msg)
                        }
                    })
                }
            }
        }
        return v
    }()
    
    
}
    
    


extension YFChooseUserAvatarCardView {
    
    
    @objc func imageChanged(sender :UITapGestureRecognizer) {
        let senderview = sender.view as!  systemIconView
        
        
        isHaveImg = true
        
        
        let senderTag = senderview.tag
        currentIndex = senderTag - 15000
       
        refrehUI()
        
        self.topCameraImg.show(picData?[currentIndex] ?? "")
    }
    
    
    func refrehUI() {
        
        if isHaveImg {
            trueLbl.backgroundColor = .init(hexString: "#388CEF")
        }
        
        for index in 0...9 {
            let view = viewWithTag(15000 + index)  as!  systemIconView
            view.layer.borderColor =  index == currentIndex ? UIColor.init(hexString: "#388CEF").cgColor : UIColor.clear.cgColor
        }
    }
    
    
    @objc func saveAction() {
        
        if !isHaveImg {
            return
        }
        print("保存")
  
        if currentIndex > 0 {
            if let data = picData {
                AccountViewModel.updateUserInfo(userID: IMController.shared.uid, faceURL:data[self.currentIndex]) { errCode, errMsg in
                    if errCode != 0 {
                        SuperToast.show(title: errMsg)
                    } else {
                        print("保存成功")
                        self.bottomShow(show: false)
                    }
                }
            }
        } else {
            
            uploadImgToAvatar()
        }

    }
    
    func uploadImgToAvatar() {
        let image = userIconImg!.compress(expectSize: 20 * 1024)
        let result = FileHelper.shared.saveImage(image: image)
        if result.isSuccess {
            ProgressHUD.animate()
            self._viewModel.uploadFile(fullPath: result.fullPath, onProgress: { [weak self] progress in

            }, onComplete: { [weak self] code, msg in
                ProgressHUD.dismiss()
                if code == 0 {
                    self?.bottomShow(show: false)
                   
                } else {
//                          ProgressHUD.error(msg)
                    SuperToast.show(title: msg)
                }
            })
        }
    }
    
    
    
    
    @objc func refreshAction() {
        getPicNet()
    }
    
    func getPicNet() {
        
        YFMineNetViewModel.pictureFind {  [weak  self] data in
            
            self?.picData = data
            for (index, item) in data.enumerated() {
                let iconView = self?.viewWithTag(15000 + index) as! systemIconView
                iconView.centerImg.show(item)
                
            }
            
            if self?.currentIndex ?? -1 > -1  {
                self?.topCameraImg.show(data[self!.currentIndex])
            }
            
           
            
        } completionHandler: { errCode, errMsg in
            
        }
        
    }
    
    @objc func changeAvatar() {
        
//        NotificationCenter.default.post(name: Notification.Name("homeChooseUserIcon"), object: nil)
        
        if let currentController = findController() {
            currentController.presentSelectedPictureActionSheet { [weak self] in
                guard let self else { return }
                _photoHelper.presentPhotoLibrary(byController: currentController)
            } cameraHandler: {[weak self] in
                guard let self else { return }
//                _photoHelper.presentCamera(byController: currentController)
                presentCamera()
            }
        }
        
    }
    
    
//    , UIImagePickerControllerDelegate, UINavigationControllerDelegate  private let _viewModel = MineViewModel()
    
    func presentCamera() {
         
        if let currentController = findController() {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = true
     
            // 检查相机权限
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                // 检查相机权限
                switch AVCaptureDevice.authorizationStatus(for: .video) {
                case .authorized:
                    // 已授权，可以直接调用相机
                    currentController.present(imagePicker, animated: true, completion: nil)
                case .notDetermined:
                    // 未询问过用户授权，请求授权
                    AVCaptureDevice.requestAccess(for: .video) { granted in
                        if granted {
                            DispatchQueue.main.async {
                                currentController.present(imagePicker, animated: true, completion: nil)
                            }
                        }
                    }
                default:
                    // 无权限，可以提示用户或者跳转到设置页面
                    print("无权限访问相机")
                }
            } else {
                // 设备无相机，提示用户或者进行错误处理
                print("设备无相机")
            }
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate
      func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
          picker.dismiss(animated: true, completion: nil)
      }
   
      func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
          // 处理图片
          if var image = info[.editedImage] as? UIImage {
              // 使用image
              
//              ProgressHUD.animate()
              currentIndex = -1
              isHaveImg = true
              refrehUI()
              userIconImg = image
              self.topCameraImg.image = image
              
             
              
          }
   
          picker.dismiss(animated: true, completion: nil)
      }
    
    
}
