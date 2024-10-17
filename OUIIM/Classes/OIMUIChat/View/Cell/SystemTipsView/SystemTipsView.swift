
import ChatLayout
import Foundation
import UIKit
import OUICore

class SystemTipsView: UIView, StaticViewFactory, ContainerCollectionViewCellDelegate {

    private lazy var textView: MessageTextView = {
        let v = MessageTextView()
        
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isScrollEnabled = false
        v.isEditable = false
        v.backgroundColor = .clear
        v.textContainerInset = UIEdgeInsets(top: 4, left: 6, bottom: 4, right: 6)
        v.textContainer.lineFragmentPadding = 0
        v.textAlignment = .center
        v.delegate = self
        v.linkTextAttributes = [.foregroundColor: UIColor.systemBlue, .underlineStyle: 0]
        v.textColor = .c8E9AB0
        v.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        v.layer.cornerRadius = 4
        
        return v
    }()

    private var controller: SystemTipsViewController?

    private var viewPortWidth: CGFloat = 300
    
    private var contentWidthConstraint: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }
    
    func apply(_ layoutAttributes: ChatLayoutAttributes) {
        
        if controller != nil && controller!.needHide {
            return
        }
        
        setupSize()
        
    }

    func setup(with controller: SystemTipsViewController) {
        self.controller = controller
        reloadData()
    }
    
    func prepareForReuse() {
        textView.attributedText = nil
        textView.text = nil
    }

    func reloadData() {
        guard let controller else {
            return
        }
        
        textView.backgroundColor = controller.enableBackgroundColor ? .cF4F5F7 : .clear
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        UIView.performWithoutAnimation {
            if controller.text != nil {
                textView.text = controller.text!
                // 重用cell以后会导致attributedText一直有值
                textView.attributedText = NSAttributedString(string: controller.text!, attributes: [.foregroundColor: UIColor.c8E9AB0,
                    .font: UIFont.f12,
                    .paragraphStyle: paragraphStyle])
            } else {
                let attr = NSMutableAttributedString(attributedString: controller.attributedString!)
                attr.addAttributes([.font: UIFont.f12,
                    .paragraphStyle: paragraphStyle], range: NSMakeRange(0, attr.length))
                textView.attributedText = attr
            }
        }
        
//        if controller.needHide {
//            textView.isHidden = true
//            textView.text = ""
//        }
    }

    private func setupSubviews() {
        layoutMargins = .zero
        translatesAutoresizingMaskIntoConstraints = false
        insetsLayoutMarginsFromSafeArea = false
        
        let spacer1 = UIView()
        spacer1.translatesAutoresizingMaskIntoConstraints = false
        
        let spacer2 = UIView()
        spacer2.translatesAutoresizingMaskIntoConstraints = false
        
        let stack = UIStackView(arrangedSubviews: [spacer1, textView, spacer2])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.alignment = .center
        
        addSubview(stack)
        NSLayoutConstraint.activate([
            spacer1.widthAnchor.constraint(equalTo: spacer2.widthAnchor, multiplier: 1),
            stack.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            stack.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
        ])
        
        contentWidthConstraint = stack.widthAnchor.constraint(equalToConstant: viewPortWidth)
        contentWidthConstraint?.priority = UILayoutPriority(999)
    }

    private func setupSize() {
        UIView.performWithoutAnimation { [self] in
            self.contentWidthConstraint?.constant = self.viewPortWidth
            self.contentWidthConstraint?.isActive = true
        }
    }
}

extension SystemTipsView: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if URL.absoluteString.hasPrefix(linkSchme) ||
            URL.absoluteString.hasPrefix(reEditSchme) ||
            URL.absoluteString.hasPrefix(sendFriendReqSchme) {
            print("\(#function):\(URL)")
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

extension MessageTextView: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isKind(of: UILongPressGestureRecognizer.self) ||
            NSStringFromClass(type(of: otherGestureRecognizer)) == "UITextTapRecognizer" {
            
            return false
        }
        
        return true
    }
}
