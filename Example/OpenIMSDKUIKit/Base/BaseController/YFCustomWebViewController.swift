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
    
    var h5DetailInfo:h5Model?

    override func initViews() {
        super.initViews()
        initRelativeLayoutSafeArea()
        title = "JS交互测试"
        addRightTextButton("调用h5方法")
        container.addSubview(webView)
        bridge = WKWebViewJavascriptBridge(webView: webView)
        webView.uiDelegate = self
        // 注册 Swift 方法供 H5 调用
        bridge.register(handlerName: "testiOSCallback") { parameters, callback in
            if let data = parameters as? String {
                print("Received data from H5: \(data)")
                // 给 H5 一个响应
                SuperToast.show(title: "h5调用swift，返回给h5 111111")
                callback?("111111")
            }
        }
        bridge.register(handlerName: "refreshWebView") { parameters, callback in
            let request = URLRequest(url: URL(string: "http://www.baidu.com")!)
                   //请求
            self.webView.load(request)
        }
        //显示网址内容
        //创建一个Request
//        let request = URLRequest(url: URL(string: loadUrl)!)
//        //请求
//        webView.load(request)
        // 加载 HTML 文件
//        if let htmlPath = Bundle.main.path(forResource: "error", ofType: "html") {
//            let url = URL(fileURLWithPath: htmlPath)
//            let request = URLRequest(url: url)
//            webView.load(request)
//        }
        if loadUrl?.length ?? 0 > 0{
            if ((loadUrl?.hasPrefix("www.")) != nil){
                loadUrl = "http://" + (loadUrl ?? "")
            }
            let request = URLRequest(url: URL(string: loadUrl)!)
            webView.load(request)
        }else{
            checkH5()
        }
        
    }
    func registerAllFunc(){
        //h5获取token
        bridge.register(handlerName: "getToken") { parameters, callback in
            callback?(IMController.shared.tokenABC)
        }
        //h5调用扫一扫
        bridge.register(handlerName: "getScanCode") { parameters, callback in
            let vc = ScanViewController()
            vc.scanDidComplete = { [weak self] (result: String) in
                ProgressHUD.dismiss()
                callback?(result)
                self?.navigationController?.popViewController(animated: true)
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
        //h5调用保存图片
        bridge.register(handlerName: "saveImage") { image, callback in
            self.saveImage(image: image as! UIImage)
        }
        //h5获取群成员
        bridge.register(handlerName: "getGroupMember") { parameters, callback in
            
            IMController.shared.getGroupMemberList(groupId: parameters?["groupID"] as! String, filter: .all, offset: 0, count: 100000) { ms in
                let encoder = JSONEncoder()
                do  {
                    let jsondata = try encoder.encode(ms)
                    if let jsonString = String(data: jsondata, encoding: .utf8) {
                        print(jsonString)
                        callback?(jsonString)
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
        
    }
    @objc func saveImage(image:UIImage) {
        let status = PHPhotoLibrary.authorizationStatus()
        if (status == .authorized) {
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(image:didFinishSavingWithError:contextInfo:)), nil)
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
                    UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(image:didFinishSavingWithError:contextInfo:)), nil)
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
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: any Error) {
        print("网页加载失败\(error.localizedDescription)")
        
    }
    // 处理临时导航失败
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
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
                    self.checkWebView(data: jsonString.base64Encoded)
                }
            } catch {
                print(error.localizedDescription)
            }
        }).disposed(by: _disposeBag)
    }
    func checkWebView(data:String?){
        YFMineNetViewModel.checkH5(paramters: ["data":data as Any]) { [weak self] data in
            ProgressHUD.dismiss()
            self?.h5DetailInfo = data
            if !SuperStringUtil.isUrl(data.data?.info?.url, showTip: false) {
                let key = (data.data?.info?.pwd ?? "") + "0000000000"
                let ivs = "0000000000000000"
                if let de = try? AESEncyptUtil.decrypt_AES_CBC(decryptText: data.data?.info?.url ?? "", key: key, ivs: ivs){
                    //解析成功
                    if de.hasPrefix("www."){
                        self?.loadUrl = "http://" + de
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
                            if de1.hasPrefix("www."){
                                self?.loadUrl = "http://" + de1
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
                if ((data.data?.info?.url?.hasPrefix("www.")) != nil){
                    self?.loadUrl = "http://" + (data.data?.info?.url ?? "")
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
        if h5DetailInfo?.data?.info?.auto == 0 && (h5DetailInfo?.data?.extend?.app?.permission?.count ?? 0 > 0){
            //需要弹出授权框
            
        }
        
    }
    /// 拦截点击返回按钮
    override func leftBtnClick(_ sender: QMUIButton) {
        if webView.canGoBack {
            //如果浏览器能返回上一页，就直接返回上一页
            webView.goBack()
            return
        }
        
        super.leftBtnClick(sender)
    }
    override func rightBtnClick(_ sender: QMUIButton) {
//        // 获取默认的网站数据存储实例
//            let dataStore = WKWebsiteDataStore.default()
//            // 获取所有类型的网站数据
//            let dataTypes = WKWebsiteDataStore.allWebsiteDataTypes()
//            // 从过去的某个时间点开始，这里设置为遥远的过去，意味着清除所有缓存数据
//            let date = Date.distantPast
//            // 异步删除指定类型和时间范围内的网站数据
//            dataStore.removeData(ofTypes: dataTypes, modifiedSince: date) {
//                print("WKWebView 缓存已清空")
//                let request = URLRequest(url: URL(string: self.loadUrl)!)
//                self.webView.load(request)
//            }
        callH5Method()
    }
    private func callH5Method() {
        let message = "Hello from Swift!"
        bridge.call(handlerName: "testJavascriptHandler", data: message){response in
            var str = "没有返回任何数据"
            if let response = response as? String {
                print("Received response from H5: \(response)")
                str = "并返回" + response
            }
            SuperToast.show(title: "swift调用h5，" + str)
        }
    }
}
