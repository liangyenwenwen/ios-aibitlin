
import ChatLayout
import Foundation
import UIKit
import OUICore

final class CustomView: UIView, ContainerCollectionViewCellDelegate {

    private var viewPortWidth: CGFloat = 300

    private lazy var textView: UITextView = {
        let v = UITextView()
        v.layer.cornerRadius = 20
        v.layer.masksToBounds = true
        
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isScrollEnabled = false
        v.isEditable = false
        v.spellCheckingType = .no
        v.backgroundColor = .clear
        v.dataDetectorTypes = .link
        v.font = .f17
        v.scrollsToTop = false
        v.bounces = false
        v.bouncesZoom = false
        v.showsHorizontalScrollIndicator = false
        v.showsVerticalScrollIndicator = false
        v.isExclusiveTouch = true
        v.isUserInteractionEnabled = false
        v.textContainer.lineBreakMode = .byCharWrapping
        v.textColor = .c0C1C33
        v.linkTextAttributes = [.foregroundColor: UIColor.systemBlue,
                                       .underlineStyle: 0]
        v.setContentCompressionResistancePriority(UILayoutPriority(999), for: .vertical)
        v.textContainerInset = UIEdgeInsets(top: 10, left: 8, bottom: 10, right: 12)
        return v
    }()

    private var controller: CustomViewController?

    private var textViewWidthConstraint: NSLayoutConstraint?

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

    public override func layoutSubviews() {
        super.layoutSubviews()
    }

    func setup(with controller: CustomViewController) {
        self.controller = controller
        reloadData()
    }

    func reloadData() {
        guard let controller else {
            return
        }
        if controller.text != nil {
            textView.text = controller.text
        } else {
            textView.attributedText = controller.attributedString
        }
        
        
        backgroundColor = controller.messageType == .incoming ? .init(hexString: "#EAEAEA") : .init(hexString: "#388CEF")
        
        if controller.highlight {
            UIView.animate(withDuration: 1, animations: { [self] in
                self.textView.backgroundColor = .systemRed
            }) { _ in
                UIView.animate(withDuration: 1) { [self] in
                    self.textView.backgroundColor = .clear
                }
            }
        }
        
        
        
    }

    private func setupSubviews() {
        layoutMargins = .zero
        translatesAutoresizingMaskIntoConstraints = false
        insetsLayoutMarginsFromSafeArea = false
        
        addSubview(textView)
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            textView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
            textView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor)
        ])
        textViewWidthConstraint = textView.widthAnchor.constraint(lessThanOrEqualToConstant: viewPortWidth)
        textViewWidthConstraint?.isActive = true
        
        isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(tap))
        addGestureRecognizer(tap)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGesture.delegate = self
        longPressGesture.minimumPressDuration = 0.3
        textView.addGestureRecognizer(longPressGesture)
        
//        textView.backgroundColor = .orange
//        backgroundColor = .red
        clipsToBounds = true
        layer.cornerRadius = 20
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
        UIView.performWithoutAnimation {
            self.textViewWidthConstraint?.constant = viewPortWidth * StandardUI.maxWidthRate
            setNeedsLayout()
        }
    }

}

extension CustomView: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isKind(of: UILongPressGestureRecognizer.self) ||
            NSStringFromClass(type(of: otherGestureRecognizer)) == "UITextTapRecognizer" {
            
            return false
        }
        
        return true
    }
}
