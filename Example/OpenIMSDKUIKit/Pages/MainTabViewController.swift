
import OUIIM
import OUICore
import OpenIMSDK
import RxSwift
import RxCocoa
import ProgressHUD
import Localize_Swift
import MJExtension
import IQKeyboardManagerSwift
import GTSDK
import Alamofire
#if ENABLE_MOMENTS
import OUIMoments
#endif

#if ENABLE_CALL
import OUICalling
#endif

private let signupuserKey = "signupuserKey"

class MainTabViewController: UITabBarController {
    
    private let _viewModel = MineViewModel()
    private let reachabilityManager = NetworkReachabilityManager()
    var mineNavigationController:NavigationController?
    
    func clearConversation() {
        conversationViewController.clearRecord()
    }
    
    private let _disposeBag = DisposeBag()
    var lastTabBarItemTag: Int = 0
    var lastTabBarItemSelectedTime: Date?
//    private let callRecordsViewController = CallRecordsViewController()
    private let conversationViewController = ChatListViewController()
//    private let CallRecordsViewController = CallRecordsViewController()
    private lazy var _moreView: TabMoreView = {
        let v = TabMoreView()
        return v
    }()
    
    private lazy var _YFChooseUserAvatarCardView: YFChooseUserAvatarCardView = {
        let v = YFChooseUserAvatarCardView()
        return v
    }()
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        var controllers: [UIViewController] = []
        
        // 注册对名为"myNotification"的通知的观察
//        NotificationCenter.default.addObserver(self, selector: #selector(changeAvatar), name: Notification.Name("homeChooseUserIcon"), object: nil)
        
        let chatNav = NavigationController.init(rootViewController: conversationViewController)
        chatNav.tabBarItem.image = UIImage.init(named: "TabMessageSelected_0")?.withRenderingMode(.alwaysOriginal)
        chatNav.tabBarItem.selectedImage = UIImage.init(named: "TabMessageSelected_1")?.withRenderingMode(.alwaysOriginal)
        controllers.append(chatNav)
        IMController.shared.totalUnreadSubject.map({ (unread: Int) -> String? in
            IMController.shared.unChatMessageCount = unread
            UIApplication.shared.applicationIconBadgeNumber = IMController.shared.unChatMessageCount + IMController.shared.unCallPhoneMessageCount + IMController.shared.unContactMessageCount
            var badge: String?
            if unread == 0 {
                badge = nil
            } else if unread > 99 {
                badge = "99+"
            } else {
                badge = String(unread)
            }
            return badge
        }).bind(to: chatNav.tabBarItem.rx.badgeValue).disposed(by: _disposeBag)
        
        
//        CallRecordsViewController
        ///通话记录
        let recordsVC = CallRecordsViewController()
        let recordsNav = NavigationController.init(rootViewController: recordsVC)
        recordsNav.tabBarItem.image = UIImage.init(named: "TabPhoneSelected_0")?.withRenderingMode(.alwaysOriginal)
        recordsNav.tabBarItem.selectedImage = UIImage.init(named: "TabPhoneSelected_1")?.withRenderingMode(.alwaysOriginal)
        controllers.append(recordsNav)
        
//        let vc = FriendListViewController()
//        vc.hidesBottomBarWhenPushed = true
//        self?.navigationController?.pushViewController(vc, animated: true)
        
//        ContactsViewController  FriendListViewController
        let contactVC = FriendListViewController()
        let contactNav = NavigationController.init(rootViewController: contactVC)
        contactNav.tabBarItem.image = UIImage.init(named: "TabContactSelected_0")?.withRenderingMode(.alwaysOriginal)
        contactNav.tabBarItem.selectedImage = UIImage.init(named: "TabContactSelected_1")?.withRenderingMode(.alwaysOriginal)
        controllers.append(contactNav)

        IMController.shared.contactUnreadSubject.map({ (unread: Int) -> String? in
            IMController.shared.unContactMessageCount = unread
            UIApplication.shared.applicationIconBadgeNumber = IMController.shared.unChatMessageCount + IMController.shared.unCallPhoneMessageCount + IMController.shared.unContactMessageCount
            var badge: String?
            if unread == 0 {
                badge = nil
            } else {
                badge = String(unread)
            }
            return badge
        }).bind(to: contactNav.tabBarItem.rx.badgeValue).disposed(by: _disposeBag)
                    
//        let myNav = NavigationController.init(rootViewController: UserMessageVC())
//        myNav.tabBarItem.image = UIImage.init(named: "TabMeSelected_0")
//        myNav.tabBarItem.selectedImage = UIImage.init(named: "TabMeSelected_1")
//        controllers.append(myNav)
        
//        MineViewController  MeHomeController
        let mineNav = NavigationController.init(rootViewController: MeHomeController())
        mineNav.tabBarItem.image = UIImage.init(named: "TabMeSelected_0")?.withRenderingMode(.alwaysOriginal)
        mineNav.tabBarItem.selectedImage = UIImage.init(named: "TabMeSelected_1")?.withRenderingMode(.alwaysOriginal)
        controllers.append(mineNav)
        mineNavigationController = mineNav
        
                
        
        self.viewControllers = controllers
        self.tabBar.isTranslucent = false
        self.tabBar.backgroundColor = .white;
        
        self.tabBar.layer.shadowColor = UIColor.black.cgColor;
        self.tabBar.layer.shadowOpacity = 0.08;
        self.tabBar.layer.shadowOffset = CGSize.init(width: 0, height: 0);
        self.tabBar.layer.shadowRadius = 5;
        
        self.tabBar.backgroundImage = UIImage.init()
        self.tabBar.shadowImage = UIImage.init()
        delegate = self
        
        setText()
        NotificationCenter.default.addObserver(self, selector: #selector(setText), name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(logout), name: .init("logout"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(deleteAccount), name: .init("deleteAccount"), object: nil)
        
        loginExsitAccount()
        
//        tabBar.backgroundColor = .black183
        
//        let appearance = tabBar.standardAppearance.copy()
//        appearance.backgroundImage = UIImage.getImageAboutColor(color: .clear)
//        appearance.shadowImage = UIImage.getImageAboutColor(color: .clear)
//        tabBar.standardAppearance = appearance
        
        tabBar.layer.shadowOpacity = 0.0
        
        tabBar.unselectedItemTintColor = .init(hexString: "#333333")
        
        // 注册对名为"refrehCallLogsbadgeValue"的通知的观察  刷新badgeValue
        NotificationCenter.default.addObserver(self, selector: #selector(refreshBadges(_:)), name: Notification.Name("refrehCallLogsbadgeValue"), object: nil)
        
        reachabilityManager?.startListening()
        reachabilityManager?.listener = { status in
            switch status {
            case .notReachable:
                IMController.shared.netWorkStatus = "noNetWork"
                NotificationCenter.default.post(name: Notification.Name("netWorkStatus"), object: nil, userInfo: ["value": "noNetWork"])
            default:
                IMController.shared.netWorkStatus = "hasNetWork"
                NotificationCenter.default.post(name: Notification.Name("netWorkStatus"), object: nil, userInfo: ["value": "hasNetWork"])
                break
            }
        }
        CallingManager.calculateCount()
        
    }
    
    @objc func refreshBadges(_ notidication: Notification) {
        
        print(notidication.userInfo)
        
        if  let userinfo = notidication.userInfo, let receivedValue = userinfo["value"] as? String {
            
            
//            let root = self?.tabBarController
//            let tabBarItem = root?.tabBar.items![0]
//            if count > 0 {
//                tabBarItem?.badgeValue = count > 99 ? "99+" : "\(count)"
//            } else {
//                tabBarItem?.badgeValue = nil
//            }
            
            let tabBarItem = self.tabBar.items![1]
            let count = Int(receivedValue) ?? 0
            if  count > 0  {
                tabBarItem.badgeValue = count > 99 ? "99+" : "\(count)"
                IMController.shared.unCallPhoneMessageCount = count
                UIApplication.shared.applicationIconBadgeNumber = IMController.shared.unChatMessageCount + IMController.shared.unCallPhoneMessageCount + IMController.shared.unContactMessageCount
            } else {
                tabBarItem.badgeValue = nil
            }
            
        }
    }
    
    @objc
    private func setText() {
        
        let Arr = ["消息".localized(), "通话记录".localized(), "通讯录".localized(), "我的".localized()]
        
        for (index, element) in Arr.enumerated() {
            
            viewControllers?[index].tabBarItem.title = element
            
        }
//        
//        viewControllers?[0].tabBarItem.title = "消息".localized()
//        viewControllers?[1].tabBarItem.title = "通话记录".localized()
//        viewControllers?[2].tabBarItem.title = "通讯录".localized()
//        viewControllers?[3].tabBarItem.title = "我的".localized()
//        viewControllers?[4].tabBarItem.title = "工具箱".localized()
        
       
    }
    
    private func loginExsitAccount() {
        
        IMController.shared.currentUserRelay.subscribe(onNext: { r in
            guard let r else { return }
            
            let p = ["userID": r.userID, "nickname": r.nickname, "faceURL": r.faceURL]

            if let json = try? JSONSerialization.data(withJSONObject: p, options: .fragmentsAllowed) {
                UserDefaults.standard.set(json, forKey: signupuserKey)
                UserDefaults.standard.synchronize()
            }
        }).disposed(by: _disposeBag)
        
        if let uid = UserDefaults.standard.object(forKey: AccountViewModel.IMUidKey) as? String,
           let token = UserDefaults.standard.object(forKey: AccountViewModel.IMTokenKey) as? String,
           let chatToken = UserDefaults.standard.object(forKey: AccountViewModel.bussinessTokenKey) as? String {
            
            if let u = UserDefaults.standard.object(forKey: signupuserKey) as? String, let user = JsonTool.fromJson(u, toClass: UserInfo.self) {
                conversationViewController.refreshUserInfo(userInfo: user)
            }
            AccountViewModel.loginIM(uid: uid, imToken: token, chatToken: chatToken) {[weak self] (errCode, errMsg) in

                if errMsg != nil {
                    ProgressHUD.error( errMsg)
//                    SuperToast.show(title: errMsg)
                    self?.presentLoginController()
                } else {
                    self?.loginSuccess()
                   
                }
            }
        } else {
            DispatchQueue.main.async {
                self.presentLoginController()
            }
        }
    }
    
    @objc private func logout() {
#if ENABLE_CALL
        OUICalling.CallingManager.manager.end()
#endif
        IMController.shared.currentUserRelay.accept(nil)
        pushBindAlias(false)
        UIApplication.shared.applicationIconBadgeNumber = 0
        IMController.shared.unChatMessageCount = 0
        IMController.shared.unCallPhoneMessageCount = 0
        IMController.shared.unContactMessageCount = 0
        IMController.shared.certificationLevel = 0
        IMController.shared.isSetPayPassWord = false
        AccountViewModel.saveUser(uid: nil, imToken: nil, chatToken: nil)
        presentLoginController()
    }
    @objc private func deleteAccount(){
#if ENABLE_CALL
        OUICalling.CallingManager.manager.end()
#endif
        IMController.shared.currentUserRelay.accept(nil)
        UIApplication.shared.applicationIconBadgeNumber = 0
        IMController.shared.unChatMessageCount = 0
        IMController.shared.unCallPhoneMessageCount = 0
        IMController.shared.unContactMessageCount = 0
        IMController.shared.certificationLevel = 0
        IMController.shared.isSetPayPassWord = false
        AccountViewModel.saveUser(uid: nil, imToken: nil, chatToken: nil)
        presentLoginController()
    }
    
    private func presentLoginController() {
        viewControllers?.first?.tabBarItem.badgeValue = nil
        if let viewControllers, viewControllers.count > 1 {
            self.viewControllers?[1].tabBarItem.badgeValue = nil
            viewControllers.forEach({ $0.navigationController?.popToRootViewController(animated: false) })
        }
        var isNew = true
        if isNew {
            let vc = YFAibitlinHome()
            vc.modalPresentationStyle = .fullScreen
            let nav = UINavigationController.init(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: false) {
                self.selectedIndex = 0
                CallingManager.calculateCount()
                self.mineNavigationController?.popToRootViewController(animated: false)
                
            }
        } else {
            let vc = YFLoginVC()
            vc.loginBtn.rx.tap.subscribe(onNext: {  [weak vc, weak self] in
                guard let controller = vc, let phone = controller.phone, !phone.isEmpty else { return }
                
                if !controller.chooseDelegateBtn.isSelected {
                    SuperToast.show(title: "请勾选协议".localized())
                    return
                }

                if vc?.useType == .usePhone {
                    if !SuperStringUtil.isPhoneNumber(controller.phone!) {
                        SuperToast.show(title:  "填写正确的手机号码".localized())
                        return
                    }                   
                } else {
                   
                    if !SuperStringUtil.isEmail(controller.phone!) {
                        SuperToast.show(title:  "填写正确的邮箱".localized())
                        return
                    }
                }

                

                let psw = controller.password
                let code = controller.verificationCode
                

                
                var account: String?
                
                ProgressHUD.animate()
                let curAccount = vc?.useType == .usePhone ? phone : nil
                let preAccount = AccountViewModel.perLoginAccount
                
                if curAccount != preAccount {
                    self?.clearConversation()
                }
                
                AccountViewModel.loginDemo(phone: vc?.useType == .usePhone ? phone : nil,
                                           account: account,
                                           email: vc?.useType == .useEmail ? phone : nil,
                                           psw: code != nil ? nil : psw,
                                           verificationCode: code,
                                           areaCode: controller.areaCode!,
                                           LoginType: 0) {[weak self] (errCode, errMsg) in
                    
                    
                    if errMsg != nil {
                        ProgressHUD.dismiss()
                        SuperToast.show(title: String(errCode).localized())
                        self?.presentLoginController()
                        
                    } else {
                        UserDefaults.standard.setValue(vc?.useType.rawValue, forKey: loginTypeKey)
                        UserDefaults.standard.synchronize()
                        self?.loginSuccess(dismiss: true)

                    }
                }
                
            }).disposed(by: _disposeBag)
            vc.modalPresentationStyle = .fullScreen
            let nav = UINavigationController.init(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
//            self.present(nav, animated: false)
            self.present(nav, animated: false) {
                self.selectedIndex = 0
                CallingManager.calculateCount()
                self.mineNavigationController?.popToRootViewController(animated: false)
                
            }
        }
        
        
        return;
        
        
        
    }
    
    func loginSuccess(dismiss: Bool = false) {
        let event = EventLoginSucceed()
        JNNotificationCenter.shared.post(event)
        
        IQKeyboardManager.shared.enable = false
        
        if !dismiss {
#if ENABLE_CALL
            CallingManager.manager.checkRTCWhileStarting()
#endif
        }
        
        IMController.shared.getSelfInfo { [self] r in
            guard let r else { return }
            
            let p = JsonTool.toJson(fromObject: r)
            UserDefaults.standard.set(p, forKey: signupuserKey)
            UserDefaults.standard.synchronize()
            conversationViewController.refreshUserInfo(userInfo: r)
            
            if r.faceURL == nil || r.faceURL == "" {
                userFirstChooseAvatar()
             
            }
            
            updateLanguage(uid: r.userID)
            initWallet(uid: r.userID,nickName: r.nickname ?? "")
            loadUserCertificationLevel(uid:r.userID)
            //            checkAppVersion(uid:r.userID)
            pushBindAlias(true)
            ProgressHUD.dismiss()
            UserDefaults.standard.set("0", forKey: "blogVersion\(Open_im_sdkGetLoginUserID())")
            if dismiss {
                self.dismiss(animated: true) {
#if ENABLE_CALL
            CallingManager.manager.checkRTCWhileStarting()
#endif
                }
            }
        }
    }
    
    func pushBindAlias(_ bind: Bool = true) {
        if let userID = AccountViewModel.userID {
            bind ? GeTuiSdk.bindAlias(userID, andSequenceNum: "im") : GeTuiSdk.unbindAlias(userID, andSequenceNum: "im", andIsSelf: true)
        }
    }
}

extension MainTabViewController {
    //初始化钱包
    func initWallet(uid: String,nickName:String){
        BoBRealNameModel.InitWalletRequest(userId: uid,nickName: nickName){ errCode, errMsg in
        }
    }
    //
    func loadUserCertificationLevel(uid: String){
        AccountViewModel.queryUserWalletInfo(userId: uid,
                                             valueHandler: { [weak self] (data :MineWalletMoneyData) in
            IMController.shared.isSetPayPassWord = data.anQuan ?? false
            IMController.shared.certificationLevel = data.certificationLevel ?? 0
        }, completionHandler: {(errCode, errMsg) in
        })
    }
    //检查更新
    func checkAppVersion(uid: String){
        YFMineNetViewModel.checkAppVersion(uid: uid) { data in
            let appVersion =  UserDefaults.standard.string(forKey: "AppVersion") ?? Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
            let newVersion = data["iosVersion"] as? String
            if appVersion != newVersion{
                if data["forceUpdate"] as! Int == 1{
                    //强制升级
                    UserDefaults.standard.removeObject(forKey: "AppVersion")
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [self] in
//                        guard let rootViewController = AppDelegate.shared.window?.rootViewController else { return }
//                        rootViewController.presentNewAlert(title: data["versionDescribe"] as? String, confirmTitle: "立即更新") {
//                            if let url = URL(string: data["apkUrl"] as! String) {
//                                UIApplication.shared.open(url)
//                            }
//                        }
//                    }
                }else{
                    //普通升级
                    UserDefaults.standard.set(newVersion, forKey: "AppVersion")
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [self] in
//                        
//                        guard let rootViewController = AppDelegate.shared.window?.rootViewController else { return }
//                        rootViewController.presentNewAlert(title: data["versionDescribe"] as? String, confirmTitle: "立即更新", cancelTitle: "稍后更新") {
//                            if let url = URL(string: data["apkUrl"] as! String) {
//                                UIApplication.shared.open(url)
//                            }
//                        }
//                    }
                }
            }
        }
    }
    
    // MARK: - 张亚飞打的标记 更新语言
    
    func updateLanguage(uid: String) {
        
        let userDefaults = UserDefaults.standard
        
        let currentLanuage = userDefaults.string(forKey: "blogLanguage\(uid)")
        if currentLanuage != nil {
            YFMineNetViewModel.updateLanguage(uid: uid)
        }  else {
            
//            if String.getCurrentLanguageFirst() != userDefaults.string(forKey: "blogLanguage\(uid)") {
                YFMineNetViewModel.addUserLanguage(uid: uid)
//            }
        }

        
        
    }
    
    func  userFirstChooseAvatar() {
        AccountViewModel.queryUserInfo(userIDList: [IMController.shared.uid],
                                       valueHandler: { [weak self] (users: [QueryUserInfo]) in
            guard let user: QueryUserInfo = users.first else { return }
            
            if user.faceURL == nil || user.faceURL == "" {
                self?.toChooseUserAvatar()
            }
        }, completionHandler: {(errCode, errMsg) in
            
        })
    }
    
    
    func toChooseUserAvatar() {
        let r =  YFChooseUserAvatarCardView()
        _YFChooseUserAvatarCardView = YFChooseUserAvatarCardView()
        view.addSubview(r)
        r.snp.makeConstraints { make in
            make.top.trailing.leading.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        r.bottomShow(show: true)
    }
}


extension MainTabViewController: UITabBarControllerDelegate {
    
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {

        let currentTabBarItemTag = tabBarController.selectedIndex
        
        if currentTabBarItemTag == lastTabBarItemTag {
            let currentTime = Date()
            if let lastSelectedTime = lastTabBarItemSelectedTime,
               currentTime.timeIntervalSince(lastSelectedTime) < 0.3 {
                conversationViewController.scrollToUnreadItem()
            }
        }
        
        lastTabBarItemTag = currentTabBarItemTag
        lastTabBarItemSelectedTime = Date()
        
        if let nav = viewController as? UINavigationController, nav.topViewController is ChatListViewController {
            conversationViewController.tapTab = true
        }
        return true

    }
}

func getTabBarHeight() -> CGFloat {
    if let tabBarController = UIApplication.shared.keyWindow?.rootViewController as? UITabBarController {
        return tabBarController.tabBar.frame.size.height
    }
    return 0.0
}


