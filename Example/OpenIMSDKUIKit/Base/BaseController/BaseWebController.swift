//
//  BaseWebController.swift
//  MyCloudMusic
//
//  Created by mac on 2024/4/28.
//

import UIKit
import WebKit
import TangramKit

class BaseWebController: BaseTitleController {
    var uri: String?
    var content: String?
    
    override func initViews() {
        super.initViews()
        initRelativeLayoutSafeArea()
        
        //设置右侧按钮
        addRightImageButton(R.image.close()!.withTintColor())
        container.addSubview(webView)
        
        container.addSubview(progressView)
    }
    
    override func rightBtnClick(_ sender: QMUIButton) {
        if webView.canGoBack {
            webView.goBack()
            return
        }
        back()
    }

    
    override func initDatum() {
        super.initDatum()
        
        if SuperStringUtil.isNotBlank(uri) {
            let request = URLRequest(url: URL(string: uri!)!)
            webView.load(request)
        } else {
            var buffer = String(BaseWebController.CONTENT_WRAPPER_START)
            
            //添加内容
            buffer.append(content!)
            
            buffer.append(BaseWebController.CONTENT_WRAPPER_END)
            
            //加载字符串
            webView.loadHTMLString(buffer, baseURL: URL(string: BaseWebController.WEBVIEW_BASE_URL))
        }
    }
   
    override func initListeners() {
        super.initListeners()
        
        if SuperStringUtil.isBlank(title) {
            
            webView.addObserver(self, forKeyPath: "title", options: .new, context: nil)
            
        }
        
        //监听加载进度
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
    }
    
    //KVO  监听回调
    override  func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let _ = object as? WKWebView {
            if keyPath == "title"{
                //标题
                self.title = webView.title
            }else if keyPath == "estimatedProgress"{
                //进度
                            
                //0~1
                let progress = change?[NSKeyValueChangeKey.newKey] as? Float  ?? 0
                progressView.progress = progress
                
                if progress < 1 {
                    progressView.show()
                    
                    //完全不透明
                    progressView.alpha = 1
                } else {
                    UIView.animate(withDuration: 0.35, delay: 0.15) {
                        self.progressView.alpha = 0
                    } completion: { finished in
                        if finished {
                            self.progressView.hide()
                            self.progressView.progress = 0
                            self.progressView.alpha = 1
                        }
                    }

                }
            }

        }
    }
    
    
    /// 获取配置
    static func defaultConfiguration() -> WKWebViewConfiguration {
        let r = WKWebViewConfiguration()
        if #available(iOS 10.0, *) {
            r.mediaTypesRequiringUserActionForPlayback = .all
        }else {
            r.mediaPlaybackRequiresUserAction = false
        }
        return r
    }
    
    lazy var webView: WKWebView = {
        let r = WKWebView(frame: CGRect.zero, configuration: BaseWebController.defaultConfiguration())
        r.tg_width.equal(.fill)
        r.tg_height.equal(.fill)
        return r
    }()
    
    lazy var progressView: UIProgressView = {
        let r = UIProgressView()
        r.tg_width.equal(.fill)
        r.tg_height.equal(1)
        r.progressTintColor = .colorPrimary
        return r
    }()
}

extension BaseWebController {
    
    static let CONTENT_WRAPPER_START = "<!DOCTYPE html><html><head><title></title><meta name=\"viewport\" content=\"width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no\"><style type=\"text/css\"> body{font-family: Helvetica Neue,Helvetica,PingFang SC,Hiragino Sans GB,Microsoft YaHei,Arial,sans-serif;word-wrap: break-word;word-break: normal;} h2{text-align: center;} img {max-width: 100%;} pre{word-wrap: break-word!important;overflow: auto;}</style></head><body>"
    static let CONTENT_WRAPPER_END = "</body></html>"
    static let WEBVIEW_BASE_URL = "http://ixuea.com"
    
    
    static func start(_ controller:UINavigationController,title:String?=nil,uri:String?=nil,content:String?=nil) {
        let target = BaseWebController()
//        target.title = title
        target.uri = uri
        target.content = content
        controller.pushViewController(target, animated: true)
    }
    
}
