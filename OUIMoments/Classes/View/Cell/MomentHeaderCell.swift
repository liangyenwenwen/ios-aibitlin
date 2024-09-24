
import OUICore
import IGListKit
import SnapKit

/// 顶部视图
class MomentHeaderCell: UICollectionViewCell {
    
    var onTap: ((_ action: MomentAction) -> Void)?
    
    fileprivate lazy var bgImageView: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFill
        v.layer.masksToBounds = true
        v.image = UIImage(nameInBundle: "moments_header_bg")
        
        return v
    }()
    
    lazy var avatarImageView: AvatarView = {
        let v = AvatarView()
        return v
    }()
    
    lazy var userNameLabel: UILabel = {
        let v = UILabel()
        v.textAlignment = .right
        v.textColor = .white
        v.font = .systemFont(ofSize: 18)
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(bgImageView)
        bgImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.addSubview(avatarImageView)
        avatarImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(MomentPadding)
            make.bottom.equalToSuperview().inset(24)
        }
        
        contentView.addSubview(userNameLabel)
        userNameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(avatarImageView)
            make.leading.equalTo(avatarImageView.snp.trailing).offset(8)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

extension MomentHeaderCell: ListBindable {
    
    func bindViewModel(_ viewModel: Any) {
        guard let viewModel = viewModel as? HeaderInfo else {
            return
        }
        
        bgImageView.setImage(with: viewModel.backgroundURL, placeHolder: "moments_header_bg")
        avatarImageView.setAvatar(url: viewModel.faceURL, text: viewModel.userName, fullText: true, onTap: { [weak self] in
            self?.onTap?(.avatar)
        })
        userNameLabel.text = viewModel.userName
    }
}
