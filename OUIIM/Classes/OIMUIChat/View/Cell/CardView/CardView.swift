import ChatLayout
import Foundation
import OUICore

class CardView: UIView, ContainerCollectionViewCellDelegate {
    
    private var viewPortWidth: CGFloat = 300
    private var contentWidthConstraint: NSLayoutConstraint?
    private var contentHeightConstraint: NSLayoutConstraint?
    
    private lazy var avatarView: AvatarView = {
        let v = AvatarView()
        v.size = 56
        v.layer.cornerRadius = 28
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
    
    private lazy var IDLabel: UILabel = {
        let v = UILabel()
        v.text = "ID:"
        v.font = UIFont(name: "PingFangSC-Regular", size: 14)
        v.textColor = .init(hexString: "#666666")
        return v
    }()
    
    lazy var attentionLbl: UIButton = {
        let v = UIButton()
        v.setTitleColor(.white, for: .normal)
        v.setTitle("添加好友".localized(), for: .normal)
        v.titleLabel?.font = UIFont(name: "PingFangSC-Regular", size: 14)
        v.backgroundColor = .init(hexString: "#388CEF")
        v.contentEdgeInsets = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18)
        v.clipsToBounds = true
        v.layer.cornerRadius = 14
        return v
    }()
    
    
    
    private var controller: CardController!

    func reloadData() {
        guard let controller else {
            return
        }
        nameLabel.text = SuperStringUtil.getUserState(showname: controller.name ?? "").n
        self.IDLabel.text = "ID:" + (controller.userID ?? "")
        avatarView.setAvatar(url: controller.faceURL, text: controller.name)
    }
    
    func apply(_ layoutAttributes: ChatLayoutAttributes) {
        viewPortWidth = layoutAttributes.layoutFrame.width
        setupSize()
    }

    func setup(with controller: CardController) {
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
        
        
        let messageStack = UIStackView(arrangedSubviews: [nameLabel, IDLabel])
        messageStack.spacing = 8
        messageStack.alignment = .leading
        messageStack.axis = .vertical
        
        
        let infoStack = UIStackView(arrangedSubviews: [avatarView, messageStack, attentionLbl])
        infoStack.spacing = 8
        infoStack.alignment = .center
        
        let line = UIView()
        line.backgroundColor = .cE8EAEF
        
        let label = UILabel()
        label.text = "名片".innerLocalized()
        label.font = .systemFont(ofSize: 12)
        label.textColor = UIColor.c8E9AB0
        
//        let columStack = UIStackView(arrangedSubviews: [infoStack, line, label])
        let columStack = UIStackView(arrangedSubviews: [infoStack])
        columStack.spacing = 8
        columStack.axis = .vertical
        columStack.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(columStack)
        NSLayoutConstraint.activate([
            attentionLbl.heightAnchor.constraint(equalToConstant: 28),
            line.heightAnchor.constraint(equalToConstant: 1),
            columStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            columStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            columStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            columStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
//            columStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 21),
//            columStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
//            columStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -21),
//            columStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15),
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
//            self.contentWidthConstraint?.constant = self.viewPortWidth * StandardUI.maxWidthRate
            self.contentWidthConstraint?.constant = 280
//            self.contentHeightConstraint?.constant = 80
//            self.contentHeightConstraint?.constant = 76
//            self.contentHeightConstraint?.isActive = true
            self.setNeedsLayout()
        }
    }
}
