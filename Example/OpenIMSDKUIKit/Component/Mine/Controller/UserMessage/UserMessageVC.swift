//
//  UserMessageVC.swift
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
import OpenIMSDK
import NSObject_Rx
import ProgressHUD

#if ENABLE_MOMENTS
import OUIMoments
#endif

class UserMessageVC: BaseTitleController {

    var userID: String = ""
//    var ConversationInfo: ConversationInfo?
    var userInfo: QueryUserInfo?
    var isFriend:Bool = false//是否是好友关系
    var friendRemarkName:String = ""
    lazy var netWorkTipView: YFNotNetTopTipView = {
        let  r = YFNotNetTopTipView()
        return r
    }()
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
        self.getOtherSetting()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func initViews() {
        super.initViews()
        setBackGroundColor(.colorBackgroundAPP)
        
        
        addUserBg()
        addMore()
        initTableViewSafeAreCustom(.grouped)
        container.tg_padding = UIEdgeInsets(top: PADDING_MEDDLE, left: PADDING_OUTER, bottom: PADDING_MEDDLE, right: PADDING_OUTER)
        
//        tableView.tableHeaderView = tableHeaderView
//        view.layoutIfNeeded()
//        print(userHeaderView.frame)
//        datum = TestDataUtil.BokeData.filter({ item in
//            item.state == .normal
//        })
        tableView.register(MineBokeListCell.self, forCellReuseIdentifier: MineBokeListCell.className)
        tableView.contentInsetAdjustmentBehavior = .never
        

        tableView.reloadData()
        
        superFooterContainer.backgroundColor = .colorSurface
        superFooterContainerContainer.addSubview(footerBtnView)
        
//        IMController.shared.getConversation(sessionType: .c2c, sourceId: userID) { [weak self] (conversation: ConversationInfo?) in
//            guard let conversation else { return }
//
//            self?.ConversationInfo = conversation
//            self?.updataUI()
//        }
        getUserInfo()
        othersSeeMyBlog()
        view.addSubview(netWorkTipView)
        netWorkTipView.snp_remakeConstraints { make in
            make.top.equalTo(44 + kStatusBarHeight)
            make.left.right.equalTo(0)
            make.height.equalTo(44)
        }
        if IMController.shared.netWorkStatus == "hasNetWork"{
            netWorkTipView.isHidden = true
            container.tg_padding = UIEdgeInsets(top: PADDING_MEDDLE+44 + kStatusBarHeight, left: PADDING_OUTER, bottom: PADDING_MEDDLE, right: PADDING_OUTER)
            
        }else{
            netWorkTipView.isHidden = false
            container.tg_padding = UIEdgeInsets(top: PADDING_MEDDLE+44 + kStatusBarHeight+44, left: PADDING_OUTER, bottom: PADDING_MEDDLE, right: PADDING_OUTER)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(refreshNetWorkStatus(_:)), name: Notification.Name("netWorkStatus"), object: nil)
        
        if userInfo?.nickname?.isEmpty == false{
            updataUI()
        }
    }
    
    
    func getUserInfo() {
        
//        IMController.shared.getUserInfo(uids: [userID], groupID: nil) { [self] users in
//            guard let sdkUser = users.first else { return }
//            userInfo = sdkUser
//            
//            print(userInfo?.showName)
//            
//            
//        }
        ProgressHUD.animate()
        AccountViewModel.queryUserInfo(userIDList: [userID],
                                       valueHandler: { [weak self] (users: [QueryUserInfo]) in
            ProgressHUD.dismiss()
            guard let user: QueryUserInfo = users.first else { return }
//            print(user.nickname, user.phoneNumber, user.email)
            self?.userInfo = user
            self?.updataUI()
        }, completionHandler: {(errCode, errMsg) in
            SuperToast.show(title: String(errCode).localized())
            ProgressHUD.dismiss()
        })
        IMController.shared.getFriendsInfo(userIDs: [userID]) { [self] friendInfo in
            if let friendInfo = friendInfo.first {
                if friendInfo.remark != nil{
                    self.friendRemarkName = friendInfo.remark ?? ""
                    self.userHeaderView.username.text = self.friendRemarkName
                }
            }
        }        
    }
    
    
    func updataUI() {
        
        userHeaderView.bindData(userInfo: userInfo)
        if friendRemarkName.length > 0{
            userHeaderView.username.text = friendRemarkName
        }

        sectionBlogTitleLbl.text = "网站".localized()
        sectionMomentsTitleLbl.text =  "动态".localized()
        tableView.tableHeaderView = tableHeaderView
        view.layoutIfNeeded()
        
        
        
        self.tableView.reloadData()
        
        
        if userInfo?.userID == IMController.shared.uid {
            superFooterContainer.hide()
            moreBtn.hide()
//            footerBtnView.hide()
        }
        
//        userHeaderView.setNeedsLayout()
//        userHeaderView.layoutIfNeeded()
        
//        CGFloat height = [headerView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
//        let height = userHeaderView.systemLayoutSizeFitting(.)
//        CGRect headerFrame = headerView.frame;
//        headerFrame.size.height = height;
//        headerView.frame = headerFrame;
        
    }
    
    
    
    
    func addUserBg() {
        view.addSubview(topBg)
        topBg.snp_remakeConstraints { make in
            make.left.top.right.equalTo(0)
            make.height.equalTo(300)
        }
        let bottom = UIImageView()
        bottom.image = R.image.user_meesage_top_bg_bottom()
        bottom.frame = CGRect(x: 0, y: 150, width: UIScreen.main.bounds.width, height: 150)
        view.addSubview(bottom)
    }
    
    func addMore() {
        navView.addRighttItem(moreBtn)
        moreBtn.rx.tap.subscribe(onNext: { [weak self] in
            self?.showBottomSheet()
        }).disposed(by: rx.disposeBag)
    }
    lazy var moreBtn: QMUIButton = {
        let r = ViewFactoryUtil.imageBtn(R.image.tabMoreSelected()!.withTintColor())
        r.tintColor = .white
        return r
    }()
    //上面添加高度 为了tableview不在nav下面
    lazy var tableHeaderView: TGLinearLayout = {
        let r = TGLinearLayout(.vert)
        r.tg_width.equal(.fill)
        r.tg_height.equal(.wrap)
        r.addSubview(userHeaderView)
        userHeaderView.tg_top.equal(0)
        return r
    }()
    
    lazy var userHeaderView: UserMessageHeaderView = {
        let r = UserMessageHeaderView()
        return r
    }()
    
    var sectionBlogTitleLbl = UILabel()
    var sectionMomentsTitleLbl = UILabel()
    
    lazy var footerBtnView: BottomBtnView = {
        let r = BottomBtnView()
        r.setStyle(.sendMessage)
        
        r.leftBtn.rx.tap.subscribe(onNext: { [weak self] in
            self?.addfriend()
        }).disposed(by: rx.disposeBag)
        
        r.rightBtn.rx.tap.subscribe(onNext: { [weak self] in
            self?.toChat()
        }).disposed(by: rx.disposeBag)
        
        r.centerBtn.rx.tap.subscribe(onNext: { [weak self] in
            self?.toChat()
        }).disposed(by: rx.disposeBag)
        return r
    }()
    
    func addfriend(){
        if let handler = OIMApi.addFriendhandle {
            handler(self, userID, { res in
                
            })
        }
    }
    @objc func refreshNetWorkStatus(_ notidication: Notification) {
            if  let userinfo = notidication.userInfo, let netWorkStatus = userinfo["value"] as? String {
                if netWorkStatus == "hasNetWork"{
                    netWorkTipView.isHidden = true
                    container.tg_padding = UIEdgeInsets(top: PADDING_MEDDLE+44 + kStatusBarHeight, left: PADDING_OUTER, bottom: PADDING_MEDDLE, right: PADDING_OUTER)
                }else{
                    netWorkTipView.isHidden = false
                    container.tg_padding = UIEdgeInsets(top: PADDING_MEDDLE+44 + kStatusBarHeight+44, left: PADDING_OUTER, bottom: PADDING_MEDDLE, right: PADDING_OUTER)
                }
            }
        }
    func toChat()  {
        
        // MARK: - 张亚飞打的标记  获取会话信息
        IMController.shared.getConversation(sessionType: .c2c, sourceId: userID) { [weak self] (conversation: ConversationInfo?) in
            guard let conversation else { return }

            let vc = ChatViewControllerBuilder().build(conversation, hiddenInputBar: false)
            self?.navigationController?.pushViewController(vc, animated: true)
        }

    }
    
    func showBottomSheet()  {
        let contentView = MineChooseBottomSheetView()
        contentView.userID = userID
        contentView.tg_width.equal(.fill)
        contentView.isFriend = isFriend
        if isFriend == true{
            contentView.tg_height.equal(350)
        }else{
            contentView.tg_height.equal(300)
        }
        contentView.addUserMessageUI()
        contentView.currentController = self
        contentView.chooseTitle = { [weak self] title in
            print(title)
            self?.bottomSheetClick(title)
            GKCover.hide()
        }
        contentView.reportBlock = {[weak self] title in
            self?.reportAction()
        }
        GKCover.cover(from: view, contentView: contentView, style: .translucent, showStyle: .bottom, showAnimStyle: .bottom, hideAnimStyle: .bottom, notClick: false)
    }
    
    
    func reportAction() {
        let vc = YFFeedbackVC()
        vc.reportType = .user
        vc.userItem = userInfo
        gotoController(vc)
    }
    
    
    
    
    func bottomSheetClick(_ title: String) {
        if(title == "ModifyRemarks".localized()) {
            changeFriendName()
        }
        if(title == "Report".localized()) {
            let vc = YFFeedbackVC()
            vc.reportType = .user
            vc.userItem = userInfo
            gotoController(vc)
        }
        
        if(title == "解除好友关系".localized()) {
            
            // MARK: - 张亚飞打的标记  刷新首页
            let navController = self.tabBarController?.children.first as? UINavigationController;
            let vc: ChatListViewController? = navController?.viewControllers.first(where: { vc in
                return vc is ChatListViewController
            }) as? ChatListViewController
            
            if vc != nil {
                vc!.refreshConversations()
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    func changeFriendName() {
        let vc = ChangeMessageVC()
        vc.changeType = .markFriendname
        vc.saveBtn.rx.tap.subscribe(onNext: {[weak self, weak vc] in
            self?.changeFriendAPI(remark: vc?.editView.text)
        }).disposed(by: rx.disposeBag)
        self.gotoController(vc)
    }
    
    func changeFriendAPI(remark: String?) {
        self.saveRemark(remark: remark!, onSuccess: {[weak self] res in
            print(res)
            self?.friendRemarkName = remark ?? ""
            self?.userHeaderView.username.text = remark
            self?.navigationController?.popViewController()
        })
    }
    
    
    
    func saveRemark(remark: String, onSuccess: @escaping CallBack.StringOptionalReturnVoid)  {
        IMController.shared.setFriend(uid: userID, remark: remark, onSuccess: onSuccess)
    }
    
    
    
    func getOtherSetting() {
        IMController.shared.checkFriend(userID: userID) {[weak self] friend in
            self?.isFriend = friend
            if self?.isFriend == false {
                self?.footerBtnView.setStyle(.sendMessageAndAttention)
            } else {
                self?.footerBtnView.setStyle(.sendMessage)
            }
        }
//        IMController.shared.getUserInfo(uids: [userID], groupID: nil) { [self] users in
//            guard let sdkUser = users.first else { return }
////            userInfoRelay.accept(sdkUser)
//            
//            if let handler = OIMApi.queryUsersInfoWithCompletionHandler, userID != IMController.shared.uid {
//                handler([userID], { [weak self] users in
//                    guard let self else { return }
//                    
//                    if let chatUser = users.first {
//                        isFriend = !(chatUser.allowAddFriend == 1 && sdkUser.friendInfo == nil)
//                        
//                        if isFriend == false {
//                            self.footerBtnView.setStyle(.sendMessageAndAttention)
//                        } else {
//                            self.footerBtnView.setStyle(.sendMessage)
//                        }
//
//                    }
//                })
//            }
//            
////            let isFriend = sdkUser.friendInfo != nil
//            
////            guard !isFriend else {
//////                allowSendMsg.accept(true)
////                self.footerBtnView.setStyle(.sendMessageAndAttention)
////                return
////            }
//            
//            
//        }
    }
    
    lazy var tableSectionHeader: UIView = {
//        let r = TGLinearLayout(.vert)
        let section = ViewFactoryUtil.sectionHeaderView(title:"website".localized(), isHaveMore: true)
//        sectionTitleLbl = section.viewWithTag(20001) as! UILabel
//        if ConversationInfo != nil {
//            sectionTitleLbl.text = R.string.localizable.userBlog(ConversationInfo?.showName ?? "")
//        }
        
        section.tg_width.equal(.fill)
        section.tg_height.equal(44)
        section.tg_top.equal(12)
        section.backgroundColor = .white
        section.layer.cornerRadius = 14
        section.layer.maskedCorners  = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
//        r.addSubview(section)
        let tap = UITapGestureRecognizer(target: self, action: #selector(gotoBokeList))
        section.addGestureRecognizer(tap)
        return section
    }()
    
    
    
    class tableViewSectionHeader : TGLinearLayout {
        
        
        init() {
            super.init(frame: .zero, orientation: .vert)
            innerInit()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            innerInit()
            tg_height.equal(56)
        }
        
        func innerInit()  {
            addSubview(sectionView)
        }
        
        lazy var sectionView: UIView = {
            let section = ViewFactoryUtil.sectionHeaderView(title: "website".localized(), isHaveMore: true)
            section.tg_width.equal(.fill)
            section.tg_height.equal(44)
            section.tg_top.equal(12)
            section.backgroundColor = .white
            section.layer.cornerRadius = 14
            section.layer.maskedCorners  = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            return section
        }()
        
        
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
//    override func viewWillLayoutSubviews() {
//        view.layoutIfNeeded()
//    }
}

extension UserMessageVC {
    
    func othersSeeMyBlog() {
        ProgressHUD.animate()
        YFMineNetViewModel.otherSeeMyBlog(userId: userID) { [weak self] data in
            ProgressHUD.dismiss()
            self?.datum = data
            self?.tableView.reloadData()
        } completionHandler: { errCode, errMsg in
            ProgressHUD.dismiss()
            SuperToast.show(title: errMsg?.localized())
        }

    }
}



extension UserMessageVC {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let r = tableSectionHeader
//        
//        let titleLbl = r.viewWithTag(20001) as! UILabel
//        if section == 0 {
//            titleLbl.text = R.string.localizable.userMoments(ConversationInfo?.showName ?? "")
//            sectionMomentsTitleLbl = titleLbl
//        } else {
//            titleLbl.text = R.string.localizable.userBlog(ConversationInfo?.showName ?? "")
//            sectionBlogTitleLbl = titleLbl
//        }
//        
//        return r
        
//        let userShowname = SuperStringUtil.getUserShowname(showname: userInfo?.nickname ?? "")
        
        let r = tableViewSectionHeader()
        let sectionLbl = r.sectionView.viewWithTag(20001) as! UILabel
        let leftImg = r.sectionView.viewWithTag(20003) as! UIImageView
        leftImg.image = section == 0 ? R.image.section_moments_icon()! : R.image.boke_icon()
        if section == 0 {
            
            r.sectionView.layer.maskedCorners  = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            sectionMomentsTitleLbl = sectionLbl
            if userInfo != nil {
                sectionLbl.text = "动态".localized()
            }
            let tap = UITapGestureRecognizer(target: self, action: #selector(gotoMoments))
            r.sectionView.addGestureRecognizer(tap)
        } else {
            if datum.count == 0 {
                r.sectionView.layer.maskedCorners  = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            } else {
                r.sectionView.layer.maskedCorners  = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            }
            
            sectionBlogTitleLbl = sectionLbl
            if userInfo != nil {
                sectionLbl.text = "网站".localized()
            }
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(gotoBokeList))
            r.sectionView.addGestureRecognizer(tap)
        }
        
        return r
    }
    
    
    @objc func gotoBokeList() {
                
        let vc = MineBokeListViewController()
        vc.vcType = .othersBlog
        vc.othersID = userInfo?.userID
        vc.othersName = friendRemarkName.length > 0 ? friendRemarkName : SuperStringUtil.getUserShowname(showname: userInfo?.nickname ?? "")
        gotoController(vc)
        
    }
    
    
    @objc func gotoMoments() {
//        let vc = MomentsViewController()
//        vc.hidesBottomBarWhenPushed = true
//        self.navigationController.setNavigationBarHidden(false, animated: true)
//        self.pushViewController(vc)
//        self.navigationController?.pushViewController(vc)
        
        if let user = userInfo {
            let vc = OthersViewController(userID: user.userID!, nickname: friendRemarkName.length > 0 ? friendRemarkName : SuperStringUtil.getUserShowname(showname: userInfo?.nickname ?? ""), faceURL: user.faceURL)
            navigationController?.pushViewController(vc, animated: true)
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 56
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if self.userInfo != nil {
            return 2
        } else {
            return 0
        }
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if  section == 0 {
            return 0
        }
        return datum.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MineBokeListCell.className, for: indexPath) as! MineBokeListCell
        cell.isClean()
        cell.bindData(datum[indexPath.row] as! myBlogShowBlogPOModel)
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = datum[indexPath.row] as! myBlogShowBlogPOModel
//        SuperWebController.start((self.navigationController!), uri: item.userBlogUrl)
//        YFMineNetViewModel.scanBlog(blog: item)

        SuperWebController.startAboubBlog(self.navigationController!, blogItem: item)
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        if section == 0 {
            return nil
        } else {
            let r = TGLinearLayout(.vert)
            r.tg_width.equal(.fill)
            let height = datum.count > 0 ? 20 : 0
            r.tg_height.equal(height)
            r.backgroundColor = .white
            r.layer.cornerRadius = 10
            r.layer.maskedCorners  = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            return r
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if section == 0 {
            return 0
        } else {
            return datum.count > 0 ? 20 : 0
        }
    }
    
    
}



