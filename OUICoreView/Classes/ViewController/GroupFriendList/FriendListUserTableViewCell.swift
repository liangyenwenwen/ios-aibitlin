
import OUICore

open class FriendListUserTableViewCell: UITableViewCell {
    public let avatarImageView: AvatarView = {
        let v = AvatarView()
        v.size = 40.w
        v.layer.cornerRadius = 20.w
        return v
    }()
    
    let titleView: UIView = {
        let v = UIView()
        return v
    }()

    public let titleLabel: UILabel = {
        let v = UILabel()
//        v.font = UIFont.f17
//        v.textColor = UIColor.c0C1C33
        v.font =  UIFont(name: "PingFangSC-Medium", size: 18)
//        v.textColor = UIColor(red: 0.533, green: 0.533, blue: 0.533, alpha: 1)
        v.textColor = .init(hexString: "#333333")
        return v
    }()
    
    lazy var tagLable: UILabel = {
        let v = UILabel()
        v.font = UIFont(name: "PingFangSC-Semibold", size: 11)
        v.textColor = .init(hexString: "#7238EF")
        v.text = nil
        return v
    }()

    public let subtitleLabel: UILabel = {
        let v = UILabel()
        v.font = .f14
        v.textColor = .c8E9AB0
        return v
    }()
    
    public let trainingLabel: UILabel = {
        let v = UILabel()
        v.font = .f12
        v.textColor = .c0C1C33
        v.layer.masksToBounds = true
        return v
    }()
    
    public let rowStack: UIStackView = {
        let v = UIStackView();
        v.spacing = 8
        v.alignment = .center
        v.distribution = .fill
        
        return v
    }()

    lazy var lineView: UIView = {
        let r = UIView()
//        r.backgroundColor = .init(hexString: "#F5F5F5")
//        r.backgroundColor = .placeholderText
        r.backgroundColor = .init(hexString: "#d9d9d9")
        return r
    }()
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .cellBackgroundColor
        
        let textStack: UIStackView = {
//            let v = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
            let v = UIStackView(arrangedSubviews: [titleView, subtitleLabel])
            v.axis = .vertical
            v.spacing = 4
            v.alignment = .leading
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
        
        
        trainingLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        rowStack.addArrangedSubview(avatarImageView)
        rowStack.addArrangedSubview(textStack)
        rowStack.addArrangedSubview(trainingLabel)
        rowStack.alignment = .center
        
        contentView.addSubview(rowStack)
        
        rowStack.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(8.h)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        contentView.addSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.left.equalTo(titleLabel.snp_left)
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
            make.right.equalTo(-20)
        }
    }

    @available(*, unavailable)
    required public init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        reset()
    }
    
    private func reset() {
        titleLabel.text = nil
        titleLabel.attributedText = nil
        subtitleLabel.text = nil
        trainingLabel.text = nil
        trainingLabel.attributedText = nil
        avatarImageView.setAvatar(url: nil, text: nil, onTap: nil)
        
        titleLabel.textColor = .c0C1C33
        subtitleLabel.textColor = .c0C1C33
        trainingLabel.textColor = .c0C1C33
    }
    
    
    public func bindData(user: UserInfo) {
        
//       titleLabel.text = SuperStringUtil.getUserState(showname: user.nickname!).n
       avatarImageView.setAvatar(url: user.faceURL, text: user.nickname, onTap: nil)
        
        let userStruct = SuperStringUtil.getUserState(showname: user.nickname!)
        titleLabel.text =  userStruct.n
        titleLabel.textColor = userStruct.v > 0 ? .init(hexString: "#FF3939") : .init(hexString: "#333333")
        tagLable.text =  SuperStringUtil.getUserTag(showname: user.nickname!) ?? ""
        
    }
    
}
