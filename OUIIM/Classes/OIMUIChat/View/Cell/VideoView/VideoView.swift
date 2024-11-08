
import ChatLayout
import Foundation
import UIKit
import OUICore

final class VideoView: UIView, ContainerCollectionViewCellDelegate {
    
    private lazy var stackView = UIStackView(frame: bounds)
        
    public lazy var imageView = UIImageView(frame: bounds)
    
    private lazy var playImageView = UIImageView(image: UIImage(systemName: "play.circle")?.withRenderingMode(.alwaysTemplate))
    
    private var controller: VideoController!
    
    private var imageWidthConstraint: NSLayoutConstraint?
    
    private var imageHeightConstraint: NSLayoutConstraint?
    
    private var viewPortWidth: CGFloat = 300
    
    private var imageMaxWidth = 120.0.w
    
    private lazy var durationLabel: UILabel = {
        let v = UILabel()
        v.backgroundColor = .clear
        v.textColor = .white
        v.translatesAutoresizingMaskIntoConstraints = false
        v.font = .f12
        
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }
    
    func prepareForReuse() {
        imageView.cancelDownload()
    }
    
    func apply(_ layoutAttributes: ChatLayoutAttributes) {
        viewPortWidth = layoutAttributes.layoutFrame.width
        setupSize()
    }
    
    func setup(with controller: VideoController) {
        self.controller = controller
        imageView.tag = controller.messageId.hash
    }
    
    func reloadData() {
        durationLabel.text = controller.duration
        
        if controller.image != nil {
            imageView.image = controller.image
            imageView.contentMode = .scaleAspectFill
        } else {
            if controller.source.thumb?.url == nil{
                imageView.contentMode = .scaleAspectFit
                imageView.image =  UIImage(nameInBundle:"common_image_placeholder")
            }else{
                imageView.contentMode = .scaleAspectFill
                imageView.setImage(url: controller.source.source.url, thumbURL: controller.source.thumb?.url)
            }
            
        }
        
    }
    
    private func setupSubviews() {
        layoutMargins = .zero
        translatesAutoresizingMaskIntoConstraints = false
        insetsLayoutMarginsFromSafeArea = false
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .init(hexString: "#F6F8F8")
        
        stackView.addArrangedSubview(imageView)
        
        imageView.addSubview(playImageView)
        playImageView.translatesAutoresizingMaskIntoConstraints = false
        playImageView.tintColor = .white
        
        imageView.addSubview(durationLabel)
    
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),

            playImageView.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            playImageView.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            playImageView.widthAnchor.constraint(equalToConstant: 44),
            playImageView.heightAnchor.constraint(equalToConstant: 44),
            
            durationLabel.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -4),
            durationLabel.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -4)
        ])
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tap))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tap)
        
        imageWidthConstraint = imageView.widthAnchor.constraint(equalToConstant: imageMaxWidth)
        imageWidthConstraint?.priority = UILayoutPriority(999)
        
        imageHeightConstraint = imageView.heightAnchor.constraint(equalToConstant: imageMaxWidth)
        imageHeightConstraint?.priority = UILayoutPriority(999)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 0.3
        imageView.addGestureRecognizer(longPressGesture)
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
        var width = 0.0
        var height = 0.0
        
        if (imageMaxWidth > controller.size.width) {
            width = controller.size.width
            height = controller.size.height
        } else {
            width = imageMaxWidth;
            height = width * controller.size.height / controller.size.width;
        }
        
        imageWidthConstraint?.constant = width
        imageHeightConstraint?.constant = height
        imageWidthConstraint?.isActive = true
        imageHeightConstraint?.isActive = true

        setNeedsLayout()
    }
}
