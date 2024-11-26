//
//  BoBUnRealNameTipView.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/11/25.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Foundation
class BoBUnRealNameTipView:UIView {
    var viewClick:(()->Void)!
    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initViews()  {
        backgroundColor = .init(hexString: "#FFDFDF")
        addSubview(leftImg)
        addSubview(titleLbl)
        leftImg.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.centerY.equalTo(self.snp_centerY)
            make.width.height.equalTo(24)
        }
        titleLbl.snp_makeConstraints { make in
            make.left.equalTo(leftImg.snp_right).offset(5)
            make.centerY.equalTo(leftImg)
        }
    }
    
    lazy var leftImg: UIImageView = {
        let r = UIImageView()
        r.image = UIImage(named: "warnings_icon")
        return r
    }()
    
    lazy var titleLbl: UILabel = {
        let r = UILabel()
        r.font =  UIFont(name: "PingFangSC-Regular", size: 14)
        r.textColor = .init(hexString: "#FD5344")
        r.text = "您尚未实名认证，请认证>>".innerLocalized()
        return r
    }()
    
}
