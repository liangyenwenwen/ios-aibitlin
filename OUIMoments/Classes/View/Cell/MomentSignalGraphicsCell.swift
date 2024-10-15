
import OUICore
//import ZLPhotoBrowser
import IGListKit
import SnapKit

/// 单张图片显示
class MomentSignalGraphicsCell: UICollectionViewCell {
    
    var onExpand: ((Int) -> Void)?
    var onTapAvatar: ((String?) -> Void)?
    var onPreview: ((Int, UIView) -> Void)?
    
    fileprivate lazy var avatarView: AvatarView = {
        let v = AvatarView()
        return v
    }()
    
    fileprivate lazy var nameLabel: UILabel = {
        let v = UILabel()
        v.font = UIFont.boldSystemFont(ofSize: 17)
        v.translatesAutoresizingMaskIntoConstraints = false
        v.setContentCompressionResistancePriority(UILayoutPriority(999), for: .vertical)
        
        return v
    }()
    
    fileprivate lazy var contentLabel: MomentLabel = {
        let v = MomentLabel()
        v.font = .f17
        v.numberOfLines = 0
        v.translatesAutoresizingMaskIntoConstraints = false
        v.setContentCompressionResistancePriority(UILayoutPriority(998), for: .vertical)
        
        return v
    }()
    
    /// 单张图片
    fileprivate lazy var singleImageView: UIImageView = {
        let v = UIImageView()
        v.clipsToBounds = true
        v.contentMode = .scaleAspectFit
        v.isUserInteractionEnabled = true
        v.isHidden = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(previewImage(_:)))
        v.addGestureRecognizer(tap)
        v.tag = 10
        
        return v
    }()
    
    lazy var playButton: UIImageView = {
        let v = UIImageView(image: .init(nameInBundle: "moments_video_play_icon"))
        
        return v
    }()
    
    fileprivate lazy var expandBtn: UIButton = {
        let v = UIButton(type: .custom)
        v.setTitle("展开".innerLocalized(), for: .normal)
        v.setTitle("收起".innerLocalized(), for: .selected)
        v.setTitleColor(.c0089FF, for: .normal)
        v.titleLabel?.font = .f14
        v.addTarget(self, action: #selector(expand(_:)), for: .touchUpInside)
        v.sizeToFit()
        v.isHidden = true
        
        return v
    }()
    
    var viewModel: MomentsInfo?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .cellBackgroundColor
        
        singleImageView.addSubview(playButton)
        playButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        singleImageView.snp.makeConstraints { make in
            make.width.equalTo(120.w)
        }
        
        expandBtn.snp.makeConstraints { make in
            make.height.equalTo(30)
        }
        
        let verSV = UIStackView(arrangedSubviews: [nameLabel, contentLabel, expandBtn, singleImageView])
        verSV.axis = .vertical
        verSV.spacing = MomentWidgetSpace
        verSV.alignment = .leading
        
        let horSV = UIStackView(arrangedSubviews: [avatarView, verSV])
        horSV.spacing = MomentWidgetSpace
        horSV.alignment = .top
        
        contentView.addSubview(horSV)
        horSV.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview().inset(MomentPadding)
            make.bottom.equalToSuperview()
        }
        
        setLabel()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setLabel() {
        contentLabel.enabledTypes = [.URL, .phone]
        contentLabel.handleURLTap { (text) in
            let url = URL(string: text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
        contentLabel.handlePhoneTap { (phone) in
            UIApplication.shared.openURL(URL(string: "tel://\(phone)")!)
        }
    }
    
    @objc func previewImage(_ ges: UIGestureRecognizer) {
        switch ges.view?.tag {
        case 10:
            if let images = self.viewModel?.images {
                let forVideo = self.viewModel?.content?.type == 1
                onPreview?(0, ges.view!)
            }
        default:
            break
        }
    }
    
    @objc func expand(_ btn: UIButton) {
        onExpand?(btn.tag)
    }
}

extension MomentSignalGraphicsCell: ListBindable {
    
    func bindViewModel(_ viewModel: Any) {
        guard let viewModel = viewModel as? MomentsInfo else { return }
        self.viewModel = viewModel
        
        let userState = SuperStringUtil.getUserState(showname: viewModel.nickname)
        
        avatarView.setAvatar(url: viewModel.faceURL, text: userState.n, onTap: { [weak self] in
            self?.onTapAvatar?(viewModel.faceURL)
        })
        
        nameLabel.text = userState.n
        contentLabel.text = viewModel.content?.text
        
        if viewModel.isNeedExpend {
            let isExpand = viewModel.isTextExpend ?? false
            expandBtn.isSelected = isExpand
            contentLabel.numberOfLines = isExpand ? 0 : 3
        }
        expandBtn.isHidden = !viewModel.isNeedExpend
        // 展示单张图片
        if !viewModel.images.isEmpty {
            singleImageView.isHidden = false
            singleImageView.setImage(with: viewModel.images.first!.thumb, placeHolder: "common_image_placeholder", showIndicator: true)
            let isVideo = viewModel.content?.type == 1
            playButton.isHidden = !isVideo
        }
        
        setNeedsLayout()
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        contentLabel.text = nil
        singleImageView.isHidden = true
        playButton.isHidden = true
    }
}

