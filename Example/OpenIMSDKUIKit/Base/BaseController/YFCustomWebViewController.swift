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



class YFCustomWebViewController: BaseTitleController, WKUIDelegate,WKNavigationDelegate {
    lazy var webView: WKWebView = {
        let r = WKWebView(frame: CGRect.zero, configuration: SuperWebController.defaultConfiguration())
        r.navigationDelegate = self
        r.tg_width.equal(.fill)
        r.tg_height.equal(.fill)
        return r
    }()
    private let _disposeBag = DisposeBag()
    private var bridge: WKWebViewJavascriptBridge!
    var loadUrl:String?
    var appid:String?
    var chatUserId:String?
    var chatGroupId:String?
    var h5DetailInfo:h5Model?
    var loadImageAPI:String?
    var messageId:String?
    var chatInfo:[String:Any]?
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        self.navView.hide()
        
    }
    override func initViews() {
        super.initViews()
        initRelativeLayoutSafeArea()
        container.addSubview(webView)
        bridge = WKWebViewJavascriptBridge(webView: webView)
        webView.uiDelegate = self
        // 加载 HTML 文件
//        if let htmlPath = Bundle.main.path(forResource: "error", ofType: "html") {
//            let url = URL(fileURLWithPath: htmlPath)
//            let request = URLRequest(url: url)
//            webView.load(request)
//        }
        checkH5()
        //注册方法供h5调用
        registerAllFunc()
    }
    func registerAllFunc(){
        //刷新
        bridge.register(handlerName: "refreshWebView") { parameters, callback in
            let request = URLRequest(url: URL(string: "http://www.baidu.com")!)
                   //请求
            self.webView.load(request)
        }
        //关闭h5页面
        bridge.register(handlerName: "closeWebView") { parameters, callback in
            self.navigationController?.popViewController(animated: true)
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
            
            IMController.shared.sendCommonTemplateMessage(param: parameters!["msg"] as? [String:Any], to: userId.length > 0 ? userId : groupId, conversationType: userId.length > 0 ? .c2c : .superGroup) { [weak self] msg in
                callHandleback!("发送成功")
            } onComplete: { [weak self] msg in
                callHandleback!("发送失败")
            }
        }
        //h5获取群成员列表
        bridge.register(handlerName: "getGroupMembersInfo") { parameters, callback in
            
            IMController.shared.getGroupMemberList(groupId: parameters?["groupId"] as! String, filter: .all, offset: 0, count: 100000) { [weak self] ms in
                var groupMemberList = []
                for item in ms {
                    groupMemberList.append(["userId":item.userID,"name":item.nickname,"face":item.faceURL])
                }
                self?.bridge.call(handlerName: "onGroupMembersInfo", data: groupMemberList){response in
                    
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
                self?.bridge.call(handlerName: "onGroups", data: groupList){response in
                    
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
                self?.bridge.call(handlerName: "onFriendList", data: friendList){response in
                    
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
            self._photoHelper.setConfigToMultipleSelected(forVideo: false, maxSelectCount: 1)
            self._photoHelper.showSelectMetaSheet(byController: self)
//            self._photoHelper.presentPhotoLibrary(byController: self)
        }
        //h5改变客户端消息页面
        bridge.register(handlerName: "saveEx") { [self]parameters, callback in
            let localEx = parameters!["ex"] as? String
            if self.messageId?.length ?? 0 > 0{
                NotificationCenter.default.post(name: Notification.Name("changeMessageLocalEx"), object: nil, userInfo: ["value": "localEx","messageId":self.messageId ?? ""])

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
    }
    private lazy var _photoHelper: PhotoHelper = {
        let v = PhotoHelper()
        v.setConfigToMultipleSelected()
        v.didPhotoSelected = { [weak self] (images: [UIImage], assets: [PHAsset]) in
            guard var photo = images.first else { return }
            self?.upLoadImage(image: photo)
        }
        
        v.didCameraFinished = { [weak self] (photo: UIImage?, videoPath: URL?) in
            guard let sself = self else { return }
            if var photo {
                self?.upLoadImage(image: photo)
            }
        }
        return v
    }()
    func upLoadImage(image:UIImage) {
        ProgressHUD.animate()
        let uploadImage = image.compress(expectSize: 1500 * 1024)
        let result = FileHelper.shared.saveImage(image: uploadImage)
        
        if result.isSuccess {
            YFMineNetViewModel.uploadImageFromPath(apiUrl:loadImageAPI ?? "",fileURL:NSURL(fileURLWithPath: result.fullPath) as URL) { [weak self] data in
                ProgressHUD.dismiss()
                self?.loadImageAPI = nil
                self?.bridge.call(handlerName: "onPhotoUpload", data: data.url ?? ""){response in
                    
                }
            } completionHandler: { errCode, errMsg in
                ProgressHUD.dismiss()
                SuperToast.show(title: errMsg?.localized())
            }
        } else {
            
            ProgressHUD.dismiss()
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
        
    }
    // 处理临时导航失败
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        if loadUrl!.hasPrefix("https://"){
            loadUrl = loadUrl!.replacingOccurrences(of: "https://", with: "http://")
            let request = URLRequest(url: URL(string: loadUrl)!)
            webView.load(request)
        }else{
            //加载失败页
        }
        print("Provisional navigation failed with error: \(error.localizedDescription)")
    }

    
    func checkH5(){
        IMController.shared.currentUserRelay.subscribe(onNext: { r in
            guard let r else { return }
            let param = ["uid":r.userID,"nickname":r.nickname,"avatar":r.faceURL,"url":"","appid":self.appid,"md5":""]
            do  {
                let jsondata = try JSONSerialization.data(withJSONObject: param, options: .prettyPrinted)
                if let jsonString = String(data: jsondata, encoding: .utf8) {
                    print(jsonString)
                    self.checkWebView(dataStr: jsonString.base64Encoded)
                }
            } catch {
                print(error.localizedDescription)
            }
        }).disposed(by: _disposeBag)
    }
    func checkWebView(dataStr:String?){
        YFMineNetViewModel.checkH5(paramters: ["data":dataStr as Any]) { [weak self] data in
            ProgressHUD.dismiss()
            self?.h5DetailInfo = data
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
        } completionHandler: { errCode, errMsg in
            ProgressHUD.dismiss()
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
    /// 拦截点击返回按钮
    override func leftBtnClick(_ sender: QMUIButton) {
        if webView.canGoBack {
            //如果浏览器能返回上一页，就直接返回上一页
            webView.goBack()
            return
        }
        
        super.leftBtnClick(sender)
    }
}
