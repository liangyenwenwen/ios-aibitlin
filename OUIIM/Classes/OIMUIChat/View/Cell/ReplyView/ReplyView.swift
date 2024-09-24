
import ChatLayout
import Foundation
import UIKit
import OUICore

final class ReplyView: UIView, ContainerCollectionViewCellDelegate {

    private var viewPortWidth: CGFloat = 300

    private lazy var textView: MessageTextView = {
        let v = MessageTextView()
        v.layer.cornerRadius = 5
        v.layer.masksToBounds = true
        v.isEditable = false
        v.isSelectable = true
        v.isUserInteractionEnabled = true
        
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isScrollEnabled = false
        v.spellCheckingType = .no
        v.backgroundColor = .clear
        v.dataDetectorTypes = [.link]
        v.font = .f17
        v.scrollsToTop = false
        v.bounces = false
        v.bouncesZoom = false
        v.showsHorizontalScrollIndicator = false
        v.showsVerticalScrollIndicator = false
        v.isExclusiveTouch = true
        v.setContentCompressionResistancePriority(UILayoutPriority(999), for: .vertical)
        v.setContentHuggingPriority(UILayoutPriority(rawValue: 999), for: .horizontal)
        v.linkTextAttributes = [.foregroundColor: UIColor.systemBlue, .underlineStyle: 0]
        v.delegate = self
        v.textContainer.lineBreakMode = .byCharWrapping
        v.textContainer.lineFragmentPadding = 0
        v.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        
        return v
    }()
    
    private lazy var replyTextView: UITextView = {
        let v = UITextView()
        v.backgroundColor = .cF4F5F7
        
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isScrollEnabled = false
        v.isEditable = false
        v.isSelectable = false
        v.font = .f12
        v.scrollsToTop = false
        v.bounces = false
        v.textContainer.maximumNumberOfLines = 2
        v.setContentCompressionResistancePriority(UILayoutPriority(998), for: .vertical)
        v.setContentHuggingPriority(UILayoutPriority(rawValue: 999), for: .horizontal)
        v.linkTextAttributes = [.foregroundColor: UIColor.systemBlue, .underlineStyle: 0]
        v.delegate = self
        v.showsHorizontalScrollIndicator = false
        v.showsVerticalScrollIndicator = false
        v.textContainer.lineBreakMode = .byTruncatingTail
        v.textContainer.lineFragmentPadding = 0
        v.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        
        return v
    }()
    
    private lazy var playButtonImageView: UIImageView = {
        let v = UIImageView(image: UIImage(systemName: "play.circle"))
        v.tintColor = .white
        v.translatesAutoresizingMaskIntoConstraints = false
        v.widthAnchor.constraint(equalToConstant: 8).isActive = true
        v.heightAnchor.constraint(equalToConstant: 8).isActive = true
        
        return v
    }()
    
    private lazy var attachmentView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .cF4F5F7
        
        v.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        v.addGestureRecognizer(tap)
        
        return v
    }()
    
    private lazy var attachmentImageView: UIImageView = {
        let v = UIImageView()
        v.layer.cornerRadius = 6
        v.translatesAutoresizingMaskIntoConstraints = false
        v.widthAnchor.constraint(equalToConstant: 20).isActive = true
        v.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        return v
    }()
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        controller?.quoteMessageAction()
    }
    
    private lazy var textBlankView = UIView()
    
    private lazy var replyBlankView = UIView()
    
    private lazy var textStack: UIStackView = {
        let v = UIStackView(arrangedSubviews: [textView])
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    private lazy var replyStack: UIStackView = {
        let v = UIStackView(arrangedSubviews: [replyTextView])
        v.layer.masksToBounds = true
        v.layer.cornerRadius = 5
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()

    private var controller: ReplyViewController?

    private var textStackWidthConstraint: NSLayoutConstraint?

    private var replyStackWidthConstraint: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }

    func prepareForReuse() {
        textView.resignFirstResponder()
    }

    func apply(_ layoutAttributes: ChatLayoutAttributes) {
        viewPortWidth = layoutAttributes.layoutFrame.width
        setupSize()
    }

    func setup(with controller: ReplyViewController) {
        self.controller = controller
        attachmentImageView.tag = controller.messageID.hash
        reloadData()
    }

    func reloadData() {
        guard let controller else {
            return
        }
        
        controller.quoteAttributedString.addAttributes([.font: UIFont.f14, .foregroundColor: UIColor.c8E9AB0], range: NSMakeRange(0, controller.quoteAttributedString.length))
        replyTextView.attributedText = controller.quoteAttributedString
        
        attachmentImageView.image = controller.attachmentImage
        
        if controller.attachmentImage != nil {
            if !replyStack.arrangedSubviews.contains(attachmentView) {
                replyStack.addArrangedSubview(attachmentView)
            }
            attachmentView.isHidden = false
            playButtonImageView.isHidden = !controller.isVideo
        } else {
            if replyStack.arrangedSubviews.contains(attachmentView) {
                replyStack.removeArrangedSubview(attachmentView)
            }
            attachmentView.isHidden = true
        }
        
        // 保持各自的消息体长度
        if controller.type.isIncoming {
            textStack.removeArrangedSubview(textBlankView)
            replyStack.removeArrangedSubview(replyBlankView)
            
            textStack.addArrangedSubview(textBlankView)
            replyStack.addArrangedSubview(replyBlankView)
        } else {
            textStack.removeArrangedSubview(textBlankView)
            replyStack.removeArrangedSubview(replyBlankView)
            
            textStack.insertArrangedSubview(textBlankView, at: 0)
            replyStack.insertArrangedSubview(replyBlankView, at: 0)
        }
        
        textView.backgroundColor = controller.type.isIncoming ? .cF4F5F7 : .cCCE7FE
        
        if let attr = controller.attributedString {
            let re = NSMutableAttributedString(attributedString: attr)
            re.addAttributes([.font: UIFont.f17], range: NSMakeRange(0, attr.length))
            textView.attributedText = re
        } else {
            textView.text = controller.text != nil ? " \(controller.text!) " : nil
        }
    }
    
    private func setupSubviews() {
        layoutMargins = .zero
        translatesAutoresizingMaskIntoConstraints = false
        insetsLayoutMarginsFromSafeArea = false
        
        let stack = UIStackView(arrangedSubviews: [textStack, replyStack])
        stack.axis = .vertical
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        attachmentView.addSubview(attachmentImageView)
        attachmentView.addSubview(playButtonImageView)
        addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            stack.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
            
            attachmentImageView.topAnchor.constraint(equalTo: attachmentView.topAnchor, constant: 4),
            attachmentImageView.leadingAnchor.constraint(equalTo: attachmentView.leadingAnchor, constant: 4),
            attachmentImageView.trailingAnchor.constraint(equalTo: attachmentView.trailingAnchor, constant: -4),
            attachmentImageView.bottomAnchor.constraint(equalTo: attachmentView.bottomAnchor, constant: -4),
            
            playButtonImageView.centerYAnchor.constraint(equalTo: attachmentView.centerYAnchor),
            playButtonImageView.centerXAnchor.constraint(equalTo: attachmentView.centerXAnchor)
        ])
        
        textStackWidthConstraint = textView.widthAnchor.constraint(lessThanOrEqualToConstant: viewPortWidth)
        textStackWidthConstraint?.isActive = true
        
        replyStackWidthConstraint = replyTextView.widthAnchor.constraint(lessThanOrEqualToConstant: viewPortWidth)
        replyStackWidthConstraint?.isActive = true
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        textView.addGestureRecognizer(longPressGesture)
        
        isUserInteractionEnabled = true
        let longPressGesture2 = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        addGestureRecognizer(longPressGesture2)
        
        if let gestureRecognizers = textView.gestureRecognizers {
            for gesture in gestureRecognizers {
                gesture.require(toFail: longPressGesture)
                gesture.require(toFail: longPressGesture2)
            }
        }
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            controller?.longPress?(textView, gesture.location(in: textView))
        }
    }

    private func setupSize() {
        UIView.performWithoutAnimation { [self] in
            self.replyStackWidthConstraint?.constant = viewPortWidth * StandardUI.maxWidthRate
            self.textStackWidthConstraint?.constant = viewPortWidth * StandardUI.maxWidthRate
            setNeedsLayout()
        }
    }
}

extension ReplyView: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        
        if interaction == .presentActions || interaction == .preview {
            controller?.longPress?(self, CGPoint(x: self.frame.width - textView.frame.width / 2.0, y: 0))
            
            return false
        }
        
        if URL.absoluteString.hasPrefix("link://") {
            controller?.action(url: URL)
            
            return false
        }
        
        return true
    }

}

/// UITextView with hacks to avoid selection
private final class MessageTextView: UITextView {

    override var isFocused: Bool {
        false
    }

    override var canBecomeFirstResponder: Bool {
        false
    }

    override var canBecomeFocused: Bool {
        false
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        false
    }

}
