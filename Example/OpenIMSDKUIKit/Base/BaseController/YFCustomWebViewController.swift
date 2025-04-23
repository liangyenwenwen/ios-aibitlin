//
//  YFCustomWebViewController.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2025/2/27.
//  Copyright © 2025 rentsoft. All rights reserved.
//

import UIKit
import WebKit
import WKWebViewJavascriptBridge
import OUICore
import RxSwift
import OUIIM
import ProgressHUD



class YFCustomWebViewController: UIViewController, WKUIDelegate,WKNavigationDelegate {
    var sendCommonTemplateMessageBlock:(([String : Any]) -> ())?
    private let _disposeBag = DisposeBag()
    private var bridge: WKWebViewJavascriptBridge!
    var loadUrl:String?
    var appid:String?
    var chatUserId:String?
    var chatGroupId:String?
    var h5DetailInfo:h5Model?
    var messageId:String?
    var chatInfo:[String:Any]?
    
    var loadImageAPI:String?
    var imageArray:[UIImage] = []
    var imageUrlArray:[Any] = []
    var isforVideo:Bool = false
    
    var refreshURL:String?
    lazy var errorView:YFWebViewErrorView = {
        let r = YFWebViewErrorView()
        r.isHidden = true
        r.backBlock = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        r.refreshBlock = { [weak self] in
            r.isHidden = true
            if self?.h5DetailInfo == nil{
                self?.checkH5()
            }else{
                if self?.refreshURL == nil{
                    self?.refreshURL = self?.loadUrl
                }
                let request = URLRequest(url: URL(string: self?.refreshURL)!)
                self?.webView.load(request)
                self?.refreshURL = nil
            }
        }
        return r
    }()
    lazy var navView: UIView = {
        let r = UIView()
        r.isHidden = true
        r.backgroundColor = .white
        r.addSubview(backImg)
        r.addSubview(titleLabel)
        backImg.snp.makeConstraints { make in
            make.left.equalTo(18)
            make.width.height.equalTo(20)
            make.bottom.equalTo(r).offset(-12)
        }
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(100)
            make.right.equalTo(-100)
            make.centerY.equalTo(backImg)
        }
        return r
    }()
    lazy var backImg: UIImageView = {
        let r = UIImageView()
        r.image = .init(named: "common_back_icon")
        r.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(backAction))
        r.addGestureRecognizer(tap)
        return r
    }()
    lazy var titleLabel: UILabel = {
        let r = UILabel()
        r.textColor = .init(hexString: "#333333")
        r.font =  UIFont(name: "PingFangSC-Medium", size: 18)
        r.text = ""
        r.textAlignment = .center
        return r
    }()
    lazy var webView: WKWebView = {
        let r = WKWebView(frame: CGRect.zero, configuration: SuperWebController.defaultConfiguration())
        r.navigationDelegate = self
        return r
    }()
    @objc func backAction() {
        if webView.canGoBack {
            //如果浏览器能返回上一页，就直接返回上一页
            webView.goBack()
            return
        }
        self.navigationController?.popViewController(animated: true)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .colorBackgroundAPP
        view.addSubview(webView)
        view.addSubview(navView)
        view.addSubview(errorView)
        webView.snp.makeConstraints { make in
            make.top.left.right.equalTo(0)
            make.bottom.equalTo(-kSafeAreaBottomHeight)
        }
        navView.snp.makeConstraints { make in
//            make.top.equalTo(kStatusBarHeight)
            make.top.left.right.equalTo(0)
            make.height.equalTo(44+kStatusBarHeight)
        }
        errorView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
        bridge = WKWebViewJavascriptBridge(webView: webView)
        webView.uiDelegate = self
        checkH5()
        //注册方法供h5调用
        registerAllFunc()
        webView.addObserver(self, forKeyPath: "title", options: .new, context: nil)
    }
    func registerAllFunc(){
        //关闭h5页面
        bridge.register(handlerName: "closeWebView") { parameters, callback in
            self.navigationController?.popViewController(animated: true)
        }
        //h5获取AppId
        bridge.register(handlerName: "getAppId") { parameters, callback in
            callback?(self.appid)
        }
        //h5获取当前语言
        bridge.register(handlerName: "getLanguage") { parameters, callback in
            callback?(String.getCurrentLanguageFirst())
        }
        //h5获取token
        bridge.register(handlerName: "getToken") { parameters, callback in
            if self.h5DetailInfo?.data?.info?.auto == 0 && (self.h5DetailInfo?.data?.extend?.app?.permission?.count ?? 0 > 0) && YFFileDataUtil.isHaveThisH5Data(.loginAuth,item: self.h5DetailInfo!) == false
            {
                //需要弹出授权框
                let authView = AuthorizedLoginAlertView()
                authView.tg_width.equal(.fill)
                authView.tg_height.equal(351 + kSafeAreaBottomHeight)
                authView.updateContentUI(model: self.h5DetailInfo!)
                authView.authLoginAction = { [weak self] in
                    YFFileDataUtil.saveOneH5ToFile(.loginAuth, item: self!.h5DetailInfo!)
                    callback?(self?.h5DetailInfo?.token)
                }
                authView.cancleAuthLoginAction = {[weak self] in
                    self?.navigationController?.popViewController(animated: true)
                }
                GKCover.cover(from:self.view.window, contentView: authView, style: .translucent, showStyle: .bottom, showAnimStyle: .bottom, hideAnimStyle: .bottom, notClick: true)
            }else{
                callback?(self.h5DetailInfo?.token)
            }
        }
        //h5调用扫一扫
        bridge.register(handlerName: "scan") { parameters, callback in
            let vc = ScanViewController()
            vc.scanDidComplete = { [weak self] (result: String) in
                ProgressHUD.dismiss()
                self?.bridge.call(handlerName: "onScan", data: result){response in
                    
                }
                self?.navigationController?.popViewController(animated: true)
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
        //h5调用发送消息
        
        bridge.register(handlerName: "sendMessage") { parameters, callHandleback in
            let userId = parameters?["userId"] as! String
            let groupId = parameters?["groupId"] as! String
            if self.sendCommonTemplateMessageBlock != nil{
                self.sendCommonTemplateMessageBlock!(parameters!)
            }else{
                IMController.shared.sendCommonTemplateMessage(param: parameters?["msg"] as? [String : Any], to: userId.length > 0 ? userId : groupId, conversationType: userId.length > 0 ? .c2c : .superGroup) { msg in
                    callHandleback?("发送成功")
                } onComplete: { msg in
                    callHandleback?("发送失败")
                }
            }
            
        }
        //h5获取群成员列表
        bridge.register(handlerName: "getGroupMembersInfo") { parameters, callback in
            
            IMController.shared.getGroupMemberList(groupId: parameters?["groupId"] as! String, filter: .all, offset: 0, count: 100000) { [weak self] ms in
                var groupMemberList = []
                for item in ms {
                    groupMemberList.append(["userId":item.userID,"name":item.nickname,"face":item.faceURL])
                }
                self?.bridge.call(handlerName: "onGroupMembersInfo", data: ["code":200,"list":groupMemberList]){response in
                    
                }
            }onFailure: {[weak self] errCode, errMsg in
                self?.bridge.call(handlerName: "onGroupMembersInfo", data: ["code":errCode,"list":[]]){response in
                    
                }
            }
        }
        //h5获取我的群列表
        bridge.register(handlerName: "getGroups") { parameters, callback in
            
            IMController.shared.getJoinedGroupList { [weak self] (groups: [GroupInfo]) in
                let groups: [GroupInfo] = groups
                var groupList = []
                for item in groups {
                    groupList.append(["groupId":item.groupID,"name":item.groupName ?? "","face":"","mCount":item.memberCount])
                }
                self?.bridge.call(handlerName: "onGroups", data: ["code":200,"list":groupList]){response in
                    
                }
            }onFailure: {[weak self] errCode, errMsg in
                self?.bridge.call(handlerName: "onGroups", data: ["code":errCode,"list":[]]){response in
                    
                }
            }
        }
        //h5获取我的好友列表
        bridge.register(handlerName: "getFriendList") { parameters, callback in
            IMController.shared.getFriendList { [weak self] users in
                let userList = users.compactMap({ UserInfo(userID: $0.userID!, nickname: $0.remark?.isEmpty == false ? $0.remark : $0.nickname, faceURL: $0.faceURL) })
                var friendList = []
                for item in userList {
                    friendList.append(["userId":item.userID,"name":item.nickname ?? "","face":item.faceURL])
                }
                self?.bridge.call(handlerName: "onFriendList", data: ["code":200,"list":friendList]){response in
                    
                }
            }onFailure: {[weak self] errCode, errMsg in
                self?.bridge.call(handlerName: "onFriendList", data: ["code":errCode,"list":[]]){response in
                    
                }
            }
        }
        //h5调用保存图片
        bridge.register(handlerName: "saveImage") { parameters, callback in
            self.saveImage(base64String: parameters?["img"] as! String)
        }
        //h5调用分享图片
        bridge.register(handlerName: "shareImage") { parameters, callback in
            let image = self.base64StringToImage(base64String: parameters!["img"] as! String)
            if image != nil {
                let activityViewController = UIActivityViewController(activityItems: [image!], applicationActivities: nil)
                self.present(activityViewController, animated: true)
            }else{
                SuperToast.show(title: "分享失败".localized())
            }
        }
        //h5调用相机或相册上传图片
        bridge.register(handlerName: "photoUpload") {parameters, callback in
            self.loadImageAPI = parameters!["url"] as? String
            var maxCount = parameters!["maxCount"] as? Int ?? 1
            self.isforVideo = parameters!["mediaType"] as? String ?? "image" == "image" ? false : true
            if maxCount > 20{
                maxCount = 20
            }
            self.imageArray.removeAll()
            self.imageUrlArray.removeAll()
            self._photoHelper.setConfigToMultipleSelected(forVideo:self.isforVideo, maxSelectCount: maxCount)
            self._photoHelper.showSelectMetaSheet(byController: self)
//            self._photoHelper.presentPhotoLibrary(byController: self)
        }
        //h5改变客户端消息页面
        bridge.register(handlerName: "saveEx") { [self]parameters, callback in
            let localEx = parameters!["msg"] as? String
            if self.messageId?.length ?? 0 > 0,
               localEx?.length ?? 0 > 0{
                NotificationCenter.default.post(name: Notification.Name("changeMessageLocalEx"), object: nil, userInfo: ["value": localEx!,"messageId":self.messageId ?? ""])

            }
        }
        //h5获取客户端聊天信息
        bridge.register(handlerName: "getCurrentConversationInfo") { [self]parameters, callback in
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: self.chatInfo ?? [], options: [])
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    callback?(jsonString)
                }
            } catch {
                print("JSON serialization failed: \(error)")
            }
        }
        //获取客户端信息
        bridge.register(handlerName: "getUserInfo") {parameters, callback in
            let userInfo = ["nickname":IMController.shared.currentUserRelay.value?.nickname,
                            "faceURL":IMController.shared.currentUserRelay.value?.faceURL,
                            "userID":IMController.shared.currentUserRelay.value?.userID]
            callback?(userInfo)
        }
    }
    private lazy var _photoHelper: PhotoHelper = {
        let v = PhotoHelper()
        v.setConfigToMultipleSelected()
        v.didPhotoSelected = { [weak self] (images: [UIImage], assets: [PHAsset]) in
            guard var photo = images.first else { return }
            self?.imageArray = self!.imageArray + images
            self?.uploadImageNetWork(index: 0)
        }
        
        v.didCameraFinished = { [weak self] (photo: UIImage?, videoPath: URL?) in
            guard let sself = self else { return }
            if var photo {
                self?.imageArray.append(photo)
                self?.uploadImageNetWork(index: 0)
            }
        }
        return v
    }()
    func uploadImageNetWork(index: Int) {
        if index < imageArray.count {
            ProgressHUD.animate()
            let uploadImage = imageArray[index].compress(expectSize: 1500 * 1024)
            let result = FileHelper.shared.saveImage(image: uploadImage)
            if result.isSuccess {
                YFMineNetViewModel.uploadH5ImageFromPath(apiUrl:loadImageAPI ?? "",fileURL:NSURL(fileURLWithPath: result.fullPath) as URL) { [weak self] data in
                    self!.imageUrlArray.append(data)
                    self?.uploadImageNetWork(index: index + 1)
                } completionHandler: {[weak self] errCode, errMsg in
                    self?.uploadImageNetWork(index: index + 1)
                }
            } else {
                uploadImageNetWork(index: index + 1)
            }
        } else {
            print("\n\n\n所有图片上传完成")
            ProgressHUD.dismiss()
            if imageUrlArray.count == 0{
                SuperToast.show(title: "上传失败".localized())
            }else{
                bridge.call(handlerName: "onPhotoUpload", data: imageUrlArray){response in
                
                }
            }
        }
    }
    @objc func saveImage(base64String:String) {
        let status = PHPhotoLibrary.authorizationStatus()
        if (status == .authorized) {
            let image = base64StringToImage(base64String: base64String)
            if image != nil {
                UIImageWriteToSavedPhotosAlbum(image!, self, #selector(self.image(image:didFinishSavingWithError:contextInfo:)), nil)
            }else{
                SuperToast.show(title: "图片保存失败".localized())
            }
        } else if (status == .restricted || status == .denied) {
            let alert = UIAlertController(title: "提示".localized(), message: "请去-> [设置 - 隐私 - 相册] 打开访问开关".localized(), preferredStyle: .alert)
            //cacel 取消也改变值  defalut 必须选择 alert才会消失
            alert.addAction(title: "确定".localized(), style:.cancel)
            alert.show()
        } else if (status == .notDetermined) { // 首次使用
            PHPhotoLibrary.requestAuthorization({ (firstStatus) in
                let isTrue = (firstStatus == .authorized)
                if isTrue {
                    // 用户首次允许
                    let image = self.base64StringToImage(base64String: base64String)
                    if image != nil {
                        UIImageWriteToSavedPhotosAlbum(image!, self, #selector(self.image(image:didFinishSavingWithError:contextInfo:)), nil)
                    }else{
                        SuperToast.show(title: "图片保存失败".localized())
                    }
                } else {
                    // 用户首次拒绝
                }
            })
        }
    }
    @objc func image(image: UIImage, didFinishSavingWithError: NSError?,contextInfo: AnyObject)
    {

        if didFinishSavingWithError != nil {
            print("error!")
            SuperToast.show(title: "图片保存失败".localized())
            return
        }
        print("图片保存成功".localized())
        SuperToast.show(title: "图片保存成功".localized())
    }
    func base64StringToImage(base64String: String) -> UIImage? {
        // 移除Base64字符串中的空白符和可能的URL Scheme（如"data:image/png;base64,")
        let cleanedBase64 = base64String.replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "data:image/png;base64,", with: "")
            .replacingOccurrences(of: "data:image/jpeg;base64,", with: "")
     
        // 将Base64字符串转换为Data
        guard let imageData = Data(base64Encoded: cleanedBase64) else {
            print("Error: Could not create Data from Base64 string")
            return nil
        }
     
        // 使用Data初始化UIImage
        guard let image = UIImage(data: imageData) else {
            print("Error: Could not create UIImage from Data")
            return nil
        }
     
        return image
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: any Error) {
        print("网页加载失败\(error.localizedDescription)")
        if let nsError = error as NSError?, nsError.code == NSURLErrorCancelled {
            // 忽略取消错误
            return
        }
        if let failedURL = webView.url {
            refreshURL = failedURL.absoluteString
        }
        errorView.isHidden = false
        
        
    }
    // 处理临时导航失败
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        if let nsError = error as NSError?, nsError.code == NSURLErrorCancelled {
            // 忽略取消错误
            return
        }
        if loadUrl!.hasPrefix("https://"){
            loadUrl = loadUrl!.replacingOccurrences(of: "https://", with: "http://")
            let request = URLRequest(url: URL(string: loadUrl)!)
            webView.load(request)
        }else{
            //加载失败页
            if let failedURL = webView.url {
                refreshURL = failedURL.absoluteString
            }
            errorView.isHidden = false
        }
        print("Provisional navigation failed with error: \(error.localizedDescription)")
    }
    /// KVO监听回调
    /// - Parameters:
    ///   - keyPath: <#keyPath description#>
    ///   - object: <#object description#>
    ///   - change: <#change description#>
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let _ = object as? WKWebView {
            if keyPath == SuperWebController.TITLE {
                //标题
                self.titleLabel.text = webView.title
            }
        }
    }
    
    func checkH5(){
        IMController.shared.getJoinedGroupList { [weak self] (groups: [GroupInfo]) in
            let groups: [GroupInfo] = groups
            var gidsList = []
            for item in groups {
                gidsList.append((IMController.shared.currentUserRelay.value?.userID ?? "" + item.groupID).md5())
            }
            let param = ["uid":IMController.shared.currentUserRelay.value?.userID,"nickname":IMController.shared.currentUserRelay.value?.nickname,"avatar":IMController.shared.currentUserRelay.value?.faceURL,"url":"","appid":self?.appid,"md5":""]
            do  {
                let jsondata = try JSONSerialization.data(withJSONObject: param, options: .prettyPrinted)
                if let jsonString = String(data: jsondata, encoding: .utf8) {
                    self?.checkWebView(param: ["data":jsonString.base64Encoded as Any,"gids":gidsList])
                }else{
                    self?.webView.isHidden = false
                }
            } catch {
                print(error.localizedDescription)
                self?.webView.isHidden = false
            }
            
        }onFailure: {[weak self] errCode, errMsg in
            self?.webView.isHidden = false
        }
    }
    func checkWebView(param:[String:Any]){
        YFMineNetViewModel.checkH5(paramters: param) { [weak self] data in
            ProgressHUD.dismiss()
            self?.h5DetailInfo = data
            if data.data?.type == 3{
                self?.navView.isHidden = false
                self?.webView.snp_updateConstraints({ make in
                    make.top.equalTo(44+kStatusBarHeight)
                })
            }
            YFFileDataUtil.saveOneH5ToFile(item: data)
            if self?.loadUrl?.length ?? 0 > 0{
                if self?.loadUrl?.hasPrefix("http://") == false && self?.loadUrl?.hasPrefix("https://") == false {
                    self?.loadUrl = "https://" + (self?.loadUrl ?? "")
                }
                self?.loadCheckH5()
                return
            }
            if !SuperStringUtil.isUrl(data.data?.info?.url, showTip: false) {
                let key = (data.data?.info?.pwd ?? "") + "0000000000"
                let ivs = "0000000000000000"
                if let de = try? AESEncyptUtil.decrypt_AES_CBC(decryptText: data.data?.info?.url ?? "", key: key, ivs: ivs){
                    //解析成功
                    if de.hasPrefix("http://") == false && de.hasPrefix("https://") == false {
                        self?.loadUrl = "https://" + de
                    }else{
                        self?.loadUrl = de
                    }
                    self?.loadCheckH5()
                }else{
                   //解析失败输入密码
                    let passWordView = WebViewPwdViewController()
                    passWordView.tg_width.equal(.fill)
                    passWordView.tg_height.equal(210)
                    passWordView.sureBtnClickBlock = { [weak self] passWord in
                        let key1 = passWord + "0000000000"
                        let ivs1 = "0000000000000000"
                        if let de1 = try? AESEncyptUtil.decrypt_AES_CBC(decryptText: data.data?.info?.url ?? "", key: key1, ivs: ivs1){
                            //解析成功
                            if de1.hasPrefix("http://") == false && de1.hasPrefix("https://") == false {
                                self?.loadUrl = "https://" + de1
                            }else{
                                self?.loadUrl = de1
                            }
                            self?.loadCheckH5()
                            passWordView.endEditing(true)
                            GKCover.hide()
                        }else{
                            SuperToast.show(title: "密码错误".localized())
                        }
                    }
                    passWordView.cancleBtnClickBlock = {[weak self] in
                        self?.navigationController?.popViewController(animated: true)
                    }
                    GKCover.cover(from: self?.view.window, contentView: passWordView, style: .translucent, showStyle: .center, showAnimStyle: .bottom, hideAnimStyle: .bottom, notClick: true)
                }
                
            }else{
                if data.data?.info?.url?.hasPrefix("http://") == false && data.data?.info?.url?.hasPrefix("https://") == false {
                    self?.loadUrl = "https://" + (data.data?.info?.url ?? "")
                }else{
                    self?.loadUrl = data.data?.info?.url
                }
                self?.loadCheckH5()
            }
        } completionHandler: {[weak self] errCode, errMsg in
            ProgressHUD.dismiss()
            self?.webView.isHidden = false
            SuperToast.show(title: errMsg?.localized())
        }
    }
    func loadCheckH5(){
        let request = URLRequest(url: URL(string: loadUrl)!)
        webView.load(request)
//        checkAuthLogin()
    }
//    func checkAuthLogin(){
//        if h5DetailInfo?.data?.info?.auto == 0 && (h5DetailInfo?.data?.extend?.app?.permission?.count ?? 0 > 0) && YFFileDataUtil.isHaveThisH5Data(.loginAuth,item: h5DetailInfo!) == false
//        {
//            //需要弹出授权框
//            let authView = AuthorizedLoginAlertView()
//            authView.tg_width.equal(.fill)
//            authView.tg_height.equal(351 + kSafeAreaBottomHeight)
//            authView.updateContentUI(model: h5DetailInfo!)
//            authView.authLoginAction = { [weak self] in
//                YFFileDataUtil.saveOneH5ToFile(.loginAuth, item: self!.h5DetailInfo!)
//            }
//            authView.cancleAuthLoginAction = {[weak self] in
//                self?.navigationController?.popViewController(animated: true)
//            }
//            GKCover.cover(from:view.window, contentView: authView, style: .translucent, showStyle: .bottom, showAnimStyle: .bottom, hideAnimStyle: .bottom, notClick: true)
//        }
//    }   
}
