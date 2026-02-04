//
//  YFAibitlinAgreementAlert.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/11/26.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Foundation
import TangramKit
import BSText
import UIKit
import WebKit
import WKWebViewJavascriptBridge
import ProgressHUD
import GTSDK

class TouristAlert2: TGRelativeLayout,WKNavigationDelegate,WKUIDelegate{
    private var useType: MyStyle = .useTourist
    private var webView: WKWebView!
    private var bridge: WKWebViewJavascriptBridge!

    var agreementBlock:(()->Void)?
    var currentVC: UIViewController?
    init() {
        super.init(frame: CGRect.zero)
        initViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initViews()  {
        corner(MEDDLE_RADIUS)
        tg_left.equal(28)
        tg_right.equal(28)
        tg_height.equal(.wrap)
        tg_space = 40
        tg_gravity = .horz.center
        tg_padding = UIEdgeInsets(top: 0, left: PADDING_OUTER, bottom: 0, right: PADDING_OUTER)
        backgroundColor = .colorBackgroundAPP
        
        // 创建配置（可自定义偏好设置）
        let webConfig = WKWebViewConfiguration()
        // 允许 JS 交互（核心！网页和原生通信必须开）
        webConfig.preferences.javaScriptEnabled = true
        webConfig.preferences.javaScriptCanOpenWindowsAutomatically = false
        // 禁用内建的缩放手势
        webConfig.allowsInlineMediaPlayback = true
        
        // 初始化 WKWebView
        webView = WKWebView(frame: CGRect.zero, configuration: SuperWebController.defaultConfiguration())
        //webView = WKWebView(frame: self.bounds, configuration: webConfig)
        self.addSubview(webView)

        // 设置代理（监听加载状态、跳转等）
        webView.navigationDelegate = self
        // 允许上下拉回弹
        webView.scrollView.bounces = false
        // 添加到当前视图
        //self.addSubview(webView)
        // 方案1：原生代码禁用滚动（推荐）
        webView.scrollView.isScrollEnabled = false
        // 可选：同时禁用缩放
        webView.scrollView.maximumZoomScale = 1.0
        webView.scrollView.minimumZoomScale = 1.0
        // 禁用缩放回弹
        webView.scrollView.bouncesZoom = false
        
        // 自动布局（适配屏幕旋转/尺寸变化）
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: self.topAnchor),
            webView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
//        if let url = URL(string: "https://www.baidu.com") {
//                    let request = URLRequest(url: url)
//                    webView.load(request)
//                }
        
        // 假设你已经有了一个relativeLayout实例
        addConstraint(NSLayoutConstraint(item: webView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: webView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: webView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: webView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0))
        
        
        // 初始化桥接（关联WKWebView）
        bridge = WKWebViewJavascriptBridge(webView: webView)
        webView.uiDelegate = self
        webView.navigationDelegate = self // 重新设置
        
        // 文件夹名：WebResources，index.html 在其中
        guard let webFolderURL = Bundle.main.url(forResource: "WebResources", withExtension: nil) else {
            SuperToast.show(title: "文件夹不存在".localized())
            return
        }
        let htmlURL = webFolderURL.appendingPathComponent("index.html")
        webView.loadFileURL(htmlURL, allowingReadAccessTo: webFolderURL)
        
        
        print("===确认 WebView 已经挂载到 TGRelativeLayout")
        print(webView.superview)
        setupBridge()
        
        //addSubview(bt1)
    }
    
            
    lazy var bt1 :UIButton = {
        let testButton = UIButton(type: .system)
        testButton.setTitle("Swift调用JS方法", for: .normal)
        testButton.frame = CGRect(x: 20, y: safeAreaInsets.top + 20, width: bounds.width - 100, height: 44)
        testButton.addTarget(self, action: #selector(callJSFunction), for: .touchUpInside)
        bringSubviewToFront(testButton)
        return testButton
    }()
    
    // MARK: - 初始化WKWebViewJavascriptBridge
    private func setupBridge() {

        // 注册供JS调用的Swift方法
        // 方法1：showAlert（无返回值给JS）
        bridge.register(handlerName:"showAlert") { [weak self] data, responseCallback in
            print("==================showAlert")
            guard let self = self else { return }
            // 无返回值时，responseCallback传nil即可
            responseCallback?(nil)
        }
        
        //获取验证截图
        bridge.register(handlerName: "getCaptcha") {[weak self] parameters, callback in
            guard let self = self else { return }
            getVerificationCode()
        }
        
        //登录
        bridge.register(handlerName: "login") {[weak self] data, callback in
            guard let self = self else { return }
            if data != nil{
                let x = (data?["param"] ?? -1) as! Int
                if( x > -1 ){
                    ProgressHUD.animate()
                    let tabController = UIApplication.shared.keyWindow?.rootViewController as? MainTabViewController
                    AccountViewModel.registerAccount(phone: "", areaCode: "", verificationCode: x.description, password: "", faceURL: "", nickName: "", email: "", registerType: 3){ [weak self] errCode, result in
                        ProgressHUD.dismiss()
                        if errCode == 0 {
                            GKCover.hide()
                            AccountViewModel.loginIM(uid: AccountViewModel.baseUser.userID,
                                                     imToken: AccountViewModel.baseUser.imToken,
                                                     chatToken: AccountViewModel.baseUser.chatToken)
                            { [weak self] _, _ in
                                
                                if let userID = AccountViewModel.userID {
                                    GeTuiSdk.bindAlias(userID, andSequenceNum: "im")
                                }
                                UserDefaults.standard.setValue(self?.useType.rawValue, forKey: loginTypeKey)
                                UserDefaults.standard.synchronize()
                                //AccountViewModel.savePreLoginAccount(self?.useType == .usePhone ? self?.phone : self?.email)
                                AccountViewModel.updateUserInfo(userID: AccountViewModel.userID!) { _, _ in
                                    tabController?.loginSuccess(dismiss: true)
                                }
                            }
                            
                        }else if errCode == 20006 {
                            guard let self = self else { return }
                            getVerificationCode()
                        }else{
                            //SuperToast.show(title: String(errCode).localized())
                            SuperToast.show(title: "网络异常，请稍后再试".localized())
                        }
                    }
                }else{
                    getVerificationCode()
                }
            }
        }
    
    }
    
    // MARK: - Swift调用JS方法
      @objc private func callJSFunction() {
          print("----")
          bridge.call(handlerName: "showMessageFromSwift", data: "Hello JS! 我是来自Swift的消息"){response in
              print(response)
          }

      }
    
    
    // 页面加载完成后回调该方法
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        //getVerificationCode()
    }
    
    func getVerificationCode(){
        print("请求网络滑块验证码")
        /// 请求验证码
        endEditing(true)
        
        let invaitationCode = ""
        
        AccountViewModel.touristCode(phone:"0", areaCode: "0", email: "0", invaitationCode: invaitationCode, useFor: .tourist) { [weak self] errCode, result in
            //guard let sself = self else { return }
            if errCode == 0 {
                var ss = result as? Any as! VerifyCaptcha
                if let json = ss.toJSONString(prettyPrinted: true) {
                    self?.bridge.call(handlerName: "onCaptcha", data: json){response in}
                    //self?.bridge.call(handlerName: "onCaptcha", data: ["data":json]){response in}
                    return
                }else{
                    
                }
            }else if(errCode == 20005){
                GKCover.hide()
                SuperToast.show(title: "频繁获取验证码，请稍后再试".localized())
            }else{
                GKCover.hide()
                SuperToast.show(title: "网络异常，请稍后再试".localized())
            }
        }
        
    }

}
