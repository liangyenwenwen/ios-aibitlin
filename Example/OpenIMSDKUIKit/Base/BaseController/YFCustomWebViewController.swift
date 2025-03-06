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
        addRightTextButton("调用h5方法")
        webView.uiDelegate = self
        container.addSubview(webView)
        bridge = WebViewJavascriptBridge(forWebView: webView)
        // 注册 Swift 方法供 H5 调用
        bridge.registerHandler( "callSwiftFunction") { parameters, callback in
            if let data = parameters as? String {
                print("Received data from H5: \(data)")
                // 给 H5 一个响应
                SuperToast.show(title: "h5调用swift，返回给h5 111111")
                callback?("111111")
            }
        }
        if loadUrl!.hasPrefix("www."){
            loadUrl = "http://" + loadUrl!
        }
        
        //显示网址内容
        //创建一个Request
        let request = URLRequest(url: URL(string: loadUrl)!)
        //请求
        webView.load(request)
        // 加载 HTML 文件
//        if let htmlPath = Bundle.main.path(forResource: "homeIndex", ofType: "html") {
//            let url = URL(fileURLWithPath: htmlPath)
//            let request = URLRequest(url: url)
//            webView.load(request)
//        }
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
        bridge.callHandler( "callH5Method", data: message) { response in
            var str = "没有返回任何数据"
            if let response = response as? String {
                print("Received response from H5: \(response)")
                str = "并返回" + response
            }
            SuperToast.show(title: "swift调用h5，" + str)
        }
    }
}
