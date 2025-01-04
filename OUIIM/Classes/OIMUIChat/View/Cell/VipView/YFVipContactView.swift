//
//  YFVipContactView.swift
//  OUIIM
//
//  Created by mac on 2024/9/3.
//

import ChatLayout
import Foundation
import UIKit
import OUICore

class YFVipContactView: UIView, StaticViewFactory, ContainerCollectionViewCellDelegate {

    private var controller: YFVipContactViewController?

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
        v.numberOfLines = 1
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

    func setup(with controller: YFVipContactViewController) {
        self.controller = controller
        reloadData()
    }
    
    func prepareForReuse() {

    }

    func reloadData() {
        guard let controller else {
            return
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
        setNeedsLayout()
    }
}


class YFContactNormalView: UIView {
    
    var chatBlock:((_ userid: String) -> Void)?
    
    var userItem: systemCustomNotitifyUser?
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .purple
        clipsToBounds = true
        layer.cornerRadius = 6
        
        addSubview(contactIcon)
        addSubview(contactNickName)
        addSubview(contactID)
        addSubview(sendMessage)
        
        contactIcon.snp.makeConstraints { make in
            make.left.equalTo(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(56)
        }
        contactIcon.clipsToBounds = true
        contactIcon.layer.cornerRadius = 28
        
        sendMessage.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
            make.width.lessThanOrEqualTo(90)
            make.width.greaterThanOrEqualTo(70)
        }
        
        
        contactNickName.snp.makeConstraints { make in
            make.left.equalTo(contactIcon.snp_right).offset(13)
            make.top.equalTo(contactIcon.snp_top).offset(5)
            make.right.equalTo(sendMessage.snp_left).offset(-10)
        }
        
        contactID.snp.makeConstraints { make in
            make.left.equalTo(contactIcon.snp_right).offset(13)
            make.top.equalTo(contactIcon.snp_top).offset(33)
            make.right.equalTo(sendMessage.snp_left).offset(-10)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var contactIcon: UIImageView = {
        let v = UIImageView()
        v.image = UIImage(named: "tag_vip")
        return v
    }()
    
    lazy var contactNickName: UILabel = {
        let v = UILabel()
        v.font =  UIFont(name: "PingFangSC-Semibold", size: 16)
        v.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        v.text = "荷包123123123123123124124"
        return v
    }()
    
    lazy var contactID: UILabel = {
        let v = UILabel()
        v.font =  UIFont(name: "PingFangSC-Regular", size: 14)
        v.textColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)
        v.text = "ID:123123123123124124123123"
        return v
    }()
    
    lazy var sendMessageLbl: UILabel = {
        let v = UILabel()
        v.textAlignment = .center
        v.textColor = .white
       
        v.text = "发消息".innerLocalized()
        v.font =  UIFont(name: "PingFangSC-Regular", size: 14)
        return v
    }()
    
    lazy var sendMessage: UIView = {
        let v = UIView()
        v.addSubview(sendMessageLbl)
        v.backgroundColor = .c0089FF
        v.clipsToBounds = true
        v.layer.cornerRadius = 14
        sendMessageLbl.snp.makeConstraints { make in
            make.top.bottom.equalTo(0)
            make.height.equalTo(28)
            make.left.equalTo(11)
            make.right.equalTo(-11)
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(chat))
        v.addGestureRecognizer(tap)
        
        return v
    }()
    
    
    func update(user: systemCustomNotitifyUser) {
        userItem = user
        let userState = SuperStringUtil.getUserState(showname: user.nickname!)
        
        contactIcon.setImageAbout(string: user.faceURL, placeHolder: "DefaultAvatar")
        contactNickName.text = userState.n
        contactNickName.textColor = userState.v > 0  ? .init(hexString: "#ff3939")  : .init(hexString: "#999999")
        contactID.text = user.userID
        
    
    }
    
    
    @objc func chat() {
        
//        if let block = chatBlock {
//            block(userItem!.userID!)
//        }
        
//        if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
            // MARK: -    获取会话信息
            IMController.shared.getConversation(sessionType: .c2c, sourceId: userItem!.userID!) { [weak self] (conversation: ConversationInfo?) in
                guard let conversation else { return }
//                print("获取控制器成功")
                let vc = ChatViewControllerBuilder().build(conversation, hiddenInputBar: false)
                vc.hidesBottomBarWhenPushed = true
                self?.findNavigator()?.pushViewController(vc, animated: false)
            }
//        } else {
//            print("获取控制器失败")
//        }
        
        
        
    }
    
}

extension UIView {
    func findController() -> UIViewController! {
            return self.findControllerWithClass(UIViewController.self)
        }
        
        func findNavigator() -> UINavigationController! {
            return self.findControllerWithClass(UINavigationController.self)
        }
        
        func findControllerWithClass<T>(_ clzz: AnyClass) -> T? {
            var responder = self.next
            while(responder != nil) {
                if (responder!.isKind(of: clzz)) {
                    return responder as? T
                }
                responder = responder?.next
            }
            return nil
        }
}
