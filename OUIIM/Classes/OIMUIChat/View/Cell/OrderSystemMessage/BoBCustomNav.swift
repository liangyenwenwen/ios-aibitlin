//
//  BoBCustomNav.swift
//  OUIIM
//
//  Created by mac on 2024/12/23.
//

import Foundation
import OUICore
class BoBCustomNav:UIView {
    var backBlock:(()->Void)!
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }
    
    func setupSubviews()  {
        
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.top.equalTo(kStatusBarHeight)
            make.left.right.equalTo(0)
            make.height.equalTo(44)
        }
        
        contentView.addSubview(backImg)
        contentView.addSubview(titleLabel)
        backImg.snp.makeConstraints { make in
            make.left.equalTo(18)
            make.width.height.equalTo(20)
            make.centerY.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(100)
            make.right.equalTo(-100)
            make.centerY.equalToSuperview()
        }
    }
    @objc func backAction() {
        print("返回")
        self.backBlock()
    }
    lazy var contentView: UIView = {
        let r = UIView()
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
        r.text = "订单通知"
        r.textAlignment = .center
        return r
    }()
}
