//
//  AdvertisingLaunchViewController.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/12/30.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Foundation
import OUICore

class AdvertisingLaunchViewController: UIViewController {
    // 定时器，用于控制广告展示时长并自动跳转
    private var timer: DispatchSourceTimer?
    // 广告展示时长，单位为秒，可根据实际需求调整
    var adDuration = 6

    override func viewDidLoad() {
        super.viewDidLoad()
        adImageView.frame = view.bounds
        view.addSubview(adImageView)
        view.addSubview(closeBtn)
        closeBtn.snp_makeConstraints { make in
            make.right.equalTo(-16)
            make.top.equalTo(kStatusBarHeight+10)
            make.width.equalTo(100)
            make.height.equalTo(26)
        }
        loadCachedOrDownloadAdImage()
    }
    lazy var adImageView: UIImageView = {
        let r = UIImageView()
        r.contentMode = .scaleAspectFit
        return r
    }()
    lazy var closeBtn: UIButton = {
        let r = UIButton()
        r.setTitleColor(.black333, for: .normal)
        r.backgroundColor = .black999
        r.titleLabel?.font = .regularFont(14)
        r.setTitle("5s" + "自动跳过", for: .normal)
        r.corner(13)
        r.rx.tap.subscribe(onNext: {[weak self] in
            self?.stopTimer()
            self?.jumpToMainPage()
        }).disposed(by: rx.disposeBag)
        return r
    }()
    func loadCachedOrDownloadAdImage() {
        let showType = Int(UserDefaults.standard.string(forKey: "showOpenScreenPage") ?? "1")
        let cachedImage = SDImageCache.shared.imageFromDiskCache(forKey: "cached_ad_image")
        if cachedImage != nil && showType == 2{
            // 如果本地缓存中有图片，直接显示缓存图片
            adImageView.image = cachedImage
            startTimer()
        }else{
            jumpToMainPage()
        }
    }
    func startTimer() {
        // 创建一个基于全局并发队列的定时器源
        timer = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
        // 设置定时器触发间隔为1秒
        timer?.schedule(deadline:.now(), repeating:.seconds(1))
        // 设置定时器触发时执行的闭包
        timer?.setEventHandler {[weak self] in
            DispatchQueue.main.async {
                self?.adDuration = (self?.adDuration ?? 0)-1
                self?.closeBtn.setTitle(String(self?.adDuration ?? 0) + "s" + "自动跳过", for: .normal)
                if self?.adDuration == 0{
                    self?.stopTimer()
                    self?.jumpToMainPage()
                }
            }
        }
        // 启动定时器
        timer?.resume()
    }
    func stopTimer() {
        if timer != nil{
            timer?.cancel()
            timer = nil
        }
    }

    @objc func jumpToMainPage() {
        // 这里简单地创建一个新的视图控制器作为主页面示例，实际中替换为真实的主页面逻辑
        let mainViewController = MainTabViewController()
        mainViewController.view.backgroundColor = .white
        // 执行视图切换，使用UIWindow的根视图控制器进行替换，这里假设应用只有一个窗口
        if let window = UIApplication.shared.windows.first {
            window.rootViewController = mainViewController
            window.makeKeyAndVisible()
        }
    }
}
