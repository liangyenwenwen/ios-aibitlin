//
//  YFCommonTemplateView.swift
//  Alamofire
//
//  Created by mac on 2025/4/8.
//

import Foundation
import OUICore
import ChatLayout
class YFCommonTemplateView: UIView, ContainerCollectionViewCellDelegate  {

    private var viewPortWidth: CGFloat = 280
    private var contentWidthConstraint: NSLayoutConstraint?
    private var contentHeightConstraint: NSLayoutConstraint?
    private lazy var headStack: UIStackView = {
        let v = UIStackView(arrangedSubviews: [logoImageView, titleLabel])
        v.spacing = 6
        v.axis = .horizontal
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    private lazy var logoImageView: UIImageView = {
        let v = UIImageView()
        return v
    }()
    private lazy var titleLabel: UILabel = {
        let v = UILabel()
        v.font = UIFont(name: "PingFangSC-Medium", size: 16)
        v.textColor = .init(hexString: "#333333")
        v.numberOfLines = 1
        return v
    }()
    private lazy var introLabel: UILabel = {
        let v = UILabel()
        v.font = UIFont(name: "PingFangSC-Regular", size: 14)
        v.textColor = .init(hexString: "#666666")
        v.numberOfLines = 0
        return v
    }()
    private lazy var redPacketView: UIView = {
        let v = UIView()
        v.corner(radius: 10)
        v.backgroundColor = .init(hexString: "#F25151")
        v.addSubview(redPacketIcon)
        v.addSubview(redPackeTitleLabel)
        v.addSubview(statusLabel)
        redPacketIcon.snp_makeConstraints { make in
            make.width.height.equalTo(56)
            make.centerY.equalToSuperview()
            make.left.equalTo(12)
        }
        redPackeTitleLabel.snp_makeConstraints { make in
            make.left.equalTo(redPacketIcon.snp_right).offset(13)
            make.top.equalTo(redPacketIcon.snp_top).offset(4)
            make.right.equalToSuperview().offset(-12)
            make.height.equalTo(22)
        }
        statusLabel.snp_makeConstraints { make in
            make.left.right.height.equalTo(redPackeTitleLabel)
            make.bottom.equalTo(redPacketIcon.snp_bottom).offset(-4)
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(clickRedPacketView))
        v.addGestureRecognizer(tap)
        return v
    }()
    
    
    private lazy var redPacketIcon: UIImageView = {
        let v = UIImageView()
        return v
    }()
    
    private lazy var redPackeTitleLabel: UILabel = {
        let v = UILabel()
        v.font = UIFont(name: "PingFangSC-Medium", size: 16)
        v.textColor = .white
        return v
    }()
    
    private lazy var statusLabel: UILabel = {
        let v = UILabel()
        v.font = UIFont(name: "PingFangSC-Regular", size: 14)
        v.textColor = .white
        v.numberOfLines = 1
        return v
    }()
    private lazy var longBtn: UIButton = {
        let v = UIButton(type: .custom)
        v.backgroundColor = .init(hexString: "#388CEF")
        v.setTitleColor(.white, for: .normal)
        v.titleLabel?.font = UIFont(name: "PingFangSC-Regular", size: 14)
        v.layer.cornerRadius = 16
        v.layer.masksToBounds = true
        v.addTarget(self, action: #selector(longBtnClick), for: .touchUpInside)
        return v
    }()
    private lazy var smallBtntack: UIStackView = {
        let v = UIStackView(arrangedSubviews: [leftBtn, rightBtn])
        v.spacing = 10
        v.axis = .horizontal
        v.distribution = .fillEqually
        v.alignment = .fill
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    private lazy var leftBtn: UIButton = {
        let v = UIButton(type: .custom)
        v.backgroundColor = .init(hexString: "#388CEF")
        v.setTitleColor(.white, for: .normal)
        v.titleLabel?.font = UIFont(name: "PingFangSC-Regular", size: 14)
        v.layer.cornerRadius = 16
        v.layer.masksToBounds = true
        v.addTarget(self, action: #selector(leftBtnClick), for: .touchUpInside)
        return v
    }()
    private lazy var rightBtn: UIButton = {
        let v = UIButton(type: .custom)
        v.backgroundColor = .init(hexString: "#388CEF")
        v.setTitleColor(.white, for: .normal)
        v.titleLabel?.font = UIFont(name: "PingFangSC-Regular", size: 14)
        v.layer.cornerRadius = 16
        v.layer.masksToBounds = true
        v.addTarget(self, action: #selector(rightBtnClick), for: .touchUpInside)
        return v
    }()
    private lazy var mediaView: UIView = {
        let v = UIView()
        v.corner(radius: 8)
        v.backgroundColor = .black
        v.addSubview(mediaImageView)
        v.addSubview(playImageView)
        mediaImageView.snp_makeConstraints { make in
            make.edges.equalToSuperview()
        }
        playImageView.snp_makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(44)
        }
        return v
    }()
    private lazy var mediaImageView: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFill
        return v
    }()
    private lazy var playImageView: UIImageView = {
        let v = UIImageView(image: UIImage(systemName: "play.circle")?.withRenderingMode(.alwaysTemplate))
        v.translatesAutoresizingMaskIntoConstraints = false
        v.tintColor = .white
        return v
    }()
    private lazy var remarkLabel: UILabel = {
        let v = UILabel()
        v.numberOfLines = 0
        v.font = UIFont(name: "PingFangSC-Medium", size: 16)
        v.textColor = .init(hexString: "#333333")
        v.numberOfLines = 0
        return v
    }()
    private lazy var contentView: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 10
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .init(hexString: "#EAEAEA")
        v.isUserInteractionEnabled = true
        return v
    }()
    
    private var controller: YFCommonTemplateController!
    
    func reloadData(messageSource:commonTemplateMessageSource) {
//        guard let controller else {
//            return
//        }
//        titleLabel.text = controller.instructions
//        if controller.redPacketStatus == 0{
//            //未领取
//            
//            if controller.source.redPacketType == 3{
//                //专属红包
//                statusLabel.text = "红包-" + controller.source.receiverName! + "专属"
//                if controller.source.receiverId == IMController.shared.uid || controller.source.sendUserId == IMController.shared.uid{
//                    contentView.backgroundColor = .init(hexString: "#F25151")
//                }else{
//                    contentView.backgroundColor = .init(hexString: "#FFA0A0")
//                }
//            }else{
//                statusLabel.text = "红包"
//                contentView.backgroundColor = .init(hexString: "#F25151")
//            }
//            
//        }else if controller.redPacketStatus == 1{
//            //已领取
//            statusLabel.text = "红包-已领取"
//            contentView.backgroundColor = .init(hexString: "#FFA0A0")
//        }else if controller.redPacketStatus == 2{
//            //已过期
//            statusLabel.text = "红包-已过期"
//            contentView.backgroundColor = .init(hexString: "#FFA0A0")
//        }else if controller.redPacketStatus == 3{
//            //已领完
//            statusLabel.text = "红包-已领完"
//            contentView.backgroundColor = .init(hexString: "#FFA0A0")
//        }
        logoImageView.setImageWithURLString(messageSource.logo ?? "", placeholder: UIImage(named: "launch_logo"))
        titleLabel.text = messageSource.title ?? ""
        if (messageSource.intro ?? "").length > 0{
            introLabel.isHidden = false
            introLabel.text = messageSource.intro
        }else{
            introLabel.isHidden = true
        }
        if messageSource.item != nil{
            redPacketView.isHidden = false
            redPackeTitleLabel.text = messageSource.item?.name
            statusLabel.text = messageSource.item?.intro
            redPacketIcon.setImageWithURLString(messageSource.item?.icon ?? "", placeholder: nil)
            redPacketView.backgroundColor = .init(hexString: (messageSource.item?.bg)!)
        }else{
            redPacketView.isHidden = false
        }
        if messageSource.bt != nil{
            if messageSource.bt?.long != nil{
                longBtn.isHidden = false
                longBtn.setTitle(messageSource.bt?.long?.name, for: .normal)
            }else{
                longBtn.isHidden = true
            }
            if messageSource.bt?.left != nil || messageSource.bt?.right != nil{
                smallBtntack.isHidden = false
                if messageSource.bt?.left != nil{
                    leftBtn.isHidden = false
                    leftBtn.setTitle(messageSource.bt?.left?.name, for: .normal)
                }else{
                    leftBtn.isHidden = true
                }
                if messageSource.bt?.right != nil{
                    rightBtn.isHidden = false
                    rightBtn.setTitle(messageSource.bt?.right?.name, for: .normal)
                }else{
                    rightBtn.isHidden = true
                }
            }else{
                smallBtntack.isHidden = true
            }
        }else{
            longBtn.isHidden = true
            smallBtntack.isHidden = true
        }
        if messageSource.media != nil{
            mediaView.isHidden = false
            mediaImageView.setImageWithURLString(messageSource.media?.media_url, placeholder: nil)
            if messageSource.media?.type == "video"{
                playImageView.isHidden = false
            }else{
                playImageView.isHidden = true
            }
        }else{
            mediaView.isHidden = true
        }
        if (messageSource.remark ?? "").length > 0 {
            remarkLabel.isHidden = false
            remarkLabel.text = messageSource.remark
        }else{
            remarkLabel.isHidden = true
        }
        
        
    }
    
    func apply(_ layoutAttributes: ChatLayoutAttributes) {
        viewPortWidth = layoutAttributes.layoutFrame.width
        setupSize()
    }

    func setup(with controller: YFCommonTemplateController) {
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
        
        addSubview(contentView)
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            contentView.widthAnchor.constraint(equalToConstant: 280),
        ])
        
        let contentStack = UIStackView(arrangedSubviews:[headStack,introLabel,redPacketView,longBtn,smallBtntack,mediaView,remarkLabel])
        contentStack.spacing = 12
        contentStack.axis = .vertical
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            contentStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            contentStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            contentStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            contentStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            logoImageView.heightAnchor.constraint(equalToConstant: 24),
            logoImageView.widthAnchor.constraint(equalToConstant: 24),
            redPacketView.heightAnchor.constraint(equalToConstant: 76),
            longBtn.heightAnchor.constraint(equalToConstant: 32),
            leftBtn.heightAnchor.constraint(equalToConstant: 32),
            rightBtn.heightAnchor.constraint(equalToConstant: 32),
            mediaView.heightAnchor.constraint(equalToConstant: 162)
        ])
        
        contentWidthConstraint = contentStack.widthAnchor.constraint(equalToConstant: viewPortWidth)
        contentWidthConstraint?.priority = UILayoutPriority(999)
        contentWidthConstraint?.isActive = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tap))
        contentView.isUserInteractionEnabled = true
        contentView.addGestureRecognizer(tap)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 0.3
        contentView.addGestureRecognizer(longPressGesture)
    }
    
    @objc private func tap() {
        controller?.action(type: "base")
    }
    //点击
    @objc private func clickRedPacketView() {
        controller?.action(type: "item")
    }
    //这里是长按钮
    @objc private func longBtnClick() {
        controller?.action(type: "longBtn")
    }
    //这里是短按钮1
    @objc private func leftBtnClick() {
        controller?.action(type: "leftBtn")
    }
    //这里是短按钮2
    @objc private func rightBtnClick() {
        controller?.action(type: "rightBtn")
    }
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            controller?.longPress?(gesture.view!, gesture.location(in: gesture.view))
        }
    }
    
    private func setupSize() {
        UIView.performWithoutAnimation { [self] in
            self.contentWidthConstraint?.constant = 280
//            self.contentHeightConstraint?.constant = 76

//            self.contentHeightConstraint?.isActive = true
            self.setNeedsLayout()
        }
    }
}
