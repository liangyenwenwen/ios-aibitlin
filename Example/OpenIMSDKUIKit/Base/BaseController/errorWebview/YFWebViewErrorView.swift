//
//  YFWebViewErrorView.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2025/4/23.
//  Copyright © 2025 rentsoft. All rights reserved.
//

import Foundation
import OUICore
class YFWebViewErrorView:UIView {
    var backBlock:(()->Void)!
    var refreshBlock:(()->Void)!
    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initViews()  {
        backgroundColor = .colorBackgroundAPP
        addSubview(navView)
        addSubview(refreshImg)
        addSubview(tipLabel)
        navView.snp.makeConstraints { make in
            make.top.left.right.equalTo(0)
            make.height.equalTo(kStatusBarHeight+44)
        }
        refreshImg.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.height.equalTo(40)
            make.centerY.equalTo(self.snp_centerY).offset(-60)
        }
        tipLabel.snp_makeConstraints { make in
            make.top.equalTo(refreshImg.snp_bottom).offset(20)
            make.left.equalTo(16)
            make.right.equalTo(-16)
        }
    }
    lazy var navView: UIView = {
        let r = UIView()
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
        r.text = "加载失败"
        r.textAlignment = .center
        return r
    }()
    
    
    lazy var refreshImg: UIImageView = {
        let r = UIImageView()
        r.image = .init(named: "refresh_blue")
        r.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(refreshAction))
        r.addGestureRecognizer(tap)
        return r
    }()
    lazy var tipLabel: UILabel = {
        let r = UILabel()
        r.textColor = .init(hexString: "#333333")
        r.font =  .regularFont(16)
        r.text = "网络不给力，点击重新加载"
        r.numberOfLines = 0
        r.textAlignment = .center
        return r
    }()
    @objc func refreshAction() {
        self.refreshBlock()
    }
    @objc func backAction() {
        self.backBlock()
    }
    
}
