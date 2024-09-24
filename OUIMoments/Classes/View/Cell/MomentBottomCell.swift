
import Foundation
import IGListKit
import SnapKit

class MomentBottomCell: UICollectionViewCell {
    
    private lazy var timeLabel: UILabel = {
        let v = UILabel()
        v.sizeToFit()
        v.textColor = .systemGray2
        v.font = .f12
        
        return v
    }()
    
    private lazy var deleteBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        btn.setTitleColor(.systemBlue, for: .normal)
        btn.setTitle("删除".innerLocalized(), for: .normal)
        btn.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
        btn.tag = 1
        return btn
    }()
    
    lazy var metionLabel: UILabel = {
        let v = UILabel()
        v.textColor = .systemGray3
        v.font = .f12
        
        return v
    }()
    
    private lazy var permissionBtn: UIButton = {
        let v = UIButton(type: .custom)
        v.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
        v.tag = 2
        return v
    }()
    
    private lazy var moreBtn: UIButton = {
        let v = UIButton(type: .custom)
        v.setImage(UIImage(nameInBundle: "moments_more_icon"), for: .normal)
        v.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
        
        return v
    }()
    
    var onAction: MomentHandler?
    /// The top cell of the section, which is the avatar part
    var onRelativeRect: (() -> CGRect)?
    var isLiked: (() -> Bool)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .cellBackgroundColor
        
        let horSV = UIStackView(arrangedSubviews: [timeLabel, permissionBtn, deleteBtn, UIView(), moreBtn])
        horSV.alignment = .center
        horSV.spacing = 8
        
        let verSV = UIStackView(arrangedSubviews: [metionLabel, horSV])
        verSV.axis = .vertical
        
        contentView.addSubview(verSV)
        verSV.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(MomentContentLeftPadding)
            make.trailing.equalToSuperview().inset(MomentPadding)
            make.top.bottom.equalToSuperview()
        }
        
        moreBtn.snp.makeConstraints { make in
            make.width.equalTo(40)
        }
    }
    
    fileprivate lazy var commentnputView: CommentInputView = {
        let inputView = CommentInputView()
        inputView.delegate = self
        return inputView
    }()
    
    var viewModel: MomentsInfo?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        permissionBtn.isEnabled = false
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    @objc func click(_ btn: UIButton) {
        switch btn.tag {
        case 0:
            // more
            OperateMenuView.show(self.moreBtn, isLiked: self.viewModel?.likesContainsSelf ?? false, canComment: true) {[weak self] idx in
                guard let `self` = self else { return }
                if idx == 0 {
                    self.onAction?(nil, .thumbup)
                }else {
                    self.commentnputView.show()
                }
            }
        case 1:
            // delete
            self.onAction?(nil, .delete)
        case 2:
            // permissions
            self.onAction?(nil, .permisson)
        default:
            break
        }
    }
}

extension MomentBottomCell: ListBindable {
    
    func bindViewModel(_ viewModel: Any) {
        guard let viewModel = viewModel as? MomentsInfo else { return }
        self.viewModel = viewModel
        timeLabel.text = Date.timeString(timeInterval: TimeInterval(viewModel.createTime))
        timeLabel.sizeToFit()
        deleteBtn.isHidden = !viewModel.isMine
        metionLabel.text = viewModel.atUsers.isEmpty ? nil : "提到了".innerLocalized() + ":" + viewModel.atUsers.map {$0.nickname}.joined(separator: "、")
        
        // Show private/partially visible icons
        if viewModel.permission == 0 || !viewModel.isMine {
            permissionBtn.isHidden = true
        } else if viewModel.permission == 1 {
            permissionBtn.isHidden = false
            permissionBtn.setImage(UIImage(nameInBundle: "moments_private_icon"), for: .normal)
        } else {
            permissionBtn.isHidden = false
            permissionBtn.setImage(UIImage(nameInBundle: "moments_part_icon"), for: .normal)
            permissionBtn.isEnabled = true
        }
        
    }
}

extension MomentBottomCell: CommentInputViewDelegate {
    func onTopChanged(_ top: CGFloat) {
        if let onRelativeRect = onRelativeRect {
            commentnputView.scrollForComment(onRelativeRect())
        }
    }
    
    func onTextChanged(_ text: String) {
        print("comment draft: \(text)")
        self.onAction?(nil, .commentDraft(text))
    }
    
    func onSend(_ text: String) {
        if !text.isEmpty {
            self.onAction?( nil, .comment(text))
        }
    }
}
