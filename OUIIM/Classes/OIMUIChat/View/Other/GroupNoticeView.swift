
import OUICore

class GroupNoticeView: UIView {
    
    var onTap: (() -> Void)?
    var onClose: (() -> Void)?
    
    func showIn(view: UIView) {
        view.addSubview(self)
        NSLayoutConstraint.activate([
            self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            self.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        ])
    }
    
    private lazy var titleLabel: UILabel = {
        let v = UILabel()
        v.numberOfLines = 2
        v.font = .f17
        v.setContentCompressionResistancePriority(UILayoutPriority(999), for: .horizontal)
        v.setContentCompressionResistancePriority(UILayoutPriority(999), for: .vertical)

        let image = UIImage(nameInBundle: "chat_msg_notice_speaker_icon")
        let attachment = NSTextAttachment(image: image!)
        attachment.bounds = CGRect(x: 0, y: -6, width: 24, height: 24)
        let base = NSMutableAttributedString(attachment: attachment)
        base.append(NSAttributedString(string: "groupAc".innerLocalized(), attributes: [.foregroundColor: UIColor.systemBlue]))
        v.attributedText = base
        
        return v
    }()
    
    lazy var contentLabel: UILabel = {
        let v = UILabel()
        v.textColor = .c0C1C33
        v.font = .f14
        v.numberOfLines = 2
        v.setContentCompressionResistancePriority(UILayoutPriority(999), for: .horizontal)
        v.setContentCompressionResistancePriority(UILayoutPriority(999), for: .vertical)

        return v
    }()
    
    private lazy var closeButton: UIButton = {
        let v = UIButton(type: .system)
        v.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        v.tintColor = .white
        v.translatesAutoresizingMaskIntoConstraints = false
        v.addTarget(self, action: #selector(close), for: .touchUpInside)
        
        return v
    }()
    
    @objc
    private func close() {
        onClose?()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubview() {
        let contentView = UIView()
        contentView.layer.cornerRadius = 5
        contentView.backgroundColor = .cF2F8FF
        contentView.layer.masksToBounds = true
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.isUserInteractionEnabled = true
        
        addSubview(contentView)
        
        let vStack = UIStackView(arrangedSubviews: [titleLabel, contentLabel])
        vStack.axis = .vertical
        vStack.spacing = 8
        vStack.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(vStack)
        
        contentView.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            contentView.heightAnchor.constraint(equalToConstant: 67),

            vStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            vStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            vStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            vStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            contentLabel.heightAnchor.constraint(lessThanOrEqualToConstant: 200),
            closeButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            closeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            closeButton.heightAnchor.constraint(equalToConstant: 16),
            closeButton.widthAnchor.constraint(equalToConstant: 16),
        ])
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        contentView.addGestureRecognizer(tap)
    }
    
    @objc
    private func tapAction() {
        onTap?()
    }
}
