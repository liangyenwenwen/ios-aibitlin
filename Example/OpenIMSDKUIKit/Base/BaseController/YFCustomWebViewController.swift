//
//  YFCustomWebViewController.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2025/2/27.
//  Copyright © 2025 rentsoft. All rights reserved.
//

import UIKit
import WebKit
import WebViewJavascriptBridge

class YFCustomWebViewController: BaseTitleController, WKUIDelegate {
    lazy var webView: WKWebView = {
        let r = WKWebView(frame: CGRect.zero, configuration: SuperWebController.defaultConfiguration())
        r.tg_width.equal(.fill)
        r.tg_height.equal(.fill)
        return r
    }()
    private var bridge: WebViewJavascriptBridge!
    var loadUrl:String?

    override func initViews() {
        super.initViews()
        initRelativeLayoutSafeArea()
        title = "JS交互测试"
        addRightTextButton("iOS调用h5方法")
        webView.uiDelegate = self
        container.addSubview(webView)
        bridge = WebViewJavascriptBridge(forWebView: webView)
        // 注册 Swift 方法供 H5 调用
        bridge.registerHandler( "callSwiftFunction") { parameters, callback in
            if let data = parameters as? String {
                print("Received data from H5: \(data)")
                // 给 H5 一个响应
                callback?("111111")
            }
        }
//        if loadUrl!.hasPrefix("www."){
//            loadUrl = "http://" + loadUrl!
//        }
//        
//        //显示网址内容
//        //创建一个Request
//        let request = URLRequest(url: URL(string: loadUrl)!)
//        //请求
//        webView.load(request)
        // 加载 HTML 文件
        if let htmlPath = Bundle.main.path(forResource: "homeIndex", ofType: "html") {
            let url = URL(fileURLWithPath: htmlPath)
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    override func rightBtnClick(_ sender: QMUIButton) {
        callH5Method()
    }
    private func callH5Method() {
        let message = "Hello from Swift!"
        bridge.callHandler( "callH5Method", data: message) { response in
            if let response = response as? String {
                print("Received response from H5: \(response)")
            }
        }
    }
}
