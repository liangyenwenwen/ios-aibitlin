
import OUICore
import Kingfisher

// MARK: - 张亚飞打的标记  首页聊天列表CEll
class ChatTableViewCell: UITableViewCell {
    
    let avatarImageView: AvatarView = {
        let v = AvatarView()
        v.size = 48.h
        v.clipsToBounds = true
        v.layer.cornerRadius = 24.h
        return v
    }()

    let titleLabel: UILabel = {
        let v = UILabel()
        v.font = .f17
        v.textColor = .c0C1C33
        
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

    lazy var tagView: userTag = {
        let v = userTag()
        return v
    }()
    
    let titleView: UIView = {
        let v = UIView()
        return v
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        selectionStyle = .none

        setUpUI()
        
//        titleView.addSubview(titleLabel)
//        titleView.addSubview(tagView)
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
            v.addArrangedSubview(tagView)
            v.alignment = .center
            v.distribution = .equalCentering
            v.spacing = 4
//            v.backgroundColor = .red
//            v.spacing = 4
            return v
        }()
        
        let vStack: UIStackView = {
            let v = UIStackView(arrangedSubviews: [hTitleStack, subtitleLabel])
            v.axis = .vertical
            v.distribution = .equalSpacing
            v.spacing = 4
//            v.backgroundColor = .yellow
            return v
        }()
        
        let hStack = UIStackView(arrangedSubviews: [avatarImageView, vStack])
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
        titleLabel.snp.makeConstraints { make in
//            make.left.equalToSuperview()
//            make.centerX.equalToSuperview()
            make.width.lessThanOrEqualTo(100)
        }
        
        tagView.snp.makeConstraints { make in
            make.left.equalTo(titleLabel.snp_right).offset(5)
            make.centerY.equalTo(titleLabel)
            make.height.equalTo(12)
            make.right.equalToSuperview()
        }
        
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
        AvatarManager.placeholderImage = UIImage(named: "DefaultAvatar")!

    }
    
    
}






// MARK: - 张亚飞打的标记 用户tag
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

