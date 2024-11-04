//
//  MineMessageVC.swift
//  MyCloudMusic
//
//  Created by mac on 2024/5/7.
//

import UIKit
import TangramKit
import RxSwift
import RxCocoa
import OUIIM
import OUICore
import ProgressHUD

class MineMessageVC: BaseTitleController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    public var user: UserInfo?
    
    private let _viewModel = MineViewModel()
    var changeType: ChangeMessageType?
//    private let _imViewModoel = UserProfileViewModel(userId: AccountViewModel.userID, groupId: nil)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        _viewModel.queryUserInfo()
    }
    
    override func initViews() {
        super.initViews()
        setBackGroundColor(.colorBackgroundAPP)
        initLinearLayoutSafeArea()
    
//        title = R.string.localizable.myProfile()
        title = "MyProfile".localized()
        
        container.tg_padding = UIEdgeInsets(top: PADDING_MEDDLE, left: PADDING_MEDDLE, bottom: PADDING_MEDDLE, right: PADDING_MEDDLE)
        container.tg_space = PADDING_OUTER
        
//        container.addSubview(ViewFactoryUtil.sectionTilteLbael(R.string.localizable.basicInformation()))
        container.addSubview(ViewFactoryUtil.sectionTilteLbael("BasicInformation".localized()))
        container.addSubview(accountMessageView)
        
//        container.addSubview(ViewFactoryUtil.sectionTilteLbael(R.string.localizable.socialMediaHomepage(), top: 14))
//        container.addSubview(ViewFactoryUtil.sectionTilteLbael("SocialMediaHomepage".localized(), top: 14))
//        container.addSubview(bindMessageView)
        
        bindData()
    }
    
    override func bindData() {
        _viewModel.currentUserRelay.subscribe(onNext: { [weak self] (user: QueryUserInfo?) in
            guard let self, user != nil else { return }
            updateUI()
            
        }).disposed(by: rx.disposeBag)
        
    }
    
    func updateUI() {
        
        let user = _viewModel.currentUserRelay.value
        
        userNicknameView.contentLbl.text = SuperStringUtil.getUserShowname(showname: user?.nickname ?? "")
        userIconView.changeIcon.show(user?.faceURL)
//        userIconView.changeIcon.hide()
        userIconView.avatarImageView.setAvatar(url: user?.faceURL, text: SuperStringUtil.getUserState(showname: user?.nickname ?? "").n)
        userIconView.avatarImageView.corner(20)
        userIDView.contentLbl.text = user?.chatID ?? user?.userID
        introView.contentLbl.text  = user?.personalProfile
    }
    
    lazy var accountMessageView: TGLinearLayout = {
        let r = TGLinearLayout(.vert)
        r.tg_width.equal(.fill)
        r.tg_height.equal(.wrap)
        r.tg_space = 1
        r.corner(MEDDLE_RADIUS)
        r.backgroundColor = .white
        
        r.addSubview(userIconView)
        r.addSubview(ViewFactoryUtil.smallDivider())
        r.addSubview(userNicknameView)
        r.addSubview(ViewFactoryUtil.smallDivider())
        r.addSubview(userIDView)
//        r.addSubview(ViewFactoryUtil.smallDivider())
//        r.addSubview(introView)
        
        return r
    }()
    
    lazy var userIconView: SuperSettingView = {
//        let r = SuperSettingView.createSetIcon(R.string.localizable.introTitle(R.string.localizable.photo())) { [weak self] data in
//            self?.changeAvatar()
//        }
        let r = SuperSettingView.createSetIcon(R.string.localizable.introTitle("Photo".localized())) { [weak self] data in
            self?.changeAvatar()
        }
        r.isMediumFont()
        return r
    }()
    
    
    lazy var userNicknameView: SuperSettingView = {
//        let r = SuperSettingView.createSetTitleAddContentView(R.string.localizable.introTitle(R.string.localizable.name()), "荷包蛋小朋友") { [weak self] data in
//            self?.changeMessage(.nickname)
//        }
        let r = SuperSettingView.createSetTitleAddContentView("Name".localized(), "荷包蛋小朋友") { [weak self] data in
            self?.changeMessage(.nickname)
        }
        r.isMediumFont()
        return r
    }()
    
    lazy var userIDView: SuperSettingView = {
        let r = SuperSettingView.createSetTitleAddContentView("Aibitlin ID：", "Richenda0728") { [weak self] data in
//            self?.changeMessage(.userID)
//            SuperToast.show(title: "开发中".localized())
        }
        r.isMediumFont()
        r.moreIconView.hide()
        return r
    }()
    
    
    lazy var introView: SuperSettingView = {
//        let r = SuperSettingView.createSetTitleAddContentView(R.string.localizable.introTitle(R.string.localizable.personalProfile()), "") { [weak self] data in
//            self?.changeMessage(.userIntro)
//        }
        let r = SuperSettingView.createSetTitleAddContentView("PersonalProfile".localized(), "") { [weak self] data in
//            self?.changeMessage(.userIntro)
            SuperToast.show(title: "开发中".localized())
        }
        r.isMediumFont()
        return r
    }()
    
    
    lazy var bindMessageView: TGLinearLayout = {
        let r = TGLinearLayout(.vert)
        r.tg_width.equal(.fill)
        r.tg_height.equal(.wrap)
        r.tg_space = 1
        r.corner(MEDDLE_RADIUS)
        r.backgroundColor = .white
        
        r.addSubview(bindFacebookView)
        r.addSubview(ViewFactoryUtil.smallDivider())
        r.addSubview(bindInstagramView)
        r.addSubview(ViewFactoryUtil.smallDivider())
        r.addSubview(bindTikTokView)
        r.addSubview(ViewFactoryUtil.smallDivider())
        r.addSubview(bindYouTubeView)
        r.addSubview(ViewFactoryUtil.smallDivider())
        
        return r
    }()
    
    lazy var bindFacebookView: SuperSettingView = {
//        let r = SuperSettingView.createSetTitleAddContentView(R.string.localizable.introTitle(R.string.localizable.homePage("Facebook")), R.string.localizable.notFilledIn()) { [weak self] data in
//            self?.changeMessage(.facebook)
//        }
        let r = SuperSettingView.createSetTitleAddContentView("IntroTitle".localizedFormat("HomePage".localizedFormat("Facebook")), "NotFilledIn".localized()) { [weak self] data in
            self?.changeMessage(.facebook)
        }
        r.isMediumFont()
        return r
    }()
    
    lazy var bindInstagramView: SuperSettingView = {
//        let r = SuperSettingView.createSetTitleAddContentView(R.string.localizable.introTitle(R.string.localizable.homePage("Instagram")), R.string.localizable.notFilledIn()) { [weak self] data in
//            self?.changeMessage(.instagram)
//        }
        let r = SuperSettingView.createSetTitleAddContentView("IntroTitle".localizedFormat("HomePage".localizedFormat("Instagram")), "NotFilledIn".localized()) { [weak self] data in
            self?.changeMessage(.facebook)
        }
        r.isMediumFont()
        return r
    }()
    
    
    lazy var bindTikTokView: SuperSettingView = {
//        let r = SuperSettingView.createSetTitleAddContentView(R.string.localizable.introTitle(R.string.localizable.homePage("TikTok")), R.string.localizable.notFilledIn()) { [weak self] data in
//            self?.changeMessage(.tiktok)
//        }
        let r = SuperSettingView.createSetTitleAddContentView("IntroTitle".localizedFormat("HomePage".localizedFormat("TikTok")), "NotFilledIn".localized()) { [weak self] data in
            self?.changeMessage(.facebook)
        }
        r.isMediumFont()
        return r
    }()
    
    lazy var bindYouTubeView: SuperSettingView = {
//        let r = SuperSettingView.createSetTitleAddContentView(R.string.localizable.introTitle(R.string.localizable.homePage("YouTube")), R.string.localizable.notFilledIn()) { [weak self] data in
//            self?.changeMessage(.youtube)
//        }
        let r = SuperSettingView.createSetTitleAddContentView("IntroTitle".localizedFormat("HomePage".localizedFormat("YouTube")), "NotFilledIn".localized()) { [weak self] data in
            self?.changeMessage(.facebook)
        }
        r.isMediumFont()
        return r
    }()
    
    func changeMessage(_ type: ChangeMessageType)  {
        let vc = ChangeMessageVC()
        vc.changeType = type
        self.changeType = type
        vc.saveBtn.rx.tap.subscribe(onNext: {[weak self, weak vc] in
//            print(vc?.title as Any)
//            self?.title = vc?.title
            vc?.navigationController?.popViewController()
            self?.changeMessageAbout(vc?.editView.text)
        }).disposed(by: rx.disposeBag)
        self.gotoController(vc)
    }
    
    
    func changeMessageAbout(_ data: String?) {
        switch changeType {
        case .nickname:
            changeNickName(data)
        case .userID:
            changeChatID(data)
        case .userIntro:
            changeIntro(data)
            break
        default:
            break;
        }
    }
    
    
    func changeNickName(_ data: String?) {
 
//        ProgressHUD.animate()
        self._viewModel.updateNickname(data!) { [weak self] code, msg in
//            ProgressHUD.dismiss()
            if code == 0 {
                self?.userNicknameView.contentLbl.text = data
                
            } else {
//                ProgressHUD.error(msg)
                SuperToast.show(title: msg)
            }
  
        }
    }
    
    func changeChatID(_ data: String?) {
 
//        ProgressHUD.animate()
        self._viewModel.updateChatID(data!) { [weak self] code, msg in
            ProgressHUD.dismiss()
            if code == 0 {
                self?.userIDView.contentLbl.text = data
                
            } else {
//                ProgressHUD.error(msg)
                SuperToast.show(title: msg)
            }
  
        }
    }
    
    func changeIntro(_ data: String?) {
 
        ProgressHUD.animate()
        self._viewModel.updateIntro(data!) { [weak self] code, msg in
            ProgressHUD.dismiss()
            if code == 0 {
                self?.introView.contentLbl.text = data
                print("++++++++++")
            } else {
                ProgressHUD.error(msg)
//                SuperToast.show(title: msg)
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
//            
//            presentCamera()
//        }
        _photoHelper.setConfigToMultipleSelected(forVideo: false, maxSelectCount: 1)
        _photoHelper.showSelectMetaSheet(byController: self)
    }
    
    
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
//                self?._viewModel.uploadFile(fullPath: result.fullPath, onProgress: { [weak self] progress in
////                    ProgressHUD.progress(progress)
//                }, onComplete: { [weak self] code, msg in
//                    if code == 0 {
//                        self?.user?.faceURL = "file://" + result.fullPath
//                        self?.userIconView.iconView.image = first
//                        
//                    } else {
////                        ProgressHUD.error(msg)
//                        SuperToast.show(title: msg)
//                    }
//                    ProgressHUD.dismiss()
//                })
//            } else {
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
//                    self?._viewModel.uploadFile(fullPath: result.fullPath, onProgress: { [weak self] progress in
////                        ProgressHUD.progress(progress)
//                    }, onComplete: { [weak self] code, msg in
//                        if code == 0 {
//                            self?.user?.faceURL = "file://" + result.fullPath
//                            self?.userIconView.iconView.image = photo
//                           
//                        } else {
////                            ProgressHUD.error(msg)
//                            SuperToast.show(title: msg)
//                        }
//                        ProgressHUD.dismiss()
//                    })
//                }
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
                    self?._viewModel.uploadFile(fullPath: result.fullPath, onProgress: { [weak self] progress in
    //                    ProgressHUD.progress(progress)
                    }, onComplete: { [weak self] code, msg in
                        if code == 0 {
                            self?.user?.faceURL = "file://" + result.fullPath
                            self?.userIconView.iconView.image = first
                            
                        } else {
    //                        ProgressHUD.error(msg)
                            SuperToast.show(title: msg)
                        }
                        ProgressHUD.dismiss()
                    })
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
                        self?._viewModel.uploadFile(fullPath: result.fullPath, onProgress: { [weak self] progress in
    //                        ProgressHUD.progress(progress)
                        }, onComplete: { [weak self] code, msg in
                            if code == 0 {
                                self?.user?.faceURL = "file://" + result.fullPath
                                self?.userIconView.iconView.image = photo
                               
                            } else {
    //                            ProgressHUD.error(msg)
                                SuperToast.show(title: msg)
                            }
                            ProgressHUD.dismiss()
                        })
                    }
                }
            }
            return v
        }()
    
    
    //    , UIImagePickerControllerDelegate, UINavigationControllerDelegate  private let _viewModel = MineViewModel()
        
        func presentCamera() {
             

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
                        present(imagePicker, animated: true, completion: nil)
                    case .notDetermined:
                        // 未询问过用户授权，请求授权
                        AVCaptureDevice.requestAccess(for: .video) { granted in
                            if granted {
                                DispatchQueue.main.async {
                                    self.present(imagePicker, animated: true, completion: nil)
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
                      self._viewModel.uploadFile(fullPath: result.fullPath, onProgress: { [weak self] progress in

                      }, onComplete: { [weak self] code, msg in
                          if code == 0 {
                              self?.user?.faceURL = "file://" + result.fullPath
                              self?.userIconView.iconView.image = image
                             
                          } else {
//                              ProgressHUD.error(msg)
                              SuperToast.show(title: msg)
                          }
                          ProgressHUD.dismiss()
                      })
                  }
                  
              }
       
              picker.dismiss(animated: true, completion: nil)
          }
    
}
