//
//  MeHomeController.swift
//  MyCloudMusic
//
//  Created by mac on 2024/4/29.
//

import OUICore
import OUIIM
import TangramKit
import UIKit
import RxCocoa
import NSObject_Rx

#if ENABLE_MOMENTS
import OUIMoments
#endif

class MeHomeController: BaseLogicController {
    private let _viewModel = MineViewModel()
    
    var vipTitle = UILabel()
    var userShowId: String = ""
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        _viewModel.queryUserInfo()
        
        getMyBlog()
        getMyStarBlog()
        updatelanguage()
        
    }
    
    override func initViews() {
        super.initViews()
        initLinearLayoutSafeArea()
        container.tg_padding = UIEdgeInsets(top: PADDING_OUTER, left: PADDING_OUTER, bottom: PADDING_OUTER, right: PADDING_OUTER)
        container.tg_space = 12
        
        addTopUserMessage()
        addVIP()
        addCode()
        addMoments()
        addMyBoke()
        addMyStarBoke()
        
        bindData()
        
//        YFMineNetViewModel.updateLanguage()
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func bindData() {
        
        _viewModel.currentUserRelay.subscribe(onNext: { [weak self] (user: QueryUserInfo?) in
            guard let self, user != nil else { return }
            
            updateHeaderView()
            
        }).disposed(by: rx.disposeBag)
        
    }

    func updatelanguage() {
        
//        let  viplbl = vipView.viewWithTag(20001) as! UILabel
//        viplbl.text = "我的二维码".localized()
        
        
        let  codeTitle = sectionCodeView.viewWithTag(20001) as! UILabel
        codeTitle.text = "我的二维码".localized()
        
        let  monentsTitle = sectionMomentsView.viewWithTag(20001) as! UILabel
        monentsTitle.text = "我的动态".localized()
        
        let  myBlogTitle = sectionMyBlogView.viewWithTag(20001) as! UILabel
        myBlogTitle.text = "我的博客".localized()
        
        let  starBlogTitle = sectionStarBlogView.viewWithTag(20001) as! UILabel
        starBlogTitle.text = "我收藏的博客".localized()
        
    }
    
    func updateHeaderView() {
        let user = _viewModel.currentUserRelay.value
        
//        userIcon.showAvator(user?.faceURL)
        
        let userState = SuperStringUtil.getUserState(showname: user?.nickname ?? "")
        
        avatarImageView.setAvatar(url: user?.faceURL, text: userState.n)
        username.text = userState.n
        tagLable.text = SuperStringUtil.getUserTag(showname: (user?.nickname)!)  ?? "普通用户".localized()
        tagLable.textColor = userState.v > 0  ? .init(hexString: "#7238EF")  : .init(hexString: "#999999")
//        userID.text = user?.chatID
        
//        print(user?.userID)
//        print(user?.chatID)
        
//        if userState.v > 0 {
//            userShowId = "\(String(describing: user?.chatID != nil ? user!.chatID! : user!.userID!))"
//        } else {
//            userShowId = "\(String(describing: user?.chatID != nil ? user!.chatID! : user!.userID!))"
//        }
        userShowId = user?.chatID ?? (user?.userID ?? "")
        if userState.v > 0 {
            vipTitle.text = "VIP ID: ".localized() + userShowId
        } else {
            vipTitle.text = "ID: " + userShowId
        }
        
        
        let defaults = UserDefaults.standard
        defaults.set(userState.v, forKey: "vipRank")
        
    }
    
    func addTopUserMessage() {
        let userView = TGLinearLayout(.horz)
        userView.tg_gravity = .vert.center
        userView.corner(MEDDLE_RADIUS)
        userView.tg_width.equal(.fill)
        userView.tg_height.equal(.wrap)
        userView.tg_padding = UIEdgeInsets(top: PADDING_OUTER, left: PADDING_SMALL, bottom: PADDING_OUTER, right: 0)
//        userView.backgroundColor = .red
        userView.tg_space = PADDING_OUTER
        container.addSubview(userView)
        
//        userView.addSubview(userIcon)
        userView.addSubview(avatarImgBg)
        avatarImgBg.addSubview(avatarImageView)
        
        let userMessageView = TGLinearLayout(.vert)
        userMessageView.tg_width.equal(.fill)
        userMessageView.tg_height.equal(.wrap)
        userMessageView.tg_left.equal(14)
//        userMessageView.tg_space = PADDING_SMALL
        userView.addSubview(userMessageView)
        
        userMessageView.addSubview(username)
        userMessageView.addSubview(tagLable)
//        userMessageView.addSubview(userID)
        
//        userView.addSubview(scanBtn)
        userView.addSubview(appSettingBtn)

    }

    lazy var userIcon: UIImageView = {
        let r = ViewFactoryUtil.circleImgView(R.image.defaultAvatar()!, 64)
        return r
    }()
    
    lazy var avatarImgBg: UIView = {
        let r = UIView()
        r.tg_width.equal(64)
        r.tg_height.equal(64)
        return r
    }()
    
    lazy var avatarImageView: AvatarView = {
        let v = AvatarView()
        v.size = 64
        v.border(.white)
        v.corner(32)
        return v
    }()
    
    lazy var username: UILabel = {
        let r = ViewFactoryUtil.customBoldTilteLable("", font: TEXT_LARGE4)
        r.numberOfLines = 1
        return r
    }()
    
//    lazy var usertag : UserTagView = {
//       let r = UserTagView()
//        r.addThirdUI()
//        return r
//    }()
    
    lazy var tagLable: UILabel = {
            let v = UILabel()
            v.font = UIFont(name: "PingFangSC-Semibold", size: 11)
            v.textColor = .init(hexString: "#7238EF")
//            v.text = "[V4、\("企业".localized())、\("博客".localized())]".localized()
            v.text = nil
            v.tg_width.equal(.wrap)
            v.tg_height.equal(.wrap)
            return v
        }()
    
//    lazy var userID: UILabel = {
//        let r = ViewFactoryUtil.sectionTilteLbael()
//        r.text = "用户id"
//        return r
//    }()
    
    lazy var scanBtn: QMUIButton = {
        let r = ViewFactoryUtil.imageBtn(R.image.mine_QRCode_icon()!, 20)
        r.tg_right.equal(0)
        r.tg_centerY.equal(0)
        r.addTarget(self, action: #selector(scanCode), for: .touchUpInside)
        return r
    }()
    
    lazy var appSettingBtn: QMUIButton = {
        let r = ViewFactoryUtil.imageBtn(R.image.mine_setting_icon()!, 20)
        r.tg_right.equal(scanBtn.tg_left, offset: 10)
        r.tg_centerY.equal(0)
        r.addTarget(self, action: #selector(settingUserMessage), for: .touchUpInside)
        return r
    }()
    
//    lazy var settingIMg: UIImageView = {
//        let r = ViewFactoryUtil.defalutImgView(R.image.mine_setting_icon()!, 20)
//        r.tg_right.equal(scanBtn.tg_left, offset: 10)
//        r.tg_centerY.equal(0)
//        let tap = UITapGestureRecognizer(target: self, action: #selector(settingUserMessage))
//        r.isUserInteractionEnabled = true
//        r.addGestureRecognizer(tap)
//        
//        return r
//    }()
    
    
    lazy var vipView: UIView = {
        let vipView = ViewFactoryUtil.sectionHeaderViewAboutVIP(R.image.section_vip()!, title: "ID:", isHaveMore: true)
        vipView.backgroundColor = .white
        vipView.corner(MEDDLE_RADIUS)
        vipView.tg_width.equal(.fill)
        vipView.tg_height.equal(44)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(gotoVip))
        vipView.addGestureRecognizer(tap)
        
        
        
        
        return vipView
    }()
    
    func addVIP() {

        container.addSubview(vipView)
        
        vipTitle = vipView.viewWithTag(20001) as! UILabel
        let copyImg = vipView.viewWithTag(20002) as! UIImageView
        
        let copyView = UIView()
//        copyView.backgroundColor = .red.withAlphaComponent(0.3)
        view.addSubview(copyView)
        copyView.snp.makeConstraints { make in
            make.left.equalTo(vipTitle.snp_left)
            make.top.equalTo(vipView)
            make.bottom.equalTo(vipView)
            make.right.equalTo(copyImg.snp_right)
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(copyUserID))
        copyView.addGestureRecognizer(tap)
        
    }
    
    func addCode() {

        container.addSubview(sectionCodeView)
    }
    
    lazy var sectionCodeView: UIView = {
        let codeView = ViewFactoryUtil.sectionHeaderView(R.image.section_QR_code()!, title: "我的二维码".localized(), isHaveMore: true)
        codeView.backgroundColor = .white
        codeView.corner(MEDDLE_RADIUS)
        codeView.tg_width.equal(.fill)
        codeView.tg_height.equal(44)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(gotoCode))
        codeView.addGestureRecognizer(tap)
        return codeView
    }()
    
    
    func addMoments() {
        
        container.addSubview(sectionMomentsView)
    }
    
    
    lazy var sectionMomentsView : UIView = {
        let codeView = ViewFactoryUtil.sectionHeaderView(R.image.section_moments_icon()!, title: "我的动态".localized(), isHaveMore: true)
        codeView.backgroundColor = .white
        codeView.corner(MEDDLE_RADIUS)
        codeView.tg_width.equal(.fill)
        codeView.tg_height.equal(44)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(gotoMoments))
        codeView.addGestureRecognizer(tap)
        return codeView
    }()
    
    

    func addMyBoke() {
        let bokeView = TGLinearLayout(.vert)
        bokeView.backgroundColor = .white
        bokeView.corner(MEDDLE_RADIUS)
        bokeView.tg_width.equal(.fill)
        bokeView.tg_height.equal(.wrap)
        container.addSubview(bokeView)
        
        
        bokeView.addSubview(sectionMyBlogView)
              
        bokeView.addSubview(bokeItemsView)
    }
    
    lazy var sectionMyBlogView: UIView = {
        let bokeHeader = ViewFactoryUtil.sectionHeaderView(title: "我的博客".localized(), isHaveMore: true)
        bokeHeader.tg_height.equal(44)
        let tap = UITapGestureRecognizer(target: self, action: #selector(gotoMyBokeList))
        bokeHeader.addGestureRecognizer(tap)
        return bokeHeader
    }()
    
    
    lazy var bokeItemsView: SectionItemsView = {
        let r = SectionItemsView()
        
        r.bokeClick = { [weak self] item, isMore in
            if isMore {
                self?.gotoControllerFromRoot(MineBokeListViewController.self)
            } else {

                
                let vc = MineBokeStatisticsVC()
                vc.boke = item
                
                self?.gotoControllerFromRoot(vc)

            }
        }
        
        return r
    }()
    
    func addMyStarBoke() {
        let bokeView = TGLinearLayout(.vert)
        bokeView.backgroundColor = .white
        bokeView.corner(MEDDLE_RADIUS)
        bokeView.tg_width.equal(.fill)
        bokeView.tg_height.equal(.wrap)
        container.addSubview(bokeView)
        
   
        bokeView.addSubview(sectionStarBlogView)
              
        bokeView.addSubview(myStarblogItemsView)
    }
    
    
    lazy var sectionStarBlogView: UIView = {
        let bokeHeader = ViewFactoryUtil.sectionHeaderView(R.image.section_star()!,title: "我收藏的博客".localized(), isHaveMore: true)
        bokeHeader.tg_height.equal(44)
        let tap = UITapGestureRecognizer(target: self, action: #selector(gotoMyStarBokeList))
        bokeHeader.addGestureRecognizer(tap)
        return bokeHeader
    }()
    
    lazy var myStarblogItemsView: SectionItemsView = {
        let r = SectionItemsView()
        
        r.bokeClick = { [weak self] item, isMore in
            if isMore {
                let vc = MineBokeListViewController()
                vc.vcType = .star
                self?.gotoControllerFromRoot(vc)
            } else {
                SuperWebController.start((self!.navigationController!), uri: item.myBlogShowBlogPO.userBlogUrl, isRoot: true)
            }
        }
        
        return r
    }()
    
    
    
}



extension MeHomeController {
    @objc func scanCode() {
//        gotoControllerFromRoot(UserMessageVC.self)
        guard let user: QueryUserInfo = _viewModel.currentUserRelay.value else { return }
        let vc = QRCodeViewController(idString: IMController.addFriendPrefix.append(string: user.userID!))
        vc.avatarView.setAvatar(url: user.faceURL, text: user.nickname)
        vc.nameLabel.text = user.nickname
        vc.tipLabel.text = "qrcodeHint".innerLocalized()
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func settingUserMessage() {
        gotoControllerFromRoot(MineSettingVC.self)
    }
    
    @objc func showMoreBoke() {
        print(#function)
//        bokeItemsView.update(data: Array(repeating: "hello", count: Int.random(in: 1 ... 10)))
    }
    
  
    @objc func gotoMyBokeList() {
        let vc = MineBokeListViewController()
        vc.vcType = .meBlog
        gotoControllerFromRoot(vc)
    }
    @objc func gotoMyStarBokeList() {
        let vc = MineBokeListViewController()
        vc.vcType = .star
        gotoControllerFromRoot(vc)
        
//        gotoControllerFromRoot(YFChatNewFriendListVC.self)
    }
    
    
    @objc func gotoVip() {
        gotoControllerFromRoot(YFMineHomeBuyVipVC.self)
    }
    
    @objc func gotoMoments() {
//        let vc = MomentsViewController()
//        gotoControllerFromRoot(vc)
        
        guard let user: QueryUserInfo = _viewModel.currentUserRelay.value else { return }
        let vc = OthersViewController(userID: user.userID!, nickname: SuperStringUtil.getUserShowname(showname: user.nickname ?? ""), faceURL: user.faceURL)
//        navigationController?.pushViewController(vc, animated: true)
        gotoControllerFromRoot(vc)
    }
    
    @objc func gotoCode() {
        guard let user: QueryUserInfo = _viewModel.currentUserRelay.value else { return }
//        let vc = QRCodeViewController(idString: IMController.addFriendPrefix.append(string: user.userID!))
//        vc.avatarView.setAvatar(url: user.faceURL, text: user.nickname)
//        vc.nameLabel.text = user.nickname
//        vc.tipLabel.text = "qrcodeHint".innerLocalized()
//        vc.hidesBottomBarWhenPushed = true
//        navigationController?.pushViewController(vc, animated: true)
        
        let v = YFMineQRCodeVC()
        v.user = user
//        navigationController?.pushViewController(v, animated: true)
        gotoControllerFromRoot(v)
    }
    
    
    @objc func copyUserID() {
        UIPasteboard.general.string = userShowId
        
        SuperToast.show(title: "复制成功".localized())
    }
    
    
    func getMyBlog() {
        
        if let IMUser = IMController.shared.currentUserRelay.value {
            
            YFMineNetViewModel.mineBlog(userId: IMUser.userID) { [weak self] data in
                self?.bokeItemsView.updateNet(data: data)

            } completionHandler: { errCode, errMsg in
                
            }

        }
        
    }
    
    
    func getMyStarBlog() {
        
//        print(YFFileDataUtil.readDataToFile())
        
        self.myStarblogItemsView.updateNet(data: YFFileDataUtil.readDataToFile())
        
    }
    
    
    
}
