
import OUICore
import RxSwift
import SnapKit
import ProgressHUD

class NewMessageViewController: UIViewController {
    
    private lazy var tableView: UITableView = {
        let v = UITableView()
        v.register(NewMessageCell.self, forCellReuseIdentifier:  NSStringFromClass(NewMessageCell.self))
        v.rowHeight = UITableView.automaticDimension
        v.estimatedRowHeight = 60
        v.backgroundColor = .clear
        
        if #available(iOS 15.0, *) {
            v.sectionHeaderTopPadding = 0
        }
        v.tableFooterView = UIView()
        
        return v
    }()
    
    let viewModel = NewMessageViewModel()
    let _disposeBag = DisposeBag()
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ProgressHUD.dismiss()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .viewBackgroundColor
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        bindData()
        viewModel.loadNewMessages()
        let clearButton = UIBarButtonItem(title: "清空".innerLocalized(), style: .done, target: self, action: #selector(clear))
        navigationItem.setRightBarButton(clearButton, animated: false)
    }
    
    @objc func clear() {
        presentAlert(title: "确认清空消息吗？".innerLocalized()) { [weak self] in
            self?.viewModel.clearNewMessage()
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
    func bindData() {
        viewModel.loading.subscribe(onNext: { isLoading in
            if isLoading {
                ProgressHUD.animate()
            } else {
                ProgressHUD.dismiss()
            }
        }).disposed(by: _disposeBag)
        
        let dateFormater = DateFormatter()
        dateFormater.dateStyle = .short
        
        viewModel.items.bind(to: tableView.rx.items(cellIdentifier: NSStringFromClass(NewMessageCell.self), cellType: NewMessageCell.self)) { _, model, cell in
            
            let c = model.content
            
            let modelState = SuperStringUtil.getUserState(showname: model.nickname)
            
            if let thumb = c?.metas.first?.thumb {
                cell.previewImageView.setImage(with: thumb.defaultThumbnailURLString, placeHolder: nil)
            } else {
                cell.trailingLabel.text = c?.text
            }
            
            cell.dateLabel.text = Date.timeString(timeInterval: TimeInterval(model.createTime))
            
            if model.type == .favor {
                let user = model.likeUsers.first
                
                let userState = SuperStringUtil.getUserState(showname: user?.nickname ?? "")
                
                
                cell.avatarView.setAvatar(url: user?.faceURL, text: userState.n)
                cell.nickNameLabel.text = userState.n
                // 为你点了赞
                var attach = NSTextAttachment()
                attach.bounds = .init(x: 0, y: -3, width: 16, height: 16)
                attach.image = .init(nameInBundle: "moments_thumb_selected_icon")
                
                let imageStr = NSAttributedString.init(attachment: attach)
                var contentString = NSMutableAttributedString.init(string:  " " + "likedWho".innerLocalizedFormat(arguments: modelState.n))
                contentString.insert(imageStr, at: 0)
                cell.contentLabel.attributedText = contentString
                
            } else if model.type == .mention {
                // 提到了你
                let user = model.atUsers.first
                
                let userState = SuperStringUtil.getUserState(showname: user?.nickname ?? "")
                
                cell.avatarView.setAvatar(url: user?.faceURL, text: userState.n)
                cell.nickNameLabel.text = userState.n
                cell.contentLabel.text = "mentionedWho".innerLocalizedFormat(arguments: model.nickname)
            } else {
                // 评论了你
                let comment = model.comments.first
                
                let userState = SuperStringUtil.getUserState(showname: comment?.nickname ?? "")
                
                cell.avatarView.setAvatar(url: comment?.faceURL, text: userState.n)
                cell.nickNameLabel.text = userState.n
                
                if let replyUserID = comment?.replyUserID, !replyUserID.isEmpty {
                    //回复：xxx ： 内容
                    cell.contentLabel.text = "repliedWho".innerLocalizedFormat(arguments: modelState.n, comment!.content)
                } else {
                   cell.contentLabel.text = "commentedWho".innerLocalizedFormat(arguments: modelState.n, comment!.content)
                }
            }
            
        }.disposed(by: _disposeBag)
        
        tableView.rx.modelSelected(NewMessageInfo.self).subscribe(onNext: { [weak self] info in
            
            let vc = MomentsViewController(momentID: info.workMomentID)
            self?.navigationController?.pushViewController(vc, animated: true)
        }).disposed(by: _disposeBag)
    }
}

class NewMessageCell: UITableViewCell {
    
    // 头像
    lazy var avatarView: AvatarView = {
        let v = AvatarView()
        return v
    }()
    
    // 名字
    lazy var nickNameLabel: UILabel = {
        let v = UILabel()
        v.font = .f17
        v.textColor = .c0C1C33
        
        return v
    }()
    
    // 内容
    lazy var contentLabel: UILabel = {
        let v = UILabel()
        v.font = .f14
        v.textColor = .c0C1C33
        
        return v
    }()
    
    // 时间
    lazy var dateLabel: UILabel = {
        let v = UILabel()
        v.font = .f12
        v.textColor = .c8E9AB0
        
        return v
    }()
    
    // 多媒体图
    lazy var previewImageView: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFill
        v.layer.masksToBounds = true
        
        return v
    }()
    
    // 文本内容
    lazy var trailingLabel: UILabel = {
        let v = UILabel()
        v.font = .f12
        v.textColor = .c0C1C33
        
        return v
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = .cellBackgroundColor
        
        let verSV = UIStackView(arrangedSubviews: [nickNameLabel, contentLabel, SizeBox(height: 8), dateLabel])
        verSV.axis = .vertical
        verSV.spacing = 8
        verSV.alignment = .leading
        
        let horSV = UIStackView(arrangedSubviews: [avatarView, verSV, previewImageView, trailingLabel])
        horSV.alignment = .top
        horSV.spacing = 8
        
        contentView.addSubview(horSV)
        horSV.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.bottom.equalToSuperview().inset(8)
        }
        
        previewImageView.snp.makeConstraints { make in
            make.size.equalTo(62)
        }
        previewImageView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        trailingLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        contentLabel.text = nil
        contentLabel.attributedText = nil
        trailingLabel.text = nil
        previewImageView.image = nil
    }
}
