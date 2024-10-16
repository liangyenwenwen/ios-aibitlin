//
//  YFEmptyView.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/10/14.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Foundation

class YFEmptyView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
//        isUserInteractionEnabled = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    lazy var tipImgView: UIImageView = {
        let r = UIImageView()
        r.image = .init(named: "custom_blank_icon")
        return r
    }()
    
    lazy var tipLbl: UILabel = {
        let r = UILabel()
        r.textColor = .init(hexString: "#CCCCCC")
        r.font = .mediumFont(16)
        
        r.text = "空空如也".localized()
        return r
    }()
    
    lazy var centerView: UIView = {
        let r = UIView()
        return r
    }()
    
    
    func initUI() {
        
        backgroundColor = .white
        
        addSubview(centerView)
        
        centerView.addSubview(tipImgView)
        centerView.addSubview(tipLbl)
        
        centerView.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(-100)
            make.left.right.equalToSuperview()
        }
        
        tipImgView.snp.makeConstraints { make in
//            make.top.equalTo(200)
//            make.width.equalTo(120)
//            make.height.equalTo(54)
//            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
            make.width.equalTo(120)
            make.height.equalTo(54)
            make.centerX.equalToSuperview()
        }
        
        tipLbl.snp.makeConstraints { make in
            make.top.equalTo(tipImgView.snp_bottom).offset(20)
            make.centerX.equalToSuperview()
            make.height.equalTo(16)
            make.bottom.equalToSuperview()
        }
        
    }
    
    
    
}
