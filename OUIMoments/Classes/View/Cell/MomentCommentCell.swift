
import Foundation
import SnapKit
import IGListKit

class MomentCommentCell: UICollectionViewCell {
    
    fileprivate lazy var likeUsersTextView: UITextView = {
        let v = UITextView()
        v.font = .systemFont(ofSize: 12)
        v.isEditable = false
        v.isScrollEnabled = false
        v.textColor = UIColor(hex: 0x333333)
        v.delegate = self
        v.backgroundColor = .clear
        v.textContainerInset = .zero
        v.showsVerticalScrollIndicator = false
        v.showsHorizontalScrollIndicator = false
        v.linkTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor(hex: 0x6085b1)]
        v.textContainer.lineFragmentPadding = 0;
        v.textContainer.maximumNumberOfLines = 2
        return v
    }()
    
    fileprivate lazy var commentsTableView: CommentsTableView = {
        let view = CommentsTableView(frame: .zero)
        return view
    }()
    
    fileprivate lazy var separatorV: UIView = {
        let v = UIView()
        v.backgroundColor = .systemGray6
        return v
    }()
    
    fileprivate lazy var verSV: UIStackView = {
        let v = UIStackView(arrangedSubviews: [likeUsersTextView, commentsTableView])
        v.axis = .vertical
        v.spacing = 4
        return v
    }()
    
    var onAction: MomentHandler?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .cellBackgroundColor
        
        contentView.addSubview(verSV)
        verSV.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().inset(MomentContentLeftPadding)
            make.trailing.equalToSuperview().inset(MomentPadding)
        }
        
        contentView.addSubview(separatorV)
        separatorV.snp.makeConstraints { make in
            make.top.equalTo(verSV.snp.bottom)
            make.height.equalTo(1)
            make.leading.bottom.trailing.equalToSuperview()
        }
        
        layer.drawsAsynchronously = true
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var viewModel: MomentsInfo?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        likeUsersTextView.attributedText = nil
        commentsTableView.comments = []
    }
}

extension MomentCommentCell: ListBindable {
    
    func bindViewModel(_ viewModel: Any) {
        guard let viewModel = viewModel as? MomentsInfo else { return }
        self.viewModel = viewModel
        
        let userState = SuperStringUtil.getUserState(showname: viewModel.nickname)
        
        if viewModel.likeUsersAttributedText == nil {
            // 这里有个低端逻辑
            likeUsersTextView.snp.remakeConstraints { make in
                make.height.equalTo(0)
            }
        } else {
            likeUsersTextView.snp.remakeConstraints { make in
                make.height.equalTo(viewModel.likeUsersHeight)
            }
            
            var attach = NSTextAttachment()
            attach.bounds = .init(x: 0, y: 0, width: 10, height: 10)
            attach.image = .init(nameInBundle: "moments_thumb_selected_icon")
            let attachStr = NSMutableAttributedString.init(attachment: attach)
            attachStr.append(NSAttributedString(string: " "))
            attachStr.append(viewModel.likeUsersAttributedText!)
            
            likeUsersTextView.attributedText = attachStr
        }
        
        // 没有评论的话
        if !viewModel.comments.isEmpty {
            commentsTableView.comments = viewModel.comments
            commentsTableView.onAction = { [weak self] (replayUserID, action) in
                guard let `self` = self else {return}
                self.onAction?(replayUserID, action)
            }
            commentsTableView.scrollCallback = { [weak self] maxIndex in
                
                guard let `self` = self else { return .zero }
                
                var rect = self.frame
                rect.origin.y += self.commentsTableView.frame.minY
                
                var height: CGFloat = 0
                for idx in 0..<viewModel.comments.count {
                    let model = viewModel.comments[idx]
                    height += model.commentHeight
                    height += 4 // 展示内容的textview，上下padding
                }
                
                rect.origin.y += height
                rect.size.height = 10
                
                return rect
            }
        }
    }
}

extension MomentCommentCell: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        print("\(URL)")
        
        return false
    }
}
