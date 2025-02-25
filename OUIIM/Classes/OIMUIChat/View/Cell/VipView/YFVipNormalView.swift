//
//  YFVipNormalView.swift
import ChatLayout
import Foundation
import UIKit
import OUICore

class YFVipNormalView: UIView, StaticViewFactory, ContainerCollectionViewCellDelegate {

    private var controller: YFVipNormalViewController?

    lazy var titleLbl: UILabel = {
        let v = UILabel()
        v.font = .init(name: "PingFangSC-Semibold", size: 16)
        v.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        v.numberOfLines = 0
        v.text = "VIP购买成功";
        return v
    }()
    
    lazy var contentLbl: UILabel = {
        let v = UILabel()
        v.font = .init(name: "PingFangSC-Medium", size: 14)
        v.textColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)
        v.numberOfLines = 0
        v.text = "您已成功购买VIP2，VIP2有效期：永久有效。您已成功购买VIP2，VIP2有效期：永久有效。您已成功购买VIP2，VIP2有效期：永久有效。"
        return v
    }()
    
    lazy var contactView: YFContactNormalView = {
        let v = YFContactNormalView()
        v.backgroundColor = .init(hexString: "#EAEAEA")
        v.clipsToBounds = true
        v.layer.cornerRadius = 8
        return v
    }()
    
    lazy var timeLbl: UILabel = {
        let v = UILabel()
        v.font = .init(name: "PingFangSC-Regular", size: 11)
        v.textColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)
        v.numberOfLines = 0
        v.text = "2024-08-29 15:23:36"
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }
    
    func apply(_ layoutAttributes: ChatLayoutAttributes) {
        setupSize()
    }

    func setup(with controller: YFVipNormalViewController) {
        self.controller = controller
        reloadData()
    }
    
    func prepareForReuse() {

    }

    func reloadData() {
        guard let controller else {
            return
        }
        
        titleLbl.text = controller.source.title
        contentLbl.text = controller.source.text
//        timeLbl.text = Date.timeString(date: controller.message.date)
        timeLbl.text = Date.timeStringTransform(date: controller.message.date)
        
//        titleLbl.backgroundColor = .red
//        contentLbl.backgroundColor = .blue
        
        guard let jsonData = controller.source.text!.data(using: .utf8) else {
                    return
        }

        do {
            let user = try JSONDecoder().decode(systemCustomNotitifyItem.self, from: jsonData)
            print(user.user?.faceURL, user.user?.userID)
            contentLbl.text = user.cont
            if let messageContact = user.user {
                
                contactView.update(user:messageContact)
                contactView.isHidden = false
                
                timeLbl.snp.makeConstraints { make in
                    make.top.equalTo(contactView.snp_bottom).offset(10)
                }
            } else {
                
                contactView.isHidden = true
                print("没有user")
                
                timeLbl.snp.makeConstraints { make in
                    make.top.equalTo(contentLbl.snp_bottom).offset(10)
                }
            }
            
        } catch {
            contactView.isHidden = true
            print("没有user")
            
            timeLbl.snp.makeConstraints { make in
                make.top.equalTo(contentLbl.snp_bottom).offset(10)
            }
            
        }
        
        
    }

    private func setupSubviews() {
        
        let bgView = UIView()
        addSubview(bgView)
        
        bgView.clipsToBounds = true
        bgView.layer.cornerRadius = 8
        bgView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(8)
            make.right.equalTo(-8)
            make.top.bottom.equalToSuperview()
        }
        bgView.backgroundColor = .white
        
        
        bgView.addSubview(titleLbl)
        bgView.addSubview(contentLbl)
        bgView.addSubview(contactView)
        bgView.addSubview(timeLbl)
        
        titleLbl.snp.makeConstraints { make in
            make.left.top.equalToSuperview().offset(14)
            make.right.equalToSuperview().offset(-14)
        }
        contentLbl.snp.makeConstraints { make in
            make.left.right.equalTo(titleLbl)
            make.top.equalTo(titleLbl.snp_bottom).offset(10)
            
//            make.bottom.equalToSuperview().offset(-14)
        }
        
        contactView.snp.makeConstraints { make in
            make.left.right.equalTo(titleLbl)
            make.height.equalTo(76)
            make.top.equalTo(contentLbl.snp_bottom).offset(10)
        }
        timeLbl.snp.makeConstraints { make in
            make.left.right.equalTo(titleLbl)
            make.top.equalTo(contactView.snp_bottom).offset(10)
            make.bottom.equalToSuperview().offset(-14)
        }
        
    }

    private func setupSize() {
        
//        setNeedsLayout()
        layoutIfNeeded()
    }
}

