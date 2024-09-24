
import ChatLayout
import Foundation
import UIKit
import OUICore

class TextMessageView: UIView, ContainerCollectionViewCellDelegate {

    private lazy var textView: MessageTextView = {
        let v = MessageTextView()
        
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isScrollEnabled = false
        v.isEditable = false
        v.isSelectable = true
        
        v.backgroundColor = .clear
        v.dataDetectorTypes = [.link]
        v.font = .f17
        v.scrollsToTop = false
        v.bounces = false
        v.bouncesZoom = false
        v.delegate = self
        v.linkTextAttributes = [.foregroundColor: UIColor.systemBlue, .underlineStyle: 0]
        v.textColor = .c0C1C33
        v.setContentCompressionResistancePriority(UILayoutPriority(999), for: .vertical)
        v.setContentHuggingPriority(UILayoutPriority(rawValue: 999), for: .horizontal)
        v.textContainer.lineBreakMode = .byCharWrapping
        v.textContainerInset = UIEdgeInsets(top: 9, left: 12, bottom: 9, right: 12)
//        v.widthAnchor.constraint(greaterThanOrEqualToConstant: 45)
        v.textContainer.lineFragmentPadding = 0
        v.text = " "
        
        v.clipsToBounds = true
        v.layer.cornerRadius = 20
        return v
    }()

    private var controller: TextMessageController?

    private var textViewWidthConstraint: NSLayoutConstraint?
    
    internal var viewPortWidth: CGFloat = 300

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }

    func apply(_ layoutAttributes: ChatLayoutAttributes) {
        viewPortWidth = layoutAttributes.layoutFrame.width
        setupSize()
    }

    func setup(with controller: TextMessageController) {
        self.controller = controller
        reloadData()
    }
    
    func prepareForReuse() {
        textView.attributedText = nil
        textView.text = nil
    }
    
    // MARK: - 张亚飞打的标记  文本信息  需要加翻译
    func reloadData() {
        guard let controller else {
            return
        }
        UIView.performWithoutAnimation {
            if controller.text != nil {
//                let result = controller.type ==  .outgoing  ?  "\(controller.text!)" : "\(controller.text!) \n哈哈哈"
//                textView.attributedText = NSAttributedString(string: result, attributes: [.foregroundColor: UIColor.c0C1C33, .font: UIFont.f17])
                
                var ishave = false
                if controller.messageEx != nil {
                    print("\n\n\n\n\n\n\n\n")
                    print(controller.messageEx)
                    ishave = true
                }
                
//                let isHave = UserDefaults.standard.value(forKey: controller.userID) as? Bool
                                
                if ishave && controller.type == .incoming  && !controller.messageEx!.starts(with: "translate##") {
                    isNeedtrans()
                } else {
                    textView.attributedText = NSAttributedString(string: "\(controller.text!)", attributes: [.foregroundColor: UIColor.c0C1C33,
                        .font: UIFont.f17])
                }
                
//                if controller.type == .incoming {
//                    isNeedtrans()
//                } else {
//                    textView.attributedText = NSAttributedString(string: "\(controller.text!)", attributes: [.foregroundColor: UIColor.c0C1C33,
//                        .font: UIFont.f17])
//                }
               
            } else {
                let attr = NSMutableAttributedString(attributedString: controller.attributedString!)
                attr.addAttributes([.font: UIFont.f17], range: NSMakeRange(0, controller.attributedString!.length))
                textView.attributedText = attr
            }
            
            
        }
        
        if controller.highlight {
            UIView.animate(withDuration: 1, animations: { [self] in
                self.textView.backgroundColor = .systemRed
            }) { _ in
                UIView.animate(withDuration: 1) { [self] in
                    self.textView.backgroundColor = .clear
                }
            }
        }
        
        textView.textColor = controller.type == .incoming ? .init(hexString: "#333333") : .white
        textView.backgroundColor = controller.type == .incoming ? .init(hexString: "#EAEAEA") : .init(hexString: "#388CEF")
    }
    
    
    ///待翻译文本
    func isNeedtrans() {
        
        let textAttrStr = NSMutableAttributedString()
        
        //添加图标
        var attachment = NSTextAttachment()
        attachment.image = .init(named: "translate_text_icon")
        attachment.bounds = CGRect(x: 0, y: 0, width: 16, height: 16)
        let imageStr = NSAttributedString(attachment: attachment)
        textAttrStr.append(imageStr)
        
        //添加翻译文本
//        let transText = NSAttributedString(string: "\("Translation function is under development".localized())\n", attributes: [.foregroundColor: UIColor.c0C1C33,
//                                                                                    .font: UIFont.f17])
        let translateStr = controller!.messageEx!
        let transText = NSAttributedString(string: "\(translateStr)\n", attributes: [.foregroundColor: UIColor.c0C1C33,
                                                                                    .font: UIFont.f17])
        textAttrStr.append(transText)
        //添加正式文本
        let messageText = NSAttributedString(string: "\(controller!.text!)", attributes: [.foregroundColor: UIColor.c333333,
            .font: UIFont.f14])
        textAttrStr.append(messageText)
        
        
        self.textView.attributedText = textAttrStr
        
    }
    
    
    

    private func setupSubviews() {
        layoutMargins = .zero
        translatesAutoresizingMaskIntoConstraints = false
        insetsLayoutMarginsFromSafeArea = false
        
        let hStack = UIStackView(arrangedSubviews: [textView])
        hStack.alignment = .center
        hStack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(hStack)
        NSLayoutConstraint.activate([
            hStack.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            hStack.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
            hStack.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            hStack.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor)
        ])
        textViewWidthConstraint = textView.widthAnchor.constraint(lessThanOrEqualToConstant: viewPortWidth)
        
        //文本最低长度添加
        textView.snp.makeConstraints { make in
            make.width.greaterThanOrEqualTo(41)
        }
//        textViewWidthConstraint = textView.widthAnchor.constraint(greaterThanOrEqualToConstant: 45)
        textViewWidthConstraint?.isActive = true
        textView.heightAnchor.constraint(greaterThanOrEqualToConstant: 30).isActive = true
            
        // This solution works but beware that it's gonna disable the textView interactions, so the links won't be highlighted when pressed and the text won't be selectable.
//        if let actualRecognizers = textView.gestureRecognizers {
//            for recognizer in actualRecognizers {
//                if recognizer.isKind(of: UILongPressGestureRecognizer.self) {
//                    recognizer.isEnabled = false
//                }
//            }
//        }
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 0.3
        textView.addGestureRecognizer(longPressGesture)
        
        if let gestureRecognizers = textView.gestureRecognizers {
            for gesture in gestureRecognizers {
                gesture.require(toFail: longPressGesture)
            }
        }
        
//        textView.backgroundColor = .white
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            controller?.longPress?(self, gesture.location(in: self))
        }
    }

    private func setupSize() {
        UIView.performWithoutAnimation { [self] in
            self.textViewWidthConstraint?.constant = viewPortWidth * StandardUI.maxWidthRate
            setNeedsLayout()
        }
    }
}

extension TextMessageView: UITextViewDelegate {
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
