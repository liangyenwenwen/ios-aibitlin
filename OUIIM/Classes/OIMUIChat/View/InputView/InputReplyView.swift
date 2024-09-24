
import InputBarAccessoryView
import Foundation
import UIKit

class InputReplyView: UIView, InputItem {
    var inputBarAccessoryView: InputBarAccessoryView?
    
    var parentStackViewPosition: InputStackView.Position?
    
    func textViewDidChangeAction(with textView: InputTextView) {
        
    }
    
    func keyboardSwipeGestureAction(with gesture: UISwipeGestureRecognizer) {
        
    }
    
    func keyboardEditingEndsAction() {
        
    }
    
    func keyboardEditingBeginsAction() {
        
    }
    
    
//    func setSize(_ newValue: CGSize?, animated: Bool) {
//        size = newValue
//    }
//
//    private var size: CGSize? = CGSize(width: UIScreen.main.bounds.width, height: 30) {
//        didSet {
//            invalidateIntrinsicContentSize()
//        }
//    }
//    
//    open override var intrinsicContentSize: CGSize {
//        var contentSize = size ?? super.intrinsicContentSize
//        contentSize.height
//        return contentSize
//    }
//    
    lazy var textLabel: UILabel = {
        let v = UILabel()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.font = .systemFont(ofSize: 12)
        v.numberOfLines = 2
        v.textColor = .systemGray2
        
        return v
    }()
    
    lazy var removeButton: UIButton = {
        let v = UIButton(type: .custom)
        v.translatesAutoresizingMaskIntoConstraints = false
        v.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        v.tintColor = .systemGray
        
        return v
    }()
    
    init() {
        super.init(frame: .zero)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        let contentView = UIView()
        contentView.backgroundColor = .systemBackground
        contentView.layer.cornerRadius = 5
        contentView.layer.masksToBounds = true
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(contentView)
        
        let stack = UIStackView(arrangedSubviews: [textLabel, removeButton])
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        textLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        contentView.addSubview(stack)
        
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 2),
            stack.topAnchor.constraint(equalTo: contentView.topAnchor),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
}
