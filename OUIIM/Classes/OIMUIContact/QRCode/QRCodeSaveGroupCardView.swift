//
//  QRCodeSaveGroupCardView.swift
//  OUIIM
//
//  Created by mac on 2025/2/19.
//

import Foundation
import OUICore

class QRCodeSaveGroupCardView: UIView{
    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func initViews(){
        addSubview(titleLabel)
        addSubview(codeView)
        codeView.addSubview(codeImgView)
        codeView.addSubview(groupImgView)
        addSubview(groupIDLbl)
        addSubview(appIconImgView)
        titleLabel.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.top.equalTo(20)
            make.right.equalTo(-16)
        }
        codeView.snp.makeConstraints { make in
            make.width.height.equalTo(260)
            make.top.equalTo(titleLabel.snp_bottom).offset(17)
            make.centerX.equalToSuperview()
        }
        codeImgView.snp.makeConstraints { make in
            make.top.left.right.bottom.equalToSuperview().inset(10)
        }
        groupImgView.snp.makeConstraints { make in
            make.width.height.equalTo(56)
            make.center.equalToSuperview()
        }
        groupIDLbl.snp.makeConstraints { make in
            make.top.equalTo(codeView.snp_bottom).offset(24)
            make.height.equalTo(22)
            make.centerX.equalToSuperview()
            make.width.equalTo(260)
        }
        appIconImgView.snp.makeConstraints { make in
            make.top.equalTo(groupIDLbl.snp_bottom).offset(10)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(90)
        }
        
       
    }
    private lazy var titleLabel: UILabel = {
        let r = UILabel()
        r.font = UIFont(name: "PingFangSC-Medium", size: 15)
        r.textColor = .init(hexString: "#333333")
        r.textAlignment = .center
        return r
    }()
    lazy var codeView: UIView = {
        let r = UIView()
        r.clipsToBounds = true
        r.layer.borderWidth = 1
        r.layer.cornerRadius = 8
        let color:UIColor = .init(hexString:"#EAEAEA")!
        r.layer.borderColor = color.cgColor
        return r
    }()
    
    lazy var codeImgView: UIImageView = {
        let r = UIImageView()
        return r
    }()
    
    lazy var groupImgView: UIImageView = {
        let r = UIImageView()
        r.clipsToBounds = true
        r.layer.borderWidth = 3
        r.layer.cornerRadius = 28
        r.layer.borderColor = UIColor.white.cgColor
        r.contentMode = .scaleAspectFill
        return r
    }()
    lazy var groupIDLbl: UILabel = {
        let r = UILabel()
        r.textColor = .init(hexString: "#666666")
        r.font = UIFont(name: "PingFangSC-Regular", size: 13)
        r.textAlignment = .center
        return r
    }()
    lazy var appIconImgView: UIImageView = {
        let r = UIImageView()
        r.image = UIImage(named: "launch_logo_otc")
        return r
    }()
    func bindData(showname: String, codeImg: UIImage?, avater: UIImage?, idString: String?) {
        titleLabel.text = showname
        codeImgView.image = codeImg
        groupImgView.image = avater
        groupIDLbl.text = "groupID".innerLocalized() + "：" + (idString ?? "")
        
        
        layoutIfNeeded()
    }
}
