//
//  YFNotNetTopTipView.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/10/18.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Foundation
//import TangramKit


class YFNotNetTopTipView:UIView {
    
//    var viewClick:(()->Void)!
//    
//    init() {
//        super.init(frame: CGRect.zero, orientation: .horz)
//        initViews()
//     
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        initViews()
//       
//    }
//    
//    func initViews()  {
//        tg_padding = UIEdgeInsets(top: 0, left: PADDING_OUTER, bottom: 0, right: PADDING_OUTER)
//        tg_gravity = .vert.center
//        backgroundColor = .init(hexString: "#ffdfdf")
//        tg_space = 10
//        tg_height.equal(44)
//        tg_width.equal(.fill)
//        hide()
//        
//        addSubview(leftImg)
//        addSubview(titleLbl)
//        
//    }
    
//    lazy var leftImg: UIImageView = {
//        let r = ViewFactoryUtil.defalutImgView(R.image.warnings_icon()!, 24)
//        
//        return r
//    }()
//    
//    lazy var titleLbl: UILabel = {
//        let r = UILabel()
//        r.tg_width.equal(.wrap)
//        r.tg_height.equal(.wrap)
//        r.numberOfLines = 1
//        r.font = .regularFont(14)
//        r.textColor = .init(hexString: "#FD5344")
//        r.text = "请检查网络是否可用！".innerLocalized()
//        return r
//    }()
    var viewClick:(()->Void)!
    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
//        isUserInteractionEnabled = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initViews()  {
        backgroundColor = .init(hexString: "#ffdfdf")
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
        r.text = "请检查网络是否可用！".innerLocalized()
        return r
    }()
    
}
