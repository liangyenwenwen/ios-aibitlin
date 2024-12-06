//
//  YFRedPacketView.swift
//  Alamofire
//
//  Created by mac on 2024/12/4.
//

import Foundation
import OUICore
import ChatLayout

// MARK: - 张亚飞打的标记  自定义消息 boke

class YFRedPacketView: UIView, ContainerCollectionViewCellDelegate  {

    private var viewPortWidth: CGFloat = 280
    private var contentWidthConstraint: NSLayoutConstraint?
    private var contentHeightConstraint: NSLayoutConstraint?
    
    private lazy var redPacketIcon: UIImageView = {
        let v = UIImageView(image: UIImage(named: "mine_red_packet_log_icon"))
        return v
    }()
    
    private lazy var titleLabel: UILabel = {
        let v = UILabel()
        v.font = UIFont(name: "PingFangSC-Medium", size: 16)
        v.textColor = .white
        v.text = "恭喜发财，大吉大利"
        return v
    }()
    
    private lazy var statusLabel: UILabel = {
        let v = UILabel()
        v.font = UIFont(name: "PingFangSC-Regular", size: 14)
        v.textColor = .white
        v.text = "红包"
        v.numberOfLines = 1
        return v
    }()
    private lazy var contentView: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 10
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .init(hexString: "#F25151")
        v.isUserInteractionEnabled = true
        return v
    }()
    
    private var controller: YFRedPacketController!
    
    func reloadData() {
        guard let controller else {
            return
        }
        titleLabel.text = controller.instructions
        if controller.redPacketStatus == 0{
            //未领取
            if controller.source.redPacketType == 3{
                //专属红包
                statusLabel.text = "红包-" + controller.source.receiverName! + "专属"
            }else{
                statusLabel.text = "红包"
            }
            if controller.source.receiverId == IMController.shared.uid || controller.source.sendUserId == IMController.shared.uid{
                contentView.backgroundColor = .init(hexString: "#F25151")
            }else{
                contentView.backgroundColor = .init(hexString: "#FFA0A0")
            }
            
        }else if controller.redPacketStatus == 1{
            //已领取
            statusLabel.text = "红包-已领取"
            contentView.backgroundColor = .init(hexString: "#FFA0A0")
        }else if controller.redPacketStatus == 2{
            //已过期
            statusLabel.text = "红包-已过期"
            contentView.backgroundColor = .init(hexString: "#FFA0A0")
        }else if controller.redPacketStatus == 3{
            //已领完
            statusLabel.text = "红包-已领完"
            contentView.backgroundColor = .init(hexString: "#FFA0A0")
        }
    }
    
    func apply(_ layoutAttributes: ChatLayoutAttributes) {
        viewPortWidth = layoutAttributes.layoutFrame.width
        setupSize()
    }

    func setup(with controller: YFRedPacketController) {
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
        
        let messageStack = UIStackView(arrangedSubviews: [titleLabel, statusLabel])
        messageStack.spacing = 5
        messageStack.axis = .vertical
        messageStack.translatesAutoresizingMaskIntoConstraints = false
        
        
        let infoStack = UIStackView(arrangedSubviews: [redPacketIcon, messageStack])
        infoStack.spacing = 12
        infoStack.alignment = .center
        
        

    
        
        let columStack = UIStackView(arrangedSubviews: [infoStack])
        columStack.spacing = 8
        columStack.axis = .vertical
        columStack.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(columStack)
        NSLayoutConstraint.activate([
            columStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            columStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            columStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            columStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            redPacketIcon.widthAnchor.constraint(equalToConstant: 56),
            redPacketIcon.heightAnchor.constraint(equalToConstant: 56),

        ])
        
        contentWidthConstraint = columStack.widthAnchor.constraint(equalToConstant: viewPortWidth)
        contentWidthConstraint?.priority = UILayoutPriority(999)
        contentWidthConstraint?.isActive = true
        
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
            self.contentHeightConstraint?.constant = 76

//            self.contentHeightConstraint?.isActive = true
            self.setNeedsLayout()
        }
    }
}
