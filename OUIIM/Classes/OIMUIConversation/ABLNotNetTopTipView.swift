//
//  ABLNotNetTopTipView.swift
//  OUIIM
//
//  Created by mac on 2024/10/31.
//

import Foundation

class ABLNotNetTopTipView:UIView {
    
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
        r.font = UIFont(name: "PingFangSC-Regular", size: 14)
        r.textColor = .init(hexString: "#FD5344")
        r.text = "请检查网络是否可用！".localized()
        return r
    }()
    
    
}
