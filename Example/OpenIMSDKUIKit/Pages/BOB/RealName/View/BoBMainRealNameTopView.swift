//
//  BoBMainRealNameTopView.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/11/20.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Foundation
class BoBMainRealNameTopView: UIView{
//    var realNameInfoModel:RealNameInfoDataModel?
    var realNameType:Int? // 0:初级认证View，1:高级认证View
    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
//        isUserInteractionEnabled = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initViews()  {
        backgroundColor = .init(hexString: "#FBFBFD")
        self.border(.init(hexString: "#F0F0F0"),borderWidth: 1,cornerRadius: 8)
        addSubview(titleLabel)
        addSubview(statusView)
        addSubview(buyContentView)
        addSubview(withdrawalContentView)
        
        
        titleLabel.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.top.equalTo(20)
        }
        statusView.snp_makeConstraints { make in
            make.left.equalTo(titleLabel.snp_right).offset(8)
            make.centerY.equalTo(titleLabel)
            make.height.equalTo(18)
            make.width.equalTo(62)
        }
    }
    lazy var titleLabel: UILabel = {
        let r = UILabel()
        r.font = UIFont(name: "PingFangSC-Semibold", size: 16)
        r.textColor = .black33
        return r
    }()
    lazy var statusView: UIView = {
        let r = UIView()
        r.corner(9)
        r.addSubview(statusIcon)
        r.addSubview(statusLabel)
        statusIcon.snp_makeConstraints { make in
            make.centerY.equalTo(r)
            make.left.equalTo(4)
            make.width.height.equalTo(12)
        }
        statusLabel.snp_makeConstraints { make in
            make.centerY.equalTo(statusIcon)
            make.left.equalTo(statusIcon.snp_right).offset(4)
            make.right.equalTo(-4)
        }
        
        return r
    }()
    lazy var statusIcon: UIImageView = {
        let r = UIImageView()
        return r
    }()
    lazy var statusLabel: UILabel = {
        let r = UILabel()
        r.font = UIFont(name: "PingFangSC-Regular", size: 12)
        r.textColor = .white
        return r
    }()
    lazy var buyContentView: UIView = {
        let r = UIView()
        r.backgroundColor = .init(hexString: "#DFDFDF")
        r.corner(4)
        return r
    }()
    lazy var withdrawalContentView: UIView = {
        let r = UIView()
        r.backgroundColor = .init(hexString: "#DFDFDF")
        r.corner(4)
        return r
    }()
    lazy var tipLabel: UILabel = {
        let r = UILabel()
        r.font = UIFont(name: "PingFangSC-Regular", size: 14)
        r.textColor = .black666
        r.text = "此项需填写："
        return r
    }()
    lazy var subTipLabel: UILabel = {
        let r = UILabel()
        r.font = UIFont(name: "PingFangSC-Regular", size: 14)
        r.textColor = .black666
        r.text = "1.个人信息 2.政府发行的身份证 3.人脸识别"
        return r
    }()
    func getHeadTitleLabel(title:String,backGroundColor:UIColor,textFont:UIFont) -> UILabel{
        let headTitleLabel = UILabel()
        headTitleLabel.text = title
        headTitleLabel.backgroundColor = backGroundColor
        headTitleLabel.textColor = .black333
        headTitleLabel.font = textFont
        headTitleLabel.textAlignment = .center
        return headTitleLabel
    }
    func bindData(model:RealNameInfoDataModel){
        if realNameType == 0{
            titleLabel.text = "初级认证"
            if model.certificationLevel  != 0{
               //已认证
                statusView.backgroundColor = .init(hexString: "#3ACC9B")
                statusIcon.image = UIImage(named: "real_name_authentication_icon")
                statusLabel.text = "已认证"
            }else{
               //未认证
                statusView.backgroundColor = .init(hexString: "#FFA756")
                statusIcon.image = UIImage(named: "real_name_unAuthentication_icon")
                statusLabel.text = "未认证"
            }
            buyContentView.snp_makeConstraints { make in
                make.left.equalTo(16)
                make.top.equalTo(50)
                make.right.equalTo(-16)
                make.height.equalTo(30*(model.cjmmbRealNameAuthenticationPOS.count+1)+1)
            }
            withdrawalContentView.snp_makeConstraints { make in
                make.left.right.equalTo(buyContentView)
                make.top.equalTo(buyContentView.snp_bottom).offset(14)
                make.height.equalTo(30*(model.cjtbRealNameAuthenticationPOS.count+1)+1)
            }
            let buyTitleLabel = getHeadTitleLabel(title: "买卖币",backGroundColor: .init(hexString: "#E7E7E7"),textFont: UIFont(name: "PingFangSC-Regular", size: 15)!)
            buyContentView.addSubview(buyTitleLabel)
            buyTitleLabel.snp_makeConstraints { make in
                make.top.left.equalTo(1)
                make.right.equalTo(-1)
                make.height.equalTo(29)
            }
            for i in 0..<model.cjmmbRealNameAuthenticationPOS.count {
                let data = model.cjmmbRealNameAuthenticationPOS[i]
                let label1 = getHeadTitleLabel(title: data.currency + "限额/日",backGroundColor: .init(hexString: "#F3F3F3"),textFont: UIFont(name: "PingFangSC-Regular", size: 14)!)
                let label2 = getHeadTitleLabel(title:String(data.primaryCertificationBusiness) + " " + data.currency ,backGroundColor: .init(hexString: "#F3F3F3"),textFont: UIFont(name: "PingFangSC-Regular", size: 14)!)
                buyContentView.addSubview(label1)
                buyContentView.addSubview(label2)
                label1.snp_makeConstraints { make in
                    make.left.equalTo(1)
                    make.right.equalTo(buyContentView.snp_centerX).offset(-0.5)
                    make.height.equalTo(29)
                    make.top.equalTo((29+1)*(i+1)+1)
                }
                label2.snp_makeConstraints { make in
                    make.left.equalTo(buyContentView.snp_centerX).offset(0.5)
                    make.right.equalTo(-1)
                    make.height.top.equalTo(label1)
                }
            }
                    
            let withdrawalTitleLabel = getHeadTitleLabel(title: "提币",backGroundColor: .init(hexString: "#E7E7E7"),textFont: UIFont(name: "PingFangSC-Regular", size: 15)!)
            withdrawalContentView.addSubview(withdrawalTitleLabel)
            withdrawalTitleLabel.snp_makeConstraints { make in
                make.top.left.equalTo(1)
                make.right.equalTo(-1)
                make.height.equalTo(29)
            }
            for i in 0..<model.cjtbRealNameAuthenticationPOS.count {
                let data = model.cjtbRealNameAuthenticationPOS[i]
                let label1 = getHeadTitleLabel(title: data.currency + "限额/日",backGroundColor: .init(hexString: "#F3F3F3"),textFont: UIFont(name: "PingFangSC-Regular", size: 14)!)
                let label2 = getHeadTitleLabel(title:String(data.primaryCertificationWithdraw) + " " + data.currency ,backGroundColor: .init(hexString: "#F3F3F3"),textFont: UIFont(name: "PingFangSC-Regular", size: 14)!)
                withdrawalContentView.addSubview(label1)
                withdrawalContentView.addSubview(label2)
                label1.snp_makeConstraints { make in
                    make.left.equalTo(1)
                    make.right.equalTo(withdrawalContentView.snp_centerX).offset(-0.5)
                    make.height.equalTo(29)
                    make.top.equalTo((29+1)*(i+1)+1)
                }
                label2.snp_makeConstraints { make in
                    make.left.equalTo(withdrawalContentView.snp_centerX).offset(0.5)
                    make.right.equalTo(-1)
                    make.height.top.equalTo(label1)
                }
            }
            
        }else{
            titleLabel.text = "高级认证"
            if model.certificationLevel  == 2{
               //已认证
                statusView.backgroundColor = .init(hexString: "#3ACC9B")
                statusIcon.image = UIImage(named: "real_name_authentication_icon")
                statusLabel.text = "已认证"
            }else{
               //未认证
                statusView.backgroundColor = .init(hexString: "#FFA756")
                statusIcon.image = UIImage(named: "real_name_unAuthentication_icon")
                statusLabel.text = "未认证"
            }
            buyContentView.snp_makeConstraints { make in
                make.left.equalTo(16)
                make.top.equalTo(50)
                make.right.equalTo(-16)
                make.height.equalTo(30*(model.gjmmbRealNameAuthenticationPOS.count+1)+1)
            }
            withdrawalContentView.snp_makeConstraints { make in
                make.left.right.equalTo(buyContentView)
                make.top.equalTo(buyContentView.snp_bottom).offset(14)
                make.height.equalTo(30*(model.gjtbRealNameAuthenticationPOS.count+1)+1)
            }
            let buyTitleLabel = getHeadTitleLabel(title: "买卖币",backGroundColor: .init(hexString: "#E7E7E7"),textFont: UIFont(name: "PingFangSC-Regular", size: 15)!)
            buyContentView.addSubview(buyTitleLabel)
            buyTitleLabel.snp_makeConstraints { make in
                make.top.left.equalTo(1)
                make.right.equalTo(-1)
                make.height.equalTo(29)
            }
            for i in 0..<model.gjmmbRealNameAuthenticationPOS.count {
                let data = model.gjmmbRealNameAuthenticationPOS[i]
                let label1 = getHeadTitleLabel(title: data.currency + "限额/日",backGroundColor: .init(hexString: "#F3F3F3"),textFont: UIFont(name: "PingFangSC-Regular", size: 14)!)
                let label2 = getHeadTitleLabel(title:String(data.advancedCertificationBusiness) + " " + data.currency ,backGroundColor: .init(hexString: "#F3F3F3"),textFont: UIFont(name: "PingFangSC-Regular", size: 14)!)
                buyContentView.addSubview(label1)
                buyContentView.addSubview(label2)
                label1.snp_makeConstraints { make in
                    make.left.equalTo(1)
                    make.right.equalTo(buyContentView.snp_centerX).offset(-0.5)
                    make.height.equalTo(29)
                    make.top.equalTo((29+1)*(i+1)+1)
                }
                label2.snp_makeConstraints { make in
                    make.left.equalTo(buyContentView.snp_centerX).offset(0.5)
                    make.right.equalTo(-1)
                    make.height.top.equalTo(label1)
                }
            }
                    
            let withdrawalTitleLabel = getHeadTitleLabel(title: "提币",backGroundColor: .init(hexString: "#E7E7E7"),textFont: UIFont(name: "PingFangSC-Regular", size: 15)!)
            withdrawalContentView.addSubview(withdrawalTitleLabel)
            withdrawalTitleLabel.snp_makeConstraints { make in
                make.top.left.equalTo(1)
                make.right.equalTo(-1)
                make.height.equalTo(29)
            }
            for i in 0..<model.gjtbRealNameAuthenticationPOS.count {
                let data = model.gjtbRealNameAuthenticationPOS[i]
                let label1 = getHeadTitleLabel(title: data.currency + "限额/日",backGroundColor: .init(hexString: "#F3F3F3"),textFont: UIFont(name: "PingFangSC-Regular", size: 14)!)
                let label2 = getHeadTitleLabel(title:String(data.advancedCertificationWithdraw) + " " + data.currency ,backGroundColor: .init(hexString: "#F3F3F3"),textFont: UIFont(name: "PingFangSC-Regular", size: 14)!)
                withdrawalContentView.addSubview(label1)
                withdrawalContentView.addSubview(label2)
                label1.snp_makeConstraints { make in
                    make.left.equalTo(1)
                    make.right.equalTo(withdrawalContentView.snp_centerX).offset(-0.5)
                    make.height.equalTo(29)
                    make.top.equalTo((29+1)*(i+1)+1)
                }
                label2.snp_makeConstraints { make in
                    make.left.equalTo(withdrawalContentView.snp_centerX).offset(0.5)
                    make.right.equalTo(-1)
                    make.height.top.equalTo(label1)
                }
            }
            addSubview(tipLabel)
            addSubview(subTipLabel)
            tipLabel.snp_makeConstraints { make in
                make.left.equalTo(16)
                make.right.equalTo(16)
                make.top.equalTo(withdrawalContentView.snp_bottom).offset(16)
                make.height.equalTo(20)
            }
            subTipLabel.snp_makeConstraints { make in
                make.left.right.height.equalTo(tipLabel)
                make.top.equalTo(tipLabel.snp_bottom).offset(2)
            }
        }
        
    }
}
