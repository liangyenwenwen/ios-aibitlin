
import Foundation

class CommentsTableView: UITableView {
    
    var comments = [Comment]() {
        didSet {
            reloadData()
        }
    }
    
    var onAction: MomentHandler?
    var scrollCallback: ((_ maxIndex: Int) -> CGRect)?
    
    fileprivate lazy var commentnputView: CommentInputView = {
        let inputView = CommentInputView()
        inputView.delegate = self
        return inputView
    }()
    
    fileprivate var selectRow: IndexPath?
    
    init(frame: CGRect) {
        super.init(frame: frame, style: .plain)
        self.delegate = self
        self.dataSource = self
        self.backgroundColor = .clear
        self.rowHeight = UITableView.automaticDimension
        self.estimatedRowHeight = 20
        self.isScrollEnabled = false
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.separatorStyle = .none
        register(CommentContentCell.self, forCellReuseIdentifier: NSStringFromClass(CommentContentCell.self))
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func tapContentBg() {
        guard let indexPath = selectRow else {
            return
        }
        let model = comments[indexPath.item]
        commentnputView.textView.placeholder = "回复".innerLocalized() + "\(SuperStringUtil.getUserState(showname: model.nickname!).n)"
        commentnputView.show()
        
        onAction?(model.userID, .bg(model.isSelf!))
    }
}

extension CommentsTableView: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(CommentContentCell.self), for: indexPath) as! CommentContentCell
        let model = comments[indexPath.item]
        cell.commentTextView.attributedText = model.commentAttributedText
        
        cell.canLongPress = {
            return model.isSelf ?? false
        }
        
        cell.onClick = {[weak self] (action: MomentAction) in
            switch action {
            case .deleteComment:
                self?.onAction?(model.commentID, action)
            default:
                self?.onAction?(model.replyUserID, action)
            }
        }
        
        cell.onTextClick = {[weak self] in
            self?.selectRow = indexPath
            self?.tapContentBg()
        }
        return cell
    }
}

extension CommentsTableView: CommentInputViewDelegate {
    
    func onTopChanged(_ top: CGFloat) {
        guard let indexPath = selectRow else {
            return
        }
        
        let rect = scrollCallback?(indexPath.item)
        
        if let r = rect {
            commentnputView.scrollForComment(r)
        }
    }
    
    func onTextChanged(_ text: String) {
        print("onTextChanged: \(text)")
        guard let indexPath = selectRow else {
            return
        }
        let model = comments[indexPath.item]
        onAction?(model.userID, .commentDraft(text))
    }
    
    func onSend(_ text: String) {
        print("onSend: \(text)")
        guard let indexPath = selectRow, !text.isEmpty else {
            return
        }
        let model = comments[indexPath.item]
        onAction?(model.userID, .comment(text))
    }
}
