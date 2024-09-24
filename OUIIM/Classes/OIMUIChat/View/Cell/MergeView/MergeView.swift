
import ChatLayout
import Foundation
import LinkPresentation
import UIKit
import OUICore

final class MergeView: UIView, ContainerCollectionViewCellDelegate {
    
    private lazy var titleLabel: UILabel = {
        let v = UILabel()
        v.numberOfLines = 1
        v.font = .f17
        v.textColor = .c0C1C33
        v.contentMode = .center
        v.translatesAutoresizingMaskIntoConstraints = false
        v.setContentCompressionResistancePriority(UILayoutPriority(999), for: .vertical)
        
        return v
    }()
    
    private lazy var labelsStack: UIStackView = {
        let v = UIStackView()
        v.axis = .vertical
        v.spacing = 6
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    private lazy var contentStack: UIStackView = {
        
        let line = UIView()
        line.backgroundColor = .cE8EAEF
        line.translatesAutoresizingMaskIntoConstraints = false
        line.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        let v = UIStackView(arrangedSubviews: [UIView(), titleLabel, line, labelsStack])
        v.axis = .vertical
        v.spacing = 6
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    private var controller: MergeController?
    
    private var viewPortWidth: CGFloat = 300
    
    private var contentWidthConstraint: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func prepareForReuse() {
        labelsStack.arrangedSubviews.forEach({ labelsStack.removeArrangedSubview($0); $0.removeFromSuperview() })
    }
    
    func apply(_ layoutAttributes: ChatLayoutAttributes) {
        viewPortWidth = layoutAttributes.layoutFrame.width
        setupSize()
    }
    
    func reloadData() {
        titleLabel.text = controller?.title
        
        let labels = controller?.abstracts?.prefix(4).map({ text in
            let v = UILabel()
            v.numberOfLines = 3
            v.font = .f14
            v.textColor = .c8E9AB0
            v.lineBreakMode = .byTruncatingTail
            v.translatesAutoresizingMaskIntoConstraints = false
            v.setContentCompressionResistancePriority(UILayoutPriority(999), for: .vertical)
            v.text = text
            
            return v
        })
                
        labels?.forEach({ labelsStack.addArrangedSubview($0) })
        
        setupSize()
    }
    
    func setup(with controller: MergeController) {
        self.controller = controller
    }
    
    private func setupSubviews() {
        layoutMargins = .zero
        translatesAutoresizingMaskIntoConstraints = false
        insetsLayoutMarginsFromSafeArea = false
        
        let contentView = UIView()
        contentView.layer.cornerRadius = StandardUI.cornerRadius
        contentView.layer.borderColor = UIColor.cE8EAEF.cgColor
        contentView.layer.borderWidth = 1
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = .cellBackgroundColor
        contentView.isUserInteractionEnabled = true
        
        addSubview(contentView)
        contentView.addSubview(contentStack)
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            
            contentStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            contentStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            contentStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            contentStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8)
        ])
        
        contentWidthConstraint = contentStack.widthAnchor.constraint(equalToConstant: viewPortWidth)
        contentWidthConstraint!.priority = UILayoutPriority(999)
    
        isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(tap))
        addGestureRecognizer(tap)
        
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
        contentWidthConstraint?.constant = viewPortWidth * StandardUI.maxWidthRate
        contentWidthConstraint?.isActive = true
        
        setNeedsLayout()
    }
    
}
