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



class UserMessageVC: BaseTitleController {

    var userID: String = ""
//    var ConversationInfo: ConversationInfo?
    var userInfo: QueryUserInfo?
    var isFriend:Bool = false//是否是好友关系
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
        tableView.contentInsetAdjustmentBehavior = .never
        

        tableView.reloadData()
        
        superFooterContainer.backgroundColor = .colorSurface
        superFooterContainerContainer.addSubview(footerBtnView)
        getUserInfo()
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
        ProgressHUD.animate()
        AccountViewModel.queryUserInfo(userIDList: [userID],
                                       valueHandler: { [weak self] (users: [QueryUserInfo]) in
            ProgressHUD.dismiss()
            guard let user: QueryUserInfo = users.first else { return }
            self?.userInfo = user
            self?.updataUI()
        }, completionHandler: {(errCode, errMsg) in
            SuperToast.show(title: String(errCode) + "：" + String(errCode).localized())
            ProgressHUD.dismiss()
        })
        
    }
    
    func updataUI() {
        
        userHeaderView.bindData(userInfo: userInfo)
        
        
        let user = SuperStringUtil.getUserState(showname: userInfo?.nickname ?? "")
        
        let userShowname = user.n
        
        
        
        tableView.tableHeaderView = tableHeaderView
        view.layoutIfNeeded()
        
        
        
        self.tableView.reloadData()
        
        
        if userInfo?.userID == IMController.shared.uid {
            superFooterContainer.hide()
            moreBtn.hide()
        }
        
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
        
        // MARK: -    获取会话信息
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
            
            // MARK: -    刷新首页
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
//                        isFriend = !(chatUser.allowAddFriend == 1 && sdkUser != nil)
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
//        }
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}


extension UserMessageVC {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.className, for: indexPath)
        return cell
    }
}



