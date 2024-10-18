//
//  YFFeedbackVC.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/5/13.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import UIKit
import TangramKit
import OUICore
import ProgressHUD
import MMBAlertsPickers
import RxSwift
import RxCocoa

class YFFeedbackVC: BaseTitleController {

    var reportType: ReportType = .user
    var topViewTitle:String!
    var contentViewTitle:String!
    var imageTitle:String!
    var tempStr:String = ""
    
    var blogItem: blogDetailItem!
    var conversationItem: ConversationInfo!
    var userItem: QueryUserInfo!
    
    private let _viewModel = MineViewModel()
    
    var reportID: String = ""
    var reportImgs: String = ""
    
    override func initViews() {
        
        super.initViews()
        setBackGroundColor(.init(hexString: "#f5f5f5"))
        initLinearLayoutSafeArea()
        
        setTitle()
        
//        title = useType == .useFeedback ? "反馈".localized() : "举报".localized();
        title = "举报".localized();
        
        container.tg_padding = UIEdgeInsets(top: PADDING_OUTER, left: PADDING_OUTER, bottom: PADDING_OUTER, right: PADDING_OUTER)
        container.addSubview(meesageView)
        
//        container.addSubview(ViewFactoryUtil.smallDivider(space: 0))
//        container.addSubview(topTitleView)
//        container.addSubview(ViewFactoryUtil.smallDivider())
//        container.addSubview(contentView)
//        container.addSubview(ViewFactoryUtil.smallDivider())
//        container.addSubview(imageView)
        
        superFooterContainerContainer.tg_padding = UIEdgeInsets(top: PADDING_OUTER, left: 10, bottom: 10, right: 10)
        superFooterContainerContainer.addSubview(bottomBtn)
        
        
        print(self.reportType, self.reportID)
        
        refreshUI()
        bindData()
    }
    
    
    lazy var meesageView: TGLinearLayout = {
        
        let r = TGLinearLayout(.vert)
        r.tg_width.equal(.fill)
        r.tg_height.equal(.wrap)
        r.tg_top.equal(-6)
        r.backgroundColor = .white
//        r.tg_padding = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        r.corner(8)
        
        r.addSubview(topTitleView)
        r.addSubview(contentView)
        r.addSubview(imageView)
        
//        topTitleView.backgroundColor = .green
//        contentView.backgroundColor = .yellow
//        imageView.backgroundColor = .red
        
        return r
    }()
    
    
    
    
    func setTitle() {
        
        title = R.string.localizable.report()
        topViewTitle = "\("举报原因".localized())*"
        contentViewTitle = "\("举报描述".localized())*"
        imageTitle = "截图证据".localized()
        
//        switch useType {
//    
//        case .useFeedback:
//            title = "反馈".localized()
//            topViewTitle = "\("标题".localized())*"
//            contentViewTitle = "\("问题描述".localized())*"
//            imageTitle = "截图".localized()
//        case .useReport:
//            title = R.string.localizable.report()
//            topViewTitle = "\("举报原因".localized())*"
//            contentViewTitle = "\("举报描述".localized())*"
//            imageTitle = "截图证据".localized()
//        default:
//            break
//        }
    }
    
    
    lazy var bottomBtn: QMUIButton = {
        let r = ViewFactoryUtil.primaryHalfFilletButton()
        r.setTitle("提交".localized(), for: .normal)
        r.addTarget(self, action: #selector(toReportAction), for: .touchUpInside)
        return r
    }()
    
    lazy var topTitleView: SuperSettingView = {
        let r = SuperSettingView.createInput(topViewTitle, placeholder: R.string.localizable.pleaseFillIn()) { [weak self] data in
//            self?.reportChoose()
            
        }
        r.isMediumFont()
        r.titleView.changeColor(changeColorStr: "*")
//        if useType == .useReport {
//            r.isReport()
//        }
        return r
    }()
    
    func reportChoose() {
//        if self.useType == .useReport {
//            let alert = UIAlertController(title: "举报", message: "举报该账号的原因", preferredStyle: .actionSheet)
//            
//            let frameSizes: [String] = ["发布不适当内容对我造成骚扰", "钱财欺诈", "怀疑账号被盗用", "其他"]
//            let pickerViewValues: [[String]] = [frameSizes]
//            let pickerViewSelectedValue: PickerViewViewController.Index = (column: 0, row: frameSizes.firstIndex(of: self.tempStr) ?? 0)
//            
//            alert.addPickerView(values: pickerViewValues, initialSelection: pickerViewSelectedValue, withSerchBar: false) { [weak self] vc, picker, index, values  in
//                self?.tempStr = values[0][index.row]
//                self?.topTitleView.textFieldView.text =  values[0][index.row]
//            }
//            
//            //cacel 取消也改变值  defalut 必须选择 alert才会消失
//            alert.addAction(title: "Done".localized(), style: .cancel)
//            alert.show()
//            self.showReportSheet()
//        }
    }
    
    func showReportSheet() {
        let contentView = MineChooseBottomSheetView()
        contentView.tg_width.equal(.fill)
        contentView.tg_height.equal(319)
        contentView.addReportUI()
        contentView.chooseTitle = { [weak self] title in
            self?.topTitleView.textFieldView.text = title
            GKCover.hide()
        }
        GKCover.cover(from: view, contentView: contentView, style: .translucent, showStyle: .bottom, showAnimStyle: .bottom, hideAnimStyle: .bottom, notClick: false)
    }
    
    
    
    
    lazy var contentView: SuperSettingView = {
        let r = SuperSettingView.createInputTextView(contentViewTitle, placeholder: R.string.localizable.pleaseFillIn(), min: 75)
        r.isMediumFont()
        r.titleView.changeColor(changeColorStr: "*")
        r.tg_height.equal(110)
        r.tg_gravity = .vert.top
        r.titleView.tg_top.equal(21)
        r.textView.tg_top.equal(14)
        r.textView.tg_height.equal(80)
        r.textView.tg_width.equal(.fill)
        return r
    }()

    lazy var imageView: UIView = {
        let r = TGLinearLayout(.vert)
        r.tg_padding = UIEdgeInsets(top: PADDING_OUTER, left: PADDING_OUTER, bottom: PADDING_OUTER, right: PADDING_OUTER)
        r.tg_width.equal(.fill)
        r.tg_height.equal(.wrap)
        r.addSubview(picNumberView)
        r.addSubview(picView)
        r.tg_bottom.equal(10)
        
        return r
        
    }()
    
    lazy var picView: TGRelativeLayout = {
        let r = TGRelativeLayout()
        r.tg_top.equal(PADDING_SMALL)
        r.tg_width.equal(.fill)
        r.tg_height.equal(.wrap)
        let imageWidth = (UIScreen.main.bounds.width - PADDING_OUTER * 4 - 40) / 4
        for i in 0...8 {
            let image = ViewFactoryUtil.defalutImgView(R.image.add_image_icon()!, imageWidth)
            image.contentMode = .scaleAspectFill
            let left = Int(i % 4) * Int(imageWidth + PADDING_OUTER)
            let top = Int(i / 4) * Int(imageWidth + PADDING_OUTER)
      
            image.corner(2)
            image.tg_left.equal(left)
            image.tg_top.equal(top)
            image.tag = 6000 + i
            
            let gesTap = UITapGestureRecognizer(target: self, action: #selector(addPic(gesture:)))
            image.isUserInteractionEnabled = true
            image.addGestureRecognizer(gesTap)
            r.addSubview(image)
        }
        return r
    }()
    
    lazy var picNumberView: TGLinearLayout = {
        let r = TGLinearLayout(.horz)
        r.tg_width.equal(.fill)
        r.tg_height.equal(.wrap)
        r.tg_space = PADDING_SMALL
        r.tg_padding = UIEdgeInsets(top: PADDING_SMALL, left: 0, bottom: PADDING_SMALL, right: 0)
        r.tg_gravity = .vert.center
        let title = ViewFactoryUtil.customTilteLableWrap(imageTitle, font: TEXT_MEDDLE)
        title.font = UIFont(name: "PingFangSC-Medium", size: 16)
        r.addSubview(title)
        r.addSubview(picNumberLbl)
        r.addSubview(ViewFactoryUtil.customTilteLableWrap("*", font: TEXT_MEDDLE, textColor: .red))
        return r
    }()
        
    lazy var picNumberLbl: UILabel = {
        let r = ViewFactoryUtil.customTilteLableWrap("(0/9)", font: TEXT_MEDDLE, textColor: .placeholder)
        return r
    }()
    
    
    func refreshUI() {
        picNumberLbl.text = "\(datum.count)/9"
        for i in 0...8 {
            let image = view.viewWithTag(i + 6000) as! UIImageView
            if datum.count == 0 && i == 0 {
                image.show()
                image.image = R.image.empty_feedBack_icon()
            } else if i <= datum.count && datum.count < 9 {
                image.show()
                if i == datum.count {
                    image.image = R.image.empty_feedBack_icon()
                } else {
                    image.image = datum[i] as? UIImage
                }
            } else if datum.count == 9{
                image.show()
                image.image = datum[i] as? UIImage
            } else {
                image.hide()
            }
        }
    }
    
    @objc func addPic(gesture: UITapGestureRecognizer) {
        print(gesture.view?.tag ?? "11111")
        if gesture.view!.tag - 6000 == datum.count {
            presentSelectedPictureActionSheet { [weak self] in
                guard let self else { return }
                _photoHelper.setConfigToPickAvatar(9 - datum.count)
                _photoHelper.presentPhotoLibrary(byController: self)
            } cameraHandler: {[weak self] in
                guard let self else { return }
                _photoHelper.presentCamera(byController: self)
            }
        }
    }
    
    private lazy var _photoHelper: PhotoHelper = {
        let v = PhotoHelper()
        v.setConfigToPickAvatar(9)
        
        v.didPhotoSelected = { [weak self] (images: [UIImage], _: [PHAsset]) in
            guard var first = images.first else { return }
            
            self?.datum = self!.datum + images
            self?.refreshUI()
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
//                        self?.reloadData()
//                        ProgressHUD.dismiss()
//                    } else {
//                        ProgressHUD.error(msg)
//                    }
//                })
//            } else {
//                ProgressHUD.dismiss()
//            }
        }
        
        v.didCameraFinished = { [weak self] (photo: UIImage?, _: URL?) in
            guard let sself = self else { return }
            if var photo {
                
                self?.datum.append(photo)
                self?.refreshUI()
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
//                            self?.reloadData()
//                            ProgressHUD.dismiss()
//                        } else {
//                            ProgressHUD.error(msg)
//                        }
//                    })
//                }
            }
        }
        return v
    }()
    
    override func bindData() {
        topTitleView.needLimitLength(length: 12)
        contentView.needLimitLengthAboutTextView(length: 256)
        
        Observable.combineLatest(topTitleView.textFieldView.rx.text.orEmpty, contentView.textView.rx.text.orEmpty) {
            $0.count > 0  && $1.count > 0
        }
        .bind(to: bottomBtn.rx.isEnabled)
        .disposed(by: rx.disposeBag)
    }
    
}


extension YFFeedbackVC {
    @objc func toReportAction() {
        
        if reportType == .feedback {
            SuperToast.show(title: "提交成功".localized())
            return
        }

        
        if datum.count == 0 {
            toReportNet()
        } else {
            uploadImageNetWork(index: 0)
        }
        
        
    }
    
    func uploadImageNetWork(index: Int) {
       
        if index < datum.count {
           
            ProgressHUD.animate()
            let result = FileHelper.shared.saveImage(image: datum[index] as! UIImage)
            
            
            IMController.shared.uploadFile(fullPath: result.fullPath) { [weak self] progress in
                
            } onSuccess: { [weak self] url in
                if let url = url {
                   
                    if index > 0 {
                        self?.reportImgs = self!.reportImgs + "," + url
                    } else {
                        self?.reportImgs = url
                    }
                    self?.uploadImageNetWork(index: index + 1)
                    print(self!.reportImgs)
                    
                }
                ProgressHUD.dismiss()
            }

        } else {
            print("\n\n\n所有图片上传完成")
            toReportNet()
        }
        
        
        
    }
    
    func toReportNet() {
        
        var paramters : [String : Any] = [:]
        switch reportType {
        case .blog:
            paramters = ["blogId": blogItem.id!,
                         "userBlogUrl": blogItem.userBlogUrl!,
                         "userBlogIcon": blogItem.userBlogIcon!,
                         "userBlogName": blogItem.userBlogName!,
                         "userBlogIntro": blogItem.userBlogIntro!,
                         "userBlogCreatIp": blogItem.userBlogCreatIp!,
                         "userBlogCreatAffiliatingArea": blogItem.userBlogIntro!,

                         "reportReason":topTitleView.inputText!,
                         "reportDescription":contentView.textView.text!,
                         "reportImgs": reportImgs,
                         "reportUserId": IMController.shared.uid]
        case .chatHistory:
            paramters = [ "beReportedUserId": conversationItem.userID!,
                          "beReportedUserImg": conversationItem.faceURL ?? "",
                          "beReportedUserName": conversationItem.showName!,
                          "reportReason":topTitleView.inputText!,
                         "reportDescription":contentView.textView.text!,
                         "reportImgs": reportImgs,
                         "reportUserId": IMController.shared.uid]
        case .user:
            paramters = [ "beReportedUserId": userItem.userID!,
                          "beReportedUserName": userItem.nickname!,
                          "beReportedUserImg": userItem.faceURL ?? "",
//                          "": "",
                          "reportReason":topTitleView.inputText!,
                         "reportDescription":contentView.textView.text!,
                         "reportImgs": reportImgs,
                         "reportUserId": IMController.shared.uid]
            default:
                break
        }
        
        
        YFMineNetViewModel.reportUserNet(paramters: paramters, reportType: reportType)
        
    }
}
