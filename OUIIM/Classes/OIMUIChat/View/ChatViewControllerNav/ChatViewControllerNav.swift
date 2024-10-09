//
//  ChatViewControllerNav.swift
//  OUIIM
//
//  Created by mac on 2024/9/19.
//

import Foundation
import OUICore

class ChatViewControllerNav: UIView {
    
    
    var conversationInfo:ConversationInfo!
    
    var backBlock:(()->Void)!
    var gotoGroupBlock:(()->Void)!
    var gotoGroupUserListBlock:(()->Void)!
    var gotoUserBlock:(()->Void)!
    var showMoreBlock:(()->Void)!
    
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
        contentView.addSubview(chatIconImg)
        contentView.addSubview(moreImg)
        contentView.addSubview(GroupTitleLbl)
        contentView.addSubview(systemTitleLbl)
        contentView.addSubview(userTitleView)
        
        backImg.snp.makeConstraints { make in
            make.left.equalTo(18)
            make.width.height.equalTo(20)
            make.centerY.equalToSuperview()
        }
        
        chatIconImg.snp.makeConstraints { make in
            make.left.equalTo(54)
            make.width.height.equalTo(36)
            make.centerY.equalToSuperview()
        }
        
        moreImg.snp.makeConstraints { make in
            make.right.equalTo(-16)
            make.width.height.equalTo(24)
            make.centerY.equalToSuperview()
        }
        
        GroupTitleLbl.snp.makeConstraints { make in
            make.left.equalTo(100)
            make.right.equalTo(moreImg.snp_left).offset(-40)
            make.centerY.equalToSuperview()
        }
        
        systemTitleLbl.snp.makeConstraints { make in
            make.left.equalTo(100)
            make.right.equalTo(-100)
            make.centerY.equalToSuperview()
        }
        
        userTitleView.snp.makeConstraints { make in
            make.left.equalTo(100)
            make.top.equalTo(chatIconImg.snp_top)
            make.bottom.equalTo(chatIconImg.snp_bottom)
            make.right.equalTo(moreImg.snp_left).offset(-40)
        }
        
    }
    
    func updateAbout(info: ConversationInfo) {
        conversationInfo = info
        if info.conversationType == .notification {
            
            userTitleView.isHidden = true
            GroupTitleLbl.isHidden = true
            chatIconImg.isHidden = true
            systemTitleLbl.isHidden = false
            
            systemTitleLbl.text = info.showName
            moreImg.image = .init(named: "mine_setting_icon")
        }
        
        
        if info.conversationType == .superGroup {
            
            userTitleView.isHidden = true
            GroupTitleLbl.isHidden = false
            chatIconImg.isHidden = false
            systemTitleLbl.isHidden = true
            
            GroupTitleLbl.text = info.showName
            setIconImage()
        }
        
        if info.conversationType == .c2c {
            
            userTitleView.isHidden = false
            GroupTitleLbl.isHidden = true
            chatIconImg.isHidden = false
            systemTitleLbl.isHidden = true
            
            userNameTitle.text = info.showName
            setIconImage()
            
            updateNickName(userID: info.userID!)
        }
        
        
    }
    
    // MARK: - 张亚飞打的标记 获取用户信息
    func  updateNickName(userID: String) {
        if let handler = OIMApi.getUserMessageHandle {
            
            handler(userID, {  [weak self]res in
               print(res)
                
                let userStruct = SuperStringUtil.getUserState(showname: res)
                
                self?.userNameTitle.textColor = userStruct.v > 0 ? .init(hexString: "#FF3939") : .init(hexString: "#333333")
                
                let tag = SuperStringUtil.getUserTag(showname: res)
                
                if tag != nil {
                    self?.tagLable.text = tag
//                    self?.userNameTitle.snp.updateConstraints({ make in
//                        make.bottom.equalTo((self?.tagLable.snp_top)!)
//                    })
                } else {
                    self?.userNameTitle.snp.makeConstraints({ make in
                        make.bottom.equalToSuperview()
                    })
                }
                
                
            })
        }
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
    
    lazy var chatIconImg: UIImageView = {
        let r = UIImageView()
        r.image = .init(named: "DefaultAvatar")
        r.clipsToBounds = true
        r.layer.cornerRadius = 18
        r.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(iconDidSelect))
        r.addGestureRecognizer(tap)
        return r
    }()
    
    lazy var moreImg: UIImageView = {
        let r = UIImageView()
        r.image =  UIImage(nameInBundle: "common_more_btn_icon")
        r.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(gotoShowMore))
        r.addGestureRecognizer(tap)
        return r
    }()
    
    lazy var GroupTitleLbl: UILabel = {
        let r = UILabel()
        r.textColor = .init(hexString: "#333333")
        r.font =  UIFont(name: "PingFangSC-Medium", size: 18)
        r.text = "群名"
        
        r.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(gotoGroupUserListVC))
        r.addGestureRecognizer(tap)
        
        return r
    }()
    
    
    
    lazy var systemTitleLbl: UILabel = {
        let r = UILabel()
        r.textColor = .init(hexString: "#333333")
        r.font =  UIFont(name: "PingFangSC-Medium", size: 18)
        r.text = "系统消息"
        r.textAlignment = .center
        return r
    }()
    
    
    lazy var userTitleView: UIView = {
        let r = UIView()
        r.addSubview(userNameTitle)
        r.addSubview(tagLable)
        
        userNameTitle.snp.makeConstraints { make in
            make.left.right.equalTo(0)
            make.top.equalTo(0)
//            make.bottom.equalToSuperview()
//            make.height.equalTo(18)
        }
        
        tagLable.snp.makeConstraints { make in
            make.left.bottom.right.equalTo(0)
            make.height.equalTo(12)
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(gotoUserDetailVC))
        r.addGestureRecognizer(tap)
        
        return r
    }()
    
    lazy var userNameTitle: UILabel = {
        let r = UILabel()
        r.textColor = .init(hexString: "#333333")
        r.font =  UIFont(name: "PingFangSC-Medium", size: 18)
        r.text = "用户名"
        return r
    }()
    
//    lazy var tagView: userTag = {
//        let v = userTag()
//        return v
//    }()
    
    lazy var tagLable: UILabel = {
        let v = UILabel()
        v.font = UIFont(name: "PingFangSC-Semibold", size: 11)
        v.textColor = .init(hexString: "#7238EF")
        v.text = "[V4、\("企业".localized())、\("博客".localized())]".localized()
        v.text = nil
        return v
    }()
    
}

extension ChatViewControllerNav {
    
    @objc func iconDidSelect() {
        if conversationInfo.conversationType == .c2c {
            gotoUserDetailVC()
        } else {
            gotoGroupUserListVC()
        }
    }
    
    @objc func backAction() {
        print("返回")
        self.backBlock()
    }
    
    @objc func gotoUserDetailVC() {
        print("用户详情")
        gotoUserBlock()
    }
    
    @objc func gotoGroupDetailVC() {
        print("群组详情")
        gotoGroupBlock()
    }
    
    @objc func gotoGroupUserListVC() {
        print("群成员列表")
        gotoGroupUserListBlock()
    }
    
    @objc func gotoShowMore() {
        print("展示更多")
        showMoreBlock()
    }
    
    func setIconImage() {
        if conversationInfo.conversationType == .superGroup {

            setGroupImg(item: conversationInfo)
        } else {

            chatIconImg.kf.setImage(with: URL(string: conversationInfo.faceURL ?? ""), placeholder: UIImage(named: "DefaultAvatar"))
        }
    }
    
    func setGroupImg(item: ConversationInfo) {
        
        
        IMController.shared.getGroupMemberList(groupId: item.groupID!, filter: .all, offset: 0, count: 4) { [self] ms in
                
            var faceUrlArr:[String] = []
            for item in ms {
                faceUrlArr.append(item.faceURL!)
            }
            
            if faceUrlArr.count > 0 {
                
                setGroupImgWithFaceURls(faceUrlArr: faceUrlArr, groupID: item.groupID!)
                
            } else {
                
                chatIconImg.image = .init(named: "friend_list_new_friend_icon")
            }
            
        }
    }
    
    func setGroupImgWithFaceURls(faceUrlArr: [String], groupID: String) {
        AvatarManager.placeholderImage = UIImage(named: "DefaultAvatar")!
        AvatarManager.groupAvatarType = .QQ
        AvatarManager.distanceBetweenAvatar = 1
        chatIconImg.setImageAvatar(groupId: groupID, groupSource: faceUrlArr)
        
    }
    
}
