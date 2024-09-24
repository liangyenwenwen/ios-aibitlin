
import ChatLayout
import Foundation
import UIKit
import OUICore

final class EditingBottomTipsView: UIView, StaticViewFactory {
    public lazy var tipsLabel: UILabel = {
        let v = UILabel()
        v.font = UIFont.f14
        v.textColor = UIColor.c8E9AB0
        v.text = "无法在已退出的群聊中发送消息".innerLocalized()

        return v
    }()
    
    lazy var tipsIcon: UIImageView = {
        let v = UIImageView(image: UIImage(systemName: "exclamationmark.shield"))
        v.tintColor = UIColor.c8E9AB0
        
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        backgroundColor = UIColor.cE8EAEF
        translatesAutoresizingMaskIntoConstraints = false
        
        let hStack = UIStackView(arrangedSubviews: [tipsIcon, tipsLabel])
        hStack.alignment = .center
        hStack.spacing = 8
        hStack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(hStack)
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 64),
            hStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            hStack.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
}

final class EditingBottomView: UIView, StaticViewFactory {
    
    private var controller: EditingBottomController!
    
    private let textView = UITextView(frame: .zero)
    
    private lazy var deleteButton: UIButton = {
        let v = UIButton(type: .system)
        v.setImage(UIImage(nameInBundle: "delete_button_icon"), for: .normal)
        v.addTarget(self, action: #selector(deleteButtonTap), for: .touchUpInside)
        v.layer.cornerRadius = 5
        v.backgroundColor = .cellBackgroundColor
        v.tintColor = .red

        return v
    }()
    
    private lazy var forwardButton: UIButton = {
        let v = UIButton(type: .system)
        v.setImage(UIImage(nameInBundle: "forward_button_icon"), for: .normal)
        v.addTarget(self, action: #selector(forwardButtonTap), for: .touchUpInside)
        v.layer.cornerRadius = 5
        v.backgroundColor = .cellBackgroundColor
        v.tintColor = .c0C1C33

        return v
    }()
    
    init(controller: EditingBottomController) {
        super.init(frame: .zero)
        self.controller = controller
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        backgroundColor = .secondarySystemBackground
        translatesAutoresizingMaskIntoConstraints = false
        
        let line = UIView()
        line.backgroundColor = .systemGray5
        line.translatesAutoresizingMaskIntoConstraints = false
        
        let space = UIView()
        space.backgroundColor = .clear
        
        let deleteLabel = UILabel()
        deleteLabel.text = "删除".innerLocalized()
        deleteLabel.textColor = .c0C1C33
        deleteLabel.font = .f10
        
        let deleteStack = UIStackView(arrangedSubviews: [deleteButton, deleteLabel])
        deleteStack.axis = .vertical
        deleteStack.spacing = 4
        deleteStack.alignment = .center
        
        let forwardLabel = UILabel()
        forwardLabel.text = "合并转发".innerLocalized()
        forwardLabel.textColor = .c0C1C33
        forwardLabel.font = .f10
        
        let forwardStack = UIStackView(arrangedSubviews: [forwardButton, forwardLabel])
        forwardStack.axis = .vertical
        forwardStack.spacing = 4
        forwardStack.alignment = .center
        
        let stack = UIStackView(arrangedSubviews: [UIView(), deleteStack, UIView(), forwardStack, UIView()])
        stack.distribution = .fillEqually
        stack.alignment = .center
        
        let horStack = UIStackView(arrangedSubviews: [line, stack])
        horStack.axis = .vertical
        horStack.alignment = .fill
        horStack.distribution = .fill
        horStack.spacing = 12
        
        horStack.translatesAutoresizingMaskIntoConstraints = false
        
        let horSpacer = UIView()
        horSpacer.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(horSpacer)
        addSubview(horStack)
        NSLayoutConstraint.activate([
            deleteButton.widthAnchor.constraint(equalToConstant: 48),
            forwardButton.widthAnchor.constraint(equalToConstant: 48),
            deleteButton.heightAnchor.constraint(equalToConstant: 48),
            forwardButton.heightAnchor.constraint(equalToConstant: 48),
            
            horStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            horStack.topAnchor.constraint(equalTo: topAnchor),
            horStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            line.heightAnchor.constraint(equalToConstant: 1),
            
            horSpacer.heightAnchor.constraint(equalToConstant: UIApplication.safeAreaInsets.bottom),
            horSpacer.topAnchor.constraint(equalTo: horStack.bottomAnchor),
            horSpacer.leadingAnchor.constraint(equalTo: leadingAnchor),
            horSpacer.trailingAnchor.constraint(equalTo: trailingAnchor),
            horSpacer.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: self.bounds.width, height: 88)
    }

    @objc
    func deleteButtonTap() {
        controller.deleteAction()
    }
    
    @objc
    func forwardButtonTap() {
        controller.forwardAction()
    }
}
