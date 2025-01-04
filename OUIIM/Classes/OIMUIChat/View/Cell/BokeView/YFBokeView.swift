import ChatLayout
import Foundation
import OUICore

// MARK: -    自定义消息 boke

class YFBokeView: UIView, ContainerCollectionViewCellDelegate  {

    private var viewPortWidth: CGFloat = 300
    private var contentWidthConstraint: NSLayoutConstraint?
    private var contentHeightConstraint: NSLayoutConstraint?
    
    private lazy var avatarView: AvatarView = {
        let v = AvatarView()
        
        return v
    }()
    
    private lazy var nameLabel: UILabel = {
        let v = UILabel()
//        v.font = .systemFont(ofSize: 17)
//        v.textColor = .c0C1C33
        
        v.font = UIFont(name: "PingFangSC-Semibold", size: 16)
        v.textColor = .init(hexString: "#333333")
        
        return v
    }()
    
    private lazy var introLabel: UILabel = {
        let v = UILabel()
//        v.font = .systemFont(ofSize: 14)
//        v.textColor = .c0C1C33
        v.font = UIFont(name: "PingFangSC-Regular", size: 14)
        v.textColor = .init(hexString: "#666666")
        v.text = "intro"
        v.numberOfLines = 1
        return v
    }()
    
    private var controller: YFBokeController!
    
    func reloadData() {
        guard let controller else {
            return
        }
        nameLabel.text = controller.name
        avatarView.setAvatar(url: controller.faceURL, text: controller.name)
        introLabel.text = controller.intro
    }
    
    func apply(_ layoutAttributes: ChatLayoutAttributes) {
        viewPortWidth = layoutAttributes.layoutFrame.width
        setupSize()
    }

    func setup(with controller: YFBokeController) {
        self.controller = controller
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupSubviews() {
        layoutMargins = .zero
        translatesAutoresizingMaskIntoConstraints = false
        insetsLayoutMarginsFromSafeArea = false
        
        let contentView = UIView()
//        contentView.layer.cornerRadius = StandardUI.cornerRadius
        contentView.layer.cornerRadius = 10
//        contentView.layer.borderColor = UIColor.cE8EAEF.cgColor
//        contentView.layer.borderWidth = 1
        contentView.translatesAutoresizingMaskIntoConstraints = false
//        contentView.backgroundColor = .cellBackgroundColor
        contentView.backgroundColor = .init(hexString: "#EAEAEA")
        contentView.isUserInteractionEnabled = true
        
        addSubview(contentView)
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        let messageStack = UIStackView(arrangedSubviews: [nameLabel, introLabel])
        messageStack.spacing = 8
        messageStack.axis = .vertical
        messageStack.translatesAutoresizingMaskIntoConstraints = false
        
        
        let infoStack = UIStackView(arrangedSubviews: [avatarView, messageStack])
//        let infoStack = UIStackView(arrangedSubviews: [messageStack])
        infoStack.spacing = 12
        infoStack.alignment = .center
        
        
        
        let line = UIView()
        line.backgroundColor = .cE8EAEF
        
        let label = UILabel()
        label.text = "博客".innerLocalized()
        label.font = .systemFont(ofSize: 12)
        label.textColor = UIColor.c8E9AB0
        
//        let columStack = UIStackView(arrangedSubviews: [infoStack, line, label])
        let columStack = UIStackView(arrangedSubviews: [infoStack])
        columStack.spacing = 8
        columStack.axis = .vertical
        columStack.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(columStack)
        NSLayoutConstraint.activate([
            line.heightAnchor.constraint(equalToConstant: 1),
            columStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            columStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            columStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            columStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
//            columStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
//            columStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
//            columStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
//            columStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
        ])
        
        contentWidthConstraint = columStack.widthAnchor.constraint(equalToConstant: viewPortWidth)
        contentWidthConstraint?.priority = UILayoutPriority(999)
        contentWidthConstraint?.isActive = true
        
//        contentHeightConstraint = columStack.heightAnchor.constraint(equalToConstant: viewPortWidth)
//        contentHeightConstraint?.priority = UILayoutPriority(999)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tap))
        contentView.isUserInteractionEnabled = true
        contentView.addGestureRecognizer(tap)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 0.3
        contentView.addGestureRecognizer(longPressGesture)
    }
    
    @objc
    private func tap() {
        controller?.action()
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            controller?.longPress?(gesture.view!, gesture.location(in: gesture.view))
        }
    }
    
    private func setupSize() {
        UIView.performWithoutAnimation { [self] in
            self.contentWidthConstraint?.constant = 280
//            self.contentHeightConstraint?.constant = 50
            self.contentHeightConstraint?.isActive = true
            self.setNeedsLayout()
        }
    }
}
