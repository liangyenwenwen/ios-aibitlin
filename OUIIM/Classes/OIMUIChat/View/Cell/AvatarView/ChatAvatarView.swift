
import ChatLayout
import Foundation
import UIKit
import OUICore

final class AvatarPlaceholderView: UIView, StaticViewFactory {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }

    private func setupSubviews() {
        translatesAutoresizingMaskIntoConstraints = false
        insetsLayoutMarginsFromSafeArea = false
        layoutMargins = .zero
        let constraint = widthAnchor.constraint(equalToConstant: StandardUI.avatarWidth)
        constraint.priority = UILayoutPriority(rawValue: 999)
        constraint.isActive = true
        heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true
    }
}

final class ChatAvatarView: UIView, StaticViewFactory {

    private lazy var avatarView = RoundedCornersContainerView<AvatarView>(frame: bounds)

    private var controller: AvatarViewController?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }

    func reloadData() {
        guard let controller else { return }

        avatarView.customView.setAvatar(url: controller.faceURL, text: controller.name) { [weak controller] in
            controller?.action()
        } onLongPress: { [weak controller] in
            controller?.longPress()
        }
    }

    func setup(with controller: AvatarViewController) {
        self.controller = controller
    }

    private func setupSubviews() {
        translatesAutoresizingMaskIntoConstraints = false
        insetsLayoutMarginsFromSafeArea = false
        layoutMargins = .zero
        addSubview(avatarView)
        backgroundColor = .clear
        
        avatarView.customView.clipsToBounds = true
        avatarView.customView.size = 48.w
        avatarView.customView.layer.cornerRadius = 24.w
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            avatarView.leadingAnchor.constraint(equalTo: leadingAnchor),
            avatarView.trailingAnchor.constraint(equalTo: trailingAnchor),
            avatarView.topAnchor.constraint(equalTo: topAnchor),
            avatarView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}
