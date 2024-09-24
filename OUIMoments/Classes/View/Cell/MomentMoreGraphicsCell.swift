
import Kingfisher
import OUICore
//import ZLPhotoBrowser
import IGListKit
import SnapKit

/// 多张图片显示
class MomentMoreGraphicsCell: UICollectionViewCell {
    
    var onClick: ((Int)->Void)?
    var onTapAvatar: ((String?) -> Void)?
    var onPreview: ((Int, [UIView]) -> Void)?
    
    fileprivate lazy var avatarView: AvatarView = {
        let v = AvatarView()
        return v
    }()
    
    fileprivate lazy var nameLabel: UILabel = {
        let v = UILabel()
        v.font = .f17
        return v
    }()
    
    fileprivate lazy var contentLabel: MomentLabel = {
        let v = MomentLabel()
        v.font = .f17
        v.numberOfLines = 0
        v.showFavor = {[weak self] in
            guard let self = self else { return }
        }
        return v
    }()
    
    fileprivate lazy var expandBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("展开".innerLocalized(), for: .normal)
        btn.setTitle("收起".innerLocalized(), for: .selected)
        btn.setTitleColor(.c0089FF, for: .normal)
        btn.titleLabel?.font = .f14
        btn.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
        btn.sizeToFit()
        btn.isHidden = true
        return btn
    }()
    
    fileprivate lazy var nineImageView: NineImageView = {
        let view = NineImageView(frame: .zero)
        view.onPreviewImages = { [weak self] images, indexPath, senders in
            self?.onPreview?(indexPath.item, senders)
        }
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .cellBackgroundColor
        
        let verSV = UIStackView(arrangedSubviews: [nameLabel, contentLabel, expandBtn, nineImageView])
        verSV.axis = .vertical
        verSV.spacing = 8
        verSV.alignment = .leading
        
        let horSV = UIStackView(arrangedSubviews: [avatarView, verSV])
        horSV.spacing = 8
        horSV.alignment = .top
        horSV.distribution = .fill
        
        contentView.addSubview(horSV)
        horSV.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview().inset(MomentPadding)
            make.bottom.equalToSuperview()
        }
        
        avatarView.snp.makeConstraints { make in
            make.size.equalTo(42)
        }
        setupLabel()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    var viewModel: MomentsInfo?
    
    func setupLabel() {
        contentLabel.enabledTypes = [.URL, .phone]
        contentLabel.handleURLTap { (text) in
            let url = URL(string: text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
        
        contentLabel.handlePhoneTap { (phone) in
            if let url = NSURL(string: "tel://\(phone)") as? URL {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    @objc func click(_ btn: UIButton) {
        onClick?(btn.tag)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nineImageView.images = []
        contentLabel.text = nil
    }
}

extension MomentMoreGraphicsCell: ListBindable {
    
    func bindViewModel(_ viewModel: Any) {
        guard let viewModel = viewModel as? MomentsInfo else { return }
        self.viewModel = viewModel
        
        avatarView.setAvatar(url: viewModel.faceURL, text: viewModel.nickname, onTap: { [weak self] in
            self?.onTapAvatar?(viewModel.faceURL)
        })
        
        if (viewModel.nickname.length > 0) {
            nameLabel.text = viewModel.nickname
        }
        
        if (viewModel.content != nil) {
            contentLabel.text = viewModel.content?.text
        }
        
        if viewModel.isNeedExpend {
            let isExpand = viewModel.isTextExpend ?? false
            expandBtn.isSelected = isExpand
            contentLabel.numberOfLines = isExpand ? 0 : 3
        }
        
        expandBtn.isHidden = !viewModel.isNeedExpend

        if viewModel.images.count > 0 {
            nineImageView.images = viewModel.images
            nineImageView.snp.remakeConstraints { make in
                make.height.equalTo(viewModel.momentPicsHeight(viewModel.images.count))
                make.width.equalTo(MomentContentWidth)
            }
        }
    }
}
