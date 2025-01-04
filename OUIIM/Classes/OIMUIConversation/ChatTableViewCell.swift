
import OUICore
import Kingfisher

// MARK: -    首页聊天列表CEll
class ChatTableViewCell: UITableViewCell {
    
    let avatarImageView: AvatarView = {
        let v = AvatarView()
        v.size = 56
        v.clipsToBounds = true
        v.layer.cornerRadius = 28
        v.contentMode = .scaleAspectFill
        return v
    }()
    
    
//    let avaterImage: UIImageView = {
//       let r = UIImageView(frame: CGRect(x: 0, y: 0, width: 48, height: 48))
//        r.clipsToBounds = true
//        r.layer.cornerRadius = 24
//        r.backgroundColor = .red
//        return r
//    }()

    let titleLabel: UILabel = {
        let v = UILabel()
        v.font = UIFont(name: "PingFangSC-Semibold", size: 16)
        v.textColor = .init(hexString: "#333333")
        
        return v
    }()
    
    lazy var tagLable: UILabel = {
        let v = UILabel()
        v.font = UIFont(name: "PingFangSC-Semibold", size: 11)
        v.textColor = .init(hexString: "#7238EF")
        v.text = "[企业]".localized()
        return v
    }()
    
    let titleLabel2: UILabel = {
        let v = UILabel()
        v.font = .f17
        v.textColor = .c0C1C33
        v.text = "测试"
        return v
    }()
    

    let subtitleLabel: UILabel = {
        let v = UILabel()
        v.font = .systemFont(ofSize: 13)
        v.textColor = .c8E9AB0
        v.font = .f14
        
        return v
    }()

    let timeLabel: UILabel = {
        let v = UILabel()
        v.font = .systemFont(ofSize: 12)
        v.textColor = .c8E9AB0
        v.font = .f12
        v.setContentCompressionResistancePriority(UILayoutPriority.required, for: .horizontal)
        
        return v
    }()

    let unreadLabel: RoundCornerLayoutLabel = {
        let v = RoundCornerLayoutLabel(roundCorners: .allCorners, radius: nil)
        v.font = .f12
        v.backgroundColor = .cFF381F
        v.textColor = .white
        v.textAlignment = .center
        v.contentInset = UIEdgeInsets(top: 1, left: 4, bottom: 1, right: 4)
        
        return v
    }()

    let muteImageView: UIImageView = {
        let v = UIImageView(image: UIImage(nameInBundle: "chat_status_muted_icon"))
        v.isHidden = true
        
        return v
    }()
    
    lazy var pinImageView: UIImageView = {
        let v = UIImageView(image: UIImage(nameInBundle: "live_room_pined_icon"))
        v.isHidden = true
        
        return v
    }()

//    lazy var tagView: userTag = {
//        let v = userTag()
//        return v
//    }()
    
    let titleView: UIView = {
        let v = UIView()
        return v
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        selectionStyle = .none

        setUpUI()
        
        
        
        
        
//        titleLabel.snp.makeConstraints { make in
//            make.left.equalToSuperview()
//            make.centerY.equalToSuperview()
//        }
        
//        let tagStack: UIStackView = {
//            let v =  UIStackView(arrangedSubviews: [tagView])
//            v.alignment = .center
//            return v
//        }()
        
        let hTitleStack: UIStackView = {
//            let v =  UIStackView(arrangedSubviews: [titleLabel, titleLabel2])
//            let v =  UIStackView(arrangedSubviews: [titleLabel, tagStack])
            let v = UIStackView()
            v.addArrangedSubview(titleLabel)
            v.addArrangedSubview(tagLable)
//            titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            v.alignment = .lastBaseline
//            v.distribution = .fillProportionally
            v.spacing = 4
//            v.backgroundColor = .red
//            v.spacing = 4
            return v
        }()
        
        
        
        
        let vStack: UIStackView = {
//            let v = UIStackView(arrangedSubviews: [hTitleStack, subtitleLabel])
            let v = UIStackView(arrangedSubviews: [titleView, subtitleLabel])
            v.axis = .vertical
            v.distribution = .equalSpacing
            v.spacing = 4
//            v.backgroundColor = .yellow
            return v
        }()
        
        titleView.addSubview(tagLable)
        titleView.addSubview(titleLabel)
        tagLable.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-2)
            make.right.lessThanOrEqualToSuperview()
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.bottom.equalToSuperview()
            make.right.lessThanOrEqualTo(tagLable.snp_left).offset(-4)
        }
    

        titleView.snp.makeConstraints { make in
            make.top.right.left.equalToSuperview()
            make.height.equalTo(22)
        }
        
        
        let hStack = UIStackView(arrangedSubviews: [avatarImageView, vStack])
//        let hStack = UIStackView(arrangedSubviews: [avaterImage, vStack])
        hStack.alignment = .center
        hStack.spacing = 12.w
//        hStack.backgroundColor = .green
        contentView.addSubview(hStack)
        hStack.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.top.bottom.equalToSuperview()
        }

        contentView.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { make in
//            make.right.equalToSuperview().offset(-StandardUI.margin_22)
            make.right.equalToSuperview().offset(-36)
            make.top.equalTo(hStack).offset(5)
            make.left.greaterThanOrEqualTo(vStack.snp.right).offset(8)
        }

        contentView.addSubview(unreadLabel)
        unreadLabel.snp.makeConstraints { make in
            make.top.equalTo(timeLabel.snp.bottom)
//            make.right.equalTo(timeLabel)
//            make.left.equalTo(timeLabel.snp_right).offset(10)
            make.right.equalToSuperview().offset(-10)
//            make.height.greaterThanOrEqualTo(16)
            make.width.greaterThanOrEqualTo(unreadLabel.snp.height)
        }

        contentView.addSubview(muteImageView)
        muteImageView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-StandardUI.margin_22)
            make.centerY.equalTo(unreadLabel)
        }
        
        contentView.addSubview(pinImageView)
        pinImageView.snp.makeConstraints { make in
//            make.right.equalToSuperview().inset(16)
            make.right.equalToSuperview()
            make.top.equalToSuperview()
        }
        
//        contentView.addSubview(tagView)
//        titleLabel.snp.makeConstraints { make in
//            make.left.equalToSuperview()
//            make.centerX.equalToSuperview()
//            make.width.lessThanOrEqualTo(100)
//        }
        
//        tagView.snp.makeConstraints { make in
//            make.left.equalTo(titleLabel.snp_right).offset(5)
//            make.centerY.equalTo(titleLabel)
//            make.height.equalTo(12)
//            make.right.equalToSuperview()
//        }
        
//        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
//        tagView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
//        tagView.backgroundColor = .orange
//        layoutIfNeeded()
        
//        let array: [[String]] = [["006tNc79gy1g5fmoexlt6j30u00vxqrb.jpg", "006tNc79gy1g5fmofi07aj30u00uwqqk.jpg", "006tNc79gy1g5fln5crn5j30u00u00vh.jpg"]];
        
        
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.reset()
    }
    
    
}


extension ChatTableViewCell {
    
    fileprivate func setUpUI() {
        AvatarManager.baseUrl = "http://ww1.sinaimg.cn/small/"
        AvatarManager.groupAvatarType = .WeChat
        if UIImage(named: "DefaultAvatar") != nil {
            AvatarManager.placeholderImage = UIImage(named: "DefaultAvatar")!
        }
    }
    
//    func  updateUI(item: ConversationInfo, needCalculate: Bool = true)
    func  updateUI(item: ConversationInfo) {
        
        let placeholderName: String = item.conversationType == .c2c ? "contact_my_friend_icon" : "contact_my_group_icon"
        muteImageView.isHidden = item.recvMsgOpt == .receive
        
//        avatarImageView.reset()
        // MARK: -   群头像 头像区分
       
        if item.conversationType == .superGroup {
            
            avatarImageView.isGroup = true
            avatarImageView.setGroupImg(item: item)
           
        }  else {
            avatarImageView.isGroup = false
            avatarImageView.setAvatar(url: item.faceURL, text: item.showName, placeHolder: placeholderName, isLocal: true)
//            avatarImageView.setAboutGroupImg(linkurl: item.faceURL ?? "", userId: item.conversationID)
//            avatarImageView
        }
        
        
        let userStruct = SuperStringUtil.getUserState(showname: item.showName!)
        titleLabel.text =  userStruct.n
        
//        titleLabel.textColor = userStruct.v > 0 ? .init(hexString: "#FF3939") : .init(hexString: "#333333")
        
        pinImageView.isHidden = !item.isPinned
        subtitleLabel.attributedText = MessageHelper.getAbstructOf(conversation: item, highlight: false)
        var unreadShouldHide: Bool = false
        if item.recvMsgOpt != .receive {
            unreadShouldHide = true
        }
        if item.unreadCount <= 0 {
            unreadShouldHide = true
        }
        unreadLabel.isHidden = unreadShouldHide
        unreadLabel.text =  item.unreadCount > 99 ? "99+" : "\(item.unreadCount)"
        muteImageView.isHidden = item.recvMsgOpt == .receive
        timeLabel.text = MessageHelper.convertList(timestamp_ms: item.latestMsgSendTime)
        
        
        tagLable.isHidden = item.conversationType == .notification
        
        
        
//        if needCalculate {
            if item.conversationType == .c2c {
                
//                updateNickName(userID: item.userID!, item: item)
                
                let userStruct = SuperStringUtil.getUserState(showname: item.showName!)
                
                titleLabel.textColor = userStruct.v > 0 ? .init(hexString: "#FF3939") : .init(hexString: "#333333")
//                updateUI(item: item, needCalculate:  false)
                
                tagLable.text = ""
                
                
                
            }else if item.conversationType == .superGroup {
                updateGroupNumberCount(groupID: item.groupID!, item: item)
                tagLable.text = "[\(4)]"
                tagLable.textColor = .init(hexString: "#388CEF")
                titleLabel.textColor = .init(hexString: "#333333")
            } else {
                
               
                if item.userID == "10000" {
                    titleLabel.text = "系统通知".localized()
                } else if item.userID == "10086" {
                    titleLabel.text = "VIP专属通知".localized()
                }
                
                tagLable.text = ""
                titleLabel.textColor = .init(hexString: "#333333")
            }
//        } else  {
//            if item.conversationType == .c2c {
//                tagLable.text = ""
//            } else if item.conversationType == .superGroup {
//                tagLable.text = "[\(4)]"
//                tagLable.textColor = .init(hexString: "#388CEF")
//                titleLabel.textColor = .init(hexString: "#333333")
//            } else {
//                tagLable.text = ""
//                titleLabel.textColor = .init(hexString: "#333333")
//            }
//        }

    }
    
    // MARK: -   获取用户信息
//    func  updateNickName(userID: String, item: ConversationInfo) {
//        if let handler = OIMApi.getUserMessageHandle {
//            
//            handler(userID, {  [weak self]res in
//               print(res)
//                
//                let userStruct = SuperStringUtil.getUserState(showname: res)
//                
//                self?.titleLabel.textColor = userStruct.v > 0 ? .init(hexString: "#FF3939") : .init(hexString: "#333333")
//                self?.updateUI(item: item, needCalculate:  false)
//            })
//        }
//    }
    
    func updateGroupNumberCount(groupID: String, item: ConversationInfo) {

        IMController.shared.getGroupInfo(groupIds: [groupID]) { [weak self] (groupInfos: [GroupInfo]) in
            guard let self else { return }
            guard let groupInfo = groupInfos.first else { return }
            print(groupInfo.memberCount)
            tagLable.text = "[\(groupInfo.memberCount)]"
//            getGroupInfoHelper(groupInfo: groupInfo)
//            self.updateUI(item: item, needCalculate:  false)
        }
    }
    
}







// MARK: -   用户tag
class userTag: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
//        backgroundColor = .clear
        refreshTag()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func refreshTag() {
        let tag = tagView()
        tag.updateUI(type: 1)
        addSubview(tag)
        
        let tag1 = tagView()
        tag1.updateUI(type: 2)
        addSubview(tag1)
        
        let tag2 = tagView()
        tag2.updateUI(type: 3)
        addSubview(tag2)
        
        tag.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.height.equalToSuperview()
        }
        
        tag1.snp.makeConstraints { make in
            make.left.equalTo(tag.snp_right).offset(5)
            make.height.equalToSuperview()
        }
        
        tag2.snp.makeConstraints { make in
            make.left.equalTo(tag1.snp_right).offset(5)
            make.height.equalToSuperview()
        }
    }
    
    class tagView: UIView {
        override init(frame: CGRect) {
            super.init(frame: frame)
            backgroundColor = .purple
            clipsToBounds = true
            layer.cornerRadius = 6
            
            addSubview(tagIcon)
            addSubview(tagTitle)
            
            tagIcon.snp.makeConstraints { make in
                make.left.equalTo(3)
                make.centerY.equalToSuperview()
                make.width.height.equalTo(8)
            }
            
            tagTitle.snp.makeConstraints { make in
                make.left.equalTo(tagIcon.snp_right).offset(2)
                make.centerY.equalToSuperview()
                make.right.equalToSuperview().offset(-4)
            }
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        lazy var tagIcon: UIImageView = {
            let v = UIImageView()
            v.image = UIImage(named: "tag_vip")
            return v
        }()
        
        lazy var tagTitle: UILabel = {
            let v = UILabel()
            v.font =  UIFont(name: "PingFangSC-Medium", size: 8)
            v.textColor = .white
            v.text = "VIP2"
            return v
        }()
        
        func updateUI(type: NSInteger) {
            if type == 1{
                tagIcon.image = .init(named: "tag_vip")!
                backgroundColor = .init(hexString: "#7238EF")
                tagTitle.text = "VIP"

            }
            
            if type == 2{
                tagIcon.image = .init(named: "tag_blog")!
                backgroundColor = .init(hexString: "#EA896A")
                tagTitle.text = "博客".innerLocalized()
            }
            
            if type == 3{
                tagIcon.image = .init(named: "tag_company")!
                backgroundColor = .init(hexString: "#388CEF")
                tagTitle.text = "企业".localized()
            }
        }
    }
}

