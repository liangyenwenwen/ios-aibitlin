//
//  YFChooseUserAvatarCard.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/10/8.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Foundation

class YFChooseUserAvatarCardView: UIView {
    
    var currentIndex: Int = 1
    var bottomHeight = 672
    
    lazy var bottomView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.clipsToBounds =  true
        return v
    }()
    
    lazy var topCameraImg: UIImageView = {
        let r = UIImageView()
        r.image = .init(named: "choose_avater_camera")
        return r
    }()
    
    lazy var changeIconLbl: UILabel = {
        let r = UILabel()
        r.font = .mediumFont(16)
        r.textColor = .init(hexString: "#388CEF")
        r.text = "更换头像"
        return r
    }()
    
    lazy var chooseIconTitleLbl: UILabel = {
        let r = UILabel()
        r.textColor = .init(hexString: "#333333")
        r.font = .mediumFont(16)
        r.text = "选择系统头像"
        return r
    }()
    
    lazy var trueLbl: UILabel = {
        
        let r = UILabel()
        r.textAlignment = .center
        r.text = "保存".localized()
        r.textColor = .white
        r.font = .mediumFont(14)
        r.backgroundColor = .init(hexString: "#388CEF")
        r.corner(23)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(saveAction))
        r.isUserInteractionEnabled = true
        r.addGestureRecognizer(tap)
        
        return r
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .black.withAlphaComponent(0.3)
        
        
        addSubview(bottomView)
        bottomView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(self.snp.bottom)
            make.height.equalTo(672)
        }
        bottomView.layer.cornerRadius = 14
        bottomView.layer.maskedCorners  = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        bottomView.addSubview(topCameraImg)
        topCameraImg.snp.makeConstraints { make in
            make.top.equalTo(70)
            make.width.height.equalTo(120)
            make.centerX.equalToSuperview()
        }
        
        bottomView.addSubview(changeIconLbl)
        changeIconLbl.snp.makeConstraints { make in
            make.top.equalTo(topCameraImg.snp_bottom).offset(20)
            make.height.equalTo(22)
            make.centerX.equalToSuperview()
        }
        
        bottomView.addSubview(chooseIconTitleLbl)
        chooseIconTitleLbl.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(22)
            make.top.equalTo(topCameraImg.snp_bottom).offset(92)
        }
        
        
        
        let  width = (UIScreen.main.bounds.width - 29 * 2 - 6 * 4) / 5
        for index in 0..<10 {
            let systemIconImg = systemIconView()
            bottomView.addSubview(systemIconImg)
            systemIconImg.corner(width / 2)
            systemIconImg.tag = 15000 + index
            systemIconImg.centerImg.corner((width - 8) / 2)
            systemIconImg.layer.borderColor =  index == currentIndex ? UIColor.init(hexString: "#388CEF").cgColor : UIColor.clear.cgColor
            systemIconImg.centerImg.image = .init(named: "system_avatar_\(index)")
            
            let top = 344 + (index / 5) * 80
            let left = 29 + Int(index % 5) * Int(width + 6)
            
            systemIconImg.snp.makeConstraints { make in
                make.top.equalTo(top)
                make.left.equalTo(left)
                make.width.equalTo(width)
                make.height.equalTo(width)
            }
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(imageChanged(sender:)))
            systemIconImg.isUserInteractionEnabled = true
            systemIconImg.addGestureRecognizer(tap)
//            systemIconImg.snp.makeConstraints { make in
//                make.top.equalTo(top)
//                make.left.equalTo(left)
//            }
        }
        
        
        bottomView.addSubview(trueLbl)
        trueLbl.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.left.equalTo(24)
            make.right.equalTo(-24)
            make.height.equalTo(46)
            make.bottom.equalToSuperview().offset(-36)
        }
        
        
        
    }
    
    
    @objc func imageChanged(sender :UITapGestureRecognizer) {
        let senderview = sender.view as!  systemIconView
        
        let senderTag = senderview.tag
        currentIndex = senderTag - 15000
        for index in 0...9 {
            
            let view = viewWithTag(15000 + index)  as!  systemIconView
            view.layer.borderColor =  index == currentIndex ? UIColor.init(hexString: "#388CEF").cgColor : UIColor.clear.cgColor
        }
    }
    
    @objc func saveAction() {
        print("保存")
    }
    
    
    //点击bottom区域外 消失
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        let view = bottomView
        let point = touch.location(in: self)
        let tPoint = view.convert(point, from: self)
        if view.point(inside: tPoint, with: event) {return}
        bottomShow(show: false)
    }
    
    
    func bottomShow(show:Bool, _ duration: CGFloat = 0.3) {
        
        self.layoutIfNeeded()
        UIView.animate(withDuration: duration) {
            
            self.bottomView.snp.updateConstraints { make in
                make.top.equalTo(self.snp.bottom).offset( show ? -self.bottomHeight : 0)
            }
            self.backgroundColor = .black.withAlphaComponent(show ? 0.3 : 0)
            self.layoutIfNeeded()
        } completion: { [self] _ in
            if !show  {
                self.backgroundColor = .black.withAlphaComponent(show ? 0.3 : 0)
                self.removeFromSuperview()
            }
        }

    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    
    
    
    class systemIconView: UIView {
        
        lazy var centerImg: UIImageView = {
            let r = UIImageView()
            r.clipsToBounds = true
            r.image = .init(named: "DefaultAvatar")
            return r
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            addSubview(centerImg)
            clipsToBounds = true
            layer.borderWidth = 2
            centerImg.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(4)
                make.left.equalToSuperview().offset(4)
                make.right.equalToSuperview().offset(-4)
                make.bottom.equalToSuperview().offset(-4)
            }
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        
    }
    
    
}
