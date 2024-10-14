//
//  YFMineQRCodeVC.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/10/9.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Foundation
import TangramKit
import OUICore

class YFMineQRCodeVC: BaseTitleController {
    
    var user: QueryUserInfo!
    var username: String = ""
    var userShowId: String = ""
    
    override func initViews() {
        
        super.initViews()
        initScrollSafeArea()
        scrollViewContainer.tg_padding = UIEdgeInsets(top: PADDING_OUTER, left: PADDING_OUTER, bottom: PADDING_OUTER, right: PADDING_OUTER)
        scrollViewContainer.tg_space = 10
        superFooterContainerContainer.tg_bottom.equal(0)

        title = "我的二维码".localized()
        
        scrollViewContainer.addSubview(userCardView)
        
        addMyStarBoke()

        refreshUI()
        
        view.addSubview(saveCard)
        view.sendSubviewToBack(saveCard)
    }
    
    // MARK: - 张亚飞打的标记 卡片
    /// 用户卡片
    lazy var userCardView: TGLinearLayout = {
        let r = TGLinearLayout(.vert)
        r.tg_width.equal(.fill)
        r.tg_height.equal(.wrap)
        r.tg_top.equal(30)
        r.tg_gravity = .horz.center
        r.backgroundColor = .white
        r.corner(14)
        
        r.addSubview(userShowTitleView)
        r.addSubview(userEditTitleView)
        userEditTitleView.hide()
        r.addSubview(codeView)
        
        codeView.addSubview(codeImgView)
        codeImgView.snp.makeConstraints { make in
            make.top.left.right.bottom.equalToSuperview().inset(10)
        }
        codeView.addSubview(userAvatarImgView)
        userAvatarImgView.snp.makeConstraints { make in
            make.width.height.equalTo(56)
            make.center.equalToSuperview()
        }
        
        
        r.addSubview(userIdTitleView)
        r.addSubview(tipLbl)
        r.addSubview(lineView)
        r.addSubview(cardBottmView)
        
        return r
    }()
    
    ///未编辑状态的用户名
    lazy var userShowTitleView: TGLinearLayout = {
        let r = TGLinearLayout(.horz)
        r.tg_width.equal(.wrap)
        r.tg_height.equal(40)
        r.tg_space = 7
        r.tg_gravity = .vert.center
        r.tg_top.equal(38)
        r.addSubview(userNicknameLbl)
        r.addSubview(ViewFactoryUtil.defalutImgView(R.image.edit_icon()!, 16))
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(showNicknameTFView))
        r.addGestureRecognizer(tap)
        return r
    }()
    
    lazy var userNicknameLbl: UILabel = {
        let r = UILabel()
        r.tg_width.equal(.wrap)
        r.tg_height.equal(.wrap)
        r.textColor = .black333
        r.font = .mediumFont(15)
        r.text = username
        return r
    }()
    
    ///未编辑状态的用户名
    lazy var userEditTitleView: TGLinearLayout = {
        let r = TGLinearLayout(.horz)
        r.tg_width.equal(.wrap)
        r.tg_height.equal(40)
        r.tg_space = 7
        r.tg_gravity = .vert.center
        r.addSubview(userNicknameTF)
        r.tg_top.equal(38)
        
        let chooseBtn = ViewFactoryUtil.imageBtn(R.image.choose_blue()!, 32)
        chooseBtn.addTarget(self, action: #selector(showNicknameLblView), for: .touchUpInside)
        
        r.addSubview(chooseBtn)
        
        return r
    }()
    
    lazy var userNicknameTF: UITextField = {
        let r = UITextField()
        r.tg_width.equal(210)
        r.tg_height.equal(32)
        r.backgroundColor = .init(hexString: "#F5F5F5")
        r.corner(8)
        r.text = username
        return r
    }()
    
    lazy var codeView: UIView = {
        let r = UIView()
        r.tg_width.equal(260)
        r.tg_height.equal(260)
        r.border(.init(hexString: "#EAEAEA"), cornerRadius: 8)
        r.tg_top.equal(17)
        return r
    }()
    
    lazy var codeImgView: UIImageView = {
        let r = UIImageView()
        return r
    }()
    
    lazy var userAvatarImgView: UIImageView = {
        let r = UIImageView()
        r.border(.white, borderWidth: 3, cornerRadius: 28)
        r.contentMode = .scaleAspectFill
        return r
    }()
    
    
    ///用户id展示
    lazy var userIdTitleView: TGLinearLayout = {
        let r = TGLinearLayout(.horz)
        r.tg_width.equal(.wrap)
        r.tg_height.equal(22)
        r.tg_space = 7
        r.tg_gravity = .vert.center
        r.tg_top.equal(24)
        
        

        r.addSubview(userIDLbl)
        r.addSubview(ViewFactoryUtil.defalutImgView(R.image.copy_icon()!, 16))
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(copyUserID))
        r.isUserInteractionEnabled = true
        r.addGestureRecognizer(tap)
        
        return r
    }()
    

    
    lazy var userIDLbl: UILabel = {
        let lbl = UILabel()
        lbl.tg_width.equal(.wrap)
        lbl.tg_height.equal(.wrap)
        lbl.textColor = .black666
        lbl.font = .regularFont(13)
        
        userShowId = user.chatID ?? ""
        lbl.text = "ID: ".localized() + userShowId
        
        return lbl
    }()
    
    
    lazy var tipLbl: UILabel = {
        let r = UILabel()
        r.text = "1.未下载APP的用户，扫你的二维码可直接下载哎比邻。\n2.未注册用户在登录页面扫你的二维码，免注册即可试用哎比邻，并自动收藏您推荐的博客。".localized()
        r.tg_left.equal(16)
        r.tg_right.equal(16)
        r.tg_height.equal(.wrap)
        r.tg_top.equal(19)
        r.font = .regularFont(13)
        r.textColor = .black999
        return r
    }()
    
    lazy var lineView: UIView = {
        let r = UIView()
        r.backgroundColor = .init(hexString: "#eaeaea")
        r.tg_width.equal(.fill)
        r.tg_height.equal(1)
        r.tg_top.equal(25)
        return r
    }()
    
    lazy var cardBottmView: TGLinearLayout = {
        let r = TGLinearLayout(.horz)
        r.tg_height.equal(50)
        r.tg_width.equal(.fill)
        r.tg_gravity = .vert.center
        r.addSubview(shareView)
        
        r.addSubview(shareView)
        
        let lineView = UIView()
        lineView.tg_width.equal(1)
        lineView.tg_height.equal(15)
        lineView.backgroundColor = .init(hexString: "#eaeaea")
        r.addSubview(lineView)
        
        r.addSubview(saveView)
        return r
    }()
    
    lazy var shareView: TGLinearLayout = {
        let r = TGLinearLayout(.horz)
        r.tg_height.equal(50)
        r.tg_width.equal(.fill)
        r.tg_space = 5
        r.tg_gravity = .center
        
        r.addSubview(ViewFactoryUtil.defalutImgView(R.image.share_icon()!, 16))
        
        let lbl = UILabel()
        lbl.tg_width.equal(.wrap)
        lbl.tg_height.equal(.wrap)
        lbl.font = .regularFont(14)
        lbl.textColor = .black333
        lbl.text = "分享给好友";
        r.addSubview(lbl)
        
        return r
    }()
    
    
    lazy var saveView: TGLinearLayout = {
        let r = TGLinearLayout(.horz)
        r.tg_height.equal(50)
        r.tg_width.equal(.fill)
        r.tg_space = 5
        r.tg_gravity = .center
        
        r.addSubview(ViewFactoryUtil.defalutImgView(R.image.save_icon()!, 16))
        let lbl = UILabel()
        lbl.tg_width.equal(.wrap)
        lbl.tg_height.equal(.wrap)
        lbl.font = .regularFont(14)
        lbl.textColor = .black333
        lbl.text = "保存到手机";
        r.addSubview(lbl)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(saveQRCode))
        r.isUserInteractionEnabled = true
        r.addGestureRecognizer(tap)
        
        return r
    }()
    
    
    
    // MARK: - 张亚飞打的标记 博客
    func addMyStarBoke() {
        let bokeView = TGLinearLayout(.vert)
        bokeView.backgroundColor = .white
        bokeView.corner(MEDDLE_RADIUS)
        bokeView.tg_width.equal(.fill)
        bokeView.tg_height.equal(.wrap)
        scrollViewContainer.addSubview(bokeView)
        
        let bokeHeader = ViewFactoryUtil.sectionHeaderView(title: "我想要推荐的博客".localized(), isHaveMore: false)
        bokeHeader.tg_height.equal(44)
//        let tap = UITapGestureRecognizer(target: self, action: #selector(gotoMyStarBokeList))
//        bokeHeader.addGestureRecognizer(tap)
        bokeView.addSubview(bokeHeader)
              
        bokeView.addSubview(myStarblogItemsView)
        myStarblogItemsView.updateRecommendData()
    }
    
    lazy var myStarblogItemsView: SectionItemsView = {
        let r = SectionItemsView()
        
        r.commendbokeClick = { [weak self] item, isMore, index in
//            if isMore {
//                let vc = MineBokeListViewController()
//                vc.vcType = .star
//                self?.gotoControllerFromRoot(vc)
//            } else {
//                SuperWebController.start((self!.navigationController!), uri: item.userBlogUrl, isRoot: true)
//            }
            
            self?.addBlog(index: index)
        }
        return r
    }()
    
    lazy var saveCard: QRCodeSaveCardView = {
        let r = QRCodeSaveCardView()
        r.isHidden = true
        return r
    }()
    
    
    
}

extension YFMineQRCodeVC {
    
    func addBlog(index: Int) {
        
        let contentView = YFChatBokeBottomSheetView()
        contentView.showAll = true
        contentView.tg_width.equal(.fill)
        contentView.tg_height.equal(350)
        contentView.chooseBoke = { [weak self] item in
            
            var data = YFFileDataUtil.readDataToFile(.recommend)
            if data.count < 3 {
                YFFileDataUtil.saveOneDataToFile(.recommend, blogItem: item)
            } else {
                YFFileDataUtil.deleteOneDataFromFile(.recommend, blogItem: data[index])
                YFFileDataUtil.saveOneDataToFile(.recommend, blogItem: item)
            }
            self?.myStarblogItemsView.updateRecommendData()
            GKCover.hide()
        }
        GKCover.cover(from: self.view.window, contentView: contentView, style: .translucent, showStyle: .bottom, showAnimStyle: .bottom, hideAnimStyle: .bottom, notClick: false)
        
    }
    
    func refreshUI() {
        
        let idString = IMController.addFriendPrefix.append(string: user.userID!)
        DispatchQueue.global().async {
            let image = CodeImageGenerator.createQRCodeImage(content: idString, size: CGSize(width: 140, height: 140), foregroundColor: UIColor.black, backgroundColor: UIColor.clear)
            DispatchQueue.main.async {
                self.codeImgView.image = image
            }
        }
        
        userAvatarImgView.sd_setImage(with: URL(string: user.faceURL), placeholderImage: R.image.defaultAvatar()!)
        username = SuperStringUtil.getUserShowname(showname: user.nickname!)
        
        userNicknameLbl.text = username
        userNicknameTF.text = username
        
       
        
        
    }
    
    @objc func showNicknameLblView() {
        userShowTitleView.show()
        userEditTitleView.hide()
        view.endEditing(true)
        username = userNicknameTF.text!
        userNicknameLbl.text = username
    }
    
    @objc func showNicknameTFView() {
        
        userShowTitleView.hide()
        userEditTitleView.show()
        
        userNicknameTF.text = username
        
    }
    
    @objc func copyUserID() {
        UIPasteboard.general.string = userShowId
        
        SuperToast.show(title: "复制成功")
    }
    
    
    @objc func saveQRCode() {
        

        saveCard.bindData(showname: username, codeImg: codeImgView.image, avater: userAvatarImgView.image, idString: userIDLbl.text)

        saveCard.isHidden = false
        saveViewToPhotoAlbum(view: saveCard.userCardView)
      
    }
    
  
    func saveViewToPhotoAlbum(view:UIView) {
       
        // 开始图形上下文
            UIGraphicsBeginImageContextWithOptions(view.bounds.size,  false, 1.0)
            defer { UIGraphicsEndImageContext() } // 确保上下文能被释放
            
            // 将view渲染到图形上下文中
            if let context = UIGraphicsGetCurrentContext() {
                view.layer.render(in: context)
                view.isHidden = true
            } else {
                view.isHidden = true
            }
            
            // 从图形上下文获取图片
            guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return }
            
            // 保存图片到相册
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(image:didFinishSavingWithError:contextInfo:)), nil)
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
 
    
    
}
