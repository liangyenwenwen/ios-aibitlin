
import OUICore
import Localize_Swift
import RxSwift
import ProgressHUD
import GTSDK
import AlamofireNetworkActivityLogger
import Bugly
import IQKeyboardManagerSwift

let kGtAppId = "aaG9GXroFD6J5AdyPp59E7"
let kGtAppKey = "z4bVbPVLys7OgGEvIQMDA5"
let kGtAppSecret = "DK6becO4GU6d0YZ8EDQtw2"

#if ENABLE_ORGANIZATION
let bussinessPort = ":50010"
let bussinessRoute = "/organization"
#else
let bussinessPort = ":10008"
//let bussinessRoute = "/chat_enterprise"
let bussinessRoute = ""
#endif

//let adminPort = ":10008"
//let adminRoute = "/chat_enterprise"
//let sdkAPIPort = ":10002"
//let sdkAPIRoute = "/api_enterprise"
//let sdkWSPort = ":10001"
//let sdkWSRoute = "/msg_gateway_enterprise"

let adminPort = ":10008"
let adminRoute = ""
let sdkAPIPort = ":10002"
let sdkAPIRoute = ""
let sdkWSPort = ":10001"
let sdkWSRoute = ""

//let adminPort = ":10008"
//let adminRoute = ":10008/chat_enterprise"
//let sdkAPIPort = ":10002"
//let sdkAPIRoute = ":10002/api_enterprise"
//let sdkWSPort = ":10001"
//let sdkWSRoute = ":10001/msg_gateway_enterprise"

//let defaultAppAddress = "imserver.aibitlin.com/chat"
//let defaultIMAddress = "imserver.aibitlin.com/api"
//let defaultAdminAddress = "imserver.aibitlin.com/msg_gateway"

let defaultAppAddress = "192.168.7.126"
let defaultIMAddress = "192.168.7.126"
let defaultAdminAddress = "192.168.7.126"

//let defaultAppAddress = "192.168.7.109"
//let defaultIMAddress = "192.168.7.109"
//let defaultAdminAddress = "192.168.7.109"

//let defaultAppAddress = "web.rentsoft.cn"
//let defaultIMAddress = "web.rentsoft.cn"
//let defaultAdminAddress = "web.rentsoft.cn"

/// 本地 102
/// let defaultAppAddress = "192.168.7.16"
/// let defaultAppAddress = "192.168.7.102"
//let defaultAppAddress = "192.168.7.102"
//let defaultIMAddress = "192.168.7.102"
//let defaultAdminAddress = "192.168.7.102"

//let defaultAppAddress = "192.168.7.16"
//let defaultIMAddress = "192.168.7.16"
//let defaultAdminAddress = "192.168.7.16"

//let defaultAppAddress = "chat-api.test.bitswith.com"
//let defaultIMAddress = "api.test.bitswith.com"
//let defaultAdminAddress = "msg-gateway.test.bitswith.com"

//BLOG_AUTH = "http://110.42.42.31:18898/";
//APP_AUTH = "http://demo.aibitlin.com:10008/";
//IM_API = "http://demo.aibitlin.com:10002";
//IM_WS = "ws://demo.aibitlin.com:10001";

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate,GeTuiSdkDelegate {
    
    var backgroundTaskIdentifier: UIBackgroundTaskIdentifier?
    var orientation = UIInterfaceOrientationMask.portrait
    var window: UIWindow?
    
    var isChine: Bool = true
    
    
    open class var shared: AppDelegate {
        get {
            return UIApplication.shared.delegate as! AppDelegate
        }
    }
    
   
    private let _disposeBag = DisposeBag();
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        

        IQKeyboardManager.shared.enable = true
        
        NothingToSeeHere.harmlessFunction()
        
        //初始化 自建界面和IM界面的交互
        AccountViewModel.initInteraction()
        
        
        Bugly.start(withAppId: "3cabab095f", developmentDevice: true, config: nil)
        
        /// 设置默认语言
//        if (UserDefaults.standard.object(forKey: "appLanguage") == nil) {
//            UserDefaults.standard.setValue("en", forKey: "appLanguage")
//            UserDefaults.standard.setValue(["en"], forKey: "AppleLanguages")
//        }
        
        
//        print(YFNetworkUtils.getIPAddress())
//        print(YFNetworkUtils.getIPAddress2())
        IMController.shared.publicIP = UserDefaults.standard.string(forKey: "publicIP") ?? "60.177.29.150"
        
        YFNetworkUtils.getPublicIP { ip in
            if let ip = ip{
                IMController.shared.publicIP = ip
                UserDefaults.standard.set(ip, forKey: "publicIP")
            }
            
        }
        
        
        
        UINavigationBar.appearance().tintColor = .c0C1C33
        UINavigationBar.appearance().isTranslucent = true
        UINavigationBar.appearance().isOpaque = true
        let backImage = UIImage(named: "common_back_icon")
        UISwitch.appearance().onTintColor = .c0089FF
        
        let barAppearance = UINavigationBarAppearance()
        barAppearance.configureWithDefaultBackground()
        barAppearance.setBackIndicatorImage(backImage, transitionMaskImage: backImage)
        UINavigationBar.appearance().standardAppearance = barAppearance
        
        ProgressHUD.animationType = .circleBarSpinFade
        ProgressHUD.colorAnimation = .darkGray
        ProgressHUD.colorBackground = .clear
        ProgressHUD.colorHUD = .clear
        
        
        if #available(iOS 13.0, *) {
            let app = UINavigationBarAppearance()
            app.configureWithOpaqueBackground()
            app.titleTextAttributes = [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18),
                NSAttributedString.Key.foregroundColor: UIColor.c0C1C33,
            ]
            app.backgroundColor = UIColor.white
            app.shadowColor = .clear
            UINavigationBar.appearance().scrollEdgeAppearance = app
            UINavigationBar.appearance().standardAppearance = app
        }
        
        
        
        NetworkActivityLogger.shared.level = .debug
        NetworkActivityLogger.shared.startLogging()

        let language = Localize.currentLanguage()
        Localize.setCurrentLanguage(language)
        
        // 主要配置这里，注意http 与 https、 ws 与 wss之分，IP 用端口， 域名用路由
//        let enableTLS = UserDefaults.standard.object(forKey: useTLSKey) == nil
//        ? true : UserDefaults.standard.bool(forKey: useTLSKey)
//        UserDefaults.standard.setValue(enableTLS, forKey: useTLSKey)
//        
//        let enableDomain = UserDefaults.standard.object(forKey: useDomainKey) == nil
//        ? true : UserDefaults.standard.bool(forKey: useDomainKey)
//        UserDefaults.standard.setValue(enableDomain, forKey: useDomainKey)
        
        let enableTLS = false
        let enableDomain = false
        UserDefaults.standard.setValue(enableTLS, forKey: useTLSKey)
        UserDefaults.standard.setValue(enableDomain, forKey: useDomainKey)
        // -------设置各种base url-------
        
        let httpScheme = enableTLS ? "https://" : "http://"
        let wsScheme = enableTLS  ? "wss://" : "ws://"
        
//        let appSeverAddress = UserDefaults.standard.string(forKey: bussinessSeverAddrKey) ?? httpScheme + defaultAppAddress + (!enableDomain ? bussinessPort: bussinessRoute)
//        let sdkAPIAddr = UserDefaults.standard.string(forKey: sdkAPIAddrKey) ?? httpScheme + defaultIMAddress + (!enableDomain ? sdkAPIPort : sdkAPIRoute)
//        let sdkWSAddr = UserDefaults.standard.string(forKey: sdkWSAddrKey) ?? wsScheme + defaultAdminAddress + (!enableDomain ? sdkWSPort : sdkWSRoute)
        
        let appSeverAddress = httpScheme + defaultAppAddress + (!enableDomain ? bussinessPort: bussinessRoute)
        let sdkAPIAddr = httpScheme + defaultIMAddress + (!enableDomain ? sdkAPIPort : sdkAPIRoute)
        let sdkWSAddr = wsScheme + defaultAdminAddress + (!enableDomain ? sdkWSPort : sdkWSRoute)
        
        // 设取全局配置
        UserDefaults.standard.setValue(httpScheme + defaultAdminAddress + (!enableDomain ? adminPort : adminRoute), forKey: adminSeverAddrKey)
        
        // 设置登录注册等 - AccountViewModel
        UserDefaults.standard.setValue(appSeverAddress, forKey: bussinessSeverAddrKey)
        
        // 设置sdk接口地址
        UserDefaults.standard.setValue(sdkAPIAddr, forKey: sdkAPIAddrKey)
            
        // 设置ws地址
        UserDefaults.standard.setValue(sdkWSAddr, forKey: sdkWSAddrKey)
        UserDefaults.standard.synchronize()
        
        // 初始化SDK
        IMController.shared.setup(sdkAPIAdrr: sdkAPIAddr,
                                  sdkWSAddr: sdkWSAddr) {
            ProgressHUD.banner("accountWarn".localized(), "accountException".localized())
            NotificationCenter.default.post(name: .init("logout"), object: nil)
        }
        
        GeTuiSdk.start(withAppId: kGtAppId, appKey: kGtAppKey, appSecret: kGtAppSecret, delegate: self)
        GeTuiSdk.registerRemoteNotification([.alert, .badge, .sound])
        
        AccountViewModel.getClientConfig()
        
        OIMApi.rotationHandler = { [weak self] o in
            self?.orientation = o
        }
        return true
    }
    
    private func logout() {
        NotificationCenter.default.post(name: .init("logout"), object: nil)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
//        application.applicationIconBadgeNumber = 0
        self.backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(withName: "taskname", expirationHandler: {
            
            if (self.backgroundTaskIdentifier != .invalid) {
                UIApplication.shared.endBackgroundTask(self.backgroundTaskIdentifier!);
                self.backgroundTaskIdentifier = .invalid;
            }
        });
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
//        application.applicationIconBadgeNumber = 0
        UIApplication.shared.endBackgroundTask(self.backgroundTaskIdentifier!);
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
           // 即将收到的
           UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
           // 已经收到的
           UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return orientation
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("did Fail To Register For Remote Notifications With Error: %@", error)
    }
    
    // MARK: - GeTuiSdkDelegate
    /// [ GTSDK回调 ] SDK启动成功返回cid
    func geTuiSdkDidRegisterClient(_ clientId: String) {
        let msg = "[ TestDemo ] \(#function):\(clientId)"
        print(msg)
    }
    
    /// [ GTSDK回调 ] SDK运行状态通知
//    func geTuiSDkDidNotifySdkState(_ aStatus: SdkStatus) {
//    }
    
    /// [ GTSDK回调 ] SDK错误反馈
    func geTuiSdkDidOccurError(_ error: Error) {
        let msg = "[ TestDemo ] \(#function) \(error.localizedDescription)"
        print(msg)
    }
    
    //MARK: - 通知回调
    func getuiSdkGrantAuthorization(_ granted: Bool, error: Error?) {
        let msg = "[ TestDemo ] \(#function) \(granted ? "Granted":"NO Granted")"
        print(msg)
    }
    
    /// [ 系统回调 ] iOS 10及以上  APNs通知将要显示时触发
    @available(iOS 10.0, *)
    func geTuiSdkNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.badge, .sound, .alert])
    }
    
    @available(iOS 10.0, *)
    func geTuiSdkDidReceiveNotification(_ userInfo: [AnyHashable : Any], notificationCenter center: UNUserNotificationCenter?, response: UNNotificationResponse?, fetchCompletionHandler completionHandler: ((UIBackgroundFetchResult) -> Void)? = nil) {
        completionHandler?(.noData)
    }
    
    func pushLocalNotification(_ title: String, _ userInfo:[AnyHashable:Any]) {
        if #available(iOS 10.0, *) {
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = title
            let req = UNNotificationRequest.init(identifier: "id1", content: content, trigger: nil)
            
            UNUserNotificationCenter.current().add(req) { _ in
                print("addNotificationRequest added")
            }
        }
    }
    
    func geTuiSdkDidReceiveSlience(_ userInfo: [AnyHashable : Any], fromGetui: Bool, offLine: Bool, appId: String?, taskId: String?, msgId: String?, fetchCompletionHandler completionHandler: ((UIBackgroundFetchResult) -> Void)? = nil) {
        let msg = "[ TestDemo ] \(#function) fromGetui:\(fromGetui ? "个推消息" : "APNs消息") appId:\(appId ?? "") offLine:\(offLine ? "离线" : "在线") taskId:\(taskId ?? "") msgId:\(msgId ?? "") userInfo:\(userInfo)"
        //本地通知UserInfo参数
        var dic: [AnyHashable : Any] = [:]
        if fromGetui {
            //个推在线透传
            dic = ["_gmid_":"\(String(describing: taskId)):\(String(describing: msgId))"]
        } else {
            //APNs静默通知
            dic = userInfo;
        }
        if fromGetui && !offLine {
            //个推通道+在线，发起本地通知
            pushLocalNotification(userInfo["payload"] as! String, dic)
        }
        print(msg)
    }
    
    @available(iOS 10.0, *)
    func geTuiSdkNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
        // [ 参考代码，开发者注意根据实际需求自行修改 ]
    }
    
    //MARK: - 发送上行消息
    
    /// [ GTSDK回调 ] SDK收到sendMessage消息回调
    func geTuiSdkDidSendMessage(_ messageId: String, result: Int32) {
        let msg = "[ TestDemo ] \(#function) \(String(describing: messageId)), result=\(result)"
        print(msg)
    }
    //MARK: - 别名设置
    func geTuiSdkDidAliasAction(_ action: String, result isSuccess: Bool, sequenceNum aSn: String, error aError: Error?) {
        /*
         参数说明
         isSuccess: YES: 操作成功 NO: 操作失败
         aError.code:
         30001：绑定别名失败，频率过快，两次调用的间隔需大于 5s
         30002：绑定别名失败，参数错误
         30003：绑定别名请求被过滤
         30004：绑定别名失败，未知异常
         30005：绑定别名时，cid 未获取到
         30006：绑定别名时，发生网络错误
         30007：别名无效
         30008：sn 无效 */
        
        var msg = ""
//        if action == kGtResponseBindType {
//            msg = "[ TestDemo ] \(#function) bind alias result sn = \(String(describing: aSn)), error = \(String(describing: aError))"
//        }
//        if action == kGtResponseUnBindType {
//            msg = "[ TestDemo ] \(#function) unbind alias result sn = \(String(describing: aSn)), error = \(String(describing: aError))"
//        }
        print(msg)
    }
    
    
    //MARK: - 标签设置
    func geTuiSdkDidSetTagsAction(_ sequenceNum: String, result isSuccess: Bool, error aError: Error?) {
        /*
         参数说明
         sequenceNum: 请求的序列码
         isSuccess: 操作成功 YES, 操作失败 NO
         aError.code:
         20001：tag 数量过大（单次设置的 tag 数量不超过 100)
         20002：调用次数超限（默认一天只能成功设置一次）
         20003：标签重复
         20004：服务初始化失败
         20005：setTag 异常
         20006：tag 为空
         20007：sn 为空
         20008：离线，还未登陆成功
         20009：该 appid 已经在黑名单列表（请联系技术支持处理）
         20010：已存 tag 数目超限
         20011：tag 内容格式不正确
         */
        let msg = "[ TestDemo ] \(#function)  sequenceNum:\(sequenceNum) isSuccess:\(isSuccess) error: \(String(describing: aError))"
        
        print(msg)
    }
}

